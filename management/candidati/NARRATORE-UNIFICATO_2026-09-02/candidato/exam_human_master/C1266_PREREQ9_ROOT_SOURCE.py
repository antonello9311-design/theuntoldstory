"""SOURCE DRAFT. SQL/text emitter only; no network, SQL execution or gameplay.
Fresh genuine reviewed inputs are mandatory; this file is not a production grant.
"""
import argparse, copy, datetime, hashlib, json, pathlib, re
E=pathlib.Path('/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master')
BASELINE_REF={'path':str(E/'C1266_COUNT_DIAG3_CURRENT85_OPERATOR_BASELINE_ACTUAL.json'),'sha256':'910470f824e0ec1a6435bfb384ee96637aee23e5878e6545eba4acb2554a9140'}
NATIVE_CONSUMER_REF={'path':str(E/'C1266_TIMEOUT_ASYNC_CONTINUITY_SOURCE_FUNDEFS.json'),'sha256':'a54896fbf9c6e192b199a416e38c26484561108665b3ebcc6f2e27d1b3f11666'}
NATIVE_G2_ORIGIN='4f58bb7fb726c870a489b9db6ea088719e0b2e6153b2b3f98bf6d8be928e1b50'
ACTORS=['b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b','f0856d53-83a6-4de0-bc0c-12c87916e665']
LOC='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'
NEW={'mission_generic_owner.c1266_generation_timeout_terminal_proof_v1(uuid)','public.mission_generic_dispatch_async_status_v1(uuid,jsonb)'}
STATUS='public.mission_generic_dispatch_async_status_v1(uuid,jsonb)'
TABLES={'readiness':'mission_factory_owner.editor_release_readiness','g2':'mission_factory_owner.c464_control','authoring':'mission_factory_owner.provider_authoring_runtime','admissions':'mission_factory_owner.provider_authoring_admissions','runtime':'mission_generic_owner.runtime_policy','provider':'mission_generic_owner.provider_policy','flow':'mission_generic_owner.flow_runtime_gate'}
def sha(x):return hashlib.sha256(x.encode()if isinstance(x,str)else x).hexdigest()
def canon(x):return json.dumps(x,sort_keys=True,separators=(',',':'),ensure_ascii=False)
def q(x):return "'"+(canon(x)if not isinstance(x,str)else x).replace("'","''")+"'"
def verified(ref):
 p=pathlib.Path(ref['path']);assert p.is_file()and not p.is_symlink();assert sha(p.read_bytes())==ref['sha256'],'INPUT_DRIFT';return json.loads(p.read_text())
def instant(s):return datetime.datetime.fromisoformat(s.replace('Z','+00:00'))
def source_baseline():
 b=verified(BASELINE_REF)
 assert isinstance(b,dict)and all(k in b for k in ['actual_core85','actual_all_branch109','actual_helpers','current_headers111','configuration_schema7','frame']),'SOURCE_BASELINE_SHAPE'
 assert [len(b[k])for k in ['actual_core85','actual_all_branch109','actual_helpers','current_headers111','configuration_schema7']]==[85,109,2,111,7],'SOURCE_BASELINE_PARTITION'
 assert b['frame']['post']['g2']['source_sha256']==NATIVE_G2_ORIGIN,'NATIVE_ORIGIN_BASELINE_DRIFT'
 return b
def native_origin():
 source_baseline();facts=verified(NATIVE_CONSUMER_REF)
 f=next(h for h in facts if h['signature']=='mission_generic_owner.c1266_clean_staff_admission_v1(uuid,boolean,boolean)')
 assert f['source_md5']=='ddf38f4d3b39114d74bd00ba6a2310ac'and NATIVE_G2_ORIGIN in f['definition']and 'cc.source_sha256'in f['definition'],'NATIVE_CONSUMER_ORIGIN_FACT_DRIFT'
 return NATIVE_G2_ORIGIN
def names():
 b=source_baseline()
 branch={h['signature']for h in b['actual_all_branch109']};oldhelpers={h['signature']for h in b['actual_helpers']};oldcore={h['signature']for h in b['actual_core85']}
 assert len(branch)==109 and len(oldhelpers)==2 and len(oldcore)==85
 assert not(branch&oldhelpers)and oldcore<=(branch|oldhelpers)and not NEW&(branch|oldhelpers)
 return {'legacy_branch':branch,'helpers':oldhelpers|NEW,'core':oldcore|NEW,'full':branch|oldhelpers|NEW}
def schema_query():
 values=','.join('('+q(t)+')'for t in sorted(TABLES.values()))
 return "WITH wanted(name)AS(VALUES "+values+")SELECT jsonb_agg(jsonb_build_object('name',w.name,'oid',c.oid::bigint,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,'columns',(SELECT jsonb_agg(jsonb_build_object('num',a.attnum,'name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'not_null',a.attnotnull,'identity',a.attidentity,'generated',a.attgenerated,'default',pg_get_expr(d.adbin,d.adrelid))ORDER BY a.attnum)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped),'constraints',coalesce((SELECT jsonb_agg(jsonb_build_object('oid',co.oid::bigint,'name',co.conname,'type',co.contype,'validated',co.convalidated,'definition',pg_get_constraintdef(co.oid,false))ORDER BY co.oid)FROM pg_constraint co WHERE co.conrelid=c.oid),'[]'::jsonb),'indexes',coalesce((SELECT jsonb_agg(jsonb_build_object('oid',i.indexrelid::bigint,'definition',pg_get_indexdef(i.indexrelid))ORDER BY i.indexrelid)FROM pg_index i WHERE i.indrelid=c.oid),'[]'::jsonb),'triggers',coalesce((SELECT jsonb_agg(jsonb_build_object('oid',t.oid::bigint,'name',t.tgname,'enabled',t.tgenabled,'function_oid',t.tgfoid::bigint,'definition',pg_get_triggerdef(t.oid,false))ORDER BY t.oid)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal),'[]'::jsonb),'policies',coalesce((SELECT jsonb_agg(jsonb_build_object('oid',pol.oid::bigint,'name',pol.polname,'cmd',pol.polcmd,'permissive',pol.polpermissive,'roles',to_jsonb(pol.polroles),'qual',pg_get_expr(pol.polqual,pol.polrelid),'check',pg_get_expr(pol.polwithcheck,pol.polrelid))ORDER BY pol.oid)FROM pg_policy pol WHERE pol.polrelid=c.oid),'[]'::jsonb))ORDER BY w.name)FROM wanted w LEFT JOIN pg_class c ON c.oid=to_regclass(w.name)"
