import json,pathlib,hashlib,copy
from pglast import parser
P=pathlib.Path('/private/tmp/tus-human-custom-ordinary');B=P/'backend';I=P/'identity';A=B/'aggregate16'
source=(A/'DELTA_SOURCE.sql').read_text();source_sha=hashlib.sha256(source.encode()).hexdigest()
snapshot=json.loads((A/'BASELINE.json').read_text());pre={'headers':snapshot['headers'],'unsafe_headers':0};controls=snapshot;old=snapshot;names=json.loads((A/'C_GRAPH_111_SIGNATURES.json').read_text())['signatures'];expr=(I/'ABI_RECORD_EXPRESSION.sql').read_text().strip();assert len(pre['headers'])==103 and pre['unsafe_headers']==0
base='5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366';current='08e2b762574bb0d2125be37c1864bf2a7a688761a70e79cf2b8370ff07e57958';manifest='management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/HUMAN_CUSTOM_ORDINARY_MANIFEST.json';review_ref='management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/HUMAN_CUSTOM_ORDINARY_REVIEW.json'
assert controls['current_identity']['observed_revision_sha256']==current
post=copy.deepcopy(pre['headers']);post_byname={x['lookup_signature'].split('(')[0]:x for x in post};delta=json.loads((A/'TARGET_DELTA_METADATA.json').read_text());dbyname={x['signature'].split('(')[0]:x for x in delta};new=[]
def typ(t):
 ns=[x['String']['sval'] for x in t['names']];ns=(['pg_catalog']+ns) if len(ns)==1 else ns
 if t.get('arrayBounds'):ns[-1]='_'+ns[-1]
 return '.'.join(ns)
for node in json.loads(parser.parse_sql_json(source))['stmts']:
 f=node['stmt'].get('CreateFunctionStmt')
 if not f:continue
 name='.'.join(x['String']['sval'] for x in f['funcname']);opts={x['DefElem']['defname']:x['DefElem'].get('arg')for x in f['options']};body=opts['as']['List']['items'][0]['String']['sval'];md5=hashlib.md5(body.encode()).hexdigest();assert md5==dbyname[name]['new_body_md5']
 if name not in post_byname:
  sig=next(x for x in names if x.split('(')[0]==name);h={'lookup_signature':sig};post.append(h);post_byname[name]=h;pre['headers'].append({'lookup_signature':sig,'absent':True});new.append(sig)
  pars=[x['FunctionParameter']for x in f.get('parameters',[])];types=[typ(x['argType'])for x in pars];assert all(x.get('mode')in('FUNC_PARAM_DEFAULT','FUNC_PARAM_IN')and'defexpr'not in x for x in pars)
  h.update(oid=None,body_md5=md5,input_arg_types=types,all_arg_types=types,arg_names=[x.get('name')for x in pars]or None,arg_modes=['i']*len(types),return_type=typ(f['returnType']),returns_set=bool(f['returnType'].get('setof')),default_arg_count=0,defaults=None,variadic_type=None,strict=opts.get('strict',{}).get('Boolean',{}).get('boolval',False),volatility=opts.get('volatility',{}).get('String',{}).get('sval','volatile')[0],parallel=opts.get('parallel',{}).get('String',{}).get('sval','unsafe')[0],security_definer=opts.get('security',{}).get('Boolean',{}).get('boolval',False),language=opts['language']['String']['sval'],configuration=['search_path=""'],owner='postgres',execute=['postgres'])
 else:
  h=post_byname[name];assert h['body_md5']==dbyname[name]['old_body_md5'];h['body_md5']=md5
