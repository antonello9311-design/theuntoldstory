-- Frammento transazionale: usare soltanto MISSION_EXAM_RELEASE_RECOVERY.sql.
-- Recovery nominativo; helper conservato inerte.
DO $publisher_preflight$
BEGIN
 IF md5(pg_get_functiondef('_esame_supervisione_post(uuid,uuid,text)'::regprocedure)) IS DISTINCT FROM 'd66a4065aadc0b3f8f2878f6ebbad307' THEN RAISE EXCEPTION 'mission_session_publisher_recovery_drift: _esame_supervisione_post(uuid,uuid,text)'; END IF;
 IF md5(pg_get_functiondef('esame_narrazione_apply(uuid,uuid,text,text,jsonb,text,integer,text,numeric,integer,integer,text,text,jsonb)'::regprocedure)) IS DISTINCT FROM 'd0d87f769e5f9d0a0ed297d8f8e9f5f1' THEN RAISE EXCEPTION 'mission_session_publisher_recovery_drift: esame_narrazione_apply(uuid,uuid,text,text,jsonb,text,integer,text,numeric,integer,integer,text,text,jsonb)'; END IF;
 IF md5(pg_get_functiondef('esame_supervisione_pubblica(uuid,text)'::regprocedure)) IS DISTINCT FROM '0dff42af684620cbea00682693063be4' THEN RAISE EXCEPTION 'mission_session_publisher_recovery_drift: esame_supervisione_pubblica(uuid,text)'; END IF;
