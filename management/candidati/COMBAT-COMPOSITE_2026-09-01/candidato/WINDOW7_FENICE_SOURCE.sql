-- SOURCE_ONLY: reviewed upper deadline delta over FULL6 source 70532b3233ce24e12d18396eacb02e71db5a215df46f6ef88f60160a71384cca.
-- No other function is installed by this delta.
CREATE OR REPLACE FUNCTION clan_innata_narrative_private.fenice_staff_proof_v1(p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors;s public.combat_v2_sessions;c clan_innata_narrative_private.contexts_v1;
 origin clan_innata_narrative_private.contexts_v1;t public.clan_techniques;sel jsonb;ability jsonb;prior jsonb;proof jsonb;ids uuid[];controllers uuid[];n integer;valid_chain boolean;
BEGIN
 IF statement_timestamp()<'2026-11-07T19:00:58.461822Z'::timestamptz
 OR statement_timestamp()>='2026-11-07T22:17:48Z'::timestamptz THEN RETURN NULL;END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND actor_kind='pg' AND companion_id IS NULL AND state='attivo'
 AND character_id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid AND controller_user='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid;
 IF a.id IS NULL THEN RETURN NULL;END IF;
 SELECT * INTO s FROM public.combat_v2_sessions WHERE id=a.session_id;
 SELECT * INTO c FROM clan_innata_narrative_private.contexts_v1 WHERE context_id=(a.mechanics_snapshot#>>'{innata_staff_profile,context_id}')::uuid;
 SELECT * INTO origin FROM clan_innata_narrative_private.contexts_v1 WHERE context_id='820c5cbf-b2da-466b-bd5c-ecd03be8414c'::uuid;
 IF c.context_id IS NULL OR origin.context_id IS NULL OR c.context_id=origin.context_id
 OR s.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 OR s.created_at<'2026-11-07T19:00:58.461822Z'::timestamptz OR s.closed_at IS NOT NULL OR s.state IN('chiusa','annullata','sospeso')
 OR public.combat_v2_values_written(s.id) OR NOT c.active OR c.character_id IS DISTINCT FROM a.character_id
 OR c.location_id IS DISTINCT FROM s.location_id OR c.master_session_id IS DISTINCT FROM s.master_session_id
 OR c.scope_key IS DISTINCT FROM coalesce(c.master_session_id,c.location_id)
 OR(c.bound_combat_session_id IS NOT NULL AND c.bound_combat_session_id<>s.id)
 OR c.staff_ability_profile IS DISTINCT FROM origin.staff_ability_profile
 OR c.staff_ability_profile->>'profile_key' IS DISTINCT FROM 'byakugan-l3'
 OR c.staff_ability_profile->>'version' IS DISTINCT FROM '7'
 OR c.staff_ability_profile->>'created_by' IS DISTINCT FROM a.controller_user::text
 OR clan_innata_narrative_private.staff_profile_actor_v1(a.id)->>'profile_key' IS DISTINCT FROM 'byakugan-l3'
 OR(clan_innata_private.combat_context(a.id)).policy_id IS DISTINCT FROM 'staff_test_no_persistent_resources_v1'
 OR(clan_innata_private.combat_context(a.id)).activity_kind NOT IN('ordinary_v2','master_v2') THEN RETURN NULL;END IF;
 WITH RECURSIVE chain AS(
  SELECT c.context_id id,c.previous_context_id prev,ARRAY[c.context_id]path,true ok,c.created_at node_at
  UNION ALL
  SELECT x.context_id,x.previous_context_id,k.path||x.context_id,
   k.ok AND x.character_id=a.character_id AND x.location_id=s.location_id
   AND x.scope_key=coalesce(x.master_session_id,x.location_id) AND x.created_at<=k.node_at
   AND x.staff_ability_profile=origin.staff_ability_profile
   AND(x.bound_combat_session_id IS NULL OR EXISTS(SELECT 1 FROM public.combat_v2_sessions old
    WHERE old.id=x.bound_combat_session_id AND old.closed_at IS NOT NULL AND old.location_id=s.location_id
    AND NOT public.combat_v2_values_written(old.id))),x.created_at
  FROM chain k JOIN clan_innata_narrative_private.contexts_v1 x ON x.context_id=k.prev
  WHERE k.id<>origin.context_id AND cardinality(k.path)<16 AND NOT x.context_id=ANY(k.path))
 SELECT EXISTS(SELECT 1 FROM chain WHERE id=origin.context_id AND ok)INTO valid_chain;
 IF NOT valid_chain THEN RETURN NULL;END IF;
 SELECT e INTO sel FROM jsonb_array_elements(c.staff_ability_profile->'journal')e
 WHERE e->>'request_key'='707100f5-67b9-456b-8ee6-bda488ecd3fb'
 AND e->>'fingerprint'='87ec8a45674d8309f602710ec29880e2570ccbe1f4e68ba00c9fc91649a29400'
 AND e->>'api_version'='2' AND e#>>'{result,context_id}'='d92a97b8-8484-4957-8ccb-ce61c8920128'
 AND e#>>'{result,profile_version}'='7';
 IF sel IS NULL THEN RETURN NULL;END IF;
 SELECT array_agg(DISTINCT character_id ORDER BY character_id),array_agg(DISTINCT controller_user ORDER BY controller_user),count(*)
 INTO ids,controllers,n FROM public.combat_v2_actors WHERE session_id=s.id AND actor_kind='pg';
 IF n<>2 OR ids IS DISTINCT FROM ARRAY['2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid]
 OR controllers IS DISTINCT FROM ARRAY['15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid,'f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid]
 OR NOT combat_consumer_private.staff_test_allowed(s.location_id,controllers,false)THEN RETURN NULL;END IF;
 SELECT * INTO t FROM public.clan_techniques WHERE id='6cc40917-1719-4759-9ba8-3064b806c24e'::uuid;
 IF(t.is_active AND t.macro='clan'AND t.clan='Uchiha'AND t.uso='principale'AND t.req_grade='Genin'
 AND t.req_stat='Kekkei Genkai'AND t.req_stat_value=40 AND t.req_tecnica IS NULL AND t.req_elements IS NULL
 AND t.requirements='Grande Palla di Fuoco · grado Genin · Kekkei Genkai ≥ 40'
 AND t.chakra_cost=5 AND t.danno_base=15 AND t.gittata='media'AND t.consumption_type='ad_utilizzo'
 AND NOT t.difensiva AND NOT t.di_scena AND NOT t.is_innata
 AND coalesce((a.mechanics_snapshot->>'kekkei_genkai')::integer,0)>=40
 AND public._grade_rank(clan_innata_narrative_private.staff_profile_actor_v1(a.id)->>'required_grade')>=public._grade_rank('Genin'))IS DISTINCT FROM true
 THEN RETURN NULL;END IF;
 ability:=combat_v2_multitarget_internal.enrich_ability_v1(jsonb_build_object('source','clan','id',t.id,'name',t.name,'kind',t.category,
 'usage',t.uso,'defensive',false,'di_scena',false,'diversivo',false,'consumption_type',t.consumption_type,'range',t.gittata,
 'chakra_cost',t.chakra_cost,'damage_base',t.danno_base,'element','Fuoco'));
 IF ability->'targeting'IS DISTINCT FROM '{"mode":"multi","affects":"enemies_only","geometry":"per_target_line","selection":"manual","max_targets":3,"damage_policy":"full_each","schema_version":"combat-targeting/1.1","geometry_status":"ready"}'::jsonb THEN RETURN NULL;END IF;
 SELECT coalesce(jsonb_agg(x.value ORDER BY x.ordinality),'[]'::jsonb)INTO prior
 FROM jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]'::jsonb))WITH ORDINALITY x(value,ordinality)
 WHERE NOT(x.value->>'source'='clan'AND x.value->>'id'=t.id::text);
 proof:=jsonb_build_object('schema_version','staff-fenice-dependency/1','campaign','COMBAT-TACTICS-FACING-F3MAX2-20261107',
 'origin_context',origin.context_id,'context_id',c.context_id,'selection_request',sel->'request_key','selection_receipt_sha256',public.combat_v2_sha256(sel),
 'profile_version',7,'actor_id',a.id,'session_id',s.id,'character_id',a.character_id,'controller_user',a.controller_user,'controller_version',a.controller_version,
 'abilities_before_sha256',public.combat_v2_sha256(prior),'ability',ability,'is_test',true,'values_written',false,'chakra_spent',0,'main_action_consumed',false,'statistics_changed',false,
 'simulated_requirements',jsonb_build_object('clan_permission','Uchiha','element_permission','Fuoco','grade_minimum','Genin','kekkei_genkai_minimum',40,
 'prerequisite_permission','1260dbc8-ab0c-4b2b-9b94-909d39b7ffbe','prerequisite_ability_granted',false));
 RETURN proof||jsonb_build_object('sha256',public.combat_v2_sha256(proof));
END $function$
;