def validate_schema(live):
 expected=source_baseline()['configuration_schema7']
 assert {t['name']:t for t in live['configuration_schema']}=={t['name']:t for t in expected},'CURRENT_SCHEMA7_DRIFT_REBASE_REQUIRED'
 rr=next(t for t in expected if t['name']==TABLES['readiness']);assert not rr['triggers']
 assert any(c['name']=='editor_release_readiness_canonical_preimage_check1'for c in rr['constraints'])
def query():
 source_baseline()
 ns=names();values=','.join('('+q(s)+')'for s in sorted(ns['full']))
 headers="SELECT jsonb_agg(jsonb_build_object('signature',w.signature,'oid',p.oid::bigint,'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile,'language',l.lanname,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)))ORDER BY w.signature)FROM wanted w LEFT JOIN pg_proc p ON p.oid=to_regprocedure(w.signature)LEFT JOIN pg_language l ON l.oid=p.prolang"
 rows=[]
 for k,t in TABLES.items():
  expression="(SELECT coalesce(jsonb_agg(to_jsonb(x)ORDER BY x.actor_user),'[]'::jsonb)FROM "+t+" x WHERE actor_user=ANY(ARRAY["+','.join(q(a)+'::uuid'for a in ACTORS)+"]))"if k=='admissions'else"(SELECT to_jsonb(x)FROM "+t+" x WHERE singleton)"
  rows.extend([q(k),expression])
 return "WITH wanted(signature)AS(VALUES "+values+")SELECT jsonb_build_object('schema_version','c1266-timeout-root-live/1','captured_at',clock_timestamp(),'headers',("+headers+"),'configuration_schema',("+schema_query()+"),'rows',jsonb_build_object("+','.join(rows)+"),'staff_open',(SELECT count(*)FROM public.master_v2_sessions WHERE location_id="+q(LOC)+"::uuid AND closed_at IS NULL),'combat_open',(SELECT count(*)FROM public.combat_v2_sessions WHERE location_id="+q(LOC)+"::uuid AND closed_at IS NULL),'active_ai',(SELECT count(*)FROM public.master_v2_sessions WHERE owner_kind='ai_service'AND closed_at IS NULL),'active_provider',(SELECT count(*)FROM mission_generic_owner.work_items WHERE state IN('claimed','authorized','provider_started','uncertain')AND finalized_at IS NULL))AS timeout_root_live;"
def green(ref,required):
 r=verified(ref);assert r['finding_counts']=={'P0':0,'P1':0,'P2':0},'REVIEW_NOT_GREEN'
 covered={x['path']:x['sha256']for x in r['reviewed_refs']}
 assert all(covered.get(x['path'])==x['sha256']for x in required),'REVIEW_COVERAGE'
 return r
def fresh(x,phase):
 live=verified(x['live_ref']);assert live['schema_version']=='c1266-timeout-root-live/1'
 assert verified(x['capture_receipt_ref'])['raw_ref']==x['live_ref'],'GENUINE_CAPTURE_RECEIPT_REQUIRED'
 validate_schema(live)
 now=datetime.datetime.now(datetime.timezone.utc);age=now-instant(live['captured_at']);assert datetime.timedelta(0)<=age<=datetime.timedelta(minutes=5),'FRESH_CAPTURE_REQUIRED'
 assert live['staff_open']==live['combat_open']==live['active_ai']==live['active_provider']==0,'RESOURCE_OR_PROVIDER_ACTIVE'
 assert set(live['rows'])==set(TABLES)and len(live['rows']['admissions'])==2
 assert sorted(a['actor_user']for a in live['rows']['admissions'])==ACTORS
 hh={h['signature']:h for h in live['headers']};assert set(hh)==names()['full']
 required=names()['full']-{STATUS}if phase=='H0'else names()['full']
 assert all(hh[s]['oid']and hh[s]['source_md5']and hh[s]['ddl_md5']for s in required),'GENUINE_OID_REQUIRED'
 if phase=='H0':assert hh[STATUS]['oid']is None,'H0_CURRENT112_EXPECTED'
 else:assert len(required)==113
 protected=verified(x['protected_ref']);assert protected['protected_field_count']==48 and protected['projection_sha256']==x['expected_protected_sha256']
 assert datetime.timedelta(0)<=now-instant(protected['captured_at'])<=datetime.timedelta(minutes=5),'PROTECTED_CAPTURE_STALE'
 covered=[x['live_ref'],x['capture_receipt_ref'],x['protected_ref'],x['authority_ref']]
 if phase not in ['H0','RECOVER_HOLD']:covered.extend([x['assets_ref'],x['expected_headers_ref'],x['backend_freeze_ref'],x['UI_freeze_ref'],x['root_contract_ref']])
 green(x['actual_review_ref'],covered)
 authority=verified(x['authority_ref']);assert authority['operation']==phase and authority['provider_calls_authorized']==0 and not authority['public_enable']
 assert authority['actor_user_ids']==ACTORS and authority['location_id']==LOC and instant(authority['expires_at'])>now
 return live,hh,authority

def metadata_sql(h):
 return "IF NOT EXISTS(SELECT 1 FROM pg_proc p JOIN pg_language l ON l.oid=p.prolang WHERE p.oid="+str(h['oid'])+" AND p.oid=to_regprocedure("+q(h['signature'])+")AND md5(p.prosrc)="+q(h['source_md5'])+" AND md5(pg_get_functiondef(p.oid))="+q(h['ddl_md5'])+" AND p.proacl::text IS NOT DISTINCT FROM "+('NULL'if h['acl']is None else q(h['acl']))+" AND pg_get_userbyid(p.proowner)="+q(h['owner'])+" AND coalesce(to_jsonb(p.proconfig),'null'::jsonb)IS NOT DISTINCT FROM "+q(h['config'])+"::jsonb AND p.prosecdef="+str(h['secdef']).lower()+" AND p.provolatile::text="+q(h['volatility'])+" AND l.lanname="+q(h['language'])+")THEN RAISE EXCEPTION 'ROOT_CURRENT_METADATA_DRIFT';END IF;"
