-- Migration proposta: esame_spatial_integrated_release_001.
-- Versione assegnata e verificata assente da DB-CORE: 20260904233136. NO fixture/account/sessioni.
-- Executor DB-CORE; una transazione, target verificato esternamente.
-- Esame release: preflight in sola lettura, ripetuto nella transazione di apply.
DO $release_preflight$
DECLARE sig text;
BEGIN
 IF current_user <> 'postgres' THEN RAISE EXCEPTION 'RELEASE_OWNER_REQUIRED'; END IF;
 IF EXISTS(SELECT 1 FROM public.esame_prove WHERE stato='aperta') THEN RAISE EXCEPTION 'RELEASE_ACTIVE_EXAM_BLOCKED'; END IF;
 FOREACH sig IN ARRAY ARRAY['public._esame_sostituzione_source_id_v1(uuid,integer,text,text)',
 'public._esame_sostituzione_opzioni_comune_v1(uuid,text)',
 'public._esame_sostituzione_commit_comune_v1(uuid,uuid,text)',
 'combat_spatial._path_first_block_lifecycle_internal_v1(uuid,uuid,numeric,numeric,numeric,numeric,uuid,text)',
 'public._esame_spatial_snapshot_v1(uuid)',
 'public._esame_spatial_prepare_v1(uuid)',
 'public._esame_spatial_move_preview_v1(uuid,text,numeric,boolean)',
 'public._esame_spatial_history_record_v1(uuid,uuid,jsonb,jsonb)',
 'public._esame_spatial_snapshot_asof_v1(uuid,timestamptz)',
 'public._esame_spatial_snapshot_version_v1(uuid,integer)',
 'public._esame_spatial_move_commit_v1(uuid,text,numeric,boolean,uuid)',
 'public._esame_payload_v5_complete_v1(uuid,jsonb)',
 'public._esame_prova_opzioni_legacy_v1(uuid,text)',
 'public._esame_risolvi_legacy_v1(uuid,jsonb,text)',
 'public._esame_png_scena_snapshot_v1(uuid,timestamp with time zone,integer)'] LOOP
  IF to_regprocedure(sig) IS NOT NULL THEN RAISE EXCEPTION 'RELEASE_NEW_FUNCTION_ALREADY_EXISTS:%',sig; END IF;
 END LOOP;
END $release_preflight$;
DO $release_catalog$
DECLARE e jsonb; p pg_catalog.pg_proc%rowtype; acl_actual jsonb;
BEGIN
 FOR e IN SELECT value FROM jsonb_array_elements($spec$[{"signature":"combat_spatial.path_first_block_t(uuid,uuid,numeric,numeric,numeric,numeric,uuid)","md5":"0bec4c609f0fac1d3fbf57f9e2e7a689","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"combat_spatial.anchor_is_legal(uuid,uuid,text,text,integer)","md5":"52e3082c60dd25618870afccd05df1a2","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_ciclo_payload(uuid)","md5":"c39ba52569c750833f42ed5a32b9fec1","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_diversivo(uuid,text,text,uuid,text)","md5":"f55516cc3a757f26ccfbdc2a9d980471","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_moltiplicazione_candidato(uuid,text,integer,text)","md5":"ba935095aa9cf0861215de8f4a3807f6","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_moltiplicazione_candidato(uuid,text,integer,text,integer)","md5":"7961c72447c8f164e55efd8d8b0dd376","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_png_gioca(uuid,text,text)","md5":"ce354fb3d4acdc96854d86c64c5dd615","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_png_intenzioni(uuid)","md5":"254331ae79a7299be309ab6efb3f1bae","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_png_scena(uuid,timestamp with time zone)","md5":"114e7790cb86ccb6a95711441ca93a8b","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_prova_azione_esegui(uuid,jsonb,text)","md5":"cee0c5a6af28814a4408f344dbb649c7","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_prova_opzioni(uuid,text)","md5":"39772e2fda302362564e73fd709fa8a9","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_replay_payload(uuid,uuid)","md5":"aa75a7c1a097f013efe4912652ff452d","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_risolvi(uuid,jsonb,text)","md5":"06c7346fffc65d6f525d46849dcb817d","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_spazio_json(uuid,boolean)","md5":"00a5b4dacd9c21d1cbc61722d6a276af","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_stato_asof(esame_prove,timestamp with time zone)","md5":"2def36e7341d0919fec2ce07ca7f092e","owner":"postgres","security_definer":false,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_stato_json(uuid)","md5":"36d736c77f76363d895e87bc58dbeaeb","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public.esame_prova_apri(uuid)","md5":"93ec02d9eab3d0480a1bda295e50b880","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"authenticated","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public.narrative_surface_seed_exam(uuid,integer)","md5":"a6a1a0a7631e5c16e7c470e36faf3bf9","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]}]$spec$::jsonb) LOOP
  SELECT * INTO p FROM pg_catalog.pg_proc WHERE oid=to_regprocedure(e->>'signature');
  IF NOT FOUND OR md5(p.prosrc) IS DISTINCT FROM e->>'md5'
   OR pg_get_userbyid(p.proowner) IS DISTINCT FROM e->>'owner'
   OR p.prosecdef IS DISTINCT FROM (e->>'security_definer')::boolean
   OR p.provolatile::text IS DISTINCT FROM e->>'volatility'
   OR to_jsonb(p.proconfig) IS DISTINCT FROM e->'config' THEN
   RAISE EXCEPTION 'RELEASE_BASELINE_BODY_OR_METADATA_DRIFT:%',e->>'signature'; END IF;
  SELECT coalesce(jsonb_agg(jsonb_build_object('grantee',CASE WHEN x.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(x.grantee) END,
   'grantor',pg_get_userbyid(x.grantor),'privilege',x.privilege_type,'grantable',x.is_grantable)),'[]') INTO acl_actual
   FROM aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) x;
  IF NOT(acl_actual @> (e->'acl') AND (e->'acl') @> acl_actual) THEN
   RAISE EXCEPTION 'RELEASE_BASELINE_ACL_DRIFT:%',e->>'signature'; END IF;
 END LOOP;
END $release_catalog$;
DO $release_guard$
BEGIN
 IF current_user <> 'postgres' THEN RAISE EXCEPTION 'RELEASE_OWNER_REQUIRED'; END IF;
 IF EXISTS(SELECT 1 FROM public.esame_prove WHERE stato='aperta') THEN
  RAISE EXCEPTION 'RELEASE_ACTIVE_EXAM_BLOCKED'; END IF;
END $release_guard$;
CREATE TEMP TABLE exam_release_transaction_guard(marker boolean) ON COMMIT DROP;
DO $transaction_guard$
BEGIN
 IF to_regclass('pg_temp.exam_release_transaction_guard') IS NULL THEN
  RAISE EXCEPTION 'RELEASE_EXPLICIT_TRANSACTION_REQUIRED'; END IF;
END $transaction_guard$;

-- SOURCE candidato/000_PRELUDE.sql
-- EXAM-SPATIAL-INTEGRATED-CERTIFICATION-001
-- Packaging release distinto: apply soltanto dopo gate e GO nominativo.
-- Corpi derivati dal candidato sigillato; nessun runner incluso.

-- Transazione gestita dal canale migration; guardia esterna obbligatoria.

do $guard$
declare
  options_hash text;
  resolver_hash text;
  missing text[] := array[]::text[];
begin
  select md5(prosrc) into options_hash
    from pg_proc where oid = 'public._esame_prova_opzioni(uuid,text)'::regprocedure;
  select md5(prosrc) into resolver_hash
    from pg_proc where oid = 'public._esame_risolvi(uuid,jsonb,text)'::regprocedure;

  if options_hash <> '39772e2fda302362564e73fd709fa8a9'
     or resolver_hash <> '06c7346fffc65d6f525d46849dcb817d' then
    raise exception 'EXAM_SPATIAL_BASELINE_DRIFT options=% resolver=%',
      options_hash, resolver_hash;
  end if;

  if to_regprocedure('public.exam_substitution_instance_prepare_v1(uuid,uuid)') is null then
    missing := array_append(missing,'public.exam_substitution_instance_prepare_v1(uuid,uuid)');
  end if;
  if to_regprocedure('public.exam_substitution_source_open_v1(uuid,uuid,text,text,uuid)') is null then
    missing := array_append(missing,'public.exam_substitution_source_open_v1(uuid,uuid,text,text,uuid)');
  end if;
  if to_regprocedure('public.exam_substitution_options_v1(uuid,uuid)') is null then
    missing := array_append(missing,'public.exam_substitution_options_v1(uuid,uuid)');
  end if;
  if to_regprocedure('public.exam_substitution_commit_v1(uuid,uuid,uuid)') is null then
    missing := array_append(missing,'public.exam_substitution_commit_v1(uuid,uuid,uuid)');
  end if;
  if cardinality(missing) > 0 then
    raise exception 'EXAM_SPATIAL_COMMON_BASELINE_MISSING:%', array_to_string(missing,',');
  end if;
end
$guard$;

create temporary table exam_spatial_legacy_contract_before on commit drop as
select p.oid::regprocedure::text as signature,
       p.proowner,
       p.prosecdef,
       p.proconfig,
       p.proacl,
       p.prorettype,
       p.prokind
  from pg_proc p
 where p.oid in (
   'public._esame_prova_opzioni(uuid,text)'::regprocedure,
   'public._esame_risolvi(uuid,jsonb,text)'::regprocedure
 );

create or replace function public._esame_sostituzione_source_id_v1(
  p_prova uuid,
  p_scambio integer,
  p_meta text,
  p_difensore text
)
returns uuid
language sql
immutable
security invoker
set search_path = ''
as $function$
  select md5(
    'exam-source|' || p_prova::text || '|' || p_scambio::text || '|' ||
    p_meta || '|' || p_difensore
  )::uuid
$function$;

create or replace function public._esame_sostituzione_opzioni_comune_v1(
  p_prova uuid,
  p_chi text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  prova public.esame_prove%rowtype;
  source_id uuid;
  common_options jsonb;
  defender_key text := case when lower(coalesce(p_chi,'')) = 'png'
                            then 'png' else 'candidate' end;
  attacker_key text := case when defender_key = 'png'
                            then 'candidate' else 'png' end;
begin
  -- Il beat non limita Sostituzione: eligibility demandata al common
  -- (possesso, chakra, cooldown, ancora valida), come nella baseline viva.
  select ep.* into prova from public.esame_prove ep where ep.id = p_prova;
  if prova.id is null
     or prova.stato <> 'aperta'
     or prova.fase <> 'difesa' then
    return '[]'::jsonb;
  end if;

  source_id := public._esame_sostituzione_source_id_v1(
    p_prova, prova.scambio, prova.meta, defender_key
  );
  begin
    perform public._esame_spatial_prepare_v1(p_prova);
    perform public.exam_substitution_source_open_v1(
      p_prova,
      source_id,
      attacker_key,
      defender_key,
      md5('exam-open|' || source_id::text)::uuid
    );
    common_options := public.exam_substitution_options_v1(p_prova, source_id);
  exception when check_violation then
    -- Solo indisponibilita ordinaria: omette Sostituzione, non il menu.
    -- Il subblocco annulla anche l'eventuale source appena preparata.
    if sqlerrm in ('exam_substitution_source_not_owned_or_active',
                  'exam_substitution_resource_unavailable') then
      return '[]'::jsonb;
    end if;
    raise; -- Autorita, finestre e integrita non diventano opzioni vuote.
  end;

  return coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'chiave','sostituzione',
        'nome','Sostituzione · ' || (option_row->>'label'),
        'id','31b15861-fb78-4f8a-ac1c-ebf2d957c32e',
        'option_id',option_row->>'option_id',
        'anchor_label',option_row->>'label',
        'chakra',5,
        'disponibile',true
      ) order by option_row->>'option_id'
    )
      from jsonb_array_elements(coalesce(common_options->'options','[]'::jsonb)) option_row
  ), '[]'::jsonb);
end
$function$;

create or replace function public._esame_sostituzione_commit_comune_v1(
  p_prova uuid,
  p_option uuid,
  p_chi text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $function$
declare
  prova public.esame_prove%rowtype;
  source_id uuid;
  request_key uuid;
  common_receipt jsonb;
  v_event_id uuid;
  narrator_projection jsonb;
  defender_key text;
  spatial_before jsonb;
  spatial_after jsonb;
begin
  if p_option is null then
    raise exception 'EXAM_SUBSTITUTION_EXACT_OPTION_REQUIRED';
  end if;

  select ep.* into prova from public.esame_prove ep where ep.id = p_prova;
  if prova.id is null then
    raise exception 'La prova non esiste piu';
  end if;

  defender_key := case when lower(coalesce(p_chi,'')) = 'png'
                       then 'png' else 'candidate' end;
  source_id := public._esame_sostituzione_source_id_v1(
    p_prova, prova.scambio, prova.meta, defender_key
  );
  request_key := md5(
    'exam-commit|' || p_prova::text || '|' || p_option::text || '|' ||
    prova.scambio::text || '|' || prova.meta
  )::uuid;

  -- Lock comune prima dello snapshot; receipt replay non deve riattestare
  -- l'evento con coordinate correnti di una fase successiva.
  perform 1 from combat_spatial.arena_instances ai
    where ai.instance_id=md5('exam-instance|'||p_prova::text)::uuid for update;
  spatial_before:=public._esame_spatial_snapshot_v1(p_prova);
  common_receipt := public.exam_substitution_commit_v1(
    p_prova, p_option, request_key
  );
  v_event_id := (common_receipt->>'event_id')::uuid;
  if not exists (select 1 from combat_spatial.spatial_events se
      where se.event_id=v_event_id and se.after_state ? 'exam_spatial') then
    spatial_after:=public._esame_spatial_snapshot_v1(p_prova);
    perform public._esame_spatial_history_record_v1(p_prova,v_event_id,spatial_before,spatial_after);
  end if;

  select e.narrator_payload into narrator_projection
    from combat_spatial.spatial_events e
   where e.event_id = v_event_id;
  if narrator_projection is null then
    raise exception 'EXAM_SUBSTITUTION_RECEIPT_INCOMPLETE';
  end if;

  return jsonb_build_object(
    'profile_id','combat_exam_narrative_spatial_receipt_v1',
    'exchange_identity',jsonb_build_object(
      'exchange_id','exch_' || replace(source_id::text,'-',''),
      'exchange_version',1,
      'root_application_id',p_prova::text,
      'attack_application_id',source_id::text,
      'defense_application_id',request_key::text,
      'substitution_event_id',v_event_id::text,
      'resolution_revision',prova.scambio
    ),
    'common_receipt',common_receipt,
    'narrator_projection',narrator_projection
  );
end
$function$;

revoke all on function public._esame_sostituzione_source_id_v1(uuid,integer,text,text)
  from public, anon, authenticated, service_role;
revoke all on function public._esame_sostituzione_opzioni_comune_v1(uuid,text)
  from public, anon, authenticated, service_role;
revoke all on function public._esame_sostituzione_commit_comune_v1(uuid,uuid,text)
  from public, anon, authenticated, service_role;

grant execute on function public._esame_sostituzione_source_id_v1(uuid,integer,text,text)
  to postgres, service_role;
grant execute on function public._esame_sostituzione_opzioni_comune_v1(uuid,text)
  to postgres, service_role;
grant execute on function public._esame_sostituzione_commit_comune_v1(uuid,uuid,text)
  to postgres, service_role;


-- SOURCE candidato/005_CONTRACT_GUARD.sql
-- Prima di ogni sostituzione dei sedici corpi originali.
do $guard$
declare r record;
begin
  for r in select * from (values
    ('_esame_ciclo_payload(uuid)','c39ba52569c750833f42ed5a32b9fec1'),
    ('_esame_diversivo(uuid,text,text,uuid,text)','f55516cc3a757f26ccfbdc2a9d980471'),
    ('_esame_moltiplicazione_candidato(uuid,text,integer,text)','ba935095aa9cf0861215de8f4a3807f6'),
    ('_esame_moltiplicazione_candidato(uuid,text,integer,text,integer)','7961c72447c8f164e55efd8d8b0dd376'),
    ('_esame_png_gioca(uuid,text,text)','ce354fb3d4acdc96854d86c64c5dd615'),
    ('_esame_png_intenzioni(uuid)','254331ae79a7299be309ab6efb3f1bae'),
    ('_esame_png_scena(uuid,timestamp with time zone)','114e7790cb86ccb6a95711441ca93a8b'),
    ('_esame_prova_azione_esegui(uuid,jsonb,text)','cee0c5a6af28814a4408f344dbb649c7'),
    ('_esame_prova_opzioni(uuid,text)','39772e2fda302362564e73fd709fa8a9'),
    ('_esame_replay_payload(uuid,uuid)','aa75a7c1a097f013efe4912652ff452d'),
    ('_esame_risolvi(uuid,jsonb,text)','06c7346fffc65d6f525d46849dcb817d'),
    ('_esame_spazio_json(uuid,boolean)','00a5b4dacd9c21d1cbc61722d6a276af'),
    ('_esame_stato_asof(esame_prove,timestamp with time zone)','2def36e7341d0919fec2ce07ca7f092e'),
    ('_esame_stato_json(uuid)','36d736c77f76363d895e87bc58dbeaeb'),
    ('esame_prova_apri(uuid)','93ec02d9eab3d0480a1bda295e50b880'),
    ('narrative_surface_seed_exam(uuid,integer)','a6a1a0a7631e5c16e7c470e36faf3bf9')
  ) expected(signature,md5_prosrc) loop
    if (select md5(p.prosrc) from pg_proc p where p.oid=to_regprocedure(r.signature)) is distinct from r.md5_prosrc then
      raise exception 'EXAM_SPATIAL_CONSUMER_BASELINE_DRIFT:%',r.signature;
    end if;
  end loop;
end $guard$;
insert into exam_spatial_legacy_contract_before
select p.oid::regprocedure::text,p.proowner,p.prosecdef,p.proconfig,p.proacl,p.prorettype,p.prokind
from pg_proc p where p.oid in (
    '_esame_ciclo_payload(uuid)'::regprocedure,
    '_esame_diversivo(uuid,text,text,uuid,text)'::regprocedure,
    '_esame_moltiplicazione_candidato(uuid,text,integer,text)'::regprocedure,
    '_esame_moltiplicazione_candidato(uuid,text,integer,text,integer)'::regprocedure,
    '_esame_png_gioca(uuid,text,text)'::regprocedure,
    '_esame_png_intenzioni(uuid)'::regprocedure,
    '_esame_png_scena(uuid,timestamp with time zone)'::regprocedure,
    '_esame_prova_azione_esegui(uuid,jsonb,text)'::regprocedure,
    '_esame_prova_opzioni(uuid,text)'::regprocedure,
    '_esame_replay_payload(uuid,uuid)'::regprocedure,
    '_esame_risolvi(uuid,jsonb,text)'::regprocedure,
    '_esame_spazio_json(uuid,boolean)'::regprocedure,
    '_esame_stato_asof(esame_prove,timestamp with time zone)'::regprocedure,
    '_esame_stato_json(uuid)'::regprocedure,
    'esame_prova_apri(uuid)'::regprocedure,
    'narrative_surface_seed_exam(uuid,integer)'::regprocedure
) and not exists(select 1 from exam_spatial_legacy_contract_before b where b.signature=p.oid::regprocedure::text);


-- SOURCE common_collisioni/005_COMMON_COLLISION_LIFECYCLE.sql
-- COMMON-COLLISION-LIFECYCLE-001 / OFFLINE, NON APPLICARE.
-- Richiede BEGIN esterno, dopo 005_CONTRACT_GUARD e prima di 010_SPATIAL_OWNER.
-- Nessun COMMIT qui. Chiudere l'intero banco con ROLLBACK.
do $preflight$
declare r record; p pg_catalog.pg_proc%rowtype;
begin
  if current_user <> 'postgres' then raise exception 'COMMON_COLLISION_OWNER_REQUIRED'; end if;
  if to_regprocedure('combat_spatial._path_first_block_lifecycle_internal_v1(uuid,uuid,numeric,numeric,numeric,numeric,uuid,text)') is not null then
    raise exception 'COMMON_COLLISION_HELPER_ALREADY_EXISTS';
  end if;
  for r in select * from (values
    ('combat_spatial.path_first_block_t(uuid,uuid,numeric,numeric,numeric,numeric,uuid)','0bec4c609f0fac1d3fbf57f9e2e7a689'),
    ('combat_spatial.anchor_is_legal(uuid,uuid,text,text,integer)','52e3082c60dd25618870afccd05df1a2')
  ) e(signature,body_md5) loop
    select * into p from pg_catalog.pg_proc where oid=to_regprocedure(r.signature);
    if not found then raise exception 'COMMON_COLLISION_BASELINE_MISSING:%',r.signature; end if;
    if md5(p.prosrc) is distinct from r.body_md5
       or p.proowner <> 'postgres'::regrole or not p.prosecdef
       or p.provolatile <> 's' or p.proconfig is distinct from array['search_path=""']::text[]
       or exists(select 1 from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) a
                 where a.grantee<>p.proowner)
    then raise exception 'COMMON_COLLISION_BASELINE_DRIFT:%',r.signature; end if;
  end loop;
end $preflight$;

create temporary table common_collision_lifecycle_before on commit drop as
select p.oid, p.oid::regprocedure::text as signature,
       pg_get_functiondef(p.oid) as original_definition,
       to_jsonb(p)-'prosrc'-'oid' as original_metadata,
       null::text as installed_md5
from pg_catalog.pg_proc p where p.oid in (
  'combat_spatial.path_first_block_t(uuid,uuid,numeric,numeric,numeric,numeric,uuid)'::regprocedure,
  'combat_spatial.anchor_is_legal(uuid,uuid,text,text,integer)'::regprocedure
);

-- In autocommit la tabella ON COMMIT DROP e' gia' sparita: fermarsi PRIMA delle DDL.
do $transaction_guard$
begin
  if to_regclass('pg_temp.common_collision_lifecycle_before') is null then
    raise exception 'COMMON_COLLISION_EXPLICIT_TRANSACTION_REQUIRED';
  end if;
end $transaction_guard$;

CREATE OR REPLACE FUNCTION combat_spatial._path_first_block_lifecycle_internal_v1(p_instance uuid, p_actor uuid, p_x1 numeric, p_y1 numeric, p_x2 numeric, p_y2 numeric, p_exclude_actor uuid, p_exclude_object text)
 RETURNS numeric
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare i combat_spatial.arena_instances%rowtype; a combat_spatial.actor_states%rowtype;
  o record; x record; t numeric; best numeric:=1;
begin
  select * into strict i from combat_spatial.arena_instances where instance_id=p_instance and state='open';
  select * into strict a from combat_spatial.actor_states where instance_id=p_instance and actor_id=p_actor and state='active';
  -- L'eccezione e' solo il punto esatto dell'ancora portable disponibile.
  -- Nessun segmento di movimento e nessuna esclusione di altri attori.
  if p_exclude_object is not null then
    if p_exclude_actor is not null
       or p_x1 is distinct from p_x2 or p_y1 is distinct from p_y2
       or not exists (
         select 1 from combat_spatial.arena_objects ao
         join combat_spatial.object_states os
           on os.instance_id=p_instance and os.object_key=ao.object_key
         where ao.template_key=i.template_key and ao.template_version=i.template_version
           and ao.object_key=p_exclude_object and ao.substitutable
           and ao.lifecycle='portable_single_use' and os.state='available'
           and p_x1=(combat_spatial.shape_center(ao.shape_kind,ao.shape))[0]::numeric
           and p_y1=(combat_spatial.shape_center(ao.shape_kind,ao.shape))[1]::numeric
       )
    then return 0; end if;
  end if;
  if p_x2-a.footprint_radius_m<0 or p_y2-a.footprint_radius_m<0
     or p_x2+a.footprint_radius_m>(select width_m from combat_spatial.arena_templates where template_key=i.template_key and template_version=i.template_version)
     or p_y2+a.footprint_radius_m>(select height_m from combat_spatial.arena_templates where template_key=i.template_key and template_version=i.template_version)
  then return 0; end if;
  for o in select ao.* from combat_spatial.arena_objects ao
    where ao.template_key=i.template_key and ao.template_version=i.template_version
      and ao.blocks_movement and ao.object_key is distinct from p_exclude_object
      -- NOT EXISTS resta fail-closed anche se lifecycle/stato sono NULL o mancanti.
      and not exists (
        select 1 from combat_spatial.object_states os
        where os.instance_id=p_instance and os.object_key=ao.object_key
          and ao.lifecycle='portable_single_use'
          and ao.substitutable and ao.object_kind='substitution_anchor'
          and os.state='consumed_non_substitutable'
      )
  loop
    if o.shape_kind='circle' then
      t:=combat_spatial.segment_circle_first_t(p_x1,p_y1,p_x2,p_y2,
        (o.shape->>'cx')::numeric,(o.shape->>'cy')::numeric,(o.shape->>'radius')::numeric+a.footprint_radius_m);
    else
      t:=combat_spatial.segment_aabb_first_t(p_x1,p_y1,p_x2,p_y2,
        (o.shape->>'min_x')::numeric,(o.shape->>'min_y')::numeric,
        (o.shape->>'max_x')::numeric,(o.shape->>'max_y')::numeric,a.footprint_radius_m);
    end if;
    if t is not null then best:=least(best,greatest(0,t-0.000001)); end if;
  end loop;
  for x in select * from combat_spatial.actor_states
    where instance_id=p_instance and state='active' and actor_id<>p_actor and actor_id is distinct from p_exclude_actor
  loop
    t:=combat_spatial.segment_circle_first_t(p_x1,p_y1,p_x2,p_y2,x.x_m,x.y_m,a.footprint_radius_m+x.footprint_radius_m);
    if t is not null then best:=least(best,greatest(0,t-0.000001)); end if;
  end loop;
  return best;
end $function$;

alter function combat_spatial._path_first_block_lifecycle_internal_v1(uuid,uuid,numeric,numeric,numeric,numeric,uuid,text) owner to postgres;
revoke all on function combat_spatial._path_first_block_lifecycle_internal_v1(uuid,uuid,numeric,numeric,numeric,numeric,uuid,text) from public, anon, authenticated, service_role;
grant execute on function combat_spatial._path_first_block_lifecycle_internal_v1(uuid,uuid,numeric,numeric,numeric,numeric,uuid,text) to postgres;

CREATE OR REPLACE FUNCTION combat_spatial.path_first_block_t(p_instance uuid, p_actor uuid, p_x1 numeric, p_y1 numeric, p_x2 numeric, p_y2 numeric, p_exclude_actor uuid DEFAULT NULL::uuid)
 RETURNS numeric
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  return combat_spatial._path_first_block_lifecycle_internal_v1(
    p_instance,p_actor,p_x1,p_y1,p_x2,p_y2,p_exclude_actor,null::text);
end $function$;

CREATE OR REPLACE FUNCTION combat_spatial.anchor_is_legal(p_instance uuid, p_actor uuid, p_object text, p_profile text, p_round integer)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare i combat_spatial.arena_instances%rowtype; a combat_spatial.actor_states%rowtype; o combat_spatial.arena_objects%rowtype; os combat_spatial.object_states%rowtype;
  q point; r numeric; last integer; hit numeric;
begin
  select * into i from combat_spatial.arena_instances where instance_id=p_instance and state='open'; if not found then return false; end if;
  select * into a from combat_spatial.actor_states where instance_id=p_instance and actor_id=p_actor and state='active'; if not found then return false; end if;
  select * into o from combat_spatial.arena_objects where template_key=i.template_key and template_version=i.template_version and object_key=p_object and substitutable; if not found then return false; end if;
  select * into os from combat_spatial.object_states where instance_id=p_instance and object_key=p_object and state='available'; if not found then return false; end if;
  select max_range_m into r from combat_spatial.source_range_profiles where profile_id=p_profile; if r is null then return false; end if;
  q:=combat_spatial.shape_center(o.shape_kind,o.shape);
  if combat_spatial.distance_m(a.x_m,a.y_m,q[0]::numeric,q[1]::numeric)>r then return false; end if;
  select last_commit_round into last from combat_spatial.substitution_cooldowns where instance_id=p_instance and actor_id=p_actor;
  if found and p_round<last+3 then return false; end if;
  hit:=combat_spatial._path_first_block_lifecycle_internal_v1(p_instance,p_actor,q[0]::numeric,q[1]::numeric,q[0]::numeric,q[1]::numeric,null::uuid,p_object); if hit<1 then return false; end if;
  return true;
end $function$;

do $postflight$
begin
  if exists (
    select 1 from pg_temp.common_collision_lifecycle_before b
    left join pg_catalog.pg_proc p on p.oid=b.oid
    where p.oid is null or (to_jsonb(p)-'prosrc'-'oid') is distinct from b.original_metadata
  ) then raise exception 'COMMON_COLLISION_CONTRACT_CHANGED'; end if;
  if exists (
    select 1 from pg_catalog.pg_proc p,
      lateral aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) a
    where p.oid='combat_spatial._path_first_block_lifecycle_internal_v1(uuid,uuid,numeric,numeric,numeric,numeric,uuid,text)'::regprocedure and a.grantee<>p.proowner
  ) then raise exception 'COMMON_COLLISION_HELPER_ACL_OPEN'; end if;
end $postflight$;

update pg_temp.common_collision_lifecycle_before b
set installed_md5=md5(p.prosrc) from pg_catalog.pg_proc p where p.oid=b.oid;
insert into pg_temp.common_collision_lifecycle_before
select p.oid,p.oid::regprocedure::text,null,to_jsonb(p)-'prosrc'-'oid',md5(p.prosrc)
from pg_catalog.pg_proc p where p.oid='combat_spatial._path_first_block_lifecycle_internal_v1(uuid,uuid,numeric,numeric,numeric,numeric,uuid,text)'::regprocedure;


