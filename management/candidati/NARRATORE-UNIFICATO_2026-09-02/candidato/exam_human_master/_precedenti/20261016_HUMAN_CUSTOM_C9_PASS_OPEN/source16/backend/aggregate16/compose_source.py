from pathlib import Path
import json,hashlib,re
from pglast import parser
A=Path(__file__).parent;b=json.loads((A/'BASELINE.json').read_text());ds={x['signature'].split('(')[0]:x for x in b['definitions']};out=[];changes=[];inverse=[];proofs=[]
base='5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366';schema='mission_factory_owner.'
names=['human_ordinary_authority','human_custom_ordinary_capability','human_staff_lease_valid','human_ordinary_source','human_ordinary_arc_scope','human_ordinary_execution_read_assert','human_custom_source_assert'];mapping={schema+n+'_with_context_v1':schema+n+'_verified_v1'for n in names};bundle_names={schema+n+'_verified_v1'for n in ['human_ordinary_arc_scope','human_ordinary_execution_read_assert','human_custom_source_assert']}
def body(s):return next(x['DefElem']['arg']['List']['items'][0]['String']['sval']for x in json.loads(parser.parse_sql_json(s))['stmts'][0]['stmt']['CreateFunctionStmt']['options']if x['DefElem']['defname']=='as')
def emit(sig,old,new,kind):
 new=new.rstrip().rstrip(';')+';\n';parser.parse_sql_json(new);parser.parse_plpgsql_json(new);out.append(new)
 changes.append({'signature':sig,'old_body_md5':hashlib.md5(body(old).encode()).hexdigest()if old else None,'new_body_md5':hashlib.md5(body(new).encode()).hexdigest(),'kind':kind})
 if old:inverse.append(old.rstrip().rstrip(';')+';\n')
# Binding validator keeps every inexpensive check; shape/digests move to the unchanged full validator at each entry.
old=ds[schema+'human_verified_context_valid_v1']['definition'];bound=old.replace('human_verified_context_valid_v1','human_context_bound_v1',1)
a=" AND mission_factory_owner.keys_exact_v2(p_context,ARRAY['schema_version','backend_pid','transaction_started_at','statement_started_at','principal','auth_role','base_release_sha256','observation','observation_sha256'])";assert bound.count(a)==1;bound=bound.replace(a,'')
a=" AND p_context->>'observation_sha256'=mission_factory_owner.sha(p_context->'observation')";assert bound.count(a)==1;bound=bound.replace(a,'')
a=" AND encode(extensions.digest(convert_to(p_context#>>'{observation,canonical_preimage}','UTF8'),'sha256'),'hex')=p_base";assert bound.count(a)==1;bound=bound.replace(a,'')
emit(schema+'human_context_bound_v1(jsonb,text)',None,bound,'new_private_binding_validator');proofs.append({'moved_full_checks':["exact9keys","observationSHA","canonicalpreimageSHA"],'where_retained':'unchanged fullvalidator at every existingwith_context entry','all_other_fullvalidator_checks_preserved_in_bound':True})
# Six-key ephemeral proof bundle is only constructed by source_verified after its source/Auth checks.
def bundle_guard(arc):
 return " IF p_authority_bundle IS NOT NULL AND (mission_factory_owner.keys_exact_v2(p_authority_bundle,ARRAY['arc_id','draft_id','draft_version','source_sha256','observation_sha256','authority']) IS DISTINCT FROM true OR p_authority_bundle->>'arc_id' IS DISTINCT FROM "+arc+".id::text OR p_authority_bundle->>'draft_id' IS DISTINCT FROM "+arc+".draft_id::text OR p_authority_bundle->>'draft_version' IS DISTINCT FROM "+arc+".draft_version::text OR p_authority_bundle->>'source_sha256' IS DISTINCT FROM "+arc+".source_sha256 OR p_authority_bundle->>'observation_sha256' IS DISTINCT FROM p_context->>'observation_sha256' OR jsonb_typeof(p_authority_bundle->'authority') IS DISTINCT FROM 'object') THEN RAISE EXCEPTION 'HUMAN_PRIVATE_AUTHORITY_BINDING_INVALID' USING ERRCODE='42501';END IF;\n"