def prefix(live,hh,phase):
 s="BEGIN;SET LOCAL lock_timeout='5s';SET LOCAL statement_timeout='45s';DO $root$DECLARE actual jsonb;op_pre jsonb;op_bytes text;op_R text;op_birth timestamptz;op_expiry timestamptz;BEGIN IF current_user<>'postgres'THEN RAISE EXCEPTION 'ROOT_OWNER_REQUIRED';END IF;PERFORM pg_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0));"
 s+="LOCK TABLE "+','.join(TABLES.values())+" IN SHARE ROW EXCLUSIVE MODE;"
 for k,t in TABLES.items():
  read="SELECT coalesce(jsonb_agg(to_jsonb(x)ORDER BY x.actor_user),'[]'::jsonb)INTO actual FROM "+t+" x WHERE actor_user=ANY(ARRAY["+','.join(q(a)+'::uuid'for a in ACTORS)+"]);"if k=='admissions'else"SELECT to_jsonb(x)INTO actual FROM "+t+" x WHERE singleton FOR UPDATE;"
  s+=read+"IF actual IS DISTINCT FROM "+q(live['rows'][k])+"::jsonb THEN RAISE EXCEPTION 'ROOT_ROW_CAS_DRIFT';END IF;"
 s+=''.join(metadata_sql(h)for h in hh.values()if h['oid'])
 R=live['rows']['readiness']['revision_sha256']
 s+=public_closed_sql(q(R))
 s+="IF clock_timestamp()>="+q((instant(live['captured_at'])+datetime.timedelta(minutes=5)).isoformat())+"::timestamptz THEN RAISE EXCEPTION 'ROOT_ORIGINAL_CAPTURE_EXPIRED';END IF;"
 # Direct metadata checks only. No old Core111 assertion/Root renewal.
 s+="IF EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE owner_kind='ai_service'AND closed_at IS NULL)OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items WHERE state IN('claimed','authorized','provider_started','uncertain')AND finalized_at IS NULL)THEN RAISE EXCEPTION 'ROOT_ACTIVE_WORK';END IF;"
 s+="SELECT ("+schema_query()+")INTO actual;IF actual IS DISTINCT FROM "+q(live['configuration_schema'])+"::jsonb THEN RAISE EXCEPTION 'ROOT_SCHEMA7_CAS_DRIFT';END IF;"
 return s

def public_closed_sql(R):
 return "IF EXISTS(SELECT 1 FROM mission_generic_owner.flow_runtime_gate WHERE singleton AND public_enabled)OR EXISTS(SELECT 1 FROM mission_public_owner.release_admissions_v1 WHERE release_sha256="+R+" AND public_enabled)OR EXISTS(SELECT 1 FROM mission_public_owner.publications_v2 WHERE release_revision_sha256="+R+" AND mission_id='5878822d-dc03-4ac2-ad0b-1547f0ab3fc0'::uuid AND target='public'AND(state='open'OR visibility='open'))THEN RAISE EXCEPTION 'ROOT_PUBLIC_CURRENT_NOT_CLOSED';END IF;"
def off_sql():
 return "UPDATE mission_generic_owner.runtime_policy SET mode='off'WHERE singleton;UPDATE mission_generic_owner.provider_policy SET enabled=false WHERE singleton;UPDATE mission_generic_owner.flow_runtime_gate SET public_enabled=false WHERE singleton;UPDATE mission_factory_owner.c464_control SET runtime_enabled=false,authoring_enabled=false WHERE singleton;UPDATE mission_factory_owner.provider_authoring_runtime SET enabled=false WHERE singleton;UPDATE mission_factory_owner.provider_authoring_admissions SET enabled=false WHERE actor_user=ANY(ARRAY["+','.join(q(a)+'::uuid'for a in ACTORS)+"]);"
def held(rows):
 assert rows['runtime']['mode']=='off'and not rows['provider']['enabled']and not rows['g2']['runtime_enabled']and not rows['g2']['authoring_enabled']and not rows['authoring']['enabled']and not rows['flow']['public_enabled']and all(not a['enabled']for a in rows['admissions']),'HOLD_REQUIRED'
def refresh_header_tree(value,hh):
 if isinstance(value,dict):
  if 'signature'in value and 'source_md5'in value:
   sig=value['signature'];sig=sig if '.'in sig.split('(')[0]else'public.'+sig
   assert sig in hh,'UNKNOWN_CURRENT_HEADER_ALIAS'
   return {k:(str(hh[sig][k])if k=='oid'and isinstance(v,str)else copy.deepcopy(hh[sig][k]))if k in hh[sig]and k!='signature'else copy.deepcopy(v)for k,v in value.items()}
  return {k:refresh_header_tree(v,hh)for k,v in value.items()}
 if isinstance(value,list):return [refresh_header_tree(v,hh)for v in value]
 return copy.deepcopy(value)
def assert_header_tree(value,hh):
 if isinstance(value,dict):
  if 'signature'in value and 'source_md5'in value:
   sig=value['signature'];sig=sig if '.'in sig.split('(')[0]else'public.'+sig
   assert sig in hh and value['source_md5']==hh[sig]['source_md5']and value['ddl_md5']==hh[sig]['ddl_md5'],'ROOT_ALIAS_CURRENT_BODY_DRIFT'
  for v in value.values():assert_header_tree(v,hh)
 elif isinstance(value,list):
  for v in value:assert_header_tree(v,hh)
def config_identity(config):
 projected=copy.deepcopy(config);projected.pop('sha256',None)
 for k in ['grant_id','not_before','expires_at']:projected['c1266_clean_staff'].pop(k,None)
 projected['c1266_opening'].pop('admission_not_before',None)
 return sha(canon(projected))
