#!/usr/bin/env python3
"""Composer source-only. No network, SQL execution, provider or gameplay.
--capture-query emits ONE readonly SELECT; --plan emits a deterministic inventory.
Final installer emission requires the actual postEditorStageB envelope, then a
separately reviewed aggregate material. It never falls back to an old Root.
"""
import argparse,hashlib,json,re,sys
from pathlib import Path
sys.path.insert(0,'/private/tmp/tus-c1266-narratore76-20261101/db/parse_tools312')
from pglast import parse_sql
ROOT=Path('/Users/antonello/Desktop/theuntoldstory')
C=ROOT/'management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato'
E=ROOT/'management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master'
DEFAULT_CAPTURE=Path('/private/tmp/tus-combat-missioni-completamento-20261102/EDITOR_STAGE_B_ACTUAL.json')
SOURCES=[('innata',C/'INNATA_INTEGRAZIONE_SOURCE.sql'),('facing',C/'FACING_SOURCE.sql'),('lifecycle',C/'INNATA_LIFECYCLE_SOURCE.sql'),('tactics',C/'COMBAT_TACTICS_CANDIDATO.sql'),('eligibility',C/'INNATA_ELIGIBILITY_COMPAT_SOURCE.sql')]
CONSUMERS=[E/n for n in ['INNATA_COMMAND_LAND.html','INNATA_COMMAND_GENERIC_UI.mjs','INNATA_COMMAND_EDGE_FILES.json','INNATA_COMMAND_CONSUMERS_MANIFEST.json','INNATA_COMMAND_REVIEW.md']]
CONSUMERS += [E/n for n in ['COMBAT_MISSIONI_ADMIN.html','COMBAT_MISSIONI_EDITOR.mjs','COMBAT_MISSIONI_CREATION.mjs','COMBAT_MISSIONI_REGOLE.md','COMBAT_MISSIONI_regole.html']]
REVIEWS=[C/'COMBAT_CURRENT_RELEASE_REVIEW.json',C/'INNATA_BRIDGE_REVIEW.json',C/'COMBAT_COMPONENTS_SOURCE_REVIEW.json']
EXPECTED_INPUTS={'/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_INTEGRAZIONE_SOURCE.sql': '229115a889fd663c631a6d13311901fd53a14dc373f76f4ab52d749d2cae363a', '/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/FACING_SOURCE.sql': '96a3941ea227bf64d365826a8f0886b7bf8a98396c8f75e40167f157d399970e', '/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_LIFECYCLE_SOURCE.sql': 'a8002313cfbc3dcc60112278ec69b9fe2fe42db9380f57ba34ea640a24044ed1', '/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/COMBAT_TACTICS_CANDIDATO.sql': '22312a8ea771140a49d906a4fcce2bf05d285e9b3a9fdfb1007a72570e52a38a', '/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_LAND.html': 'ed6e01805df4f11da916b2310b9af9b9ac5a6fa1bfb6e61126d31124d88290ce', '/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_GENERIC_UI.mjs': 'e7f32894f96f304af494eae7d56e6ef11b6680aff6a41f24df8420a22025d63b', '/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_EDGE_FILES.json': '33276144f4b9352b5f3b30c841e8985247aac735ab70ce95dd84762a9f23af8e', '/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_CONSUMERS_MANIFEST.json': 'ce2cdc2286ccd3902294faa1d71e8367095a86ba3bb8582b08d7e8902ebb455a', '/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_REVIEW.md': 'a04a97919dddcd614a5b27c7c71daec145321cacf54d10fbaa1212cc7c445b4c', '/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/COMBAT_CURRENT_RELEASE_REVIEW.json': 'c0df6909c47d4344ccc49678b19ea9c0fd563ee19f6242cb3d4788cf5d046a0c', '/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_BRIDGE_REVIEW.json': 'f3f686a8fd37242d7e4a28e8ee9dad2d5b96176dc489d0028dba475c83735562', '/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/COMBAT_COMPONENTS_SOURCE_REVIEW.json': '82b7307e774461dc3b3d27fde329a7693e964bedbf4aa603705d355cbe781f41', '/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_UPKEEP_REVIEW.json': 'cc5e024b90545c5ec8df8398e482d219c7ff2f449d07f263aabd7e38d98eb8fb', '/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_INTEGRAZIONE_CONTRATTO.json': '2cd11396824a7395fa2aacac5d234708a8ee5f33a2d6761b89dafef53f5a6f05', '/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_UI_REVIEW2.json': 'e4f8c25ab6db9931aaeba8689c4af82352dbeeb7f233e3ec2f2ea56a3c61ad3a', '/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_ADMIN.html': '871552ea63704813c65d7157daca023879e16a6e2fbd27975b4153a8c3b6e393', '/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_EDITOR.mjs': 'bbc1f44089aab17f29585459a350ea2615194cc6aec1a01ce83c7097652dfea6', '/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_CREATION.mjs': '8a6e0f5b50ba58164ee1491086509169d39ba4b59efb9caf91dac5ce92bf4fd3', '/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_REGOLE.md': '737a624b3883681459090369156567d8c8665d68fde333fa5d44ca1bffdfa5c2', '/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_regole.html': 'e69d00d5ca446d6bf4af5e0f070e4adea14592ab0cc1adb2a22d642fa85d865e'}
SOURCE3_REVIEW=C/'INNATA_UPKEEP_REVIEW.json'
SUPPLEMENT_CAPTURE=Path('/private/tmp/tus-combat-missioni-completamento-20261102/COMBAT_C_PREFLIGHT_ACTUAL.json')
SUPPLEMENT_SHA='e11993185cd47554dc99b437ac23458d86f0c0f756e0419a13ad962ca297b7dd'
REVIEWS += [SOURCE3_REVIEW,E/'COMBAT_MISSIONI_UI_REVIEW2.json']
OLD_ROOT='f7aebda96092a1fd71e26ddda35da84b34e3b0144d14e64ca5da31737feec512'
EXTRA_DEPENDENCIES=[{'signature': 'clan_innata_private.combat_state_read(uuid)', 'classification': 'modified_existing_preimage', 'baseline_ddl_md5': '9b885e6418824468627d9b92d7352ce9', 'baseline_source_md5': '7f7d579ec8ea247910083fe2ef98e35b', 'source_file': '/private/tmp/tus-innata-lifecycle-20261102/clan_innata_private_combat_state_read_uuid_.sql', 'source_file_sha256': 'c6a1d8ceecc65b920366a10db019b26d2b744834d7fbd97957b19e2d73a8c6a8', 'live_guard': 'PM pure SELECT preflight must compare actual OID-resolved declaration/prosrc/DDL; source Ward is not a new live observation. Preserve actual ACL unchanged before/after DDL.'}, {'signature': 'clan_innata_private.combat_transition(uuid,text,uuid,bigint)', 'classification': 'immutable_cost_dependency', 'baseline_ddl_md5': '7c71646e93017567804d909ff1f688cb', 'baseline_source_md5': '590ec6b32fd3f4bc5fb62c46c058698a', 'source_file': '/private/tmp/tus-innata-lifecycle-20261102/clan_innata_private_combat_transition_uuid_text_uuid_bigint_.sql', 'source_file_sha256': 'b705ce64ea1efd18331412c12b2dbd10298bacfbd02404810e6cd52e2217ce73', 'live_guard': 'PM pure SELECT preflight must compare actual OID-resolved declaration/prosrc/DDL; source Ward is not a new live observation. Preserve actual ACL unchanged before/after DDL.'}, {'signature': 'clan_innata_private.combat_begin_turn(uuid)', 'classification': 'immutable_turn_dependency', 'baseline_ddl_md5': '23f8fb7c7fa79ab438ef0a2ca7c49440', 'baseline_source_md5': '2e26d98a75852e124ceecb6ae9499ad0', 'source_file': '/private/tmp/tus-innata-lifecycle-20261102/clan_innata_private_combat_begin_turn_uuid_.sql', 'source_file_sha256': '79d81b2a682c2d19d818f2ea744a9d0b7cc07d3895b1ead3d3d2bfca2f20c080', 'live_guard': 'PM pure SELECT preflight must compare actual OID-resolved declaration/prosrc/DDL; source Ward is not a new live observation. Preserve actual ACL unchanged before/after DDL.'}, {'signature': 'clan_innata_private.combat_state_ensure(uuid)', 'classification': 'immutable_state_dependency', 'baseline_ddl_md5': '371e6723c5317a235978aba64a99f0c7', 'baseline_source_md5': '059dad0c3ba656e1a276b53567e5dd95', 'source_file': '/private/tmp/tus-innata-lifecycle-20261102/clan_innata_private_combat_state_ensure_uuid_.sql', 'source_file_sha256': 'fa4c47b7bd27ad2d49c2895397c55c25bd970b0845e431f17d94bdfd4f0cd222', 'live_guard': 'PM pure SELECT preflight must compare actual OID-resolved declaration/prosrc/DDL; source Ward is not a new live observation. Preserve actual ACL unchanged before/after DDL.'}]
EXPECTED_NATIVE={'public.post_message(uuid,text,uuid,uuid,text)': '1b014855d62224aac234212563758ffc', 'public.mission_role_submit_v1(uuid,uuid,text)': '8dcd1906f2b8c9ef5056d56f5f94601c', 'combat_consumer_private.accept_invitation(uuid,uuid)': '50531d6a0a9e60ae50fb6f58f458e954', 'mission_generic_owner.bind_arena_native(uuid,uuid,uuid)': 'a7b152820563030497ba2b7c13ce3bad', 'public.master_v2_encounter_open(uuid,uuid[],jsonb,jsonb,uuid,jsonb)': '0a9e6d45a05cdd502219c7a61dd77955', 'public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)': '187469c5f920b0046456b218a352a0c8', 'clan_innata_private.combat_scope(uuid,uuid)': '56fadc08b87e9b8d6332f147e88e33f4', 'clan_innata_private.combat_state_read(uuid,uuid)': '670a393058f6b9ff21b78e95472d8517', 'clan_innata_private.combat_state_guard()': '9089e0831ef93a4f1ca0f6e2c2d33186', 'clan_innata_private.state_set_core(uuid,uuid,boolean,uuid,bigint,text,uuid)': 'a304566853b657ca12cf52ea38abc18c', 'clan_innata_private.combat_transition(uuid,uuid,text,uuid,bigint)': '4b48bb63d3a36d11ae9a9d5a5d058f1e', 'clan_innata_private.combat_begin_turn(uuid,uuid)': '1cfa814eae8703521da9dd513bbf4495', 'clan_innata_private.combat_activation_window(uuid,uuid)': 'd8e87099244ab181b093833c52403d6e', 'clan_innata_private.combat_terminal(uuid,uuid,text)': '19951df399088e68e40bc6fd4b9d9c48', 'clan_hyuga_private.consumer_options(jsonb)': 'ef9904297c8258090b6ad0e51eaeaabb', 'clan_hyuga_private.master_control_offers(uuid,bigint)': 'bf1fa786e9499e2ebffa8ff80123c722', 'clan_hyuga_private.commit_control(jsonb,jsonb)': '614c6ea89bd56d6d1807835fb93dc42f', 'clan_hyuga_private.commit_master_control(jsonb)': 'ae9d8ef35890fe1340cc17385ed8332d', 'clan_hyuga_private.off_offer_valid(uuid,uuid)': '5f721a6b949b9fa1072ac1715b43a7d7', 'mission_generic_owner.choice_commit(uuid,uuid,jsonb)': '6668c84cabdf43742951da12df83a585', 'combat_panel_private.master_projection(uuid,uuid)': '98fb781319ad2a3605fb039d7a0c8c72', 'public.mission_generic_dispatch_finalize_v1(uuid,text,text,text)': '0c01eae343afb535ba892b1a6ba758e5', 'public._combat_calcola(text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)': 'e0be5a7da4b4daa8003bf74a7f8ee7a9', 'clan_inuzuka_private.attack_calculate(uuid,jsonb,text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)': '5ac7a0ebc64b17746ff621360ffa15fc', 'public.combat_v2_round_resolve(uuid,uuid)': '986ac635bd77a6db562d0536a23ec97a', 'combat_panel_private.multiplication_tactics_allowed(uuid)': '4fb4df7625ad3c9e830a758ab829bd69', 'combat_panel_private.multiplication_add_attack_figures(uuid,uuid,jsonb,numeric,text)': 'f9c1556dcbb8e6e7ecaf35c948f28189', 'combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)': 'fb81d3c35665d012eb053ca2b14cc32b', 'mission_creation_owner.human_open(uuid,uuid)': 'ca6f975bfe10133c07c3ba35c07e58c9', 'clan_innata_private.combat_state_read(uuid)': '9b885e6418824468627d9b92d7352ce9'}
EXPECTED_OVERLAYS={'clan_innata_narrative_private.quote_v1(uuid,boolean)','clan_innata_narrative_private.ensure_context_v1(uuid,uuid,uuid,jsonb)','clan_innata_narrative_private.activate_v1(uuid,uuid,uuid,uuid,uuid)','clan_innata_narrative_private.materialize_v1(uuid)','combat_facing_private.active_level(uuid)'}
TYPE_NAMES={'int4':'integer','int8':'bigint','bool':'boolean','float8':'double precision','varchar':'character varying'}
def sha(x):return hashlib.sha256(x if isinstance(x,bytes)else x.encode()).hexdigest()
def J(x):return json.dumps(x,sort_keys=True,separators=(',',':'),ensure_ascii=False)
def q(x):return "'"+x.replace("'","''")+"'"
REVIEWS.append(C/'COMBAT_INNATA_SEAL_CLOSURE_REVIEW.json')
EXPECTED_INPUTS[str(C/'COMBAT_INNATA_SEAL_CLOSURE_REVIEW.json')]='c3b92f8f93d5b15811fe4787cc42cadb263e8b588f504a8fbaca1dce984bb276'
EXPECTED_INPUTS[str(C/'INNATA_ELIGIBILITY_COMPAT_SOURCE.sql')]='47045f209564829fd5009af8ce68a395d83649a45f4d37ee531198179968b894'
EXPECTED_NATIVE['clan_innata_private.eligibility_release_assert()']='07767c7950ea581a34402997ef8e08f0'
SEAL_CAPTURE=Path('/private/tmp/tus-combat-missioni-completamento-20261102/INNATA_COMPLETE_SEAL_ACTUAL.json')
SEAL_CAPTURE_SHA='eb939f153c1ce7e822805cd2e5830df9320ac3dd74f3113c84fd125a3c2810a6'
def sig(st):
 name='.'.join(x.sval for x in st.funcname);args=[]
 for a in st.parameters or []:
  if getattr(getattr(a,'mode',None),'value',None)in ['o','t']:continue
  names=[x.sval for x in a.argType.names if x.sval!='pg_catalog'];typ='.'.join(names);typ=TYPE_NAMES.get(typ,typ)+'[]'*len(a.argType.arrayBounds or []);args.append(typ)
 return name+'('+','.join(args)+')'
