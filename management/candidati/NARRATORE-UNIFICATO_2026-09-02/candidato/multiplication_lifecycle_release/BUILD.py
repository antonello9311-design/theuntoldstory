#!/usr/bin/env python3
"""Offline generator. Reads frozen source metadata; never connects to a database."""
import argparse
import hashlib
import json
from pathlib import Path

TARGET = 'combat_consumer_private.narrative_tech_sources_v1(uuid)'
BLOCK = r'''
 -- Moltiplicazione: immutable resolution receipt + exact resolved target/round.
 -- Native terminal state alone is insufficient; never infer an ending from damage.
 FOR event IN
  SELECT mr.formation_id, mr.attack_target_id, mr.facts, mr.receipt_sha256,
    mr.created_at AS receipt_at, mr.choice_kind, mr.outcome AS choice_outcome,
    f.actor_id, f.mode, f.state AS formation_state, f.terminal_reason, f.ended_at,
    f.declaration_id AS formation_declaration, t.state AS target_state,
    t.target_actor_id, t.outcome AS target_outcome,
    d.id AS attack_id, d.actor_id AS attacker_id, d.state AS attack_state
  FROM combat_panel_private.multiplication_resolutions mr
  JOIN combat_panel_private.multiplication_formations f ON f.id=mr.formation_id
  JOIN public.combat_v2_attack_targets t ON t.id=mr.attack_target_id
  JOIN public.combat_v2_declarations d ON d.id=t.attack_declaration_id
  WHERE f.session_id=claim.session_id AND t.round_id=claim.round_id
    AND d.round_id=claim.round_id
  ORDER BY mr.formation_id, mr.created_at, mr.attack_target_id
 LOOP
  IF unit.resolved_at IS NULL OR unit.report_id IS DISTINCT FROM claim.report_id
    OR unit.phase NOT IN ('risolto','narrato')
    OR event.attack_state IS DISTINCT FROM 'risolta'
    OR event.target_state IS DISTINCT FROM 'risolta'
    OR jsonb_typeof(event.facts) IS DISTINCT FROM 'object'
    OR event.facts->>'schema_version' IS DISTINCT FROM 'combat-multiplication-resolution/1'
    OR event.facts->'formation_id' IS DISTINCT FROM to_jsonb(event.formation_id)
    OR event.facts->'attack_target_id' IS DISTINCT FROM to_jsonb(event.attack_target_id)
    OR event.facts->>'mode' IS DISTINCT FROM event.mode
    OR event.facts->>'choice_kind' IS DISTINCT FROM event.choice_kind
    OR event.facts->>'outcome' IS DISTINCT FROM event.choice_outcome
    OR event.choice_outcome NOT IN ('original_found','copy_hit')
    OR event.receipt_sha256 IS DISTINCT FROM public.combat_v2_sha256(event.facts)
    OR jsonb_typeof(event.target_outcome->'multiplication') IS DISTINCT FROM 'array'
    OR NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements(CASE
        WHEN jsonb_typeof(event.target_outcome->'multiplication')='array'
        THEN event.target_outcome->'multiplication' ELSE '[]'::jsonb END) item
      WHERE item - 'role' = event.facts
    ) THEN
   RAISE EXCEPTION 'narrative_multiplication_receipt_invalid' USING ERRCODE='22023';
  END IF;
  IF event.formation_state IS DISTINCT FROM 'consumed'
    OR event.ended_at IS NULL OR event.ended_at < event.receipt_at
    OR event.ended_at > unit.resolved_at
    OR event.terminal_reason IS DISTINCT FROM (CASE
      WHEN event.mode='assalto' AND event.formation_declaration=event.attack_id
        AND event.actor_id=event.attacker_id THEN 'assault_resolved'
      ELSE 'first_attack' END)
    OR NOT (
      event.actor_id=event.target_actor_id OR
      (event.mode='assalto' AND event.formation_declaration=event.attack_id
        AND event.actor_id=event.attacker_id)
    )
    OR NOT EXISTS (SELECT 1 FROM combat_consumer_private.members m
      WHERE m.session_id=claim.session_id AND m.actor_id=event.actor_id) THEN
   RAISE EXCEPTION 'narrative_multiplication_terminal_event_invalid' USING ERRCODE='22023';
  END IF;
  IF NOT event.formation_id=ANY(multiplication_seen) THEN
   endings:=endings||jsonb_build_array(jsonb_build_object(
     'tecnica','Moltiplicazione del corpo','actor_id',event.actor_id,
     'stato','terminato','causa',CASE event.terminal_reason
       WHEN 'first_attack' THEN 'primo_attacco_risolto'
       WHEN 'assault_resolved' THEN 'assalto_risolto' END));
   multiplication_seen:=array_append(multiplication_seen,event.formation_id);
  END IF;
 END LOOP;
'''