def identity(pre):return sha(canon({'db':pre['db_core']['sha256'],'edge':pre['edge_bundles'],'UI':pre['ui'],'config':pre['config']['sha256']}))
def validated_assets(x):
 source=verified(x['backend_freeze_ref']);assets=verified(x['assets_ref']);ui=verified(x['UI_freeze_ref'])
 assert assets['qualified']is True and assets['edge_file_count']==14 and assets['UI_revision']>=2
 target=next(r for r in source['immutable_leaves']if r['name']=='C1266_GENERATION_TIMEOUT_ASYNC_EDGE_BUNDLE_FILES.json');files=verified(target);actual=verified(assets['edge_raw_ref'])
 assert {f['name']:f['content']for f in actual['files']}=={f['name']:f['content']for f in files}
 assert actual['name']=='mission_generic_ai'and actual['status']=='ACTIVE'and actual['verify_jwt']is False
 uit=next(r for r in ui['files']if r['path'].endswith('ASYNC_UI_SOURCE.mjs'));raw=verified(assets['UI_raw_ref']);assert sha(raw['content'])==uit['sha256']==assets['UI_sha256']
 assert assets['UI_sha256']!='d09996dcafbec5a0029f631e9b632820922082cdc8e5395a6c4791e7ff0444c6'
 publication=verified(assets['publication_ref']);assert publication['verified']is True and publication['domain_source_sha256']==uit['sha256']and publication['pages_conclusion']=='success'
 assert publication['git_head']==assets['UI']['git_head']and publication['git_blob']==assets['UI']['files']['mission-generic-ui.mjs']['git_blob']
 green(x['actual_review_ref'],[assets['edge_raw_ref'],assets['UI_raw_ref'],assets['publication_ref']])
 selfref={'path':str(pathlib.Path(__file__).resolve()),'sha256':sha(pathlib.Path(__file__).read_bytes())}
 source_review=green(x['source_review_ref'],[x['backend_freeze_ref'],x['UI_freeze_ref'],x['root_contract_ref'],selfref,BASELINE_REF,NATIVE_CONSUMER_REF])
 assert source_review['current_phase_role_barrier_verified']is True and source_review['no_future_role_assumption']is True,'CURRENT_PHASE_ALL_REQUIRED_ROLES_UNPROVEN'
 return assets

def registered(x,live,hh):
 rr=live['rows']['readiness'];assert rr['state']=='prepared'and rr['scope']=='staff'and rr['staff_guards_verified']and rr['published_assets_verified']
 assert sha(rr['canonical_preimage'])==rr['revision_sha256']==rr['observed_revision_sha256'],'REGISTERED_ROOT_BYTE_DRIFT'
 pre=json.loads(rr['canonical_preimage']);assert set(pre)=={'schema_version','contract','db_core','edge_bundles','ui','config','recovery'}
 post=verified(x['register_post_ref']);receipt=verified(x['register_post_receipt_ref']);assert receipt['raw_ref']==x['register_post_ref']
 green(x['actual_review_ref'],[x['register_post_ref'],x['register_post_receipt_ref']])
 assert post['schema_version']=='c1266-timeout-root-live/1'
 assert datetime.timedelta(0)<=datetime.datetime.now(datetime.timezone.utc)-instant(post['captured_at'])<=datetime.timedelta(minutes=5),'REGISTER_POST_EXPIRED'
 assert post['rows']['readiness']['canonical_preimage']==rr['canonical_preimage']and post['rows']['readiness']['revision_sha256']==rr['revision_sha256']
 policy=pre['config']['c1266_clean_staff'];birth=instant(policy['not_before']);expiry=instant(policy['expires_at']);now=datetime.datetime.now(datetime.timezone.utc)
 assert birth<=now<expiry and expiry-birth==datetime.timedelta(minutes=30),'REGISTERED_IMMUTABLE_CLOCK'
 assert re.fullmatch('[a-f0-9-]{36}',policy['grant_id'])and pre['config']['c1266_opening']['admission_not_before']==policy['not_before']
 assert_header_tree(pre['db_core'],hh)
 ns=names();core={h['signature']:h for h in pre['db_core']['c1266_functions']};allh={h['signature']:h for h in pre['db_core']['all_function_headers']}
 assert set(core)==ns['core']and len(core)==87 and set(allh)==ns['full']and len(allh)==113
 assert all(core[k]==hh[k]for k in core)and all(allh[k]==hh[k]for k in allh),'REGISTERED_CURRENT113_DRIFT'
 pol=pre['config']['generation_timeout_async'];assert pol['backend_freeze']==x['backend_freeze_ref']and pol['UI_freeze']==x['UI_freeze_ref']and pol['root_contract']==x['root_contract_ref']
 assert pol['db_composition_ref']==x['db_composition_ref']and pol['campaign_ref']==x['campaign_ref'],'REGISTERED_COMPOSITION_PROVENANCE_DRIFT'
 reviewed_db_composition(x,live,hh)
 campaign=reviewed_campaign(x,verified(x['authority_ref']))
 assert pol['operational_budget']==campaign['operational_budget'],'REGISTERED_OPERATION_BUDGET_DRIFT'
 assert pol['timing']=={'generation_ms':240000,'work_lease_ms':360000,'count_ms':120000,'finalize_margin_ms':20000,'paid_worker_ms':400000}
 assert pol['required_role_invariant']=='ALL_REQUIRED_CURRENT_PHASE_ROLES'and pol['future_roles_invented']is False
 expected=sha(canon({'core87':pre['db_core']['c1266_functions'],'full113':pre['db_core']['all_function_headers'],'backend_freeze':x['backend_freeze_ref']}));assert pre['db_core']['sha256']==expected
 assert pre['config']['sha256']==config_identity(pre['config'])and pre['contract']['code_identity_sha256']==identity(pre)==pre['recovery']['code_identity_sha256']
 assets=validated_assets(x);assert pre['edge_bundles']==[assets['edge']]and pre['ui']==assets['UI']
 assert pre['config']['c1266_opening']['limits']=={'input_tokens_limit':24000,'output_tokens_limit':20000,'generation_limit':14,'http_limit':28,'scene_cost_budget_usd':'0.3136'}
 review=x['source_review_ref'];assert rr['independent_review_ref']==review['path']==pre['config']['c1266_opening']['independent_review_ref']
 assert live['rows']['g2']['review_sha256']==review['sha256']==pre['config']['staff_finite_ia_budget']['composed_review_sha256']
 assert live['rows']['g2']['source_sha256']==native_origin()==pre['config']['staff_finite_ia_budget']['native_g2_source_sha256']
 assert live['rows']['g2']['root_authority_sha256']==pre['contract']['authority_sha256']and live['rows']['g2']['release_sha256']==rr['revision_sha256']and live['rows']['g2']['expires_at']==policy['expires_at']and live['rows']['g2']['complete']is True
 assert all(a['release_sha256']==rr['revision_sha256']and a['expires_at']==policy['expires_at']for a in live['rows']['admissions'])
 return pre,policy