FROZEN_UI2_FILES={'/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_ADMIN.html': '/private/tmp/tus-combat-innata-compose-20261102/_precedenti/material0/UI2/COMBAT_MISSIONI_ADMIN.html', '/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_EDITOR.mjs': '/private/tmp/tus-combat-innata-compose-20261102/_precedenti/material0/UI2/COMBAT_MISSIONI_EDITOR.mjs', '/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_CREATION.mjs': '/private/tmp/tus-combat-innata-compose-20261102/_precedenti/material0/UI2/COMBAT_MISSIONI_CREATION.mjs'}
def source_bytes(path):
 selected=Path(FROZEN_UI2_FILES.get(str(path),str(path)))
 return selected.read_bytes()
def scan():
 for path,expected in EXPECTED_INPUTS.items():
  assert sha(source_bytes(Path(path)))==expected,('Reviewed source drift',path)
 slots=[];by={};tables=[];schema=[];constraints=[];refs=set();relations=set()
 for component,path in SOURCES:
  text=path.read_text()
  for raw in parse_sql(text):
   start=raw.stmt_location;end=start+raw.stmt_len if raw.stmt_len else len(text)
   # pglast8 Python API exposes character offsets (verified with accented literal).
   sql=text[start:end].strip().rstrip(';')+';'
   st=raw.stmt;kind=type(st).__name__;item={'component':component,'ordinal':len(slots),'kind':kind,'sql':sql,'sha256':sha(sql),'source':str(path)}
   if kind=='CreateFunctionStmt':item['signature']=sig(st);by.setdefault(item['signature'],[]).append(item)
   if kind=='CreateStmt':
    rel=(st.relation.schemaname+'.'if st.relation.schemaname else'')+st.relation.relname;tables.append(rel);relations.add(rel);item['relation']=rel
   if kind=='CreateSchemaStmt':schema.append(st.schemaname)
   if kind=='AlterTableStmt':
    rel=(st.relation.schemaname+'.'if st.relation.schemaname else'')+st.relation.relname;relations.add(rel)
    if 'CONSTRAINT'in sql:constraints.append({'relation':rel,'sql':sql})
   for m in re.finditer(r"to_regprocedure\('([^']+)'\)",sql):refs.add(m.group(1))
   for m in re.finditer(r'(?:ON|FROM|JOIN|UPDATE|INTO|TABLE)\s+([a-z][a-z0-9_]*\.[a-z][a-z0-9_]*)',sql,re.I):relations.add(m.group(1))
   slots.append(item)
 overlap={k:[x['component']for x in v]for k,v in by.items()if len(v)>1}
 assert len(by)==58,(len(by),'Function inventory drift')
 assert set(overlap)==EXPECTED_OVERLAYS,overlap
 assert len(tables)==16,(len(tables),'New table inventory drift')
 return {'slots':slots,'functions':by,'overlaps':overlap,'new_tables':tables,'new_schemas':schema,'constraints':constraints,'function_refs':sorted(refs|set(by)),'relation_refs':sorted(relations)}