def lit(s):
    return "'" + str(s).replace("'", "''") + "'"

def js(v):
    return lit(json.dumps(v, ensure_ascii=False, separators=(',', ':'))) + '::jsonb'

def md5(s):
    return hashlib.md5(s.encode()).hexdigest()

def function_guard(functions, target_hash):
    lines = []
    for f in functions:
        ident = f['identity']
        expected = target_hash if ident == TARGET else f['md5']
        acl = lit(f['acl']) + '::aclitem[]' if f['acl'] is not None else 'NULL::aclitem[]'
        lines.append(f""" IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p
   WHERE p.oid=pg_catalog.to_regprocedure({lit(ident)})
    AND pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid))={lit(expected)}
    AND pg_catalog.pg_get_userbyid(p.proowner)={lit(f['owner'])}
    AND p.proacl IS NOT DISTINCT FROM {acl}) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_function_drift: %',{lit(ident)}; END IF;""")
    return '\n'.join(lines)

def table_guard(tables):
    lines = []
    for t in tables:
        ident = t['schema']+'.'+t['name']
        expected = {k: t[k] for k in ['owner','acl','relrowsecurity','relforcerowsecurity','columns']}
        body = """jsonb_build_object('owner',pg_catalog.pg_get_userbyid(c.relowner),
       'acl',c.relacl::text,'relrowsecurity',c.relrowsecurity,'relforcerowsecurity',c.relforcerowsecurity,
       'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,
         'type',pg_catalog.format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull) ORDER BY a.attnum)
         FROM pg_catalog.pg_attribute a WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped))"""
        if 'constraints' in t:
            expected.update({k:t[k] for k in ['constraints','triggers']})
            body += """ || jsonb_build_object('constraints',(SELECT jsonb_agg(jsonb_build_object(
        'name',co.conname,'type',co.contype,'definition',pg_catalog.pg_get_constraintdef(co.oid)) ORDER BY co.conname)
        FROM pg_catalog.pg_constraint co WHERE co.conrelid=c.oid),
        'triggers',(SELECT jsonb_agg(jsonb_build_object('name',tr.tgname,'enabled',tr.tgenabled,
         'definition',pg_catalog.pg_get_triggerdef(tr.oid),'function',tr.tgfoid::regprocedure::text) ORDER BY tr.tgname)
         FROM pg_catalog.pg_trigger tr WHERE tr.tgrelid=c.oid AND NOT tr.tgisinternal))"""
        lines.append(f""" IF (SELECT {body} FROM pg_catalog.pg_class c
    WHERE c.oid=pg_catalog.to_regclass({lit(ident)})) IS DISTINCT FROM {js(expected)} THEN
   RAISE EXCEPTION 'multiplication_lifecycle_table_drift: %',{lit(ident)}; END IF;""")
    return '\n'.join(lines)

QUIET = r'''
 -- checked_at is sampled once AFTER both table locks, never at transaction start.
 -- Ignore only an exhausted legacy claim with no attempt or recorded result.
 -- Any attempt (including generated/provider_reserved beyond lease) remains blocking.
 IF EXISTS (
  SELECT 1 FROM combat_consumer_private.narrative_claims c
  WHERE c.context_payload->>'ordinary'='true'
    AND c.state NOT IN ('completed','failed','expired')
    AND NOT (
      c.state='claimed'
      AND c.expires_at IS NOT NULL AND c.expires_at < checked_at
      AND c.completion_sha256 IS NULL
      AND c.completion_result IS NULL
      AND c.provider_response_id IS NULL
      AND c.provider_request_sha256 IS NULL
      AND c.raw_output_sha256 IS NULL
      AND NOT EXISTS (
        SELECT 1 FROM combat_consumer_private.scene_attempts_v2 a
        WHERE a.claim_id=c.id OR a.round_id=c.round_id
      )
    )
 ) THEN
  RAISE EXCEPTION 'multiplication_lifecycle_ordinary_claim_inflight'; END IF;
'''
UNUSED = r'''
 IF current_setting('tus.multiplication_lifecycle_recovery',true)
   IS DISTINCT FROM 'Antonello:NARRATIVE-MULTIPLICATION-LIFECYCLE-CANDIDATE-001:before-use' THEN
  RAISE EXCEPTION 'multiplication_lifecycle_named_recovery_required'; END IF;
 IF EXISTS (
  SELECT 1 FROM combat_consumer_private.scene_attempts_v2 a
  CROSS JOIN LATERAL (SELECT CASE
    WHEN jsonb_typeof(a.scene_payload->'resolved_facts')='object' THEN a.scene_payload->'resolved_facts'
    WHEN jsonb_typeof(a.scene_payload->'resolved_facts')='string'
      AND pg_catalog.pg_input_is_valid(a.scene_payload->>'resolved_facts','jsonb')
      THEN (a.scene_payload->>'resolved_facts')::jsonb ELSE '{}'::jsonb END AS facts) decoded
  CROSS JOIN LATERAL jsonb_array_elements(CASE
    WHEN jsonb_typeof(decoded.facts->'conclusioni_effetti_server')='array'
    THEN decoded.facts->'conclusioni_effetti_server' ELSE '[]'::jsonb END) e
  WHERE e->>'tecnica'='Moltiplicazione del corpo' AND e->>'stato'='terminato'
    AND e->>'causa' IN ('primo_attacco_risolto','assalto_risolto')
 ) THEN RAISE EXCEPTION 'multiplication_lifecycle_already_used_recovery_forbidden'; END IF;
'''