def enable(x,live,hh,authority):
 pre,policy=registered(x,live,hh);R=live['rows']['readiness']['revision_sha256']
 assert authority['staff_enable']is True and authority['target_root_sha256']==R and authority['Root_grant_minutes']==30
 browser=verified(x['browser_ref']);now=datetime.datetime.now(datetime.timezone.utc)
 assert browser['normal_authorized_access']is True and browser['Mac_unlocked']is True and sorted(browser['actors'])==ACTORS
 assert browser['profile_names']=={'Firefox':'Riuji','Chrome':'Tamako'}and browser['profile_identity_verified']is True
 assert datetime.timedelta(0)<=now-instant(browser['captured_at'])<=datetime.timedelta(minutes=5),'BROWSER_EXPIRED'
 qa=verified(x['QA_budget_ref']);assert qa['approved']is True and qa['root_sha256']==R and qa['duration_minutes']==30
 observation=qa['operation']=='Staff_SCHEMA_OBSERVATION'
 if observation:
  # OBS1 is a separately nominated observation, never a relabelled FULL_QA ceiling.
  budget={'max_count_calls':3,'max_generation_calls':3,'max_provider_http_calls':6,'max_reserved_usd':'0.075','max_scenes':1,'retries_allowed':False,'includes_incipit':True}
  assert qa['observation_id']=='OBS1'and authority['observation_id']=='OBS1','OBSERVATION_SCOPE_REQUIRED'
  assert all(type(qa[k])is int for k in ['max_count_calls','max_generation_calls','max_provider_http_calls','max_scenes'])
  assert {k:qa[k]for k in budget}==budget and authority['operational_budget']==budget,'OBSERVATION_BUDGET_REQUIRED'
  case=verified(qa['case_plan_ref']);green(x['actual_review_ref'],[qa['case_plan_ref']])
  assert case['observation_id']=='OBS1'and case['operational_budget']==budget,'OBSERVATION_CASE_REQUIRED'
 else:
  assert qa['operation']=='Staff_FULL_QA'and qa.get('observation_id')is None and authority.get('observation_id')is None,'QA_OPERATION_SCOPE_REQUIRED'
  assert qa['max_count_calls']==40 and qa['max_generation_calls']==40 and qa['max_provider_http_calls']==80 and qa['max_reserved_usd']=='0.992'
  campaign=reviewed_campaign(x,authority)
  assert qa['campaign_ref']==x['campaign_ref']and qa['operational_budget']==campaign['operational_budget'],'FULL_QA_OPERATIONAL_BUDGET_REQUIRED'
 assert qa['actors']==ACTORS and qa['location_id']==LOC and qa['current_phase_roles_required']is True and qa['future_roles_invented']is False
 compatibility=verified(x['operational_budget_compatibility_ref']);assert compatibility['native_compatible']is True and compatibility['ordinary_limits_unchanged']is True
 assert compatibility['evidence_kind']=='INDEPENDENT_NATIVE_CONSUMER_SOURCE_AND_GENUINE_CURRENT_CONFIG'and compatibility['review_ref']==x['source_review_ref']
 assert compatibility['Root_sha256']==R and compatibility['QA_budget_ref']==x['QA_budget_ref'],'UNPROVEN_OPERATIONAL_BUDGET'
 if not observation:
  assert compatibility['campaign_ref']==x['campaign_ref']and compatibility['operational_budget']==campaign['operational_budget'],'UNPROVEN_FULL_QA_OPERATION'
  assert compatibility['automatic_bound_ref']==campaign['automatic_bound_ref']and compatibility['cleanup_route_ref']==campaign['cleanup_route_ref'],'UNPROVEN_FULL_QA_PREREQUISITES'
  assert compatibility['automatic_chain_reservation_before_each_trigger']is True and compatibility['future_failure_cleanup_qualified']is True,'UNPROVEN_FULL_QA_CLOSURE'
 if observation:
  assert compatibility['observation_id']=='OBS1'and compatibility['operational_budget']==budget,'UNPROVEN_OBSERVATION_BUDGET'
  assert compatibility['case_plan_ref']==qa['case_plan_ref'],'UNPROVEN_OBSERVATION_CASE'
  assert compatibility['automatic_path_upper_bound']=={'count_calls':3,'generation_calls':3,'provider_http_calls':6},'UNPROVEN_OBSERVATION_BOUND'
  assert compatibility['all_automatic_branches_covered']is True and compatibility['no_retry_verified']is True,'UNPROVEN_OBSERVATION_BRANCHES'
 green(x['actual_review_ref'],[x['browser_ref'],x['QA_budget_ref'],x['operational_budget_compatibility_ref']])
 deadline=min(instant(policy['expires_at']),instant(live['captured_at'])+datetime.timedelta(minutes=5),instant(browser['captured_at'])+datetime.timedelta(minutes=5),instant(authority['expires_at']),instant(qa['expires_at']))
 assert deadline>now and (instant(policy['expires_at'])-now)>=datetime.timedelta(seconds=360),'INSUFFICIENT_ROOT_WINDOW'
 guard="IF clock_timestamp()>="+q(deadline.isoformat())+"::timestamptz THEN RAISE EXCEPTION 'ROOT_ENABLE_IMMUTABLE_DEADLINE';END IF;"
 actorarray='ARRAY['+','.join(q(a)+'::uuid'for a in ACTORS)+']'
 s=guard+"IF(SELECT count(*)FROM public.profiles p WHERE p.id=ANY("+actorarray+")AND p.role IN('admin','master')AND public._combat_presente(p.id,"+q(LOC)+"::uuid)IS TRUE)<>2 THEN RAISE EXCEPTION 'ROOT_ENABLE_ACTORS_NOT_PRESENT';END IF;"
 s+="UPDATE mission_generic_owner.runtime_policy SET mode='test'WHERE singleton AND mode='off';IF NOT FOUND THEN RAISE EXCEPTION 'ROOT_ENABLE_RUNTIME_CAS';END IF;UPDATE mission_generic_owner.provider_policy SET enabled=true WHERE singleton AND NOT enabled;IF NOT FOUND THEN RAISE EXCEPTION 'ROOT_ENABLE_PROVIDER_CAS';END IF;UPDATE mission_factory_owner.c464_control SET runtime_enabled=true WHERE singleton AND complete AND NOT runtime_enabled AND NOT authoring_enabled AND release_sha256="+q(R)+" AND expires_at="+q(policy['expires_at'])+"::timestamptz;IF NOT FOUND THEN RAISE EXCEPTION 'ROOT_ENABLE_CONTROL_CAS';END IF;UPDATE mission_factory_owner.provider_authoring_admissions SET enabled=true WHERE actor_user=ANY("+actorarray+")AND NOT enabled AND release_sha256="+q(R)+" AND expires_at="+q(policy['expires_at'])+"::timestamptz;IF(SELECT count(*)FROM mission_factory_owner.provider_authoring_admissions WHERE actor_user=ANY("+actorarray+")AND enabled AND release_sha256="+q(R)+")<>2 THEN RAISE EXCEPTION 'ROOT_ENABLE_ADMISSIONS_CAS';END IF;UPDATE mission_factory_owner.editor_release_readiness SET state='enabled',updated_at=clock_timestamp()WHERE singleton AND state='prepared'AND revision_sha256="+q(R)+" AND canonical_preimage="+q(live['rows']['readiness']['canonical_preimage'])+";IF NOT FOUND THEN RAISE EXCEPTION 'ROOT_ENABLE_READINESS_CAS';END IF;"
 s+=''.join(metadata_sql(h)for h in hh.values())+guard
 s+="IF(SELECT canonical_preimage FROM mission_factory_owner.editor_release_readiness WHERE singleton)IS DISTINCT FROM "+q(live['rows']['readiness']['canonical_preimage'])+" OR EXISTS(SELECT 1 FROM mission_generic_owner.flow_runtime_gate WHERE singleton AND public_enabled)OR EXISTS(SELECT 1 FROM mission_factory_owner.provider_authoring_runtime WHERE singleton AND enabled)OR EXISTS(SELECT 1 FROM mission_factory_owner.c464_control WHERE singleton AND authoring_enabled)THEN RAISE EXCEPTION 'ROOT_ENABLE_PUBLIC_OR_ROOT_DRIFT';END IF;"
 return s+public_closed_sql(q(R))