def schedule(s):
 # Overlay declarations are PL/pgSQL. Keep only the final reviewed body at its
 # own slot; all ACL loops run after the full58function inventory exists.
 last={k:v[-1]['ordinal']for k,v in s['functions'].items()}
 result=[];deferred=[]
 for item in s['slots']:
  x={k:v for k,v in item.items()if k!='sql'}
  if item['kind']=='TransactionStmt':x['action']='single-aggregate-transaction-boundary'
  elif item['kind']=='DoStmt'and re.match(r'DO\s+\$(?:composition|tactics_source_only)\$',item['sql']):x['action']='source-only-fence-replaced-by-material-review-preflight'
  elif item['kind']=='DoStmt'and re.match(r'DO\s+\$(?:tactics_guard|tactics_metadata|tactics_absence)\$',item['sql']):x['action']='replace-with-exact-capture-before-and-reviewed-final-after-guards'
  elif item['kind']=='CreateFunctionStmt'and item['ordinal']!=last[item['signature']]:x['action']='superseded-body-not-emitted'
  elif item['kind']=='DoStmt'and re.match(r'DO \$acl\$',item['sql']):x['action']='defer-ACL-until-all-functions-and-relations-exist';deferred.append(x)
  else:x['action']='emit-reviewed-statement-in-source-order'
  result.append(x)
 return {'slots':result,'deferred_ACL':deferred,'final_function_count':len(last),'single_transaction':True,'no_fence_only_removal':True,'required_aggregate_guards':['current Root full row/TEXT/revision/source hashes/materialreview','every existing function declaration/body/owner/ACL/pin before ANY DDL','every relation/schema/constraint/index/trigger/RLS/ACL and new absence before ANY DDL','all immutable certificate/origin/capability/profile/cost config snapshots','preserve active session admissions and verify allowed before and after adoption'],'post_DDL':['58 final source and metadata expected checks; no modified declaration except explicit supported changes','new private schemas/functions/tables postgres ACL/RLS/no client policy; new grants explicit','five exact CommonCHECKs plus separate unchanged Root524288 sizeCHECK','runtime seal byteexact; eligibility exact current private tuple, all other seal checks byteexact','new config exact tiers/approval evidence with captured original rows intact','currentRoot header occurrences updated from actual PG metadata; parent Editor component intact','current engine runtime+authoring and unchanged content certificate identity adopted atomically','old sessions remain allowed, new feature flags Worldfalse; no cleanQA claim']}
def inventory(s):
 return {'schema_version':'combat-innata-composition-plan/1','functions':{k:[{z:v for z,v in x.items()if z!='sql'}for x in values]for k,values in s['functions'].items()},'overlays':s['overlaps'],'new_tables':s['new_tables'],'new_schemas':s['new_schemas'],'constraints':s['constraints'],'statement_order':[{k:v for k,v in x.items()if k!='sql'}for x in s['slots']],'inputs':{str(p):sha(p.read_bytes())for _,p in SOURCES},'consumers':{str(p):sha(source_bytes(p))for p in CONSUMERS},'reviews':{str(p):sha(p.read_bytes())for p in REVIEWS},'schedule':schedule(s)}
def capture_query(s):
 signatures=s['function_refs']+['clan_innata_private.runtime_release_assert()','clan_innata_private.eligibility_release_assert()','mission_public_owner.role_session_allowed_v1(uuid)','mission_public_owner.engine_profile_state_v1(text,text)','mission_public_owner.engine_qualification_v1(text,boolean)','mission_public_owner.content_admission_v1(uuid,text,uuid,boolean)']
 signatures=sorted(set(signatures))
 # All Editor headers are obtained from Root recursively; all new functions are
 # represented even when absent. No character, role, message or Fato rows.
 return """WITH RECURSIVE root AS(SELECT r.*,to_jsonb(r)AS row_json FROM mission_factory_owner.editor_release_readiness r WHERE singleton),
 tree(value)AS(SELECT canonical_preimage::jsonb->'db_core' FROM root UNION ALL SELECT child FROM tree t CROSS JOIN LATERAL(
 SELECT value child FROM jsonb_each(CASE jsonb_typeof(t.value)WHEN 'object'THEN t.value ELSE '{}'::jsonb END)
 UNION ALL SELECT value FROM jsonb_array_elements(CASE jsonb_typeof(t.value)WHEN 'array'THEN t.value ELSE '[]'::jsonb END))x),
 wanted(signature)AS(SELECT unnest(ARRAY["""+','.join(q(x)for x in signatures)+"""]::text[])UNION SELECT value->>'signature'FROM tree WHERE jsonb_typeof(value)='object'AND value?'signature'),
 fn AS(SELECT w.signature,p.oid,n.nspname,p.proname,p.proowner::regrole::text owner,p.proacl::text acl,p.proconfig config,p.prosecdef secdef,l.lanname language,p.provolatile::text volatility,p.proisstrict strict,p.proparallel::text parallel,p.proleakproof leakproof,p.prokind::text kind,p.proargnames arg_names,p.proargmodes arg_modes,p.proargtypes::text arg_types,pg_get_function_result(p.oid)returns,md5(p.prosrc)source_md5,md5(pg_get_functiondef(p.oid))ddl_md5,pg_get_functiondef(p.oid)ddl FROM wanted w LEFT JOIN pg_proc p ON p.oid=to_regprocedure(w.signature)LEFT JOIN pg_namespace n ON n.oid=p.pronamespace LEFT JOIN pg_language l ON l.oid=p.prolang),
 relwanted(name)AS(SELECT unnest(ARRAY["""+','.join(q(x)for x in s['relation_refs'])+"""]::text[])UNION SELECT n.nspname||'.'||c.relname FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname IN('clan_innata_private','clan_innata_combat_private','mission_public_owner')AND c.relkind IN('r','v')),
 rel AS(SELECT w.name,c.oid,c.relkind::text kind,c.relowner::regrole::text owner,c.relacl::text acl,c.relrowsecurity rls,c.relforcerowsecurity force_rls,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid))ORDER BY a.attnum),'[]'::jsonb)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)columns,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',x.conname,'ddl',pg_get_constraintdef(x.oid),'validated',x.convalidated)ORDER BY x.conname),'[]'::jsonb)FROM pg_constraint x WHERE x.conrelid=c.oid)constraints,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',t.tgname,'enabled',t.tgenabled::text,'ddl',pg_get_triggerdef(t.oid),'function_md5',md5(pg_get_functiondef(t.tgfoid)))ORDER BY t.tgname),'[]'::jsonb)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal)triggers,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',x.polname,'command',x.polcmd::text,'permissive',x.polpermissive,'roles',to_jsonb(x.polroles),'using',pg_get_expr(x.polqual,x.polrelid),'with_check',pg_get_expr(x.polwithcheck,x.polrelid))ORDER BY x.polname),'[]'::jsonb)FROM pg_policy x WHERE x.polrelid=c.oid)policies,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',x.indexrelid::regclass::text,'ddl',pg_get_indexdef(x.indexrelid))ORDER BY x.indexrelid::regclass::text),'[]'::jsonb)FROM pg_index x WHERE x.indrelid=c.oid)indexes,
 CASE WHEN c.relkind='v'THEN pg_get_viewdef(c.oid,true)END view FROM relwanted w LEFT JOIN pg_class c ON c.oid=to_regclass(w.name))
 SELECT jsonb_build_object('schema_version','combat-innata-post-editor-stage-b-capture/1','captured_at',clock_timestamp(),'root_row',r.row_json,'root_row_sha256',public.combat_v2_sha256(r.row_json),'canonical_preimage',r.canonical_preimage,'revision_sha256',r.revision_sha256,'functions',(SELECT jsonb_agg(to_jsonb(fn)ORDER BY signature)FROM fn),'relations',(SELECT jsonb_agg(to_jsonb(rel)ORDER BY name)FROM rel),
 'release',(SELECT to_jsonb(a)FROM mission_public_owner.release_admissions_v1 a WHERE a.release_sha256=r.revision_sha256),
 'qualification',(SELECT to_jsonb(a)FROM mission_public_owner.public_qualification_attestations_v1 a WHERE a.release_sha256=r.revision_sha256),
 'profile',mission_public_owner.engine_profile_state_v1(r.revision_sha256,'mission-ai-authoring/1'),
 'content_admissions',(SELECT coalesce(jsonb_agg(to_jsonb(a)ORDER BY a.publication_request),'[]'::jsonb)FROM mission_public_owner.mission_content_admissions_v1 a WHERE a.engine_release_sha256=r.revision_sha256),
 'origin',(SELECT to_jsonb(a)FROM mission_public_owner.existing_publications_v1 a WHERE a.request_key='3ff627ec-dbee-423a-9879-8e37f7ad5510'::uuid),
 'capability',(SELECT to_jsonb(a)FROM mission_launch_owner.capabilities a WHERE a.mission_id='6d6c216a-222d-4cba-b2fc-f3e0c199c195'::uuid),
 'active_allowed_sessions',(SELECT coalesce(jsonb_agg(jsonb_build_object('session_id',a.master_session_id,'admission',to_jsonb(a))ORDER BY a.master_session_id),'[]'::jsonb)FROM mission_public_owner.session_admissions_v1 a WHERE mission_public_owner.role_session_allowed_v1(a.master_session_id)),
 'byakugan_configs',(SELECT coalesce(jsonb_agg(to_jsonb(v)ORDER BY v.technique_id,v.config_version),'[]'::jsonb)FROM clan_innata_private.config_versions v WHERE v.technique_id IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid))) AS capture FROM root r;\n"""