for name,newname in mapping.items():
 old=ds[name]['definition'];new=old
 for orig,target in mapping.items():new=new.replace(orig,target)
 new=new.replace(schema+'human_verified_context_valid_v1',schema+'human_context_bound_v1')
 f=json.loads(parser.parse_sql_json(old))['stmts'][0]['stmt']['CreateFunctionStmt'];pars=[x['FunctionParameter']for x in f.get('parameters',[])];args=[x['name']for x in pars];signature=next(x['signature']for x in b['definitions']if x['signature'].split('(')[0]==name);new_sig=signature.replace(name,newname)
 if newname in bundle_names:
  needle='p_context jsonb)';assert new.count(needle)==1;new=new.replace(needle,'p_context jsonb, p_authority_bundle jsonb)',1);new_sig=new_sig[:-1]+',jsonb)'
 if name.endswith('human_ordinary_source_with_context_v1'):
  new=new.replace('proof jsonb;policy','proof jsonb;authority_bundle jsonb;policy',1)
  marker=" IF mission_factory_owner.human_ordinary_arc_scope_verified_v1(a.id,q.state NOT IN('terminal','cancelled'),p_context) IS DISTINCT FROM true THEN RETURN NULL;END IF;"
  assert new.count(marker)==1
  derive=" IF q.state NOT IN('terminal','cancelled') THEN\n  proof:=mission_factory_owner.human_ordinary_authority_verified_v1(a.draft_id,a.draft_version,a.source_sha256,p_context);\n  IF proof IS NOT NULL THEN authority_bundle:=jsonb_build_object('arc_id',a.id,'draft_id',a.draft_id,'draft_version',a.draft_version,'source_sha256',a.source_sha256,'observation_sha256',p_context->>'observation_sha256','authority',proof);END IF;\n END IF;\n"
  new=new.replace(marker,derive+marker.replace(',p_context)',',p_context,authority_bundle)'))
  new=new.replace("human_custom_source_assert_verified_v1(a.draft_id,q.state NOT IN('terminal','cancelled'),p_context)","human_custom_source_assert_verified_v1(a.draft_id,q.state NOT IN('terminal','cancelled'),p_context,authority_bundle)")
 elif name.endswith('human_ordinary_arc_scope_with_context_v1'):
  new=new.replace('human_ordinary_execution_read_assert_verified_v1(a.id,p_live,p_context)','human_ordinary_execution_read_assert_verified_v1(a.id,p_live,p_context,p_authority_bundle)')
 elif name.endswith('human_ordinary_execution_read_assert_with_context_v1'):
  needle=' if p_active then\n  proof:=mission_factory_owner.human_ordinary_authority_verified_v1(a.draft_id,a.draft_version,a.source_sha256,p_context);';assert new.count(needle)==1
  new=new.replace(needle,bundle_guard('a')+" if p_active then\n  IF p_authority_bundle IS NULL THEN proof:=mission_factory_owner.human_ordinary_authority_verified_v1(a.draft_id,a.draft_version,a.source_sha256,p_context);ELSE proof:=p_authority_bundle->'authority';END IF;")
 elif name.endswith('human_custom_source_assert_with_context_v1'):
  new=new.replace('continuity_authorized boolean:=false;','continuity_authorized boolean:=false;verified_authority jsonb;',1)
  marker=" IF p_active THEN\n observed:=(p_context->'observation');";assert new.count(marker)==1;new=new.replace(marker,bundle_guard('ar')+marker)
  target="(mission_factory_owner.human_ordinary_authority_verified_v1(ar.draft_id,ar.draft_version,ar.source_sha256,p_context)->>'qualification_sha256')";assert new.count(target)==1
  marker=" IF sp.payload->>'capability_sha256' IS DISTINCT FROM observed->>'observed_revision_sha256' THEN";new=new.replace(marker,marker+"\n  IF ar.execution_context='staff_simulation' THEN IF p_authority_bundle IS NULL THEN verified_authority:=mission_factory_owner.human_ordinary_authority_verified_v1(ar.draft_id,ar.draft_version,ar.source_sha256,p_context);ELSE verified_authority:=p_authority_bundle->'authority';END IF;END IF;")
  new=new.replace(target,"(verified_authority->>'qualification_sha256')")
 emit(new_sig,None,new,'new_private_verified_variant')
 # Existing private entry remains full validation boundary; false custom-source history keeps no active verification.
 full=" IF mission_factory_owner.human_verified_context_valid_v1(p_context,'"+base+"') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;\n"
 if name.endswith('human_custom_source_assert_with_context_v1'):full=' IF p_active THEN\n'+full+' END IF;\n'
 call=newname+'('+','.join(args+(['NULL::jsonb']if newname in bundle_names else[]))+')'
 ret=next(x['String']['sval']for x in f['returnType']['names']);isvoid=ret=='void' or f['returnType']['names'][-1]['String']['sval']=='void'
 oldbody=body(old);replacement='\nBEGIN\n'+full+(' PERFORM '+call+';\n RETURN;'if isvoid else' RETURN '+call+';')+'\nEND;\n';wrapper=old.replace(oldbody,replacement);assert wrapper.replace(replacement,oldbody)==old
 emit(signature,old,wrapper,'existing_full_validation_boundary')
 proofs.append({'old_entry':signature,'new_verified':new_sig,'source_guard_checks_preserved':'oldbody copied before contextvalidator substitution/proofreuse','wrapper_full_validation': 'IFp_active only, preserving false history'if name.endswith('human_custom_source_assert_with_context_v1')else'always','newhelper_private':True,'newbody':hashlib.md5(body(new).encode()).hexdigest(),'oldbody':hashlib.md5(oldbody.encode()).hexdigest()})
