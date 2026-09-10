-- SETUP MINIMO: proiezione soltanto; non replica trigger/RLS/constraint nativi.
BEGIN;
CREATE SCHEMA combat_consumer_private; CREATE SCHEMA combat_panel_private; CREATE SCHEMA clan_sabaku_private; CREATE SCHEMA extensions; CREATE EXTENSION pgcrypto WITH SCHEMA extensions;
SET check_function_bodies=on;
CREATE TABLE public.combat_v2_rounds(id uuid PRIMARY KEY,session_id uuid,round_no int,state text);
CREATE TABLE public.combat_v2_declarations(id uuid PRIMARY KEY,round_id uuid,actor_id uuid,kind text,state text,outcome jsonb,parent_attack_id uuid);
CREATE TABLE public.combat_v2_attack_targets(id uuid PRIMARY KEY,attack_declaration_id uuid,state text);
CREATE TABLE public.characters(id uuid PRIMARY KEY,name text);
CREATE TABLE public.locations(id uuid PRIMARY KEY,name text,description text);
CREATE TABLE public.messages(id uuid PRIMARY KEY,body text,location_id uuid,character_id uuid);
CREATE TABLE public.combat_v2_narratives(id uuid,round_id uuid,body text);
CREATE TABLE combat_consumer_private.activities(session_id uuid,location_id uuid);
CREATE TABLE combat_consumer_private.members(session_id uuid,actor_id uuid,character_id uuid);
CREATE TABLE combat_consumer_private.narrative_claims(id uuid PRIMARY KEY,session_id uuid,round_id uuid,context_payload jsonb,report_sha256 text,control_version bigint);
CREATE TABLE combat_consumer_private.declaration_messages(declaration_id uuid,message_id uuid,message_sha256 text);
CREATE TABLE public.clan_techniques(id uuid PRIMARY KEY,name text,description text,danno_effetto text,is_active boolean);
CREATE TABLE public.jutsu(id uuid PRIMARY KEY,name_it text,effect text,limits text,is_active boolean);
CREATE FUNCTION public._combat_narrative_sha(p uuid) RETURNS text LANGUAGE sql AS $$ SELECT encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex') FROM public.messages WHERE id=p $$;
CREATE TABLE clan_sabaku_private.clones(id uuid,session_id uuid,actor_id uuid,declaration_id uuid,created_round_id uuid,instance_id uuid,reserve_id uuid,map_version bigint,source_body_version bigint,x_m numeric,y_m numeric,source_kekkei_genkai numeric,source_ninjutsu numeric,amount integer,state text,state_version bigint,end_reason text,created_at timestamp with time zone,ended_at timestamp with time zone);
CREATE TABLE clan_sabaku_private.clone_captures(id uuid,clone_id uuid,round_id uuid,target_actor_id uuid,trigger_kind text,trigger_event_id uuid,trigger_declaration_id uuid,formation_id uuid,selected_index integer,copy_hit boolean,target_velocity numeric,target_taijutsu numeric,entropy bytea,dice integer[],result jsonb,created_at timestamp with time zone);
CREATE TABLE combat_panel_private.multiplication_formations(id uuid,session_id uuid,round_id uuid,actor_id uuid,declaration_id uuid,instance_id uuid,source_body_version bigint,mode text,copy_count integer,copy_cap integer,figures jsonb,original_index integer,state text,state_version bigint,terminal_reason text,created_at timestamp with time zone,ended_at timestamp with time zone);
CREATE TABLE combat_panel_private.multiplication_resolutions(formation_id uuid,attack_target_id uuid,chooser_actor_id uuid,selected_index integer,choice_kind text,outcome text,rng_seed bytea,facts jsonb,receipt_sha256 text,created_at timestamp with time zone);
ALTER TABLE public.locations ADD COLUMN is_test boolean DEFAULT true, ADD COLUMN is_active boolean DEFAULT true;
ALTER TABLE combat_consumer_private.activities ADD COLUMN exchange_id uuid, ADD COLUMN phase text, ADD COLUMN policy_id text;
CREATE TABLE public.combat_v2_sessions(id uuid PRIMARY KEY,location_id uuid,source_kind text,lesiva boolean);
CREATE TABLE public.combat_v2_actors(id uuid PRIMARY KEY,session_id uuid,character_id uuid,controller_user uuid);
CREATE TABLE combat_consumer_private.runtime_config(singleton boolean,staff_test_location_id uuid,staff_test_enabled boolean,staff_test_provider_enabled boolean,staff_test_principals uuid[]);
CREATE TABLE public.profiles(id uuid,role text);
CREATE TABLE public.academy_class_sessions(id uuid,location_id uuid,state text);
CREATE TABLE public.esame_prove(class_session_id uuid,stato text);
SET check_function_bodies=on;
CREATE OR REPLACE FUNCTION combat_consumer_private.staff_test_allowed(p_location uuid, p_principals uuid[], p_provider boolean DEFAULT false)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT coalesce(
   p_location IS NOT NULL AND p_provider IS NOT NULL
   AND cardinality(p_principals) BETWEEN 1 AND 2
   AND array_position(p_principals,NULL) IS NULL
   AND EXISTS (
     SELECT 1 FROM combat_consumer_private.runtime_config cfg
     JOIN public.locations l ON l.id=cfg.staff_test_location_id
     WHERE cfg.singleton AND cfg.staff_test_enabled
       AND (NOT p_provider OR cfg.staff_test_provider_enabled)
       AND l.id=p_location AND l.is_active AND l.is_test
       AND p_principals <@ cfg.staff_test_principals
       AND (SELECT count(*) FROM public.profiles p
         WHERE p.id=ANY(cfg.staff_test_principals) AND p.role IN ('admin','master'))=2
       -- Il flag is_exam_room non equivale a un esame; lo stato reale sì.
       -- NULL/shape sconosciuta non costituiscono prova di assenza.
       AND NOT EXISTS (SELECT 1 FROM public.academy_class_sessions s
         WHERE s.location_id=l.id AND s.state IS DISTINCT FROM 'closed')
       AND NOT EXISTS (SELECT 1 FROM public.esame_prove e
         JOIN public.academy_class_sessions s ON s.id=e.class_session_id
         WHERE s.location_id=l.id AND (e.stato='aperta' OR e.stato IS NULL))
   ),false)