def reviewed_db_composition(x,live,hh):
 # The current header is never accepted as its own source qualification.
 c=verified(x['db_composition_ref'])
 assert c['schema_version']=='c1266-reviewed-db-composition9/1','DB_COMPOSITION_REQUIRED'
 fields=['baseline_actual_ref','baseline_raw_ref','delta_baseline_ref','delta_source_ref','delta_contract_ref','delta_static_ref','Human_continuity_ref']
 refs=[c[k]for k in fields]
 green(x['source_review_ref'],[x['db_composition_ref']]+refs)
 green(x['actual_review_ref'],[x['db_composition_ref'],x['expected_headers_ref']])
 baseline=verified(c['baseline_actual_ref']);plan=verified(c['delta_baseline_ref'])
 raw=verified(c['baseline_raw_ref']);assert not raw.get('isError'),'BASELINE_TOOL_ERROR'
 envelope=json.loads(raw['content'][0]['text'])['result']
 payload=json.loads(re.search(r'<untrusted-data-[^>]+>\n(.*?)\n</untrusted-data-',envelope,re.S)[1])
 assert len(payload)==1 and len(payload[0])==1 and next(iter(payload[0].values()))==baseline,'BASELINE_RAW_NORMALIZATION_DRIFT'
 verified(c['delta_contract_ref']);verified(c['delta_static_ref']);verified(c['Human_continuity_ref'])
 before={h['signature']:h for h in plan['headers_before']};after={h['signature']:h for h in plan['headers_after_expected']}
 historical={h['signature']:h for h in baseline['headers']}
 assert before==historical and set(before)==set(after)==names()['full'],'DB_COMPOSITION_BASELINE_DRIFT'
 assert baseline['configuration_schema']==plan['schema7']==live['configuration_schema'],'DB_COMPOSITION_SCHEMA_DRIFT'
 target='mission_staff_abort_private.quiescent_v1(uuid)'
 assert before[target]['source_md5']=='0a1a9f8f45c796442115e7417e4d9343','REVIEWED_CLEANUP7_BASE_REQUIRED'
 assert before['mission_generic_owner.unified_batch_payload(uuid)']['source_md5']=='b062fcf23872bbda58f9c3e5cec1d5f4','REVIEWED_WRITER6_BASE_REQUIRED'
 assert [s for s in before if before[s]!=after[s]]==[target],'ONLY_REVIEWED_QUIESCENT_TRANSITION'
 assert {k:v for k,v in before[target].items()if k not in ['source_md5','ddl_md5']}=={k:v for k,v in after[target].items()if k not in ['source_md5','ddl_md5']},'QUIESCENT_NON_BODY_METADATA_DRIFT'
 source=pathlib.Path(c['delta_source_ref']['path']);assert source.is_file()and not source.is_symlink()and sha(source.read_bytes())==c['delta_source_ref']['sha256'],'DELTA_SOURCE_DRIFT'
 from pglast.parser import parse_sql_json
 parsed=json.loads(parse_sql_json(source.read_text()))['stmts']
 assert len(parsed)==1 and set(parsed[0]['stmt'])=={'CreateFunctionStmt'},'SINGLE_CREATE_FUNCTION_AST_REQUIRED'
 statement=parsed[0]['stmt']['CreateFunctionStmt']
 name=lambda nodes:'.'.join(n['String']['sval']for n in nodes)
 assert statement['replace']is True and name(statement['funcname'])=='mission_staff_abort_private.quiescent_v1','PARSED_FUNCTION_NAME_DRIFT'
 args=statement['parameters'];assert len(args)==1 and name(args[0]['FunctionParameter']['argType']['names'])=='uuid','PARSED_FUNCTION_ARGUMENT_DRIFT'
 assert args[0]['FunctionParameter']['mode']=='FUNC_PARAM_DEFAULT'and 'defexpr'not in args[0]['FunctionParameter'],'PARSED_FUNCTION_MODE_DRIFT'
 assert name(statement['returnType']['names'])=='pg_catalog.bool','PARSED_FUNCTION_RETURN_DRIFT'
 bodies=[o['DefElem']['arg']['List']['items']for o in statement['options']if o['DefElem']['defname']=='as']
 assert len(bodies)==1 and len(bodies[0])==1,'SINGLE_SQL_FUNCTION_BODY_REQUIRED'
 assert hashlib.md5(bodies[0][0]['String']['sval'].encode()).hexdigest()==after[target]['source_md5'],'PLANNED_QUIESCENT_BODY_DRIFT'
 assert after==hh==verified(x['expected_headers_ref']),'ACTUAL113_NOT_REVIEWED_COMPOSITION'
 return c

