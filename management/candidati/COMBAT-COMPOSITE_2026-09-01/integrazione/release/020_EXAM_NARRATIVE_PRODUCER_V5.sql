-- PROD-V5-01. Owner Spatial. Adattatore di fatti server, nessun nuovo esito.
CREATE OR REPLACE FUNCTION public._esame_payload_v5_complete_v1(p_prova uuid, p_payload jsonb)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
 p public.esame_prove%rowtype; c public.esame_narrazione_cicli%rowtype;
 s public.esame_scambi%rowtype; ev combat_spatial.spatial_events%rowtype;
 j public.jutsu%rowtype; raw_ref jsonb; audit jsonb; b jsonb; a jsonb;
 card_ids uuid[]:=array['31b15861-fb78-4f8a-ac1c-ebf2d957c32e','2270eaf1-f131-47e0-b0af-a8da0797ae11','c6e31b7b-38fe-4b4f-b3c7-05f3e922d193']::uuid[];
 cards jsonb:='[]'; intents jsonb:='[]'; it jsonb; source_it jsonb; tid uuid;
 defender text; label text; before_description text; after_description text;
 distance_after numeric; before_x numeric; before_y numeric; after_x numeric; after_y numeric;
 width_m numeric; height_m numeric; authority text; timeline jsonb; round_no integer;