def validate_capture(p,s):
 data=json.loads(p.read_text());assert data['schema_version']=='combat-innata-post-editor-stage-b-capture/1'
 assert sha(SUPPLEMENT_CAPTURE.read_bytes())==SUPPLEMENT_SHA,'Actual preflight supplement drift'
 supplement=json.loads(SUPPLEMENT_CAPTURE.read_text());assert len(supplement)==698 and all(x['ok']is True for x in supplement)
 data['_supplemental_function_metadata']=[x['actual_meta']for x in supplement if x.get('actual_meta')is not None]
 assert {x['signature']for x in data['_supplemental_function_metadata']}=={x['signature']for x in EXTRA_DEPENDENCIES}
 data['_capture_provenance']={'actualB_file_sha256':sha(p.read_bytes()),'extra_actual_file_sha256':SUPPLEMENT_SHA,'extra_query_sha256':'8aa4503f64222d0e3a85d510480f2569d7085e3c307036f01969785e26958279','extra_rows':698,'all_ok':True}

 row=data['root_row'];text=row['canonical_preimage'];rev=row['revision_sha256'];root=json.loads(text)
 assert rev!=OLD_ROOT and sha(text)==rev and data['canonical_preimage']==text and data['revision_sha256']==rev
 assert row['state']=='enabled'and row['scope']=='staff'and row['observed_revision_sha256']==rev and row['staff_guards_verified']and row['published_assets_verified']
 assert 2<=len(text.encode())<=524288
 assert root['config'].get('editor_panel_client'), 'StageA-only Root rejected; actual StageB component required'
 assert data['profile']['authoring_enabled']is True and data['profile']['runtime_enabled']is True
 assert data['qualification']and data['release']and data['content_admissions']
 assert any(c['mission_id']=='6d6c216a-222d-4cba-b2fc-f3e0c199c195'for c in data['content_admissions'])
 assert data['origin']['request_key']=='3ff627ec-dbee-423a-9879-8e37f7ad5510'
 assert all(x in data for x in ['git_receipt','pages_receipt','cua_receipt','material_review']), 'Actual external receipts must be attached by PM; no generated PASS'
 assert all(data[x]for x in ['git_receipt','pages_receipt','cua_receipt','material_review'])
 headers={f['signature']:f for f in data['functions']+data['_supplemental_function_metadata']};relations={r['name']:r for r in data['relations']}
 assert set(s['function_refs'])-headers.keys()<={x['signature']for x in EXTRA_DEPENDENCIES},'Capture incomplete functions'
 for signature,expected in EXPECTED_NATIVE.items():
  if signature not in headers:
   assert any(x['signature']==signature and x['classification']=='modified_existing_preimage'for x in EXTRA_DEPENDENCIES),('Missingnative',signature)
  else:assert headers[signature]['ddl_md5']==expected,('Unreviewed native drift',signature)
 for signature in set(s['functions'])-EXPECTED_NATIVE.keys():
  assert headers[signature]['oid']is None,('New helper already exists; recompose',signature)
 assert set(s['new_tables'])<=relations.keys(),'Capture incomplete new relations'
 assert all(relations[n]['oid']is None for n in s['new_tables']),'Existing new relation: composition/review required; no IFNOTEXISTS bypass'
 return data

def pgtext(x):
 if isinstance(x,dict):return '{'+', '.join(json.dumps(k,ensure_ascii=False)+': '+pgtext(v)for k,v in sorted(x.items(),key=lambda kv:(len(kv[0].encode()),kv[0].encode())))+'}'
 if isinstance(x,list):return '['+', '.join(pgtext(v)for v in x)+']'
 return json.dumps(x,ensure_ascii=False,allow_nan=False)
def dq(x,label='ci_literal'):
 assert '$'+label+'$'not in x
 return '$'+label+'$'+x+'$'+label+'$'
def FN_QUERY(expr):
 return """SELECT w.signature,p.oid,n.nspname,p.proname,p.proowner::regrole::text owner,p.proacl::text acl,p.proconfig config,p.prosecdef secdef,l.lanname language,p.provolatile::text volatility,p.proisstrict strict,p.proparallel::text parallel,p.proleakproof leakproof,p.prokind::text kind,p.proargnames arg_names,p.proargmodes arg_modes,p.proargtypes::text arg_types,pg_get_function_result(p.oid)returns,md5(p.prosrc)source_md5,md5(pg_get_functiondef(p.oid))ddl_md5 FROM(SELECT """+expr+"""::text signature)w LEFT JOIN pg_proc p ON p.oid=to_regprocedure(w.signature)LEFT JOIN pg_namespace n ON n.oid=p.pronamespace LEFT JOIN pg_language l ON l.oid=p.prolang"""
def REL_QUERY(expr):
 return """SELECT w.name,c.oid,c.relkind::text kind,c.relowner::regrole::text owner,c.relacl::text acl,c.relrowsecurity rls,c.relforcerowsecurity force_rls,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid))ORDER BY a.attnum),'[]'::jsonb)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)columns,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',x.conname,'ddl',pg_get_constraintdef(x.oid),'validated',x.convalidated)ORDER BY x.conname),'[]'::jsonb)FROM pg_constraint x WHERE x.conrelid=c.oid)constraints,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',t.tgname,'enabled',t.tgenabled::text,'ddl',pg_get_triggerdef(t.oid),'function_md5',md5(pg_get_functiondef(t.tgfoid)))ORDER BY t.tgname),'[]'::jsonb)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal)triggers,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',x.polname,'command',x.polcmd::text,'permissive',x.polpermissive,'roles',to_jsonb(x.polroles),'using',pg_get_expr(x.polqual,x.polrelid),'with_check',pg_get_expr(x.polwithcheck,x.polrelid))ORDER BY x.polname),'[]'::jsonb)FROM pg_policy x WHERE x.polrelid=c.oid)policies,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',x.indexrelid::regclass::text,'ddl',pg_get_indexdef(x.indexrelid))ORDER BY x.indexrelid::regclass::text),'[]'::jsonb)FROM pg_index x WHERE x.indrelid=c.oid)indexes,
 CASE WHEN c.relkind='v'THEN pg_get_viewdef(c.oid,true)END view FROM(SELECT """+expr+"""::text name)w LEFT JOIN pg_class c ON c.oid=to_regclass(w.name)"""
def pg_arg_mode(parameter):
 mode=parameter.mode.value
 assert mode in('d','i','o','b','v','t'),('Unsupported parser parameter mode',mode)
 return 'i'if mode=='d'else mode
def expected_final(s):
 out=[]
 for signature,versions in s['functions'].items():
  item=versions[-1];fn=parse_sql(item['sql'])[0].stmt;opts={x.defname:x.arg for x in fn.options};params=[x for x in fn.parameters or []if x.mode.value not in('o','t')]
  out.append({'signature':signature,'source_md5':hashlib.md5(opts['as'][0].sval.encode()).hexdigest(),'language':opts['language'].sval,'volatility':{'stable':'s','volatile':'v','immutable':'i'}[opts['volatility'].sval if opts.get('volatility')else'volatile'],'secdef':bool(opts['security'].boolval)if opts.get('security')else False,'arg_names':[x.name or '' for x in fn.parameters or []]or None,'arg_modes':([pg_arg_mode(x)for x in fn.parameters]if any(pg_arg_mode(x)!='i'for x in fn.parameters or [])else None),'new':signature not in EXPECTED_NATIVE})
 return out