-- SOURCE candidato/010_SPATIAL_OWNER.sql
-- EXAM-SPATIAL-INTEGRATED-CERTIFICATION-001 — candidato, solo transazione QA.
-- Coordinate interne: nessun GRANT ai client e nessuna proiezione 2D -> 1D.
CREATE OR REPLACE FUNCTION public._esame_spatial_snapshot_v1(p_prova uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  p public.esame_prove%rowtype;
  i combat_spatial.arena_instances%rowtype;
  c combat_spatial.actor_states%rowtype;
  n combat_spatial.actor_states%rowtype;
  v_location uuid;
BEGIN
  SELECT ep.* INTO STRICT p FROM public.esame_prove ep WHERE ep.id=p_prova;
  SELECT ai.* INTO i FROM combat_spatial.arena_instances ai
    WHERE ai.instance_id=md5('exam-instance|'||p_prova::text)::uuid;
  IF NOT FOUND THEN
    SELECT cs.location_id INTO v_location FROM public.academy_class_sessions cs
      WHERE cs.id=p.class_session_id;
    IF EXISTS (SELECT 1 FROM combat_spatial.exam_arena_routes_v1 r
               WHERE r.class_location_id=v_location) THEN
      RAISE EXCEPTION 'EXAM_SPATIAL_INSTANCE_REQUIRED';
    END IF;
    RETURN NULL;
  END IF;
  IF i.encounter_id IS DISTINCT FROM p_prova THEN
    RAISE EXCEPTION 'EXAM_SPATIAL_INSTANCE_MISMATCH';
  END IF;
  SELECT a.* INTO STRICT c FROM combat_spatial.actor_states a
    WHERE a.instance_id=i.instance_id AND a.actor_id=md5('exam-candidate|'||p_prova::text)::uuid;
  SELECT a.* INTO STRICT n FROM combat_spatial.actor_states a
    WHERE a.instance_id=i.instance_id AND a.actor_id=md5('exam-png|'||p_prova::text)::uuid;
  IF c.state<>'active' OR n.state<>'active' OR c.actor_kind<>'PG' OR n.actor_kind<>'PNG'
     OR c.controller_principal_id IS DISTINCT FROM p.candidate_user
     OR c.projection_subject_id IS DISTINCT FROM p.candidate_character
     OR n.projection_subject_id IS DISTINCT FROM p.profilo_id
     OR c.slot_key=n.slot_key THEN
    RAISE EXCEPTION 'EXAM_SPATIAL_ACTOR_MISMATCH';
  END IF;
  RETURN jsonb_build_object(
    'instance_id',i.instance_id,'map_version',i.map_version,'instance_state',i.state,
    'distance_m',combat_spatial.distance_m(c.x_m,c.y_m,n.x_m,n.y_m),
    'candidate',jsonb_build_object('actor_id',c.actor_id,'x_m',c.x_m,'y_m',c.y_m,
      'body_version',c.body_version,'footprint_radius_m',c.footprint_radius_m),
    'png',jsonb_build_object('actor_id',n.actor_id,'x_m',n.x_m,'y_m',n.y_m,
      'body_version',n.body_version,'footprint_radius_m',n.footprint_radius_m));
END
$function$;

CREATE OR REPLACE FUNCTION public._esame_spatial_prepare_v1(p_prova uuid)
RETURNS jsonb LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  p public.esame_prove%rowtype;
  r combat_spatial.exam_arena_routes_v1%rowtype;
  v_location uuid;
  s jsonb;
BEGIN
  -- Stesso lock del prepare comune; la chiave ricevuta resta identica a quella
  -- già usata dalla porta Sostituzione, mai una nuova key sulla stessa prova.
  PERFORM pg_advisory_xact_lock(hashtextextended('exam-substitution-instance:'||p_prova::text,0));
  SELECT ep.* INTO STRICT p FROM public.esame_prove ep WHERE ep.id=p_prova FOR UPDATE;
  IF EXISTS (SELECT 1 FROM combat_spatial.arena_instances ai
             WHERE ai.instance_id=md5('exam-instance|'||p_prova::text)::uuid) THEN
    RETURN public._esame_spatial_snapshot_v1(p_prova);
  END IF;
  SELECT cs.location_id INTO v_location FROM public.academy_class_sessions cs
    WHERE cs.id=p.class_session_id;
  SELECT er.* INTO r FROM combat_spatial.exam_arena_routes_v1 er
    WHERE er.class_location_id=v_location;
  IF NOT FOUND THEN RETURN NULL; END IF;
  IF NOT r.enabled OR r.candidate_slot_key=r.png_slot_key THEN
    RAISE EXCEPTION 'EXAM_SPATIAL_ROUTE_INVALID';
  END IF;
  IF (SELECT count(*) FROM combat_spatial.arena_slots s
      WHERE s.template_key=r.template_key AND s.template_version=r.template_version
        AND s.slot_key IN (r.candidate_slot_key,r.png_slot_key))<>2 THEN
    RAISE EXCEPTION 'EXAM_SPATIAL_REQUIRED_SLOTS_MISSING';
  END IF;
  PERFORM public.exam_substitution_instance_prepare_v1(
    p_prova,md5('exam-prepare|'||p_prova::text)::uuid);
  s:=public._esame_spatial_snapshot_v1(p_prova);
  INSERT INTO combat_spatial.spatial_events
    (event_id,instance_id,event_kind,root_id,actor_id,object_key,before_state,after_state,narrator_payload,created_at)
  VALUES(md5('exam-spatial-opening|'||p_prova::text)::uuid,(s->>'instance_id')::uuid,
    'exam_spatial_opening',p_prova,(s->'candidate'->>'actor_id')::uuid,NULL,'{}'::jsonb,
    jsonb_build_object('exam_spatial',s||jsonb_build_object('prova_id',p_prova)),
    jsonb_build_object('after','posizioni iniziali della prova'),clock_timestamp());
  RETURN s;
END
$function$;

CREATE OR REPLACE FUNCTION public._esame_spatial_move_preview_v1(
  p_prova uuid,p_chi text,p_metri numeric,p_toward boolean)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE
  s jsonb; a jsonb; b jsonb; i combat_spatial.arena_instances%rowtype;
  w numeric; h numeric; r numeric; x numeric; y numeric; dx numeric; dy numeric;
  d numeric; lim numeric; t numeric; ex numeric; ey numeric; travelled numeric;
  v_actor uuid; attempt integer;
BEGIN
  IF p_chi NOT IN ('candidato','candidate','png') OR p_chi IS NULL
     OR p_metri IS NULL OR p_metri<0 OR p_metri::text IN ('NaN','Infinity','-Infinity')
     OR p_toward IS NULL THEN RAISE EXCEPTION 'EXAM_SPATIAL_MOVEMENT_INPUT_INVALID'; END IF;
  s:=public._esame_spatial_snapshot_v1(p_prova);
  IF s IS NULL THEN RETURN NULL; END IF;
  IF s->>'instance_state'<>'open' THEN RAISE EXCEPTION 'EXAM_SPATIAL_INSTANCE_CLOSED'; END IF;
  a:=s->(CASE WHEN p_chi='png' THEN 'png' ELSE 'candidate' END);
  b:=s->(CASE WHEN p_chi='png' THEN 'candidate' ELSE 'png' END);
  d:=(s->>'distance_m')::numeric;
  IF d=0 THEN
    RETURN jsonb_build_object('available',false,'reason','OPEN_COINCIDENT_DIRECTION',
      'distance_m',0,'distance_after_m',0,'travelled_m',0);
  END IF;
  SELECT ai.* INTO STRICT i FROM combat_spatial.arena_instances ai
    WHERE ai.instance_id=(s->>'instance_id')::uuid;
  SELECT at.width_m,at.height_m INTO STRICT w,h FROM combat_spatial.arena_templates at
    WHERE at.template_key=i.template_key AND at.template_version=i.template_version;
  x:=(a->>'x_m')::numeric; y:=(a->>'y_m')::numeric;
  r:=(a->>'footprint_radius_m')::numeric; v_actor:=(a->>'actor_id')::uuid;
  dx:=((b->>'x_m')::numeric-x)/d*(CASE WHEN p_toward THEN 1 ELSE -1 END);
  dy:=((b->>'y_m')::numeric-y)/d*(CASE WHEN p_toward THEN 1 ELSE -1 END);
  lim:=p_metri;
  -- Il common rifiuta endpoint fuori arena: prima si interseca il segmento
  -- col rettangolo percorribile dal centro, già ridotto del footprint.
  IF dx>0 THEN lim:=least(lim,(w-r-x)/dx);
  ELSIF dx<0 THEN lim:=least(lim,(r-x)/dx); END IF;
  IF dy>0 THEN lim:=least(lim,(h-r-y)/dy);
  ELSIF dy<0 THEN lim:=least(lim,(r-y)/dy); END IF;
  lim:=greatest(0,lim);
  t:=combat_spatial.path_first_block_t(i.instance_id,v_actor,x,y,x+dx*lim,y+dy*lim);
  lim:=lim*t;
  -- La persistenza comune è al centimetro. Si verifica il segmento realmente
  -- persistibile, non il solo endpoint ideale; nessun arrotondamento può
  -- oltrepassare budget/ostacoli. Rientro deterministico massimo due centimetri.
  FOR attempt IN 0..1 LOOP
    ex:=round(x+dx*lim,2); ey:=round(y+dy*lim,2);
    travelled:=combat_spatial.distance_m(x,y,ex,ey);
    EXIT WHEN travelled<=p_metri AND
      combat_spatial.path_first_block_t(i.instance_id,v_actor,x,y,ex,ey)=1;
    lim:=greatest(0,lim-0.02);
  END LOOP;
  IF travelled>p_metri OR
     combat_spatial.path_first_block_t(i.instance_id,v_actor,x,y,ex,ey)<>1 THEN
    RETURN jsonb_build_object('available',false,'reason','SPATIAL_PRECISION_BLOCKED',
      'distance_m',d,'distance_after_m',d,'travelled_m',0);
  END IF;
  RETURN jsonb_build_object('available',travelled>0,'distance_m',d,
    'distance_after_m',combat_spatial.distance_m(ex,ey,(b->>'x_m')::numeric,(b->>'y_m')::numeric),
    'travelled_m',travelled,'endpoint_x_m',ex,'endpoint_y_m',ey,
    'actor_id',v_actor,'instance_id',i.instance_id,'map_version',i.map_version,
    'body_version',(a->>'body_version')::integer);
END
$function$;

CREATE OR REPLACE FUNCTION public._esame_spatial_history_record_v1(
  p_prova uuid,p_event uuid,p_before jsonb,p_after jsonb)
RETURNS void LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE e combat_spatial.spatial_events%rowtype; iid uuid;
BEGIN
  iid:=md5('exam-instance|'||p_prova::text)::uuid;
  SELECT se.* INTO STRICT e FROM combat_spatial.spatial_events se WHERE se.event_id=p_event FOR UPDATE;
  IF e.instance_id<>iid OR e.event_kind NOT IN ('movement_settled','substitution_committed')
    OR (p_before->>'instance_id')::uuid IS DISTINCT FROM iid
    OR (p_after->>'instance_id')::uuid IS DISTINCT FROM iid
    OR (p_after->>'map_version')::int IS DISTINCT FROM (p_before->>'map_version')::int+1 THEN
    RAISE EXCEPTION 'EXAM_SPATIAL_HISTORY_EVENT_MISMATCH';
  END IF;
  -- Mai riscrivere un evento attestato, neppure con valori apparentemente uguali.
  IF e.after_state ? 'exam_spatial' THEN RAISE EXCEPTION 'EXAM_SPATIAL_HISTORY_ALREADY_ATTESTED'; END IF;
  UPDATE combat_spatial.spatial_events se
    SET before_state=se.before_state||jsonb_build_object('exam_spatial',p_before||jsonb_build_object('prova_id',p_prova)),
        after_state=se.after_state||jsonb_build_object('exam_spatial',p_after||jsonb_build_object('prova_id',p_prova))
    WHERE se.event_id=p_event;
END
$function$;

CREATE OR REPLACE FUNCTION public._esame_spatial_snapshot_asof_v1(p_prova uuid,p_asof timestamptz)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE s jsonb;
BEGIN
  IF p_asof IS NULL THEN RETURN public._esame_spatial_snapshot_v1(p_prova); END IF;
  SELECT se.after_state->'exam_spatial' INTO s
    FROM combat_spatial.spatial_events se
    WHERE se.instance_id=md5('exam-instance|'||p_prova::text)::uuid
      AND se.after_state->'exam_spatial'->>'prova_id'=p_prova::text
      AND se.created_at<=p_asof
    ORDER BY se.created_at DESC,(se.after_state->'exam_spatial'->>'map_version')::int DESC,se.event_id DESC
    LIMIT 1;
  RETURN s; -- Prima dell'opening nessuno snapshot; mai fallback allo stato live.
END
$function$;

CREATE OR REPLACE FUNCTION public._esame_spatial_snapshot_version_v1(p_prova uuid,p_version integer)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE s jsonb;
BEGIN
  SELECT se.after_state->'exam_spatial' INTO STRICT s
    FROM combat_spatial.spatial_events se
    WHERE se.instance_id=md5('exam-instance|'||p_prova::text)::uuid
      AND se.after_state->'exam_spatial'->>'prova_id'=p_prova::text
      AND (se.after_state->'exam_spatial'->>'map_version')::int=p_version;
  RETURN s;
END
$function$;

CREATE OR REPLACE FUNCTION public._esame_spatial_move_commit_v1(
  p_prova uuid,p_chi text,p_metri numeric,p_toward boolean,p_request_key uuid)
RETURNS jsonb LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = ''
AS $function$
DECLARE s jsonb; a jsonb; preview jsonb; fp text; replay jsonb; receipt jsonb;
  iid uuid; actor uuid; choice text; capability uuid; common_key uuid; result jsonb;
BEGIN
  IF p_request_key IS NULL THEN RAISE EXCEPTION 'EXAM_SPATIAL_REQUEST_REQUIRED'; END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended('exam-move:'||p_request_key::text,0));
  fp:=combat_spatial.server_fingerprint('_esame_spatial_move_commit_v1',
    jsonb_build_object('prova',p_prova,'chi',p_chi,'metri',p_metri,'toward',p_toward));
  replay:=combat_spatial.receipt_replay(p_request_key,'_esame_spatial_move_commit_v1',fp);
  IF replay IS NOT NULL THEN RETURN replay-'replayed'; END IF;
  PERFORM 1 FROM public.esame_prove ep WHERE ep.id=p_prova FOR UPDATE;
  iid:=md5('exam-instance|'||p_prova::text)::uuid;
  PERFORM 1 FROM combat_spatial.arena_instances ai WHERE ai.instance_id=iid FOR UPDATE;
  s:=public._esame_spatial_snapshot_v1(p_prova);
  IF s IS NULL THEN RAISE EXCEPTION 'EXAM_SPATIAL_UNBOUND_MOVEMENT'; END IF;
  preview:=public._esame_spatial_move_preview_v1(p_prova,p_chi,p_metri,p_toward);
  IF NOT (preview->>'available')::boolean THEN
    RAISE EXCEPTION 'EXAM_SPATIAL_MOVEMENT_UNAVAILABLE:%',coalesce(preview->>'reason','blocked');
  END IF;
  actor:=(preview->>'actor_id')::uuid;
  choice:='exam_move_'||replace(p_request_key::text,'-','');
  INSERT INTO combat_spatial.movement_semantic_choices
    (instance_id,actor_id,choice_key,endpoint_x_m,endpoint_y_m,max_budget_m,choice_version,enabled)
  VALUES(iid,actor,choice,(preview->>'endpoint_x_m')::numeric,
    (preview->>'endpoint_y_m')::numeric,p_metri,1,true);
  SELECT (o->>'option_id')::uuid INTO STRICT capability
    FROM jsonb_array_elements(combat_spatial.movement_options(iid,actor,p_metri)) o
    WHERE o->>'intent'=choice;
  common_key:=md5('exam-move-common|'||p_request_key::text)::uuid;
  receipt:=combat_spatial.movement_commit(capability,common_key,p_request_key);
  a:=public._esame_spatial_snapshot_v1(p_prova);
  IF (a->(CASE WHEN p_chi='png' THEN 'png' ELSE 'candidate' END)->>'x_m')::numeric
       IS DISTINCT FROM (preview->>'endpoint_x_m')::numeric
     OR (a->(CASE WHEN p_chi='png' THEN 'png' ELSE 'candidate' END)->>'y_m')::numeric
       IS DISTINCT FROM (preview->>'endpoint_y_m')::numeric THEN
    RAISE EXCEPTION 'EXAM_SPATIAL_PREVIEW_COMMIT_DIVERGENCE';
  END IF;
  PERFORM public._esame_spatial_history_record_v1(p_prova,(receipt->>'event_id')::uuid,s,a);
  result:=jsonb_build_object('common_receipt',receipt,'before',s,'after',a);
  INSERT INTO combat_spatial.request_receipts VALUES
    (p_request_key,'_esame_spatial_move_commit_v1',fp,result,clock_timestamp());
  RETURN result;
END
$function$;