assert len(dbyname)==len([x for x in json.loads(parser.parse_sql_json(source))['stmts']if 'CreateFunctionStmt'in x['stmt']])
pre['headers'].sort(key=lambda x:x['lookup_signature'])
post.sort(key=lambda x:x['lookup_signature']);(A/'EXPECTED_POST_ABI.json').write_text(json.dumps(post,ensure_ascii=False,indent=2)+'\n')
J=lambda x:json.dumps(x,ensure_ascii=False,separators=(',',':'))
L=lambda x:"'"+x.replace("'","''")+"'"
deflit=lambda x:'$rootjson$'+J(x)+'$rootjson$::jsonb'
arr=[{'lookup_signature':x} for x in names]
actual=f"(SELECT jsonb_agg(CASE WHEN proc.oid IS NULL THEN jsonb_build_object('lookup_signature',x->>'lookup_signature','absent',true) ELSE {expr} END ORDER BY x->>'lookup_signature') FROM jsonb_array_elements({deflit(arr)})x LEFT JOIN pg_proc proc ON proc.oid=to_regprocedure(x->>'lookup_signature'))"
unsafe=f"EXISTS(SELECT 1 FROM jsonb_array_elements({deflit(arr)})x LEFT JOIN pg_proc proc ON proc.oid=to_regprocedure(x->>'lookup_signature') WHERE proc.proleakproof OR EXISTS(SELECT 1 FROM aclexplode(coalesce(proc.proacl,acldefault('f',proc.proowner)))root_acl WHERE root_acl.is_grantable))"
oldkeys=sorted(x['release_sha256'] for x in old['admissions']);base_records={'admissions':sorted(old['admissions'],key=lambda x:x['release_sha256']),'attestations':sorted(old['attestations'],key=lambda x:x['release_sha256'])}
base_read="jsonb_build_object('admissions',(SELECT jsonb_agg(to_jsonb(r) ORDER BY r.release_sha256) FROM mission_public_owner.release_admissions_v1 r WHERE r.release_sha256=ANY(ARRAY["+','.join(L(x) for x in oldkeys)+"]::text[])),'attestations',(SELECT jsonb_agg(to_jsonb(root_att) ORDER BY root_att.release_sha256) FROM mission_public_owner.public_qualification_attestations_v1 root_att WHERE root_att.release_sha256=ANY(ARRAY["+','.join(L(x) for x in oldkeys)+"]::text[])))"
policy=copy.deepcopy(controls['current_identity']['observed_canonical_tuple']['config']['policy'])
semantic={'schema_version':'human-custom-semantic-compatibility/1','base_provenance':base,'source_sha256':source_sha,'delta':delta,'no_new_HTML_RPC':True,'old_legacy_AI_else_byte_exact':True,'current_graph_count':len(names),'full_abi_including_new_actual_OID':True,'custom_Staff_QA':'NOT_RUN','public_custom_enabled':False,'review_contract':'whole source, installer, finite Staff material, recovery and public-opening algorithm; own actual ordinary Staff proof required'}
semantic.update(predecessor_observed_release_sha256=current,predecessor_compatibility_sha256=controls['current_identity']['compatibility_sha256'],predecessor_context_payload_sha256=next(x['payload_sha256']for x in old['attestations']if x['payload'].get('schema_version')=='human-custom-staff-context-continuity/1'and x['payload'].get('current_release_sha256')=='67ef52b8293cd0930501fa6adc24a702ab9eddf1366d45cd3e15d69e1d12294a'),origin_context_release_sha256='0ff04ca971dc05bfd93b74409dcb6d995f7a4857a0b039192ed6030b47b7eaf3',aggregate=16,explicit_user_exception=True)
semantic.update(private_context_reuse={'full_validator':'every existing with_context boundary fresh; customsource false history remains guarded as before','verified_variants':7,'new_private_binding_helper':1,'new_graph_count':111,'proof_bundle':'private6keys bound arc/draft/version/source/contextobservationSHA/authoritative result; sameentry only','no_GUC_persistence_clientarg_cache_timeout':True,'Auth_source_lease_mechanical_proof_CAS_historical_checks_preserved':True,'trigger_boundary':'independently fresh humanassert unchanged','runtime_latency':'NOT_RUN; only Staff can prove latency','same_already_narrated_Combat_round1_Fato_and_emptyround2':'retained','QA30':'successful new commit','lease120':'actual authorized statement start plus exactly2h'})
semantic_sha=hashlib.sha256(J(semantic).encode()).hexdigest();(A/'SEMANTIC_MANIFEST.json').write_text(json.dumps(semantic,ensure_ascii=False,indent=2)+'\n')
protected_sql=(P/'PROTECTED_QUERY.sql').read_text().strip();assert protected_sql.lower().startswith('select ') and protected_sql.endswith(' as protected;');protected_expr=protected_sql[7:-len(' as protected;')]
protected_expected=json.loads((P/'RESUME_PROTECTED.json').read_text());protected_expected.pop('at');protected_guard=" IF ("+protected_expr+")-'at' IS DISTINCT FROM "+deflit(protected_expected)+" THEN RAISE EXCEPTION 'HUMAN_CUSTOM_PROTECTED48_DRIFT';END IF;\n"
own_scope_read="jsonb_build_object('arc_hash',(SELECT mission_factory_owner.sha(to_jsonb(qa)) FROM mission_factory_owner.quest_arcs qa WHERE qa.id='22765216-5f14-573f-86e4-60c402941ec9'),'episode_hash',(SELECT mission_factory_owner.sha(to_jsonb(qe)) FROM mission_factory_owner.quest_episodes qe WHERE qe.id='5046fb22-f02e-5db8-a091-33acd4eb2c0c'),'enrollments_hash',(SELECT mission_factory_owner.sha(jsonb_agg(to_jsonb(en) ORDER BY en.character_id)) FROM mission_factory_owner.quest_episode_enrollments en WHERE en.episode_id='5046fb22-f02e-5db8-a091-33acd4eb2c0c'),'runsources_count',(SELECT count(*) FROM mission_factory_owner.quest_run_sources WHERE episode_id='5046fb22-f02e-5db8-a091-33acd4eb2c0c'),'own_q',(SELECT to_jsonb(oq) FROM mission_factory_owner.quest_run_sources oq WHERE session_id='9845891c-2e02-5ba6-8b45-68ff9f2fe268'),'own_m',(SELECT to_jsonb(om) FROM public.master_v2_sessions om WHERE id='9845891c-2e02-5ba6-8b45-68ff9f2fe268'),'own_run',(SELECT to_jsonb(orr) FROM public.mission_run_state orr WHERE master_session_id='9845891c-2e02-5ba6-8b45-68ff9f2fe268'),'own_optin',(SELECT jsonb_agg(to_jsonb(oo) ORDER BY oo.request_key) FROM mission_factory_owner.c463_optin_receipts oo WHERE session_id='9845891c-2e02-5ba6-8b45-68ff9f2fe268'),'own_participants',(SELECT jsonb_agg(to_jsonb(op) ORDER BY op.character_id) FROM public.master_v2_participants op WHERE session_id='9845891c-2e02-5ba6-8b45-68ff9f2fe268'))"
own_scope_expected={k:snapshot[k] for k in ['arc_hash','episode_hash','enrollments_hash','runsources_count','own_q','own_m','own_run','own_optin','own_participants']}
own_scope_guard=" IF "+own_scope_read+" IS DISTINCT FROM "+deflit(own_scope_expected)+" THEN RAISE EXCEPTION 'HUMAN_CUSTOM_PUBLISHED_OWN_SCOPE_DRIFT';END IF;\n"
continuity_fragment=(A/'LEASE_APPEND_FRAGMENT.sql').read_text()
head=f'''-- Atomic reviewed source installation. TEMPLATE: Root finite envelope required, not an authorization.
BEGIN;
SET LOCAL search_path=pg_catalog,public,extensions;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='90s';
-- __ROOT_FINITE_ENVELOPE__
DO $root_pre$
DECLARE e jsonb:=nullif(current_setting('tus.human_custom_install',true),'')::jsonb;got jsonb;
BEGIN
 IF current_user IS DISTINCT FROM 'postgres'::name OR auth.uid() IS NOT NULL OR e IS NULL
 OR NOT mission_factory_owner.keys_exact_v2(e,ARRAY['operation','authority_sha256','expires_at','source_sha256','review_ref','review_sha256','review_findings','expected_kind','expected_runtime','expected_fixed30'])
 OR e->>'operation' IS DISTINCT FROM 'install_exact_human_custom_ordinary_C'
 OR e->>'source_sha256' IS DISTINCT FROM '{source_sha}'
 OR e->>'review_ref' IS DISTINCT FROM {L(review_ref)}
 OR e->'review_findings' IS DISTINCT FROM '{{"P0":0,"P1":0,"P2":0}}'::jsonb
 OR coalesce(e->>'authority_sha256','')!~'^[0-9a-f]{{64}}$' OR coalesce(e->>'review_sha256','')!~'^[0-9a-f]{{64}}$'
 OR e->>'expires_at' IS NULL OR (e->>'expires_at')::timestamptz<=clock_timestamp() OR (e->>'expires_at')::timestamptz>clock_timestamp()+interval '10 minutes'
 THEN RAISE EXCEPTION 'HUMAN_CUSTOM_INSTALL_ROOT_FINITE_AUTHORITY';END IF;
 IF (SELECT jsonb_agg(to_jsonb(mm) ORDER BY mm.actor_user,mm.release_sha256) FROM mission_factory_owner.manual_authoring_admissions_v1 mm WHERE mm.actor_user IN('f0856d53-83a6-4de0-bc0c-12c87916e665','b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b') AND mm.release_sha256='37dac90525b249f53fc0404b50adb4ed92df0123649326c99260bf656119d806') IS DISTINCT FROM {deflit(controls['manual'])} OR NOT EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources root_own_q JOIN public.master_v2_sessions root_own_m ON root_own_m.id=root_own_q.session_id WHERE root_own_q.session_id='9845891c-2e02-5ba6-8b45-68ff9f2fe268' AND root_own_q.state='started' AND root_own_q.control_version=3 AND root_own_q.started_at IS NOT NULL AND root_own_m.stato='in_corso' AND root_own_m.control_version=2 AND root_own_m.closed_at IS NULL) OR NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions root_own_combat WHERE id='9f5ad733-ea91-434f-8ffd-1a3c818e1e70' AND master_session_id='9845891c-2e02-5ba6-8b45-68ff9f2fe268' AND state='in_corso' AND closed_at IS NULL) OR EXISTS(SELECT 1 FROM public.combat_v2_sessions other_own_combat WHERE master_session_id='9845891c-2e02-5ba6-8b45-68ff9f2fe268' AND id<>'9f5ad733-ea91-434f-8ffd-1a3c818e1e70') THEN RAISE EXCEPTION 'HUMAN_RENEW_OWN_STARTED_OR_MANUAL_CAS';END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended('human-custom-ordinary-release',15102026));
 got:={actual};IF got IS DISTINCT FROM {deflit(pre['headers'])} OR {unsafe} THEN RAISE EXCEPTION 'HUMAN_CUSTOM_FULL111_PREFLIGHT_DRIFT';END IF;
 IF (SELECT to_jsonb(k) FROM mission_factory_owner.c416_kind_admission k WHERE singleton FOR UPDATE) IS DISTINCT FROM e->'expected_kind'
 OR (SELECT to_jsonb(r) FROM mission_factory_owner.c444_runtime_control r WHERE singleton FOR UPDATE) IS DISTINCT FROM e->'expected_runtime'
 OR (SELECT to_jsonb(g) FROM mission_factory_owner.quest_fixed30_admission g WHERE singleton FOR UPDATE) IS DISTINCT FROM e->'expected_fixed30'
 OR e->'expected_kind' IS DISTINCT FROM {deflit(controls['kind'])} OR e->'expected_runtime' IS DISTINCT FROM {deflit(controls['runtime'])} OR e->'expected_fixed30' IS DISTINCT FROM {deflit(controls['fixed30'])} THEN RAISE EXCEPTION 'HUMAN_CUSTOM_CONTROL_FULL_CAS';END IF;
 LOCK TABLE mission_public_owner.release_admissions_v1,mission_public_owner.public_qualification_attestations_v1 IN SHARE ROW EXCLUSIVE MODE;
 IF (SELECT count(*) FROM mission_public_owner.release_admissions_v1)<>{len(old['admissions'])} OR (SELECT count(*) FROM mission_public_owner.public_qualification_attestations_v1)<>{len(old['attestations'])} OR {base_read} IS DISTINCT FROM {deflit(base_records)} THEN RAISE EXCEPTION 'HUMAN_CUSTOM_BASE_PROVENANCE_DRIFT';END IF;
 got:=mission_factory_owner.human_ordinary_release_identity_v1('{base}',true);
 IF got->>'revision_sha256' IS DISTINCT FROM '{base}' OR got IS DISTINCT FROM {deflit(controls['current_identity'])} OR got->>'observed_revision_sha256' IS DISTINCT FROM '{current}' THEN RAISE EXCEPTION 'HUMAN_CUSTOM_BASE_CURRENT_ABI_REQUIRED';END IF;
{own_scope_guard}{protected_guard} IF EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND id<>'9845891c-2e02-5ba6-8b45-68ff9f2fe268'::uuid AND stato<>'chiusa' AND closed_at IS NULL) THEN RAISE EXCEPTION 'HUMAN_CUSTOM_OTHER_STAFF_SCENE_OPEN';END IF;
END $root_pre$;
'''
foot=f'''
DO $root_bind_C$
DECLARE e jsonb:=nullif(current_setting('tus.human_custom_install',true),'')::jsonb;a jsonb;expected jsonb:={deflit(post)};oldid jsonb;ct jsonb;cp jsonb;db_sha text;client_binding jsonb;edge_binding jsonb;pol jsonb:={deflit(policy)};csha text;ckey text;current_row mission_public_owner.release_admissions_v1;obs jsonb;lease_effective timestamptz:=statement_timestamp();lease_expiry timestamptz;lease_payload jsonb;lease_key text;lease_uuid uuid:=extensions.uuid_generate_v4();lease_new_kind jsonb;lease_new_runtime jsonb;
BEGIN
 a:={actual};
 IF jsonb_array_length(a)<>{len(names)} OR {unsafe} OR EXISTS(SELECT 1 FROM jsonb_array_elements(expected)ex LEFT JOIN jsonb_array_elements(a)ac ON ac->>'lookup_signature'=ex->>'lookup_signature' WHERE ac IS NULL OR ac-'oid' IS DISTINCT FROM ex-'oid' OR (ex->>'oid' IS NOT NULL AND ac->>'oid' IS DISTINCT FROM ex->>'oid') OR coalesce(ac->>'oid','')!~'^[1-9][0-9]*$') THEN RAISE EXCEPTION 'HUMAN_CUSTOM_CURRENT111_FULL_ABI_POST_MISMATCH';END IF;
 client_binding:={deflit(controls['current_identity']['observed_canonical_tuple']['client']['bindings'])};
 edge_binding:={deflit(controls['current_identity']['observed_canonical_tuple']['edge']['bindings'])};
 db_sha:=mission_factory_owner.sha(a);
 ct:=jsonb_build_object('schema_version','human-custom-ordinary-release-tuple/1','base_release_sha256','{base}','db_core',jsonb_build_object('sha256',db_sha,'functions',a),'client',jsonb_build_object('sha256',mission_factory_owner.sha(client_binding),'bindings',client_binding),'edge',jsonb_build_object('sha256',mission_factory_owner.sha(edge_binding),'bindings',edge_binding),'config',jsonb_build_object('sha256',mission_factory_owner.sha(pol),'policy',pol));
 csha:=mission_factory_owner.sha(ct);
 lease_expiry:=lease_effective+interval '2 hours';
 INSERT INTO mission_public_owner.release_admissions_v1(release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)
 VALUES(csha,db_sha,ct#>>'{{edge,sha256}}',ct#>>'{{client,sha256}}',ct#>>'{{config,sha256}}','mission-public-admission/1',e->>'review_ref','AUTHORIZED_TEST_MANIFEST:'||{L(manifest)},clock_timestamp(),false);
 ckey:=mission_factory_owner.sha(jsonb_build_object('schema_version','human-release-compatibility-key/1','base_release_sha256','{base}','current_release_sha256',csha));
 INSERT INTO mission_public_owner.release_admissions_v1(release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)
 SELECT ckey,db_sha256,edge_sha256,client_sha256,configuration_sha256,contract_version,independent_review_ref,'SOURCE_RECORD_ONLY:human-release-compatibility/1',clock_timestamp(),false FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=csha;
 cp:=jsonb_build_object('schema_version','human-release-compatibility/1','base_release_sha256','{base}','base_canonical_tuple_sha256','{base}','current_release_sha256',csha,'current_canonical_tuple',ct,'independent_review_ref',e->>'review_ref','review_sha256',e->>'review_sha256','review_findings',e->'review_findings','semantic_manifest_sha256','{semantic_sha}','compatible_scope','legacy-human-ordinary','ordinary_custom_runtime_qa','NOT_RUN');
 INSERT INTO mission_public_owner.public_qualification_attestations_v1(release_sha256,request_key,payload,payload_sha256,positive_staff_evidence_ref,authorized_test_manifest_ref)
 VALUES(ckey,extensions.uuid_generate_v5('e954b5ba-025a-5820-acd3-614cd7a2a6cd'::uuid,ckey),cp,mission_factory_owner.sha(cp),'SOURCE_REVIEW_ONLY:'||(e->>'review_ref'),{L(manifest)});
{continuity_fragment}
 IF mission_factory_owner.human_ordinary_authority_v1('770f2d68-2775-546d-98a6-7297335e4edf',2,'24d6b0730cf1fcc78a821c49955addcef8dd320ce93316744f306693247cf726')->>'qualification_sha256' IS DISTINCT FROM (e->'expected_fixed30')->>'public_staff_qualification_sha256' THEN RAISE EXCEPTION 'HUMAN_LEASE_STRONG_CURRENT_AUTHORITY_POST';END IF;
 obs:=mission_factory_owner.human_ordinary_release_identity_v1('{base}',true);
 IF obs->>'schema_version' IS DISTINCT FROM 'human-compatible-release-identity/1' OR obs->>'provenance_release_sha256' IS DISTINCT FROM '{base}' OR obs->>'observed_revision_sha256' IS DISTINCT FROM csha OR obs->'observed_canonical_tuple' IS DISTINCT FROM ct OR mission_factory_owner.human_release_observation_valid_v1(obs,'{base}',true) IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_CUSTOM_TYPED_CURRENT_IDENTITY_POST';END IF;
 IF (SELECT count(*) FROM mission_public_owner.release_admissions_v1)<>{len(old['admissions'])+3} OR (SELECT count(*) FROM mission_public_owner.public_qualification_attestations_v1)<>{len(old['attestations'])+2} OR (SELECT to_jsonb(kp) FROM mission_factory_owner.c416_kind_admission kp WHERE singleton) IS DISTINCT FROM lease_new_kind OR (SELECT to_jsonb(rp) FROM mission_factory_owner.c444_runtime_control rp WHERE singleton) IS DISTINCT FROM lease_new_runtime OR {base_read} IS DISTINCT FROM {deflit(base_records)} OR (SELECT to_jsonb(g) FROM mission_factory_owner.quest_fixed30_admission g WHERE singleton) IS DISTINCT FROM e->'expected_fixed30' OR EXISTS(SELECT 1 FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=csha AND public_enabled) THEN RAISE EXCEPTION 'HUMAN_CUSTOM_BASE_OR_CUSTOM_GATE_POST_DRIFT';END IF;
{own_scope_guard}{protected_guard} PERFORM mission_factory_owner.c408_stage1_complete_assert_v1();
 PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();
 PERFORM mission_factory_owner.c463_optin_complete_assert_v1();
END $root_bind_C$;
'''
# The finite lease fragment changes only two dates in each pre-CASed row; no review/history/request reset.
whole=head+source+'\n'+foot+'\nCOMMIT;\n'
parser.parse_sql_json(whole);parser.parse_plpgsql_json(whole)
(A/'INSTALL_TEMPLATE.sql').write_text(whole)
(A/'INSTALL_COMPONENTS.json').write_text(json.dumps({'source_sha256':source_sha,'template_sha256':hashlib.sha256(whole.encode()).hexdigest(),'template_bytes':len(whole.encode()),'graph_count':len(names),'new_helpers':new,'semantic_manifest_sha256':semantic_sha,'review_ref':review_ref,'manifest_ref':manifest,'policy':policy,'expected_abi_file':'EXPECTED_POST_ABI.json','state':'TEMPLATE_NOT_PERMIT_NO_APPLY','provider_calls':0},ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'template_bytes':len(whole.encode()),'template_sha256':hashlib.sha256(whole.encode()).hexdigest(),'source_sha256':source_sha,'functions':len(dbyname),'ABI':len(names),'SQL_PL_parser':'PASS','materialization':'PENDING_GREEN_REVIEW'},indent=2))