def reviewed_campaign(x,authority):
 c=verified(x['campaign_ref'])
 budget={'max_count_calls':32,'max_generation_calls':32,'max_provider_http_calls':64,'max_reserved_usd':'0.7936','max_scenes':1,'retries_allowed':False,'includes_incipit':True}
 assert c['schema_version']=='c1266-prerequisites9-finite-campaign/1'and c['operation']=='Staff_FULL_QA','CAMPAIGN_SCOPE_REQUIRED'
 assert c['operational_budget']==budget==authority['operational_budget'],'EXPLICIT_RESIDUAL_OPERATION_BUDGET_REQUIRED'
 assert c['duration_minutes']==30 and c['root_windows']==1,'SINGLE_FINITE_CAMPAIGN_REQUIRED'
 assert c['cumulative_before']=={'count_calls':8,'generation_calls':6,'provider_http_calls':14,'accounted_usd':'0.1137409','unknown_billable':8,'settled':6},'HISTORICAL_COUNTS_NOT_PRESERVED'
 assert c['historical_ceiling']=={'count_calls':40,'generation_calls':40,'provider_http_calls':80,'reserved_usd':'0.992'},'HISTORICAL_CEILING_DRIFT'
 refs=[c[k]for k in ['ledger_ref','case_plan_ref','automatic_bound_ref','cleanup_route_ref']]
 for r in refs:verified(r)
 green(x['source_review_ref'],[x['campaign_ref']]+refs)
 green(x['actual_review_ref'],[x['campaign_ref']])
 assert c['automatic_chain_reservation_before_each_trigger']is True and c['future_failure_cleanup_qualified']is True,'CAMPAIGN_PREREQUISITES_OPEN'
 return c

def compose(x,live,hh):
 ns=names();pre=json.loads(live['rows']['readiness']['canonical_preimage']);assert set(pre)=={'schema_version','contract','db_core','edge_bundles','ui','config','recovery'}
 source=verified(x['backend_freeze_ref']);assert source['classification']=='BACKEND_SOURCE_FREEZE_NOT_INTEGRATED_INSTALL_OR_GAMEPLAY_CERTIFICATION'
 # Mandatory planned-body evidence, not self-referential current pins.
 installer=next(r for r in source['immutable_leaves']if r['name']=='C1266_GENERATION_TIMEOUT_ASYNC_DB_DELTA.sql')
 text=pathlib.Path(installer['path']).read_text();assert sha(text)==installer['sha256']
 from pglast.parser import parse_sql_json
 expected={}
 for node in json.loads(parse_sql_json(text))['stmts']:
  if 'CreateFunctionStmt'not in node['stmt']:continue
  function=node['stmt']['CreateFunctionStmt'];name='.'.join(n['String']['sval']for n in function['funcname'])
  types=['.'.join(n['String']['sval']for n in p['FunctionParameter']['argType']['names'])for p in function['parameters']]
  bodies=[o['DefElem']['arg']['List']['items']for o in function['options']if o['DefElem']['defname']=='as']
  assert len(bodies)==1 and len(bodies[0])==1,'LEGACY_SOURCE_SINGLE_AS_REQUIRED'
  signature=name+'('+','.join(types)+')';assert signature not in expected,'LEGACY_SOURCE_DUPLICATE_DEFINITION'
  expected[signature]=hashlib.md5(bodies[0][0]['String']['sval'].encode()).hexdigest()
 assert len(expected)==3 and all(hh[k]['source_md5']==v for k,v in expected.items()),'CURRENT_BODY_NOT_QUALIFIED_SOURCE'
 assert hh['mission_generic_owner.c1266_generation_timeout_terminal_proof_v1(uuid)']['oid']==309324
 composition=reviewed_db_composition(x,live,hh)
 predecessor=verified(composition['baseline_actual_ref'])['rows']['readiness']
 assert live['rows']['readiness']['revision_sha256']==predecessor['revision_sha256']and live['rows']['readiness']['canonical_preimage']==predecessor['canonical_preimage'],'ONE_NEW_ROOT_FROM_REVIEWED_PREDECESSOR_ONLY'
 campaign=reviewed_campaign(x,verified(x['authority_ref']))

 assets=validated_assets(x);assert assets['qualified']is True and assets['edge_file_count']==14 and assets['UI_revision']>=2,'QUALIFIED_UI_REV2_REQUIRED'
 assert assets['UI_sha256']!='d09996dcafbec5a0029f631e9b632820922082cdc8e5395a6c4791e7ff0444c6','UNSAFE_UI_D099'
 edge_target=next(r for r in source['immutable_leaves']if r['name']=='C1266_GENERATION_TIMEOUT_ASYNC_EDGE_BUNDLE_FILES.json')
 edge_files=verified(edge_target);actual_edge=verified(assets['edge_raw_ref'])
 assert {f['name']:f['content']for f in actual_edge['files']}=={f['name']:f['content']for f in edge_files},'ACTUAL_EDGE_BODY_DRIFT'
 ui_freeze=verified(x['UI_freeze_ref']);ui_target=next(r for r in ui_freeze['files']if r['path'].endswith('ASYNC_UI_SOURCE.mjs'))
 ui_raw=verified(assets['UI_raw_ref']);assert sha(ui_raw['content'])==assets['UI_sha256']==ui_target['sha256'],'ACTUAL_UI_NOT_QUALIFIED_SOURCE'
 green(x['actual_review_ref'],[assets['edge_raw_ref'],assets['UI_raw_ref']])

 selfref={'path':str(pathlib.Path(__file__).resolve()),'sha256':sha(pathlib.Path(__file__).read_bytes())}
 review=green(x['source_review_ref'],[x['backend_freeze_ref'],x['UI_freeze_ref'],x['root_contract_ref'],selfref,BASELINE_REF,NATIVE_CONSUMER_REF])
 assert review['current_phase_role_barrier_verified']is True and review['no_future_role_assumption']is True,'CURRENT_PHASE_ROLE_BARRIER_OPEN'
 declared=verified(x['expected_headers_ref']);assert set(declared)==ns['full']and all(declared[s]==hh[s]for s in ns['full']),'ACTUAL113_SEMANTIC_HEADER_DRIFT'
 # Sets are partitioned by producer/consumer roles, not a replacement of 111 with113.
 pre=copy.deepcopy(pre);pre['db_core']=refresh_header_tree(pre['db_core'],hh);pre['db_core']['c1266_functions']=[hh[s]for s in sorted(ns['core'])]
 pre['db_core']['all_function_headers']=[hh[s]for s in sorted(ns['full'])]
 pre['db_core']['additional_dependencies']=[hh[s]for s in ['mission_generic_owner.count_overflow_terminal_v1(uuid,uuid)','mission_staff_abort_private.quiescent_v1(uuid)','public.mission_generic_dispatch_status_v1(uuid,jsonb)']]
 pre['db_core']['sha256']=sha(canon({'core87':pre['db_core']['c1266_functions'],'full113':pre['db_core']['all_function_headers'],'backend_freeze':x['backend_freeze_ref']}))
 # Opening profile is a closed Native consumer; its pricing/limits shape is retained.
 opening=pre['config']['c1266_opening'];assert opening['limits']=={'input_tokens_limit':24000,'output_tokens_limit':20000,'generation_limit':14,'http_limit':28,'scene_cost_budget_usd':'0.3136'}
 pre['config']['generation_timeout_async']={'schema_version':'c1266-generation-timeout-root-policy/1','backend_freeze':x['backend_freeze_ref'],'UI_freeze':x['UI_freeze_ref'],'root_contract':x['root_contract_ref'],'timing':{'generation_ms':240000,'work_lease_ms':360000,'count_ms':120000,'finalize_margin_ms':20000,'paid_worker_ms':400000},'required_role_invariant':'ALL_REQUIRED_CURRENT_PHASE_ROLES','future_roles_invented':False,'core_count':87,'full_count':113,'predecessor_R':live['rows']['readiness']['revision_sha256']}
 pre['config']['generation_timeout_async']['db_composition_ref']=x['db_composition_ref']
 pre['config']['generation_timeout_async']['campaign_ref']=x['campaign_ref']
 pre['config']['generation_timeout_async']['operational_budget']=campaign['operational_budget']
 opening['independent_review_ref']=x['source_review_ref']['path'];budget=pre['config']['staff_finite_ia_budget'];budget['composed_review_ref']=x['source_review_ref']['path'];budget['composed_review_sha256']=x['source_review_ref']['sha256'];assert budget['native_g2_source_sha256']==native_origin()==live['rows']['g2']['source_sha256'],'NATIVE_QUALIFIED_ORIGIN_NOT_RUNTIME_CODE'
 pre['config']['c1266_source_qualification'].update(source_review=x['source_review_ref'],actual_review=x['actual_review_ref'],authority=x['authority_ref']);pre['edge_bundles']=[assets['edge']];pre['ui']=assets['UI']
 projected=copy.deepcopy(pre['config']);projected.pop('sha256',None)
 for k in ['grant_id','not_before','expires_at']:projected['c1266_clean_staff'].pop(k,None)
 projected['c1266_opening'].pop('admission_not_before',None);pre['config']['sha256']=sha(canon(projected))
 code=sha(canon({'db':pre['db_core']['sha256'],'edge':pre['edge_bundles'],'UI':pre['ui'],'config':pre['config']['sha256']}));pre['contract']['code_identity_sha256']=code;pre['contract']['authority_sha256']=x['authority_ref']['sha256'];pre['recovery']={'schema_version':'c1266-timeout-forward-hold/1','availability_OFF_only':True,'history_keep':True,'code_identity_sha256':code}
 assert len(canon(pre).encode())<=262144,'ROOT_CANONICAL_SIZE'
 return pre