REVOKE ALL ON FUNCTION public._esame_spatial_history_record_v1(uuid,uuid,jsonb,jsonb) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public._esame_spatial_snapshot_version_v1(uuid,integer) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public._esame_spatial_snapshot_version_v1(uuid,integer) TO postgres,service_role;
REVOKE ALL ON FUNCTION public._esame_spatial_snapshot_asof_v1(uuid,timestamptz) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public._esame_spatial_move_commit_v1(uuid,text,numeric,boolean,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public._esame_spatial_history_record_v1(uuid,uuid,jsonb,jsonb) TO postgres,service_role;
GRANT EXECUTE ON FUNCTION public._esame_spatial_snapshot_asof_v1(uuid,timestamptz) TO postgres,service_role;
GRANT EXECUTE ON FUNCTION public._esame_spatial_move_commit_v1(uuid,text,numeric,boolean,uuid) TO postgres,service_role;
REVOKE ALL ON FUNCTION public._esame_spatial_move_preview_v1(uuid,text,numeric,boolean) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public._esame_spatial_move_preview_v1(uuid,text,numeric,boolean) TO postgres,service_role;
REVOKE ALL ON FUNCTION public._esame_spatial_snapshot_v1(uuid) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public._esame_spatial_prepare_v1(uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public._esame_spatial_snapshot_v1(uuid) TO postgres,service_role;
GRANT EXECUTE ON FUNCTION public._esame_spatial_prepare_v1(uuid) TO postgres,service_role;


-- SOURCE release/020_EXAM_NARRATIVE_PRODUCER_V5.sql
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


-- SOURCE candidato/full_body/_esame_prova_opzioni_legacy_v1.sql
CREATE OR REPLACE FUNCTION public._esame_prova_opzioni_legacy_v1(p_prova uuid, p_chi text DEFAULT 'candidato'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_c public.characters%rowtype;
  v_dist int; v_maxm int; v_ck int; v_vel int; v_nin int;
  v_speso boolean; v_rapida_spesa boolean; v_sposta_spesa boolean;
  v_beat int; v_sost_round int; v_sost_id uuid; v_sost_ck int := 0; v_sost_ok boolean;
  v_disp_id uuid; v_disp_ck int := 0; v_disp_nome text; v_disp_ok boolean := false;
  v_princ jsonb; v_scen jsonb := '[]'::jsonb; v_inn jsonb := '[]'::jsonb; v_rap jsonb; v_reaz jsonb; v_posizioni jsonb;
  v_png boolean; v_motivo_beat text; v_copie boolean;
  -- [017-R1] il diversivo e le sue direzioni
  v_div jsonb := '[]'::jsonb; v_div_id uuid; v_div_nome text; v_div_ck int := 0;
  v_div_scorso int; v_div_ok boolean; v_direzioni jsonb := '[]'::jsonb;
  v_copie_cap int := 0; v_copie_offerte jsonb := '[]'::jsonb;
  v_assalto_avanzamenti jsonb := '[]'::jsonb;
  -- [ADDENDUM] le due posizioni risultanti, calcolate una volta e lette due:
  -- dal ramo `disponibile` e dal ramo `metri`. Calcolarle due volte è il modo
  -- in cui un elenco comincia a promettere una cosa e l'esecutore a farne
  -- un'altra.
  v_pos_io int; v_pos_lui int; v_pos_avv int; v_pos_rit int;
  v_avv_ok boolean; v_rit_ok boolean;
  -- [031] La manovra del candidato non è un attacco e non accetta metri.
  v_man jsonb := '[]'::jsonb; v_dist_dopo_avv int;
  v_principale_dopo boolean := false;
begin
  select * into v from public.esame_prove where id = p_prova;
  if not found then raise exception 'La prova non esiste più'; end if;
  select * into v_prof from public.esame_png_profili where id = v.profilo_id;

  v_png  := (lower(coalesce(p_chi,'candidato')) = 'png');
  v_beat := v.beat;
  v_dist := abs(v.pos_png - v.pos_candidato);

  if v_png then
    v_vel := v_prof.velocita; v_nin := v_prof.ninjutsu; v_ck := v.ck_png;
    v_sost_round := v.sost_round_png;
    v_copie := coalesce(v.copie_attive_png,false);
  else
    select * into v_c from public.characters where id = v.candidate_character;
    v_vel := coalesce(v_c.velocita,0); v_nin := coalesce(v_c.ninjutsu,0); v_ck := v.ck_cand;
    v_sost_round := v.sost_round_cand;
    v_copie := coalesce(v.copie_attive_cand,false);
  end if;
  v_maxm := (v_vel / 10) * 5;

  -- [ADDENDUM] `_esame_muove` è la sede unica: si ferma sul bersaglio, non
  -- scavalca, e rispetta il campo. Se questo elenco calcolasse i metri con
  -- un'aritmetica sua, tornerebbe il difetto in forma più piccola.
  v_pos_io  := case when v_png then v.pos_png else v.pos_candidato end;
  v_pos_lui := case when v_png then v.pos_candidato else v.pos_png end;
  v_pos_avv := public._esame_bordo(public._esame_muove(v_pos_io, v_pos_lui, v_maxm, true));
  v_pos_rit := public._esame_bordo(public._esame_muove(v_pos_io, v_pos_lui, v_maxm, false));
  v_avv_ok  := v_maxm > 0 and v_pos_avv is distinct from v_pos_io;
  v_rit_ok  := v_maxm > 0 and v_pos_rit is distinct from v_pos_io;

  -- L'economia dell'azione vale per chi ha il turno d'attacco in questa metà.
  v_speso        := v.usato_principale and ((v.meta = 'png') = v_png);
  v_rapida_spesa := v.usato_rapida     and ((v.meta = 'png') = v_png);
  v_sposta_spesa := v.usato_spostamento and ((v.meta = 'png') = v_png);

  v_motivo_beat := case v_beat
    when 1 then 'In questa prova non ancora: prima il passo e il colpo, il maestro vuole vedere quelli.'
    when 2 then 'In questa prova non ancora: prima mostra come ti muovi.'
    else null end;

  -- ── principali: i jutsu. Beat 1 non li offre ancora; beat 2 sì. ──────────
  -- Nessuna tecnica di clan per il PNG: un avversario d'esame non ha clan.
  select coalesce(jsonb_agg(x order by x->>'nome'), '[]'::jsonb) into v_princ from (
    select jsonb_build_object(
      'id', j.id, 'fonte', 'jutsu', 'nome', j.name_it, 'clan', null, 'livello', null,
      'grado', j.rank, 'disciplina', j.category, 'gittata', coalesce(j.gittata,'media'),
      'portata_m', public._fascia_metri(coalesce(j.gittata,'media')),
      'chakra', coalesce(j.chakra_cost,0),
      'posseduta', true,
      'disponibile', v_dist <= public._fascia_metri(coalesce(j.gittata,'media'))
                     and (coalesce(j.chakra_cost,0) = 0 or v_ck >= coalesce(j.chakra_cost,0))
                     and not v_speso,
      'motivo_no', case
        when v_speso then 'hai già speso l''azione principale'
        when v_dist > public._fascia_metri(coalesce(j.gittata,'media'))
          then 'a ' || v_dist || ' metri non arriva: copre ' || public._fascia_metri(coalesce(j.gittata,'media'))
        when coalesce(j.chakra_cost,0) > v_ck
          then 'servono ' || j.chakra_cost || ' chakra, ne hai ' || v_ck
        end) as x
      from public.jutsu j
     where j.is_active and j.uso = 'principale' and not coalesce(j.difensiva,false)
       -- [017-R1] un diversivo NON è un attacco: esce dall'elenco delle
       -- principali e rientra sotto `diversivi`, che ha regole sue. È in UN
       -- PUNTO SOLO, ed è il perimetro di cui parla `04_COLONNE.md`.
       and not coalesce(j.diversivo,false)
       -- [042-B0] né una tecnica di scena. Vale per il candidato E per il
       -- PNG: `_esame_png_intenzioni` cicla su questo stesso elenco.
       and not coalesce(j.di_scena,false)
       and ( (v_png and j.id = any(v_prof.repertorio))
             or (not v_png and exists (select 1 from public.character_jutsu cj
                                        where cj.jutsu_id = j.id and cj.user_id = v.candidate_user)) )
  ) s;

  if not v_png then
    select coalesce(jsonb_agg(x order by x->>'nome'), '[]'::jsonb) into v_scen from (
      select jsonb_build_object(
        'id', j.id, 'fonte', 'scena', 'nome', j.name_it,
        'grado', j.rank, 'disciplina', j.category, 'gittata', 'sé stesso',
        'portata_m', 0, 'chakra', coalesce(j.chakra_cost,0),
        'posseduta', true,
        'disponibile', not v_speso
                       and (coalesce(j.chakra_cost,0) = 0 or v_ck >= coalesce(j.chakra_cost,0)),
        'motivo_no', case
          when v_speso then 'hai già speso l''azione principale'
          when coalesce(j.chakra_cost,0) > v_ck
            then 'servono ' || j.chakra_cost || ' chakra, ne hai ' || v_ck
          end) as x
        from public.jutsu j
       where j.is_active and coalesce(j.di_scena,false)
         and j.uso <> 'fuori_scontro'
         and exists (select 1 from public.character_jutsu cj
                      where cj.jutsu_id = j.id and cj.user_id = v.candidate_user)
    ) s;
    v_princ := v_princ || v_scen;
  end if;

  -- ── innate: solo il candidato può averne, e solo al beat 3 ──────────────
  if not v_png then
    select coalesce(jsonb_agg(x order by x->>'nome'), '[]'::jsonb) into v_inn from (
      select jsonb_build_object(
        'id', t.id, 'fonte', 'innata', 'nome', t.name, 'clan', t.clan, 'livello', t.level,
        'chakra', coalesce(t.chakra_cost,0), 'per_round', true, 'posseduta', true,
        'disponibile', v_beat >= 3 and not v_speso
                       and (coalesce(t.chakra_cost,0) = 0 or v_ck >= coalesce(t.chakra_cost,0)),
        'motivo_no', case
          when v_beat < 3 then 'In questa prova non ancora: si aggiunge all''ultimo scambio.'
          when v_speso then 'hai già speso l''azione principale'
          when coalesce(t.chakra_cost,0) > v_ck
            then 'servono ' || t.chakra_cost || ' chakra, ne hai ' || v_ck
          end) as x
        from public.clan_techniques t
        join public.character_abilities ca
          on ca.technique_id = t.id and ca.character_id = v.candidate_character and ca.state = 'attiva'
       where t.is_active and t.is_innata and t.consumption_type = 'per_turno'
         and public._grade_rank(coalesce(v_c.rank,'Deshi')) >=
             public._grade_rank(coalesce(t.req_grade,'Deshi'))
    ) s;
  end if;

  -- [R3] Guardia è ritirata: non esistono rapide nel contratto dell'Esame.
  v_rap := '[]'::jsonb;

  -- ── reazioni: schivata e parata sempre; la Sostituzione solo al beat 3 ──
  select j.id, coalesce(j.chakra_cost,0) into v_sost_id, v_sost_ck
    from public.jutsu j
   where j.is_active and j.difensiva and j.action_type = 'reazione'
     and ( (v_png and j.id = any(v_prof.repertorio))
           or (not v_png and exists (select 1 from public.character_jutsu cj
                                      where cj.jutsu_id = j.id and cj.user_id = v.candidate_user)) )
   limit 1;

  -- Stesso confine di combat_dichiara_difesa: una ogni tre turni difensivi.
  v_sost_ok := v_sost_id is not null
           and (v_sost_round is null or v_sost_round < v.scambio - 2)
           and (coalesce(v_sost_ck,0) = 0 or v_ck >= coalesce(v_sost_ck,0));

  v_posizioni := (select coalesce(jsonb_agg(m order by m),'[]'::jsonb) from unnest(array[0,5,10,15]) m
                   where m <= case when v_nin < 25 then 0 when v_nin < 50 then 5
                                   when v_nin < 75 then 10 else 15 end);

  if v.fase='difesa'
     and (v.pend_azione->'principale'->>'fonte')='jutsu'
     and exists (select 1 from public.jutsu a
                  where a.id=(v.pend_azione->'principale'->>'id')::uuid
                    and lower(a.category)='genjutsu') then
    select j.id,j.name_it,coalesce(j.chakra_cost,0)
      into v_disp_id,v_disp_nome,v_disp_ck
      from public.jutsu j
     where j.is_active and j.name_it='Dispersione'
       and ((v_png and j.id=any(v_prof.repertorio))
         or (not v_png and exists(select 1 from public.character_jutsu cj
                                  where cj.jutsu_id=j.id and cj.user_id=v.candidate_user)))
     limit 1;
    v_disp_ok := v_disp_id is not null and (v_disp_ck=0 or v_ck>=v_disp_ck);
  end if;

  v_reaz := jsonb_build_array(
    jsonb_build_object('chiave','schivata','nome','Schivata','chakra',0,'disponibile',true),
    jsonb_build_object('chiave','parata','nome','Parata','chakra',0,'disponibile',true),
    jsonb_build_object('chiave','sostituzione','nome','Sostituzione','id',v_sost_id,
      'chakra', coalesce(v_sost_ck,0),
      'disponibile', v_sost_ok,
      'posizioni', v_posizioni,
      'motivo_no', case
        when v_sost_id is null then 'non la conosci'
        when v_sost_round is not null and v_sost_round >= v.scambio - 2
          then 'si usa una volta ogni tre turni difensivi'
        when coalesce(v_sost_ck,0) > v_ck
          then 'servono ' || v_sost_ck || ' chakra, ne hai ' || v_ck end));

  -- [A10 §B] Le copie compaiono SOLO se ci sono. Niente voce grigia con
  -- un motivo_no: una difesa che non si può giocare non è un'opzione.
  if v_copie then
    v_reaz := v_reaz || jsonb_build_array(jsonb_build_object(
      'chiave','copie','nome','Confondere con le copie','chakra',0,
      'disponibile', v.fase = 'difesa'));
  end if;

  -- [A10 §B] Stesso principio per la Dispersione: c'è quando è giocabile
  -- (contro Genjutsu e con il chakra che basta), altrimenti non c'è.
  if v_disp_ok then
    v_reaz := v_reaz || jsonb_build_array(jsonb_build_object(
      'chiave','tecnica','id',v_disp_id,'nome',v_disp_nome,'fonte','jutsu',
      'disciplina','Abilità','chakra',v_disp_ck,'disponibile',true));
  end if;

  -- ── [017-R1] il diversivo: DUE direzioni, e solo se muovono davvero ────
  -- Le condizioni sono quattro e stanno tutte qui, perché l'elenco è la sola
  -- fonte di legalità (decisione PM 9). `_esame_diversivo` le ricontrolla
  -- comunque: chi esegue non si fida di chi offre.
  --
  -- ⚠️ `manovre_png < 2` vale anche per il diversivo, e non è pignoleria: il
  -- diversivo incrementa `manovre_png`, quindi eredita la prova di
  -- terminazione della R2. Se lo si offrisse oltre il due, si allungherebbe
  -- una catena che la R2 ha dimostrato finita, e la dimostrazione andrebbe
  -- rifatta da capo.
  select j.id, j.name_it, coalesce(j.chakra_cost,0)
    into v_div_id, v_div_nome, v_div_ck
    from public.jutsu j
   where j.is_active and coalesce(j.diversivo,false)
     and ( (v_png and j.id = any(v_prof.repertorio))
           or (not v_png and exists (select 1 from public.character_jutsu cj
                                      where cj.jutsu_id = j.id and cj.user_id = v.candidate_user)) )
   order by j.name_it limit 1;

  v_div_scorso := case when v_png then v.diversivo_scambio_png else v.diversivo_scambio_cand end;
  v_div_ok := v_div_id is not null
              and v.fase = 'attacco'
              and not v_speso
              and v_div_ck <= v_ck
              and (v_div_scorso is null or v_div_scorso < v.scambio)
              and (not v_png or v.manovre_png < 2);

  if v_div_ok then
    select coalesce(jsonb_agg(x order by x->>'chiave'), '[]'::jsonb) into v_div from (
      select jsonb_build_object(
        'chiave',    d.dir,
        'nome',      case d.dir when 'avvicinamento' then 'Coprire un avvicinamento'
                                else 'Coprire una ritirata' end,
        'tecnica',   v_div_nome,
        'id',        v_div_id,
        'chakra',    v_div_ck,
        'distanza_dopo', abs(public._esame_bordo(public._diversivo_posizione(
                             case when v_png then v.pos_png else v.pos_candidato end,
                             case when v_png then v.pos_candidato else v.pos_png end,
                             d.dir, v_maxm, 2, 5))
                           - (case when v_png then v.pos_candidato else v.pos_png end)),
        'disponibile', true) as x
        from (values ('avvicinamento'),('ritirata')) as d(dir)
       -- zero offerte morte: una direzione che non cambia la posizione non
       -- viene presentata. Non è un vezzo di interfaccia, è il mandato.
       where public._esame_diversivo_cambia(
               case when v_png then v.pos_png else v.pos_candidato end,
               case when v_png then v.pos_candidato else v.pos_png end,
               d.dir, v_maxm, 2)
    ) s;
  end if;

  -- [107] Assalto usa soltanto l'avanzamento interno che chiude davvero la
  -- misura. Il payload offre zero se il candidato è già a contatto, altrimenti
  -- l'unica distanza positiva necessaria. Se la Velocità non basta, Assalto
  -- non compare fra le modalità: il client non deve proporre mosse morte.
  if not v_png then
    if v_dist <= 2 then
      v_assalto_avanzamenti := jsonb_build_array(0);
    elsif v_avv_ok and abs(v_pos_avv-v_pos_lui) <= 2
          and mod(abs(v_pos_avv-v_pos_io),5)=0 then
      v_assalto_avanzamenti := jsonb_build_array(abs(v_pos_avv-v_pos_io));
    else
      v_assalto_avanzamenti := '[]'::jsonb;
    end if;
  end if;

  -- [077] Per il candidato Moltiplicazione è UNA tecnica. Direzione e modalità
  -- sono decisioni di secondo livello; copie e costi arrivano dal server.
  if not v_png and v_div_id is not null then
    v_direzioni:=v_div;
    v_copie_cap:=least(public._copie_cap(coalesce(v_c.ninjutsu,0),coalesce(v_c.rank,'Deshi')),4,
                       greatest(0,(v_ck-v_div_ck)/5));
    select coalesce(jsonb_agg(n order by n),'[]'::jsonb) into v_copie_offerte
      from generate_series(1,v_copie_cap) n;
    if v.fase='attacco' and not v_speso and v_copie_cap>0
       and (v_div_scorso is null or v_div_scorso<v.scambio) then
      v_div:=jsonb_build_array(jsonb_build_object(
        'id',v_div_id,'tecnica',v_div_nome,'nome',v_div_nome,'disponibile',true,
        'modalita_offerte',jsonb_build_array('diversivo','copertura') ||
          case when jsonb_array_length(v_assalto_avanzamenti)>0
               then jsonb_build_array('assalto') else '[]'::jsonb end,
        'assalto_avanzamenti',v_assalto_avanzamenti,
        'direzioni_offerte',v_direzioni,'copie_offerte',v_copie_offerte,
        'copie_max',v_copie_cap,'costo_base',v_div_ck,'costo_per_copia',5));
    else
      v_div:='[]'::jsonb;
    end if;
  end if;

  -- ── [031] manovra di chiusura del candidato ──────────────────────────────
  -- Il confronto è sullo stato RISULTANTE dopo il massimo avvicinamento.
  -- Le innate disponibili contano: se il candidato può agire, la manovra
  -- non compare. Il server calcola distanza e posizione, mai il client.
  v_dist_dopo_avv := abs(v_pos_avv - v_pos_lui);
  select (v_dist_dopo_avv <= 2)
      or exists (
           select 1 from jsonb_array_elements(v_princ) e
            where coalesce((e->>'chakra')::int,0) <= v_ck
              and coalesce((e->>'portata_m')::int,0) >= v_dist_dopo_avv)
      or exists (
           select 1 from jsonb_array_elements(v_inn) e
            where coalesce((e->>'disponibile')::boolean,false))
    into v_principale_dopo;

  if not v_png
     and v.fase = 'attacco' and v.meta = 'candidato'
     and not v_speso and not v_sposta_spesa
     and v_avv_ok
     and jsonb_array_length(v_div) = 0
     and not v_principale_dopo then
    v_man := jsonb_build_array(jsonb_build_object(
      'chiave', 'avvicinamento',
      'nome', 'Chiudere la misura',
      'disponibile', true,
      'distanza_dopo', v_dist_dopo_avv));
  end if;

  return jsonb_build_object(
    'versione', 1,
    'prova_id', v.id, 'chi', case when v_png then 'png' else 'candidato' end,
    'scambio', v.scambio, 'beat', v_beat, 'fase', v.fase, 'meta', v.meta,
    'distanza', v_dist,
    'fascia', case when v_dist <= 2 then 'a contatto' when v_dist <= 10 then 'corta'
                   when v_dist <= 30 then 'media' else 'lunga' end,
    'slancio', case when v_png then v.slancio_png else v.slancio_cand end,
    'chakra', jsonb_build_object('ora', v_ck, 'max', case when v_png then v.ck_png_max else v.ck_cand_max end),
    'spostamento', jsonb_build_object(
      'disponibile', v.fase = 'attacco' and not v_sposta_spesa
                     and (v_avv_ok or v_rit_ok),
      'max_metri', v_maxm,
      'avvicinamento', jsonb_build_object(
        'disponibile', v.fase = 'attacco' and not v_sposta_spesa and v_avv_ok,
        'metri',         abs(v_pos_avv - v_pos_io),
        'distanza_dopo', abs(v_pos_avv - v_pos_lui),
        'motivo_no', case when not v_avv_ok then 'sei già addosso: non c''è terreno da guadagnare' end),
      'ritirata', jsonb_build_object(
        'disponibile', v.fase = 'attacco' and not v_sposta_spesa and v_rit_ok,
        'metri',         abs(v_pos_rit - v_pos_io),
        'distanza_dopo', abs(v_pos_rit - v_pos_lui),
        'motivo_no', case when not v_rit_ok then 'da qui non puoi cedere altro terreno' end),
      'motivo_no', case when v.fase = 'difesa' then 'in difesa si risponde e basta'
                        when v_sposta_spesa then 'già speso in questo round'
                        when not (v_avv_ok or v_rit_ok) then 'nessuno spostamento cambierebbe la posizione' end),
    'colpo', jsonb_build_object('nome','Colpo a mani nude','fonte','colpo','gittata','contatto',
      'portata_m', 2, 'chakra', 0,
      'disponibile', v_dist <= 2 and not v_speso,
      'disponibile_dopo_avvicinamento',
        v_dist > 2 and not v_speso and v_avv_ok and v_dist_dopo_avv <= 2,
      'motivo_no', case when v_speso then 'hai già speso l''azione principale'
                        when v_dist > 2 then 'a ' || v_dist || ' metri non lo raggiungi: serve il contatto' end),
    'principali', v_princ,
    'diversivi', v_div,
    'manovre', v_man,
    'innate', v_inn,
    'rapide', v_rap,
    'reazioni', v_reaz);
end
$function$;

REVOKE ALL ON FUNCTION public._esame_prova_opzioni_legacy_v1(uuid,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public._esame_prova_opzioni_legacy_v1(uuid,text) TO postgres,service_role;


-- SOURCE candidato/full_body/_esame_risolvi_legacy_v1.sql
CREATE OR REPLACE FUNCTION public._esame_risolvi_legacy_v1(p_prova uuid, p_azione jsonb, p_chi text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_c public.characters%rowtype;
  v_att jsonb;                       -- l'attacco dichiarato e in attesa
  v_chi_att text; v_png_att boolean;
  v_kind text := 'fisico'; v_base int := 0; v_tech text := 'Colpo a mani nude';
  v_elem text; v_gittata text := 'contatto'; v_portata int := 2;
  v_reaz text; v_dif_disc text; v_dif_tech text;
  v_a jsonb; v_d jsonb; v_calc jsonb;
  v_dist int; v_dado_a int; v_dado_d int;
  v_pv int; v_pv_max int; v_slancio int; v_slancio_next int;
  v_ck_costo int := 0; v_ck_reaz int := 0;
  v_ordine int; v_colpito boolean; v_striscio boolean; v_appl int; v_ko boolean := false;
  v_nome_att text; v_nome_dif text; v_esito text; v_base_frase text; v_frase text;
  v_loc uuid; v_copie_attive boolean := false; v_esito_copie text;
  v_assalto boolean := false; v_copie_att int := 0; v_mod_assalto int := 0; v_esito_assalto text;
  v_originale_idx int := 0; v_bersaglio_idx int := 0;
  -- [038] la ricevuta del ciclo, la riga di scambio appena scritta e il
  -- testo composto. `v_frase` resta: è ancora la voce del ripiego.
  v_ciclo public.esame_narrazione_cicli%rowtype; v_scambio_id uuid;
  v_app text; v_testo text; v_mid uuid; v_ruolo_png text;
  v_esito_ciclo uuid; v_esito_ricevuta uuid;
  v_finale boolean := false; v_finale_tipo text; v_senza_forze jsonb;
  v_scambio_risolto int;
  -- [BANCO 038] l'intestazione AZIONE e l'etichetta chiusa della
  -- reazione, per il ripiego in difesa.
  v_az text; v_et text; v_referto jsonb; v_dist_lab text; v_danno_lab text;
  -- [001] la ricevuta arricchita: bersaglio, conseguenza, gravità, ancora,
  -- movimento, iniziativa — fatti del server, in parole.
  v_zona text; v_conseg text; v_grav text; v_ancora jsonb; v_pos_dif int;
  v_movimento text; v_pc_prima int; v_pp_prima int;
begin
  select * into v from public.esame_prove where id = p_prova for update;
  if not found then raise exception 'La prova non esiste più'; end if;
  if v.stato <> 'aperta' then raise exception 'La prova non è più aperta'; end if;
  select * into v_prof from public.esame_png_profili where id = v.profilo_id;
  select * into v_c from public.characters where id = v.candidate_character;
  select location_id into v_loc from public.academy_class_sessions where id = v.class_session_id;

  v_att := coalesce(v.pend_azione, '{}'::jsonb);
  v_chi_att := case when v.meta = 'png' then 'png' else 'candidato' end;
  v_png_att := (v_chi_att = 'png');
  if lower(coalesce(p_chi,'')) = v_chi_att then
    raise exception 'Chi attacca non può anche reagire: la metà di scambio è mal composta.';
  end if;

  v_nome_att := case when v_png_att then v_prof.nome else v_c.name end;
  v_nome_dif := case when v_png_att then v_c.name else v_prof.nome end;
  v_dist := abs(v.pos_png - v.pos_candidato);

  -- ── che cosa attacca ────────────────────────────────────────────────────
  -- ── [017-R1] la terza rete: un diversivo non arriva MAI fin qui ─────────
  -- Gli unici scrittori di `pend_azione` sono `esame_prova_azione` e
  -- `_esame_png_gioca`, ed entrambi sono guardati. Se questo ramo si accende, un
  -- chiamante è regredito — e la scelta è fra una prova ferma e una prova che
  -- infligge danno con una tecnica che per regolamento non ne fa.
  -- ⚠️ SOLLEVA di proposito: scostamento dichiarato (§3 di
  -- `03_DECISIONI_E_SCOSTAMENTI.md`). Una prova ferma si vede; il danno
  -- silenzioso è esattamente il difetto che stiamo chiudendo.
  if (v_att->'principale'->>'fonte') = 'jutsu'
     and exists (select 1 from public.jutsu j
                  where j.id = (v_att->'principale'->>'id')::uuid
                    and coalesce(j.diversivo,false)) then
    raise exception 'Un diversivo non può essere risolto come attacco: la metà è mal composta.';
  end if;

  -- [042-B0] gemella, per la tecnica di scena.
  if (v_att->'principale'->>'fonte') = 'jutsu'
     and exists (select 1 from public.jutsu j
                  where j.id = (v_att->'principale'->>'id')::uuid
                    and coalesce(j.di_scena,false)) then
    raise exception 'Una tecnica di scena non può essere risolta come attacco: la metà è mal composta.';
  end if;

  v_assalto := (v_att->'principale'->>'fonte')='moltiplicazione'
               and (v_att->'principale'->>'modalita')='assalto';
  if v_assalto then
    v_kind:='fisico'; v_base:=10; v_tech:='Moltiplicazione del corpo · Assalto';
    v_elem:=null; v_gittata:='contatto'; v_portata:=2; v_ck_costo:=0;
    v_copie_att:=greatest(1,least(4,coalesce((v_att->'principale'->>'copie')::int,1)));
    v_originale_idx:=coalesce((v_att->'principale'->>'originale_idx')::int,0);
    if v_originale_idx<1 or v_originale_idx>v_copie_att+1 then
      raise exception 'L''Assalto non contiene un originale valido.';
    end if;
    v_bersaglio_idx:=1+mod(public._esame_dado(
      v.seme,public._esame_indice(v.scambio,v.meta,v_chi_att,'assalto')),v_copie_att+1);
    if v_bersaglio_idx=v_originale_idx then
      v_esito_assalto:='originale_individuato'; v_mod_assalto:=0;
    else
      v_esito_assalto:='copia_colpita'; v_mod_assalto:=public._copie_bonus(v_copie_att);
    end if;
  elsif (v_att->'principale'->>'fonte') = 'jutsu' then
    select lower(j.category), coalesce(j.damage_base,0), j.name_it, j.nature,
           coalesce(j.gittata,'media'), public._fascia_metri(coalesce(j.gittata,'media')),
           coalesce(j.chakra_cost,0)
      into v_kind, v_base, v_tech, v_elem, v_gittata, v_portata, v_ck_costo
      from public.jutsu j where j.id = (v_att->'principale'->>'id')::uuid;
  else
    v_kind := 'fisico'; v_base := 10; v_tech := 'Colpo a mani nude';
    v_elem := null; v_gittata := 'contatto'; v_portata := 2; v_ck_costo := 0;
  end if;

  -- ── come si reagisce ────────────────────────────────────────────────────
  v_reaz := lower(coalesce(p_azione->>'reazione','schivata'));
  if v_reaz not in ('schivata','parata','sostituzione','tecnica','copie') then
    raise exception 'reazione non valida';
  end if;
  v_copie_attive := case when v_png_att then coalesce(v.copie_attive_cand,false)
                         else coalesce(v.copie_attive_png,false) end;
  if v_reaz = 'copie' and not v_copie_attive then
    raise exception 'Le copie non sono più attive.';
  end if;
  if v_reaz = 'sostituzione' then
    -- [V1.1 · decisione 11] il costo si legge dalla riga vera, non si scrive 0.
    select j.name_it, lower(j.category), coalesce(j.chakra_cost,0)
      into v_dif_tech, v_dif_disc, v_ck_reaz
      from public.jutsu j
     where j.is_active and j.difensiva and j.action_type = 'reazione' limit 1;
    v_dif_tech := coalesce(v_dif_tech, 'Sostituzione');
    v_dif_disc := coalesce(v_dif_disc, 'ninjutsu');
  elsif v_reaz='tecnica' then
    if v_kind<>'genjutsu' then
      raise exception 'Dispersione si usa soltanto come difesa da un Genjutsu.';
    end if;
    select j.name_it,lower(j.category),coalesce(j.chakra_cost,0)
      into v_dif_tech,v_dif_disc,v_ck_reaz
      from public.jutsu j
     where j.id=nullif(p_azione->>'tecnica','')::uuid
       and j.is_active and j.name_it='Dispersione' and j.uso='difesa' and j.difensiva
       and ((v_png_att and exists(select 1 from public.character_jutsu cj
                                  where cj.jutsu_id=j.id and cj.user_id=v.candidate_user))
         or (not v_png_att and j.id=any(v_prof.repertorio)))
     limit 1;
    if v_dif_tech is null then
      raise exception 'Dispersione non posseduta o non disponibile.';
    end if;
  end if;

  -- ── i dadi: deterministici, dal seme della prova ────────────────────────
  v_dado_a := public._esame_dado(v.seme, public._esame_indice(v.scambio, v.meta, v_chi_att, 'att'));
  v_dado_d := public._esame_dado(v.seme, public._esame_indice(v.scambio, v.meta, v_chi_att, 'dif'));

  -- ── i due corpi, con lo Slancio dentro il json dell'ATTACCANTE ──────────
  v_slancio := case when v_png_att then v.slancio_png else v.slancio_cand end;
  if v_png_att then
    v_a := public._esame_corpo_json(v.profilo_id, v_slancio);
    v_d := public._esame_char_json(v.candidate_character, 0);
  else
    v_a := public._esame_char_json(v.candidate_character, case when v_assalto then 0 else v_slancio end);
    v_d := public._esame_corpo_json(v.profilo_id, 0);
  end if;

  v_d := v_d || jsonb_build_object('copie_n',case when v_png_att then v.copie_n_cand else v.copie_n_png end);
  v_calc := public._combat_calcola(
    v_kind, v_a, v_d, v_reaz, v_dif_disc, v_base, v_elem,
    v_dado_a, v_dado_d, v_mod_assalto, 0, false);

  if v_assalto and v_esito_assalto='copia_colpita' then
    v_d := v_d || jsonb_build_object(
      'velocita',0,'taijutsu',0,'mente',0,'ninjutsu',0,'genjutsu',0,'fuuinjutsu',0,'copie_n',0);
    v_calc := public._combat_calcola(
      v_kind,v_a,v_d,'nessuna',null,v_base,v_elem,
      v_dado_a,0,0,0,false);
  end if;

  v_colpito  := (v_calc->>'colpito')::boolean;
  v_striscio := (v_calc->>'striscio')::boolean;
  v_appl     := (v_calc->>'danno_applicato')::int;
  v_esito_copie := case when v_assalto then v_esito_assalto else nullif(v_calc->>'esito_copie','') end;

  -- ── le risorse SIMULATE: qui, e in nessun altro posto ───────────────────
  if v_png_att then
    v_pv := greatest(0, v.pv_cand - v_appl);  v_pv_max := v.pv_cand_max;
  else
    v_pv := greatest(0, v.pv_png  - v_appl);  v_pv_max := v.pv_png_max;
  end if;
  v_ko := (v_pv = 0);

  -- [001] i fatti in parole, decisi QUI e scritti sullo scambio.
  v_danno_lab := case when v_ko then 'fuori combattimento'
                      when v_appl = 0 then 'nessuno'
                      when v_appl <= greatest(1, v_pv_max / 10) then 'lieve'
                      when v_appl <= greatest(1, v_pv_max / 4) then 'serio'
                      else 'grave' end;
  v_zona   := case when not v_png_att then public._esame_zona_dichiarata((select m.body from public.esame_narrazione_cicli c2 join public.messages m on m.id = c2.pg_message_id  where c2.prova_id = p_prova and c2.ruolo = 'png_difende' order by c2.created_at desc limit 1), v.seme, public._esame_indice(v.scambio, v.meta, v_chi_att, 'att')) end;
  v_zona   := coalesce(v_zona, public._esame_zona(v.seme, v.scambio, v.meta, v_chi_att, v_kind)); -- [005] testo del candidato prima del dado
  v_grav   := case when v_colpito or v_striscio or v_ko then v_danno_lab else 'nessuno' end;
  v_conseg := case when v_colpito or v_striscio or v_ko
                   then public._esame_conseguenza(v_danno_lab, v_zona, v_ko) else 'nessuna' end;
  v_pos_dif := case when v_png_att then v.pos_candidato else v.pos_png end;
  v_ancora := case when v_reaz = 'sostituzione' and not v_colpito
                   then public._esame_ancora_scegli(p_prova, v_pos_dif) else null end;

  -- ── lo Slancio, con la regola del motore: +3 se non va a segno, tetto 9 ──
  if v_colpito then v_slancio_next := 0; else v_slancio_next := least(9, v_slancio + 3); end if;

  select coalesce(max(ordine),0) + 1 into v_ordine from public.esame_scambi where prova_id = p_prova;

  insert into public.esame_scambi (
    prova_id, profilo_id, scambio, meta, ordine, chi_attacca,
    attacker_name, defender_name, kind, tech_name, base, elemento, gittata, distanza,
    reazione, dif_tech_name, dif_disciplina,
    pool_att, pool_dif, dado_att, dado_dif, mod_mira, mod_guardia, mod_colto,
    mod_elem_att, mod_elem_dif, atk_tot, def_tot, margine, bonus_margine, off,
    riduzione_div, riduzione, danno_grezzo, danno_applicato, cap_attivo, colpito, ko,
    chakra_dichiarato, striscio, mod_slancio, slancio_successivo, esito_copie,
    opzione_scelta, scelta_da,
    pos_cand_prima, pos_png_prima, pos_cand, pos_png,
    bersaglio, conseguenza, gravita, ancora)
  values (
    p_prova, v.profilo_id, v.scambio, v.meta, v_ordine, v_chi_att,
    v_nome_att, v_nome_dif, v_kind, v_tech, v_base, v_elem, v_gittata, v_dist,
    v_reaz, v_dif_tech, v_dif_disc,
    (v_calc->>'pool_att')::int, (v_calc->>'pool_dif')::int,
    (v_calc->>'dado_att')::int, (v_calc->>'dado_dif')::int,
    (v_calc->>'mod_mira')::int, (v_calc->>'mod_guardia')::int, (v_calc->>'mod_colto')::int,
    (v_calc->>'mod_elem_att')::int, (v_calc->>'mod_elem_dif')::int,
    (v_calc->>'atk_tot')::int, (v_calc->>'def_tot')::int, (v_calc->>'margine')::int,
    (v_calc->>'bonus_margine')::int, (v_calc->>'off')::int,
    (v_calc->>'riduzione_div')::int, (v_calc->>'riduzione')::int,
    (v_calc->>'danno_grezzo')::int, v_appl, (v_calc->>'cap_attivo')::boolean,
    v_colpito, v_ko,
    v_ck_costo, v_striscio, (v_calc->>'mod_slancio')::int, v_slancio_next, v_esito_copie,
    coalesce(v_att->>'opzione_id', p_azione->>'opzione_id'),
    coalesce(v_att->>'scelta_da', p_azione->>'scelta_da', 'candidato'),
    -- «prima» viaggia dentro `pend_azione`, scritto da chi ha aperto la metà;
    -- se manca (una metà aperta da un corpo vecchio) si ripiega sullo stato di
    -- adesso, che è onesto: dice «non risulta nessun movimento».
    coalesce((v_att->>'pos_cand_prima')::int, v.pos_candidato),
    coalesce((v_att->>'pos_png_prima')::int,  v.pos_png),
    v.pos_candidato, v.pos_png,
    v_zona, v_conseg, v_grav, v_ancora->>'id')
  returning id into v_scambio_id;

  -- ── la voce: si racconta con le parole di riserva se l'IA non ha parlato ─
  v_esito := case
    when v_esito_copie = 'copia_colpita' then 'copia_colpita'
    when v_esito_copie = 'originale_individuato' then 'originale_individuato'
    when v_reaz = 'sostituzione' and not v_colpito then 'sostituito'
    when v_colpito then 'colpito'
    when v_striscio then 'sfiorato'
    when v_reaz = 'parata' then 'parato'
    when v_reaz = 'schivata' then 'schivato'
    else 'mancato' end;
  -- ═══ [038] LA VOCE UNICA · si pubblica SOLO la branca che è accaduta ═══
  --
  -- 🔴 Che cosa faceva questo blocco, e perché era sbagliato in due modi:
  --    (a) pubblicava con `_esame_post(v_loc, v_prof.nome, …)`, cioè con il
  --        NOME DEL PNG come autore — il difetto che il contratto chiude;
  --    (b) la guardia `if v_png_att` faceva sì che una difesa del PNG non
  --        venisse MAI narrata. È il fatto 2 di QA-037: «difesa complessa,
  --        nessun esito narrato». Non era una svista del modello: era questa
  --        riga.
  --
  -- Adesso: la prosa della branca reale viene dalla ricevuta, l'appendice la
  -- costruisce il server, e l'autore è sempre e solo «Il narratore».
  v_base_frase := (case when v_png_att then 'png_att' else 'cand_att' end) || '.'
               || (case when v_kind = 'fisico' then 'colpo' else 'tecnica' end) || '.' || v_esito;

  v_app := public._esame_appendice(v_scambio_id, public._esame_ciclo_numeri());

  -- La ricevuta viva di questo ciclo. `accettata` = il modello ha parlato ed è
  -- stato validato; `ripiego` = il modello è muto e la voce viene dal catalogo.
  select * into v_ciclo from public.esame_narrazione_cicli
   where prova_id = p_prova and stato in ('accettata','ripiego')
   order by created_at desc, id desc limit 1;

  if v_ciclo.id is not null
     and v_ciclo.stato = 'accettata'
     and v_ciclo.esiti ? v_esito then
    -- ⚠️ Il sigillo si ricontrolla QUI, sotto lock, prima di pubblicare. Non
    --    difende da un attaccante — chi scrive la tabella riscrive il sigillo —
    --    difende da NOI: una migrazione futura che tocchi `esiti` senza passare
    --    dal validatore fa diventare rossa la ricevuta invece di pubblicare
    --    prosa che nessuno ha validato.
    if v_ciclo.receipt_sha256 is distinct from public._esame_ricevuta_sigillo(
         v_ciclo.opzioni_id, v_ciclo.intenzione_id, v_ciclo.azione_png,
         v_ciclo.esiti, v_ciclo.esiti_attesi) then
      raise exception 'La ricevuta % non corrisponde al proprio sigillo: non pubblico.', v_ciclo.opzioni_id;
    end if;
    v_frase := v_ciclo.esiti->>v_esito;
  else
    -- Il ripiego: la frase del catalogo, con la regola di sempre. La differenza
    -- col passato è che adesso esce in TUTTI E DUE i ruoli, non solo quando il
    -- PNG attaccava.
    v_frase := public._esame_frase(p_prova, v_base_frase, v_ordine,
                 jsonb_build_object('attaccante', v_nome_att, 'difensore', v_nome_dif, 'tecnica', v_tech));
  end if;

  v_ruolo_png := coalesce(v_ciclo.ruolo, case when v_png_att then 'png_attacca' else 'png_difende' end);

  if v_frase is not null and btrim(v_frase) <> '' then
    if v_ruolo_png = 'png_difende' then
      -- UN messaggio solo: AZIONE + ESITO. L'azione è già stata validata e non
      -- è mai stata pubblicata da sola — è il punto del contratto §3.
      --
      -- 🔴 [BANCO 038 · difetto 5] IL RIPIEGO IN DIFESA HA LA STESSA FORMA.
      --    Col modello muto `azione_png` è nullo, e il ramo `else ''` faceva
      --    uscire il SOLO `ESITO`: due forme diverse per lo stesso momento
      --    della scena, e un'asimmetria col ripiego in attacco — che l'AZIONE
      --    la scrive, e per una ragione dichiarata («senza, il candidato
      --    riceverebbe un turno da difendere senza avere letto nessun
      --    attacco»). Qui vale identica: senza AZIONE il giocatore non legge
      --    mai che cosa il PNG ha TENTATO, solo com'è finita.
      --    L'etichetta è testo chiuso, e si legge dalla stessa porta che offre
      --    le reazioni: due elenchi delle stesse parole divergono.
      -- 🔴 «Kazane parata.» muore qui. Non era una frase: era un'etichetta con
      --    un punto in fondo, e attaccata alla prosa del modello produceva due
      --    voci nello stesso messaggio. Il ripiego adesso scrive una frase
      --    intera, con soggetto e verbo, scelta da un elenco CHIUSO del server.
      if coalesce(btrim(v_ciclo.azione_png),'') <> '' then
        v_az := btrim(v_ciclo.azione_png);
      else
        v_az := v_nome_dif || case lower(coalesce(v_reaz,''))
                  when 'parata'       then ' porta le braccia a coprirsi.'
                  when 'schivata'     then ' sposta il peso per uscire dalla traiettoria.'
                  when 'sostituzione' then ' tenta la Sostituzione.'
                  when 'copie'        then ' lascia che le sagome gli si chiudano davanti.'
                  else                     ' reagisce.' end;
      end if;
      -- 🔴 [A5] L'APPENDICE NON SI PUBBLICA PIÙ, NÉ IN MEZZO NÉ IN CODA.
      --    La A4 l'aveva spostata dopo la chiusura narrativa e questo bastava
      --    a togliere il difetto dell'INTERRUZIONE, non quello che Antonello
      --    aveva segnalato: «l'esito dev'essere prosa uniforme dal principio
      --    alla fine». Un tag `((Riuji → Kazane · Colpo · 0 m))` in fondo al
      --    messaggio resta un referto tecnico dentro la chat, e resta la cosa
      --    che rompe la voce del Narratore.
      --
      -- 🟢 `v_app` NON sparisce: continua a essere calcolata e finisce
      --    integra dentro `v_referto.appendice`, che è l'audit. Cambia solo
      --    che cosa vede il giocatore. Il referto autoritativo non si perde —
      --    era il vincolo esplicito della review.
      v_testo := regexp_replace(
        concat_ws(' ', public._esame_chiudi(v_az), public._esame_chiudi(v_frase)),
        '[[:space:]]+', ' ', 'g');
    else
      -- Il PNG aveva attaccato: l'AZIONE è già in chat da minuti, e qui esce
      -- soltanto l'ESITO — dalla STESSA risposta modello, senza una seconda
      -- chiamata. È il §4 del contratto.
      -- [A5] anche qui: solo prosa. L'appendice vive nel referto.
      v_testo := regexp_replace(
        public._esame_chiudi(v_frase),
        '[[:space:]]+', ' ', 'g');
    end if;
    -- [095/27] L'esito di una difesa del candidato non viene pubblicato
    -- prima che il Narratore abbia ricevuto il testo reale della difesa.
    v_mid := null;
  end if;

  -- La ricevuta si CONSUMA: una seconda difesa non può pubblicare un secondo
  -- ESITO (gate E-25).
  --
  -- ⚠️ CORREZIONE DEL BANCO (inversione D7a). La prima stesura di questo
  --    commento diceva che `where stato in (…)` era «la condizione che rende
  --    l'aggiornamento idempotente». È FALSO, e l'inversione lo ha dimostrato:
  --    toglierla non accende niente, perché la SELECT che carica `v_ciclo`
  --    dieci righe più su filtra GIÀ sugli stessi due stati — quindi qui la
  --    riga è codice morto difensivo, non la guardia.
  --    La guardia vera è quella SELECT, insieme al `for update` sulla prova.
  --    La riga resta perché costa nulla e protegge da una riscrittura futura
  --    della SELECT, ma chiamarla «la condizione» era esattamente il genere di
  --    commento che fa cercare il difetto nel posto sbagliato.
  -- ── il REFERTO: i fatti chiusi, senza un solo numero autoritativo ──────
  select e->>'nome' into v_et
    from jsonb_array_elements(
           public._esame_prova_opzioni(p_prova,
             case when v_png_att then 'candidato' else 'png' end)->'reazioni') e
   where e->>'chiave' = v_reaz;

  v_pc_prima := coalesce((v_att->>'pos_cand_prima')::int, v.pos_candidato);
  v_pp_prima := coalesce((v_att->>'pos_png_prima')::int,  v.pos_png);
  v_movimento := coalesce(nullif(concat_ws('; ',
    case when v_pc_prima <> v.pos_candidato then
      v_c.name || case when abs(v.pos_png - v.pos_candidato) < abs(v.pos_png - v_pc_prima)
                       then ' ha guadagnato terreno' else ' ha ceduto terreno' end
      || case when v.pos_candidato in (0,10) then ', fino al bordo del tatami' else '' end end,
    case when v_pp_prima <> v.pos_png then
      v_prof.nome || case when abs(v.pos_png - v.pos_candidato) < abs(v_pp_prima - v.pos_candidato)
                          then ' ha guadagnato terreno' else ' ha ceduto terreno' end
      || case when v.pos_png in (0,10) then ', fino al bordo del tatami' else '' end end), ''), 'nessuno');
  v_dist_lab := case when v_dist <= 2 then 'a contatto'
                     when v_dist <= 10 then 'a corta distanza'
                     when v_dist <= 30 then 'a media distanza'
                     else 'a lunga distanza' end;
  v_danno_lab := case when v_ko then 'fuori combattimento'
                      when v_appl = 0 then 'nessuno'
                      when v_appl <= greatest(1, v_pv_max / 10) then 'lieve'
                      when v_appl <= greatest(1, v_pv_max / 4) then 'serio'
                      else 'grave' end;
  v_referto := jsonb_build_object(
    'ruolo_png',      v_ruolo_png,
    'attaccante',     v_nome_att,
    'difensore',      v_nome_dif,
    'tecnica',        v_tech,
    'genere_attacco', v_kind,
    'reazione',       v_reaz,
    'reazione_nome',  coalesce(v_et, 'una reazione'),
    'esito',          v_esito,
    'colpito',        v_colpito,
    'di_striscio',    v_striscio,
    'fuori_combattimento', v_ko,
    'danno',          v_danno_lab,
    'distanza',       v_dist_lab,
    'appendice',      nullif(btrim(coalesce(v_app,'')),''),
    -- [001] la ricevuta arricchita (P1): fatti del server, solo parole.
    'bersaglio',      v_zona,
    'bersaglio_su',   case when v_esito_copie = 'copia_colpita' then 'una copia di ' || v_nome_dif else v_nome_dif end,
    'conseguenza',    v_conseg,
    'gravita',        v_grav,
    'postura_difensore', case when v_colpito or v_ko then public._esame_postura(v_danno_lab, v_ko) else 'in guardia' end,
    'movimento',      v_movimento,
    'iniziativa',     case when v_png_att then 'passa a ' || v_nome_dif else 'passa a ' || v_nome_att end,
    'scambio',        case v.scambio when 1 then 'primo' when 2 then 'secondo' when 3 then 'terzo' else 'ultimo' end,
    'ancora',         v_ancora,
    'segni',          public._esame_segni(p_prova, v_ordine));

  if v_ciclo.id is not null then
    update public.esame_narrazione_cicli
       -- [090-CICLI:2:INIZIO]
     -- Se il motore ha prodotto un esito che l'elenco congelato non
     -- prevedeva, l'elenco si AMPLIA invece di far saltare la transazione.
     -- L'esito e' legittimo per costruzione: viene da `_esame_esiti_reazione`
     -- della reazione davvero giocata. Il CHECK resta severo com'era:
     -- cambia chi lo rispetta, non quanto e' severo.
     -- ⚠️ Nella stessa UPDATE il lato destro legge la riga VECCHIA, quindi
     --    `esiti_attesi` qui e' ancora quello di prima: ed e' cio' che serve.
     -- ⚠️ `array_append` e non `esiti_attesi || v_esito`: Postgres legge il
     --    secondo come array||array e fallisce con «malformed array literal».
     --    E' la trappola §3 delle convenzioni, ripresa in flagrante dal banco.
     set stato = 'risolta',
         esiti_attesi = case when v_esito = any(esiti_attesi) then esiti_attesi
                             else (select array_agg(distinct x order by x)
                                     from unnest(array_append(esiti_attesi, v_esito)) x) end,
         esiti_ampliati = esiti_ampliati or not (v_esito = any(esiti_attesi)),
         esito_reale = v_esito, referto = v_referto,
     -- [090-CICLI:2:FINE]
           testo_esito = nullif(btrim(v_testo),'') ,
           result_message_id = coalesce(v_mid, result_message_id),
           resolved_at = now()
     where id = v_ciclo.id and stato in ('accettata','ripiego');
  end if;

  -- ── avanzamento della macchina a stati (§5.2) ───────────────────────────
  v_scambio_risolto := v.scambio;
  update public.esame_prove set
    pv_cand = case when v_png_att then v_pv else pv_cand end,
    pv_png  = case when v_png_att then pv_png else v_pv end,
    slancio_cand = case when v_png_att then slancio_cand else v_slancio_next end,
    slancio_png  = case when v_png_att then v_slancio_next else slancio_png end,
    sost_round_cand = case when (not v_png_att) or v_reaz <> 'sostituzione' then sost_round_cand else v.scambio end,
    sost_round_png  = case when v_png_att or v_reaz <> 'sostituzione' then sost_round_png else v.scambio end,
    sost_usata_cand = sost_usata_cand or (v_png_att and v_reaz = 'sostituzione'),
    ck_cand = case when v_png_att and v_reaz in ('sostituzione','tecnica') then greatest(0, ck_cand - v_ck_reaz)
                   when (not v_png_att) then greatest(0, ck_cand - v_ck_costo) else ck_cand end,
    ck_png  = case when (not v_png_att) and v_reaz in ('sostituzione','tecnica') then greatest(0, ck_png  - v_ck_reaz)
                   when v_png_att then greatest(0, ck_png - v_ck_costo) else ck_png end,
    tecnica_png_usata = tecnica_png_usata or (v_png_att and v_kind <> 'fisico'),
    -- Il primo attacco diretto consuma le copie del difensore, anche quando
    -- sceglie Schivata, Parata o Sostituzione.
    copie_attive_cand = case
      when v_png_att then false
      when v_assalto then false
      else copie_attive_cand end,
    copie_attive_png  = case when v_png_att then copie_attive_png else false end,
    copie_n_cand = case
      when v_png_att then 0
      when v_assalto then 0
      else copie_n_cand end,
    copie_n_png  = case when v_png_att then copie_n_png else 0 end,
    copie_scambio_cand = case
      when v_png_att then null
      when v_assalto then null
      else copie_scambio_cand end,
    copie_scambio_png  = case when v_png_att then copie_scambio_png else null end,
    copie_salvate_cand = copie_salvate_cand
      + case when v_png_att and v_esito_copie = 'copia_colpita' then 1 else 0 end,
    pend_azione = null,
    opzioni_png = null, opzioni_id = null, opzioni_at = null,
    usato_principale = false, usato_rapida = false, usato_spostamento = false,
    -- fine della metà: se attaccava il candidato tocca al PNG, altrimenti si
    -- chiude lo scambio e si sale di gradino.
    meta    = case when v_png_att then 'candidato' else 'png' end,
    fase    = 'attacco',
    scambio = case when v_png_att then least(4, v.scambio + 1) else v.scambio end,
    beat    = case when v_png_att then least(4, v.scambio + 1) else v.beat end,
    -- Le colonne Guardia sono storiche: non vengono più scritte.
    guardia_cand = guardia_cand,
    guardia_png  = guardia_png
  where id = p_prova;

  -- KO simulato o QUARTO scambio finito: si chiude come «done», non come persa.
  -- (Il contratto è a quattro round: vedi `di_scambi` in `_esame_stato_json` e
  --  il vincolo `esame_prove_scambio_beat`, allargato a 1..4 dal §7.)
  -- Si rilegge la fotografia DOPO costi e danni: il chakra arrivato a zero
  -- è una condizione terminale tanto quanto i PV, anche se l'ultimo colpo non
  -- ha prodotto un KO fisico.
  select * into v from public.esame_prove where id=p_prova;
  v_finale := v.pv_cand<=0 or v.pv_png<=0 or v.ck_cand<=0 or v.ck_png<=0
               or (v_png_att and v_scambio_risolto>=4);

  if v_finale then
    v_finale_tipo := case
      when v.pv_cand<=0 or v.pv_png<=0 or v.ck_cand<=0 or v.ck_png<=0
        then 'sfinimento'
      else 'quattro_round' end;
    v_senza_forze := coalesce((select jsonb_agg(nome order by nome) from (
      select v_c.name nome where v.pv_cand<=0 or v.ck_cand<=0
      union all
      select v_prof.nome where v.pv_png<=0 or v.ck_png<=0
    ) q),'[]'::jsonb);
    v_referto := v_referto || jsonb_build_object(
      'finale_tipo',v_finale_tipo,
      'senza_forze',v_senza_forze,
      'chiusura_richiesta','ultimo esito e intervento del Sensei nello stesso racconto',
      'iniziativa','la prova si chiude');

    v_esito_ciclo := gen_random_uuid();
    v_esito_ricevuta := gen_random_uuid();
    insert into public.esame_narrazione_cicli
      (id,prova_id,opzioni_id,ruolo,stato,pg_message_id,
       esiti,esiti_attesi,testo_esito,referto,created_at)
    values
      (v_esito_ciclo,p_prova,v_esito_ricevuta,'png_finale','aperta',
       (select pg_message_id from public.esame_prove where id=p_prova),
       '{}'::jsonb,array[]::text[],nullif(btrim(v_testo),''),v_referto,now());
    update public.esame_prove set
      meta='narratore', fase='finale', pend_azione=null,
      opzioni_id=v_esito_ricevuta, opzioni_at=now(),
      opzioni_png=jsonb_build_object('intenzioni',jsonb_build_array(jsonb_build_object(
        'intenzione_id','narra_finale','chiave','narra_finale',
        'etichetta','Concludi l''Esame','genere','finale',
        'esiti_possibili','[]'::jsonb)))
    where id=p_prova;
  elsif v_png_att then
    -- La meccanica è già chiusa e il candidato avrebbe di nuovo l'offensiva,
    -- ma l'azione resta bloccata finché questo esito non è stato pubblicato.
    v_esito_ciclo := gen_random_uuid();
    v_esito_ricevuta := gen_random_uuid();
    insert into public.esame_narrazione_cicli
      (id,prova_id,opzioni_id,ruolo,stato,pg_message_id,
       esiti,esiti_attesi,testo_esito,referto,created_at)
    values
      (v_esito_ciclo,p_prova,v_esito_ricevuta,'png_esito','aperta',
       (select pg_message_id from public.esame_prove where id=p_prova),
       '{}'::jsonb,array[]::text[],nullif(btrim(v_testo),''),v_referto,now());
    update public.esame_prove set
      opzioni_id=v_esito_ricevuta, opzioni_at=now(),
      opzioni_png=jsonb_build_object('intenzioni',jsonb_build_array(jsonb_build_object(
        'intenzione_id','narra_esito','chiave','narra_esito',
        'etichetta','Racconta l''esito della difesa','genere','esito',
        'esiti_possibili','[]'::jsonb)))
    where id=p_prova;
  else
    perform public._esame_png_turno(p_prova);
  end if;

  return jsonb_build_object('versione',1,'ordine',v_ordine,'esito',v_esito,
                            'esito_copie',v_esito_copie,
                            'colpito',v_colpito,'striscio',v_striscio,'danno',v_appl);
end
$function$;

REVOKE ALL ON FUNCTION public._esame_risolvi_legacy_v1(uuid,jsonb,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public._esame_risolvi_legacy_v1(uuid,jsonb,text) TO postgres,service_role;


-- SOURCE release/030_CICLO_PAYLOAD.sql
CREATE OR REPLACE FUNCTION public._esame_ciclo_payload(p_prova uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  c public.esame_narrazione_cicli%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_c public.characters%rowtype;
  v_int jsonb; v_e jsonb; v_out jsonb := '[]'::jsonb;
  v_pg text;
  v_assalto boolean := false;
  v_chi_att text; v_kind text := 'fisico';
  v_fatti jsonb;
begin
  select * into v from public.esame_prove where id = p_prova;
  if not found or v.stato <> 'aperta' then return null; end if;

  select * into c from public.esame_narrazione_cicli
   where prova_id = p_prova and stato = 'aperta';
  if not found then return null; end if;

  select * into v_prof from public.esame_png_profili where id = v.profilo_id;
  select * into v_c from public.characters where id = v.candidate_character;

  select left(btrim(m.body), 2500) into v_pg
    from public.messages m where m.id = c.pg_message_id;

  v_assalto := c.ruolo = 'png_difende'
    and v.pend_azione->'principale'->>'fonte' = 'moltiplicazione'
    and v.pend_azione->'principale'->>'modalita' = 'assalto';

  v_int := coalesce(v.opzioni_png->'intenzioni','[]'::jsonb);
  for v_e in select * from jsonb_array_elements(v_int) loop
    v_out := v_out || jsonb_build_array(jsonb_build_object(
      'id',        v_e->>'intenzione_id',
      'etichetta', v_e->>'etichetta',
      'genere',    v_e->>'genere',
      'movimento', case v_e->>'movimento' when 'avanti' then 'guadagna terreno'
                                          when 'indietro' then 'cede terreno' else null end,
      'esiti_possibili', case when v_assalto
        then '["copia_colpita","originale_individuato"]'::jsonb
        else to_jsonb(coalesce(
          (select array_agg(x) from jsonb_array_elements_text(v_e->'esiti_possibili') x),
          array[]::text[]))
      end));
  end loop;

  -- I fatti già decisi per questo ciclo, prima della risoluzione: chi attacca
  -- nella metà in corso e dove il colpo è destinato (il dado della prova).
  if c.ruolo in ('png_difende','png_attacca') then
    v_chi_att := case when v.meta = 'png' then 'png' else 'candidato' end;
    if c.ruolo = 'png_difende' then
      v_kind := case when v.pend_azione->'principale'->>'fonte' = 'jutsu'
                     then coalesce((select lower(j.category) from public.jutsu j
                                     where j.id = (v.pend_azione->'principale'->>'id')::uuid), 'fisico')
                     else 'fisico' end;
    end if;
    v_fatti := jsonb_build_object(
      'attacca', case when v_chi_att = 'png' then v_prof.nome else coalesce(v_c.name,'il candidato') end,
      'difende', case when v_chi_att = 'png' then coalesce(v_c.name,'il candidato') else v_prof.nome end,
      'bersaglio_previsto', case when c.ruolo = 'png_difende'
          then coalesce(public._esame_zona_dichiarata(v_pg, v.seme, public._esame_indice(v.scambio, v.meta, v_chi_att, 'att')), public._esame_zona(v.seme, v.scambio, v.meta, v_chi_att, v_kind))
          else public._esame_zona(v.seme, v.scambio, 'png', 'png', 'fisico') end,
      'nota_bersaglio', case when c.ruolo = 'png_difende'
          then 'se il colpo del candidato arriva, arriva qui: le branche «colpito» e «sfiorato» lo raccontano su questa zona; la gravità non è ancora nota e non va quantificata'
          else 'se l''attacco dello sfidante arriva, arriva qui: la frase che apre l''attacco dice che mira a questa zona; l''esito lo decide il campo e lo racconta il ciclo successivo' end,
      'ancora_sostituzione', case when c.ruolo = 'png_difende'
          and public._esame_spatial_snapshot_v1(p_prova) is null
          then public._esame_ancora_scegli(p_prova, v.pos_png) else null end);
  else
    v_fatti := '{}'::jsonb;
  end if;

  return public._esame_payload_v5_complete_v1(p_prova,jsonb_build_object(
    'versione',        5,
    'ricevuta_id',     c.opzioni_id,
    'ruolo',           c.ruolo,
    'contesto_pg',     coalesce(v_pg,''),
    'esito_precedente', case when c.ruolo in ('png_esito','png_finale')
      then public._esame_referto_modello(c.referto-'_spatial_audit')
      else (select public._esame_referto_modello(p.referto-'_spatial_audit')
              from public.esame_narrazione_cicli p
             where p.prova_id = p_prova
               and p.ruolo = 'png_difende'
               and p.stato = 'risolta'
               and p.result_message_id is null
               and coalesce((p.referto->>'legacy')::boolean, false) = false
             order by p.resolved_at desc nulls last, p.created_at desc, p.id desc
             limit 1)
      end,
    'fatti_del_ciclo', v_fatti,
    'stile_precedente', public._esame_storia_narrativa(p_prova),
    'scena',           public._esame_png_scena(p_prova),
    'dossier',         public._esame_dossier_sfidante(p_prova),
    'sensei',          case when c.ruolo = 'png_finale' then public._esame_sensei_finale(p_prova) else null end,
    'intenzioni',      v_out));
end
$function$;


-- SOURCE candidato/full_body/_esame_diversivo.sql
CREATE OR REPLACE FUNCTION public._esame_diversivo(p_prova uuid, p_chi text, p_direzione text, p_jutsu uuid DEFAULT NULL::uuid, p_da text DEFAULT 'candidato'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_c public.characters%rowtype;
  v_png boolean; v_dir text; v_loc uuid;
  v_id uuid; v_nome text; v_costo int;
  v_passo int; v_dist numeric; v_pos_prima int; v_pos_dopo int; v_altro int;
  v_spatial jsonb; v_preview jsonb; v_budget numeric;
  v_ck int; v_scorso int; v_frase text; v_attore text;
begin
  select * into v from public.esame_prove where id = p_prova for update;
  if not found then raise exception 'La prova non esiste più'; end if;
  if v.stato <> 'aperta' then
    return jsonb_build_object('versione',1,'ok',false,'motivo','prova non aperta');
  end if;

  v_png := (lower(coalesce(p_chi,'')) = 'png');
  if v_png <> (v.meta = 'png') or v.fase <> 'attacco' then
    return jsonb_build_object('versione',1,'ok',false,'motivo','non è il tuo turno');
  end if;

  select * into v_prof from public.esame_png_profili where id = v.profilo_id;
  select * into v_c    from public.characters       where id = v.candidate_character;
  select location_id into v_loc from public.academy_class_sessions where id = v.class_session_id;

  -- ── 1 · È davvero un diversivo? La bandiera, mai un uuid cablato ─────────
  -- `p_jutsu` nullo significa «il diversivo del repertorio»: c'è una riga sola
  -- accesa, e il giorno in cui ce ne fossero due il chiamante deve dire quale.
  select j.id, j.name_it, coalesce(j.chakra_cost,0)
    into v_id, v_nome, v_costo
    from public.jutsu j
   where j.is_active and coalesce(j.diversivo,false)
     and (p_jutsu is null or j.id = p_jutsu)
   order by j.name_it
   limit 1;
  if v_id is null then
    return jsonb_build_object('versione',1,'ok',false,'motivo','non è un diversivo');
  end if;

  -- ── 2 · la legalità, ricalcolata QUI e non ereditata dall'elenco ─────────
  -- L'elenco è calcolato prima, e fra il calcolo e questa riga la prova può
  -- essere avanzata. Chi esegue ricontrolla; chi offre non basta.
  if v.usato_principale then
    return jsonb_build_object('versione',1,'ok',false,'motivo','azione principale già spesa');
  end if;
  v_ck := case when v_png then v.ck_png else v.ck_cand end;
  if v_costo > v_ck then
    return jsonb_build_object('versione',1,'ok',false,'motivo','chakra insufficiente');
  end if;
  -- la non cumulabilità: uno per scambio, per lato. Gemella di `sost_round_*`.
  v_scorso := case when v_png then v.diversivo_scambio_png else v.diversivo_scambio_cand end;
  if v_scorso is not null and v_scorso >= v.scambio then
    return jsonb_build_object('versione',1,'ok',false,
             'motivo','le copie sono già in campo: una per scambio');
  end if;

  -- ── 3 · i metri, decisi dal server ──────────────────────────────────────
  -- ⚠️ [ADDENDUM] NESSUN RIPIEGO SU UNA DIREZIONE DIVERSA. La 016 normalizzava
  -- una parola sconosciuta a `diversivo`; qui si rifiuta. Ripiegare vorrebbe
  -- dire giocare una mossa che nessuno ha scelto, e con le due direzioni
  -- immobili tolte quel ripiego sarebbe per giunta un'azione a effetto zero.
  v_dir := lower(btrim(coalesce(p_direzione,'')));
  if v_dir not in ('avvicinamento','ritirata') then
    return jsonb_build_object('versione',1,'ok',false,
             'motivo','direzione non riconosciuta: si copre un avvicinamento o una ritirata');
  end if;

  v_passo     := ((case when v_png then v_prof.velocita else v_c.velocita end) / 10) * 5;
  v_spatial:=public._esame_spatial_snapshot_v1(p_prova);
  if v_spatial is not null then
    v_dist:=(v_spatial->>'distance_m')::numeric;
    v_budget:=case when v_dir='avvicinamento' then 5 else greatest(0,least(5,2+v_passo-v_dist)) end;
    v_preview:=public._esame_spatial_move_preview_v1(p_prova,p_chi,v_budget,v_dir='avvicinamento');
    if not (v_preview->>'available')::boolean then
      return jsonb_build_object('versione',1,'ok',false,'motivo','da qui quella direzione non cambierebbe la posizione');
    end if;
    perform public._esame_spatial_move_commit_v1(p_prova,p_chi,v_budget,v_dir='avvicinamento',
      md5('exam-diversivo|'||p_prova::text||'|'||v.scambio::text||'|'||v.meta)::uuid);
  else
  v_dist      := abs(v.pos_png - v.pos_candidato);
  v_pos_prima := case when v_png then v.pos_png else v.pos_candidato end;
  v_altro     := case when v_png then v.pos_candidato else v.pos_png end;
  v_pos_dopo  := public._esame_bordo(public._diversivo_posizione(v_pos_prima, v_altro, v_dir, v_passo, 2, 5));

  -- ── [ADDENDUM decisione 5] lo ZERO si rifiuta PRIMA di consumare ─────────
  -- Qui non è stato ancora speso niente: né chakra, né azione principale, né i
  -- contatori. È l'ordine che conta, non la presenza del controllo — la R2 ha
  -- pagato caro l'inversione opposta sullo scontrino.
  -- ⚠️ E questo ramo NON è irraggiungibile solo perché l'elenco lo esclude: ci
  -- si arriva con una risposta vecchia del Narratore, o con una chiamata
  -- costruita a mano. Chi esegue non si fida di chi offre.
  if v_pos_dopo = v_pos_prima then
    return jsonb_build_object('versione',1,'ok',false,
             'motivo','da qui quella direzione non cambierebbe la posizione');
  end if;
  end if;

  -- Il verso: chi si muove resta DALLA SUA PARTE. Scritto come differenza dalla
  -- posizione dell'altro, e non come somma sulla propria, così non c'è nessun
  -- modo di scavalcare — nemmeno con un riposizionamento più lungo della
  -- distanza. È la riga che nel corpo vecchio mancava.
  if v_png then
    update public.esame_prove
       set pos_png                = case when v_spatial is null then v_pos_dopo else pos_png end,
           ck_png                 = greatest(0, ck_png - v_costo),
           -- [034] il costo appartiene alla metà appena chiusa; il flag
           -- descrive invece la metà nuova, consegnata al candidato.
           usato_principale       = false,
           diversivo_scambio_png  = v.scambio,
           copie_attive_png       = true,
           copie_n_png            = 1,
           copie_scambio_png      = v.scambio,
           -- Il candidato sta ricevendo il proprio turno d'attacco: eventuali
           -- copie vecchie del candidato scadono senza essere usate.
           copie_attive_cand      = false,
           copie_n_cand           = 0,
           copie_scambio_cand     = null,
           manovre_png            = manovre_png + 1,      -- eredita la terminazione della R2
           -- ⚠️ `usato_spostamento` NON compare in questo update, ed è
           --    l'identità della tecnica. Vedi §D5 del banco.
           meta                   = 'candidato',
           fase                   = 'attacco',
           usato_rapida           = false,
           usato_spostamento      = false,
           pend_azione            = null,
           opzioni_png = null, opzioni_id = null, opzioni_at = null
     where id = p_prova;
    v_attore := v_prof.nome;
  else
    update public.esame_prove
       set pos_candidato           = case when v_spatial is null then v_pos_dopo else pos_candidato end,
           ck_cand                 = greatest(0, ck_cand - v_costo),
           -- [034] il PNG riceve una metà nuova e deve poter scegliere
           -- una principale; il marker per-scambio impedisce il replay.
           usato_principale        = false,
           diversivo_scambio_cand  = v.scambio,
           copie_attive_cand       = true,
           copie_n_cand            = 1,
           copie_scambio_cand      = v.scambio,
           diversivi_cand          = diversivi_cand + 1,
           -- Il PNG sta ricevendo il proprio turno d'attacco.
           copie_attive_png        = false,
           copie_n_png             = 0,
           copie_scambio_png       = null,
           -- il contatore della CONDOTTA (l'osservazione «non ha mai cambiato
           -- distanza»), che non è la spesa del turno: le due cose hanno nomi
           -- simili e significati opposti.
           -- il riposizionamento È un cambio di distanza, e il contatore
           -- della condotta lo registra. Qui non serve più il `case`: sopra si
           -- è già rifiutato tutto ciò che non muove.
           spostamenti_cand        = spostamenti_cand + 1,
           meta                    = 'png',
           fase                    = 'attacco',
           usato_rapida            = false,
           usato_spostamento       = false,
           pend_azione             = null
     where id = p_prova;
    v_attore := v_c.name;
  end if;

  -- ── 4 · la scena. Se il modello ha già parlato, il server tace ───────────
  -- Stessa regola di `_esame_risolvi`: la frase di riserva esce solo quando la
  -- battuta non l'ha scritta l'IA.
  if coalesce(p_da,'candidato') <> 'ia' then
    v_frase := public._esame_frase(p_prova, 'diversivo.' || v_dir,
                 coalesce(v.scambio,1),
                 jsonb_build_object('attore', v_attore,
                                    'tecnica', v_nome,
                                    'avversario', case when v_png then v_c.name else v_prof.nome end));
    if v_png and v_frase is not null then
      -- [BANCO 038] la voce unica vale anche qui: il diversivo del PNG esce
      -- dal Narratore, non dal nome del profilo. Prima chiamava `_esame_post`,
      -- che questa stessa migrazione ha trasformato in lapide — la riga
      -- sollevava `0A000` e fermava il ciclo.
      perform public._esame_narratore_post(v_loc, v_frase);
    end if;
  end if;

  -- ── 5 · il turno è passato: se tocca al PNG, il suo elenco va scritto QUI ─
  -- Senza, `opzioni_png` resta nullo, il ripiego non trova niente da scegliere e
  -- la prova si ferma in silenzio. È la stessa riga, e la stessa ragione, della
  -- coda di `_esame_risolvi`.
  if not v_png then
    perform public._esame_png_turno(p_prova);
  end if;

  return jsonb_build_object(
    'versione',1,'ok',true,'genere','diversivo',
    'direzione', v_dir, 'tecnica', v_nome,
    'posizione_prima', v_pos_prima, 'posizione', v_pos_dopo,
    'distanza_prima', v_dist, 'distanza', abs(v_pos_dopo - v_altro),
    'chakra_speso', v_costo,
    'attende', case when v_png then 'azione del candidato' else 'azione del PNG' end);
end
$function$;


-- SOURCE candidato/full_body/_esame_moltiplicazione_candidato__4args.sql
CREATE OR REPLACE FUNCTION public._esame_moltiplicazione_candidato(p_prova uuid, p_modalita text, p_copie integer, p_direzione text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype; v_c public.characters%rowtype;
  v_j uuid; v_nome text; v_base int; v_cap int; v_costo int;
  v_mode text; v_dir text; v_maxm int; v_pos0 int; v_pos1 int; v_loc uuid;
  v_spatial jsonb; v_budget numeric;
begin
  select * into v from public.esame_prove where id=p_prova for update;
  if not found or v.stato<>'aperta' then raise exception 'La prova non è aperta'; end if;
  if v.meta<>'candidato' or v.fase<>'attacco' then raise exception 'non è il tuo turno'; end if;
  if v.usato_principale then raise exception 'azione principale già spesa'; end if;
  select * into v_c from public.characters where id=v.candidate_character;
  select j.id,j.name_it,coalesce(j.chakra_cost,0) into v_j,v_nome,v_base
    from public.jutsu j
   where j.is_active and coalesce(j.diversivo,false)
     and exists(select 1 from public.character_jutsu cj where cj.jutsu_id=j.id and cj.user_id=v.candidate_user)
   order by j.name_it limit 1;
  if v_j is null then raise exception 'Moltiplicazione non posseduta'; end if;

  v_mode:=lower(btrim(coalesce(p_modalita,'')));
  if v_mode not in ('diversivo','copertura','assalto') then raise exception 'modalità non valida'; end if;
  v_cap:=least(public._copie_cap(coalesce(v_c.ninjutsu,0),coalesce(v_c.rank,'Deshi')),4);
  if p_copie is null or p_copie<1 or p_copie>v_cap then raise exception 'numero di copie non consentito'; end if;
  v_costo:=v_base+(5*p_copie);
  if v.ck_cand<v_costo then raise exception 'Chakra insufficiente: servono % (ne hai %)',v_costo,v.ck_cand; end if;
  v_spatial:=public._esame_spatial_snapshot_v1(p_prova);

  if v_mode='diversivo' then
    v_dir:=lower(btrim(coalesce(p_direzione,'')));
    if v_dir not in ('avvicinamento','ritirata') then raise exception 'scegli avvicinamento o ritirata'; end if;
    v_maxm:=(coalesce(v_c.velocita,0)/10)*5;
    v_pos0:=v.pos_candidato;
    if v_spatial is not null then
      v_budget:=case when v_dir='avvicinamento' then 5
        else greatest(0,least(5,2+v_maxm-(v_spatial->>'distance_m')::numeric)) end;
      perform public._esame_spatial_move_commit_v1(p_prova,'candidato',v_budget,v_dir='avvicinamento',
        md5('exam-moltiplicazione4|'||p_prova::text||'|'||v.scambio::text||'|'||v.meta)::uuid);
    else
    v_pos1:=public._esame_bordo(public._diversivo_posizione(v.pos_candidato,v.pos_png,v_dir,v_maxm,2,5));
    if v_pos1=v_pos0 then raise exception 'da qui quella direzione non cambierebbe la posizione'; end if;
    end if;
    update public.esame_prove set
      pos_candidato=case when v_spatial is null then v_pos1 else pos_candidato end, ck_cand=ck_cand-v_costo,
      copie_attive_cand=true, copie_n_cand=p_copie, copie_scambio_cand=scambio,
      diversivo_scambio_cand=scambio, diversivi_cand=diversivi_cand+1,
      spostamenti_cand=spostamenti_cand+1,
      meta='png',fase='attacco',usato_principale=false,usato_rapida=false,usato_spostamento=false,
      pend_azione=null,opzioni_png=null,opzioni_id=null,opzioni_at=null
    where id=p_prova;
  elsif v_mode='copertura' then
    update public.esame_prove set
      ck_cand=ck_cand-v_costo,
      copie_attive_cand=true, copie_n_cand=p_copie, copie_scambio_cand=scambio,
      diversivo_scambio_cand=scambio,
      meta='png',fase='attacco',usato_principale=false,usato_rapida=false,usato_spostamento=false,
      pend_azione=null,opzioni_png=null,opzioni_id=null,opzioni_at=null
    where id=p_prova;
  else
    update public.esame_prove set
      ck_cand=ck_cand-v_costo,
      copie_attive_cand=false, copie_n_cand=0, copie_scambio_cand=null,
      fase='difesa',usato_principale=true,
      pend_azione=jsonb_build_object(
        'tipo','attacco','principale',jsonb_build_object(
          'fonte','moltiplicazione','id',v_j,'modalita','assalto','copie',p_copie),
        'opzione_id','moltiplicazione:assalto','scelta_da','candidato',
        'spatial_before_version',v_spatial->'map_version',
        'pos_cand_prima',case when v_spatial is null then v.pos_candidato end,
        'pos_png_prima',case when v_spatial is null then v.pos_png end)
    where id=p_prova;
  end if;

  perform public._esame_png_turno(p_prova);
  return public._esame_stato_json(p_prova) || jsonb_build_object(
    'moltiplicazione',jsonb_build_object('modalita',v_mode,'copie',p_copie,'chakra_speso',v_costo,
      'direzione',case when v_mode='diversivo' then v_dir else null end));
end $function$;


-- SOURCE candidato/full_body/_esame_moltiplicazione_candidato__5args.sql
CREATE OR REPLACE FUNCTION public._esame_moltiplicazione_candidato(p_prova uuid, p_modalita text, p_copie integer, p_direzione text, p_originale_idx integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype; v_c public.characters%rowtype;
  v_j uuid; v_nome text; v_base int; v_cap int; v_costo int;
  v_mode text; v_maxm int; v_pos0 int; v_pos1 int; v_move int := 0;
  v_orig int;
  v_spatial jsonb; v_preview jsonb; v_receipt jsonb; v_moved boolean;
begin
  select * into v from public.esame_prove where id=p_prova for update;
  if not found or v.stato<>'aperta' then raise exception 'La prova non è aperta'; end if;
  if v.meta<>'candidato' or v.fase<>'attacco' then raise exception 'non è il tuo turno'; end if;
  if v.usato_principale then raise exception 'azione principale già spesa'; end if;
  if v.usato_spostamento then raise exception 'Moltiplicazione sostituisce lo spostamento ordinario: non può sommarsi'; end if;
  select * into v_c from public.characters where id=v.candidate_character;
  select j.id,j.name_it,coalesce(j.chakra_cost,0) into v_j,v_nome,v_base
    from public.jutsu j
   where j.is_active and coalesce(j.diversivo,false)
     and exists(select 1 from public.character_jutsu cj where cj.jutsu_id=j.id and cj.user_id=v.candidate_user)
   order by j.name_it limit 1;
  if v_j is null then raise exception 'Moltiplicazione non posseduta'; end if;
  if v_base<>10 then raise exception 'catalogo incoerente: Moltiplicazione deve avere costo base 10'; end if;
  v_mode:=lower(btrim(coalesce(p_modalita,'')));
  if v_mode not in ('diversivo','copertura','assalto') then raise exception 'modalità non valida'; end if;
  v_cap:=least(public._copie_cap(coalesce(v_c.ninjutsu,0),coalesce(v_c.rank,'Deshi')),4);
  if p_copie is null or p_copie<1 or p_copie>v_cap then raise exception 'numero di copie non consentito'; end if;
  v_costo:=v_base+(5*p_copie);
  if v.ck_cand<v_costo then raise exception 'Chakra insufficiente: servono % (ne hai %)',v_costo,v.ck_cand; end if;
  v_maxm:=(coalesce(v_c.velocita,0)/10)*5;
  v_pos0:=v.pos_candidato; v_pos1:=v_pos0;
  v_spatial:=public._esame_spatial_snapshot_v1(p_prova);

  if v_spatial is not null then
    if v_mode='assalto' and nullif(btrim(coalesce(p_direzione,'')),'') is null then
      select n into v_move from generate_series(0,v_maxm,5) n
       where (public._esame_spatial_move_preview_v1(p_prova,'candidato',n,true)->>'distance_after_m')::numeric<=2
       order by n limit 1;
      if v_move is null then raise exception 'Assalto non puo concludersi a contatto da questa distanza'; end if;
    else
      if coalesce(p_direzione,'') !~ '^-?[0-9]+$' then raise exception 'spostamento di Moltiplicazione non valido'; end if;
      v_move:=p_direzione::int;
    end if;
    if abs(v_move)>v_maxm or mod(abs(v_move),5)<>0 or (v_mode='assalto' and v_move<0) then
      raise exception 'spostamento di Moltiplicazione fuori budget o direzione';
    end if;
    v_preview:=public._esame_spatial_move_preview_v1(p_prova,'candidato',abs(v_move),v_move>=0);
    if v_move<>0 and not (v_preview->>'available')::boolean then
      raise exception 'da qui quello spostamento non cambierebbe la posizione';
    end if;
    if v_mode='assalto' then
      if (v_preview->>'distance_after_m')::numeric>2 then raise exception 'Assalto deve concludersi a contatto con il bersaglio'; end if;
      v_orig:=p_originale_idx;
      if v_orig is null or v_orig<1 or v_orig>p_copie+1 then raise exception 'originale non consentito'; end if;
    elsif p_originale_idx is not null then raise exception 'la scelta dell''originale appartiene soltanto all''Assalto'; end if;
    if v_move<>0 then
      v_receipt:=public._esame_spatial_move_commit_v1(p_prova,'candidato',abs(v_move),v_move>0,
        md5('exam-moltiplicazione|'||p_prova::text||'|'||v.scambio::text||'|'||v.meta)::uuid);
    end if;
    v_moved:=v_move<>0;
  else

  if v_mode='assalto' then
    if coalesce(p_direzione,'0') ~ '^-' then
      raise exception 'Assalto consente soltanto un avanzamento verso il bersaglio';
    end if;
    if coalesce(p_direzione,'0') !~ '^[0-9]+$' then
      raise exception 'avanzamento di Assalto non valido';
    end if;
    -- [121] compatibilita LAND: ricava l'unico avanzamento che
    -- conclude a contatto soltanto quando il client non lo ha trasmesso.
    -- Le LAND aggiornate continuano a inviarlo esplicitamente.
    if nullif(btrim(coalesce(p_direzione,'')),'') is null then
      v_pos1:=public._esame_bordo(public._esame_muove(v.pos_candidato,v.pos_png,v_maxm,true));
      if abs(v.pos_png-v_pos1)>2 or mod(abs(v_pos1-v_pos0),5)<>0 then
        raise exception 'Assalto non puo concludersi a contatto da questa distanza';
      end if;
      v_move:=abs(v_pos1-v_pos0);
      v_pos1:=v_pos0;
    else
      v_move:=p_direzione::int;
    end if;
    if v_move>v_maxm or mod(v_move,5)<>0 then
      raise exception 'con Velocità % Assalto consente al massimo % metri in avanzamento, a passi di 5',v_c.velocita,v_maxm;
    end if;
    if v_move>0 then
      v_pos1:=public._esame_bordo(public._esame_muove(v.pos_candidato,v.pos_png,v_move,true));
      if v_pos1=v_pos0 then raise exception 'da qui l''avanzamento non cambierebbe la posizione'; end if;
    end if;
    if abs(v.pos_png-v_pos1)>2 then
      raise exception 'Assalto deve concludersi a contatto con il bersaglio';
    end if;
    v_orig:=p_originale_idx;
    if v_orig is null or v_orig<1 or v_orig>p_copie+1 then
      raise exception 'originale non consentito: scegli un numero fra 1 e %',p_copie+1;
    end if;
  else
    if coalesce(p_direzione,'') !~ '^-?[0-9]+$' then raise exception 'spostamento di Moltiplicazione non valido'; end if;
    v_move:=p_direzione::int;
    if abs(v_move)>v_maxm or mod(abs(v_move),5)<>0 then
      raise exception 'con Velocità % Moltiplicazione consente al massimo % metri, a passi di 5',v_c.velocita,v_maxm;
    end if;
    if v_move<>0 then
      v_pos1:=public._esame_bordo(public._esame_muove(v.pos_candidato,v.pos_png,abs(v_move),v_move>0));
      if v_pos1=v_pos0 then raise exception 'da qui quello spostamento non cambierebbe la posizione'; end if;
    end if;
    if p_originale_idx is not null then raise exception 'la scelta dell''originale appartiene soltanto all''Assalto'; end if;
  end if;

  v_moved:=v_pos1<>v_pos0;
  end if;

  if v_mode in ('diversivo','copertura') then
    update public.esame_prove set
      pos_candidato=case when v_spatial is null then v_pos1 else pos_candidato end,ck_cand=ck_cand-v_costo,
      copie_attive_cand=true,copie_n_cand=p_copie,copie_scambio_cand=scambio,
      diversivo_scambio_cand=scambio,
      diversivi_cand=diversivi_cand+case when v_mode='diversivo' then 1 else 0 end,
      spostamenti_cand=spostamenti_cand+case when v_moved then 1 else 0 end,
      meta='png',fase='attacco',usato_principale=false,usato_rapida=false,usato_spostamento=false,
      pend_azione=null,opzioni_png=null,opzioni_id=null,opzioni_at=null
    where id=p_prova;
  else
    update public.esame_prove set
      pos_candidato=case when v_spatial is null then v_pos1 else pos_candidato end,
      ck_cand=ck_cand-v_costo,
      copie_attive_cand=true,copie_n_cand=p_copie,copie_scambio_cand=scambio,
      spostamenti_cand=spostamenti_cand+case when v_moved then 1 else 0 end,
      fase='difesa',usato_principale=true,usato_spostamento=v_moved,
      pend_azione=jsonb_build_object(
        'tipo','attacco','principale',jsonb_build_object(
          'fonte','moltiplicazione','id',v_j,'modalita','assalto','copie',p_copie,'originale_idx',v_orig),
        'opzione_id','moltiplicazione:assalto','scelta_da','candidato',
        'spatial_before_version',v_spatial->'map_version',
        'pos_cand_prima',case when v_spatial is null then v.pos_candidato end,
        'pos_png_prima',case when v_spatial is null then v.pos_png end)
    where id=p_prova;
  end if;
  perform public._esame_png_turno(p_prova);
  return public._esame_stato_json(p_prova)||jsonb_build_object(
    'moltiplicazione',jsonb_build_object('modalita',v_mode,'copie',p_copie,
      'chakra_speso',v_costo,'spostamento_m',v_move,
      'originale_idx',case when v_mode='assalto' then v_orig else null end));
end $function$;


-- SOURCE candidato/full_body/_esame_png_gioca.sql
CREATE OR REPLACE FUNCTION public._esame_png_gioca(p_prova uuid, p_opzione text, p_da text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_int jsonb; v_sc jsonb;
  v_metri numeric; v_pos int; v_id uuid;
  v_spatial jsonb;
begin
  select * into v from public.esame_prove where id = p_prova for update;
  if not found or v.stato <> 'aperta' then
    return jsonb_build_object('versione',1,'ok',false,'motivo','prova non aperta');
  end if;
  if p_opzione is null or btrim(p_opzione) = '' then
    return jsonb_build_object('versione',1,'ok',false,'motivo','nessuna mossa da giocare');
  end if;

  -- L'elenco si RIDERIVA dallo stato vivo: non si esegue quello memorizzato.
  v_spatial:=public._esame_spatial_snapshot_v1(p_prova);
  -- Fra la scrittura dell'elenco e questa riga la prova non può essere
  -- avanzata (lo scontrino lo impedisce), ma se un giorno lo fosse, si
  -- eseguirebbe comunque ciò che è legale ADESSO.
  v_int := public._esame_png_intenzioni(p_prova)->'intenzioni';
  v_sc  := public._esame_png_traduci(v_int, p_opzione);
  if v_sc is null then
    return jsonb_build_object('versione',1,'ok',false,
                              'motivo','intenzione non disponibile');
  end if;
  if v_spatial is not null and v_sc->>'reazione'='sostituzione'
     and p_opzione is distinct from v_sc->>'intenzione_id'
     and p_opzione is distinct from v_sc->>'chiave' then
    return jsonb_build_object('versione',1,'ok',false,'motivo','seleziona l''intenzione esatta della Sostituzione');
  end if;
  if v_sc->>'rapida' is not null then
    return jsonb_build_object('versione',1,'ok',false,
                              'motivo','le azioni rapide sono state ritirate');
  end if;

  -- ── lo scontrino si consuma QUI, prima di qualunque effetto ──────────────
  update public.esame_prove
     set opzioni_png = null, opzioni_id = null, opzioni_at = null
   where id = p_prova;

  -- ── metà difensiva: la reazione risolve subito ───────────────────────────
  if v_sc->>'genere' = 'reazione' then
    return public._esame_risolvi(p_prova,
      jsonb_build_object('tipo','difesa',
                         'reazione',      v_sc->>'reazione',
                         'option_id',     v_sc->>'option_id',
                         'opzione_id',    v_sc->>'reazione',
                         'intenzione_id', v_sc->>'intenzione_id',
                         'scelta_da',     p_da),
      'png');
  end if;

  -- ── [017-R1] il diversivo: delega, e la delega è il punto ────────────────
  -- Non riscrivo qui il riposizionamento: `_esame_diversivo` è l'unico posto in
  -- cui il diversivo diventa stato, per i due lati del tavolo. Due copie della
  -- stessa regola divergono; una sola no — ed è la stessa ragione per cui il
  -- verso del movimento si calcola in un punto solo.
  --
  -- ⚠️ Sta PRIMA del movimento ordinario, e non è un dettaglio: un'intenzione
  -- di genere `diversivo` non porta mai un movimento (lo garantisce
  -- `_esame_png_intenzioni`), ma se un giorno lo portasse, eseguire il
  -- movimento e POI delegare vorrebbe dire che `_esame_diversivo` calcola il
  -- tetto anti-stallo su una distanza diversa da quella che ha visto chi ha
  -- offerto. Il rifiuto è meglio della doppia contabilità.
  if v_sc->>'genere' = 'diversivo' then
    return public._esame_diversivo(p_prova, 'png', v_sc->>'direzione', null, p_da);
  end if;

  -- ── il movimento, se il turno ne prevede uno ─────────────────────────────
  -- [ADDENDUM] la posizione la calcola `_esame_muove`: si ferma sul bersaglio,
  -- non scavalca, e rispetta il campo. Qui NON si somma più un verso ai metri —
  -- era la forma esatta del difetto, scritta sull'altro lato del tavolo.
  if v_sc->>'movimento' is not null then
    v_metri := greatest(0, coalesce((v_sc->>'metri')::numeric, 0));
    if v_spatial is not null then
      perform public._esame_spatial_move_commit_v1(p_prova,'png',v_metri,v_sc->>'movimento'='avanti',
        md5('exam-png-move|'||p_prova::text||'|'||v.scambio::text||'|'||v.meta)::uuid);
    else
    v_pos   := public._esame_bordo(public._esame_muove(v.pos_png, v.pos_candidato, v_metri::int,
                                   v_sc->>'movimento' = 'avanti'));
    -- [ADDENDUM decisione 5] una richiesta vecchia o manipolata che non
    -- cambierebbe niente si rifiuta PRIMA di consumare: lo scontrino è già
    -- stato consumato sopra, ma movimento, azione, chakra e contatori no — e
    -- non devono esserlo. Il turno resta al PNG e il ripiego lo rigioca.
    if v_pos = v.pos_png then
      return jsonb_build_object('versione',1,'ok',false,
               'motivo','quel movimento non cambierebbe la posizione');
    end if;
    end if;
    update public.esame_prove
       set pos_png = case when v_spatial is null then v_pos else pos_png end, usato_spostamento = true
     where id = p_prova;
  end if;

  -- ── la manovra: CHIUDE la metà e passa il turno al candidato ─────────────
  -- Non riapre l'elenco, non scrive uno scambio, non consuma un gradino. È
  -- l'unica forma di turno che non dichiara una principale (decisione PM 3), e
  -- `manovre_png` la conta: a due manovre consecutive il server smette di
  -- offrire l'arretramento, e da lì la distanza può solo calare.
  if v_sc->>'genere' = 'manovra' then
    update public.esame_prove
       set manovre_png       = manovre_png + 1,
           meta              = 'candidato',
           fase              = 'attacco',
           usato_principale  = false,
           usato_rapida      = false,
           usato_spostamento = false,
           -- Il candidato riceve il proprio turno: copie non usate scadono.
           copie_attive_cand = false,
           copie_scambio_cand = null
     where id = p_prova;
    return jsonb_build_object('versione',1,'ok',true,'genere','manovra',
             'intenzione', v_sc->>'intenzione_id',
             'chiave',     v_sc->>'chiave',
             'attende','azione del candidato');
  end if;

  -- ── la principale: resta in attesa della reazione del candidato ──────────
  if (v_sc->>'principale') like 'jutsu:%' then
    v_id := substring(v_sc->>'principale' from 7)::uuid;
  end if;

  update public.esame_prove
     set usato_principale = true,
         fase             = 'difesa',
         manovre_png      = 0,
         pend_azione = jsonb_build_object(
           'tipo','attacco',
           'spatial_before_version',v_spatial->'map_version',
           'principale', jsonb_build_object(
              'fonte', case when v_id is null then 'colpo' else 'jutsu' end,
              'id',    v_id),
           'opzione_id',    v_sc->>'principale',
           'intenzione_id', v_sc->>'intenzione_id',
           'chiave',        v_sc->>'chiave',
           'scelta_da',     p_da)
   where id = p_prova;

  return jsonb_build_object('versione',1,'ok',true,'genere','turno',
           'intenzione', v_sc->>'intenzione_id',
           'chiave',     v_sc->>'chiave',
           'mossa',      v_sc->>'principale',
           'attende','reazione del candidato');
end
$function$;


-- SOURCE candidato/full_body/_esame_png_intenzioni.sql
CREATE OR REPLACE FUNCTION public._esame_png_intenzioni(p_prova uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_op jsonb; v_e jsonb;
  v_maxm int; v_sposta_ok boolean;
  v_verso int; v_pos int; v_d numeric; v_d0 numeric; v_metri int;
  v_spatial jsonb; v_preview jsonb;
  v_mov text; v_movimenti text[];
  v_int jsonb := '[]'::jsonb; v_out jsonb;
  v_et text; v_princ text; v_nome text; v_ck int;
  v_tolte int := 0; v_turni_ok boolean;
  v_dir text;   -- [017-R1] la direzione del diversivo
  c_tetto constant int := 16;
begin
  select * into v from public.esame_prove where id = p_prova;
  if not found then raise exception 'La prova non esiste più'; end if;

  v_op := public._esame_prova_opzioni(p_prova, 'png');
  v_spatial:=public._esame_spatial_snapshot_v1(p_prova);

  -- ── la metà difensiva: una reazione È già un turno completo ──────────────
  if not (v.fase = 'attacco' and v.meta = 'png') then
    for v_e in select * from jsonb_array_elements(v_op->'reazioni') loop
      if coalesce((v_e->>'disponibile')::boolean,false) then
        v_int := v_int || jsonb_build_array(jsonb_build_object(
          'chiave',     'reazione.' || (v_e->>'chiave') || case when v_e ? 'option_id' then '.'||(v_e->>'option_id') else '' end,
          'option_id',  v_e->>'option_id',
          'genere',     'reazione',
          'etichetta',  v_e->>'nome',
          'movimento',  null, 'metri', null,
          'rapida',     null, 'principale', null,
          'reazione',   v_e->>'chiave'));
      end if;
    end loop;
    return public._esame_png_numera('reazione', v_int, 0);
  end if;

  -- ── la metà d'attacco: movimento × principale ────────────────────────────
  v_maxm      := coalesce((v_op->'spostamento'->>'max_metri')::int, 0);
  v_sposta_ok := coalesce((v_op->'spostamento'->>'disponibile')::boolean,false) and v_maxm > 0;
  v_d0        := case when v_spatial is null then abs(v.pos_png-v.pos_candidato)
                     else (v_spatial->>'distance_m')::numeric end;
  -- Il verso si calcola con la STESSA riga di `_esame_png_gioca`. Due letture
  -- della stessa cosa divergono; una sola no.
  v_verso     := case when v.pos_candidato >= v.pos_png then 1 else -1 end;

  foreach v_mov in array array['fermo','avanti','indietro'] loop
    if v_mov <> 'fermo' and not v_sposta_ok then continue; end if;
    -- [ADDENDUM] i metri e la posizione li calcola `_esame_muove`, che è la
    -- stessa sede del movimento del candidato e dello scontro ordinario.
    -- ⚠️ `least(v_maxm, v_d0)` era già giusto per l'avvicinamento e resta vero
    -- come RISULTATO, ma non è più scritto qui: scriverlo in due posti è il
    -- modo in cui questa famiglia di difetti si riproduce.
    v_metri := case when v_mov = 'fermo' then 0 else v_maxm end;
    if v_spatial is not null then
      v_preview:=public._esame_spatial_move_preview_v1(p_prova,'png',v_metri,v_mov<>'indietro');
      if v_mov<>'fermo' and not (v_preview->>'available')::boolean then continue; end if;
      v_d:=(v_preview->>'distance_after_m')::numeric;
      -- Il comando trasporta il budget originale; non riusa la distanza
      -- quantizzata come nuovo budget, che potrebbe cambiare l'endpoint.
    else
    v_pos   := case v_mov
                 when 'avanti'   then public._esame_bordo(public._esame_muove(v.pos_png, v.pos_candidato, v_metri, true))
                 when 'indietro' then public._esame_bordo(public._esame_muove(v.pos_png, v.pos_candidato, v_metri, false))
                 else v.pos_png end;
    -- [ADDENDUM decisione 4] zero cambiamenti = nessuna offerta. Vale anche per
    -- il bordo del campo: a 60 metri di separazione «indietro» sparisce da solo.
    if v_mov <> 'fermo' and v_pos = v.pos_png then continue; end if;
    v_metri := abs(v_pos - v.pos_png);
    v_d := abs(v_pos - v.pos_candidato);
    end if;

    -- Il colpo a mani nude: gratis, a contatto, sempre nel repertorio.
    -- La chiave conserva il segmento `libero` per compatibilità con gli
    -- scontrini R2, ma non rappresenta più una rapida selezionabile.
    if v_d <= 2 and not v.usato_principale then
      v_princ := 'colpo'; v_nome := 'colpo a mani nude';
      v_et := btrim(concat_ws(', ',
                case v_mov when 'avanti' then 'passo avanti'
                           when 'indietro' then 'passo indietro' end,
                v_nome));
      v_int := v_int || jsonb_build_array(jsonb_build_object(
        'chiave',     v_mov || '.libero.' || v_princ,
        'genere',     'turno',
        'etichetta',  upper(left(v_et,1)) || substr(v_et,2),
        'movimento',  nullif(v_mov,'fermo'),
        'metri',      nullif(v_metri,0),
        'rapida',     null,
        'principale', v_princ,
        'reazione',   null));
    end if;

    -- I jutsu del repertorio realmente posseduto, sfrondati dal gradino.
    for v_e in select * from jsonb_array_elements(v_op->'principali') loop
      v_ck := coalesce((v_e->>'chakra')::int, 0);
      if v.beat >= 2
         and not v.usato_principale
         and v_d <= coalesce((v_e->>'portata_m')::int, 0)
         and (v_ck = 0 or v.ck_png >= v_ck)
      then
        v_princ := 'jutsu:' || (v_e->>'id');
        v_nome  := v_e->>'nome';
        v_et := btrim(concat_ws(', ',
                  case v_mov when 'avanti' then 'passo avanti'
                             when 'indietro' then 'passo indietro' end,
                  v_nome));
        v_int := v_int || jsonb_build_array(jsonb_build_object(
          'chiave',     v_mov || '.libero.' || v_princ,
          'genere',     'turno',
          'etichetta',  upper(left(v_et,1)) || substr(v_et,2),
          'movimento',  nullif(v_mov,'fermo'),
          'metri',      nullif(v_metri,0),
          'rapida',     null,
          'principale', v_princ,
          'reazione',   null));
      end if;
    end loop;
  end loop;

  -- ── il tetto, PRIMA delle manovre, e il taglio si DICHIARA ───────────────
  -- ⚠️ L'ORDINE DI QUESTE DUE SEZIONI È UNA CORREZIONE, NON UNO STILE.
  -- Le manovre si accodano in fondo, quindi un tetto applicato DOPO taglia
  -- sempre e soltanto loro. Misurato: basta una terza principale a contatto
  -- nel repertorio (un `INSERT` di catalogo, il gesto più ordinario del
  -- progetto) perché al secondo gradino a contatto si arrivi a 16 turni interi
  -- + 1 manovra = 17, e `manovra.indietro` sparisca — insieme alla decisione
  -- PM 3 e alla voce `allontanamento` che la Edge viva legge. Il tetto vale
  -- per i turni interi, che sono intercambiabili; le manovre non lo sono,
  -- perché sono l'unica forma in cui il PNG può cedere terreno.
  if jsonb_array_length(v_int) > c_tetto then
    v_tolte := jsonb_array_length(v_int) - c_tetto;
    select coalesce(jsonb_agg(s.e), '[]'::jsonb) into v_int
      from (select e from jsonb_array_elements(v_int) with ordinality t(e,n)
             order by n limit c_tetto) s;
  end if;

  -- ── [017-R1] IL DIVERSIVO: un terzo genere, accanto a turno e manovra ────
  -- Sta QUI — dopo il tetto, prima delle manovre — e la posizione è la stessa
  -- correzione del tetto: il diversivo non è intercambiabile con un turno
  -- intero, quindi non deve poter essere tagliato da un tetto pensato per cose
  -- che lo sono.
  --
  -- L'elenco delle direzioni lo fa `_esame_prova_opzioni`, che è anche il posto
  -- in cui muoiono le offerte morte: se la direzione non cambia davvero la
  -- posizione, non arriva fin qui. Vale il principio della R2 — la
  -- disponibilità NON si rilegge da un campo calcolato altrove, ma qui la
  -- distanza NON è simulata (il diversivo parte dallo stato di adesso, non da
  -- dopo un movimento), quindi `_esame_prova_opzioni` è la fonte giusta.
  --
  -- ⚠️ E il diversivo si offre SOLO con `movimento` nullo. Sarebbe tecnicamente
  -- possibile comporre «passo avanti + diversivo», e per un turno la mobilità
  -- arriverebbe a passo + 5. Non lo offro: il tetto anti-stallo è calcolato
  -- sulla distanza di ADESSO, e sommarlo a un movimento già fatto lo renderebbe
  -- una regola che protegge da uno stallo che non è più quello misurato.
  for v_e in select * from jsonb_array_elements(coalesce(v_op->'diversivi','[]'::jsonb)) loop
    v_dir := v_e->>'chiave';
    v_int := v_int || jsonb_build_array(jsonb_build_object(
      'chiave',     'diversivo.' || v_dir,
      'genere',     'diversivo',
      'etichetta',  case v_dir when 'avvicinamento' then 'Coprire un avvicinamento con le copie'
                               else 'Coprire una ritirata con le copie' end,
      'movimento',  null, 'metri', null,
      'rapida',     null, 'principale', null, 'reazione', null,
      'direzione',  v_dir));
  end loop;

  -- ── la manovra: cedere o guadagnare terreno, e CHIUDERE la metà ──────────
  -- Decisione PM 3, con la precisazione venuta da una MISURA: tutto il
  -- repertorio di un Deshi ha gittata «contatto» (portata 2) e il passo minimo
  -- è 5 metri, quindi un turno «indietro + principale» NON PUÒ ESISTERE. Se la
  -- manovra si offrisse solo quando non c'è altro, il Narratore non potrebbe
  -- MAI cedere terreno e la decisione PM 5 resterebbe lettera morta.
  --
  -- ⚠️ LA TERMINAZIONE, che è il punto delicato di questa scelta:
  --   · con un turno intero disponibile si offre SOLO l'arretramento, e solo
  --     finché le manovre consecutive sono meno di due → al massimo due mezze
  --     scene cedute di fila, poi si combatte;
  --   · senza nessun turno intero resta l'avvicinamento (e dalla terza SOLO
  --     quello) → la distanza cala in modo monotono finché una principale
  --     torna legale. È la prova B8.
  -- ⚠️ «turno intero» qui vuol dire ANCORA E SOLO `genere='turno'`: un
  -- diversivo NON è un turno intero, perché non dichiara una principale che
  -- colpisce. Se contasse come tale, la presenza di un diversivo toglierebbe
  -- l'arretramento dall'elenco e la decisione PM 3 della R2 tornerebbe lettera
  -- morta per la porta di servizio.
  v_turni_ok := exists (select 1 from jsonb_array_elements(v_int) e
                         where e->>'genere' = 'turno');
  if v_sposta_ok then
    v_movimenti := case
      when v_turni_ok and v.manovre_png <  2 then array['indietro']
      when v_turni_ok                        then array[]::text[]
      when v.manovre_png >= 2                then array['avanti']
      else array['avanti','indietro'] end;
    foreach v_mov in array v_movimenti loop
      -- [ADDENDUM] stessa sede, stessa regola, stesso rifiuto dello zero.
      if v_spatial is not null then
        v_preview:=public._esame_spatial_move_preview_v1(p_prova,'png',v_maxm,v_mov='avanti');
        if not (v_preview->>'available')::boolean then continue; end if;
        v_metri:=v_maxm;
      else
      v_pos   := public._esame_bordo(public._esame_muove(v.pos_png, v.pos_candidato, v_maxm, v_mov = 'avanti'));
      if v_pos = v.pos_png then continue; end if;
      v_metri := abs(v_pos - v.pos_png);
      end if;
      v_int := v_int || jsonb_build_array(jsonb_build_object(
        'chiave',     'manovra.' || v_mov,
        'genere',     'manovra',
        'etichetta',  case v_mov when 'avanti' then 'Guadagnare terreno'
                                 else 'Cedere terreno' end,
        'movimento',  v_mov,
        'metri',      v_metri,
        'rapida',     null, 'principale', null, 'reazione', null));
    end loop;
  end if;

  -- ── il pavimento: da qui non si esce con l'elenco vuoto ──────────────────
  -- Vale come rete, non come strada: con i sei profili vivi (passo 5 o 10
  -- metri) questo ramo non si accende mai, e il banco lo asserisce invece di
  -- darlo per buono. Ma se un giorno si accendesse, la differenza è fra una
  -- mezza scena persa e una prova che muore aspettando il chiuditore.
  if jsonb_array_length(v_int) = 0 then
    v_int := jsonb_build_array(jsonb_build_object(
      'chiave',     'manovra.fermo',
      'genere',     'manovra',
      'etichetta',  'Studiare l''avversario senza attaccare',
      'movimento',  null, 'metri', null,
      'rapida',     null, 'principale', null, 'reazione', null));
  end if;

  -- Nessun tetto silenzioso: `troncate` dice quante intenzioni sono state
  -- tolte, e il tetto non tocca mai le manovre né il pavimento.
  return public._esame_png_numera('attacco', v_int, v_tolte);
end
$function$;


-- SOURCE candidato/full_body/_esame_png_scena.sql
CREATE OR REPLACE FUNCTION public._esame_png_scena(p_prova uuid, p_asof timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_ag public.ai_agents%rowtype;
  v_c public.characters%rowtype;
  v_d numeric;
  v_spatial jsonb; v_bound boolean;
  v_storia jsonb;
begin
  select * into v from public.esame_prove where id = p_prova;
  if not found then raise exception 'La prova non esiste più'; end if;
  select * into v_prof from public.esame_png_profili where id = v.profilo_id;
  select * into v_ag   from public.ai_agents        where id = v_prof.agent_id;
  select * into v_c    from public.characters       where id = v.candidate_character;

  -- [replay] lo stato com'era a un istante dato, ricostruito dagli scambi.
  if p_asof is not null then
    v := public._esame_stato_asof(v, p_asof);
  end if;

  v_bound:=public._esame_spatial_snapshot_v1(p_prova) is not null;
  v_spatial:=public._esame_spatial_snapshot_asof_v1(p_prova,p_asof);
  if v_bound and v_spatial is null then raise exception 'EXAM_SPATIAL_HISTORY_UNAVAILABLE'; end if;
  v_d := case when v_bound then (v_spatial->>'distance_m')::numeric
              else abs(v.pos_png-v.pos_candidato) end;

  -- Gli ultimi tre scambi, in parole e in terza persona.
  select coalesce(jsonb_agg(t.x order by t.rn desc), '[]'::jsonb) into v_storia
    from (
      select row_number() over (order by s.ordine desc) as rn,
             jsonb_build_object(
               'quando', case row_number() over (order by s.ordine desc)
                           when 1 then 'poco fa' when 2 then 'prima' else 'all''inizio' end,
               'chi',    s.attacker_name,
               'azione', coalesce(s.tech_name, 'un colpo'),
               'contro', s.defender_name,
               'difesa', coalesce(s.reazione, 'nessuna'),
               'bersaglio', public._esame_scambio_fatti(s)->>'bersaglio',
               'esito',  case when s.esito_copie = 'copia_colpita' then 'una copia è stata colpita'
                              when s.esito_copie = 'originale_individuato' then 'l''originale è stato individuato'
                              when s.ko then 'fuori combattimento'
                              when s.colpito then 'a segno'
                              when s.striscio then 'di striscio'
                              else 'a vuoto' end,
               'conseguenza', public._esame_scambio_fatti(s)->>'conseguenza') as x
        from public.esame_scambi s
       where s.prova_id = p_prova
         and (p_asof is null or s.created_at <= p_asof)
       order by s.ordine desc
       limit 3) t;

  return jsonb_build_object(
    'luogo', public._esame_luogo_prova(p_prova),
    'sfidante', jsonb_build_object(
      'nome',      v_prof.nome,
      'epiteto',   v_prof.epiteto,
      'villaggio', v_prof.villaggio,
      'grado',     'deshi',
      'stile',     v_prof.stile,
      'genere',    case when coalesce(v_ag.persona->>'genere','') <> '' then v_ag.persona->>'genere'
                        when v_prof.nome in ('Kotoha','Hazuki','Kazane') then 'femminile' else 'maschile' end),
    'candidato', jsonb_build_object(
      'nome',      coalesce(v_c.name, 'il candidato'),
      'villaggio', coalesce(v_c.village, v_prof.villaggio),
      'grado',     'deshi'),
    'condizione', jsonb_build_object(
      'sfidante',  jsonb_build_object(
        'fiato',  public._esame_banda_pv(v.pv_png, v.pv_png_max),
        'chakra', public._esame_banda_ck(v.ck_png, v.ck_png_max),
        'copie',  case when v.copie_attive_png then 'copie attive' else 'nessuna copia' end),
      'candidato', jsonb_build_object(
        'fiato',  public._esame_banda_pv(v.pv_cand, v.pv_cand_max),
        'chakra', public._esame_banda_ck(v.ck_cand, v.ck_cand_max),
        'copie',  case when v.copie_attive_cand then 'copie attive' else 'nessuna copia' end)),
    'misura', jsonb_build_object(
      'fascia', case when v_d <= 2 then 'a contatto' when v_d<=10 then 'a corta distanza'
                    when v_d<=30 then 'a media distanza' else 'a lunga distanza' end,
      'descrizione', case when v_d <= 2 then 'i due sono addosso l''uno all''altro'
                          when v_d <= 5 then 'i due sono a pochi passi'
                          when v_bound then 'i due sono separati da spazio percorribile'
                          else 'i due sono ai lati opposti del tatami' end,
      'bordo', concat_ws('; ',
        case when not v_bound and v.pos_candidato in (0,10) then v_c.name || ' ha il bordo del tatami alle spalle' end,
        case when not v_bound and v.pos_png in (0,10) then v_prof.nome || ' ha il bordo del tatami alle spalle' end)),
    'momento', jsonb_build_object(
      'scambio', case v.scambio when 1 then 'primo' when 2 then 'secondo'
                             when 3 then 'terzo' else 'ultimo' end,
      'tocca_a', case when v.meta = 'png' then v_prof.nome
                      when v.meta = 'candidato' then coalesce(v_c.name,'il candidato')
                      else 'il Narratore' end,
      'fase',    v.fase),
    'spazio', case when v_bound then jsonb_build_object('autorita','arena',
      'distanza_m',v_d,'candidato',jsonb_build_object('riferimento','candidato'),
      'avversario',jsonb_build_object('riferimento','avversario'))
      else public._esame_spazio_json(p_prova, false) end,
    'osservazioni', to_jsonb(coalesce(v.osservazioni, array[]::text[])),
    'segni', public._esame_segni(p_prova, null, p_asof),
    'storia', v_storia);
end
$function$;


-- SOURCE candidato/full_body/_esame_png_scena_snapshot_v1.sql
CREATE OR REPLACE FUNCTION public._esame_png_scena_snapshot_v1(p_prova uuid, p_asof timestamp with time zone, p_version integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_ag public.ai_agents%rowtype;
  v_c public.characters%rowtype;
  v_d numeric;
  v_spatial jsonb; v_bound boolean;
  v_storia jsonb;
begin
  select * into v from public.esame_prove where id = p_prova;
  if not found then raise exception 'La prova non esiste più'; end if;
  select * into v_prof from public.esame_png_profili where id = v.profilo_id;
  select * into v_ag   from public.ai_agents        where id = v_prof.agent_id;
  select * into v_c    from public.characters       where id = v.candidate_character;

  -- [replay] lo stato com'era a un istante dato, ricostruito dagli scambi.
  if p_asof is not null then
    v := public._esame_stato_asof(v, p_asof);
  end if;

  v_bound:=public._esame_spatial_snapshot_v1(p_prova) is not null;
  v_spatial:=public._esame_spatial_snapshot_version_v1(p_prova,p_version);
  if v_bound and v_spatial is null then raise exception 'EXAM_SPATIAL_HISTORY_UNAVAILABLE'; end if;
  v_d := case when v_bound then (v_spatial->>'distance_m')::numeric
              else abs(v.pos_png-v.pos_candidato) end;

  -- Gli ultimi tre scambi, in parole e in terza persona.
  select coalesce(jsonb_agg(t.x order by t.rn desc), '[]'::jsonb) into v_storia
    from (
      select row_number() over (order by s.ordine desc) as rn,
             jsonb_build_object(
               'quando', case row_number() over (order by s.ordine desc)
                           when 1 then 'poco fa' when 2 then 'prima' else 'all''inizio' end,
               'chi',    s.attacker_name,
               'azione', coalesce(s.tech_name, 'un colpo'),
               'contro', s.defender_name,
               'difesa', coalesce(s.reazione, 'nessuna'),
               'bersaglio', public._esame_scambio_fatti(s)->>'bersaglio',
               'esito',  case when s.esito_copie = 'copia_colpita' then 'una copia è stata colpita'
                              when s.esito_copie = 'originale_individuato' then 'l''originale è stato individuato'
                              when s.ko then 'fuori combattimento'
                              when s.colpito then 'a segno'
                              when s.striscio then 'di striscio'
                              else 'a vuoto' end,
               'conseguenza', public._esame_scambio_fatti(s)->>'conseguenza') as x
        from public.esame_scambi s
       where s.prova_id = p_prova
         and (p_asof is null or s.created_at <= p_asof)
       order by s.ordine desc
       limit 3) t;

  return jsonb_build_object(
    'luogo', public._esame_luogo_prova(p_prova),
    'sfidante', jsonb_build_object(
      'nome',      v_prof.nome,
      'epiteto',   v_prof.epiteto,
      'villaggio', v_prof.villaggio,
      'grado',     'deshi',
      'stile',     v_prof.stile,
      'genere',    case when coalesce(v_ag.persona->>'genere','') <> '' then v_ag.persona->>'genere'
                        when v_prof.nome in ('Kotoha','Hazuki','Kazane') then 'femminile' else 'maschile' end),
    'candidato', jsonb_build_object(
      'nome',      coalesce(v_c.name, 'il candidato'),
      'villaggio', coalesce(v_c.village, v_prof.villaggio),
      'grado',     'deshi'),
    'condizione', jsonb_build_object(
      'sfidante',  jsonb_build_object(
        'fiato',  public._esame_banda_pv(v.pv_png, v.pv_png_max),
        'chakra', public._esame_banda_ck(v.ck_png, v.ck_png_max),
        'copie',  case when v.copie_attive_png then 'copie attive' else 'nessuna copia' end),
      'candidato', jsonb_build_object(
        'fiato',  public._esame_banda_pv(v.pv_cand, v.pv_cand_max),
        'chakra', public._esame_banda_ck(v.ck_cand, v.ck_cand_max),
        'copie',  case when v.copie_attive_cand then 'copie attive' else 'nessuna copia' end)),
    'misura', jsonb_build_object(
      'fascia', case when v_d <= 2 then 'a contatto' when v_d<=10 then 'a corta distanza'
                    when v_d<=30 then 'a media distanza' else 'a lunga distanza' end,
      'descrizione', case when v_d <= 2 then 'i due sono addosso l''uno all''altro'
                          when v_d <= 5 then 'i due sono a pochi passi'
                          when v_bound then 'i due sono separati da spazio percorribile'
                          else 'i due sono ai lati opposti del tatami' end,
      'bordo', concat_ws('; ',
        case when not v_bound and v.pos_candidato in (0,10) then v_c.name || ' ha il bordo del tatami alle spalle' end,
        case when not v_bound and v.pos_png in (0,10) then v_prof.nome || ' ha il bordo del tatami alle spalle' end)),
    'momento', jsonb_build_object(
      'scambio', case v.scambio when 1 then 'primo' when 2 then 'secondo'
                             when 3 then 'terzo' else 'ultimo' end,
      'tocca_a', case when v.meta = 'png' then v_prof.nome
                      when v.meta = 'candidato' then coalesce(v_c.name,'il candidato')
                      else 'il Narratore' end,
      'fase',    v.fase),
    'spazio', case when v_bound then jsonb_build_object('autorita','arena',
      'distanza_m',v_d,'candidato',jsonb_build_object('riferimento','candidato'),
      'avversario',jsonb_build_object('riferimento','avversario'))
      else public._esame_spazio_json(p_prova, false) end,
    'osservazioni', to_jsonb(coalesce(v.osservazioni, array[]::text[])),
    'segni', public._esame_segni(p_prova, null, p_asof),
    'storia', v_storia);
end
$function$;
REVOKE ALL ON FUNCTION public._esame_png_scena_snapshot_v1(uuid,timestamptz,integer) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public._esame_png_scena_snapshot_v1(uuid,timestamptz,integer) TO postgres,service_role;


-- SOURCE candidato/full_body/_esame_prova_azione_esegui.sql
CREATE OR REPLACE FUNCTION public._esame_prova_azione_esegui(p_prova uuid, p_azione jsonb, p_testo text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype; v_uid uuid := auth.uid();
  v_op jsonb; v_tipo text; v_fonte text; v_id uuid; v_sposta int; v_rapida text;
  v_reaz text; v_voce jsonb; v_maxm int; v_dist numeric; v_portata int; v_costo int; v_nome text;
  v_spatial jsonb; v_move jsonb;
  v_c public.characters%rowtype; v_opzione text; v_verso int; v_rifiuto text;
  -- [ADDENDUM] la posizione risultante, e la fotografia di INIZIO METÀ che
  -- `_esame_risolvi` scriverà nel referto. Viaggiano in `pend_azione` invece che
  -- in due colonne di `esame_prove`: è lo stesso trasporto che RUNTIME-AUDIT-011
  -- usa per `narr`, e una variabile non attraversa due transazioni.
  v_pos_new int; v_pc0 int; v_pp0 int;
  -- [038] il messaggio del candidato, salvato nella STESSA transazione
  -- dell'azione strutturata. È il fatto 1 di QA-037: due testi da 940 e
  -- 927 caratteri salvati, e `storia: []` nel payload. Erano due gesti.
  v_msg uuid; v_testo text; v_res jsonb;
begin
  if v_uid is null then raise exception 'non autenticato'; end if;
  select * into v from public.esame_prove where id = p_prova for update;
  if not found then raise exception 'La prova non esiste più'; end if;
  if v.candidate_user <> v_uid then raise exception 'Questa non è la tua prova'; end if;
  if v.stato <> 'aperta' then raise exception 'La prova non è più aperta'; end if;
  if exists (select 1 from public.esame_narrazione_cicli c
              where c.prova_id=p_prova and c.ruolo='png_esito' and c.stato='aperta') then
    raise exception 'Il narratore sta completando l''esito della tua difesa.';
  end if;
  select * into v_c from public.characters where id = v.candidate_character;

  -- ⚠️ QUI, prima di qualunque movimento: dopo, `v` viene riletta e questi
  -- due numeri sarebbero già quelli di dopo.
  v_pc0 := v.pos_candidato; v_pp0 := v.pos_png;
  v_spatial:=public._esame_spatial_snapshot_v1(p_prova);

  -- ═══ [038] IL TESTO DEL CANDIDATO, ATOMICO CON L'AZIONE ═══════════════════
  -- Prima di ogni ramo, e dentro il `for update` della prova: o entrano tutti e
  -- due o non entra nessuno dei due. Il client non può indicare un messaggio
  -- altrui perché non indica nessun messaggio — lo SCRIVE questa porta, con
  -- l'utente e il personaggio già validati sopra.
  --
  -- Il tetto è 2.500 e SOLLEVA invece di troncare: un testo tagliato è un testo
  -- rotto pubblicato in chat, e il giocatore non saprebbe perché. Il client ha
  -- già il proprio contatore; questa è la rete, non la regola.
  -- [A10 §D] Qui si CONTROLLA soltanto. La pubblicazione è più giù, nei
  -- punti in cui l'azione non può più essere rifiutata: un testo scritto
  -- prima della validazione resta in aula anche quando il gesto non è
  -- mai avvenuto, perché il rifiuto di gittata non solleva.
  v_testo := nullif(btrim(coalesce(p_testo,'')),'');
  if v_testo is not null then
    if length(v_testo) > 5000 then
      raise exception 'Il testo supera i 5.000 caratteri (ne hai scritti %).', length(v_testo);
    end if;
  end if;
  v_tipo := lower(coalesce(p_azione->>'tipo',''));
  v_op   := public._esame_prova_opzioni(p_prova, 'candidato');
  v_dist := case when v_spatial is null then abs(v.pos_png-v.pos_candidato)
                 else (v_spatial->>'distance_m')::numeric end;

  -- ── il candidato REAGISCE (metà d'attacco del PNG) ──────────────────────
  if v.meta = 'png' and v.fase = 'difesa' then
    if v_tipo <> 'difesa' then raise exception 'non è il tuo turno'; end if;
    v_reaz := lower(coalesce(p_azione->>'reazione','schivata'));
    if v_reaz = 'guardia' then
      raise exception 'La Guardia è stata ritirata: scegli una reazione di difesa.';
    end if;
    if v_reaz = 'copie' and (p_azione ? 'tecnica' or p_azione ? 'posizione') then
      raise exception 'Le copie non accettano tecnica, posizione o valori dal client.';
    end if;
    select e into v_voce from jsonb_array_elements(v_op->'reazioni') e
     where e->>'chiave'=v_reaz
       and (v_spatial is null or v_reaz<>'sostituzione' or e->>'option_id'=p_azione->>'option_id')
       and (v_reaz<>'tecnica' or e->>'id'=coalesce(p_azione->>'tecnica',''));
    if v_voce is null then raise exception 'tecnica non disponibile o non ancora attiva'; end if;
    if not coalesce((v_voce->>'disponibile')::boolean,false) then
      if v.beat < 3 and v_reaz = 'sostituzione' then
        raise exception 'In questa prova non ancora: %', v_voce->>'motivo_no';
      end if;
      if v_reaz = 'sostituzione' and v.sost_round_cand is not null then
        raise exception 'La Sostituzione non si usa due turni di fila.';
      end if;
      raise exception '%', coalesce(v_voce->>'motivo_no','tecnica non disponibile o non ancora attiva');
    end if;
    v_msg := public._esame_testo_candidato(p_prova, v_testo);   -- [A10 §D]
    return public._esame_risolvi(p_prova,
      jsonb_build_object('tipo','difesa','reazione',v_reaz,
                         'option_id',case when v_reaz='sostituzione' then v_voce->>'option_id' end,
                         'tecnica',case when v_reaz='tecnica' then v_voce->>'id' else null end,
                         'opzione_id',case when v_reaz='tecnica' then v_reaz||':'||(v_voce->>'id') else v_reaz end,
                         'scelta_da','candidato'),
      'candidato');
  end if;

  -- ── il candidato ATTACCA ────────────────────────────────────────────────
  if not (v.meta = 'candidato' and v.fase = 'attacco') then
    raise exception 'non è il tuo turno';
  end if;
  if v_tipo not in ('attacco','manovra') then raise exception 'non è il tuo turno'; end if;

  -- ── [031] nessuna principale legale: avvicina e chiude la metà ─────────────
  -- Contratto: {"tipo":"manovra","manovra":"avvicinamento"}.
  -- Il client sceglie una chiave chiusa, mai metri o posizione. La legalità
  -- viene ricalcolata dallo stato bloccato; un secondo invio serializza dietro
  -- il FOR UPDATE e trova il turno già passato.
  if v_tipo = 'manovra' then
    if (p_azione - array['tipo','manovra']::text[]) <> '{}'::jsonb then
      raise exception 'La manovra non accetta metri, posizione, tecnica o altri valori.';
    end if;
    select e into v_voce
      from jsonb_array_elements(coalesce(v_op->'manovre','[]'::jsonb)) e
     where e->>'chiave' = lower(btrim(coalesce(p_azione->>'manovra','')));
    if v_voce is null or not coalesce((v_voce->>'disponibile')::boolean,false) then
      raise exception 'manovra non disponibile: esiste ancora una continuazione legale';
    end if;

    v_maxm := (coalesce(v_c.velocita,0) / 10) * 5;
    if v_spatial is not null then
      v_move:=public._esame_spatial_move_commit_v1(p_prova,'candidato',v_maxm,true,
        md5('exam-manovra|'||p_prova::text||'|'||v.scambio::text||'|'||v.meta)::uuid);
    else
    v_pos_new := public._esame_bordo(public._esame_muove(v.pos_candidato, v.pos_png, v_maxm, true));
    if v_pos_new = v.pos_candidato then
      raise exception 'manovra non disponibile: nessun avvicinamento utile';
    end if;
    end if;

    update public.esame_prove
       set pos_candidato      = case when v_spatial is null then v_pos_new else pos_candidato end,
           -- È un cambio di distanza reale: la condotta deve vederlo, come
           -- vede il riposizionamento del Diversivo.
           spostamenti_cand   = spostamenti_cand + 1,
           meta               = 'png',
           fase               = 'attacco',
           usato_principale   = false,
           usato_rapida       = false,
           usato_spostamento  = false,
           pend_azione        = null,
           -- Nessun attacco è arrivato: le copie del PNG scadono quando
           -- comincia il successivo turno d'attacco del proprietario.
           copie_attive_png   = false,
           copie_scambio_png  = null,
           opzioni_png = null, opzioni_id = null, opzioni_at = null
     where id = p_prova
       and stato = 'aperta' and meta = 'candidato' and fase = 'attacco'
       and not usato_principale and not usato_spostamento;
    if not found then
      raise exception 'manovra già consumata o turno già passato';
    end if;

    v_msg := public._esame_testo_candidato(p_prova, v_testo);   -- [A10 §D]
    perform public._esame_png_turno(p_prova);
    return public._esame_stato_json(p_prova)
      || jsonb_build_object('manovra', jsonb_build_object(
           'genere','manovra','chiave','avvicinamento','esito','misura chiusa'));
  end if;
  if p_azione ? 'rapida' and p_azione->'rapida' is not null
     and p_azione->'rapida' <> 'null'::jsonb then
    raise exception 'La Guardia è stata ritirata: l''Esame non offre azioni rapide.';
  end if;

  -- Moltiplicazione governa da sola la propria posizione; nessun movimento
  -- separato può precederla nella stessa azione.
  if lower(coalesce(p_azione->'principale'->>'fonte',''))='moltiplicazione'
     and p_azione ? 'spostamento' then
    raise exception 'Moltiplicazione non accetta uno spostamento separato';
  end if;

  -- spostamento, se dichiarato: si applica PRIMA dell'attacco, come nel motore.
  v_sposta := coalesce((p_azione->>'spostamento')::int, 0);
  if v_sposta <> 0 then
    if v.usato_spostamento then raise exception 'hai già usato lo spostamento in questo round'; end if;
    v_maxm := coalesce((v_op->'spostamento'->>'max_metri')::int, 0);
    if abs(v_sposta) > v_maxm then
      raise exception 'con Velocità % ti muovi al massimo di % metri', v_c.velocita, v_maxm;
    end if;
    -- positivo = avvicinarsi, negativo = allontanarsi. Il client dice quanti
    -- metri e da che parte; DOVE si finisce lo decide il server, e lo decide in
    -- una sede sola — la stessa del PNG e dello scontro ordinario.
    if v_spatial is not null then
      v_move:=public._esame_spatial_move_commit_v1(p_prova,'candidato',abs(v_sposta),v_sposta>0,
        md5('exam-spostamento|'||p_prova::text||'|'||v.scambio::text||'|'||v.meta)::uuid);
    else
    v_pos_new := public._esame_bordo(public._esame_muove(v.pos_candidato, v.pos_png,
                                     abs(v_sposta), v_sposta > 0));
    -- [ADDENDUM decisione 5] zero cambiamenti = rifiuto, e PRIMA di consumare.
    -- ⚠️ `raise` e non un rifiuto silenzioso: qui siamo dentro la porta del
    -- giocatore, e un `update` a zero righe gli lascerebbe l'interfaccia ferma
    -- senza sapere perché. Non c'è nessun contatore da salvare da un rollback:
    -- fin qui la transazione non ha scritto niente.
    if v_pos_new = v.pos_candidato then
      raise exception 'Da qui quello spostamento non cambierebbe la posizione.';
    end if;
    end if;
    update public.esame_prove
       set pos_candidato = case when v_spatial is null then v_pos_new else pos_candidato end,
           usato_spostamento = true,
           spostamenti_cand = spostamenti_cand + 1
     where id = p_prova;
    select * into v from public.esame_prove where id = p_prova;
    v_dist := case when v_spatial is null then abs(v.pos_png-v.pos_candidato)
                   else (v_move->'after'->>'distance_m')::numeric end;
    v_op := public._esame_prova_opzioni(p_prova, 'candidato');
  end if;

  if v.usato_principale then raise exception 'hai già speso l''azione principale'; end if;

  -- ── [017-R1] il diversivo: una PAROLA, mai una posizione ────────────────
  -- Il client manda `{"principale":{"fonte":"diversivo","direzione":"ritirata"}}`.
  -- Non manda metri, non manda una posizione finale, e non c'è nessun parametro
  -- da cui potrebbe. La direzione si valida contro l'elenco che il server ha
  -- appena calcolato: è la stessa forma dello scontrino del Narratore.
  if lower(coalesce(p_azione->'principale'->>'fonte','')) = 'diversivo' then
    select e into v_voce from jsonb_array_elements(v_op->'diversivi') e
     where e->>'chiave' = lower(btrim(coalesce(p_azione->'principale'->>'direzione','')));
    if v_voce is null then
      raise exception 'quella direzione non è fra quelle offerte in questo momento';
    end if;
    if not coalesce((v_voce->>'disponibile')::boolean, false) then
      raise exception '%', coalesce(v_voce->>'motivo_no', 'quel diversivo non è disponibile adesso');
    end if;
    v_msg := public._esame_testo_candidato(p_prova, v_testo);   -- [A10 §D]
    v_res := public._esame_diversivo(p_prova, 'candidato', v_voce->>'chiave',
                                     (v_voce->>'id')::uuid, 'candidato');
    if not coalesce((v_res->>'ok')::boolean, false) then
      raise exception '%', coalesce(v_res->>'motivo', 'diversivo rifiutato');
    end if;
    return v_res;
  end if;

  v_fonte := lower(coalesce(p_azione->'principale'->>'fonte','colpo'));

  if v_fonte='moltiplicazione' then
    if ((p_azione->'principale') - array['fonte','id','modalita','copie','direzione','originale_idx']::text[])<>'{}'::jsonb then
      raise exception 'Moltiplicazione contiene campi non autorizzati';
    end if;
    v_msg := public._esame_testo_candidato(p_prova, v_testo);   -- [A10 §D]
    return public._esame_moltiplicazione_candidato(
      p_prova,p_azione->'principale'->>'modalita',
      nullif(p_azione->'principale'->>'copie','')::integer,
      p_azione->'principale'->>'direzione',
      nullif(p_azione->'principale'->>'originale_idx','')::integer);
  end if;

  if v_fonte = 'scena' then
    v_id := nullif(p_azione->'principale'->>'id','')::uuid;
    select e into v_voce
      from jsonb_array_elements(coalesce(v_op->'principali','[]'::jsonb)) e
     where e->>'fonte' = 'scena' and (e->>'id')::uuid = v_id;
    if v_voce is null or not coalesce((v_voce->>'disponibile')::boolean,false) then
      raise exception '%', coalesce(v_voce->>'motivo_no','tecnica di scena non disponibile');
    end if;
    v_costo := coalesce((v_voce->>'chakra')::int,0);
    v_nome := v_voce->>'nome';
    if v_costo > v.ck_cand then
      raise exception 'Chakra insufficiente: servono % (ne hai %)', v_costo, v.ck_cand;
    end if;

    update public.esame_prove
       set ck_cand = greatest(0, ck_cand - v_costo),
           meta = 'png', fase = 'attacco',
           usato_principale = false, usato_rapida = false, usato_spostamento = false,
           pend_azione = null, opzioni_png = null, opzioni_id = null, opzioni_at = null
     where id = p_prova and stato = 'aperta' and meta = 'candidato' and fase = 'attacco';
    if not found then raise exception 'turno già passato'; end if;
    v_msg := public._esame_testo_candidato(p_prova, v_testo);   -- [A10 §D]
    perform public._esame_png_turno(p_prova);
    return public._esame_stato_json(p_prova)
      || jsonb_build_object('tecnica_scena', jsonb_build_object(
           'id',v_id,'nome',v_nome,'chakra_speso',v_costo,'danno',0));
  end if;

  if v_fonte = 'colpo' then
    v_portata := 2; v_costo := 0; v_opzione := 'colpo';
    if v_dist > v_portata then
      -- ⚠️ SCELTA DICHIARATA, e ratificabile dal PM. Qui NON si solleva: si
      --    registra il rifiuto e si restituisce la frase del motore. È il solo
      --    modo perché l'osservazione «ha attaccato da fuori portata più di una
      --    volta» (§7.2) possa scattare: un'eccezione annulla la transazione e
      --    con essa il contatore, e l'osservazione non scatterebbe mai — cioè
      --    il difetto che la R1.2 ha appena tolto dall'altra riga del §7.2.
      --    Nulla viene speso e la prova non avanza.
      v_rifiuto := v_c.name || ' è a ' || v_dist || ' metri: «Colpo a mani nude» arriva a ' || v_portata || '.';
      update public.esame_prove set rifiuti_gittata = rifiuti_gittata + 1 where id = p_prova;
      return public._esame_stato_json(p_prova) || jsonb_build_object('rifiuto', v_rifiuto);
    end if;
  elsif v_fonte in ('jutsu','clan','innata') then
    v_id := nullif(p_azione->'principale'->>'id','')::uuid;
    select e into v_voce from jsonb_array_elements(v_op->'principali') e where (e->>'id')::uuid = v_id;
    if v_voce is null then
      select e into v_voce from jsonb_array_elements(v_op->'innate') e where (e->>'id')::uuid = v_id;
    end if;
    if v_voce is null then
      -- [017-R1] il rifiuto PARLANTE: la tecnica esiste, il giocatore ce l'ha,
      -- ma non è un attacco. Senza questo ramo il messaggio sarebbe «tecnica
      -- non disponibile», che è vero e inutile — e il pulsante di oggi manda
      -- proprio questo.
      if exists (select 1 from public.jutsu j
                  where j.id = v_id and j.is_active and coalesce(j.diversivo,false)) then
        raise exception '«%» non è un attacco: crea copie illusorie per coprire uno spostamento. Si gioca scegliendo una direzione.',
          (select name_it from public.jutsu where id = v_id);
      end if;
      -- [042-B0] il rifiuto PARLANTE per la tecnica di scena: esiste, il
      -- candidato la possiede, ma non è un attacco.
      if exists (select 1 from public.jutsu j
                  where j.id = v_id and j.is_active and coalesce(j.di_scena,false)) then
        raise exception '«%» è una tecnica di scena: si usa fuori dallo scontro e non può essere dichiarata come attacco.',
          (select name_it from public.jutsu where id = v_id);
      end if;
      raise exception 'tecnica non disponibile o non ancora attiva';
    end if;
    v_portata := coalesce((v_voce->>'portata_m')::int, 30);
    v_costo   := coalesce((v_voce->>'chakra')::int, 0);
    v_opzione := 'jutsu:' || v_id::text;
    if v_dist > v_portata then
      v_rifiuto := v_c.name || ' è a ' || v_dist || ' metri: «' || (v_voce->>'nome') || '» arriva a ' || v_portata || '.';
      update public.esame_prove set rifiuti_gittata = rifiuti_gittata + 1 where id = p_prova;
      return public._esame_stato_json(p_prova) || jsonb_build_object('rifiuto', v_rifiuto);
    end if;
    if v_costo > v.ck_cand then
      raise exception 'Chakra insufficiente: servono % (ne hai %)', v_costo, v.ck_cand;
    end if;
    if not coalesce((v_voce->>'disponibile')::boolean,false) then
      raise exception '%', coalesce(v_voce->>'motivo_no','tecnica non disponibile o non ancora attiva');
    end if;
  else
    raise exception 'tecnica non disponibile o non ancora attiva';
  end if;

  -- L'attacco è dichiarato: resta in attesa della reazione del PNG. Il turno
  -- del PNG non dipende dal browser (§7.3): lo spinge esame_prova_tick.
  update public.esame_prove
     set usato_principale = true,
         fase = 'difesa',
         pend_azione = jsonb_build_object(
           'tipo','attacco',
           'principale', jsonb_build_object('fonte', v_fonte, 'id', v_id),
           'opzione_id', v_opzione, 'scelta_da', 'candidato',
           'spatial_before_version',v_spatial->'map_version',
           'pos_cand_prima', case when v_spatial is null then v_pc0 end,
           'pos_png_prima', case when v_spatial is null then v_pp0 end)
   where id = p_prova;

  v_msg := public._esame_testo_candidato(p_prova, v_testo);   -- [A10 §D]
  perform public._esame_png_turno(p_prova);
  return public._esame_stato_json(p_prova);
end
$function$;


-- SOURCE candidato/full_body/_esame_prova_opzioni.sql
CREATE OR REPLACE FUNCTION public._esame_prova_opzioni(p_prova uuid, p_chi text DEFAULT 'candidato'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 VOLATILE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_c public.characters%rowtype;
  v_dist numeric; v_maxm int; v_ck int; v_vel int; v_nin int;
  v_spatial jsonb; v_avv jsonb; v_rit jsonb;
  v_speso boolean; v_rapida_spesa boolean; v_sposta_spesa boolean;
  v_beat int;
  v_disp_id uuid; v_disp_ck int := 0; v_disp_nome text; v_disp_ok boolean := false;
  v_princ jsonb; v_scen jsonb := '[]'::jsonb; v_inn jsonb := '[]'::jsonb; v_rap jsonb; v_reaz jsonb;
  v_common_sost jsonb := '[]'::jsonb;
  v_png boolean; v_motivo_beat text; v_copie boolean;
  -- [017-R1] il diversivo e le sue direzioni
  v_div jsonb := '[]'::jsonb; v_div_id uuid; v_div_nome text; v_div_ck int := 0;
  v_div_scorso int; v_div_ok boolean; v_direzioni jsonb := '[]'::jsonb;
  v_copie_cap int := 0; v_copie_offerte jsonb := '[]'::jsonb;
  v_assalto_avanzamenti jsonb := '[]'::jsonb;
  -- [ADDENDUM] le due posizioni risultanti, calcolate una volta e lette due:
  -- dal ramo `disponibile` e dal ramo `metri`. Calcolarle due volte è il modo
  -- in cui un elenco comincia a promettere una cosa e l'esecutore a farne
  -- un'altra.
  v_pos_io int; v_pos_lui int; v_pos_avv int; v_pos_rit int;
  v_avv_ok boolean; v_rit_ok boolean;
  -- [031] La manovra del candidato non è un attacco e non accetta metri.
  v_man jsonb := '[]'::jsonb; v_dist_dopo_avv numeric;
  v_principale_dopo boolean := false;
begin
  select * into v from public.esame_prove where id = p_prova;
  if not found then raise exception 'La prova non esiste più'; end if;
  v_spatial := public._esame_spatial_snapshot_v1(p_prova);
  if v_spatial is null then
    return public._esame_prova_opzioni_legacy_v1(p_prova,p_chi);
  end if;
  select * into v_prof from public.esame_png_profili where id = v.profilo_id;

  v_png  := (lower(coalesce(p_chi,'candidato')) = 'png');
  v_beat := v.beat;
  v_dist := (v_spatial->>'distance_m')::numeric;

  if v_png then
    v_vel := v_prof.velocita; v_nin := v_prof.ninjutsu; v_ck := v.ck_png;
    v_copie := coalesce(v.copie_attive_png,false);
  else
    select * into v_c from public.characters where id = v.candidate_character;
    v_vel := coalesce(v_c.velocita,0); v_nin := coalesce(v_c.ninjutsu,0); v_ck := v.ck_cand;
    v_copie := coalesce(v.copie_attive_cand,false);
  end if;
  v_maxm := (v_vel / 10) * 5;

  -- [ADDENDUM] `_esame_muove` è la sede unica: si ferma sul bersaglio, non
  -- scavalca, e rispetta il campo. Se questo elenco calcolasse i metri con
  -- un'aritmetica sua, tornerebbe il difetto in forma più piccola.
  v_avv := public._esame_spatial_move_preview_v1(p_prova,p_chi,v_maxm,true);
  v_rit := public._esame_spatial_move_preview_v1(p_prova,p_chi,v_maxm,false);
  v_avv_ok := (v_avv->>'available')::boolean;
  v_rit_ok := (v_rit->>'available')::boolean;

  -- L'economia dell'azione vale per chi ha il turno d'attacco in questa metà.
  v_speso        := v.usato_principale and ((v.meta = 'png') = v_png);
  v_rapida_spesa := v.usato_rapida     and ((v.meta = 'png') = v_png);
  v_sposta_spesa := v.usato_spostamento and ((v.meta = 'png') = v_png);

  v_motivo_beat := case v_beat
    when 1 then 'In questa prova non ancora: prima il passo e il colpo, il maestro vuole vedere quelli.'
    when 2 then 'In questa prova non ancora: prima mostra come ti muovi.'
    else null end;

  -- ── principali: i jutsu. Beat 1 non li offre ancora; beat 2 sì. ──────────
  -- Nessuna tecnica di clan per il PNG: un avversario d'esame non ha clan.
  select coalesce(jsonb_agg(x order by x->>'nome'), '[]'::jsonb) into v_princ from (
    select jsonb_build_object(
      'id', j.id, 'fonte', 'jutsu', 'nome', j.name_it, 'clan', null, 'livello', null,
      'grado', j.rank, 'disciplina', j.category, 'gittata', coalesce(j.gittata,'media'),
      'portata_m', public._fascia_metri(coalesce(j.gittata,'media')),
      'chakra', coalesce(j.chakra_cost,0),
      'posseduta', true,
      'disponibile', v_dist <= public._fascia_metri(coalesce(j.gittata,'media'))
                     and (coalesce(j.chakra_cost,0) = 0 or v_ck >= coalesce(j.chakra_cost,0))
                     and not v_speso,
      'motivo_no', case
        when v_speso then 'hai già speso l''azione principale'
        when v_dist > public._fascia_metri(coalesce(j.gittata,'media'))
          then 'a ' || v_dist || ' metri non arriva: copre ' || public._fascia_metri(coalesce(j.gittata,'media'))
        when coalesce(j.chakra_cost,0) > v_ck
          then 'servono ' || j.chakra_cost || ' chakra, ne hai ' || v_ck
        end) as x
      from public.jutsu j
     where j.is_active and j.uso = 'principale' and not coalesce(j.difensiva,false)
       -- [017-R1] un diversivo NON è un attacco: esce dall'elenco delle
       -- principali e rientra sotto `diversivi`, che ha regole sue. È in UN
       -- PUNTO SOLO, ed è il perimetro di cui parla `04_COLONNE.md`.
       and not coalesce(j.diversivo,false)
       -- [042-B0] né una tecnica di scena. Vale per il candidato E per il
       -- PNG: `_esame_png_intenzioni` cicla su questo stesso elenco.
       and not coalesce(j.di_scena,false)
       and ( (v_png and j.id = any(v_prof.repertorio))
             or (not v_png and exists (select 1 from public.character_jutsu cj
                                        where cj.jutsu_id = j.id and cj.user_id = v.candidate_user)) )
  ) s;

  if not v_png then
    select coalesce(jsonb_agg(x order by x->>'nome'), '[]'::jsonb) into v_scen from (
      select jsonb_build_object(
        'id', j.id, 'fonte', 'scena', 'nome', j.name_it,
        'grado', j.rank, 'disciplina', j.category, 'gittata', 'sé stesso',
        'portata_m', 0, 'chakra', coalesce(j.chakra_cost,0),
        'posseduta', true,
        'disponibile', not v_speso
                       and (coalesce(j.chakra_cost,0) = 0 or v_ck >= coalesce(j.chakra_cost,0)),
        'motivo_no', case
          when v_speso then 'hai già speso l''azione principale'
          when coalesce(j.chakra_cost,0) > v_ck
            then 'servono ' || j.chakra_cost || ' chakra, ne hai ' || v_ck
          end) as x
        from public.jutsu j
       where j.is_active and coalesce(j.di_scena,false)
         and j.uso <> 'fuori_scontro'
         and exists (select 1 from public.character_jutsu cj
                      where cj.jutsu_id = j.id and cj.user_id = v.candidate_user)
    ) s;
    v_princ := v_princ || v_scen;
  end if;

  -- ── innate: solo il candidato può averne, e solo al beat 3 ──────────────
  if not v_png then
    select coalesce(jsonb_agg(x order by x->>'nome'), '[]'::jsonb) into v_inn from (
      select jsonb_build_object(
        'id', t.id, 'fonte', 'innata', 'nome', t.name, 'clan', t.clan, 'livello', t.level,
        'chakra', coalesce(t.chakra_cost,0), 'per_round', true, 'posseduta', true,
        'disponibile', v_beat >= 3 and not v_speso
                       and (coalesce(t.chakra_cost,0) = 0 or v_ck >= coalesce(t.chakra_cost,0)),
        'motivo_no', case
          when v_beat < 3 then 'In questa prova non ancora: si aggiunge all''ultimo scambio.'
          when v_speso then 'hai già speso l''azione principale'
          when coalesce(t.chakra_cost,0) > v_ck
            then 'servono ' || t.chakra_cost || ' chakra, ne hai ' || v_ck
          end) as x
        from public.clan_techniques t
        join public.character_abilities ca
          on ca.technique_id = t.id and ca.character_id = v.candidate_character and ca.state = 'attiva'
       where t.is_active and t.is_innata and t.consumption_type = 'per_turno'
         and public._grade_rank(coalesce(v_c.rank,'Deshi')) >=
             public._grade_rank(coalesce(t.req_grade,'Deshi'))
    ) s;
  end if;

  -- [R3] Guardia è ritirata: non esistono rapide nel contratto dell'Esame.
  v_rap := '[]'::jsonb;

  -- La Sostituzione arriva esclusivamente dal resolver spaziale comune.
  -- Le opzioni contengono capability opache e un'etichetta semantica: mai
  -- coordinate, distanze o la vecchia lista di posizioni.
  v_common_sost := public._esame_sostituzione_opzioni_comune_v1(p_prova, p_chi);

  if v.fase='difesa'
     and (v.pend_azione->'principale'->>'fonte')='jutsu'
     and exists (select 1 from public.jutsu a
                  where a.id=(v.pend_azione->'principale'->>'id')::uuid
                    and lower(a.category)='genjutsu') then
    select j.id,j.name_it,coalesce(j.chakra_cost,0)
      into v_disp_id,v_disp_nome,v_disp_ck
      from public.jutsu j
     where j.is_active and j.name_it='Dispersione'
       and ((v_png and j.id=any(v_prof.repertorio))
         or (not v_png and exists(select 1 from public.character_jutsu cj
                                  where cj.jutsu_id=j.id and cj.user_id=v.candidate_user)))
     limit 1;
    v_disp_ok := v_disp_id is not null and (v_disp_ck=0 or v_ck>=v_disp_ck);
  end if;

  v_reaz := jsonb_build_array(
    jsonb_build_object('chiave','schivata','nome','Schivata','chakra',0,'disponibile',true),
    jsonb_build_object('chiave','parata','nome','Parata','chakra',0,'disponibile',true)
  ) || v_common_sost;

  -- [A10 §B] Le copie compaiono SOLO se ci sono. Niente voce grigia con
  -- un motivo_no: una difesa che non si può giocare non è un'opzione.
  if v_copie then
    v_reaz := v_reaz || jsonb_build_array(jsonb_build_object(
      'chiave','copie','nome','Confondere con le copie','chakra',0,
      'disponibile', v.fase = 'difesa'));
  end if;

  -- [A10 §B] Stesso principio per la Dispersione: c'è quando è giocabile
  -- (contro Genjutsu e con il chakra che basta), altrimenti non c'è.
  if v_disp_ok then
    v_reaz := v_reaz || jsonb_build_array(jsonb_build_object(
      'chiave','tecnica','id',v_disp_id,'nome',v_disp_nome,'fonte','jutsu',
      'disciplina','Abilità','chakra',v_disp_ck,'disponibile',true));
  end if;

  -- ── [017-R1] il diversivo: DUE direzioni, e solo se muovono davvero ────
  -- Le condizioni sono quattro e stanno tutte qui, perché l'elenco è la sola
  -- fonte di legalità (decisione PM 9). `_esame_diversivo` le ricontrolla
  -- comunque: chi esegue non si fida di chi offre.
  --
  -- ⚠️ `manovre_png < 2` vale anche per il diversivo, e non è pignoleria: il
  -- diversivo incrementa `manovre_png`, quindi eredita la prova di
  -- terminazione della R2. Se lo si offrisse oltre il due, si allungherebbe
  -- una catena che la R2 ha dimostrato finita, e la dimostrazione andrebbe
  -- rifatta da capo.
  select j.id, j.name_it, coalesce(j.chakra_cost,0)
    into v_div_id, v_div_nome, v_div_ck
    from public.jutsu j
   where j.is_active and coalesce(j.diversivo,false)
     and ( (v_png and j.id = any(v_prof.repertorio))
           or (not v_png and exists (select 1 from public.character_jutsu cj
                                      where cj.jutsu_id = j.id and cj.user_id = v.candidate_user)) )
   order by j.name_it limit 1;

  v_div_scorso := case when v_png then v.diversivo_scambio_png else v.diversivo_scambio_cand end;
  v_div_ok := v_div_id is not null
              and v.fase = 'attacco'
              and not v_speso
              and v_div_ck <= v_ck
              and (v_div_scorso is null or v_div_scorso < v.scambio)
              and (not v_png or v.manovre_png < 2);

  if v_div_ok then
    select coalesce(jsonb_agg(x order by x->>'chiave'), '[]'::jsonb) into v_div from (
      select jsonb_build_object(
        'chiave',    d.dir,
        'nome',      case d.dir when 'avvicinamento' then 'Coprire un avvicinamento'
                                else 'Coprire una ritirata' end,
        'tecnica',   v_div_nome,
        'id',        v_div_id,
        'chakra',    v_div_ck,
        'distanza_dopo', (m.preview->>'distance_after_m')::numeric,
        'disponibile', true) as x
        from (values ('avvicinamento'),('ritirata')) as d(dir)
        cross join lateral (select public._esame_spatial_move_preview_v1(p_prova,p_chi,
          case when d.dir='avvicinamento' then 5 else greatest(0,least(5,2+v_maxm-v_dist)) end,
          d.dir='avvicinamento') as preview) m
       -- zero offerte morte: una direzione che non cambia la posizione non
       -- viene presentata. Non è un vezzo di interfaccia, è il mandato.
       where (m.preview->>'available')::boolean
    ) s;
  end if;

  -- [107] Assalto usa soltanto l'avanzamento interno che chiude davvero la
  -- misura. Il payload offre zero se il candidato è già a contatto, altrimenti
  -- l'unica distanza positiva necessaria. Se la Velocità non basta, Assalto
  -- non compare fra le modalità: il client non deve proporre mosse morte.
  if not v_png then
    if v_dist <= 2 then
      v_assalto_avanzamenti := jsonb_build_array(0);
    elsif v_avv_ok and (v_avv->>'distance_after_m')::numeric <= 2 then
      -- Il comando resta in passi da cinque metri; il percorso effettivo
      -- può arrestarsi prima. Il writer ricontrolla lo stesso preview.
      select coalesce(jsonb_agg(n order by n),'[]'::jsonb) into v_assalto_avanzamenti
      from (select n from generate_series(5,v_maxm,5) n
        where (public._esame_spatial_move_preview_v1(p_prova,p_chi,n,true)->>'distance_after_m')::numeric<=2
        order by n limit 1) only_contact;
    else
      v_assalto_avanzamenti := '[]'::jsonb;
    end if;
  end if;

  -- [077] Per il candidato Moltiplicazione è UNA tecnica. Direzione e modalità
  -- sono decisioni di secondo livello; copie e costi arrivano dal server.
  if not v_png and v_div_id is not null then
    v_direzioni:=v_div;
    v_copie_cap:=least(public._copie_cap(coalesce(v_c.ninjutsu,0),coalesce(v_c.rank,'Deshi')),4,
                       greatest(0,(v_ck-v_div_ck)/5));
    select coalesce(jsonb_agg(n order by n),'[]'::jsonb) into v_copie_offerte
      from generate_series(1,v_copie_cap) n;
    if v.fase='attacco' and not v_speso and v_copie_cap>0
       and (v_div_scorso is null or v_div_scorso<v.scambio) then
      v_div:=jsonb_build_array(jsonb_build_object(
        'id',v_div_id,'tecnica',v_div_nome,'nome',v_div_nome,'disponibile',true,
        'modalita_offerte',jsonb_build_array('diversivo','copertura') ||
          case when jsonb_array_length(v_assalto_avanzamenti)>0
               then jsonb_build_array('assalto') else '[]'::jsonb end,
        'assalto_avanzamenti',v_assalto_avanzamenti,
        'direzioni_offerte',v_direzioni,'copie_offerte',v_copie_offerte,
        'copie_max',v_copie_cap,'costo_base',v_div_ck,'costo_per_copia',5));
    else
      v_div:='[]'::jsonb;
    end if;
  end if;

  -- ── [031] manovra di chiusura del candidato ──────────────────────────────
  -- Il confronto è sullo stato RISULTANTE dopo il massimo avvicinamento.
  -- Le innate disponibili contano: se il candidato può agire, la manovra
  -- non compare. Il server calcola distanza e posizione, mai il client.
  v_dist_dopo_avv := (v_avv->>'distance_after_m')::numeric;
  select (v_dist_dopo_avv <= 2)
      or exists (
           select 1 from jsonb_array_elements(v_princ) e
            where coalesce((e->>'chakra')::int,0) <= v_ck
              and coalesce((e->>'portata_m')::int,0) >= v_dist_dopo_avv)
      or exists (
           select 1 from jsonb_array_elements(v_inn) e
            where coalesce((e->>'disponibile')::boolean,false))
    into v_principale_dopo;

  if not v_png
     and v.fase = 'attacco' and v.meta = 'candidato'
     and not v_speso and not v_sposta_spesa
     and v_avv_ok
     and jsonb_array_length(v_div) = 0
     and not v_principale_dopo then
    v_man := jsonb_build_array(jsonb_build_object(
      'chiave', 'avvicinamento',
      'nome', 'Chiudere la misura',
      'disponibile', true,
      'distanza_dopo', v_dist_dopo_avv));
  end if;

  return jsonb_build_object(
    'versione', 1,
    'prova_id', v.id, 'chi', case when v_png then 'png' else 'candidato' end,
    'scambio', v.scambio, 'beat', v_beat, 'fase', v.fase, 'meta', v.meta,
    'distanza', v_dist,
    'fascia', case when v_dist <= 2 then 'a contatto' when v_dist <= 10 then 'corta'
                   when v_dist <= 30 then 'media' else 'lunga' end,
    'slancio', case when v_png then v.slancio_png else v.slancio_cand end,
    'chakra', jsonb_build_object('ora', v_ck, 'max', case when v_png then v.ck_png_max else v.ck_cand_max end),
    'spostamento', jsonb_build_object(
      'disponibile', v.fase = 'attacco' and not v_sposta_spesa
                     and (v_avv_ok or v_rit_ok),
      'max_metri', v_maxm,
      'avvicinamento', jsonb_build_object(
        'disponibile', v.fase = 'attacco' and not v_sposta_spesa and v_avv_ok,
        'metri',         (v_avv->>'travelled_m')::numeric,
        'distanza_dopo', (v_avv->>'distance_after_m')::numeric,
        'motivo_no', case when not v_avv_ok then 'sei già addosso: non c''è terreno da guadagnare' end),
      'ritirata', jsonb_build_object(
        'disponibile', v.fase = 'attacco' and not v_sposta_spesa and v_rit_ok,
        'metri',         (v_rit->>'travelled_m')::numeric,
        'distanza_dopo', (v_rit->>'distance_after_m')::numeric,
        'motivo_no', case when not v_rit_ok then 'da qui non puoi cedere altro terreno' end),
      'motivo_no', case when v.fase = 'difesa' then 'in difesa si risponde e basta'
                        when v_sposta_spesa then 'già speso in questo round'
                        when not (v_avv_ok or v_rit_ok) then 'nessuno spostamento cambierebbe la posizione' end),
    'colpo', jsonb_build_object('nome','Colpo a mani nude','fonte','colpo','gittata','contatto',
      'portata_m', 2, 'chakra', 0,
      'disponibile', v_dist <= 2 and not v_speso,
      'disponibile_dopo_avvicinamento',
        v_dist > 2 and not v_speso and v_avv_ok and v_dist_dopo_avv <= 2,
      'motivo_no', case when v_speso then 'hai già speso l''azione principale'
                        when v_dist > 2 then 'a ' || v_dist || ' metri non lo raggiungi: serve il contatto' end),
    'principali', v_princ,
    'diversivi', v_div,
    'manovre', v_man,
    'innate', v_inn,
    'rapide', v_rap,
    'reazioni', v_reaz);
end
$function$;


-- SOURCE release/031_REPLAY_PAYLOAD.sql
CREATE OR REPLACE FUNCTION public._esame_replay_payload(p_prova uuid, p_ciclo uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  c public.esame_narrazione_cicli%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_c public.characters%rowtype;
  s public.esame_scambi%rowtype;     -- lo scambio risolto da/dopo questo ciclo
  v_pg text; v_ref jsonb; v_fatti jsonb; v_int jsonb; v_asof timestamptz;
  v_chi_att text; v_esiti jsonb; v_et text; v_f jsonb; v_mov text;
  v_pc_prima int; v_pp_prima int; v_ordine int;
  v_spatial jsonb; v_audit jsonb; v_bound boolean; v_scene_version integer;
begin
  select * into v from public.esame_prove where id = p_prova;
  if not found then return null; end if;
  select * into c from public.esame_narrazione_cicli where id = p_ciclo and prova_id = p_prova;
  if not found then return null; end if;
  select * into v_prof from public.esame_png_profili where id = v.profilo_id;
  select * into v_c from public.characters where id = v.candidate_character;
  v_asof := c.created_at;
  v_bound:=public._esame_spatial_snapshot_v1(p_prova) is not null;
  v_audit:=c.referto->'_spatial_audit';
  if v_bound then
    if v_audit is null then raise exception 'EXAM_SPATIAL_REPLAY_REFERENCE_MISSING'; end if;
    v_scene_version:=(v_audit->>case when c.ruolo in ('png_esito','png_finale') then 'after_version' else 'before_version' end)::int;
    v_spatial:=public._esame_spatial_snapshot_version_v1(p_prova,v_scene_version);
  end if;
  select left(btrim(m.body), 2500) into v_pg from public.messages m where m.id = c.pg_message_id;

  -- lo scambio collegato: per png_esito/png_finale è l'ultimo scritto PRIMA
  -- del ciclo; per png_difende/png_attacca è il primo scritto DOPO.
  if v_bound then
    select x.* into strict s from public.esame_scambi x
      where x.id=(v_audit->>'scambio_id')::uuid and x.prova_id=p_prova;
  elsif c.ruolo in ('png_esito','png_finale') then
    select * into s from public.esame_scambi x where x.prova_id = p_prova and x.created_at <= c.created_at
     order by x.ordine desc limit 1;
  else
    select * into s from public.esame_scambi x where x.prova_id = p_prova and x.created_at > c.created_at
     order by x.ordine asc limit 1;
  end if;

  -- il referto, arricchito con i fatti ricalcolati
  if c.ruolo in ('png_esito','png_finale') and s.id is not null then
    v_f := public._esame_scambio_fatti(s);
    if v_bound then
      v_mov:=c.referto->>'movimento';
    else
    v_pc_prima := coalesce(s.pos_cand_prima, s.pos_cand); v_pp_prima := coalesce(s.pos_png_prima, s.pos_png);
    v_mov := coalesce(nullif(concat_ws('; ',
      case when v_pc_prima <> s.pos_cand then v_c.name || case when abs(s.pos_png - s.pos_cand) < abs(s.pos_png - v_pc_prima) then ' ha guadagnato terreno' else ' ha ceduto terreno' end end,
      case when v_pp_prima <> s.pos_png then v_prof.nome || case when abs(s.pos_png - s.pos_cand) < abs(v_pp_prima - s.pos_cand) then ' ha guadagnato terreno' else ' ha ceduto terreno' end end), ''), 'nessuno');
    end if;
    v_ref := coalesce(c.referto, '{}'::jsonb) || jsonb_build_object(
      'bersaglio', v_f->>'bersaglio', 'bersaglio_su', s.defender_name,
      'conseguenza', v_f->>'conseguenza', 'gravita', v_f->>'gravita',
      'postura_difensore', case when s.colpito or s.ko then public._esame_postura(v_f->>'gravita', s.ko) else 'in guardia' end,
      'movimento', v_mov,
      'iniziativa', case when c.ruolo = 'png_finale' then 'la prova si chiude'
                         when s.chi_attacca = 'png' then 'passa a ' || s.defender_name else 'passa a ' || s.attacker_name end,
      'scambio', case s.scambio when 1 then 'primo' when 2 then 'secondo' when 3 then 'terzo' else 'ultimo' end,
      'ancora', case when v_bound then c.referto->'ancora'
                    when s.reazione = 'sostituzione' and not s.colpito
                     then (select jsonb_build_object('id',a->>'id','oggetto',a->>'oggetto','dove',a->>'dove','taglia',a->>'taglia','nota',a->>'nota')
                             from jsonb_array_elements(public._esame_aula_ancore(public._esame_aula_villaggio(p_prova))) a
                            order by sqrt(power((a->>'x')::numeric - (case when s.chi_attacca='png' then s.pos_cand else s.pos_png end),2) + power((a->>'y')::numeric - 5,2)), a->>'id' limit 1)
                     else null end,
      'segni', public._esame_segni(p_prova, s.ordine));
    v_ref := public._esame_referto_modello(v_ref-'_spatial_audit');
  elsif c.ruolo = 'png_attacca' then
    v_ref := (select public._esame_referto_modello(p.referto-'_spatial_audit') from public.esame_narrazione_cicli p
               where p.prova_id = p_prova and p.ruolo = 'png_difende' and p.stato = 'risolta'
                 and p.created_at < c.created_at
               order by p.resolved_at desc nulls last, p.created_at desc limit 1);
  else
    v_ref := null;
  end if;

  -- l'intenzione reale come unica intenzione
  v_esiti := to_jsonb(coalesce(c.esiti_attesi, array[]::text[]));
  if c.ruolo in ('png_difende','png_attacca') then
    v_chi_att := case when c.ruolo = 'png_attacca' then 'png' else 'candidato' end;
    v_et := case when c.ruolo = 'png_difende' then 'Reazione: ' || coalesce(s.reazione, 'reazione')
                 else coalesce(s.tech_name, 'attacco') end;
    v_int := jsonb_build_array(jsonb_build_object(
      'id', coalesce(c.intenzione_id, 'replay'), 'etichetta', v_et,
      'genere', case when c.ruolo = 'png_difende' then 'reazione' else 'turno' end,
      'movimento', null, 'esiti_possibili', v_esiti));
    v_fatti := jsonb_build_object(
      'attacca', case when v_chi_att = 'png' then v_prof.nome else coalesce(v_c.name,'il candidato') end,
      'difende', case when v_chi_att = 'png' then coalesce(v_c.name,'il candidato') else v_prof.nome end,
      'bersaglio_previsto', case when s.id is not null
          then coalesce(case when s.chi_attacca <> 'png' then public._esame_zona_dichiarata(v_pg, v.seme, public._esame_indice(s.scambio, s.meta, s.chi_attacca, 'att')) end, public._esame_zona(v.seme, s.scambio, s.meta, s.chi_attacca, s.kind)) else null end,
      'nota_bersaglio', case when c.ruolo = 'png_difende'
          then 'se il colpo del candidato arriva, arriva qui: le branche «colpito» e «sfiorato» lo raccontano su questa zona; la gravità non è ancora nota e non va quantificata'
          else 'se l''attacco dello sfidante arriva, arriva qui: la frase che apre l''attacco dice che mira a questa zona; l''esito lo decide il campo e lo racconta il ciclo successivo' end,
      'ancora_sostituzione', null);
  else
    v_int := jsonb_build_array(jsonb_build_object(
      'id', case when c.ruolo = 'png_finale' then 'narra_finale' else 'narra_esito' end,
      'etichetta', case when c.ruolo = 'png_finale' then 'Concludi l''Esame' else 'Racconta l''esito della difesa' end,
      'genere', case when c.ruolo = 'png_finale' then 'finale' else 'esito' end,
      'movimento', null, 'esiti_possibili', '[]'::jsonb));
    v_fatti := '{}'::jsonb;
  end if;

  return public._esame_payload_v5_complete_v1(p_prova,jsonb_build_object(
    'versione', 5, 'replay', true,
    'ricevuta_id', c.opzioni_id, 'ruolo', c.ruolo,
    'contesto_pg', coalesce(v_pg,''),
    'esito_precedente', v_ref,
    'fatti_del_ciclo', v_fatti,
    'stile_precedente', public._esame_storia_narrativa(p_prova, v_asof),
    'scena', case when v_bound then public._esame_png_scena_snapshot_v1(p_prova,v_asof,v_scene_version)
                  else public._esame_png_scena(p_prova, v_asof) end,
    'dossier', public._esame_dossier_sfidante(p_prova),
    'sensei', case when c.ruolo = 'png_finale' then public._esame_sensei_finale(p_prova) else null end,
    'intenzioni', v_int,
    'originale', jsonb_build_object('azione_png', c.azione_png, 'testo_esito', c.testo_esito, 'model', c.model, 'stato', c.stato)));
end
$function$;


-- SOURCE candidato/full_body/_esame_risolvi.sql
CREATE OR REPLACE FUNCTION public._esame_risolvi(p_prova uuid, p_azione jsonb, p_chi text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_c public.characters%rowtype;
  v_att jsonb;                       -- l'attacco dichiarato e in attesa
  v_chi_att text; v_png_att boolean;
  v_kind text := 'fisico'; v_base int := 0; v_tech text := 'Colpo a mani nude';
  v_elem text; v_gittata text := 'contatto'; v_portata int := 2;
  v_reaz text; v_dif_disc text; v_dif_tech text;
  v_a jsonb; v_d jsonb; v_calc jsonb;
  v_dist numeric; v_dado_a int; v_dado_d int;
  v_spatial_before jsonb; v_spatial_after jsonb;
  v_spatial_start jsonb; v_spatial_event uuid;
  v_pv int; v_pv_max int; v_slancio int; v_slancio_next int;
  v_ck_costo int := 0; v_ck_reaz int := 0;
  v_ordine int; v_colpito boolean; v_striscio boolean; v_appl int; v_ko boolean := false;
  v_nome_att text; v_nome_dif text; v_esito text; v_base_frase text; v_frase text;
  v_loc uuid; v_copie_attive boolean := false; v_esito_copie text;
  v_assalto boolean := false; v_copie_att int := 0; v_mod_assalto int := 0; v_esito_assalto text;
  v_originale_idx int := 0; v_bersaglio_idx int := 0;
  -- [038] la ricevuta del ciclo, la riga di scambio appena scritta e il
  -- testo composto. `v_frase` resta: è ancora la voce del ripiego.
  v_ciclo public.esame_narrazione_cicli%rowtype; v_scambio_id uuid;
  v_app text; v_testo text; v_mid uuid; v_ruolo_png text;
  v_esito_ciclo uuid; v_esito_ricevuta uuid;
  v_finale boolean := false; v_finale_tipo text; v_senza_forze jsonb;
  v_scambio_risolto int;
  -- [BANCO 038] l'intestazione AZIONE e l'etichetta chiusa della
  -- reazione, per il ripiego in difesa.
  v_az text; v_et text; v_referto jsonb; v_dist_lab text; v_danno_lab text;
  v_sost_comune jsonb;
  -- [001] la ricevuta arricchita: bersaglio, conseguenza, gravità, ancora,
  -- movimento, iniziativa — fatti del server, in parole.
  v_zona text; v_conseg text; v_grav text; v_ancora jsonb; v_pos_dif int;
  v_movimento text; v_pc_prima int; v_pp_prima int;
begin
  select * into v from public.esame_prove where id = p_prova for update;
  if not found then raise exception 'La prova non esiste più'; end if;
  v_spatial_before:=public._esame_spatial_snapshot_v1(p_prova);
  if v_spatial_before is null then
    return public._esame_risolvi_legacy_v1(p_prova,p_azione,p_chi);
  end if;
  if v.stato <> 'aperta' then raise exception 'La prova non è più aperta'; end if;
  select * into v_prof from public.esame_png_profili where id = v.profilo_id;
  select * into v_c from public.characters where id = v.candidate_character;
  select location_id into v_loc from public.academy_class_sessions where id = v.class_session_id;

  v_att := coalesce(v.pend_azione, '{}'::jsonb);
  v_chi_att := case when v.meta = 'png' then 'png' else 'candidato' end;
  v_png_att := (v_chi_att = 'png');
  if lower(coalesce(p_chi,'')) = v_chi_att then
    raise exception 'Chi attacca non può anche reagire: la metà di scambio è mal composta.';
  end if;

  v_nome_att := case when v_png_att then v_prof.nome else v_c.name end;
  v_nome_dif := case when v_png_att then v_c.name else v_prof.nome end;
  v_dist := (v_spatial_before->>'distance_m')::numeric;

  -- ── che cosa attacca ────────────────────────────────────────────────────
  -- ── [017-R1] la terza rete: un diversivo non arriva MAI fin qui ─────────
  -- Gli unici scrittori di `pend_azione` sono `esame_prova_azione` e
  -- `_esame_png_gioca`, ed entrambi sono guardati. Se questo ramo si accende, un
  -- chiamante è regredito — e la scelta è fra una prova ferma e una prova che
  -- infligge danno con una tecnica che per regolamento non ne fa.
  -- ⚠️ SOLLEVA di proposito: scostamento dichiarato (§3 di
  -- `03_DECISIONI_E_SCOSTAMENTI.md`). Una prova ferma si vede; il danno
  -- silenzioso è esattamente il difetto che stiamo chiudendo.
  if (v_att->'principale'->>'fonte') = 'jutsu'
     and exists (select 1 from public.jutsu j
                  where j.id = (v_att->'principale'->>'id')::uuid
                    and coalesce(j.diversivo,false)) then
    raise exception 'Un diversivo non può essere risolto come attacco: la metà è mal composta.';
  end if;

  -- [042-B0] gemella, per la tecnica di scena.
  if (v_att->'principale'->>'fonte') = 'jutsu'
     and exists (select 1 from public.jutsu j
                  where j.id = (v_att->'principale'->>'id')::uuid
                    and coalesce(j.di_scena,false)) then
    raise exception 'Una tecnica di scena non può essere risolta come attacco: la metà è mal composta.';
  end if;

  v_assalto := (v_att->'principale'->>'fonte')='moltiplicazione'
               and (v_att->'principale'->>'modalita')='assalto';
  if v_assalto then
    v_kind:='fisico'; v_base:=10; v_tech:='Moltiplicazione del corpo · Assalto';
    v_elem:=null; v_gittata:='contatto'; v_portata:=2; v_ck_costo:=0;
    v_copie_att:=greatest(1,least(4,coalesce((v_att->'principale'->>'copie')::int,1)));
    v_originale_idx:=coalesce((v_att->'principale'->>'originale_idx')::int,0);
    if v_originale_idx<1 or v_originale_idx>v_copie_att+1 then
      raise exception 'L''Assalto non contiene un originale valido.';
    end if;
    v_bersaglio_idx:=1+mod(public._esame_dado(
      v.seme,public._esame_indice(v.scambio,v.meta,v_chi_att,'assalto')),v_copie_att+1);
    if v_bersaglio_idx=v_originale_idx then
      v_esito_assalto:='originale_individuato'; v_mod_assalto:=0;
    else
      v_esito_assalto:='copia_colpita'; v_mod_assalto:=public._copie_bonus(v_copie_att);
    end if;
  elsif (v_att->'principale'->>'fonte') = 'jutsu' then
    select lower(j.category), coalesce(j.damage_base,0), j.name_it, j.nature,
           coalesce(j.gittata,'media'), public._fascia_metri(coalesce(j.gittata,'media')),
           coalesce(j.chakra_cost,0)
      into v_kind, v_base, v_tech, v_elem, v_gittata, v_portata, v_ck_costo
      from public.jutsu j where j.id = (v_att->'principale'->>'id')::uuid;
  else
    v_kind := 'fisico'; v_base := 10; v_tech := 'Colpo a mani nude';
    v_elem := null; v_gittata := 'contatto'; v_portata := 2; v_ck_costo := 0;
  end if;

  -- ── come si reagisce ────────────────────────────────────────────────────
  v_reaz := lower(coalesce(p_azione->>'reazione','schivata'));
  if v_reaz not in ('schivata','parata','sostituzione','tecnica','copie') then
    raise exception 'reazione non valida';
  end if;
  if v_reaz = 'sostituzione' then
    v_sost_comune := public._esame_sostituzione_commit_comune_v1(
      p_prova,
      nullif(p_azione->>'option_id','')::uuid,
      p_chi
    );
    v_spatial_after:=public._esame_spatial_snapshot_v1(p_prova);
  end if;
  v_copie_attive := case when v_png_att then coalesce(v.copie_attive_cand,false)
                         else coalesce(v.copie_attive_png,false) end;
  if v_reaz = 'copie' and not v_copie_attive then
    raise exception 'Le copie non sono più attive.';
  end if;
  if v_reaz = 'sostituzione' then
    -- [V1.1 · decisione 11] il costo si legge dalla riga vera, non si scrive 0.
    select j.name_it, lower(j.category), coalesce(j.chakra_cost,0)
      into v_dif_tech, v_dif_disc, v_ck_reaz
      from public.jutsu j
     where j.is_active and j.difensiva and j.action_type = 'reazione' limit 1;
    v_dif_tech := coalesce(v_dif_tech, 'Sostituzione');
    v_dif_disc := coalesce(v_dif_disc, 'ninjutsu');
  elsif v_reaz='tecnica' then
    if v_kind<>'genjutsu' then
      raise exception 'Dispersione si usa soltanto come difesa da un Genjutsu.';
    end if;
    select j.name_it,lower(j.category),coalesce(j.chakra_cost,0)
      into v_dif_tech,v_dif_disc,v_ck_reaz
      from public.jutsu j
     where j.id=nullif(p_azione->>'tecnica','')::uuid
       and j.is_active and j.name_it='Dispersione' and j.uso='difesa' and j.difensiva
       and ((v_png_att and exists(select 1 from public.character_jutsu cj
                                  where cj.jutsu_id=j.id and cj.user_id=v.candidate_user))
         or (not v_png_att and j.id=any(v_prof.repertorio)))
     limit 1;
    if v_dif_tech is null then
      raise exception 'Dispersione non posseduta o non disponibile.';
    end if;
  end if;

  -- ── i dadi: deterministici, dal seme della prova ────────────────────────
  v_dado_a := public._esame_dado(v.seme, public._esame_indice(v.scambio, v.meta, v_chi_att, 'att'));
  v_dado_d := public._esame_dado(v.seme, public._esame_indice(v.scambio, v.meta, v_chi_att, 'dif'));

  -- ── i due corpi, con lo Slancio dentro il json dell'ATTACCANTE ──────────
  v_slancio := case when v_png_att then v.slancio_png else v.slancio_cand end;
  if v_png_att then
    v_a := public._esame_corpo_json(v.profilo_id, v_slancio);
    v_d := public._esame_char_json(v.candidate_character, 0);
  else
    v_a := public._esame_char_json(v.candidate_character, case when v_assalto then 0 else v_slancio end);
    v_d := public._esame_corpo_json(v.profilo_id, 0);
  end if;

  v_d := v_d || jsonb_build_object('copie_n',case when v_png_att then v.copie_n_cand else v.copie_n_png end);
  v_calc := public._combat_calcola(
    v_kind, v_a, v_d, v_reaz, v_dif_disc, v_base, v_elem,
    v_dado_a, v_dado_d, v_mod_assalto, 0, false);

  if v_assalto and v_esito_assalto='copia_colpita' then
    v_d := v_d || jsonb_build_object(
      'velocita',0,'taijutsu',0,'mente',0,'ninjutsu',0,'genjutsu',0,'fuuinjutsu',0,'copie_n',0);
    v_calc := public._combat_calcola(
      v_kind,v_a,v_d,'nessuna',null,v_base,v_elem,
      v_dado_a,0,0,0,false);
  end if;

  v_colpito  := (v_calc->>'colpito')::boolean;
  v_striscio := (v_calc->>'striscio')::boolean;
  v_appl     := (v_calc->>'danno_applicato')::int;
  if v_reaz = 'sostituzione' then
    v_colpito := false;
    v_striscio := false;
    v_appl := 0;
  end if;
  v_esito_copie := case when v_assalto then v_esito_assalto else nullif(v_calc->>'esito_copie','') end;

  -- ── le risorse SIMULATE: qui, e in nessun altro posto ───────────────────
  if v_png_att then
    v_pv := greatest(0, v.pv_cand - v_appl);  v_pv_max := v.pv_cand_max;
  else
    v_pv := greatest(0, v.pv_png  - v_appl);  v_pv_max := v.pv_png_max;
  end if;
  v_ko := (v_pv = 0);

  -- [001] i fatti in parole, decisi QUI e scritti sullo scambio.
  v_danno_lab := case when v_ko then 'fuori combattimento'
                      when v_appl = 0 then 'nessuno'
                      when v_appl <= greatest(1, v_pv_max / 10) then 'lieve'
                      when v_appl <= greatest(1, v_pv_max / 4) then 'serio'
                      else 'grave' end;
  v_zona   := case when not v_png_att then public._esame_zona_dichiarata((select m.body from public.esame_narrazione_cicli c2 join public.messages m on m.id = c2.pg_message_id  where c2.prova_id = p_prova and c2.ruolo = 'png_difende' order by c2.created_at desc limit 1), v.seme, public._esame_indice(v.scambio, v.meta, v_chi_att, 'att')) end;
  v_zona   := coalesce(v_zona, public._esame_zona(v.seme, v.scambio, v.meta, v_chi_att, v_kind)); -- [005] testo del candidato prima del dado
  v_grav   := case when v_colpito or v_striscio or v_ko then v_danno_lab else 'nessuno' end;
  v_conseg := case when v_colpito or v_striscio or v_ko
                   then public._esame_conseguenza(v_danno_lab, v_zona, v_ko) else 'nessuna' end;
  v_pos_dif := case when v_png_att then v.pos_candidato else v.pos_png end;
  v_ancora := case when v_reaz = 'sostituzione' then jsonb_build_object(
    'id', v_sost_comune#>>'{exchange_identity,substitution_event_id}',
    'nome', coalesce(v_sost_comune#>>'{narrator_projection,anchor_semantic_label}',
                     'ancora autorizzata'),
    'esito', 'consumed_non_substitutable'
  ) else null end;

  -- ── lo Slancio, con la regola del motore: +3 se non va a segno, tetto 9 ──
  if v_colpito then v_slancio_next := 0; else v_slancio_next := least(9, v_slancio + 3); end if;

  select coalesce(max(ordine),0) + 1 into v_ordine from public.esame_scambi where prova_id = p_prova;

  insert into public.esame_scambi (
    prova_id, profilo_id, scambio, meta, ordine, chi_attacca,
    attacker_name, defender_name, kind, tech_name, base, elemento, gittata, distanza,
    reazione, dif_tech_name, dif_disciplina,
    pool_att, pool_dif, dado_att, dado_dif, mod_mira, mod_guardia, mod_colto,
    mod_elem_att, mod_elem_dif, atk_tot, def_tot, margine, bonus_margine, off,
    riduzione_div, riduzione, danno_grezzo, danno_applicato, cap_attivo, colpito, ko,
    chakra_dichiarato, striscio, mod_slancio, slancio_successivo, esito_copie,
    opzione_scelta, scelta_da,
    pos_cand_prima, pos_png_prima, pos_cand, pos_png,
    bersaglio, conseguenza, gravita, ancora)
  values (
    p_prova, v.profilo_id, v.scambio, v.meta, v_ordine, v_chi_att,
    v_nome_att, v_nome_dif, v_kind, v_tech, v_base, v_elem, v_gittata, v_dist,
    v_reaz, v_dif_tech, v_dif_disc,
    (v_calc->>'pool_att')::int, (v_calc->>'pool_dif')::int,
    (v_calc->>'dado_att')::int, (v_calc->>'dado_dif')::int,
    (v_calc->>'mod_mira')::int, (v_calc->>'mod_guardia')::int, (v_calc->>'mod_colto')::int,
    (v_calc->>'mod_elem_att')::int, (v_calc->>'mod_elem_dif')::int,
    (v_calc->>'atk_tot')::int, (v_calc->>'def_tot')::int, (v_calc->>'margine')::int,
    (v_calc->>'bonus_margine')::int, (v_calc->>'off')::int,
    (v_calc->>'riduzione_div')::int, (v_calc->>'riduzione')::int,
    (v_calc->>'danno_grezzo')::int, v_appl, (v_calc->>'cap_attivo')::boolean,
    v_colpito, v_ko,
    v_ck_costo, v_striscio, (v_calc->>'mod_slancio')::int, v_slancio_next, v_esito_copie,
    coalesce(v_att->>'opzione_id', p_azione->>'opzione_id'),
    coalesce(v_att->>'scelta_da', p_azione->>'scelta_da', 'candidato'),
    -- «prima» viaggia dentro `pend_azione`, scritto da chi ha aperto la metà;
    -- se manca (una metà aperta da un corpo vecchio) si ripiega sullo stato di
    -- adesso, che è onesto: dice «non risulta nessun movimento».
    null, null, null, null,
    v_zona, v_conseg, v_grav, v_ancora->>'id')
  returning id into v_scambio_id;

  -- ── la voce: si racconta con le parole di riserva se l'IA non ha parlato ─
  v_esito := case
    when v_esito_copie = 'copia_colpita' then 'copia_colpita'
    when v_esito_copie = 'originale_individuato' then 'originale_individuato'
    when v_reaz = 'sostituzione' and not v_colpito then 'sostituito'
    when v_colpito then 'colpito'
    when v_striscio then 'sfiorato'
    when v_reaz = 'parata' then 'parato'
    when v_reaz = 'schivata' then 'schivato'
    else 'mancato' end;
  -- ═══ [038] LA VOCE UNICA · si pubblica SOLO la branca che è accaduta ═══
  --
  -- 🔴 Che cosa faceva questo blocco, e perché era sbagliato in due modi:
  --    (a) pubblicava con `_esame_post(v_loc, v_prof.nome, …)`, cioè con il
  --        NOME DEL PNG come autore — il difetto che il contratto chiude;
  --    (b) la guardia `if v_png_att` faceva sì che una difesa del PNG non
  --        venisse MAI narrata. È il fatto 2 di QA-037: «difesa complessa,
  --        nessun esito narrato». Non era una svista del modello: era questa
  --        riga.
  --
  -- Adesso: la prosa della branca reale viene dalla ricevuta, l'appendice la
  -- costruisce il server, e l'autore è sempre e solo «Il narratore».
  v_base_frase := (case when v_png_att then 'png_att' else 'cand_att' end) || '.'
               || (case when v_kind = 'fisico' then 'colpo' else 'tecnica' end) || '.' || v_esito;

  v_app := public._esame_appendice(v_scambio_id, public._esame_ciclo_numeri());

  -- La ricevuta viva di questo ciclo. `accettata` = il modello ha parlato ed è
  -- stato validato; `ripiego` = il modello è muto e la voce viene dal catalogo.
  select * into v_ciclo from public.esame_narrazione_cicli
   where prova_id = p_prova and stato in ('accettata','ripiego')
   order by created_at desc, id desc limit 1;

  if v_ciclo.id is not null
     and v_ciclo.stato = 'accettata'
     and v_ciclo.esiti ? v_esito then
    -- ⚠️ Il sigillo si ricontrolla QUI, sotto lock, prima di pubblicare. Non
    --    difende da un attaccante — chi scrive la tabella riscrive il sigillo —
    --    difende da NOI: una migrazione futura che tocchi `esiti` senza passare
    --    dal validatore fa diventare rossa la ricevuta invece di pubblicare
    --    prosa che nessuno ha validato.
    if v_ciclo.receipt_sha256 is distinct from public._esame_ricevuta_sigillo(
         v_ciclo.opzioni_id, v_ciclo.intenzione_id, v_ciclo.azione_png,
         v_ciclo.esiti, v_ciclo.esiti_attesi) then
      raise exception 'La ricevuta % non corrisponde al proprio sigillo: non pubblico.', v_ciclo.opzioni_id;
    end if;
    v_frase := v_ciclo.esiti->>v_esito;
  else
    -- Il ripiego: la frase del catalogo, con la regola di sempre. La differenza
    -- col passato è che adesso esce in TUTTI E DUE i ruoli, non solo quando il
    -- PNG attaccava.
    v_frase := public._esame_frase(p_prova, v_base_frase, v_ordine,
                 jsonb_build_object('attaccante', v_nome_att, 'difensore', v_nome_dif, 'tecnica', v_tech));
  end if;

  v_ruolo_png := coalesce(v_ciclo.ruolo, case when v_png_att then 'png_attacca' else 'png_difende' end);

  if v_frase is not null and btrim(v_frase) <> '' then
    if v_ruolo_png = 'png_difende' then
      -- UN messaggio solo: AZIONE + ESITO. L'azione è già stata validata e non
      -- è mai stata pubblicata da sola — è il punto del contratto §3.
      --
      -- 🔴 [BANCO 038 · difetto 5] IL RIPIEGO IN DIFESA HA LA STESSA FORMA.
      --    Col modello muto `azione_png` è nullo, e il ramo `else ''` faceva
      --    uscire il SOLO `ESITO`: due forme diverse per lo stesso momento
      --    della scena, e un'asimmetria col ripiego in attacco — che l'AZIONE
      --    la scrive, e per una ragione dichiarata («senza, il candidato
      --    riceverebbe un turno da difendere senza avere letto nessun
      --    attacco»). Qui vale identica: senza AZIONE il giocatore non legge
      --    mai che cosa il PNG ha TENTATO, solo com'è finita.
      --    L'etichetta è testo chiuso, e si legge dalla stessa porta che offre
      --    le reazioni: due elenchi delle stesse parole divergono.
      -- 🔴 «Kazane parata.» muore qui. Non era una frase: era un'etichetta con
      --    un punto in fondo, e attaccata alla prosa del modello produceva due
      --    voci nello stesso messaggio. Il ripiego adesso scrive una frase
      --    intera, con soggetto e verbo, scelta da un elenco CHIUSO del server.
      if coalesce(btrim(v_ciclo.azione_png),'') <> '' then
        v_az := btrim(v_ciclo.azione_png);
      else
        v_az := v_nome_dif || case lower(coalesce(v_reaz,''))
                  when 'parata'       then ' porta le braccia a coprirsi.'
                  when 'schivata'     then ' sposta il peso per uscire dalla traiettoria.'
                  when 'sostituzione' then ' tenta la Sostituzione.'
                  when 'copie'        then ' lascia che le sagome gli si chiudano davanti.'
                  else                     ' reagisce.' end;
      end if;
      -- 🔴 [A5] L'APPENDICE NON SI PUBBLICA PIÙ, NÉ IN MEZZO NÉ IN CODA.
      --    La A4 l'aveva spostata dopo la chiusura narrativa e questo bastava
      --    a togliere il difetto dell'INTERRUZIONE, non quello che Antonello
      --    aveva segnalato: «l'esito dev'essere prosa uniforme dal principio
      --    alla fine». Un tag `((Riuji → Kazane · Colpo · 0 m))` in fondo al
      --    messaggio resta un referto tecnico dentro la chat, e resta la cosa
      --    che rompe la voce del Narratore.
      --
      -- 🟢 `v_app` NON sparisce: continua a essere calcolata e finisce
      --    integra dentro `v_referto.appendice`, che è l'audit. Cambia solo
      --    che cosa vede il giocatore. Il referto autoritativo non si perde —
      --    era il vincolo esplicito della review.
      v_testo := regexp_replace(
        concat_ws(' ', public._esame_chiudi(v_az), public._esame_chiudi(v_frase)),
        '[[:space:]]+', ' ', 'g');
    else
      -- Il PNG aveva attaccato: l'AZIONE è già in chat da minuti, e qui esce
      -- soltanto l'ESITO — dalla STESSA risposta modello, senza una seconda
      -- chiamata. È il §4 del contratto.
      -- [A5] anche qui: solo prosa. L'appendice vive nel referto.
      v_testo := regexp_replace(
        public._esame_chiudi(v_frase),
        '[[:space:]]+', ' ', 'g');
    end if;
    -- [095/27] L'esito di una difesa del candidato non viene pubblicato
    -- prima che il Narratore abbia ricevuto il testo reale della difesa.
    v_mid := null;
  end if;

  -- La ricevuta si CONSUMA: una seconda difesa non può pubblicare un secondo
  -- ESITO (gate E-25).
  --
  -- ⚠️ CORREZIONE DEL BANCO (inversione D7a). La prima stesura di questo
  --    commento diceva che `where stato in (…)` era «la condizione che rende
  --    l'aggiornamento idempotente». È FALSO, e l'inversione lo ha dimostrato:
  --    toglierla non accende niente, perché la SELECT che carica `v_ciclo`
  --    dieci righe più su filtra GIÀ sugli stessi due stati — quindi qui la
  --    riga è codice morto difensivo, non la guardia.
  --    La guardia vera è quella SELECT, insieme al `for update` sulla prova.
  --    La riga resta perché costa nulla e protegge da una riscrittura futura
  --    della SELECT, ma chiamarla «la condizione» era esattamente il genere di
  --    commento che fa cercare il difetto nel posto sbagliato.
  -- ── il REFERTO: i fatti chiusi, senza un solo numero autoritativo ──────
  if v_reaz = 'sostituzione' then
    v_et := 'Sostituzione · ' || coalesce(
      v_sost_comune#>>'{narrator_projection,anchor_semantic_label}',
      'ancora autorizzata'
    );
  else
    select e->>'nome' into v_et
      from jsonb_array_elements(
             public._esame_prova_opzioni(p_prova,
               case when v_png_att then 'candidato' else 'png' end)->'reazioni') e
     where e->>'chiave' = v_reaz;
  end if;

  v_spatial_after:=coalesce(v_spatial_after,public._esame_spatial_snapshot_v1(p_prova));
  v_spatial_start:=public._esame_spatial_snapshot_version_v1(p_prova,
    coalesce((v_att->>'spatial_before_version')::int,(v_spatial_before->>'map_version')::int));
  select se.event_id into strict v_spatial_event from combat_spatial.spatial_events se
    where se.instance_id=(v_spatial_after->>'instance_id')::uuid
      and (se.after_state->'exam_spatial'->>'map_version')::int=(v_spatial_after->>'map_version')::int;
  v_movimento := coalesce(nullif(concat_ws('; ',
    case when v_spatial_start->'candidate' is distinct from v_spatial_after->'candidate'
      then v_c.name||' ha cambiato posizione' end,
    case when v_spatial_start->'png' is distinct from v_spatial_after->'png'
      then v_prof.nome||' ha cambiato posizione' end), ''), 'nessuno');
  v_dist_lab := case when v_dist <= 2 then 'a contatto'
                     when v_dist <= 10 then 'a corta distanza'
                     when v_dist <= 30 then 'a media distanza'
                     else 'a lunga distanza' end;
  v_danno_lab := case when v_ko then 'fuori combattimento'
                      when v_appl = 0 then 'nessuno'
                      when v_appl <= greatest(1, v_pv_max / 10) then 'lieve'
                      when v_appl <= greatest(1, v_pv_max / 4) then 'serio'
                      else 'grave' end;
  v_referto := jsonb_build_object(
    '_spatial_audit',jsonb_build_object('scambio_id',v_scambio_id,'event_id',v_spatial_event,
      'before_version',v_spatial_start->'map_version','impact_version',v_spatial_before->'map_version',
      'after_version',v_spatial_after->'map_version'),
    'ruolo_png',      v_ruolo_png,
    'attaccante',     v_nome_att,
    'difensore',      v_nome_dif,
    'tecnica',        v_tech,
    'genere_attacco', v_kind,
    'reazione',       v_reaz,
    'reazione_nome',  coalesce(v_et, 'una reazione'),
    'esito',          v_esito,
    'colpito',        v_colpito,
    'di_striscio',    v_striscio,
    'fuori_combattimento', v_ko,
    'danno',          v_danno_lab,
    'distanza',       v_dist_lab,
    'appendice',      nullif(btrim(coalesce(v_app,'')),''),
    -- [001] la ricevuta arricchita (P1): fatti del server, solo parole.
    'bersaglio',      v_zona,
    'bersaglio_su',   case when v_esito_copie = 'copia_colpita' then 'una copia di ' || v_nome_dif else v_nome_dif end,
    'conseguenza',    v_conseg,
    'gravita',        v_grav,
    'postura_difensore', case when v_colpito or v_ko then public._esame_postura(v_danno_lab, v_ko) else 'in guardia' end,
    'movimento',      v_movimento,
    'iniziativa',     case when v_png_att then 'passa a ' || v_nome_dif else 'passa a ' || v_nome_att end,
    'scambio',        case v.scambio when 1 then 'primo' when 2 then 'secondo' when 3 then 'terzo' else 'ultimo' end,
    'ancora',         v_ancora,
    'segni',          public._esame_segni(p_prova, v_ordine));

  if v_ciclo.id is not null then
    update public.esame_narrazione_cicli
       -- [090-CICLI:2:INIZIO]
     -- Se il motore ha prodotto un esito che l'elenco congelato non
     -- prevedeva, l'elenco si AMPLIA invece di far saltare la transazione.
     -- L'esito e' legittimo per costruzione: viene da `_esame_esiti_reazione`
     -- della reazione davvero giocata. Il CHECK resta severo com'era:
     -- cambia chi lo rispetta, non quanto e' severo.
     -- ⚠️ Nella stessa UPDATE il lato destro legge la riga VECCHIA, quindi
     --    `esiti_attesi` qui e' ancora quello di prima: ed e' cio' che serve.
     -- ⚠️ `array_append` e non `esiti_attesi || v_esito`: Postgres legge il
     --    secondo come array||array e fallisce con «malformed array literal».
     --    E' la trappola §3 delle convenzioni, ripresa in flagrante dal banco.
     set stato = 'risolta',
         esiti_attesi = case when v_esito = any(esiti_attesi) then esiti_attesi
                             else (select array_agg(distinct x order by x)
                                     from unnest(array_append(esiti_attesi, v_esito)) x) end,
         esiti_ampliati = esiti_ampliati or not (v_esito = any(esiti_attesi)),
         esito_reale = v_esito, referto = v_referto,
     -- [090-CICLI:2:FINE]
           testo_esito = nullif(btrim(v_testo),'') ,
           result_message_id = coalesce(v_mid, result_message_id),
           resolved_at = now()
     where id = v_ciclo.id and stato in ('accettata','ripiego');
  end if;

  -- ── avanzamento della macchina a stati (§5.2) ───────────────────────────
  v_scambio_risolto := v.scambio;
  update public.esame_prove set
    pv_cand = case when v_png_att then v_pv else pv_cand end,
    pv_png  = case when v_png_att then pv_png else v_pv end,
    slancio_cand = case when v_png_att then slancio_cand else v_slancio_next end,
    slancio_png  = case when v_png_att then v_slancio_next else slancio_png end,
    -- Sostituzione e relativo cooldown sono gia committati dalla porta comune.
    sost_round_cand = sost_round_cand,
    sost_round_png  = sost_round_png,
    sost_usata_cand = sost_usata_cand,
    ck_cand = case when v_png_att and v_reaz = 'tecnica' then greatest(0, ck_cand - v_ck_reaz)
                   when (not v_png_att) then greatest(0, ck_cand - v_ck_costo) else ck_cand end,
    ck_png  = case when (not v_png_att) and v_reaz = 'tecnica' then greatest(0, ck_png  - v_ck_reaz)
                   when v_png_att then greatest(0, ck_png - v_ck_costo) else ck_png end,
    tecnica_png_usata = tecnica_png_usata or (v_png_att and v_kind <> 'fisico'),
    -- Il primo attacco diretto consuma le copie del difensore, anche quando
    -- sceglie Schivata, Parata o Sostituzione.
    copie_attive_cand = case
      when v_png_att then false
      when v_assalto then false
      else copie_attive_cand end,
    copie_attive_png  = case when v_png_att then copie_attive_png else false end,
    copie_n_cand = case
      when v_png_att then 0
      when v_assalto then 0
      else copie_n_cand end,
    copie_n_png  = case when v_png_att then copie_n_png else 0 end,
    copie_scambio_cand = case
      when v_png_att then null
      when v_assalto then null
      else copie_scambio_cand end,
    copie_scambio_png  = case when v_png_att then copie_scambio_png else null end,
    copie_salvate_cand = copie_salvate_cand
      + case when v_png_att and v_esito_copie = 'copia_colpita' then 1 else 0 end,
    pend_azione = null,
    opzioni_png = null, opzioni_id = null, opzioni_at = null,
    usato_principale = false, usato_rapida = false, usato_spostamento = false,
    -- fine della metà: se attaccava il candidato tocca al PNG, altrimenti si
    -- chiude lo scambio e si sale di gradino.
    meta    = case when v_png_att then 'candidato' else 'png' end,
    fase    = 'attacco',
    scambio = case when v_png_att then least(4, v.scambio + 1) else v.scambio end,
    beat    = case when v_png_att then least(4, v.scambio + 1) else v.beat end,
    -- Le colonne Guardia sono storiche: non vengono più scritte.
    guardia_cand = guardia_cand,
    guardia_png  = guardia_png
  where id = p_prova;

  -- KO simulato o QUARTO scambio finito: si chiude come «done», non come persa.
  -- (Il contratto è a quattro round: vedi `di_scambi` in `_esame_stato_json` e
  --  il vincolo `esame_prove_scambio_beat`, allargato a 1..4 dal §7.)
  -- Si rilegge la fotografia DOPO costi e danni: il chakra arrivato a zero
  -- è una condizione terminale tanto quanto i PV, anche se l'ultimo colpo non
  -- ha prodotto un KO fisico.
  select * into v from public.esame_prove where id=p_prova;
  v_finale := v.pv_cand<=0 or v.pv_png<=0 or v.ck_cand<=0 or v.ck_png<=0
               or (v_png_att and v_scambio_risolto>=4);

  if v_finale then
    v_finale_tipo := case
      when v.pv_cand<=0 or v.pv_png<=0 or v.ck_cand<=0 or v.ck_png<=0
        then 'sfinimento'
      else 'quattro_round' end;
    v_senza_forze := coalesce((select jsonb_agg(nome order by nome) from (
      select v_c.name nome where v.pv_cand<=0 or v.ck_cand<=0
      union all
      select v_prof.nome where v.pv_png<=0 or v.ck_png<=0
    ) q),'[]'::jsonb);
    v_referto := v_referto || jsonb_build_object(
      'finale_tipo',v_finale_tipo,
      'senza_forze',v_senza_forze,
      'chiusura_richiesta','ultimo esito e intervento del Sensei nello stesso racconto',
      'iniziativa','la prova si chiude');

    v_esito_ciclo := gen_random_uuid();
    v_esito_ricevuta := gen_random_uuid();
    insert into public.esame_narrazione_cicli
      (id,prova_id,opzioni_id,ruolo,stato,pg_message_id,
       esiti,esiti_attesi,testo_esito,referto,created_at)
    values
      (v_esito_ciclo,p_prova,v_esito_ricevuta,'png_finale','aperta',
       (select pg_message_id from public.esame_prove where id=p_prova),
       '{}'::jsonb,array[]::text[],nullif(btrim(v_testo),''),v_referto,now());
    update public.esame_prove set
      meta='narratore', fase='finale', pend_azione=null,
      opzioni_id=v_esito_ricevuta, opzioni_at=now(),
      opzioni_png=jsonb_build_object('intenzioni',jsonb_build_array(jsonb_build_object(
        'intenzione_id','narra_finale','chiave','narra_finale',
        'etichetta','Concludi l''Esame','genere','finale',
        'esiti_possibili','[]'::jsonb)))
    where id=p_prova;
  elsif v_png_att then
    -- La meccanica è già chiusa e il candidato avrebbe di nuovo l'offensiva,
    -- ma l'azione resta bloccata finché questo esito non è stato pubblicato.
    v_esito_ciclo := gen_random_uuid();
    v_esito_ricevuta := gen_random_uuid();
    insert into public.esame_narrazione_cicli
      (id,prova_id,opzioni_id,ruolo,stato,pg_message_id,
       esiti,esiti_attesi,testo_esito,referto,created_at)
    values
      (v_esito_ciclo,p_prova,v_esito_ricevuta,'png_esito','aperta',
       (select pg_message_id from public.esame_prove where id=p_prova),
       '{}'::jsonb,array[]::text[],nullif(btrim(v_testo),''),v_referto,now());
    update public.esame_prove set
      opzioni_id=v_esito_ricevuta, opzioni_at=now(),
      opzioni_png=jsonb_build_object('intenzioni',jsonb_build_array(jsonb_build_object(
        'intenzione_id','narra_esito','chiave','narra_esito',
        'etichetta','Racconta l''esito della difesa','genere','esito',
        'esiti_possibili','[]'::jsonb)))
    where id=p_prova;
  else
    perform public._esame_png_turno(p_prova);
  end if;

  return jsonb_build_object('versione',1,'ordine',v_ordine,'esito',v_esito,
                            'esito_copie',v_esito_copie,
                            'colpito',v_colpito,'striscio',v_striscio,'danno',v_appl,
                            'spatial_receipt',case when v_reaz = 'sostituzione'
                              then v_sost_comune else null end);
end
$function$;


-- SOURCE candidato/full_body/_esame_spazio_json.sql
CREATE OR REPLACE FUNCTION public._esame_spazio_json(p_prova uuid, p_rivela boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_fig jsonb;
  v_spatial jsonb;
begin
  select * into v from public.esame_prove where id = p_prova;
  if not found then return null; end if;
  v_spatial:=public._esame_spatial_snapshot_v1(p_prova);
  if v_spatial is not null then
    if v.figure_cand is not null then raise exception 'OPEN_EXAM_SPATIAL_LEGACY_FIGURES'; end if;
    return jsonb_build_object('unita','metri','autorita','arena',
      'candidato',jsonb_build_object('nome_noto',true,'riferimento','candidato'),
      'avversario',jsonb_build_object('riferimento','avversario'),
      'distanza_m',(v_spatial->>'distance_m')::numeric,
      'figure','[]'::jsonb,'originale_rivelato',false);
  end if;

  if v.figure_cand is null then
    -- Nessuna figura: la scena e' due corpi e la distanza fra loro.
    return jsonb_build_object(
      'unita','metri',
      'candidato', jsonb_build_object('nome_noto',true,'posizione_m',v.pos_candidato),
      'avversario',jsonb_build_object('posizione_m',v.pos_png),
      'distanza_m', abs(v.pos_png - v.pos_candidato),
      'figure', '[]'::jsonb,
      'originale_rivelato', false);
  end if;

  select jsonb_agg(x order by (x->>'posizione_m')::int, (x->>'etichetta'))
    into v_fig
    from (
      select jsonb_build_object(
               'etichetta', 'figura ' || row_number() over (order by (e->>'pos')::int),
               'posizione_m', (e->>'pos')::int,
               'distanza_da_avversario_m', abs(v.pos_png - (e->>'pos')::int),
               'e_originale',
                 case when p_rivela and (e->>'idx')::int = v.originale_cand then true
                      when p_rivela then false
                      else null end
             ) as x
        from jsonb_array_elements(v.figure_cand) e
    ) s;

  return jsonb_build_object(
    'unita','metri',
    'candidato',  jsonb_build_object('figure_indistinguibili', not coalesce(p_rivela,false)),
    'avversario', jsonb_build_object('posizione_m', v.pos_png),
    'figure', coalesce(v_fig,'[]'::jsonb),
    'distanza_minima_m', (select min(abs(v.pos_png - (e->>'pos')::int))
                            from jsonb_array_elements(v.figure_cand) e),
    'distanza_massima_m', (select max(abs(v.pos_png - (e->>'pos')::int))
                            from jsonb_array_elements(v.figure_cand) e),
    'originale_rivelato', coalesce(p_rivela,false));
end
$function$;


-- SOURCE candidato/full_body/_esame_stato_asof.sql
CREATE OR REPLACE FUNCTION public._esame_stato_asof(v esame_prove, p_asof timestamp with time zone)
 RETURNS esame_prove
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'public'
AS $function$
declare
  r record; last public.esame_scambi%rowtype; n int;
begin
  select coalesce(sum(case when chi_attacca = 'png' then danno_applicato else 0 end),0) as d_cand,
         coalesce(sum(case when chi_attacca <> 'png' then danno_applicato else 0 end),0) as d_png,
         coalesce(sum(case when chi_attacca = 'png' then chakra_dichiarato else 0 end),0) as ck_png,
         coalesce(sum(case when chi_attacca <> 'png' then chakra_dichiarato else 0 end),0) as ck_cand,
         count(*) as n
    into r
    from public.esame_scambi s where s.prova_id = v.id and s.created_at <= p_asof;
  select * into last from public.esame_scambi s where s.prova_id = v.id and s.created_at <= p_asof
   order by s.ordine desc limit 1;
  v.pv_cand := greatest(0, v.pv_cand_max - r.d_cand);
  v.pv_png  := greatest(0, v.pv_png_max  - r.d_png);
  v.ck_cand := greatest(0, v.ck_cand_max - r.ck_cand);
  v.ck_png  := greatest(0, v.ck_png_max  - r.ck_png);
  if last.id is not null then
    v.pos_candidato := last.pos_cand; v.pos_png := last.pos_png;
    -- dopo uno scambio risolto: se attaccava il png, tocca al candidato allo scambio dopo
    v.scambio := case when last.chi_attacca = 'png' then least(4, last.scambio + 1) else last.scambio end;
    v.meta    := case when last.chi_attacca = 'png' then 'candidato' else 'png' end;
  else
    v.pos_candidato := 2; v.pos_png := 7; v.scambio := 1; v.meta := 'candidato';
  end if;
  v.fase := 'attacco'; v.copie_attive_png := false; v.copie_attive_cand := false;
  v.figure_cand := null; v.originale_cand := null; v.copie_n_cand := 0;
  if public._esame_spatial_snapshot_v1(v.id) is not null then
    -- La rowtype legacy non può rappresentare due coordinate: i consumer
    -- spaziali leggono _snapshot_asof, mai questi scalari come autorità.
    v.pos_candidato:=null; v.pos_png:=null;
  end if;
  return v;
end
$function$;


-- SOURCE candidato/full_body/_esame_stato_json.sql
CREATE OR REPLACE FUNCTION public._esame_stato_json(p_prova uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype; v_prof public.esame_png_profili%rowtype;
  v_c public.characters%rowtype; v_mio boolean; v_dist numeric; v_spatial jsonb;
begin
  select * into v from public.esame_prove where id = p_prova;
  if not found then raise exception 'La prova non esiste più'; end if;
  select * into v_prof from public.esame_png_profili where id = v.profilo_id;
  select * into v_c from public.characters where id = v.candidate_character;
  v_spatial:=public._esame_spatial_snapshot_v1(p_prova);
  v_dist := case when v_spatial is null then abs(v.pos_png-v.pos_candidato)
                 else (v_spatial->>'distance_m')::numeric end;
  v_mio  := (v.stato = 'aperta') and ((v.meta = 'candidato' and v.fase in ('attacco','uscita'))
                                   or (v.meta = 'png' and v.fase = 'difesa'));

  return jsonb_build_object(
    'versione', 1,
    'prova', jsonb_build_object(
      'id', v.id, 'stato', v.stato, 'scambio', v.scambio, 'di_scambi', 4,
      'meta', v.meta, 'fase', v.fase, 'beat', v.beat,
      'tuo_turno', v_mio,
      'azione_richiesta', case when v.fase='uscita' then 'uscita'
                               when v.meta = 'png' and v.fase = 'difesa' then 'reazione'
                               else 'principale' end),
    'io', jsonb_build_object(
      'nome', v_c.name, 'pos', case when v_spatial is null then v.pos_candidato end,
      'pv', v.pv_cand, 'pv_max', v.pv_cand_max,
      'ck', v.ck_cand, 'ck_max', v.ck_cand_max,
      'slancio', v.slancio_cand,
      'copie_attive', coalesce(v.copie_attive_cand,false),
      'speso', jsonb_build_object(
        'principale', v.usato_principale and v.meta = 'candidato',
        'rapida',     false,
        'spostamento',v.usato_spostamento and v.meta = 'candidato')),
    'avversario', jsonb_build_object(
      'nome', v_prof.nome, 'pos', case when v_spatial is null then v.pos_png end,
      'pv', null, 'pv_max', null, 'ck', null, 'ck_max', null),
    'distanza', v_dist,
    'fascia', case when v_dist <= 2 then 'a contatto' when v_dist <= 10 then 'corta'
                   when v_dist <= 30 then 'media' else 'lunga' end,
    'opzioni', case when v.stato = 'aperta' and v.fase<>'uscita'
                    then public._esame_prova_opzioni(p_prova,'candidato')
                    else '{}'::jsonb end,
    'narrazione_attesa', (v.stato = 'aperta' and not v_mio),
    'ia_degradata', v.ia_degradata);
end
$function$;


-- SOURCE candidato/full_body/esame_prova_apri.sql
CREATE OR REPLACE FUNCTION public.esame_prova_apri(p_session uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid uuid := auth.uid();
  v_sess record; v_c public.characters%rowtype; v_prof uuid;
  v_vill text; v_passo int; v_prova uuid; v_loc uuid;
  v_pvm int; v_ckm int; v_seme bigint; v_pp public.esame_png_profili%rowtype;
  v_sensei_name text; v_sensei_titolo text; v_sensei_registro text;
  v_spatial jsonb;
begin
  if v_uid is null then raise exception 'non autenticato'; end if;

  select * into v_c from public.characters where user_id = v_uid limit 1;
  if v_c.id is null then raise exception 'Ti serve un personaggio'; end if;

  select s.*, l.is_exam, l.id as lid into v_sess
    from public.academy_class_sessions s
    join public.academy_lessons l on l.id = s.lesson_id
   where s.id = p_session;
  if not found or not coalesce(v_sess.is_exam,false) then
    raise exception 'Questa non è la tua prova';
  end if;
  if not exists (select 1 from public.academy_class_participants p
                  where p.session_id = p_session and p.user_id = v_uid and p.kind = 'student') then
    raise exception 'Questa non è la tua prova';
  end if;
  v_loc := v_sess.location_id;

  -- Idempotenza (§13a): un secondo invio ritrova la prova aperta e NON riesegue
  -- la selezione. L'indice unico parziale del §1.2 lo garantisce anche sotto
  -- doppio invio simultaneo.
  select id into v_prova from public.esame_prove
   where class_session_id = p_session and stato = 'aperta' limit 1;
  if v_prova is not null then
    return public._esame_stato_json(v_prova);
  end if;

  -- La prova applicata è l'ULTIMO passo valutabile del copione: si deriva dai
  -- dati, non da un numero magico. Con il copione di oggi è il passo 4.
  select max(sc.step) into v_passo
    from public.academy_lesson_script sc
   where sc.lesson_id = v_sess.lesson_id and coalesce(sc.valuta,false)
     and lower(btrim(sc.village)) = coalesce(nullif(lower(btrim(v_sess.village)),''),'konoha');
  if v_sess.state = 'closed' or v_passo is null then
    raise exception 'La prova non è ancora il passo di questo esame';
  end if;

  -- [108] Una sessione EXAM non svolge la scaletta dell'Accademia: viene
  -- portata sul passo valutativo nella stessa transazione che apre la prova.
  -- L'UPDATE è limitato alla sessione già autenticata dal controllo del
  -- partecipante qui sopra e non riapre mai una sessione chiusa.
  if v_sess.state <> 'teaching' or coalesce(v_sess.step,0) <> v_passo then
    update public.academy_class_sessions
       set state='teaching',
           step=v_passo,
           step_at=now()+interval '24 hours',
           ai_blocked_at=coalesce(ai_blocked_at,now()),
           ai_block_reason=coalesce(ai_block_reason,'staff')
     where id=p_session and state<>'closed';
    if not found then
      raise exception 'La prova non è ancora il passo di questo esame';
    end if;
    v_sess.state := 'teaching';
    v_sess.step := v_passo;
  end if;

  -- ⚠️ locations.region è minuscolo, characters.village è maiuscolo: senza
  --    lower() da entrambe le parti l'insieme dei profili è SEMPRE vuoto.
  v_vill := lower(btrim(coalesce(v_c.village,'')));
  -- [A10 §A] La sessione QA ha un avversario CONCORDATO. Fuori da
  -- quell'unico id l'elenco è vuoto e si torna al selettore di sempre:
  -- la rotazione pubblica non cambia di una riga.
  v_prof := public._esame_qa_avversario(p_session);
  if v_prof is not null then
    -- Un avversario concordato che non fosse più giocabile NON deve
    -- degradare in silenzio nel primo della rotazione: è esattamente il
    -- difetto che questa sezione toglie. Si dice, e ci si ferma.
    if not exists (select 1 from public.esame_png_profili p
                    where p.id = v_prof and p.is_active
                      and p.villaggio = v_vill) then
      raise exception 'QA: l''avversario concordato non è disponibile per questo villaggio';
    end if;
  else
    v_prof := public._esame_profilo_scegli(v_vill);
  end if;
  if v_prof is null then raise exception 'Non c''è nessun avversario disponibile'; end if;
  select * into v_pp from public.esame_png_profili where id = v_prof;

  -- Il Sensei e' una presenza narrativa dell'incipit, non un secondo agente
  -- che interviene durante la prova. La scelta e' stabile per sessione e usa
  -- la scheda viva del villaggio.
  select a.name, a.persona->>'titolo', a.persona->>'registro'
    into v_sensei_name, v_sensei_titolo, v_sensei_registro
    from public.ai_agents a
   where a.kind='sensei' and a.is_active
     and lower(btrim(a.village))=v_vill
   order by md5(p_session::text || a.id::text)
   limit 1;
  if v_sensei_name is null then
    raise exception 'Nessun Sensei disponibile per introdurre la prova';
  end if;

  -- Le risorse simulate partono dai MASSIMI, non dai valori correnti: chi
  -- arriva all'esame ferito non deve essere punito da una prova che non toglie
  -- niente di vero, e SIM-002 ha bisogno di condizioni iniziali fisse.
  -- Una formula sola, quella del regolamento.
  v_pvm := public.calc_vita_max(v_c.resistenza, v_c.rank);
  v_ckm := public.calc_chakra_max(v_c.ninjutsu, v_c.mente, v_c.rank);

  -- Il seme è deterministico sulle coordinate della prova: nessun random(),
  -- nessun clock_timestamp(). Una prova rieseguita con lo stesso seme e le
  -- stesse scelte dà gli stessi numeri, ed è un controllo del banco.
  v_seme := ((hashtextextended(p_session::text || '·' || v_c.id::text, 0) % 2147483647) + 2147483647) % 2147483647;

  insert into public.esame_prove (
    class_session_id, candidate_user, candidate_character, profilo_id,
    pos_candidato, pos_png,
    pv_cand, pv_cand_max, ck_cand, ck_cand_max,
    pv_png,  pv_png_max,  ck_png,  ck_png_max,
    seme)
  values (
    p_session, v_uid, v_c.id, v_prof,
    2, 7,                                        -- [001] ingaggio a cinque metri, dentro il tatami di dieci
    v_pvm, v_pvm, v_ckm, v_ckm,
    v_pp.vita_max, v_pp.vita_max, v_pp.chakra_max, v_pp.chakra_max,
    v_seme)
  returning id into v_prova;

  v_spatial:=public._esame_spatial_prepare_v1(v_prova);

  -- La riga di sistema all'apertura, scritta dal SERVER e non dall'IA, fra
  -- doppie parentesi come ammette la convenzione. Il testo esatto è di
  -- RULES-LORE: questo è quello proposto al §9 del contratto.
  insert into public.messages (location_id, character_id, sender_user, author_name, body, kind)
  values (v_loc, null, null, 'Sistema',
    '((Nella prova si combatte a pieni valori. I tuoi punti veri non cambiano: qui non si perde nulla.))',
    'sistema');

  perform public._esame_narratore_post(v_loc,
    case when v_spatial is not null then format(
      '%s %s e %s prendono posto nelle posizioni iniziali dell''arena. %s dà il via alla prova: «Mostrate ciò che avete imparato». [Turni: %s-%s]',
      public._esame_aula_incipit(v_vill),v_c.name,v_pp.nome,v_sensei_name,v_c.name,v_pp.nome)
    else
    format($incipit$%s %s e %s prendono posto uno di fronte all'altro, separati da cinque metri, e il suono dei loro passi si spegne prima dell'inizio. %s "Le regole sono semplici: per ottenere il grado dovete saper dimostrare quello che avete imparato. Se lo riterro' opportuno, fermero' l'esame in qualsiasi momento." Cosi' enuncia prima di dare il via con un gesto ai due deshi che si trovano a cinque metri di distanza l'uno dall'altro. Questa e' la prova finale dell'Accademia, l'Esame Genin nella sua essenza: non sara' la sola vittoria a decidere il valore di quanto accadra', ma cio' che ciascun deshi sapra' mostrare di quello che ha imparato e del talento che possiede. [Turni: %s-%s]$incipit$,
      public._esame_aula_incipit(v_vill),
      v_c.name,v_pp.nome,
      case lower(v_sensei_name)
        when 'ibara' then 'Ibara, la Vipera del deserto, li osserva immobile con le mani giunte davanti e lo sguardo chiaro fermo sui due deshi.'
        when 'rentaro' then 'Rentaro, il maestro esploratore, li osserva con un mezzo sorriso ironico e gli occhi vivaci stretti come sotto il sole.'
        else format('%s, %s, li osserva in silenzio.',v_sensei_name,coalesce(v_sensei_titolo,'Sensei dell''Accademia'))
      end,
      v_c.name,v_pp.nome) end);

  return public._esame_stato_json(v_prova);
end
$function$;


-- SOURCE candidato/full_body/narrative_surface_seed_exam.sql
CREATE OR REPLACE FUNCTION public.narrative_surface_seed_exam(p_prova uuid, p_attempt_no integer DEFAULT 1)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  r record;
  v public.esame_prove%rowtype;
  c public.esame_narrazione_cicli%rowtype;
  p public.esame_png_profili%rowtype;
  v_agent_persona jsonb;
  v_candidate_name text;
  v_png_name text;
  v_action_text text;
  v_location_id uuid;
  v_location_region text;
  v_active_cycles integer;
  v_int jsonb;
  v_engine_options jsonb;
  v_outcome text;
  v_intent_id text;
  v_intent_fact text;
  v_action text;
  v_kind text;
  v_principal text;
  v_movement jsonb;
  v_movement_fact text;
  v_start_distance numeric;
  v_end_distance numeric;
  v_move_meters numeric;
  v_spatial jsonb; v_preview jsonb;
  v_capacity_meters integer;
  v_attack_range integer;
  v_outcome_text text;
  v_actor text;
  v_target text;
  v_prior_outcome text;
  v_prior_fact text;
  v_intents jsonb := '[]'::jsonb;
  v_facts jsonb := '[]'::jsonb;
  v_dialogues jsonb;
  v_utterances jsonb;
  v_continuity jsonb := '[]'::jsonb;
  v_environment jsonb;
  v_recent jsonb;
  v_components jsonb := '[]'::jsonb;
  v_state_version text;
begin
  if p_attempt_no is distinct from 1 then
    raise exception using errcode='22023', message='il Surface Realizer ammette una sola generazione per ciclo';
  end if;

  select count(*) into v_active_cycles
    from public.esame_narrazione_cicli x
   where x.prova_id=p_prova and x.stato='aperta';
  if v_active_cycles <> 1 then
    raise exception using errcode='55000', message='fotografia narrativa Exam non univoca';
  end if;

  select ep as prova, enc as ciclo, epp as profilo, aa.persona as agent_persona,
         public._narrative_surface_label(ch.name,'il candidato') as candidate_name,
         public._narrative_surface_label(epp.nome,'l''avversario') as png_name,
         m.body as action_text, acs.location_id, l.region as location_region
    into r
    from public.esame_prove ep
    join public.esame_narrazione_cicli enc
      on enc.prova_id=ep.id and enc.stato='aperta'
    join public.esame_png_profili epp
      on epp.id=ep.profilo_id and epp.is_active is true
    join public.ai_agents aa
      on aa.id=epp.agent_id and aa.is_active is true
    join public.characters ch
      on ch.id=ep.candidate_character and ch.user_id=ep.candidate_user
    join public.academy_class_sessions acs
      on acs.id=ep.class_session_id
    join public.locations l
      on l.id=acs.location_id and l.is_active is true and (l.is_exam_room is true or public._ai_narrative_exam_qa_seed_location_allowed_131m(ep.id,l.id))
    join public.messages m
      on m.id=enc.pg_message_id
     and m.character_id=ep.candidate_character
     and m.sender_user=ep.candidate_user
     and m.location_id=acs.location_id
     and m.kind = 'say'
   where ep.id=p_prova and ep.stato='aperta';
  if not found then
    raise exception using errcode='P0002', message='fotografia Exam o azione PG non disponibile';
  end if;
  v := r.prova;
  c := r.ciclo;
  p := r.profilo;
  v_agent_persona := r.agent_persona;
  v_candidate_name := r.candidate_name;
  v_png_name := r.png_name;
  v_action_text := r.action_text;
  v_location_id := r.location_id;
  v_location_region := r.location_region;
  if c.opzioni_id is null or c.ruolo not in ('png_difende','png_attacca','png_esito','png_finale') then
    raise exception using errcode='55000', message='receipt o ruolo Exam non conforme';
  end if;
  if length(v_action_text) > 5000 then
    raise exception using errcode='22001', message='azione PG oltre il limite';
  end if;

  v_utterances := public._narrative_exam_utterances(v_action_text);
  v_prior_outcome := c.referto->>'esito';
  v_prior_fact := case when c.ruolo in ('png_esito','png_finale') then 'fact.resolved.' else 'fact.prior.' end || coalesce(v_prior_outcome,'exchange');
  v_outcome_text := public._narrative_exam_outcome_text(v_prior_outcome);
  if v_outcome_text is null then
    raise exception using errcode='22023', message='referto Exam non mappato';
  end if;
  v_actor := case when coalesce(c.referto->>'ruolo_png','png_difende')='png_attacca' then 'actor.png' else 'actor.candidate' end;
  v_target := case when v_actor='actor.png' then 'actor.candidate' else 'actor.png' end;

  v_facts := jsonb_build_array(
    jsonb_build_object(
      'id','fact.environment.exam','status','server_fact','actor_ref','place.tatami','target_ref',null,
      'action','l''aula d''esame contiene un tatami libero al centro','surface_permissions',jsonb_build_array('environment')
    ),
    jsonb_build_object(
      'id',v_prior_fact,'status','server_fact','actor_ref',v_actor,'target_ref',v_target,
      'action',v_outcome_text,'surface_permissions',jsonb_build_array('body_response','recovery','fatigue','emotion')
    )
  );

  if c.ruolo in ('png_difende','png_attacca') then
    -- La fotografia delle opzioni resta autoritativa. Per l'attacco usiamo
    -- anche il repertorio calcolato dal server per ricavare la portata della
    -- principale: nessun metro, direzione o contatto viene chiesto al modello.
    select coalesce(max((x->>'metri')::integer),0)
      into v_capacity_meters
      from jsonb_array_elements(coalesce(v.opzioni_png->'intenzioni','[]'::jsonb)) x
     where x->>'movimento' in ('avanti','indietro')
       and coalesce(x->>'metri','') ~ '^[0-9]+$';
    v_spatial:=public._esame_spatial_snapshot_v1(p_prova);
    v_start_distance := case when v_spatial is null then abs(v.pos_png-v.pos_candidato)
                             else (v_spatial->>'distance_m')::numeric end;

    for v_int in
      select value from jsonb_array_elements(coalesce(v.opzioni_png->'intenzioni','[]'::jsonb))
    loop
      v_kind := v_int->>'genere';
      v_principal := v_int->>'principale';

      -- Simmetria PG/PNG ratificata: nella metà offensiva entrano nel seed
      -- soltanto attacchi reali già offerti dal motore. Manovra e diversivo
      -- restano al fallback autoritativo, ma non diventano un'intenzione
      -- narrativa autonoma alternativa all'attacco.
      if c.ruolo='png_attacca' and (v_kind<>'turno' or v_principal is null) then
        continue;
      end if;
      -- In difesa non esiste movimento libero: sono ammesse soltanto le
      -- reazioni chiuse offerte dal motore.
      if c.ruolo='png_difende' then
        if v_kind<>'reazione' then continue; end if;
        if v_int->>'movimento' is not null or v_int->>'metri' is not null
           or v_principal is not null then
          raise exception using errcode='22023', message='reazione Exam contaminata da movimento o principale';
        end if;
      end if;

      v_intent_id := v_int->>'intenzione_id';
      if v_intent_id is null or v_intent_id !~ '^[a-z][a-z0-9_.:-]{0,72}$' then
        raise exception using errcode='22023', message='intenzione Exam non conforme';
      end if;
      v_intent_id := 'intent.' || v_intent_id;
      v_intent_fact := 'fact.' || v_intent_id;
      v_movement := null;
      v_movement_fact := null;

      if c.ruolo='png_attacca' then
        if v_principal='colpo' then
          v_attack_range := 2;
        else
          -- Il repertorio completo serve soltanto alle tecniche. Un colpo usa
          -- la portata canonica già chiusa dal motore e non provoca una
          -- seconda derivazione inutile della fotografia.
          if v_engine_options is null then
            v_engine_options := public._esame_prova_opzioni(p_prova,'png');
          end if;
          select (x->>'portata_m')::integer into v_attack_range
            from jsonb_array_elements(coalesce(v_engine_options->'principali','[]'::jsonb)) x
           where 'jutsu:' || (x->>'id') = v_principal
             and coalesce(x->>'portata_m','') ~ '^[0-9]+$'
           limit 1;
        end if;
        if v_attack_range is null or v_attack_range<0 then
          raise exception using errcode='22023', message='portata offensiva Exam non disponibile';
        end if;

        if v_int->>'movimento' is null then
          v_move_meters := 0;
          v_end_distance := v_start_distance;
        else
          if v_int->>'movimento' not in ('avanti','indietro')
             or coalesce(v_int->>'metri','') !~ '^[1-9][0-9]*$' then
            raise exception using errcode='22023', message='modificatore di movimento Exam non conforme';
          end if;
          v_move_meters := (v_int->>'metri')::integer;
          if v_move_meters>v_capacity_meters then
            raise exception using errcode='22023', message='movimento Exam oltre la capacità offerta dal server';
          end if;
          if v_spatial is not null then
            v_preview:=public._esame_spatial_move_preview_v1(p_prova,'png',v_move_meters,v_int->>'movimento'='avanti');
            if not (v_preview->>'available')::boolean then raise exception 'EXAM_SPATIAL_FROZEN_MOVEMENT_STALE'; end if;
            v_move_meters:=(v_preview->>'travelled_m')::numeric;
            v_end_distance:=(v_preview->>'distance_after_m')::numeric;
          else
          v_end_distance := case v_int->>'movimento'
            when 'avanti' then greatest(0,v_start_distance-v_move_meters)
            else v_start_distance+v_move_meters end;
          end if;
          v_movement_fact := v_intent_fact || '.movement';
          v_movement := jsonb_build_object(
            'fact_ref',v_movement_fact,
            'direction',v_int->>'movimento',
            'meters',v_move_meters,
            'capacity_meters',v_capacity_meters,
            'start_distance_meters',v_start_distance,
            'end_distance_meters',v_end_distance,
            'attack_range_meters',v_attack_range,
            'contact_reached',v_end_distance<=v_attack_range,
            'authority','server_frozen_option'
          );
        end if;

        -- Un'intenzione offensiva fuori portata non viene trasformata in una
        -- manovra narrativa: il producer fallisce chiuso e lascia il fallback
        -- server scegliere il percorso legale.
        if v_end_distance>v_attack_range then
          continue;
        end if;
        if v_movement_fact is not null then
          v_facts := v_facts || jsonb_build_array(jsonb_build_object(
            'id',v_movement_fact,'status','server_fact','actor_ref','actor.png','target_ref','actor.candidate',
            'action',case v_int->>'movimento'
              when 'avanti' then 'il PNG avanza di ' || v_move_meters || ' metri e porta la distanza da ' || v_start_distance || ' a ' || v_end_distance || ' metri'
              else 'il PNG arretra di ' || v_move_meters || ' metri e porta la distanza da ' || v_start_distance || ' a ' || v_end_distance || ' metri' end,
            'surface_permissions',jsonb_build_array('non_mechanical_motion','trajectory')
          ));
        end if;
      end if;

      v_action := lower(left(coalesce(nullif(btrim(v_int->>'etichetta'),''),'azione fisica offerta dal server'),120));
      v_facts := v_facts || jsonb_build_array(jsonb_build_object(
        'id',v_intent_fact,'status','npc_intention','actor_ref','actor.png','target_ref','actor.candidate',
        'action',v_action,
        'surface_permissions',case when c.ruolo='png_attacca'
          then jsonb_build_array('trajectory','anatomical_target','non_mechanical_motion','fatigue','emotion')
          else jsonb_build_array('body_response','recovery','non_mechanical_motion','fatigue','emotion') end
      ));
      declare
        v_outcomes jsonb := '[]'::jsonb;
      begin
        for v_outcome in select value from jsonb_array_elements_text(coalesce(v_int->'esiti_possibili','[]'::jsonb))
        loop
          v_outcome_text := public._narrative_exam_outcome_text(v_outcome);
          if v_outcome_text is null or v_outcome !~ '^[a-z][a-z0-9_]{0,40}$' then
            raise exception using errcode='22023', message='esito possibile Exam non mappato';
          end if;
          v_outcomes := v_outcomes || jsonb_build_array(v_outcome);
          if not exists (select 1 from jsonb_array_elements(v_facts) f where f->>'id'='fact.option.' || v_outcome) then
            v_facts := v_facts || jsonb_build_array(jsonb_build_object(
              'id','fact.option.' || v_outcome,'status','server_option',
              'actor_ref',case when c.ruolo='png_difende' then 'actor.candidate' else 'actor.png' end,
              'target_ref',case when c.ruolo='png_difende' then 'actor.png' else 'actor.candidate' end,
              'action',v_outcome_text,
              'surface_permissions',jsonb_build_array('body_response','recovery','fatigue')
            ));
          end if;
        end loop;
        v_intents := v_intents || jsonb_build_array(jsonb_build_object(
          'id',v_intent_id,
          'kind',case when c.ruolo='png_attacca' then 'offense' else 'defense' end,
          'fact_ref',v_intent_fact,
          'movement_modifier',v_movement,
          'requires_defense_handoff',c.ruolo='png_attacca',
          'outcome_ids',v_outcomes
        ));
      end;
    end loop;
    if jsonb_array_length(v_intents)=0 then
      raise exception using errcode='55000', message=case when c.ruolo='png_attacca'
        then 'nessun attacco offensivo reale Exam offerto'
        else 'nessuna reazione difensiva Exam offerta' end;
    end if;
  else
    v_intent_id := case when c.ruolo='png_finale' then 'intent.final' else 'intent.resolve' end;
    v_intents := jsonb_build_array(jsonb_build_object(
      'id',v_intent_id,
      'kind',case when c.ruolo='png_finale' then 'final' else 'resolution' end,
      'fact_ref',v_prior_fact,
      'movement_modifier',null,
      'requires_defense_handoff',false,
      'outcome_ids','[]'::jsonb));
  end if;

  v_dialogues := jsonb_build_array(jsonb_build_object(
    'id','dialogue.png.exam','speaker_ref','actor.png','addressee_ref','actor.candidate',
    'acts',jsonb_build_array('challenge','aspiration'),
    'topics',jsonb_build_array('exam_goal','relationship'),'responds_to_player',false
  ));
  if jsonb_array_length(v_utterances)>0 then
    v_dialogues := v_dialogues || jsonb_build_array(jsonb_build_object(
      'id','dialogue.png.reply','speaker_ref','actor.png','addressee_ref','actor.candidate',
      'acts',jsonb_build_array('acknowledgement','challenge'),
      'topics',jsonb_build_array('player_utterance','relationship'),'responds_to_player',true
    ));
  end if;

  v_continuity := jsonb_build_array(jsonb_build_object(
    'id','continuity.png.prior_motion.1','kind','prior_motion','subject_ref','actor.png',
    'description',left('lo scambio precedente resta visibile nel modo in cui il PNG ricompone postura e respiro dopo che ' || v_outcome_text,240),
    'authority','server_fact'
  ));
  if v.pv_png < v.pv_png_max then
    v_continuity := v_continuity || jsonb_build_array(jsonb_build_object(
      'id','continuity.png.fatigue.1','kind','fatigue','subject_ref','actor.png',
      'description','la fatica accumulata negli scambi precedenti resta visibile nel corpo del PNG',
      'authority','server_fact'
    ));
  end if;
  if v_target='actor.png' and coalesce(c.referto->>'danno','nessuno') <> 'nessuno' then
    v_continuity := v_continuity || jsonb_build_array(jsonb_build_object(
      'id','continuity.png.pain.1','kind','pain','subject_ref','actor.png',
      'description','il PNG porta ancora la reazione fisica del colpo appena ricevuto',
      'authority','server_fact'
    ));
  end if;

  v_environment := jsonb_build_array(
    jsonb_build_object('ref','place.tatami','description','tatami dell''aula d''esame, libero al centro e illuminato dalle finestre'),
    jsonb_build_object('ref','object.training_supports','description','piccoli supporti di legno restano ordinati ai margini della sala')
  );
  select coalesce(jsonb_agg(left(x.testo_esito,3500) order by x.resolved_at desc, x.id desc),'[]'::jsonb)
    into v_recent
    from (
      select h.id,h.testo_esito,h.resolved_at
        from public.esame_narrazione_cicli h
       where h.prova_id=p_prova and h.id<>c.id and h.stato='risolta'
         and btrim(coalesce(h.testo_esito,''))<>''
       order by h.resolved_at desc nulls last,h.id desc
       limit 8
    ) x;

  v_components := case c.ruolo
    when 'png_attacca' then jsonb_build_array(jsonb_build_object(
      'id','component.handoff.defense','slot_id','action',
      'text',v_candidate_name || ' deve ora difendersi dall''attacco appena descritto.','source','server_deterministic'))
    when 'png_esito' then jsonb_build_array(jsonb_build_object(
      'id','component.handoff.initiative','slot_id','action',
      'text','L''iniziativa torna a ' || v_candidate_name || ' per la nuova offensiva.','source','server_deterministic'))
    when 'png_finale' then jsonb_build_array(jsonb_build_object(
      'id','component.final','slot_id','action',
      'text',case when c.referto->>'finale_tipo'='sfinimento'
        then 'Il Sensei arresta la prova e invita ' || v_candidate_name || ' a ritirare il coprifronte all''ingresso dell''aula.'
        else 'Il Sensei arresta lo scontro dopo il quarto scambio, dichiara di aver visto abbastanza e consegna il coprifronte a ' || v_candidate_name || '.' end,
      'source','server_deterministic'))
    else '[]'::jsonb end;

  v_state_version := encode(extensions.digest(concat_ws('|',
    v.updated_at,c.id,c.stato,c.ruolo,c.opzioni_id,v.scambio,v.fase,v.beat,
    c.pg_message_id,encode(extensions.digest(v_action_text,'sha256'),'hex'),p.updated_at,
    v_location_id,v_location_region
  ),'sha256'),'hex');

  return jsonb_build_object(
    'producer_version','exam-surface-seed/1.0',
    'source_event_id',c.id,'receipt_id',c.opzioni_id,'state_version',v_state_version,'role',c.ruolo,
    'refs',jsonb_build_array(
      jsonb_build_object('id','actor.png','role','png','label',v_png_name),
      jsonb_build_object('id','actor.candidate','role','candidate','label',v_candidate_name),
      jsonb_build_object('id','actor.sensei','role','sensei','label','il Sensei'),
      jsonb_build_object('id','place.tatami','role','place','label','il tatami'),
      jsonb_build_object('id','object.training_supports','role','object','label','i supporti da esercitazione')
    ),
    'intents',v_intents,'facts',v_facts,'dialogue_frames',v_dialogues,
    'player_input',jsonb_build_object('trust','untrusted_narrative_evidence','action_text',v_action_text,'utterances',v_utterances),
    'persona',public._narrative_exam_persona(v_agent_persona,v_png_name),
    'continuity',v_continuity,'environment',v_environment,'recent_surfaces',v_recent,
    'deterministic_components',v_components,
    'limits',jsonb_build_object('max_segments',12,'max_dialogues',case when c.ruolo='png_finale' then 1 else 2 end,'max_output_chars',3500)
  );
end
$function$;


-- SOURCE candidato/999_POSTLUDE.sql
do $postcondition$
declare
  mismatch_count integer;
begin
  select count(*) into mismatch_count
    from exam_spatial_legacy_contract_before before_contract
    join pg_proc after_contract
      on after_contract.oid = before_contract.signature::regprocedure
   where after_contract.proowner is distinct from before_contract.proowner
      or after_contract.prosecdef is distinct from before_contract.prosecdef
      or after_contract.proconfig is distinct from before_contract.proconfig
      or after_contract.proacl is distinct from before_contract.proacl
      or after_contract.prorettype is distinct from before_contract.prorettype
      or after_contract.prokind is distinct from before_contract.prokind;

  if mismatch_count <> 0 then
    raise exception 'EXAM_SPATIAL_LEGACY_CONTRACT_DRIFT:%', mismatch_count;
  end if;

  if (select p.provolatile from pg_proc p
       where p.oid = 'public._esame_prova_opzioni(uuid,text)'::regprocedure) <> 'v' then
    raise exception 'EXAM_SPATIAL_OPTIONS_MUST_BE_VOLATILE';
  end if;

  if strpos(
       pg_get_functiondef('public._esame_risolvi(uuid,jsonb,text)'::regprocedure),
       '_esame_ancora_scegli(p_prova, v_pos_dif)'
     ) > 0
     or strpos(
       pg_get_functiondef('public._esame_risolvi(uuid,jsonb,text)'::regprocedure),
       'v_reaz in (''sostituzione'',''tecnica'')'
     ) > 0 then
    raise exception 'EXAM_SPATIAL_LEGACY_SUBSTITUTION_PATH_REMAINS';
  end if;

  if strpos(
       pg_get_functiondef('public._esame_prova_opzioni(uuid,text)'::regprocedure),
       '''posizioni'', v_posizioni'
     ) > 0 then
    raise exception 'EXAM_SPATIAL_LEGACY_POSITION_OFFER_REMAINS';
  end if;
end
$postcondition$;

-- COMMIT gestito dal canale migration; il gate QA termina con ROLLBACK esterno.
-- Verifica read-only dei 33 corpi e metadati effettivamente installati.
DO $release_catalog$
DECLARE e jsonb; p pg_catalog.pg_proc%rowtype; acl_actual jsonb;
BEGIN
 FOR e IN SELECT value FROM jsonb_array_elements($spec$[{"signature":"combat_spatial.path_first_block_t(uuid,uuid,numeric,numeric,numeric,numeric,uuid)","md5":"edb02c1d0a874862a53de10740287d2a","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"combat_spatial.anchor_is_legal(uuid,uuid,text,text,integer)","md5":"c3446fa3b59bee3c2358a305bf854626","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_ciclo_payload(uuid)","md5":"afa1e1b78a1f1e74b55c7ea72efebb00","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_diversivo(uuid,text,text,uuid,text)","md5":"a666c1e30c7ed7947f4fcba120f39a87","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_moltiplicazione_candidato(uuid,text,integer,text)","md5":"e49a61fd6b60a91361811c44d978fd3f","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_moltiplicazione_candidato(uuid,text,integer,text,integer)","md5":"8c7a3eaccd884c5e114123e256a1d197","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_png_gioca(uuid,text,text)","md5":"7d0f3ac17868b6b2a5d0fe8e1ad56a52","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_png_intenzioni(uuid)","md5":"a004b552c851b1ca5657332ee1eb1008","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_png_scena(uuid,timestamp with time zone)","md5":"4df4a855a652e73cd0451bbabe8dc141","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_prova_azione_esegui(uuid,jsonb,text)","md5":"1ddd670e1cb2b7705ecb022b89d7b903","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_prova_opzioni(uuid,text)","md5":"268e0af570192411708cbaa226499dd2","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_replay_payload(uuid,uuid)","md5":"928ee368e24314feb00f491721af625f","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_risolvi(uuid,jsonb,text)","md5":"befd519e7636c0c0ceed87c341075e4b","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_spazio_json(uuid,boolean)","md5":"19562518c4891a3b06217549bf975449","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_stato_asof(esame_prove,timestamp with time zone)","md5":"9a0121f9569d98336203d82b20e9cd63","owner":"postgres","security_definer":false,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_stato_json(uuid)","md5":"dfba0b583d25bea709fc298ca6897fbe","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public.esame_prova_apri(uuid)","md5":"e70524bfd80ad0190e5c0b6fdded8dce","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"authenticated","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public.narrative_surface_seed_exam(uuid,integer)","md5":"1bc63f64077044096c0d652a11e27cbf","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_sostituzione_source_id_v1(uuid,integer,text,text)","md5":"288a8b22adad46457336de1477a1d3df","owner":"postgres","security_definer":false,"volatility":"i","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_sostituzione_opzioni_comune_v1(uuid,text)","md5":"85308475d40449f72409ea1eb95acc35","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_sostituzione_commit_comune_v1(uuid,uuid,text)","md5":"d5c235a351699f6e9075f78d06f83d4e","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"combat_spatial._path_first_block_lifecycle_internal_v1(uuid,uuid,numeric,numeric,numeric,numeric,uuid,text)","md5":"b8f547878c4f98606eed2432ba3d8245","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_spatial_snapshot_v1(uuid)","md5":"2427498ada99d808352fc0ed7c0606eb","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_spatial_prepare_v1(uuid)","md5":"3033c1ce114a40b92da61d8bfe2c0fae","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_spatial_move_preview_v1(uuid,text,numeric,boolean)","md5":"cd07a3b98b5b24be9039efb493f58415","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_spatial_history_record_v1(uuid,uuid,jsonb,jsonb)","md5":"9ed175ca853b996447bcb951108169f6","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_spatial_snapshot_asof_v1(uuid,timestamptz)","md5":"36c74bb65e99916a08c4e97c63ec2875","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_spatial_snapshot_version_v1(uuid,integer)","md5":"4c934d69d6dd8df39e0c6b6bf5515344","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_spatial_move_commit_v1(uuid,text,numeric,boolean,uuid)","md5":"f25e11b158de4656193f469ddf2e065d","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_payload_v5_complete_v1(uuid,jsonb)","md5":"31e16bcaaba7cab4b3b096d135b8a8f0","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=\"\""],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_prova_opzioni_legacy_v1(uuid,text)","md5":"39772e2fda302362564e73fd709fa8a9","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_risolvi_legacy_v1(uuid,jsonb,text)","md5":"06c7346fffc65d6f525d46849dcb817d","owner":"postgres","security_definer":true,"volatility":"v","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]},{"signature":"public._esame_png_scena_snapshot_v1(uuid,timestamp with time zone,integer)","md5":"05804ff60d573b2574b158957946b7d1","owner":"postgres","security_definer":true,"volatility":"s","config":["search_path=public"],"acl":[{"grantee":"postgres","grantor":"postgres","privilege":"EXECUTE","grantable":false},{"grantee":"service_role","grantor":"postgres","privilege":"EXECUTE","grantable":false}]}]$spec$::jsonb) LOOP
  SELECT * INTO p FROM pg_catalog.pg_proc WHERE oid=to_regprocedure(e->>'signature');
  IF NOT FOUND OR md5(p.prosrc) IS DISTINCT FROM e->>'md5'
   OR pg_get_userbyid(p.proowner) IS DISTINCT FROM e->>'owner'
   OR p.prosecdef IS DISTINCT FROM (e->>'security_definer')::boolean
   OR p.provolatile::text IS DISTINCT FROM e->>'volatility'
   OR to_jsonb(p.proconfig) IS DISTINCT FROM e->'config' THEN
   RAISE EXCEPTION 'RELEASE_INSTALLED_BODY_OR_METADATA_DRIFT:%',e->>'signature'; END IF;
  SELECT coalesce(jsonb_agg(jsonb_build_object('grantee',CASE WHEN x.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(x.grantee) END,
   'grantor',pg_get_userbyid(x.grantor),'privilege',x.privilege_type,'grantable',x.is_grantable)),'[]') INTO acl_actual
   FROM aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) x;
  IF NOT(acl_actual @> (e->'acl') AND (e->'acl') @> acl_actual) THEN
   RAISE EXCEPTION 'RELEASE_INSTALLED_ACL_DRIFT:%',e->>'signature'; END IF;
 END LOOP;
END $release_catalog$;