def generate(root):
    bp=root/'BASELINE.json'
    b=json.loads(bp.read_text())
    target=next(f for f in b['functions'] if f['identity']==TARGET)
    before=target['definition']
    assert md5(before)==target['md5']=='955228bdc23c89cdb287198db57231b8'
    decl="  sources jsonb:='[]'; endings jsonb:='[]'; native_id uuid; source_kind text;"
    anchor=" RETURN jsonb_build_object('fonti_tecniche',sources,'conclusioni_effetti_server',endings);"
    assert before.count(decl)==before.count(anchor)==1
    after=before.replace(decl,decl+" multiplication_seen uuid[]:=ARRAY[]::uuid[];").replace(anchor,BLOCK+anchor)
    assert after.replace(BLOCK,'').replace(' multiplication_seen uuid[]:=ARRAY[]::uuid[];','')==before
    functions=b['functions']+b['quiet_source_functions']
    assert len(b['quiet_source_functions'])==6
    assert len({f['identity'] for f in functions})==len(functions)
    tables=b['tables']+b['environment']['lifecycle_tables']
    table_pins=table_guard(tables)
    before_guard=function_guard(functions,md5(before))
    after_guard=function_guard(functions,md5(after))
    locks='LOCK TABLE combat_consumer_private.narrative_claims, combat_consumer_private.scene_attempts_v2 IN SHARE ROW EXCLUSIVE MODE;'
    header="BEGIN;\nSET LOCAL lock_timeout='3s';\nSET LOCAL statement_timeout='30s';\nSET LOCAL search_path TO public,extensions;\n"+locks+'\n'
    for name,guard,body,post,recovery in [('INSTALL.sql',before_guard,after,after_guard,False),('RECOVERY.sql',after_guard,before,before_guard,True)]:
        sql='-- Candidate only. Separate independent review, local qualification and named production gate.\n'+header
        sql+="DO $pre$ DECLARE checked_at timestamptz; BEGIN\n checked_at:=clock_timestamp();\n IF current_user<>'postgres' THEN RAISE EXCEPTION 'multiplication_lifecycle_postgres_required'; END IF;\n"
        sql+=guard+'\n'+table_pins+'\n'+QUIET+(UNUSED if recovery else '')+'\nEND $pre$;\n'
        sql+=body.rstrip()+';\n' if not body.rstrip().endswith(';') else body.rstrip()+'\n'
        sql+='ALTER FUNCTION '+TARGET+' OWNER TO postgres;\n'
        sql+='REVOKE ALL ON FUNCTION '+TARGET+' FROM PUBLIC,anon,authenticated,service_role;\n'
        sql+='GRANT EXECUTE ON FUNCTION '+TARGET+' TO postgres;\n'
        sql+='DO $post$ BEGIN\n'+post+'\n'+table_pins+'\nEND $post$;\nCOMMIT;\n'
        (root/name).write_text(sql)
    b['candidate']={'target':TARGET,'before_md5':md5(before),'after_md5':md5(after),
      'before_sha256':hashlib.sha256(before.encode()).hexdigest(),'after_sha256':hashlib.sha256(after.encode()).hexdigest(),
      'changed_functions':1,'new_functions':0,'new_tables':0,'hook_changed':False,
      'after_definition':after,'preservation_exact_outside_insertions':True}
    bp.write_text(json.dumps(b,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({k:v for k,v in b['candidate'].items() if k!='after_definition'}))

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--directory',type=Path,default=Path(__file__).resolve().parent)
    generate(parser.parse_args().directory.resolve())