def emit_backend(data,s,out,preflight_only=False):
 from pglast import parse_plpgsql
 row=data['root_row'];revision=data['revision_sha256'];root=json.loads(row['canonical_preimage']);snap=inventory(s)
 assert sha(pgtext(row))==data['root_row_sha256'],'PG JSONB serialization must reproduce actual fullrow before compact hash guards'
 functions=[{k:v for k,v in f.items()if k!='ddl'}for f in data['functions']+data['_supplemental_function_metadata']]
 fhash={f['signature']:sha(pgtext(f))for f in functions};rhash={r['name']:sha(pgtext(r))for r in data['relations']}
 expected=expected_final(s);sched=schedule(s)
 relation_by_name={r['name']:r for r in data['relations']}
 for item in s['slots']:
  ast=parse_sql(item['sql'])[0].stmt
  if type(ast).__name__=='CreateTrigStmt':
   rel=(ast.relation.schemaname+'.'if ast.relation.schemaname else'')+ast.relation.relname
   assert rel in relation_by_name,('Trigger relation capture missing',rel)
   assert ast.trigname not in {x['name']for x in relation_by_name[rel]['triggers']},('New trigger collision',rel,ast.trigname)

 identity={'schema_version':'combat-innata-integrated-component/1','capture_provenance':data['_capture_provenance'],'parent_editor_release':revision,'source_inputs':snap['inputs'],'consumer_inputs':snap['consumers'],'review_inputs':snap['reviews'],'availability':'staff_only_world_new_features_false','new_mission_QA_claim':False,'contracts':['mission-role-command/3','mission-role-submit/2','byakugan-facing/1','combat-multiplication-tactics/1'],'cumulative_counters_preserved':True}
 pre=[]
 for schema in s['new_schemas']:pre.append("SELECT "+q('Schema_absent:'+schema)+"name,NOT EXISTS(SELECT 1 FROM pg_namespace WHERE nspname="+q(schema)+")ok")
 pre.append("SELECT 'Root_fullrow'::text name,coalesce((SELECT public.combat_v2_sha256(to_jsonb(r))="+q(data['root_row_sha256'])+"FROM mission_factory_owner.editor_release_readiness r WHERE singleton),false)ok")
 pre.append("SELECT 'Function:'||w.key name,public.combat_v2_sha256((SELECT to_jsonb(f)FROM("+FN_QUERY('w.key')+")f))=w.value ok FROM jsonb_each_text("+dq(J({f['signature']:fhash[f['signature']]for f in data['functions']}),'ci_prefn')+"::jsonb)w")
 pre.append("SELECT 'Relation:'||w.key name,public.combat_v2_sha256((SELECT to_jsonb(t)FROM("+REL_QUERY('w.key')+")t))=w.value ok FROM jsonb_each_text("+dq(J(rhash),'ci_prerel')+"::jsonb)w")
 custody=[('origin','mission_public_owner.existing_publications_v1','request_key',data['origin']['request_key']),('capability','mission_launch_owner.capabilities','mission_id',data['capability']['mission_id']),('release','mission_public_owner.release_admissions_v1','release_sha256',revision),('qualification','mission_public_owner.public_qualification_attestations_v1','release_sha256',revision)]
 for name,table,col,key in custody:
  pre.append("SELECT "+q('Custody:'+name)+"name,(SELECT public.combat_v2_sha256(to_jsonb(v))FROM "+table+" v WHERE "+col+'='+q(key)+')='+q(sha(pgtext(data[name])))+'ok')
 pre.append("SELECT 'Profile' name,public.combat_v2_sha256(mission_public_owner.engine_profile_state_v1("+q(revision)+",'mission-ai-authoring/1'))="+q(sha(pgtext(data['profile'])))+'ok')
 pre.append("SELECT 'Certificates' name,public.combat_v2_sha256((SELECT coalesce(jsonb_agg(to_jsonb(c)ORDER BY c.publication_request),'[]'::jsonb)FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256="+q(revision)+'))='+q(sha(pgtext(data['content_admissions'])))+'ok')
 pre.append("SELECT 'Byakugan_original_configs' name,public.combat_v2_sha256((SELECT coalesce(jsonb_agg(to_jsonb(v)ORDER BY v.technique_id,v.config_version),'[]'::jsonb)FROM clan_innata_private.config_versions v WHERE v.technique_id IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid)))="+q(sha(pgtext(data['byakugan_configs'])))+'ok')
 pre=["SELECT x.name,x.ok,NULL::jsonb actual_meta FROM("+x+")x"for x in pre]
 for dep in EXTRA_DEPENDENCIES:
  name=dep['signature'];condition="m.ddl_md5="+q(dep['baseline_ddl_md5'])+"AND m.source_md5="+q(dep['baseline_source_md5'])+"AND public.combat_v2_sha256(to_jsonb(m))="+q(sha(pgtext(next(x for x in data['_supplemental_function_metadata']if x['signature']==name))))+"AND m.owner='postgres'AND NOT EXISTS(SELECT 1 FROM aclexplode(coalesce(m.acl::aclitem[],acldefault('f','postgres'::regrole)))a WHERE a.grantee<>'postgres'::regrole)"
  pre.append("SELECT "+q('Extra_dependency:'+name)+"name,coalesce("+condition+",false)ok,to_jsonb(m)actual_meta FROM("+FN_QUERY(q(name))+")m")
 # Full independently reviewed native seal closure, not just functions already in B capture.
 assert sha(SEAL_CAPTURE.read_bytes())==SEAL_CAPTURE_SHA
 closure=json.loads(SEAL_CAPTURE.read_text())[0]['complete_seal_capture'];assert closure['missing']==[]and len(closure['headers'])==106
 fnkeys=['oid','nspname','proname','owner','acl','config','secdef','language','volatility','strict','parallel','leakproof','kind','arg_names','arg_modes','arg_types','returns','source_md5','ddl_md5']
 sealmeta={h['requested_signature']:{'signature':h['requested_signature'],**{k:h[k]for k in fnkeys}}for h in closure['headers']}
 pre.append("SELECT 'Native_seal_closure:'||w.key name,coalesce((SELECT to_jsonb(m)FROM("+FN_QUERY('w.key')+")m)=w.value,false)ok,NULL::jsonb actual_meta FROM jsonb_each("+dq(J(sealmeta),'ci_seal_closure')+"::jsonb)w")
 esc=closure['elemental_schema'];pre.append("SELECT 'Native_seal_schema' name,coalesce((SELECT n.nspowner::regrole::text="+q(esc['owner'])+"AND n.nspacl::text="+q(esc['acl'])+"AND(SELECT count(*)FROM pg_proc p WHERE p.pronamespace=n.oid)="+str(esc['function_count'])+" FROM pg_namespace n WHERE n.nspname='combat_v2_elemental_internal'),false)ok,NULL::jsonb actual_meta")
 pre_sql='SELECT * FROM('+(' UNION ALL '.join(pre))+')ci_preflight ORDER BY name;\n';assert len(parse_sql(pre_sql))==1;(out/'PREFLIGHT.sql').write_text(pre_sql)
 if preflight_only:
  print('Readonly preflight emitted; no installer or recovery emitted',len(pre_sql.encode()),sha(pre_sql));return
 pieces=["-- Combat+Innata backend stage. Exact material review required before apply.\n-- New consumer deployment and Staff enable are separate receipt-bound stage; World flags remain false.\nBEGIN;\nDO $ci_install$\nDECLARE ci_before mission_factory_owner.editor_release_readiness;ci_before_functions jsonb;ci_old_trigger_bindings jsonb;ci_trigger_oid oid;ci_trigger_expected jsonb;ci_check record;ci_sig text;ci_meta jsonb;ci_expected jsonb;ci_old jsonb;ci_post jsonb:='{}';ci_relpost jsonb:='{}';ci_rel text;ci_baseline jsonb;ci_node record;ci_key text;ci_header jsonb;ci_root jsonb;ci_db jsonb;ci_cfg jsonb;ci_identity jsonb;ci_text text;ci_rev text;ci_binding jsonb;ci_payload jsonb;ci_cert jsonb;ci_request uuid;ci_item jsonb;ci_sessions jsonb;BEGIN\nIF current_user<>'postgres'OR session_user<>'postgres'OR auth.uid()IS NOT NULL THEN RAISE EXCEPTION 'COMBAT_INNATA_OPERATOR_REQUIRED';END IF;IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'COMBAT_INNATA_RELEASE_BUSY';END IF;SELECT * INTO STRICT ci_before FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;"]
 pieces.append('ci_before_functions:='+dq(J([f for f in functions if f['signature']in EXPECTED_NATIVE]),'ci_before_functions')+'::jsonb;FOR ci_check IN '+pre_sql.rstrip().rstrip(';')+" LOOP IF ci_check.ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'COMBAT_INNATA_PREFLIGHT:%',ci_check.name;END IF;IF ci_check.actual_meta IS NOT NULL AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(ci_before_functions)x WHERE x->>'oid'=ci_check.actual_meta->>'oid')THEN ci_before_functions:=ci_before_functions||jsonb_build_array(ci_check.actual_meta);END IF;END LOOP;")
 pieces.append("SELECT coalesce(jsonb_agg(jsonb_build_object('session_id',a.master_session_id,'admission',to_jsonb(a))ORDER BY a.master_session_id),'[]'::jsonb)INTO ci_sessions FROM mission_public_owner.session_admissions_v1 a WHERE mission_public_owner.role_session_allowed_v1(a.master_session_id);")
 pieces.append("IF nullif(current_setting('app.combat_innata_material_review_ref',true),'')IS NULL OR coalesce(current_setting('app.combat_innata_material_review_sha256',true),'')!~'^[0-9a-f]{64}$'THEN RAISE EXCEPTION 'COMBAT_INNATA_MATERIAL_REVIEW_REQUIRED';END IF;")
 old_rel_oids=sorted({int(r['oid'])for r in data['relations']if r['oid']is not None})
 pieces.append("SELECT coalesce(jsonb_object_agg(n.nspname||'.'||c.relname||':'||t.tgname,jsonb_build_object('relation_oid',t.tgrelid::text,'trigger_name',t.tgname,'callback_oid',t.tgfoid::text,'function_md5',md5(pg_get_functiondef(t.tgfoid)))),'{}'::jsonb)INTO ci_old_trigger_bindings FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace WHERE NOT t.tgisinternal AND t.tgrelid=ANY(ARRAY["+','.join(str(o)for o in old_rel_oids)+"]::oid[]);")
 # Source-only packaging guards are replaced by the complete captured guard prefix.
 # All runtime assertions and final availability predicates in function bodies remain.
 deferred=[]
 for item,plan in zip(s['slots'],sched['slots']):
  action=plan['action']
  if action=='defer-ACL-until-all-functions-and-relations-exist':deferred.append(item['sql']);continue
  if action!='emit-reviewed-statement-in-source-order':continue
  pieces.append('EXECUTE '+dq(item['sql'],'ci_stmt'+str(item['ordinal']))+';')
 pieces+=['EXECUTE '+dq(sql,'ci_deferred'+str(i))+';'for i,sql in enumerate(deferred)]
 pieces.append("REVOKE ALL ON ALL FUNCTIONS IN SCHEMA clan_innata_narrative_private,combat_facing_private FROM PUBLIC,anon,authenticated,service_role;GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA clan_innata_narrative_private,combat_facing_private TO postgres;")
 pieces.append('FOR ci_expected IN SELECT value FROM jsonb_array_elements('+dq(J(expected),'ci_expected')+"::jsonb)LOOP ci_sig:=ci_expected->>'signature';SELECT to_jsonb(f)INTO ci_meta FROM("+FN_QUERY('ci_sig')+")f;IF ci_meta->>'source_md5'IS DISTINCT FROM ci_expected->>'source_md5'OR ci_meta->>'language'IS DISTINCT FROM ci_expected->>'language'OR ci_meta->>'volatility'IS DISTINCT FROM ci_expected->>'volatility'OR ci_meta->'secdef'IS DISTINCT FROM ci_expected->'secdef'OR ci_meta->'arg_names'IS DISTINCT FROM ci_expected->'arg_names'OR ci_meta->'arg_modes'IS DISTINCT FROM ci_expected->'arg_modes'OR ci_meta->>'owner'IS DISTINCT FROM 'postgres'THEN RAISE EXCEPTION 'COMBAT_INNATA_FINAL_SOURCE:%',ci_sig USING DETAIL=jsonb_build_object('expected',ci_expected,'actual_metadata',ci_meta)::text;END IF;SELECT value INTO ci_old FROM jsonb_array_elements(ci_before_functions)WHERE (value->>'oid')::oid=to_regprocedure(ci_sig);IF ci_expected->'new'='false'::jsonb AND(ci_meta-ARRAY['signature','source_md5','ddl_md5'])IS DISTINCT FROM(ci_old-ARRAY['signature','source_md5','ddl_md5'])THEN RAISE EXCEPTION 'COMBAT_INNATA_DECLARATION_DRIFT:%',ci_sig;END IF;IF ci_expected->'new'='true'::jsonb AND(ci_meta->'config'IS DISTINCT FROM jsonb_build_array('search_path=\"\"')OR ci_meta->>'parallel'<>'u'OR ci_meta->'strict'<>'false'::jsonb OR ci_meta->'leakproof'<>'false'::jsonb OR ci_meta->>'kind'<>'f'OR EXISTS(SELECT 1 FROM aclexplode(coalesce((ci_meta->>'acl')::aclitem[],acldefault('f','postgres'::regrole)))a WHERE a.grantee<>'postgres'::regrole))THEN RAISE EXCEPTION 'COMBAT_INNATA_NEW_PRIVATE_METADATA:%',ci_sig;END IF;ci_post:=ci_post||jsonb_build_object(ci_meta->>'oid',ci_meta);END LOOP;")
 # Existing functions not targeted remain exactly as captured, including all21Editor ports.
 target_oids={f['oid']for f in functions if f['signature']in EXPECTED_NATIVE};remaining={f['signature']:fhash[f['signature']]for f in functions if f['oid']not in target_oids and f['signature']not in s['functions']}
 pieces.append('FOR ci_check IN SELECT * FROM jsonb_each_text('+dq(J(remaining),'ci_unchanged_functions')+"::jsonb)LOOP ci_sig:=ci_check.key;IF public.combat_v2_sha256((SELECT to_jsonb(f)FROM("+FN_QUERY('ci_sig')+" )f))IS DISTINCT FROM ci_check.value THEN RAISE EXCEPTION 'COMBAT_INNATA_UNTOUCHED_FUNCTION:%',ci_sig;END IF;END LOOP;")
 new_tables=s['new_tables'];new_names=dq(J(new_tables),'ci_new_tables')
 pieces.append('FOR ci_item IN SELECT value FROM jsonb_array_elements('+new_names+"::jsonb)LOOP ci_rel:=ci_item#>>'{}';SELECT to_jsonb(t)INTO ci_meta FROM("+REL_QUERY('ci_rel')+")t;IF ci_meta->>'oid'IS NULL OR ci_meta->>'kind'<>'r'OR ci_meta->>'owner'<>'postgres'OR ci_meta->'rls'<>'true'::jsonb OR ci_meta->'force_rls'<>'true'::jsonb OR ci_meta->'policies'<>'[]'::jsonb OR EXISTS(SELECT 1 FROM aclexplode(coalesce((ci_meta->>'acl')::aclitem[],acldefault('r','postgres'::regrole)))a WHERE a.grantee<>'postgres'::regrole)THEN RAISE EXCEPTION 'COMBAT_INNATA_PRIVATE_RELATION:%',ci_rel;END IF;ci_relpost:=ci_relpost||jsonb_build_object(ci_rel,public.combat_v2_sha256(ci_meta));END LOOP;")
 for dep in EXTRA_DEPENDENCIES:
  if dep['classification']=='modified_existing_preimage':continue
  pieces.append('ci_sig:='+q(dep['signature'])+';SELECT to_jsonb(f)INTO ci_meta FROM('+FN_QUERY('ci_sig')+")f;SELECT value INTO ci_old FROM jsonb_array_elements(ci_before_functions)WHERE(value->>'oid')::oid=to_regprocedure(ci_sig);IF ci_meta IS DISTINCT FROM ci_old THEN RAISE EXCEPTION 'COMBAT_INNATA_EXTRA_IMMUTABLE_DEPENDENCY:%',ci_sig;END IF;")
 # Only the three reviewed existing tables gain trigger/check metadata changes;
 # ledger and receipt tables change exactly their named CHECK predicates.
 changed_relations={'clan_innata_private.actor_state','clan_innata_combat_private.combat_state','clan_innata_combat_private.combat_receipts','clan_innata_combat_private.combat_resource_ledger','public.combat_v2_declarations'}
 target_old_hashes={f['ddl_md5']for f in functions if f['signature']in EXPECTED_NATIVE};callback_relations={r['name']for r in data['relations']if any(t['function_md5']in target_old_hashes for t in r['triggers'])};changed_relations|=callback_relations
 untouched_relations={r['name']:rhash[r['name']]for r in data['relations']if r['name']not in new_tables and r['name']not in changed_relations}
 pieces.append('FOR ci_check IN SELECT * FROM jsonb_each_text('+dq(J(untouched_relations),'ci_unchanged_relations')+"::jsonb)LOOP ci_rel:=ci_check.key;IF public.combat_v2_sha256((SELECT to_jsonb(t)FROM("+REL_QUERY('ci_rel')+" )t))IS DISTINCT FROM ci_check.value THEN RAISE EXCEPTION 'COMBAT_INNATA_UNTOUCHED_RELATION:%',ci_rel;END IF;END LOOP;")
 for i,rel in enumerate(data['relations']):
  if rel['name']in new_tables or rel['name']not in changed_relations:continue
  name=rel['name'];expr=REL_QUERY(q(name))
  if name not in changed_relations:
   pieces.append('IF public.combat_v2_sha256((SELECT to_jsonb(t)FROM('+expr+')t))IS DISTINCT FROM '+q(rhash[name])+"THEN RAISE EXCEPTION 'COMBAT_INNATA_EXISTING_RELATION:%',"+q(name)+';END IF;')
  else:
   excluded=(['constraints']if name in ['clan_innata_combat_private.combat_state','clan_innata_combat_private.combat_receipts','clan_innata_combat_private.combat_resource_ledger']else[])+(['triggers']if name in callback_relations or name in ['clan_innata_private.actor_state','public.combat_v2_declarations','clan_innata_combat_private.combat_state']else[])
   old={k:v for k,v in rel.items()if k not in excluded};arr='ARRAY['+','.join(q(k)for k in excluded)+']'
   pieces.append('SELECT to_jsonb(t)INTO ci_meta FROM('+expr+')t;IF public.combat_v2_sha256(ci_meta-'+arr+')IS DISTINCT FROM '+q(sha(pgtext(old)))+"THEN RAISE EXCEPTION 'COMBAT_INNATA_RELATION_SCOPE:%',"+q(name)+';END IF;')
   # Retain all preexisting triggers/constraints except the exact five replaced checks.
   replaced={'combat_state_technique_id_check','combat_receipts_chakra_spent_check','combat_resource_ledger_expected_amount_check','combat_resource_ledger_committed_amount_check','combat_resource_ledger_applied_amount_check'}
   for key in excluded:
    original=[v for v in rel[key]if v['name']not in replaced]
    if key=='triggers':
     pieces.append('FOR ci_item IN SELECT value FROM jsonb_array_elements('+dq(J(original),'ci_preserve'+str(i)+key)+"::jsonb)LOOP SELECT tgfoid INTO STRICT ci_trigger_oid FROM pg_trigger WHERE tgrelid="+q(name)+"::regclass AND tgname=ci_item->>'name'AND NOT tgisinternal;IF ci_trigger_oid::text IS DISTINCT FROM ci_old_trigger_bindings#>>ARRAY["+q(name+':')+"||(ci_item->>'name'),'callback_oid']THEN RAISE EXCEPTION 'COMBAT_INNATA_TRIGGER_CALLBACK_OID:%',"+q(name)+";END IF;ci_trigger_expected:=ci_item;IF ci_post?ci_trigger_oid::text THEN ci_trigger_expected:=jsonb_set(ci_trigger_expected,'{function_md5}',ci_post#>ARRAY[ci_trigger_oid::text,'ddl_md5'],false);END IF;IF NOT(ci_meta->'triggers'@>jsonb_build_array(ci_trigger_expected))THEN RAISE EXCEPTION 'COMBAT_INNATA_EXISTING_TRIGGER:%/%',"+q(name)+",ci_item->>'name';END IF;END LOOP;")
     continue
    pieces.append('IF EXISTS(SELECT 1 FROM jsonb_array_elements('+dq(J(original),'ci_preserve'+str(i)+key)+"::jsonb)x WHERE NOT(ci_meta->"+q(key)+"@>jsonb_build_array(x)))THEN RAISE EXCEPTION 'COMBAT_INNATA_EXISTING_SUBOBJECT:%',"+q(name+':'+key)+';END IF;')
   pieces.append('ci_relpost:=ci_relpost||jsonb_build_object('+q(name)+',public.combat_v2_sha256(ci_meta));')
 pieces.append("FOR ci_item IN SELECT value FROM jsonb_each(ci_old_trigger_bindings)LOOP SELECT tgfoid INTO STRICT ci_trigger_oid FROM pg_trigger WHERE tgrelid=(ci_item->>'relation_oid')::oid AND tgname=ci_item->>'trigger_name'AND NOT tgisinternal;IF ci_trigger_oid::text IS DISTINCT FROM ci_item->>'callback_oid'THEN RAISE EXCEPTION 'COMBAT_INNATA_EXISTING_CALLBACK_OID:%',ci_item->>'trigger_name';END IF;END LOOP;")
 pieces.append("FOR ci_check IN SELECT key,value FROM jsonb_each("+dq(J(sealmeta),'ci_post_seal_closure')+"::jsonb)LOOP ci_expected:=coalesce(ci_post->(ci_check.value->>'oid'),ci_check.value)||jsonb_build_object('signature',ci_check.key);SELECT to_jsonb(f)INTO ci_meta FROM("+FN_QUERY('ci_check.key')+")f;IF ci_meta IS DISTINCT FROM ci_expected THEN RAISE EXCEPTION 'COMBAT_INNATA_NATIVE_SEAL_CLOSURE:%',ci_check.key;END IF;END LOOP;")
 pieces.append("PERFORM clan_innata_private.runtime_release_assert();PERFORM clan_innata_private.eligibility_release_assert();IF(SELECT to_jsonb(g)FROM clan_innata_narrative_private.gate_v1 g WHERE singleton)IS DISTINCT FROM '{\"singleton\":true,\"staff_enabled\":false,\"public_enabled\":false,\"control_version\":1}'::jsonb OR(SELECT public_enabled FROM combat_facing_private.release_gate WHERE singleton)IS DISTINCT FROM false OR EXISTS(SELECT 1 FROM combat_panel_private.multiplication_tactics_release_gate WHERE ordinary_enabled OR master_enabled OR generic_enabled)THEN RAISE EXCEPTION 'COMBAT_INNATA_INITIAL_AVAILABILITY';END IF;")
 # Rebind only current db_core headers; historical config/recovery references stay intact.
 pieces.append('ci_identity:='+dq(J(identity),'ci_identity')+"::jsonb;ci_root:=ci_before.canonical_preimage::jsonb;FOR ci_node IN WITH RECURSIVE walk(path,node)AS(SELECT ARRAY['db_core']::text[],ci_root->'db_core'UNION ALL SELECT w.path||c.k,c.v FROM walk w CROSS JOIN LATERAL(SELECT key k,value v FROM jsonb_each(CASE jsonb_typeof(w.node)WHEN 'object'THEN w.node ELSE '{}'::jsonb END)UNION ALL SELECT(ord-1)::text,value FROM jsonb_array_elements(CASE jsonb_typeof(w.node)WHEN 'array'THEN w.node ELSE '[]'::jsonb END)WITH ORDINALITY a(value,ord))c)SELECT path,node FROM walk WHERE jsonb_typeof(node)='object'AND node?'signature'LOOP ci_sig:=CASE WHEN split_part(ci_node.node->>'signature','(',1)LIKE '%.%'THEN(ci_node.node->>'signature')ELSE 'public.'||(ci_node.node->>'signature')END;IF ci_post?(to_regprocedure(ci_sig)::oid::text)THEN ci_header:=ci_node.node;ci_sig:=to_regprocedure(ci_sig)::oid::text;FOR ci_key IN SELECT jsonb_object_keys(ci_header)LOOP IF ci_key IN('source_md5','ddl_md5')THEN ci_header:=jsonb_set(ci_header,ARRAY[ci_key],ci_post#>ARRAY[ci_sig,ci_key],false);END IF;END LOOP;ci_root:=jsonb_set(ci_root,ci_node.path,ci_header,false);END IF;END LOOP;")
 pieces.append("ci_db:=(ci_root->'db_core')||jsonb_build_object('combat_innata_functions',ci_post,'combat_innata_relations',ci_relpost);ci_db:=jsonb_set(ci_db,'{sha256}',to_jsonb(public.combat_v2_sha256(jsonb_build_object('inventory',ci_db-'sha256','source_component',ci_identity))),false);ci_cfg:=(ci_root->'config')||jsonb_build_object('combat_innata',ci_identity);ci_cfg:=jsonb_set(ci_cfg,'{sha256}',to_jsonb(public.combat_v2_sha256(ci_cfg-'sha256')),false);ci_root:=jsonb_set(jsonb_set(ci_root,'{db_core}',ci_db,false),'{config}',ci_cfg,false);ci_root:=jsonb_set(ci_root,'{contract,code_identity_sha256}',to_jsonb(public.combat_v2_sha256(ci_identity)),false);ci_root:=jsonb_set(ci_root,'{recovery,semantic_identity_sha256}',to_jsonb(public.combat_v2_sha256(ci_identity)),false);IF ci_root->'ui'IS DISTINCT FROM(ci_before.canonical_preimage::jsonb)->'ui'OR ci_root->'edge_bundles'IS DISTINCT FROM(ci_before.canonical_preimage::jsonb)->'edge_bundles'OR ci_root#>'{config,editor_panel}'IS DISTINCT FROM(ci_before.canonical_preimage::jsonb)#>'{config,editor_panel}'OR ci_root#>'{config,editor_panel_client}'IS DISTINCT FROM(ci_before.canonical_preimage::jsonb)#>'{config,editor_panel_client}'THEN RAISE EXCEPTION 'COMBAT_INNATA_EDITOR_OR_ASSETS_CHANGED';END IF;ci_text:=ci_root::text;IF octet_length(ci_text)>524288 THEN RAISE EXCEPTION 'COMBAT_INNATA_ROOT_TOO_LARGE';END IF;ci_rev:=encode(extensions.digest(convert_to(ci_text,'UTF8'),'sha256'),'hex');")
 # No independent material review is invented: require the PM to bind the exact
 # final review ref+sha via transaction-local settings before calling installer.
 pieces.append("IF nullif(current_setting('app.combat_innata_material_review_ref',true),'')IS NULL OR coalesce(current_setting('app.combat_innata_material_review_sha256',true),'')!~'^[0-9a-f]{64}$'THEN RAISE EXCEPTION 'COMBAT_INNATA_MATERIAL_REVIEW_REQUIRED';END IF;UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=ci_text,revision_sha256=ci_rev,observed_revision_sha256=ci_rev,client_build='mission-factory-admin/2:'||ci_rev,independent_review_ref=current_setting('app.combat_innata_material_review_ref',true),updated_at=clock_timestamp()WHERE singleton;")
 ar=data['release'];aq=data['qualification'];ap=data['profile']
 pieces.append("ci_binding:=jsonb_build_object('db_sha256',ci_root#>>'{db_core,sha256}','edge_sha256',"+q(ar['edge_sha256'])+",'client_sha256',public.combat_v2_sha256(ci_root->'ui'),'configuration_sha256',ci_root#>>'{config,sha256}');INSERT INTO mission_public_owner.release_admissions_v1(release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)VALUES(ci_rev,ci_binding->>'db_sha256',ci_binding->>'edge_sha256',ci_binding->>'client_sha256',ci_binding->>'configuration_sha256','mission-public-admission/1',current_setting('app.combat_innata_material_review_ref',true),"+q(ar['staff_evidence_ref'])+",clock_timestamp(),true);INSERT INTO mission_public_owner.engine_profile_events_v1(event_id,engine_release_sha256,profile_key,expected_control_version,control_version,authoring_enabled,runtime_enabled,reason)VALUES(extensions.uuid_generate_v5('3ff627ec-dbee-423a-9879-8e37f7ad5510',ci_rev||':profile:1'),ci_rev,'mission-ai-authoring/1',0,1,true,true,'Preserve installed Editor and public mission; new Combat Innata features initially private Staff only');")
 pieces.append('ci_payload:='+dq(J(aq['payload']),'ci_qualification')+"::jsonb;ci_payload:=ci_payload||jsonb_build_object('revision_sha256',ci_rev,'bindings',ci_binding,'reuse_evidence',(ci_payload->'reuse_evidence')||jsonb_build_object('new_mission_QA_claim',false,'combat_innata_component',ci_identity,'scope','Public native contract compatibility with new gated Staff branches; no fresh clean runtime claim'),'independent_review',jsonb_build_object('ref',current_setting('app.combat_innata_material_review_ref',true),'sha256',current_setting('app.combat_innata_material_review_sha256',true),'P0',0,'P1',0,'P2',0));INSERT INTO mission_public_owner.public_qualification_attestations_v1(release_sha256,request_key,payload,payload_sha256,positive_staff_evidence_ref,authorized_test_manifest_ref,created_by)VALUES(ci_rev,extensions.uuid_generate_v5('3ff627ec-dbee-423a-9879-8e37f7ad5510',ci_rev||':qualification'),ci_payload,mission_factory_owner.sha(ci_payload),"+q(aq['positive_staff_evidence_ref'])+','+q(aq['authorized_test_manifest_ref'])+','+q(aq['created_by'])+");IF mission_public_owner.engine_qualification_v1(ci_rev,true)IS NULL THEN RAISE EXCEPTION 'COMBAT_INNATA_QUALIFICATION';END IF;")
 for i,certificate in enumerate(data['content_admissions']):
  pieces.append('ci_cert:='+dq(J(certificate['payload']),'ci_certificate'+str(i))+"::jsonb;ci_request:=extensions.uuid_generate_v5("+q(certificate['publication_request'])+"::uuid,ci_rev||':content-adoption');ci_cert:=ci_cert||jsonb_build_object('request_key',ci_request,'engine_release_sha256',ci_rev,'created_at',clock_timestamp());INSERT INTO mission_public_owner.mission_content_admissions_v1(request_key,mission_id,config_version,engine_release_sha256,publication_request,payload,payload_sha256)VALUES(ci_request,"+q(certificate['mission_id'])+'::uuid,'+str(int(certificate['config_version']))+',ci_rev,'+q(certificate['publication_request'])+"::uuid,ci_cert,mission_factory_owner.sha(ci_cert));IF mission_public_owner.content_admission_v1("+q(certificate['mission_id'])+'::uuid,ci_rev,'+q(certificate['publication_request'])+"::uuid,true)IS NULL THEN RAISE EXCEPTION 'COMBAT_INNATA_ADOPTION';END IF;")
 pieces.append("FOR ci_item IN SELECT value FROM jsonb_array_elements(ci_sessions)LOOP IF NOT mission_public_owner.role_session_allowed_v1((ci_item->>'session_id')::uuid)OR ci_item->'admission'IS DISTINCT FROM(SELECT to_jsonb(a)FROM mission_public_owner.session_admissions_v1 a WHERE a.master_session_id=(ci_item->>'session_id')::uuid)THEN RAISE EXCEPTION 'COMBAT_INNATA_SESSION_CONTINUITY';END IF;END LOOP;IF mission_public_owner.engine_profile_state_v1(ci_rev,'mission-ai-authoring/1')->'authoring_enabled'IS DISTINCT FROM 'true'::jsonb THEN RAISE EXCEPTION 'COMBAT_INNATA_EDITOR_DISABLED';END IF;RAISE NOTICE 'COMBAT_INNATA_BACKEND_ROOT:%',ci_rev;END $ci_install$;COMMIT;")
 sql='\n'.join(pieces)+'\n';parse_sql(sql);parse_plpgsql(sql.replace('ci_before mission_factory_owner.editor_release_readiness','ci_before record'));(out/'INSTALL.sql').write_text(sql)
 # Conservative disable: no rows deleted, old bodies restored or resources rewritten.
 recovery="""-- Forward recovery of the integrated engine only; no historical Root/body rollback.
BEGIN;
DO $ci_recover$ DECLARE r mission_factory_owner.editor_release_readiness; n bigint;ci_sig text;ci_meta jsonb;ci_header jsonb;BEGIN
IF current_user<>'postgres'OR session_user<>'postgres'OR auth.uid()IS NOT NULL THEN RAISE EXCEPTION 'COMBAT_INNATA_OPERATOR_REQUIRED';END IF;
IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'COMBAT_INNATA_RELEASE_BUSY';END IF;
SELECT * INTO STRICT r FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE;
IF r.canonical_preimage::jsonb#>>'{config,combat_innata,schema_version}'IS DISTINCT FROM 'combat-innata-integrated-component/1'THEN RAISE EXCEPTION 'COMBAT_INNATA_RECOVERY_SCOPE';END IF;
IF EXISTS(SELECT 1 FROM public.combat_v2_sessions s JOIN public.locations l ON l.id=s.location_id JOIN mission_generic_owner.encounters e ON e.encounter_id=s.id WHERE l.is_test AND s.closed_at IS NULL)OR EXISTS(SELECT 1 FROM mission_generic_owner.panel_permits p JOIN public.master_v2_sessions m ON m.id=p.master_session_id JOIN public.locations l ON l.id=m.location_id WHERE l.is_test AND p.consumed_at IS NULL AND p.created_at>clock_timestamp()-interval '150 seconds')THEN RAISE EXCEPTION 'COMBAT_INNATA_RECOVERY_SCOPE_ACTIVE';END IF;
IF EXISTS(SELECT 1 FROM clan_innata_narrative_private.states_v1 s JOIN clan_innata_narrative_private.contexts_v1 c USING(context_id)WHERE s.active AND c.active)OR EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_state st JOIN public.combat_v2_sessions cs ON cs.id=st.session_id WHERE st.active AND cs.closed_at IS NULL AND st.technique_id IN('8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid))THEN RAISE EXCEPTION 'COMBAT_INNATA_RECOVERY_REQUIRES_NORMAL_OFF_DRAIN';END IF;
UPDATE clan_innata_narrative_private.gate_v1 SET staff_enabled=false,public_enabled=false,control_version=control_version+1 WHERE singleton;
UPDATE combat_facing_private.release_gate SET staff_enabled=false,public_enabled=false,revision=revision+1 WHERE singleton;
UPDATE combat_panel_private.multiplication_tactics_release_gate SET staff_enabled=false,ordinary_enabled=false,master_enabled=false,generic_enabled=false,version=version+1 WHERE singleton;
IF mission_public_owner.engine_qualification_v1(r.revision_sha256,true)IS NULL THEN RAISE EXCEPTION 'COMBAT_INNATA_RECOVERY_LEGACY';END IF;
END $ci_recover$;COMMIT;
"""
 bodyguard="FOR ci_header IN SELECT value FROM jsonb_each(r.canonical_preimage::jsonb#>'{db_core,combat_innata_functions}')LOOP ci_sig:=ci_header->>'signature';SELECT to_jsonb(f)INTO ci_meta FROM("+FN_QUERY('ci_sig')+")f;IF ci_meta IS DISTINCT FROM ci_header THEN RAISE EXCEPTION 'COMBAT_INNATA_RECOVERY_BODY_DRIFT:%',ci_sig;END IF;END LOOP;\n"
 recovery=recovery.replace("IF EXISTS(SELECT 1 FROM public.combat_v2_sessions s",bodyguard+"IF EXISTS(SELECT 1 FROM public.combat_v2_sessions s",1)
 parse_sql(recovery);parse_plpgsql(recovery.replace('r mission_factory_owner.editor_release_readiness','r record'));(out/'RECOVERY.sql').write_text(recovery)
 (out/'MATERIAL.json').write_text(json.dumps({'schema_version':'combat-innata-material/1','capture_sha256':sha(pgtext(data)),'parent_release':revision,'source_identity':identity,'files':{n:{'bytes':len((out/n).read_bytes()),'sha256':sha((out/n).read_bytes())}for n in ['INSTALL.sql','RECOVERY.sql','PREFLIGHT.sql']},'new_functions':27,'existing_functions':31,'final_functions':58,'new_tables':16,'review':'REQUIRED','apply':'NOT_RUN','Staff':'NOT_RUN','consumer_stage':'NOT_EMITTED_PENDING_ACTUAL_BACKEND_AND_DEPLOY_RECEIPTS'},indent=2)+'\n')
 print('Backend material emitted for independent review only',len(sql.encode()),sha(sql))

