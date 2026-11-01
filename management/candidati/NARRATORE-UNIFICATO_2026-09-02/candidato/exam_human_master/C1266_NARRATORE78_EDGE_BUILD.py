#!/usr/bin/env python3
"""C1266 aggregate28: one total-content memory capacity; static checks only."""
import argparse,hashlib,json,re,posixpath,subprocess,difflib
from pathlib import Path
def sha(b):return hashlib.sha256(b).hexdigest()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--baseline',required=True);ap.add_argument('--site',required=True);ap.add_argument('--output',required=True);a=ap.parse_args()
 baseline=Path(a.baseline).read_bytes();b=json.loads(baseline);assert b['version']==143 and len(b['files'])==16
 old={f['name']:f['content']for f in b['files']};new=dict(old);edits={}
 previous='e0b73266-f03f-5e6d-a54f-d025f5673615';older=['07640a7d-73fe-5f9b-b78b-f65199596a2f','bb24b63b-c121-54a3-a43f-6a49135c780f'];campaign='6fc6dbce-82ce-5a70-b5ee-cd3333ada2cf'
 def once(n,before,after):
  assert new[n].count(before)==1,(n,before[:100],new[n].count(before));new[n]=new[n].replace(before,after);edits.setdefault(n,[]).append((before,after))
 runtime='mission-generic-runtime.mjs';handler='mission-staff-editorial.mjs'
 once(runtime,"export const COMBAT_REPORT_CAMPAIGN='"+previous+"';","export const COMBAT_REPORT_CAMPAIGN='"+campaign+"';")
 helper="""// Prompt4 report memory only. Legacy memory schemas/rules/validators stay unchanged.
const NARRATOR_MEMORY_TOTAL_VERSION='mission-narrator-memory-total/1';
const NARRATOR_MEMORY_TOTAL_CAP=7080;
const narratorTotalMemorySchema={type:'object',additionalProperties:false,required:['state','known','open','used'],
 description:`Memoria privata: capienza complessiva di ${NARRATOR_MEMORY_TOTAL_CAP} codepoint Unicode nei contenuti di state e di tutte le voci known, open e used, distribuiti liberamente tra campi e voci.`,
 properties:{state:{type:'string'},known:{type:'array',items:{type:'string'}},open:{type:'array',items:{type:'string'}},used:{type:'array',items:{type:'string'}}}};
const NARRATOR_MEMORY_TOTAL_RULE=SCENE_MEMORY_RULE+'\\n'+NARRATOR_MEMORY_TOTAL_VERSION+'. La memoria ha una capienza complessiva di '+NARRATOR_MEMORY_TOTAL_CAP+' codepoint Unicode, sommando il contenuto di state e di tutte le voci known, open e used. Distribuiscila liberamente fra campi e voci, senza limiti per singola frase o numero di voci; la sintassi JSON non entra nel conteggio. Esprimi unità di significato complete entro questa capienza, senza troncare il testo.';
function narratorTotalMemoryShape(memory){
 if(!exact(memory,['state','known','open','used'])||typeof memory.state!=='string'
  ||!['known','open','used'].every(key=>Array.isArray(memory[key])&&memory[key].every(value=>typeof value==='string')))return false;
 return [memory.state,...memory.known,...memory.open,...memory.used].reduce((total,value)=>total+Array.from(value).length,0)<=NARRATOR_MEMORY_TOTAL_CAP;
}
"""
 boundary='export async function combatReportNarratorRequest(p,b,limits){';once(runtime,boundary,helper+'\n'+boundary)
 oldsys=re.search(r' const sys="staff-combat-report-narrator/3\.[^\n]+',old[runtime]);assert oldsys;oldsys=oldsys.group(0)
 newsys=oldsys.replace('staff-combat-report-narrator/3.','staff-combat-report-narrator/4.').replace('+SCENE_MEMORY_RULE;','+NARRATOR_MEMORY_TOTAL_RULE;')
 assert newsys!=oldsys;once(runtime,oldsys,newsys)
 oldformat="text:{format:{type:'json_schema',name:'staff_combat_report_narrative_memory',strict:true,schema:{type:'object',properties:{text:{type:'string'},scene_memory:sceneMemorySchema},required:['text','scene_memory'],additionalProperties:false}}}};"
 newformat=oldformat.replace('scene_memory:sceneMemorySchema','scene_memory:narratorTotalMemorySchema');once(runtime,oldformat,newformat)
 oldcheck="||!narrativeSceneMemoryShape(value.scene_memory))bad();";newcheck="||!narratorTotalMemoryShape(value.scene_memory))bad();";once(runtime,oldcheck,newcheck)
 once(handler," const readableCampaigns=new Set(['"+older[0]+"','"+older[1]+"',campaign]);"," const readableCampaigns=new Set(['"+older[0]+"','"+older[1]+"','"+previous+"',campaign]);")
 once(handler,"value.prompt_revision!=='staff-combat-report-narrator/3'","value.prompt_revision!=='staff-combat-report-narrator/4'")
 out=Path(a.output);out.mkdir(parents=True,exist_ok=True);files=[];syntax=[]
 node='/Users/antonello/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node'
 for n,s in new.items():
  p=out/'edge'/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s)
  if n.endswith('.mjs'):
   q=subprocess.run([node,'--check',str(p)],capture_output=True,text=True);assert q.returncode==0,(n,q.stderr);syntax.append(n)
  for imp in re.findall(r"(?:from\s*|import\s*)['\"](\.[^'\"]+)['\"]",s):assert posixpath.normpath(str(Path(n).parent/imp))in new
  inverse=s
  for before,after in reversed(edits.get(n,[])):assert inverse.count(after)==1;inverse=inverse.replace(after,before)
  assert inverse==old[n]
  files.append({'name':n,'baseline_sha256':sha(old[n].encode()),'candidate_sha256':sha(s.encode()),'bytes':len(s.encode()),'changed':s!=old[n],'inverse':'EXACT_EDGE143'})
  if s!=old[n]:
   d=out/'diff'/Path(n+'.diff');d.parent.mkdir(parents=True,exist_ok=True);d.write_text(''.join(difflib.unified_diff(old[n].splitlines(True),s.splitlines(True),fromfile='Edge143/'+n,tofile='Narratore78/'+n)))
 # Static byte-equivalence only, no local projector/gameplay/model execution.
 old_projection_start=old[runtime].index('function narratorStructuredValue(');old_projection_end=old[runtime].index('export async function combatReportNarratorRequest(',old_projection_start)
 projection=old[runtime][old_projection_start:old_projection_end];assert projection in new[runtime]
 rule_line=next(line for line in old[runtime].splitlines()if line.startswith('const SCENE_MEMORY_RULE='));assert rule_line in new[runtime]
 for name,end in [('function narrativeSceneMemoryShape(', 'function checkedNarrativeSceneOutput('),('function narrativeActorPersonaView(','function nativeWriterActors(')]:
  start=old[runtime].index(name);stop=old[runtime].index(end,start);assert old[runtime][start:stop]in new[runtime],name
 assert oldsys.replace('staff-combat-report-narrator/3.','staff-combat-report-narrator/4.').replace('+SCENE_MEMORY_RULE;','+NARRATOR_MEMORY_TOTAL_RULE;')==newsys
 assert 'maxLength'not in helper and 'maxItems'not in helper
 oldnormal="  return {ok:true,origin:'combat_report',text:value.text,scene_memory:value.scene_memory,advisories:[],failure_codes:[]};";assert oldnormal in old[runtime]and oldnormal in new[runtime]
 pack={'name':'mission_generic_ai','entrypoint_path':'mission-generic-index.ts','verify_jwt':b['verify_jwt'],'files':[{'name':f['name'],'content':new[f['name']]}for f in b['files']]};assert pack['verify_jwt']is False
 package=out/'EDGE_PACKAGE.json';package.write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n')
 site=Path(a.site);uiold=(site/'mission-generic-ui.mjs').read_text();ui=uiold;assert sha(ui.encode())=='4a89a8eed57dc30e64b58fe6730c19d5aa93797102717a9d3757feddeeacb8bc'
 ctl=next(line for line in ui.splitlines(True)if line.startswith(' const combatReportStructured='))
 newctl=ctl.replace('combatReportStructured=','combatReportTotalMemory=') .replace(previous,campaign).replace("build:'staff-combat-report-ui/3'","build:'staff-combat-report-ui/4'").replace("title:'Narratore · fonti e memoria'","title:'Narratore · memoria complessiva'").replace("caseLabels:['Fatti, reazioni e memoria privata']","caseLabels:['Memoria a capienza complessiva']")
 uiedits=[(ctl,ctl+newctl),("  combatReportStructured.mount(host);","  combatReportStructured.mount(host);\n  combatReportTotalMemory.mount(host);"),("dispose(){combatReportStructured.dispose();","dispose(){combatReportTotalMemory.dispose();combatReportStructured.dispose();"),("export const VERSION='mission-combat64-ui/5-narratore77-report03';","export const VERSION='mission-combat64-ui/5-narratore78-report04';")]
 for before,after in uiedits:assert ui.count(before)==1;ui=ui.replace(before,after)
 inv=ui
 for before,after in reversed(uiedits):assert inv.count(after)==1;inv=inv.replace(after,before)
 assert inv==uiold
 uidir=out/'ui';uidir.mkdir(exist_ok=True);(uidir/'mission-generic-ui.mjs').write_text(ui)
 q=subprocess.run([node,'--check',str(uidir/'mission-generic-ui.mjs')],capture_output=True,text=True);assert q.returncode==0,q.stderr
 landold=(site/'land.html').read_text();assert sha(landold.encode())=='beceecc6c7183b63208250c4f1c3f4c99c038d0c4a002a402e1f851af504fb2e'
 oldpin='./mission-generic-ui.mjs?v=narratore77-4a89a8eed57dc30e';newpin='./mission-generic-ui.mjs?v=narratore78-'+sha(ui.encode())[:16]
 assert landold.count(oldpin)==1;land=landold.replace(oldpin,newpin);assert land.replace(newpin,oldpin)==landold;(uidir/'land.html').write_text(land)
 for name,bs,cs in [('mission-generic-ui.mjs',uiold,ui),('land.html',landold,land)]:
  (out/'diff'/(name+'.diff')).write_text(''.join(difflib.unified_diff(bs.splitlines(True),cs.splitlines(True),fromfile='UIdf11/'+name,tofile='Narratore78/'+name)))
 helper_hash=sha((site/'mission-editorial-staff.mjs').read_bytes());assert helper_hash=='34fa4e6596cf18d3eb56130e487c8a0f6e0af7f152e06aebbeeca1859567255f'
 remote={'head':'bce702937f9f367958d46862b9c4fccad5d21b2c','tree':'80013432298f4cabef61618afba059d27017d176','evidence':'Fresh GitHub ref/tree via connector; local Git blob SHA1 matched tree. Content-addressed reconciliation, not full remote readback.'}
 uirows=[]
 for n,s in [('land.html',land),('mission-generic-ui.mjs',ui)]:
  bs=(site/n).read_bytes();blob=hashlib.sha1(b'blob '+str(len(bs)).encode()+b'\0'+bs).hexdigest();expected={'land.html':'776734819f5145a4f6a2f0e5512867929a080a2e','mission-generic-ui.mjs':'769ebf6115221454a7a2d5ca588314db6a76b2d9'}[n];assert blob==expected
  uirows.append({'path':'sito_live/'+n,'baseline_bytes':len(bs),'baseline_sha256':sha(bs),'baseline_git_blob':blob,'candidate_bytes':len(s.encode()),'candidate_sha256':sha(s.encode()),'candidate_path':str(uidir/n),'inverse':'EXACT_UIdf11'})
 uimanifest={'schema':'narratore78-ui/1','campaign_id':campaign,'historical_read_campaigns':older+[previous],'module_version':'mission-combat64-ui/5-narratore78-report04','module_pin':'narratore78-'+sha(ui.encode())[:16],'files':uirows,'unchanged_helper_sha256':helper_hash,'remote':remote,'old_panes_preserved':True,'separate_new_journal':True,'no_polling_autostart':True,'html_delta':'one import cache pin only','global_build':'UNCHANGED','syntax':'PASS_MODULE','runtime':'NOT_RUN'}
 (out/'UI.json').write_text(json.dumps(uimanifest,ensure_ascii=False,indent=2)+'\n')
 contract={'schema':'mission-narrator-memory-total/1','input_projection':'mission-narrator-report-input/2 unchanged byte-for-byte from77','campaign_id':campaign,'prompt_revision':'staff-combat-report-narrator/4',
  'memory':{'keys':['state','known','open','used'],'state_type':'string','other_fields_type':'array of strings','capacity_total_codepoints':7080,'counted_content':'state plus every string in known/open/used; Unicode codepoints, JSON syntax excluded','JS_count':'Array.from(value).length summed across all content strings','DB_count':'PostgreSQL length(value) summed across all content strings','per_string_maxLength':None,'per_bucket_maxItems':None,'provider_schema':'shape only, global capacity described to model','provider_enforces_sum':False,'runtime_and_DB_enforce_sum':True,'versioned_constant':'NARRATOR_MEMORY_TOTAL_CAP=7080, no new Root/policy key'},
  'output':{'required':['text','scene_memory'],'normalized_keys':['ok','origin','text','scene_memory','advisories','failure_codes'],'storage':'private editorial_runs.result.scene_memory; publicResult unchanged'},
  'unchanged':['projection77','narrative paragraph except prompt version','field order','legacy sceneMemorySchema/narrativeSceneMemoryShape/SCENE_MEMORY_RULE','source/report/history/receipts','ledger/accounting/worker'],
  'not_allowed':['truncation','reassembly','fallback','retry','second model call','semantic validation','model choice of capacity','gameplay memory mutation'],
  'risk':'JSON schema cannot express this aggregate sum. Runtime and DB enforce the technical capacity; raw is retained on failure. Existing provider output and transport limits bound JSON overhead; no hidden entry-count limit is added.',
  'runtime_quality':'NOT_RUN'}
 (out/'INPUT_CONTRACT.json').write_text(json.dumps(contract,ensure_ascii=False,indent=2)+'\n')
 (out/'PROMPT_DIFF.md').write_text('# Narratore78 · capienza complessiva memoria\n\nIl paragrafo narrativo, la proiezione77 e l’ordine dell’output restano identici, salvo il numero di versione del prompt.\n\nLa regola memoria esistente resta byte identica e riceve una specifica isolata `mission-narrator-memory-total/1`: 7080 codepoint Unicode complessivi nei contenuti di state e di tutte le voci known/open/used; distribuzione libera; nessun massimo per frase o numero di voci; sintassi JSON esclusa.\n\nIl nuovo schema conserva i quattro campi e i tipi, senza maxLength/maxItems. Il solo validatore della nuova preview verifica forma e somma globale. Il provider verifica la forma JSON; runtime e DB verificano la capienza. Nessun troncamento, ricomposizione, ripiego, secondo tentativo o chiamata aggiuntiva. Le memorie e i lettori precedenti restano invariati.\n')
 static={'aggregate':28,'baseline_edge':143,'baseline_ezbr':b['ezbr_sha256'],'baseline_metadata_sha256':sha(baseline),'package_sha256':sha(package.read_bytes()),'builder_sha256':sha(Path(__file__).read_bytes()),'new_total_memory_helper_sha256':sha(helper.encode()),'files':files,'changed_files':sum(f['changed']for f in files),'unchanged_files':sum(not f['changed']for f in files),'syntax':syntax,'relative_imports':'RESOLVED_STATIC','whole_inverse':'EXACT_EDGE143','campaign_id':campaign,'historical_read_campaigns':older+[previous],'projection77_sha256':sha(projection.encode()),'projection77':'BYTE_IDENTICAL','narrative_paragraph_and_output_order':'IDENTICAL_EXCEPT_VERSION_AND_SCOPED_MEMORY_BINDING','legacy_helpers':'BYTE_IDENTICAL','capacity_codepoints':7080,'new_schema_has_per_entry_caps':False,'provider_sum_enforcement':False,'runtime_DB_sum_enforcement':True,'new_semantic_gate':False,'source_payload_and_binding':'UNCHANGED','prompt_revision':'staff-combat-report-narrator/4','provider_calls':0,'runtime_quality':'NOT_RUN','UI':uimanifest}
 (out/'STATIC.json').write_text(json.dumps(static,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({k:static[k]for k in ['aggregate','package_sha256','builder_sha256','changed_files','unchanged_files','provider_calls']}))
if __name__=='__main__':main()