$function$;
REVOKE ALL ON FUNCTION combat_consumer_private.staff_test_allowed(uuid,uuid[],boolean) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_consumer_private.staff_test_allowed(uuid,uuid[],boolean) TO postgres;
CREATE OR REPLACE FUNCTION public.combat_v2_values_written(p_session uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select coalesce((select s.lesiva and not coalesce(l.is_test,false)
    from public.combat_v2_sessions s join public.locations l on l.id=s.location_id where s.id=p_session),false)
$function$;
REVOKE ALL ON FUNCTION public.combat_v2_values_written(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.combat_v2_values_written(uuid) TO postgres;
GRANT EXECUTE ON FUNCTION public.combat_v2_values_written(uuid) TO service_role;
INSERT INTO public.clan_techniques VALUES('617484d6-af7b-41c3-a37f-615b22818421','Clone di Sabbia','Il Sabaku modella la sabbia della propria giara in una sagoma che funge da trappola. Quando un avversario si avvicina, la sabbia scatta per avvolgerlo e trattenerlo. Il Clone può essere ingannato dalle copie create con la Moltiplicazione.','Con Controllo della Sabbia attivo, crea un solo Clone entro 3 m dall’utilizzatore: consuma l’azione principale e 5 chakra, impegnando 5 unità di sabbia disponibili nella giara. Il Clone si innesca automaticamente quando un PG avversario o una sua figura di Moltiplicazione valida è entro 2 m, anche subito alla creazione. Una copia consuma l’unico innesco senza applicare la presa al proprietario. Contro il PG, la cattura confronta ⌊(Kekkei Genkai + Ninjutsu) / 5⌋ + 2d10 del creatore con ⌊(Velocità + Taijutsu) / 5⌋ + 2d10 del bersaglio; la parità favorisce la cattura. Il successo immobilizza il PG senza infliggere danni; il fallimento esaurisce il Clone. Il bersaglio può tentare di liberarsi con la propria azione principale e senza chakra: ⌊(Forza + Taijutsu) / 5⌋ + 2d10 contro ⌊pool della presa registrato / 5⌋ + 2d10; serve un risultato superiore e si può tentare una sola volta per proprio turno. Se la presa interrompe l’avvicinamento prima della dichiarazione di attacco o Moltiplicazione, il movimento percorso e la presa restano registrati e la principale rimane disponibile. Il Clone dura al massimo 3 turni del creatore, incluso quello di creazione. Termina anche quando la presa viene sciolta, il bersaglio è fuori combattimento, l’utilizzatore è assente o fuori combattimento, Controllo della Sabbia viene spento, la sabbia non è utilizzabile o lo scontro termina. Alla conclusione si libera la quota impegnata, senza creare nuova sabbia né rimborsare chakra. Non ha un mantenimento proprio; i costi dell’Innata restano separati.',true);
INSERT INTO public.jutsu VALUES('c6e31b7b-38fe-4b4f-b3c7-05f3e922d193','Moltiplicazione del corpo','Crei copie illusorie mentre ti riposizioni. Le copie possono confondere il primo attacco diretto ricevuto: la difesa usa Mente + Ninjutsu.','Azione principale, una volta per round o scambio. Le copie non si accumulano, si consumano al primo attacco diretto o scadono al tuo turno successivo. Se la copia viene colpita non subisci danno né sfioramento; se l''originale è individuato l''attacco si risolve normalmente.',true);

INSERT INTO public.combat_v2_rounds VALUES('00000000-0000-0000-0000-000000000010','00000000-0000-0000-0000-000000000001',1,'risolto');
INSERT INTO public.characters VALUES('00000000-0000-0000-0000-000000000101','Attore A'),('00000000-0000-0000-0000-000000000102','Attore B');
INSERT INTO public.locations(id,name,description) VALUES('00000000-0000-0000-0000-000000000200','Arena sintetica','Spiazzo aperto.');
INSERT INTO combat_consumer_private.members VALUES('00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000011','00000000-0000-0000-0000-000000000101'),('00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000012','00000000-0000-0000-0000-000000000102');
INSERT INTO combat_consumer_private.activities(session_id,location_id) VALUES('00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000200');
INSERT INTO public.combat_v2_declarations VALUES('00000000-0000-0000-0000-000000000020','00000000-0000-0000-0000-000000000010','00000000-0000-0000-0000-000000000011','utilita','risolta','{"sabaku_clone":{"schema_version":"sabaku-clone/1","created":true}}',NULL);
INSERT INTO public.messages VALUES('00000000-0000-0000-0000-000000000030','Role sintetica libera: l’attore alza una mano.','00000000-0000-0000-0000-000000000200','00000000-0000-0000-0000-000000000101');
INSERT INTO combat_consumer_private.declaration_messages SELECT '00000000-0000-0000-0000-000000000020',id,public._combat_narrative_sha(id) FROM public.messages;
INSERT INTO combat_consumer_private.narrative_claims VALUES('00000000-0000-0000-0000-000000000040','00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000010','{"ordinary":true,"genere":"azione_risolta","fatti":{"clone_creation":{"created":true}}}',repeat('a',64),1);

UPDATE combat_consumer_private.activities SET exchange_id='00000000-0000-0000-0000-000000000010',phase='resolved',policy_id='staff_test_no_persistent_resources_v1';
INSERT INTO public.combat_v2_sessions VALUES('00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000200','ordinary',false);
INSERT INTO public.combat_v2_actors VALUES('00000000-0000-0000-0000-000000000011','00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000101','00000000-0000-0000-0000-000000000901'),('00000000-0000-0000-0000-000000000012','00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000102','00000000-0000-0000-0000-000000000902');
INSERT INTO public.profiles VALUES('00000000-0000-0000-0000-000000000901','admin'),('00000000-0000-0000-0000-000000000902','master');
INSERT INTO combat_consumer_private.runtime_config VALUES(true,'00000000-0000-0000-0000-000000000200',true,false,ARRAY['00000000-0000-0000-0000-000000000901','00000000-0000-0000-0000-000000000902']::uuid[]);

-- Minimal projection fixture, NOT native gameplay/Auth/schema parity.
ALTER TABLE public.combat_v2_rounds ADD COLUMN phase text, ADD COLUMN resolved_at timestamptz, ADD COLUMN report_id uuid;
ALTER TABLE public.combat_v2_attack_targets ADD COLUMN round_id uuid, ADD COLUMN target_actor_id uuid, ADD COLUMN outcome jsonb;
ALTER TABLE combat_consumer_private.narrative_claims ADD COLUMN report_id uuid, ADD COLUMN state text;
CREATE TABLE combat_consumer_private.scene_attempts_v2(scene_payload jsonb);
UPDATE public.combat_v2_rounds SET phase='risolto',resolved_at='2026-09-10T01:00:03Z',report_id='00000000-0000-0000-0000-000000000090';
UPDATE combat_consumer_private.narrative_claims SET report_id='00000000-0000-0000-0000-000000000090',state='completed',context_payload='{"ordinary":true,"genere":"azione_risolta","reazione":"schivata","fatti":{"fixture":"synthetic projection of branch006"}}';
UPDATE public.combat_v2_declarations SET kind='attacco' WHERE id='00000000-0000-0000-0000-000000000020';
INSERT INTO public.combat_v2_declarations(id,round_id,actor_id,kind,state,outcome) VALUES('00000000-0000-0000-0000-000000000022','00000000-0000-0000-0000-000000000010','00000000-0000-0000-0000-000000000012','difesa','risolta','{}');
INSERT INTO public.messages VALUES('00000000-0000-0000-0000-000000000032','Role sintetica: il difensore tenta la schivata.','00000000-0000-0000-0000-000000000200','00000000-0000-0000-0000-000000000102');
INSERT INTO combat_consumer_private.declaration_messages SELECT '00000000-0000-0000-0000-000000000022',id,public._combat_narrative_sha(id) FROM public.messages WHERE id='00000000-0000-0000-0000-000000000032';
INSERT INTO public.combat_v2_rounds(id,session_id,round_no,state) VALUES('00000000-0000-0000-0000-000000000009','00000000-0000-0000-0000-000000000001',0,'risolto');
INSERT INTO public.combat_v2_declarations(id,round_id,actor_id,kind,state,outcome) VALUES('00000000-0000-0000-0000-000000000019','00000000-0000-0000-0000-000000000009','00000000-0000-0000-0000-000000000012','utilita','risolta','{}');
INSERT INTO clan_sabaku_private.clones(id,session_id,actor_id,state,end_reason,ended_at) VALUES('00000000-0000-0000-0000-000000000050','00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000011','ended','capture_failed','2026-09-10T01:00:02Z');
INSERT INTO clan_sabaku_private.clone_captures(id,clone_id,round_id,copy_hit,result,created_at) VALUES('00000000-0000-0000-0000-000000000060','00000000-0000-0000-0000-000000000050','00000000-0000-0000-0000-000000000010',false,'{"schema_version":"sabaku-clone-capture/1","copy_hit":false,"success":false,"damage":0}','2026-09-10T01:00:01Z');
INSERT INTO combat_panel_private.multiplication_formations(id,session_id,round_id,actor_id,declaration_id,mode,copy_count,figures,state,terminal_reason,created_at,ended_at) VALUES('00000000-0000-0000-0000-000000000070','00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000009','00000000-0000-0000-0000-000000000012','00000000-0000-0000-0000-000000000019','copertura',1,'{"qa_private_sentinel":"never publish"}','consumed','first_attack','2026-09-10T00:59:00Z','2026-09-10T01:00:02Z');
INSERT INTO public.combat_v2_attack_targets(id,attack_declaration_id,state,round_id,target_actor_id,outcome) VALUES('00000000-0000-0000-0000-000000000080','00000000-0000-0000-0000-000000000020','risolta','00000000-0000-0000-0000-000000000010','00000000-0000-0000-0000-000000000012','{}');
CREATE OR REPLACE FUNCTION public.combat_v2_sha256(p_value jsonb)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO ''
AS $function$
  select encode(extensions.digest(convert_to(coalesce(p_value,'null'::jsonb)::text,'UTF8'),'sha256'),'hex')
$function$;
CREATE OR REPLACE FUNCTION combat_consumer_private.narrative_tech_sources_v1(p_claim uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE claim combat_consumer_private.narrative_claims%ROWTYPE;
  unit public.combat_v2_rounds%ROWTYPE; ref record; event record; content jsonb;
  sources jsonb:='[]'; endings jsonb:='[]'; native_id uuid; source_kind text;
BEGIN
 SELECT * INTO STRICT claim FROM combat_consumer_private.narrative_claims WHERE id=p_claim;
 SELECT * INTO STRICT unit FROM public.combat_v2_rounds WHERE id=claim.round_id;
 IF unit.session_id IS DISTINCT FROM claim.session_id OR claim.context_payload->>'ordinary' IS DISTINCT FROM 'true'
   OR claim.context_payload->>'genere' IS DISTINCT FROM 'azione_risolta' THEN
   RAISE EXCEPTION 'narrative_tech_scope_invalid' USING ERRCODE='22023';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.activities staff_activity
      JOIN public.combat_v2_sessions staff_session ON staff_session.id=staff_activity.session_id
      JOIN public.locations staff_location ON staff_location.id=staff_activity.location_id
      WHERE staff_activity.session_id=claim.session_id AND staff_activity.exchange_id=claim.round_id
        AND staff_activity.phase='resolved' AND staff_activity.policy_id='staff_test_no_persistent_resources_v1'
        AND staff_session.source_kind='ordinary' AND staff_session.location_id=staff_activity.location_id
        AND staff_location.is_test AND NOT public.combat_v2_values_written(staff_session.id)
        AND combat_consumer_private.staff_test_allowed(staff_location.id,
          (SELECT array_agg(actor.controller_user ORDER BY actor.id)
           FROM combat_consumer_private.members member JOIN public.combat_v2_actors actor
             ON actor.id=member.actor_id AND actor.session_id=member.session_id
             AND actor.character_id=member.character_id
           WHERE member.session_id=claim.session_id),false)) THEN
   RAISE EXCEPTION 'narrative_tech_staff_scope_required' USING ERRCODE='42501';
 END IF;
 -- Native rows certify use: no role-text/name lookup, no inventory scan.
 FOR ref IN
  SELECT DISTINCT x.catalog,x.actor_id FROM (
   SELECT 'clan_techniques'::text catalog,d.actor_id
    FROM public.combat_v2_declarations d
    WHERE d.round_id=claim.round_id AND d.state='risolta'
      AND d.outcome->'sabaku_clone'->>'schema_version'='sabaku-clone/1'
      AND d.kind='utilita'
   UNION
   SELECT 'clan_techniques',c.actor_id FROM clan_sabaku_private.clone_captures cc
    JOIN clan_sabaku_private.clones c ON c.id=cc.clone_id
    WHERE cc.round_id=claim.round_id AND c.session_id=claim.session_id
   UNION
   SELECT 'jutsu',f.actor_id FROM combat_panel_private.multiplication_formations f
    JOIN public.combat_v2_declarations d ON d.id=f.declaration_id
    WHERE f.session_id=claim.session_id AND d.round_id=claim.round_id AND d.state='risolta'
   UNION
   SELECT 'jutsu',f.actor_id FROM combat_panel_private.multiplication_resolutions mr
    JOIN combat_panel_private.multiplication_formations f ON f.id=mr.formation_id
    JOIN public.combat_v2_attack_targets t ON t.id=mr.attack_target_id
    JOIN public.combat_v2_declarations d ON d.id=t.attack_declaration_id
    WHERE f.session_id=claim.session_id AND d.round_id=claim.round_id AND d.state='risolta'
      AND t.state IN('risolta','superflua')
   UNION
   SELECT 'jutsu',f.actor_id FROM clan_sabaku_private.clone_captures cc
    JOIN combat_panel_private.multiplication_formations f ON f.id=cc.formation_id
    WHERE cc.round_id=claim.round_id AND f.session_id=claim.session_id
  ) x ORDER BY x.catalog,x.actor_id
 LOOP
  IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.members m
    WHERE m.session_id=claim.session_id AND m.actor_id=ref.actor_id) THEN
   RAISE EXCEPTION 'narrative_tech_actor_not_in_scene' USING ERRCODE='22023';
  END IF;
  IF ref.catalog='clan_techniques' THEN
   native_id:='617484d6-af7b-41c3-a37f-615b22818421';
   SELECT jsonb_build_object('id',id,'name',name,'description',description,'danno_effetto',danno_effetto)
     INTO STRICT content FROM public.clan_techniques WHERE id=native_id;
  ELSE
   native_id:='c6e31b7b-38fe-4b4f-b3c7-05f3e922d193';
   SELECT jsonb_build_object('id',id,'name_it',name_it,'effect',effect,'limits',limits)
     INTO STRICT content FROM public.jutsu WHERE id=native_id;
  END IF;
  sources:=sources||jsonb_build_array(jsonb_build_object('catalog',ref.catalog,'technique_id',native_id,
    'actor_id',ref.actor_id,'mapping_version','ordinary-tech/1','source_sha256',
    encode(extensions.digest(convert_to(content::text,'UTF8'),'sha256'),'hex'),'content',content));
 END LOOP;
 -- Terminal event only when the native capture and native terminal state agree.
 -- No original index, figures, coordinates, dice, private stats, or inference from damage.
 FOR event IN
  SELECT cc.id,cc.copy_hit,cc.result,c.actor_id,c.state,c.end_reason,c.ended_at,cc.created_at
  FROM clan_sabaku_private.clone_captures cc JOIN clan_sabaku_private.clones c ON c.id=cc.clone_id
  WHERE cc.round_id=claim.round_id AND c.session_id=claim.session_id
  ORDER BY cc.created_at,cc.id
 LOOP
  IF event.result->>'schema_version' IS DISTINCT FROM 'sabaku-clone-capture/1'
    OR event.result->'copy_hit' IS DISTINCT FROM to_jsonb(event.copy_hit)
    OR jsonb_typeof(event.result->'success') IS DISTINCT FROM 'boolean' THEN
   RAISE EXCEPTION 'narrative_tech_capture_invalid' USING ERRCODE='22023';
  END IF;
  IF event.result->'success'='false'::jsonb THEN
   IF event.state IS DISTINCT FROM 'ended' OR event.ended_at IS NULL
    OR event.ended_at<event.created_at
    OR event.end_reason IS DISTINCT FROM (CASE WHEN event.copy_hit THEN 'copy_triggered' ELSE 'capture_failed' END) THEN
    RAISE EXCEPTION 'narrative_tech_terminal_event_missing' USING ERRCODE='22023';
   END IF;
   endings:=endings||jsonb_build_array(jsonb_build_object('tecnica','Clone di Sabbia','actor_id',event.actor_id,
      'stato','terminato','causa',event.end_reason));
  END IF;
 END LOOP;
 RETURN jsonb_build_object('fonti_tecniche',sources,'conclusioni_effetti_server',endings);
END $function$;
CREATE OR REPLACE FUNCTION combat_consumer_private.scene_snapshot_v2(p_claim uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_consumer_private.narrative_claims%ROWTYPE;
  activity combat_consumer_private.activities%ROWTYPE; row record; snap jsonb; candidate jsonb;
  actors jsonb; actions jsonb:='[]'; sources jsonb:='[]'; role_count integer:=0;
  prior_count integer:=0; included integer:=0; current_round integer; place public.locations%ROWTYPE;
  body_sha text; facts jsonb;
BEGIN
  SELECT * INTO STRICT c FROM combat_consumer_private.narrative_claims WHERE id=p_claim;
  SELECT * INTO STRICT activity FROM combat_consumer_private.activities WHERE session_id=c.session_id;
  SELECT round_no INTO STRICT current_round FROM public.combat_v2_rounds WHERE id=c.round_id;
  SELECT * INTO STRICT place FROM public.locations WHERE id=activity.location_id;
  IF c.context_payload->>'genere' NOT IN('confronto','rinuncia','azione_risolta') THEN RAISE EXCEPTION 'scene_kind_unsupported'; END IF;
  SELECT jsonb_agg(jsonb_build_object('id',m.actor_id,'name',ch.name,'kind','PG','persona',null,'may_speak',false) ORDER BY m.actor_id)
    INTO actors FROM combat_consumer_private.members m JOIN public.characters ch ON ch.id=m.character_id
    WHERE m.session_id=c.session_id;
  IF jsonb_array_length(actors) IS DISTINCT FROM 2 THEN RAISE EXCEPTION 'scene_current_consumer_roster_unsupported'; END IF;
  -- La descrizione del luogo è ambientazione pubblica. Event_note esclusa: nessuna nuova policy implicita.
  IF nullif(btrim(place.description),'') IS NOT NULL THEN
    sources:=sources||jsonb_build_array(jsonb_build_object('id','location:'||place.id,'session_id',c.session_id,
      'round_id',c.round_id,'kind','setting','actor_id',null,'sequence',current_round,'body',place.description,
      'sha256',encode(extensions.digest(convert_to(place.description,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
  END IF;
  FOR row IN
    SELECT d.id,d.actor_id,d.kind,m.id message_id,m.body,m.location_id,m.character_id,l.message_sha256,mem.character_id expected_character
    FROM public.combat_v2_declarations d
    JOIN combat_consumer_private.members mem ON mem.actor_id=d.actor_id AND mem.session_id=c.session_id
    LEFT JOIN combat_consumer_private.declaration_messages l ON l.declaration_id=d.id
    LEFT JOIN public.messages m ON m.id=l.message_id
    WHERE d.round_id=c.round_id AND d.kind IN('attacco','utilita','passa','movimento','difesa','nessuna')
    ORDER BY CASE WHEN d.kind IN('difesa','nessuna') THEN 1 ELSE 0 END,d.id
  LOOP
    IF row.message_id IS NULL OR row.location_id IS DISTINCT FROM activity.location_id
      OR row.character_id IS DISTINCT FROM row.expected_character OR nullif(btrim(row.body),'') IS NULL
      OR public._combat_narrative_sha(row.message_id) IS DISTINCT FROM row.message_sha256 THEN RAISE EXCEPTION 'scene_current_source_invalid'; END IF;
    role_count:=role_count+1;
    actions:=actions||jsonb_build_array(jsonb_build_object('actor_id',row.actor_id,
      'role',CASE WHEN row.kind IN('difesa','nessuna') THEN 'difesa' ELSE 'azione' END,'source_id',row.message_id));
    body_sha:=encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex');
    sources:=sources||jsonb_build_array(jsonb_build_object('id',row.message_id,'session_id',c.session_id,'round_id',c.round_id,
      'kind','role','actor_id',row.actor_id,'sequence',current_round,'body',row.body,'sha256',body_sha,'visibility','public','complete',true));
  END LOOP;
  IF role_count<>(CASE WHEN c.context_payload->>'genere'='confronto' OR c.context_payload->>'reazione' IS NOT NULL THEN 2 ELSE 1 END) THEN
    RAISE EXCEPTION 'scene_current_actions_incomplete'; END IF;
  -- Proiezione narrativa già prodotta dal server: nessuna lettura di mechanics_snapshot o ricalcolo.
  facts:=c.context_payload-ARRAY['player_reports','gia_visto','ordinary','model'];
  IF c.context_payload->>'ordinary'='true' AND c.context_payload->>'genere'='azione_risolta'
    AND EXISTS(SELECT 1 FROM combat_consumer_private.activities staff_activity
      JOIN public.combat_v2_sessions staff_session ON staff_session.id=staff_activity.session_id
      JOIN public.locations staff_location ON staff_location.id=staff_activity.location_id
      WHERE staff_activity.session_id=c.session_id AND staff_activity.exchange_id=c.round_id
        AND staff_activity.phase='resolved' AND staff_activity.policy_id='staff_test_no_persistent_resources_v1'
        AND staff_session.source_kind='ordinary' AND staff_session.location_id=staff_activity.location_id
        AND staff_location.is_test AND NOT public.combat_v2_values_written(staff_session.id)
        AND combat_consumer_private.staff_test_allowed(staff_location.id,
          (SELECT array_agg(actor.controller_user ORDER BY actor.id)
           FROM combat_consumer_private.members member JOIN public.combat_v2_actors actor
             ON actor.id=member.actor_id AND actor.session_id=member.session_id
             AND actor.character_id=member.character_id
           WHERE member.session_id=c.session_id),false)) THEN
    facts:=facts||combat_consumer_private.narrative_tech_sources_v1(c.id);
  END IF;
  SELECT count(*) INTO prior_count FROM public.combat_v2_narratives n JOIN public.combat_v2_rounds r ON r.id=n.round_id
    WHERE r.session_id=c.session_id AND r.round_no<current_round AND r.state='narrato';
  snap:=jsonb_build_object('schema_version','combat-scene/1','session_id',c.session_id,'round_id',c.round_id,
    'report_sha256',c.report_sha256,'control_version',c.control_version,'location',place.name,
    'actors',actors,'actions',actions,'resolved_facts',facts::text,'sources',sources,
    'selection',jsonb_build_object('max_input_bytes',49152,'previous_available',prior_count,'previous_included',0));
  IF octet_length(snap::text)>49152 THEN RAISE EXCEPTION 'scene_required_context_overflow'; END IF;
  FOR row IN SELECT n.id,n.round_id,n.body,r.round_no FROM public.combat_v2_narratives n
    JOIN public.combat_v2_rounds r ON r.id=n.round_id WHERE r.session_id=c.session_id AND r.round_no<current_round
    AND r.state='narrato' ORDER BY r.round_no DESC,n.id
  LOOP
    candidate:=jsonb_set(snap,'{sources}',(snap->'sources')||jsonb_build_array(jsonb_build_object('id',row.id,
      'session_id',c.session_id,'round_id',row.round_id,'kind','fato','actor_id',null,'sequence',row.round_no,'body',row.body,
      'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true)));
    candidate:=jsonb_set(candidate,'{selection,previous_included}',to_jsonb(included+1));
    EXIT WHEN octet_length(candidate::text)>49152;
    included:=included+1; snap:=candidate;
  END LOOP;
  RETURN snap;
END $function$;
ALTER FUNCTION combat_consumer_private.narrative_tech_sources_v1(uuid) OWNER TO postgres; REVOKE ALL ON FUNCTION combat_consumer_private.narrative_tech_sources_v1(uuid) FROM PUBLIC,anon,authenticated,service_role; GRANT EXECUTE ON FUNCTION combat_consumer_private.narrative_tech_sources_v1(uuid) TO postgres;
ALTER FUNCTION combat_consumer_private.scene_snapshot_v2(uuid) OWNER TO postgres; REVOKE ALL ON FUNCTION combat_consumer_private.scene_snapshot_v2(uuid) FROM PUBLIC,anon,authenticated,service_role; GRANT EXECUTE ON FUNCTION combat_consumer_private.scene_snapshot_v2(uuid) TO postgres;

INSERT INTO combat_panel_private.multiplication_resolutions(formation_id,attack_target_id,choice_kind,outcome,facts,created_at)
VALUES('00000000-0000-0000-0000-000000000070','00000000-0000-0000-0000-000000000080','random','original_found','{"schema_version":"combat-multiplication-resolution/1","formation_id":"00000000-0000-0000-0000-000000000070","attack_target_id":"00000000-0000-0000-0000-000000000080","mode":"copertura","choice_kind":"random","outcome":"original_found"}','2026-09-10T01:00:01Z');
UPDATE combat_panel_private.multiplication_resolutions SET receipt_sha256=public.combat_v2_sha256(facts);
UPDATE public.combat_v2_attack_targets SET outcome=jsonb_build_object('multiplication',(SELECT jsonb_agg(facts||'{"role":"synthetic"}'::jsonb) FROM combat_panel_private.multiplication_resolutions));
CREATE TABLE qa_results(group_id text PRIMARY KEY,result text,detail jsonb);
CREATE FUNCTION public.qa_assert(ok boolean,label text) RETURNS void LANGUAGE plpgsql AS $$ BEGIN IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'QA assertion: %',label; END IF; END $$;
CREATE FUNCTION public.qa_data_digest() RETURNS text LANGUAGE plpgsql AS $$
DECLARE n text; all_data jsonb:='{}'; rows_json jsonb;
BEGIN
FOREACH n IN ARRAY ARRAY['public.combat_v2_rounds','public.combat_v2_declarations','public.combat_v2_attack_targets','public.characters','public.locations','public.messages','public.combat_v2_narratives','public.clan_techniques','public.jutsu','public.combat_v2_sessions','public.combat_v2_actors','public.profiles','combat_consumer_private.activities','combat_consumer_private.members','combat_consumer_private.narrative_claims','combat_consumer_private.declaration_messages','combat_consumer_private.runtime_config','combat_consumer_private.scene_attempts_v2','clan_sabaku_private.clones','clan_sabaku_private.clone_captures','combat_panel_private.multiplication_formations','combat_panel_private.multiplication_resolutions'] LOOP
EXECUTE format('SELECT coalesce(jsonb_agg(to_jsonb(t) ORDER BY to_jsonb(t)::text),''[]''::jsonb) FROM %s t',n) INTO rows_json;
all_data:=all_data||jsonb_build_object(n,rows_json);
END LOOP; RETURN public.combat_v2_sha256(all_data); END $$;
CREATE TABLE qa_before AS SELECT combat_consumer_private.narrative_tech_sources_v1('00000000-0000-0000-0000-000000000040') projection, combat_consumer_private.scene_snapshot_v2('00000000-0000-0000-0000-000000000040') snapshot,public.qa_data_digest() data_sha;
SELECT public.qa_assert(md5(pg_get_functiondef('combat_consumer_private.narrative_tech_sources_v1(uuid)'::regprocedure))='955228bdc23c89cdb287198db57231b8','BEFORE function pin');
SELECT public.qa_assert(md5(pg_get_functiondef('combat_consumer_private.scene_snapshot_v2(uuid)'::regprocedure))='a417e6a98201a2177cb8c244a736bb3c','BEFORE function pin');
COMMIT;