def main():
 a=argparse.ArgumentParser();a.add_argument('--capture-query',action='store_true');a.add_argument('--preflight-only',action='store_true');a.add_argument('--plan',action='store_true');a.add_argument('--baseline',type=Path,default=DEFAULT_CAPTURE);a.add_argument('--out',type=Path,default=Path('/private/tmp/tus-combat-innata-compose-20261102'));opt=a.parse_args();s=scan()
 if opt.capture_query:
  sql=capture_query(s);assert len(parse_sql(sql))==1;print(sql,end='');return
 opt.out.mkdir(parents=True,exist_ok=True);plan=inventory(s)
 if opt.plan:
  (opt.out/'INVENTORY.json').write_text(json.dumps(plan,indent=2)+'\n');print('Inventory prepared:58 functions,5 overlays,16 new tables; no installer emitted');return
 if not opt.baseline.exists():raise SystemExit('AWAITING_ACTUAL_EDITOR_STAGE_B: no installer or recovery emitted')
 data=validate_capture(opt.baseline,s)
 (opt.out/'BASELINE_ACCEPTED.json').write_text(json.dumps({'input_sha256':sha(opt.baseline.read_bytes()),'revision':data['revision_sha256'],'status':'CAPTURE_ACCEPTED_REQUIRES_FINAL_COMPOSITION_REVIEW'},indent=2)+'\n')
 if opt.preflight_only:emit_backend(data,s,opt.out,preflight_only=True);return
 review=json.loads(SOURCE3_REVIEW.read_text());assert review['findings']=={'P0':0,'P1':0,'P2':0}and sha(SOURCE3_REVIEW.read_bytes())=='cc5e024b90545c5ec8df8398e482d219c7ff2f449d07f263aabd7e38d98eb8fb'
 emit_backend(data,s,opt.out)
if __name__=='__main__':main()