def render(x):
 source_baseline()
 phase=x['operation'];assert phase in ['H0','REGISTER','ENABLE_STAFF','RECOVER_HOLD']
 live,hh,authority=fresh(x,'H0'if phase=='H0'else phase);s=prefix(live,hh,phase)
 if phase in ['H0','RECOVER_HOLD']:return s+off_sql()+"IF(SELECT canonical_preimage FROM mission_factory_owner.editor_release_readiness WHERE singleton)IS DISTINCT FROM "+q(live['rows']['readiness']['canonical_preimage'])+" THEN RAISE EXCEPTION 'ROOT_H0_IDENTITY_MUTATED';END IF;END $root$;COMMIT;"
 held(live['rows'])
 if phase=='REGISTER':
  assert authority['Root_grant_minutes']==30,'UNSUPPORTED_WINDOW';pre=compose(x,live,hh)
  s+="op_pre:="+q(pre)+"::jsonb;op_birth:=clock_timestamp();op_expiry:=op_birth+interval '30 minutes';op_pre:=jsonb_set(op_pre,'{config,c1266_clean_staff}',(op_pre#>'{config,c1266_clean_staff}')||jsonb_build_object('grant_id',gen_random_uuid(),'not_before',op_birth,'expires_at',op_expiry),true);op_pre:=jsonb_set(op_pre,'{config,c1266_opening,admission_not_before}',to_jsonb(op_birth),true);op_bytes:=op_pre::text;op_R:=encode(extensions.digest(convert_to(op_bytes,'UTF8'),'sha256'),'hex');"
  s+="UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=op_bytes,revision_sha256=op_R,observed_revision_sha256=op_R,client_build='mission-factory-admin/2:'||op_R,state='prepared',independent_review_ref="+q(x['source_review_ref']['path'])+",updated_at=clock_timestamp()WHERE singleton;UPDATE mission_factory_owner.c464_control SET release_sha256=op_R,review_sha256="+q(x['source_review_ref']['sha256'])+",root_authority_sha256="+q(x['authority_ref']['sha256'])+",expires_at=op_expiry WHERE singleton;UPDATE mission_factory_owner.provider_authoring_admissions SET release_sha256=op_R,expires_at=op_expiry WHERE actor_user=ANY(ARRAY["+','.join(q(a)+'::uuid'for a in ACTORS)+"]);"
 else:
  s+=enable(x,live,hh,authority)
 if phase=='REGISTER':s+=public_closed_sql('op_R')
 return s+"END $root$;COMMIT;"
def main():
 p=argparse.ArgumentParser();p.add_argument('--mode',choices=['emit-query','render'],required=True);p.add_argument('--input');p.add_argument('--out',required=True);a=p.parse_args();out=pathlib.Path(a.out).resolve();assert str(out).startswith('/private/tmp/')
 out.parent.mkdir(parents=True,exist_ok=True);out.write_text(query()if a.mode=='emit-query'else render(json.loads(pathlib.Path(a.input).read_text())))
if __name__=='__main__':main()
