-- ATTESTAZIONE/REBASE OFFLINE: NON E' UNA MIGRAZIONE E NON MODIFICA IL DB.
-- Il resolver comune Sostituzione R9 e i wrapper Esame sono gia LIVE inerti.
-- Questo file fallisce chiuso se la baseline richiesta dal futuro adapter non esiste.

begin read only;

do $attest$
declare
  missing text[] := array[]::text[];
begin
  if to_regprocedure('combat_spatial.anchor_is_legal(uuid,uuid,text,text,integer)') is null then
    missing := array_append(missing,'combat_spatial.anchor_is_legal(uuid,uuid,text,text,integer)');
  end if;
  if to_regprocedure('combat_spatial.substitution_commit(uuid,uuid,uuid)') is null then
    missing := array_append(missing,'combat_spatial.substitution_commit(uuid,uuid,uuid)');
  end if;
  if to_regprocedure('public.combat_v2_substitution_options_v1(uuid)') is null then
    missing := array_append(missing,'public.combat_v2_substitution_options_v1(uuid)');
  end if;
  if to_regprocedure('public.combat_v2_substitution_select_v1(uuid,uuid)') is null then
    missing := array_append(missing,'public.combat_v2_substitution_select_v1(uuid,uuid)');
  end if;
  if to_regprocedure('public.combat_v2_substitution_resolve_internal_v1(uuid,uuid)') is null then
    missing := array_append(missing,'public.combat_v2_substitution_resolve_internal_v1(uuid,uuid)');
  end if;
  if to_regprocedure('public.exam_substitution_options_v1(uuid,uuid)') is null then
    missing := array_append(missing,'public.exam_substitution_options_v1(uuid,uuid)');
  end if;
  if to_regprocedure('public.exam_substitution_commit_v1(uuid,uuid,uuid)') is null then
    missing := array_append(missing,'public.exam_substitution_commit_v1(uuid,uuid,uuid)');
  end if;
  if cardinality(missing)>0 then
    raise exception 'P1A_COMMON_SUBSTITUTION_BASELINE_MISSING:%',array_to_string(missing,',');
  end if;

  if has_function_privilege('anon','public.exam_substitution_options_v1(uuid,uuid)','execute')
     or has_function_privilege('authenticated','public.exam_substitution_options_v1(uuid,uuid)','execute')
     or has_function_privilege('anon','public.exam_substitution_commit_v1(uuid,uuid,uuid)','execute')
     or has_function_privilege('authenticated','public.exam_substitution_commit_v1(uuid,uuid,uuid)','execute')
     or not has_function_privilege('service_role','public.exam_substitution_options_v1(uuid,uuid)','execute')
     or not has_function_privilege('service_role','public.exam_substitution_commit_v1(uuid,uuid,uuid)','execute')
  then
    raise exception 'P1A_EXAM_WRAPPER_ACL_DRIFT';
  end if;
end
$attest$;

select 'generic_sostituzione_spatial_v1'::text as authoritative_profile,
       'combat_exam_exchange_identity_v1'::text as adapter_identity,
       'ATTESTED_NO_DB_DELTA'::text as result;

rollback;