END $publisher_preflight$;
CREATE OR REPLACE FUNCTION public.esame_supervisione_pubblica(p_bozza uuid, p_sha text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare b public.esame_supervisione_bozze%rowtype; h public.esame_supervisione%rowtype; v public.esame_prove%rowtype;
  j jsonb; u jsonb; t jsonb; v_loc uuid; res jsonb; mid uuid; v_ready boolean;
begin
  perform public._esame_supervisione_staff();
  select * into b from public.esame_supervisione_bozze where id=p_bozza;
  if not found then raise exception 'Bozza assente'; end if;
  select * into v from public.esame_prove where id=b.prova for update;
  select * into h from public.esame_supervisione where prova=b.prova for update;
  select * into b from public.esame_supervisione_bozze where id=p_bozza for update;
  if b.stato<>'pronta' or b.sha is distinct from p_sha or v.stato<>'aperta' then raise exception 'Bozza non approvabile'; end if;
  if b.ricevuta is distinct from (case when h.apertura_pubblicata then v.opzioni_id else h.apertura_ricevuta end) then
    raise exception 'Ricevuta scaduta';
  end if;
  j:=case when b.tipo='apertura' then h.apertura_fatti else public._esame_ciclo_payload(b.prova) end;
  if public._esame_supervisione_hash(j) is distinct from b.payload_sha then raise exception 'Fonti cambiate: approvazione invalidata'; end if;
  if b.risultato->>'ok' is distinct from 'true' or b.risultato->>'validator_version' is distinct from 'SHION-HOLD-001' then
    raise exception 'Controlli non verdi o versione non riconosciuta';
  end if;
  update public.esame_supervisione set publishing=true where prova=b.prova;
  if b.tipo='apertura' then
    if length(b.risultato->>'testo') not between 1 and 4000
      or b.risultato->>'testo' is distinct from btrim(b.risultato->>'testo') then
      raise exception 'Apertura non pubblicabile integralmente';
    end if;
    select location_id into v_loc from public.academy_class_sessions where id=v.class_session_id;
    mid:=public._esame_supervisione_post(b.prova,v_loc,b.risultato->>'testo');
    if mid is null then raise exception 'Apertura non pubblicata'; end if;
    update public.esame_supervisione set apertura_pubblicata=true where prova=b.prova;
    res:=jsonb_build_object('ok',true,'pubblicato','apertura','message_id',mid);
  else
    u:=b.risultato->'uscita'; t:=b.risultato->'telemetria';
    res:=public.esame_narrazione_apply(b.prova,b.ricevuta,u->>'intenzione_id',u->>'azione_png',u->'esiti',
      t->>'model',(b.risultato->>'prompt_version')::integer,b.risultato->>'impronta_prompt',null,
      (t->>'input_tokens')::integer,(t->>'output_tokens')::integer,t->>'stop_reason',null,
      jsonb_build_object('supervisione_bozza',b.id,'approvata_da',auth.uid(),'chiamate',1));
    if res->>'ripiego'='true' or res->>'scartato'='true' or res->>'pubblicato' is null then
      raise exception 'Pubblicazione rifiutata: stato e bozza conservati';
    end if;
  end if;
  v_ready:=not exists(select 1 from public.esame_narrazione_cicli where prova_id=b.prova and stato='aperta');
  update public.esame_supervisione set publishing=false,player_ready=v_ready,
    pausa_totale=pausa_totale+(now()-pausa_da),pausa_da=now(),
    idle_deadline=case when v_ready then now()+interval '3 hours' else null end where prova=b.prova;
  update public.esame_supervisione_bozze set stato='pubblicata',approvata_da=auth.uid(),pubblicata_at=now() where id=b.id;
  return res;
end; $function$;
CREATE OR REPLACE FUNCTION public.esame_narrazione_apply(p_prova uuid, p_ricevuta uuid, p_intenzione_id text, p_azione text, p_esiti jsonb, p_model text DEFAULT NULL::text, p_prompt_version integer DEFAULT NULL::integer, p_impronta_prompt text DEFAULT NULL::text, p_temperatura numeric DEFAULT NULL::numeric, p_input_tokens integer DEFAULT NULL::integer, p_output_tokens integer DEFAULT NULL::integer, p_stop_reason text DEFAULT NULL::text, p_errori text DEFAULT NULL::text, p_ctx jsonb DEFAULT NULL::jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  c public.esame_narrazione_cicli%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_loc uuid; v_int jsonb; v_e jsonb; v_attesi text[];
  v_motivo text; v_res jsonb; v_mid uuid; v_ctx jsonb; v_ok boolean;
  v_prec public.esame_narrazione_cicli%rowtype; v_unificato text;
begin
  -- ── il lock, e l'ordine: prova poi ricevuta, sempre in questo verso ──────
  -- Il ripiego (`esame_prova_tick`) prende gli stessi due lock nello stesso
  -- ordine. Invertirli qui sarebbe un deadlock che si vede solo sotto corsa —
  -- e una corsa è esattamente ciò che questa funzione deve reggere.
  select * into v from public.esame_prove where id = p_prova for update;
  if not found then
    return jsonb_build_object('versione',4,'ok',false,'motivo','prova inesistente');
  end if;
  if v.stato <> 'aperta' then
    return jsonb_build_object('versione',4,'ok',false,'motivo','prova non aperta');
  end if;

  if public._esame_supervisione_blocca(p_prova) then
    return jsonb_build_object('ok',false,'supervisione',true,'pubblicato',false);
  end if;

  select * into c from public.esame_narrazione_cicli
   where opzioni_id = p_ricevuta for update;

  -- ── LO SCONTRINO ─────────────────────────────────────────────────────────
  -- Tre modi di essere in ritardo, e sono tutti la stessa risposta: «scaduta»,
  -- non «errore». HTTP 200, `scartato:true`, ZERO messaggi, ZERO righe
  -- d'audit, ZERO effetti (gate E-27). Sopra questa riga non si scrive niente.
  if not found
     or c.prova_id <> p_prova
     or c.stato <> 'aperta'
     or v.opzioni_id is null
     or v.opzioni_id is distinct from p_ricevuta then
    return jsonb_build_object('versione',4,'ok',false,'scartato',true,
             'motivo','ricevuta scaduta: la prova è già andata avanti');
  end if;

  select * into v_prof from public.esame_png_profili where id = v.profilo_id;
  select location_id into v_loc from public.academy_class_sessions
   where id = v.class_session_id;

  -- ── l'intenzione dev'essere una di quelle OFFERTE ────────────────────────
  -- ═══ [R2b · TROVATO DALLA PARITÀ DELLA EDGE] `max_tokens` PRIMA DI TUTTO ══
  -- 🔴 In R2 questo blocco stava sotto la ricerca dell'intenzione, ed era un
  --    difetto vero: `max_tokens` si manifesta NORMALMENTE come JSON troncato a
  --    metà, cioè **senza `intenzione_id`**. La ricerca falliva per prima e
  --    l'audit registrava `motivo_ripiego = 'intenzione inventata'` invece di
  --    `tetto_token_raggiunto` — e il corpus dei tetti sarebbe nato misurando
  --    una causa inventata, che è esattamente ciò che il commento qui sotto
  --    dice di voler evitare. Il difetto era il commento giusto messo un passo
  --    troppo in basso.
  --    Lo ha trovato la prova di parità della Edge chiamando questa porta per
  --    nome, non rileggendo il SQL: `R2-K3` non lo copriva perché provava con
  --    un `intenzione_id` valido, cioè con un troncamento che non troncava.
  --
  -- ⚠️ Il blocco NON usa `v_e`: può stare qui, e qui deve stare. Sotto restano
  --    soltanto le cause che presuppongono una risposta ARRIVATA INTERA.
  -- 🔴 In R1 questa regola viveva SOLO nella Edge, ed era l'unico punto del
  --    contratto in cui «se le due dicessero cose diverse ha ragione il
  --    database» non si poteva applicare: il database non aveva niente da dire.
  --    `p_stop_reason` arrivava, veniva archiviato, e non giudicava nulla.
  --
  -- Una risposta tagliata al tetto si scarta **anche se il JSON risulta
  -- intero**: una chiusura fortunata non è una chiusura voluta. Il modello
  -- stava ancora scrivendo, e ciò che manca è precisamente ciò che non sappiamo
  -- — l'ultima branca può essere finita a metà frase e restare sintatticamente
  -- valida.
  --
  -- ⚠️ STA PRIMA del validatore, e l'ordine è una scelta: se venisse dopo, un
  --    JSON tagliato che è ANCHE invalido finirebbe nell'audit col motivo
  --    sbagliato («branca mancante» invece di «tetto raggiunto»), e il corpus
  --    dei tetti si misurerebbe su una causa inventata. Il motivo giusto è
  --    quello che poi decide se alzare il tetto.
  if lower(btrim(coalesce(p_stop_reason,''))) = 'max_tokens' then
    return public._esame_ciclo_ripiego(p_prova, p_ricevuta,
             'tetto_token_raggiunto: stop_reason=max_tokens, risposta scartata prima di qualunque pubblicazione',
             p_model, p_prompt_version, p_impronta_prompt, p_input_tokens,
             p_output_tokens, p_stop_reason, p_errori, p_ctx, p_azione);
  end if;


  select e into v_e
    from jsonb_array_elements(coalesce(v.opzioni_png->'intenzioni','[]'::jsonb)) e
   where e->>'intenzione_id' = p_intenzione_id;

  if v_e is null then
    -- Un'opzione inventata non solleva e non pubblica: registra e degrada.
    -- Una prova non deve mai restare senza continuazione.
    return public._esame_ciclo_ripiego(p_prova, p_ricevuta, 'intenzione inventata',
             p_model, p_prompt_version, p_impronta_prompt, p_input_tokens,
             p_output_tokens, p_stop_reason, p_errori, p_ctx, p_azione);
  end if;

  select coalesce(array_agg(x order by x), array[]::text[]) into v_attesi
    from jsonb_array_elements_text(coalesce(v_e->'esiti_possibili','[]'::jsonb)) x;

  -- [095] L'Assalto ha due esiti autoritativi propri. Il payload IA li ha già
  -- ricevuti da _esame_ciclo_payload: la porta di rientro deve convalidare lo
  -- stesso insieme, non le branche generiche della reazione PNG.
  if c.ruolo = 'png_difende'
     and v.pend_azione->'principale'->>'fonte' = 'moltiplicazione'
     and v.pend_azione->'principale'->>'modalita' = 'assalto' then
    v_attesi := array['copia_colpita','originale_individuato']::text[];
  end if;

  -- [084-A15] La freschezza è già garantita dall'opzioni_id monouso.
  -- Le branche valide sono quelle della singola intenzione scelta,
  -- rilette dalla stessa opzioni_png congelata e validate qui sotto.

  -- ── il validatore, DENTRO la transazione ─────────────────────────────────
  v_motivo := public._esame_narrazione_valida(p_azione, p_esiti, v_attesi, c.ruolo);

  -- Un'intenzione senza esiti (manovra, diversivo) non porta branche: la mappa
  -- dev'essere l'oggetto vuoto, e il validatore lo pretende già per identità.
  if v_motivo is not null then
    -- 🔴 NESSUNA SECONDA CHIAMATA. «Una chiamata modello per ciclo significa
    --    una, non una più la correzione» (contratto §2). Il JSON rotto, il
    --    troncamento e la branca mancante finiscono tutti qui.
    return public._esame_ciclo_ripiego(p_prova, p_ricevuta, v_motivo,
             p_model, p_prompt_version, p_impronta_prompt, p_input_tokens,
             p_output_tokens, p_stop_reason, p_errori, p_ctx, p_azione);
  end if;

  -- ── SI CONSUMA LO SCONTRINO, e da qui il ciclo è di questa chiamata ──────
  update public.esame_prove
     set opzioni_png = null, opzioni_id = null, opzioni_at = null
   where id = p_prova;

  update public.esame_narrazione_cicli set
    stato           = 'accettata',
    intenzione_id   = p_intenzione_id,
    azione_png      = btrim(p_azione),
    esiti           = p_esiti,
    esiti_attesi   = v_attesi,
    receipt_sha256  = public._esame_ricevuta_sigillo(
                        c.opzioni_id, p_intenzione_id, btrim(p_azione), p_esiti, v_attesi),
    model           = nullif(btrim(coalesce(p_model,'')),''),
    prompt_version  = p_prompt_version,
    impronta_prompt = nullif(btrim(coalesce(p_impronta_prompt,'')),''),
    temperatura     = p_temperatura,
    input_tokens    = p_input_tokens,
    output_tokens   = p_output_tokens,
    stop_reason     = p_stop_reason,
    accepted_at     = now()
  where id = c.id;

  v_ctx := coalesce(p_ctx,'{}'::jsonb) || jsonb_build_object(
             'contratto_ciclo', 4,
             'ricevuta',        c.opzioni_id,
             'branche',         jsonb_array_length(coalesce(jsonb_path_query_array(p_esiti,'$.keyvalue()'),'[]'::jsonb)),
             'stop_reason',     p_stop_reason,
             'input_tokens',    p_input_tokens,
             'output_tokens',   p_output_tokens);

  insert into public.esame_ia_tentativi
    (prova_id, scambio, meta, attempt, model, prompt_version, esito,
     opzione_scelta, errori, ctx, chars)
  values (p_prova, v.scambio, v.meta, 1,
          nullif(btrim(coalesce(p_model,'')),''), p_prompt_version,
          'pubblicato', p_intenzione_id,
          nullif(btrim(coalesce(p_errori,'')),''), v_ctx,
          length(btrim(coalesce(p_azione,''))));

  -- [098] Il finale salda l'ultimo esito e il congedo del Sensei.
  if c.ruolo = 'png_finale' then
    v_mid := public._esame_supervisione_post(p_prova,v_loc,
      regexp_replace(btrim(p_azione),'[[:space:]]+',' ','g'));
    update public.esame_narrazione_cicli
       set stato='risolta', result_message_id=v_mid, resolved_at=now()
     where id=c.id;
    update public.esame_prove set
      meta='candidato', fase='uscita', pend_azione=null,
      opzioni_png=null, opzioni_id=null, opzioni_at=null
    where id=p_prova and stato='aperta';
    return jsonb_build_object('versione',4,'ok',true,'ricevuta',c.opzioni_id,
      'pubblicato','finale completo','attende','role di uscita');
  end if;

  -- [095/27] Il terzo ruolo narra un fatto già chiuso dal motore.
  if c.ruolo = 'png_esito' then
    v_mid := public._esame_supervisione_post(p_prova,v_loc,
      regexp_replace(btrim(p_azione),'[[:space:]]+',' ','g'));
    update public.esame_narrazione_cicli
       set stato='risolta', result_message_id=v_mid, resolved_at=now()
     where id=c.id;
    update public.esame_narrazione_cicli
       set result_message_id=v_mid
     where id=(select x.id from public.esame_narrazione_cicli x
                where x.prova_id=p_prova and x.ruolo='png_attacca'
                  and x.stato='risolta' and x.result_message_id is null
                order by x.resolved_at desc nulls last,x.created_at desc,x.id desc
                limit 1);
    return jsonb_build_object('versione',4,'ok',true,'ricevuta',c.opzioni_id,
      'pubblicato','esito dopo difesa reale');
  end if;

  -- ── si GIOCA la mossa PRIMA di pubblicare l'AZIONE ───────────────────────
  -- 🔴 L'ordine è il difetto che questo candidato chiude. `esame_png_apply`
  --    pubblicava `p_testo` e POI chiamava `_esame_png_gioca`: se la mossa
  --    veniva rifiutata (uno spostamento a effetto zero, un'intenzione non più
  --    legale), in chat restava un'azione che non è mai accaduta.
  --    Qui si gioca prima. Se il motore rifiuta, la ricevuta torna al ripiego e
  --    NIENTE è stato pubblicato.
  v_res := public._esame_png_gioca(p_prova, coalesce(v_e->>'chiave', p_intenzione_id), 'ia');

  -- 🔴 [BANCO 038 · difetto 1] `_esame_png_gioca` NON restituisce sempre `ok`.
  --    Quando l'intenzione è una REAZIONE — cioè in tutto il ramo `png_difende`,
  --    che è il cuore del contratto §3 — delega a `_esame_risolvi`, e quella
  --    restituisce `{versione, ordine, esito, esito_copie, colpito, striscio,
  --    danno}`: nessun `ok`. Leggerlo con `coalesce(…,false)` faceva quindi
  --    scattare il ramo «mossa rifiutata dal motore» su OGNI difesa RIUSCITA:
  --    la ricevuta appena risolta veniva marcata `scartata`, la prova degradata
  --    a `ia_degradata=true`, nasceva una seconda riga `esame_ia_tentativi` e
  --    `_esame_ciclo_ripiego` pubblicava un SECONDO messaggio del Narratore.
  --    Misurato dal banco su §B6/§B8: due messaggi invece di uno.
  --    Un rifiuto è tale solo se il motore lo DICE: `ok` assente più `esito`
  --    presente vuol dire «lo scambio è stato risolto», non «è fallito».
  v_ok := case when v_res ? 'ok' then coalesce((v_res->>'ok')::boolean, false)
               else (v_res ? 'esito') end;

  if not v_ok then
    update public.esame_narrazione_cicli
       set stato = 'scartata', resolved_at = now()
     where id = c.id;
    return public._esame_ciclo_ripiego(p_prova, null,
             'mossa rifiutata dal motore: ' || coalesce(v_res->>'motivo','?'),
             p_model, p_prompt_version, p_impronta_prompt, p_input_tokens,
             p_output_tokens, p_stop_reason, p_errori, p_ctx, p_azione);
  end if;

  -- ── (a) il PNG si DIFENDEVA: `_esame_risolvi` ha già pubblicato AZIONE+ESITO
  -- in UN messaggio solo, leggendo la ricevuta. Qui non resta niente da fare.
  if c.ruolo = 'png_difende' then
    return v_res || jsonb_build_object('versione',4,'ricevuta',c.opzioni_id,
                      'pubblicato','azione+esito');
  end if;

  -- ── (b) il PNG ha ATTACCATO: si pubblica la SOLA AZIONE ──────────────────
  select * into v_prec
    from public.esame_narrazione_cicli
   where prova_id = p_prova
     and ruolo = 'png_difende'
     and stato = 'risolta'
     and result_message_id is null
     and coalesce((referto->>'legacy')::boolean, false) = false
     and (referto is not null or nullif(btrim(testo_esito),'') is not null)
   order by resolved_at desc nulls last, created_at desc, id desc
   limit 1 for update;

  if found then
    -- 🔴 QUI STAVA LA SALDATURA. `testo_esito` era prosa di catalogo e veniva
    --    incollata davanti al testo del modello: due voci, la difesa raccontata
    --    due volte, e la contraddizione fra «a segno» del server e «assorbe
    --    l'urto» del modello. Adesso il modello ha ricevuto `esito_precedente`
    --    e ha scritto il racconto INTERO: si pubblica il suo testo e basta.
    -- 🔴 [A5] E NON si accoda l'appendice. Il messaggio pubblicato è la sola
    --    prosa del modello: `v_prec.referto->>'appendice'` resta dov'è —
    --    nel referto, per l'audit — e non attraversa più la chat.
    v_unificato := btrim(p_azione);
    v_mid := public._esame_supervisione_post(p_prova,v_loc, v_unificato);
    update public.esame_narrazione_cicli
       set result_message_id = v_mid
     where id = v_prec.id;
  else
    -- Fail-safe per prove storiche senza il nuovo deposito: una sola azione,
    -- comunque compatta e senza intestazione tecnica.
    v_mid := public._esame_supervisione_post(p_prova,v_loc, btrim(p_azione));
  end if;

  -- Una manovra e un diversivo non lasciano nessuna mossa in attesa: non ci
  -- sarà nessun ESITO, e la ricevuta si chiude qui. Non è una mancanza: è
  -- un'azione che chiude la metà, e dirlo è più onesto che inventare un esito.
  if v_res->>'genere' in ('manovra','diversivo') or coalesce(array_length(v_attesi,1),0) = 0 then
    update public.esame_narrazione_cicli
       set stato = 'risolta', action_message_id = v_mid, resolved_at = now()
     where id = c.id;
    return v_res || jsonb_build_object('versione',4,'ricevuta',c.opzioni_id,
                      'pubblicato','azione');
  end if;

  update public.esame_narrazione_cicli
     set action_message_id = v_mid
   where id = c.id;

  return v_res || jsonb_build_object('versione',4,'ricevuta',c.opzioni_id,
                    'pubblicato','azione','attende','difesa del candidato');
end
$function$;
CREATE OR REPLACE FUNCTION public._esame_supervisione_post(p_prova uuid, p_location uuid, p_corpo text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not exists(select 1 from public.esame_prove e join public.academy_class_sessions s on s.id=e.class_session_id
    where e.id=p_prova and s.location_id=p_location) then raise exception 'Prova e stanza non corrispondono'; end if;
  if public._esame_supervisione_blocca(p_prova) then raise exception 'Supervisione: manca approvazione della bozza'; end if;
  return public._esame_narratore_post(p_location,p_corpo);
end; $function$;
REVOKE ALL ON FUNCTION public._esame_mission_formato(text,jsonb,text[]) FROM PUBLIC,anon,authenticated,service_role;