BEGIN
 IF p_payload IS NULL THEN RETURN NULL; END IF;
 SELECT * INTO STRICT p FROM public.esame_prove WHERE id=p_prova;
 SELECT * INTO STRICT c FROM public.esame_narrazione_cicli
  WHERE prova_id=p_prova AND opzioni_id=(p_payload->>'ricevuta_id')::uuid;
 -- Identita tecniche solo dalle intenzioni della stessa finestra owner.
 FOR it IN SELECT value FROM jsonb_array_elements(p_payload->'intenzioni') LOOP
  tid:=NULL; source_it:=NULL;
  IF NOT coalesce((p_payload->>'replay')::boolean,false) AND p.opzioni_id=c.opzioni_id THEN
   SELECT value INTO source_it FROM jsonb_array_elements(coalesce(p.opzioni_png->'intenzioni','[]'))
    WHERE value->>'intenzione_id'=it->>'id';
   IF source_it->>'reazione'='sostituzione' THEN
    tid:='31b15861-fb78-4f8a-ac1c-ebf2d957c32e';
   ELSIF source_it->>'reazione'='copie' OR source_it->>'genere'='diversivo' THEN
    tid:='c6e31b7b-38fe-4b4f-b3c7-05f3e922d193';
   ELSIF left(source_it->>'principale',6)='jutsu:' THEN
    tid:=substring(source_it->>'principale' FROM 7)::uuid;
   END IF;
  END IF;
  IF tid IS NOT NULL THEN
   it:=it||jsonb_build_object('tecnica_id',tid::text);
   IF NOT tid=ANY(card_ids) THEN card_ids:=array_append(card_ids,tid); END IF;
  END IF;
  intents:=intents||jsonb_build_array(it);
 END LOOP;
 FOR tid IN SELECT unnest(card_ids) LOOP
  SELECT * INTO STRICT j FROM public.jutsu WHERE id=tid AND is_active;
  IF nullif(btrim(j.name_it),'') IS NULL OR nullif(btrim(j.category),'') IS NULL
     OR nullif(btrim(j.action_type),'') IS NULL OR nullif(btrim(j.effect),'') IS NULL
     OR j.chakra_cost IS NULL THEN RAISE EXCEPTION 'EXAM_V5_CANONICAL_CARD_INCOMPLETE:%',tid; END IF;
  -- jutsu non ha una colonna description: effect e' la descrizione canonica.
  -- action_type e' tipologia, NON sequenza/preparazione/sigilli.
  -- limits e' deliberatamente ESCLUSO: contiene anche vecchie scale numeriche.
  cards:=cards||jsonb_build_array(jsonb_build_object('id',j.id::text,'nome',j.name_it,
   'categoria',j.category,'attivazione',j.action_type,'descrizione',j.effect,
   'effetto',j.effect,'chakra',j.chakra_cost::text));
 END LOOP;
 p_payload:=p_payload||jsonb_build_object('intenzioni',intents,'schede_tecniche',cards,
  'schede_tecniche_provenienza',jsonb_build_object('fonte','public.jutsu',
   'descrizione','effect, duplicato come effetto; adattamento canonico, non revisione editoriale',
   'attivazione','action_type: tipo, non istruzioni di preparazione',
   'limits','escluso; portata e posizione restano autorita del resolver'));
 IF p_payload#>>'{esito_precedente,esito}' IS DISTINCT FROM 'sostituito' THEN RETURN p_payload; END IF;
 IF c.ruolo IN ('png_esito','png_finale') THEN raw_ref:=c.referto;
 ELSIF coalesce((p_payload->>'replay')::boolean,false) THEN
  SELECT x.referto INTO raw_ref FROM public.esame_narrazione_cicli x
   WHERE x.prova_id=p_prova AND x.ruolo='png_difende' AND x.stato='risolta' AND x.created_at<c.created_at
   ORDER BY x.resolved_at DESC NULLS LAST,x.created_at DESC LIMIT 1;
 ELSE
  SELECT x.referto INTO raw_ref FROM public.esame_narrazione_cicli x
   WHERE x.prova_id=p_prova AND x.ruolo='png_difende' AND x.stato='risolta'
     AND x.result_message_id IS NULL AND coalesce((x.referto->>'legacy')::boolean,false)=false
   ORDER BY x.resolved_at DESC NULLS LAST,x.created_at DESC,x.id DESC LIMIT 1;
 END IF;
 IF raw_ref IS NULL OR raw_ref->>'esito' IS DISTINCT FROM 'sostituito' THEN
  RAISE EXCEPTION 'EXAM_V5_RESOLVED_SOURCE_MISSING';
 END IF;
 audit:=raw_ref->'_spatial_audit';
 IF audit->>'event_id' IS NOT NULL THEN
  SELECT * INTO STRICT s FROM public.esame_scambi
   WHERE id=(audit->>'scambio_id')::uuid AND prova_id=p_prova;
  SELECT * INTO STRICT ev FROM combat_spatial.spatial_events
   WHERE event_id=(audit->>'event_id')::uuid
    AND instance_id=md5('exam-instance|'||p_prova::text)::uuid AND event_kind='substitution_committed';
  b:=ev.before_state->'exam_spatial'; a:=ev.after_state->'exam_spatial';
  defender:=CASE WHEN s.chi_attacca='png' THEN 'candidate' ELSE 'png' END;
  IF b->>'prova_id' IS DISTINCT FROM p_prova::text OR a->>'prova_id' IS DISTINCT FROM p_prova::text
     OR b->>'map_version' IS DISTINCT FROM audit->>'impact_version'
     OR a->>'map_version' IS DISTINCT FROM audit->>'after_version'
     OR b->defender->>'actor_id' IS DISTINCT FROM ev.actor_id::text
     OR a->defender->>'actor_id' IS DISTINCT FROM ev.actor_id::text THEN
   RAISE EXCEPTION 'EXAM_V5_SPATIAL_RECEIPT_MISMATCH'; END IF;
  before_x:=(b->defender->>'x_m')::numeric; before_y:=(b->defender->>'y_m')::numeric;
  after_x:=(a->defender->>'x_m')::numeric; after_y:=(a->defender->>'y_m')::numeric;
  SELECT t.width_m,t.height_m INTO STRICT width_m,height_m
   FROM combat_spatial.arena_instances i JOIN combat_spatial.arena_templates t
    ON t.template_key=i.template_key AND t.template_version=i.template_version WHERE i.instance_id=ev.instance_id;
  before_description:=concat('settore ',CASE WHEN before_x<width_m/2 THEN 'sinistro' WHEN before_x>width_m/2 THEN 'destro' ELSE 'centrale' END,
   ', ',CASE WHEN before_y<height_m/2 THEN 'verso ingresso' WHEN before_y>height_m/2 THEN 'verso fondo' ELSE 'a meta tatami' END);
  after_description:=concat('settore ',CASE WHEN after_x<width_m/2 THEN 'sinistro' WHEN after_x>width_m/2 THEN 'destro' ELSE 'centrale' END,
   ', ',CASE WHEN after_y<height_m/2 THEN 'verso ingresso' WHEN after_y>height_m/2 THEN 'verso fondo' ELSE 'a meta tatami' END);
  label:=ev.narrator_payload->>'anchor_semantic_label'; distance_after:=(a->>'distance_m')::numeric;
  authority:='common_spatial_event';
 ELSE
  -- Aule non instradate: fatti lineari registrati, MAI una finta arena 2D.
  IF EXISTS(SELECT 1 FROM combat_spatial.arena_instances WHERE instance_id=md5('exam-instance|'||p_prova::text)::uuid) THEN
   RAISE EXCEPTION 'EXAM_V5_BOUND_RECEIPT_MISSING'; END IF;
  round_no:=CASE raw_ref->>'scambio' WHEN 'primo' THEN 1 WHEN 'secondo' THEN 2 WHEN 'terzo' THEN 3 WHEN 'ultimo' THEN 4 END;
  SELECT * INTO STRICT s FROM public.esame_scambi WHERE prova_id=p_prova AND scambio=round_no
   AND chi_attacca=CASE WHEN raw_ref->>'ruolo_png'='png_attacca' THEN 'png' ELSE 'candidato' END;
  IF s.pos_cand_prima IS NULL OR s.pos_png_prima IS NULL OR s.pos_cand IS NULL OR s.pos_png IS NULL THEN
   RAISE EXCEPTION 'EXAM_V5_LEGACY_POSITION_MISSING'; END IF;
  defender:=CASE WHEN s.chi_attacca='png' THEN 'candidate' ELSE 'png' END;
  distance_after:=abs(s.pos_png-s.pos_cand);
  before_description:=CASE WHEN abs(s.pos_png_prima-s.pos_cand_prima)<=2 THEN 'a contatto con attaccante' ELSE 'distaccato da attaccante' END;
  after_description:=CASE WHEN distance_after<=2 THEN 'a contatto con attaccante' ELSE 'distaccato da attaccante' END;
  IF nullif(s.ancora,'') IS NULL OR s.ancora IS DISTINCT FROM raw_ref#>>'{ancora,id}' THEN
   RAISE EXCEPTION 'EXAM_V5_LEGACY_ANCHOR_IDENTITY_MISSING'; END IF;
  label:=raw_ref#>>'{ancora,oggetto}'; authority:='legacy_server_1d';
 END IF;
 IF s.reazione IS DISTINCT FROM 'sostituzione' OR s.colpito OR nullif(btrim(label),'') IS NULL
    OR distance_after IS NULL OR distance_after<0 THEN RAISE EXCEPTION 'EXAM_V5_SUBSTITUTION_FACTS_INVALID'; END IF;
 timeline:=jsonb_build_object(
  'defender_before',jsonb_build_object('attore_ref',CASE WHEN defender='png' THEN 'actor.opponent' ELSE 'actor.candidate' END,'posizione',before_description),
  'impact_point','punto occupato dal difensore prima dello scambio',
  'anchor',jsonb_build_object('nome',label),
  'defender_after',jsonb_build_object('posizione',after_description,'riferimento',
    CASE WHEN authority='common_spatial_event' THEN 'punto dello scambio con '||label
         ELSE 'posizione finale registrata dal motore lineare, senza localizzazione dell''oggetto in due dimensioni' END),
  'distance_to_attacker_after_m',distance_after,
  'continuity','Fotografia dello scambio risolto; la misura corrente della scena resta distinta. Nessun esito di azioni successive e deciso qui.');
 -- Anche il vecchio campo narrativo usa l'ancora dello stesso referto, mai una ricerca per vicinanza.
 p_payload:=jsonb_set(p_payload,'{esito_precedente,ancora}',public._esame_referto_modello(raw_ref->'ancora'),true);
 p_payload:=jsonb_set(p_payload,'{esito_precedente,tecnica_id}',to_jsonb('31b15861-fb78-4f8a-ac1c-ebf2d957c32e'::text),true);
 p_payload:=jsonb_set(p_payload,'{scena,spazio}',coalesce(p_payload#>'{scena,spazio}','{}')||
   jsonb_build_object('authority',authority,'transition_2d_attested',authority='common_spatial_event',
     'clearance_2d_attested',authority='common_spatial_event','narrator_payload',timeline),true);
 RETURN p_payload;
END
$function$;
ALTER FUNCTION public._esame_payload_v5_complete_v1(uuid,jsonb) OWNER TO postgres;
REVOKE ALL ON FUNCTION public._esame_payload_v5_complete_v1(uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public._esame_payload_v5_complete_v1(uuid,jsonb) TO postgres;
