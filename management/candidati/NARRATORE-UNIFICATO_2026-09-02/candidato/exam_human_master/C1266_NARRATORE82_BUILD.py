#!/usr/bin/env python3
"""C1266 aggregate32: two real immutable report sources; no local gameplay/model execution."""
import argparse,hashlib,json,re,posixpath,subprocess,difflib
from pathlib import Path
def sha(b):return hashlib.sha256(b).hexdigest()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--baseline',required=True);ap.add_argument('--site',required=True);ap.add_argument('--output',required=True);a=ap.parse_args()
 raw=Path(a.baseline).read_bytes();b=json.loads(raw);assert b['version']==147 and len(b['files'])==16
 old={f['name']:f['content']for f in b['files']};new=dict(old);edits={}
 previous='712ac367-ae96-5360-aa9f-dedb32cd0c45';campaign='54e46641-46ae-5d60-aef9-eaca048c0a0f';historical=['07640a7d-73fe-5f9b-b78b-f65199596a2f','bb24b63b-c121-54a3-a43f-6a49135c780f','e0b73266-f03f-5e6d-a54f-d025f5673615','6fc6dbce-82ce-5a70-b5ee-cd3333ada2cf']
 def once(n,before,after):
  assert new[n].count(before)==1,(n,new[n].count(before),before[:100]);new[n]=new[n].replace(before,after);edits.setdefault(n,[]).append((before,after))
 runtime='mission-generic-runtime.mjs';handler='mission-staff-editorial.mjs'
 once(runtime,"export const COMBAT_REPORT_CAMPAIGN='"+previous+"';","export const COMBAT_REPORT_CAMPAIGN='"+campaign+"';")
 start=old[runtime].index('export async function createStaffCombatReportNarrator(');stop=old[runtime].index('// The same report renderer',start);oldfactory=old[runtime][start:stop]
 factory="""export async function createStaffCombatReportNarrator(source,policy){
 const bad=()=>{throw Error('MISSION_COMBAT_REPORT_PREVIEW_INVALID');};
 const keys=['schema_version','campaign_id','case_no','author_user_id','source_work_id','source_payload','source_payload_sha256','source_contract','source_contract_sha256','report_binding'];
 if(!object(source)||source.campaign_id!==COMBAT_REPORT_CAMPAIGN||![1,2].includes(source.case_no)
  ||!uuid(source.author_user_id)||!uuid(source.source_work_id)||!sha(source.source_payload_sha256)
  ||!sha(source.source_contract_sha256)||!object(source.source_contract))bad();
 const limits=editorialDialogueLimits(policy),b=source.report_binding;let p;
 if(source.case_no===1){
  if(!exact(source,keys)||source.schema_version!=='staff-combat-report-source/1'
   ||source.source_work_id!=='98082b00-d928-e6ac-5275-31d838d2bd43'
   ||source.source_payload_sha256!=='f80b1a470f0783b1546b99564c37c8f1045e5e854dd2357511da8ddef94dd217'
   ||source.source_contract_sha256!=='69739c281209e32a1293d369bda70d0f6a64749031118505ac70ff0680da1c43')bad();
  p=source.source_payload;
 }else{
  // This original unified work already attests its complete native report node.
  // No wrapper, scene, report, role or barrier is reconstructed here.
  if(!exact(source,[...keys,'selected_payload_path','selected_payload_sha256'])||source.schema_version!=='staff-combat-report-source/2'
   ||source.source_work_id!=='d075b2a7-d7af-4afe-b0cc-0bcc13c3faab'
   ||source.source_payload_sha256!=='bdcc5d0759c78ac736905360003580ab9378d9ba259e14ce1cbf7bba775f46b5'
   ||source.source_contract_sha256!=='3bf81815ed745b2e7eb357b0bfc2265e3e253820de90391eff598d5959f23681'
   ||source.selected_payload_sha256!=='3b7cb7253240524b4088a41e5922738f04eddfbe394fc904863dd192a5a0829b'
   ||!retainedJsonEqual(source.selected_payload_path,['resolved_scenes','0'])
   ||source.source_payload?.schema_version!=='mission-generic-narration/3'||source.source_payload.mode!=='unified')bad();
  const contract=source.source_contract,attestation=contract.source_attestation;
  if(contract.schema_version!=='mission-narrative-admission/3'||contract.scope!=='staff_mission'
   ||contract.work_id!==source.source_work_id||contract.payload_sha256!==source.source_payload_sha256
   ||contract.payload_schema_version!=='mission-generic-narration/3'||contract.master_session_id!==b?.master_session_id
   ||attestation?.schema_version!=='mission-narrative-source-attestation/1'||attestation.work_id!==source.source_work_id
   ||attestation.payload_sha256!==source.source_payload_sha256||attestation.master_session_id!==contract.master_session_id
   ||!Array.isArray(attestation.continuity_sources))bad();
  const selected=attestation.continuity_sources.filter(row=>retainedJsonEqual(row?.path,source.selected_payload_path));
  p=source.source_payload.resolved_scenes?.[0];
  if(selected.length!==1||selected[0].shape!=='native_combat_payload'
   ||selected[0].node_sha256!==source.selected_payload_sha256||selected[0].node_schema_version!=='mission-generic-narration/2'
   ||!retainedJsonEqual(selected[0].delta_path,['resolved_scenes','0','continuity_delta'])
   ||selected[0].history_count!==p?.history_count||selected[0].history_chain_sha256!==p?.history_chain_sha256
   ||b?.master_session_id!=='1fb789a2-0319-435f-9f6d-dd517cac7cd3'||b.session_id!=='e5093751-416c-4618-b8e5-79f21e9c4f55'
   ||b.round_id!=='9fa7f34b-dd67-44fb-a9dc-5c22463ebf73'||b.report_id!=='fab2a4eb-15fb-44d6-8803-e708f34fd3a0'
   ||b.report_sha256!=='17b4b8476226ff5470e0d48501c71d5f203b9f1de6929ad905b20787a6793fff'
   ||b.scene_sha256!=='aa886caf2470e3a08c802a779e8189b338e646e79dae51b4a602f45fb7ddce46'||b.control_version!==3)bad();
 }
 return combatReportNarratorRequest(p,b,{...limits,max_input_bytes:491520});
}

"""
 once(runtime,oldfactory,factory)
 readable=" const readableCampaigns=new Set(["+','.join(repr(v)for v in historical)+",campaign]);"
 once(handler,readable," const readableCampaigns=new Set(["+','.join(repr(v)for v in historical+[previous])+",campaign]);")
 once(handler,"||!readableCampaigns.has(r?.campaign_id)||r.case_no!==1", "||!readableCampaigns.has(r?.campaign_id)||!([1,2].includes(r.case_no)&&(r.case_no===1||r.campaign_id===campaign))")
 once(handler,"campaign_id:r.campaign_id,case_no:1,stage:'narration'", "campaign_id:r.campaign_id,case_no:r.case_no,stage:'narration'")
 once(handler,"||body.campaign_id!==campaign||body.case_no!==1||!uuid(body.request_key)", "||body.campaign_id!==campaign||![1,2].includes(body.case_no)||!uuid(body.request_key)")
 once(handler,"p_campaign:campaign,p_case:1,p_variant:'canary',p_request:body.request_key", "p_campaign:campaign,p_case:body.case_no,p_variant:'canary',p_request:body.request_key")
 once(handler,"if(value.schema_version!=='staff-combat-report-work/1'||value.stage!=='narration'||value.prompt_revision!=='staff-combat-report-narrator/4'\n   ||value.source?.schema_version!=='staff-combat-report-source/1'||value.source.author_user_id!==user",
  "if(value.schema_version!=='staff-combat-report-work/1'||value.stage!=='narration'||value.prompt_revision!=='staff-combat-report-narrator/4'\n   ||value.campaign_id!==campaign||value.case_no!==body.case_no||value.source?.case_no!==body.case_no\n   ||value.source?.schema_version!==(body.case_no===2?'staff-combat-report-source/2':'staff-combat-report-source/1')||value.source.author_user_id!==user")
 out=Path(a.output);out.mkdir(parents=True,exist_ok=True);rows=[];syntax=[];export_sets={}
 node='/Users/antonello/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node'
 def exports(s):return sorted(re.findall(r'(?m)^export\s+(?:(?:async\s+)?function|const|let|var|class)\s+([A-Za-z_$][A-Za-z0-9_$]*)',s))
 for name,s in new.items():
  p=out/'edge'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s)
  if name.endswith('.mjs'):
   result=subprocess.run([node,'--check',str(p)],capture_output=True,text=True);assert result.returncode==0,(name,result.stderr);syntax.append(name)
  for imp in re.findall(r"(?:from\s*|import\s*)['\"](\.[^'\"]+)['\"]",s):assert posixpath.normpath(str(Path(name).parent/imp))in new
  inverse=s
  for before,after in reversed(edits.get(name,[])):assert inverse.count(after)==1,(name,after[:70]);inverse=inverse.replace(after,before)
  assert inverse==old[name];assert exports(s)==exports(old[name]);export_sets[name]=exports(s)
  rows.append({'name':name,'baseline_sha256':sha(old[name].encode()),'candidate_sha256':sha(s.encode()),'bytes':len(s.encode()),'changed':s!=old[name],'inverse':'EXACT_EDGE147'})
  if s!=old[name]:
   d=out/'diff'/Path(name+'.diff');d.parent.mkdir(parents=True,exist_ok=True);d.write_text(''.join(difflib.unified_diff(old[name].splitlines(True),s.splitlines(True),fromfile='Edge147/'+name,tofile='Narratore82/'+name)))
 frozen=[]
 for prefix in ['const MISSION_NARRATIVE_SPACE_RULE=','const NARRATOR_MEMORY_TOTAL_VERSION=','const NARRATOR_MEMORY_TOTAL_CAP=','const NARRATOR_MEMORY_TOTAL_RULE=','const SCENE_MEMORY_RULE=',' const sys=\'staff-combat-report-narrator/4.']:
  line=next(line for line in old[runtime].splitlines()if line.startswith(prefix));assert line in new[runtime];frozen.append({'source':prefix,'sha256':sha(line.encode()),'status':'BYTE_IDENTICAL'})
 i=old[runtime].index('function narratorStructuredValue(');unchanged_renderer=old[runtime][i:];assert unchanged_renderer in new[runtime];frozen.append({'source':'projection + memory + combatReportNarratorRequest payload/normalizer to EOF','sha256':sha(unchanged_renderer.encode()),'status':'BYTE_IDENTICAL'})
 assert sum(row['changed']for row in rows)==2
 pack={'name':'mission_generic_ai','entrypoint_path':'mission-generic-index.ts','verify_jwt':b['verify_jwt'],'files':[{'name':f['name'],'content':new[f['name']]}for f in b['files']]};assert pack['verify_jwt']is False
 package=out/'EDGE_PACKAGE.json';package.write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n')
 site=Path(a.site);uiold=(site/'mission-generic-ui.mjs').read_text();ui=uiold;assert sha(ui.encode())=='d57789c6cea2dc0ff4ab75c62328ff3cd70e804047477ad8fcc86be32f5a7d54'
 ctl=next(line for line in ui.splitlines(True)if line.startswith(' const combatReportEditorial80='))
 newctl=ctl.replace('combatReportEditorial80=','combatReportDialogue82=') .replace(previous,campaign).replace("build:'staff-combat-report-ui/5'","build:'staff-combat-report-ui/6'").replace("title:'Narratore · prova editoriale'","title:'Narratore · dialogo nello scontro'").replace("description:'Un Fato dal report completo di uno scontro Staff già concluso. Nessuna missione rigiocata o pubblicazione precedente modificata.'","description:'Due report storici risolti: attacco PG e attacco PNG. Nessuna missione rigiocata, azione reinviata o pubblicazione precedente modificata.'").replace("caseLabels:['Reazioni, ambiente e seguito'],caseCount:1","caseLabels:['Risposta PNG alla provocazione Riuji','Attacco PNG e dialogo con Riuji'],caseCount:2")
 uiedits=[(ctl,ctl+newctl),("  combatReportEditorial80.mount(host);","  combatReportEditorial80.mount(host);\n  combatReportDialogue82.mount(host);"),("dispose(){combatReportEditorial80.dispose();","dispose(){combatReportDialogue82.dispose();combatReportEditorial80.dispose();"),("export const VERSION='mission-combat64-ui/5-narratore80-report05';","export const VERSION='mission-combat64-ui/5-narratore82-report06';")]
 for before,after in uiedits:assert ui.count(before)==1;ui=ui.replace(before,after)
 inverse=ui
 for before,after in reversed(uiedits):assert inverse.count(after)==1;inverse=inverse.replace(after,before)
 assert inverse==uiold
 uidir=out/'ui';uidir.mkdir(exist_ok=True);(uidir/'mission-generic-ui.mjs').write_text(ui)
 result=subprocess.run([node,'--check',str(uidir/'mission-generic-ui.mjs')],capture_output=True,text=True);assert result.returncode==0,result.stderr
 landold=(site/'land.html').read_text();assert sha(landold.encode())=='67af4c913b6b3af0d8fd740d820f7aa2304c74ba128aa2a31ab388abff9f0201'
 oldpin='./mission-generic-ui.mjs?v=narratore80-d57789c6cea2dc0f';newpin='./mission-generic-ui.mjs?v=narratore82-'+sha(ui.encode())[:16]
 assert landold.count(oldpin)==1;land=landold.replace(oldpin,newpin);assert land.replace(newpin,oldpin)==landold;(uidir/'land.html').write_text(land)
 for name,before,after in [('land.html',landold,land),('mission-generic-ui.mjs',uiold,ui)]:
  (out/'diff'/(name+'.diff')).write_text(''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='LAND-Esame5592/'+name,tofile='Narratore82/'+name)))
 remote={'head':'6a2833e8cf4eddd4c63c0976599d3c4bf401d9a5','evidence':'PM fresh remote ref/blob reconciliation; local baseline Git blob SHA1 matched the supplied published assets. Content-addressed, not full remote readback by this branch.'};uirows=[]
 for name,s in [('land.html',land),('mission-generic-ui.mjs',ui)]:
  before=(site/name).read_bytes();blob=hashlib.sha1(b'blob '+str(len(before)).encode()+b'\0'+before).hexdigest();assert blob=={'land.html':'502292709cf4fb15dcbe5129990d67df0b08c7b6','mission-generic-ui.mjs':'85438e101a7dca53a59094f4b954b8a9aff57bfa'}[name]
  uirows.append({'path':'sito_live/'+name,'baseline_bytes':len(before),'baseline_sha256':sha(before),'baseline_git_blob':blob,'candidate_bytes':len(s.encode()),'candidate_sha256':sha(s.encode()),'candidate_path':str(uidir/name),'inverse':'EXACT_PUBLISHED_BASELINE_ESAME5592'})
 helper=(Path('/Users/antonello/Desktop/theuntoldstory/sito_live')/'mission-editorial-staff.mjs').read_bytes();assert sha(helper)=='34fa4e6596cf18d3eb56130e487c8a0f6e0af7f152e06aebbeeca1859567255f'
 uimanifest={'schema':'narratore82-ui/1','campaign_id':campaign,'historical_read_campaigns':historical+[previous],'module_version':'mission-combat64-ui/5-narratore82-report06','module_pin':'narratore82-'+sha(ui.encode())[:16],'files':uirows,'unchanged_helper_sha256':sha(helper),'remote':remote,'case_count':2,'case_labels':['Risposta PNG alla provocazione Riuji','Attacco PNG e dialogo con Riuji'],'old_panes_preserved':True,'separate_new_case_journals':True,'no_polling_autostart':True,'html_delta':'one import cache pin; all published Exam5592 changes retained','global_build':'UNCHANGED','syntax':'PASS_MODULE','runtime':'NOT_RUN'}
 (out/'UI.json').write_text(json.dumps(uimanifest,ensure_ascii=False,indent=2)+'\n')
 contract={'schema':'narratore82-real-report-preview/1','aggregate':32,'campaign_id':campaign,'cases':{'1':'Original direct native report source/1; PG attack and PNG defense.','2':'Original full unified payload and original full contract source/2; select only the already attested resolved_scenes[0] native report. PNG attack and PG defense with authentic speech.'},
  'source2_extra_keys':['selected_payload_path','selected_payload_sha256'],'source2_authority':'DB verifies sealed original outer/contract/native node/report/round plus immutable path attestation. Renderer pins the same known work/hash/path and selects the original object without constructing a scene or barrier.',
  'source2_pins':{'work_id':'d075b2a7-d7af-4afe-b0cc-0bcc13c3faab','payload_sha256':'bdcc5d0759c78ac736905360003580ab9378d9ba259e14ce1cbf7bba775f46b5','contract_sha256':'3bf81815ed745b2e7eb357b0bfc2265e3e253820de90391eff598d5959f23681','selected_payload_path':['resolved_scenes','0'],'selected_payload_sha256':'3b7cb7253240524b4088a41e5922738f04eddfbe394fc904863dd192a5a0829b'},
  'runtime_factory':'new campaign only; exact case/source1 or case2/source2 tuple. Same unchanged renderer after source selection.','handler':'Cases1/2 only for new82, historical readers75–80 remain case1; per-case request and run bindings; same worker/ledger.',
  'frozen':['mission-narrative-space/2','staff-combat-report-narrator/4','projection','memory7080','output schema/order/normalizer','global validators','Director','WAIT','provider accounting'],
  'budget':{'cases':2,'Count':2,'Generation':2,'HTTP':4,'USD_additional_max':0.088,'USD_total_cap':4,'input_tokens_per_case':120000,'output_tokens_per_case':20000,'provider_minutes':30,'close_minutes':15,'retry':False},
  'not_done':['local projector/gameplay execution','new role submission','mission replay','Fato modification','new mechanical counterattack','provider calls before installed Staff test'],
  'quality_status':'NOT_RUN'}
 (out/'INPUT_CONTRACT.json').write_text(json.dumps(contract,ensure_ascii=False,indent=2)+'\n')
 (out/'PROMPT_DIFF.md').write_text('# Narratore82 · nessun delta alle istruzioni\n\nCORE81 `mission-narrative-space/2`, trasporto `/4`, proiezione, memoria7080, schema e normalizzatore restano byte identici aEdge147. Cambiano soltanto il routing della nuova campagna, la selezione di due fonti reali immutabili e la UI privata.\n\nCaso1 conserva la fonte diretta/1. Caso2 conserva l’intero workunifiedoriginale e il contrattooriginale; il path già attestato seleziona un nodo nativo esistente, senza produrre una fixture, ricostruire scene/barriere o modificare role/report. I consumer storici restano leggibili. La qualità si giudica soltanto sui risultati reali Staff.\n')
 static={'aggregate':32,'baseline_edge':147,'baseline_ezbr':b['ezbr_sha256'],'baseline_metadata_sha256':sha(raw),'package_sha256':sha(package.read_bytes()),'builder_sha256':sha(Path(__file__).read_bytes()),'files':rows,'changed_files':2,'unchanged_files':14,'syntax':syntax,'relative_imports':'RESOLVED_STATIC','whole_inverse':'EXACT_EDGE147','export_sets':export_sets,'export_api':'EXACT_EDGE147','campaign_id':campaign,'historical_read_campaigns':historical+[previous],'case_count':2,'source2_scope':'new82case2 only; sealed pre-existing node selection','frozen_proofs':frozen,'prompt_projection_memory_output_normalizer':'BYTE_IDENTICAL','global_validator_changes':0,'local_projector_gameplay_execution':False,'provider_calls':0,'runtime_quality':'NOT_RUN','UI':uimanifest}
 (out/'STATIC.json').write_text(json.dumps(static,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({key:static[key]for key in ['aggregate','package_sha256','builder_sha256','changed_files','unchanged_files','case_count','provider_calls']}))
if __name__=='__main__':main()
