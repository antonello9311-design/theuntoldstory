#!/usr/bin/env python3
"""E75 aggregated correction25: exact Edge140 delta. Static/syntax only."""
import argparse,json,hashlib,difflib,re,posixpath,subprocess
from pathlib import Path
def sha(x):return hashlib.sha256(x).hexdigest()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--baseline',required=True);ap.add_argument('--output',required=True);a=ap.parse_args()
 raw=Path(a.baseline).read_bytes();b=json.loads(raw);assert b['version']==140 and len(b['files'])==16
 old={f['name']:f['content']for f in b['files']};new=dict(old);changes={}
 expected={'mission-generic-runtime.mjs':'6d288420e9a1cbdb2c44a7d8e6fe046537bbca108b7194f9406159b64d906154','mission-staff-editorial.mjs':'4ff5b15accc3068f6a3cb5008cb4cf95b567f210819ca95d23ba7bec4774835a'}
 for n,h in expected.items():assert sha(old[n].encode())==h
 def once(n,before,after):
  assert new[n].count(before)==1,(n,before[:100]);new[n]=new[n].replace(before,after);changes.setdefault(n,[]).append((before,after))
 once('mission-generic-runtime.mjs'," const data=JSON.parse(checked.usr);\n validateDirector(p.director_context,p.scene.snapshot.location);\n validateKnowledge(p.knowledge_context,p.scene.snapshot.actors,'combat');", " const actors=p.scene.snapshot.actors.map(narrativeActorPersonaView);\n const data={...JSON.parse(checked.usr),attori:actors};\n validateDirector(p.director_context,p.scene.snapshot.location);\n validateKnowledge(p.knowledge_context,actors,'combat');")
 oldcatch=""" }catch{
  if(prepared?.campaign_id===campaign&&prepared?.state==='ready'&&uuid(prepared.run_id)){try{await step(prepared.run_id,{operation:'reject',reason_code:'request_build_failed'});}catch{}}
  return respond({code:'COMBAT_REPORT_PREPARE_UNCONFIRMED',retry:false,provider_retry_allowed:false},409);
 }"""
 newcatch=""" }catch(error){
  logBuildDiagnostic(prepared?.run_id,error);
  if(prepared?.campaign_id===campaign&&uuid(prepared.run_id)){
   if(prepared.state==='ready'){try{await step(prepared.run_id,{operation:'reject',reason_code:'request_build_failed'});}catch{}}
   // A known failed run is a durable receipt, not a lost start or a reason to generate again.
   try{const observed=await read(prepared.run_id);if(observed.state==='failed')return respond(view(observed,prepared.replayed,true),200);}catch{}
  }
  return respond({code:'COMBAT_REPORT_PREPARE_UNCONFIRMED',retry:false,provider_retry_allowed:false},409);
 }"""

 oldprepare=""" let prepared,factory;
 try{
  prepared=await rpc('mission_staff_editorial_prepare_v1',{p_user:user,p_campaign:campaign,p_case:1,p_variant:'canary',p_request:body.request_key});
  if(prepared.schema_version!=='staff-combat-report-work/1'||prepared.stage!=='narration'||prepared.prompt_revision!=='staff-combat-report-narrator/1'
   ||prepared.source?.schema_version!=='staff-combat-report-source/1'||prepared.source.author_user_id!==user
   ||!sha(prepared.source_sha256))throw Error('E75_SOURCE_BINDING');
  view(prepared,prepared.replayed);
  if(prepared.state!=='ready')return respond(view(prepared,true),200);
  factory=await createStaffCombatReportNarrator(prepared.source,prepared.policy);"""
 newprepare=""" let prepared,factory;
 const prepareRun=()=>rpc('mission_staff_editorial_prepare_v1',{p_user:user,p_campaign:campaign,p_case:1,p_variant:'canary',p_request:body.request_key});
 const checkedPrepared=value=>{
  if(value.schema_version!=='staff-combat-report-work/1'||value.stage!=='narration'||value.prompt_revision!=='staff-combat-report-narrator/1'
   ||value.source?.schema_version!=='staff-combat-report-source/1'||value.source.author_user_id!==user
   ||!sha(value.source_sha256))throw Error('E75_SOURCE_BINDING');
  view(value,value.replayed);return value;
 };
 try{
  prepared=checkedPrepared(await prepareRun());
  if(prepared.state==='failed'&&prepared.run_id==='5e338b9a-52e2-2e96-9c16-352e31751c3b'){
   // Validate the repaired request first. Only the server can prove and recover zero HTTP.
   factory=await createStaffCombatReportNarrator(prepared.source,prepared.policy);
   const originalRun=prepared.run_id,originalSource=prepared.source_sha256;
   await step(originalRun,{operation:'recover_preprovider',expected_failed_row_sha256:'47f123ee26d98e0008e638506adede3d240b54a34e7a23260e9c7692823aae9d',repair_ref:'C1266_NARRATORE75_REVIEW.json'});
   prepared=checkedPrepared(await prepareRun());
   if(prepared.run_id!==originalRun||prepared.source_sha256!==originalSource)throw Error('E75_RECOVERY_BINDING');
  }
  if(prepared.state!=='ready')return respond(view(prepared,true),200);
  if(!factory)factory=await createStaffCombatReportNarrator(prepared.source,prepared.policy);"""
 once('mission-staff-editorial.mjs',oldprepare,newprepare)
 once('mission-staff-editorial.mjs',oldcatch,newcatch)
 out=Path(a.output);out.mkdir(parents=True,exist_ok=True);rows=[];checks=[]
 for n,s in new.items():
  p=out/'edge'/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s)
  if n.endswith('.mjs'):
   q=subprocess.run(['/Users/antonello/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node','--check',str(p)],text=True,capture_output=True);assert q.returncode==0,(n,q.stderr);checks.append(n)
  for imp in re.findall(r"(?:from\s*|import\s*)['\"](\.[^'\"]+)['\"]",s):assert posixpath.normpath(str(Path(n).parent/imp))in new
  restored=s
  for before,after in reversed(changes.get(n,[])):assert restored.count(after)==1;restored=restored.replace(after,before)
  assert restored==old[n]
  rows.append({'name':n,'baseline_sha256':sha(old[n].encode()),'candidate_sha256':sha(s.encode()),'bytes':len(s.encode()),'changed':s!=old[n],'inverse':'EXACT_EDGE140'})
  if s!=old[n]:
   q=out/'diff'/Path(n+'.diff');q.parent.mkdir(parents=True,exist_ok=True);q.write_text(''.join(difflib.unified_diff(old[n].splitlines(True),s.splitlines(True),fromfile='Edge140/'+n,tofile='agg25/'+n)))
 # Existing projection and validator remain byte-identical; no snapshot or source producer is rewritten.
 r=old['mission-generic-runtime.mjs'];start=r.index('function narrativeActorPersonaView(');end=r.index('function nativeWriterActors(',start);assert r[start:end]in new['mission-generic-runtime.mjs']
 start=r.index('function validateKnowledge(');end=r.index('function validateSourceCursor(',start);assert r[start:end]in new['mission-generic-runtime.mjs']
 pack={'name':'mission_generic_ai','entrypoint_path':b['entrypoint_path'],'verify_jwt':b['verify_jwt'],'files':[{'name':f['name'],'content':new[f['name']]}for f in b['files']]};f=out/'EDGE_PACKAGE.json';f.write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n')
 status={'aggregate':25,'status':'SOURCE_FROZEN_NOT_REVIEWED_NOT_INSTALLED','baseline_edge':140,'baseline_ezbr':b['ezbr_sha256'],'baseline_metadata_sha256':sha(raw),'package_sha256':sha(f.read_bytes()),'builder_sha256':sha(Path(__file__).read_bytes()),'files':rows,'changed_files':2,'unchanged_files':14,'syntax':checks,'relative_imports':'RESOLVED_STATIC','whole_inverse':'EXACT_EDGE140','canonical_projection_and_validator':'BYTE_IDENTICAL','source_snapshot':'UNMODIFIED','UI':'UNMODIFIED','provider_calls':0,'gameplay':'NOT_RUN','recovery':'Separate DB recovery of same zero-HTTP run; no provider retry'}
 (out/'STATIC.json').write_text(json.dumps(status,indent=2)+'\n');print(json.dumps({k:status[k]for k in ['aggregate','package_sha256','builder_sha256','changed_files','unchanged_files']}))
if __name__=='__main__':main()