# Closed graph: original103 plus eight private ports, no public shape or caller modifications.
sigs=json.loads((A.parent/'aggregate15/C_GRAPH_103_SIGNATURES.json').read_text())['signatures'];sigs=sorted(set(sigs+[c['signature']for c in changes if c['old_body_md5']is None]));assert len(sigs)==111
old=ds[schema+'human_compatibility_identity_v1']['definition'];frag=re.search(r'jsonb_array_length\(graph\)<>103.*?\$closed\$::jsonb',old,re.S).group();rep=frag.replace('<>103','<>111');rep=re.sub(r'\$closed\$.*?\$closed\$',lambda _:'$closed$'+json.dumps(sigs,separators=(',',':'))+'$closed$',rep,flags=re.S);new=old.replace(frag,rep);assert new.replace(rep,frag)==old
emit(ds[schema+'human_compatibility_identity_v1']['signature'],old,new,'closed_graph111')
# Explicit new helper ACL; no authenticated execution or public prevalidated entry.
for c in changes:
 if c['old_body_md5']is None:out.append('REVOKE ALL ON FUNCTION '+c['signature']+' FROM PUBLIC,anon,authenticated,service_role;\nGRANT EXECUTE ON FUNCTION '+c['signature']+' TO postgres;\n')
s='\n'.join(out);parser.parse_sql_json(s);parser.parse_plpgsql_json(s)
(A/'DELTA_SOURCE.sql').write_text(s);(A/'BUSINESS_RECOVERY.sql').write_text('\n'.join(inverse));(A/'TARGET_DELTA_METADATA.json').write_text(json.dumps(changes,indent=2));(A/'C_GRAPH_111_SIGNATURES.json').write_text(json.dumps({'signatures':sigs},indent=2));(A/'VARIANT_MAPPING.json').write_text(json.dumps(proofs,indent=2));(A/'WHOLE_INVERSE.json').write_text(json.dumps([{'signature':c['signature'],'old':ds[c['signature'].split('(')[0]]['definition'],'new':next(x for x in out if x.startswith('CREATE OR REPLACE FUNCTION '+c['signature'].split('(')[0]+'('))}for c in changes if c['old_body_md5']is not None],indent=2));print('CREATE',len(changes),'new',sum(x['old_body_md5']is None for x in changes),'graph',len(sigs),'bytes',len(s),'SHA',hashlib.sha256(s.encode()).hexdigest())
