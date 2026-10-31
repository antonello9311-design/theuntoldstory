#!/usr/bin/env python3
"""E74 identity-only Staff preview adaptation from exact Edge138/UI959. Static only."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,difflib,posixpath
CAMPAIGN='beabfc88-ae45-53b1-b081-d137cd8eac41'
OLD_CAMPAIGN='ff79949a-06cb-5749-a33f-3d632d78f3a5'
EXPECTED={'mission-generic-runtime.mjs':'e8393345e5c5141546141765abd7735dfe770b8c7c4e09dc790b9c4ef844166c','mission-staff-editorial-pair.mjs':'3029e4691cdd486819a90f2c42a978efc82cdac327e13e670503ca57430fb2c6'}
UI_EXPECTED={'mission-editorial-staff.mjs':'0da10edf148d3c9d93e7c36f8b938958ee01917047e549828ddddd9e12be537d','mission-generic-ui.mjs':'52ce524cb0003389a5aa83ffe0726fd046f0954282f74ee07a344421b64199a4','land.html':'b3f0b4f0139b48145abb05f74e6046390d53cb257c32badec696872414d986c1'}
def sha(v):return hashlib.sha256(v.encode()).hexdigest()
def once(s,a,b):
 assert s.count(a)==1,(s.count(a),a[:100]);return s.replace(a,b)
def edge_sources(old):
 runtime=old['mission-generic-runtime.mjs'];marker="const EDITORIAL_DIALOGUE_E71_CAMPAIGN='"+OLD_CAMPAIGN+"';"
 runtime=once(runtime,marker,marker+"\nconst EDITORIAL_DIALOGUE_E73_CAMPAIGN='"+CAMPAIGN+"';")
 runtime=once(runtime,'![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN,EDITORIAL_DIALOGUE_E71_CAMPAIGN].includes(source.campaign_id)','![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN,EDITORIAL_DIALOGUE_E71_CAMPAIGN,EDITORIAL_DIALOGUE_E73_CAMPAIGN].includes(source.campaign_id)')
 pair=old['mission-staff-editorial-pair.mjs'];marker="const DIALOGUE_E71_CAMPAIGN='"+OLD_CAMPAIGN+"';"
 pair=once(pair,marker,marker+"\nconst DIALOGUE_E73_CAMPAIGN='"+CAMPAIGN+"';")
 pair=once(pair,'(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN||id===DIALOGUE_E71_CAMPAIGN)?{work:','(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN||id===DIALOGUE_E71_CAMPAIGN||id===DIALOGUE_E73_CAMPAIGN)?{work:')
 return {**old,'mission-generic-runtime.mjs':runtime,'mission-staff-editorial-pair.mjs':pair}
def ui_sources(old):
 module=old['mission-editorial-staff.mjs'];marker="export const LATEST_CAMPAIGN='"+OLD_CAMPAIGN+"';"
 module=once(module,marker,marker+"\nexport const E73_BUILD='staff-editorial-review73-ui/1';\nexport const E73_CAMPAIGN='"+CAMPAIGN+"';")
 main=old['mission-generic-ui.mjs'];modulepin=sha(module)[:16]
 main=once(main,"import {createStaffEditorial,createStaffEditorialPair,DIALOGUE_CAMPAIGN,DIALOGUE_BUILD,REVIEW_CAMPAIGN,REVIEW_BUILD,LATEST_CAMPAIGN,LATEST_BUILD} from './mission-editorial-staff.mjs?v=editorial72-0da10edf148d3c9d';","import {createStaffEditorial,createStaffEditorialPair,DIALOGUE_CAMPAIGN,DIALOGUE_BUILD,REVIEW_CAMPAIGN,REVIEW_BUILD,LATEST_CAMPAIGN,LATEST_BUILD,E73_CAMPAIGN,E73_BUILD} from './mission-editorial-staff.mjs?v=editorial74-"+modulepin+"';")
 main=once(main,"export const VERSION='mission-combat64-ui/5-editorial72-review71';","export const VERSION='mission-combat64-ui/5-editorial74-review73';")
 line=next(x for x in main.splitlines()if x.startswith(' const editorialReview=createStaffEditorialPair('))
 new=" const editorialE73=createStaffEditorialPair({client,identity,isStaff,currentLocation,staffRoom:STAFF_TEST_ROOM,campaign:E73_CAMPAIGN,build:E73_BUILD,title:'Verifica E73 · Staff',description:'Tre nuove prove private con le istruzioni E73 e gli stessi input del confronto precedente. Nessuna role inviata o missione rigiocata; i Fati pubblicati restano invariati.',caseLabels:['Fatti e aggiunte personali','Motivazioni e dissenso','Rettifica nel mercato']});"
 main=once(main,line,line+'\n'+new)
 main=once(main,'  editorialReview.mount(host);','  editorialReview.mount(host);\n  editorialE73.mount(host);')
 main=once(main,'dispose(){editorialLatest.dispose();','dispose(){editorialE73.dispose();editorialLatest.dispose();')
 land=once(old['land.html'],"import('./mission-generic-ui.mjs?v=editorial72-52ce524cb0003389')","import('./mission-generic-ui.mjs?v=editorial74-"+sha(main)[:16]+"')")
 # Reversibility of each exact UI delta proves that controller, auth, receipts and no-poll flow remain unchanged.
 reverse=module.replace("\nexport const E73_BUILD='staff-editorial-review73-ui/1';\nexport const E73_CAMPAIGN='"+CAMPAIGN+"';",'');assert reverse==old['mission-editorial-staff.mjs']
 reverse=main.replace(',E73_CAMPAIGN,E73_BUILD}', '}').replace('editorial74-'+modulepin,'editorial72-0da10edf148d3c9d').replace('mission-combat64-ui/5-editorial74-review73','mission-combat64-ui/5-editorial72-review71').replace('\n'+new,'').replace('\n  editorialE73.mount(host);','').replace('dispose(){editorialE73.dispose();','dispose(){');assert reverse==old['mission-generic-ui.mjs']
 reverse=land.replace("import('./mission-generic-ui.mjs?v=editorial74-"+sha(main)[:16]+"')","import('./mission-generic-ui.mjs?v=editorial72-52ce524cb0003389')");assert reverse==old['land.html']
 assert len('mission-combat64-ui/5-editorial74-review73')==len('mission-combat64-ui/5-editorial72-review71')
 return {'mission-editorial-staff.mjs':module,'mission-generic-ui.mjs':main,'land.html':land}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--baseline',required=True);ap.add_argument('--ui-baseline',required=True);ap.add_argument('--output',required=True);ap.add_argument('--node',default='/Users/antonello/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node');a=ap.parse_args()
 b=json.loads(Path(a.baseline).read_text());assert b['version']==138 and len(b['files'])==16 and b['verify_jwt']is False
 before={x['name']:x['content']for x in b['files']}
 for n,h in EXPECTED.items():assert sha(before[n])==h,(n,'Edge baseline drift')
 after=edge_sources(before);ub=Path(a.ui_baseline);uiold={n:(ub/n).read_text()for n in UI_EXPECTED}
 for n,h in UI_EXPECTED.items():assert sha(uiold[n])==h,(n,'published UI drift')
 uinew=ui_sources(uiold);out=Path(a.output);out.mkdir(parents=True,exist_ok=True);checks=[];manifest=[];diffs=[]
 def syntax(f,label):
  r=subprocess.run([a.node,'--check',str(f)],capture_output=True,text=True);assert r.returncode==0,(label,r.stderr);checks.append({'file':label,'exit_code':0})
 for item in b['files']:
  n=item['name'];body=after[n];f=out/'edge'/n;f.parent.mkdir(parents=True,exist_ok=True);f.write_text(body)
  manifest.append({'name':n,'baseline_sha256':sha(before[n]),'candidate_sha256':sha(body),'bytes':len(body.encode()),'changed':body!=before[n]})
  if n.endswith('.mjs'):syntax(f,'edge/'+n)
  for imp in re.findall(r"(?:from\s*|import\s*)['\"](\.[^'\"]+)['\"]",body):assert posixpath.normpath(str(Path(n).parent/imp))in after,(n,imp)
  if body!=before[n]:
   diff=''.join(difflib.unified_diff(before[n].splitlines(True),body.splitlines(True),fromfile='Edge138/'+n,tofile='E74/'+n));(out/(n+'.diff')).write_text(diff);diffs.append(diff)
 pack={'name':'mission_generic_ai','entrypoint_path':'mission-generic-index.ts','verify_jwt':b['verify_jwt'],'files':[{'name':x['name'],'content':after[x['name']]}for x in b['files']]};pp=out/'C1266_EDITORIAL74_EDGE_PACKAGE.json';pp.write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n')
 uirows=[]
 for n,body in uinew.items():
  f=out/'sito_live'/n;f.parent.mkdir(exist_ok=True);f.write_text(body);uirows.append({'path':'sito_live/'+n,'baseline_sha256':sha(uiold[n]),'baseline_bytes':len(uiold[n].encode()),'candidate_sha256':sha(body),'candidate_bytes':len(body.encode()),'candidate_path':'sito_live/'+n})
  if n.endswith('.mjs'):syntax(f,'ui/'+n)
  (out/(n+'.diff')).write_text(''.join(difflib.unified_diff(uiold[n].splitlines(True),body.splitlines(True),fromfile='Published/'+n,tofile='E74/'+n)))
 for i,(attrs,body)in enumerate(re.findall(r'<script\b([^>]*)>(.*?)</script\s*>',uinew['land.html'],re.S|re.I)):
  if 'src='in attrs or re.search(r'type=[\'\"](?:application/(?:ld\+)?json|importmap)',attrs):continue
  module=bool(re.search(r'type=[\'\"]module',attrs));f=out/('land-script-'+str(i)+('.mjs'if module else'.js'));f.write_text(body if module else'(async function(){\n'+body+'\n})();');syntax(f,'ui/land script '+str(i))
 reverse=after['mission-generic-runtime.mjs'].replace("\nconst EDITORIAL_DIALOGUE_E73_CAMPAIGN='"+CAMPAIGN+"';",'').replace('![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN,EDITORIAL_DIALOGUE_E71_CAMPAIGN,EDITORIAL_DIALOGUE_E73_CAMPAIGN].includes(source.campaign_id)','![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN,EDITORIAL_DIALOGUE_E71_CAMPAIGN].includes(source.campaign_id)');assert reverse==before['mission-generic-runtime.mjs']
 reverse=after['mission-staff-editorial-pair.mjs'].replace("\nconst DIALOGUE_E73_CAMPAIGN='"+CAMPAIGN+"';",'').replace('(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN||id===DIALOGUE_E71_CAMPAIGN||id===DIALOGUE_E73_CAMPAIGN)?{work:','(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN||id===DIALOGUE_E71_CAMPAIGN)?{work:');assert reverse==before['mission-staff-editorial-pair.mjs']
 static={'status':'SOURCE_FROZEN_NOT_INSTALLED_NOT_REVIEWED','baseline_edge':138,'baseline_metadata_sha256':hashlib.sha256(Path(a.baseline).read_bytes()).hexdigest(),'campaign_id':CAMPAIGN,'files':manifest,'changed_edge_files':sum(x['changed']for x in manifest),'package_sha256':hashlib.sha256(pp.read_bytes()).hexdigest(),'builder_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'syntax':checks,'relative_imports':'RESOLVED_STATIC','preserved':'Whole Edge runtime/pair and all3UI assets identical after inverse identity-only delta; old UI controller is exact','prompts_E73':'BYTE_IDENTICAL','schemas_bounds_normalizers':'BYTE_IDENTICAL','provider_calls':0,'gameplay_tests':'NOT_RUN','rebuild':'DETERMINISTIC_PACKAGE_STATIC_UI_DIFF','start_authority':'Existing authenticated RPC campaign/Root authority remains required; only explicit E68/E70/E72/E74 IDs admitted','UI_version_length_unchanged':True}
 assert static['changed_edge_files']==2
 for n in before:
  if n not in EXPECTED:assert after[n]==before[n],(n,'unrelated source drift')
 static['whole_16files_inverse']='BYTE_IDENTICAL_EDGE138'
 static['E73_all45_text_regions']='UNCHANGED_BY_IDENTITY_ONLY_WHOLE_FILE_INVERSE'
 static['unchanged_edge_files']=14
 (out/'C1266_EDITORIAL74_EDGE_STATIC.json').write_text(json.dumps(static,ensure_ascii=False,indent=2)+'\n')
 (out/'C1266_EDITORIAL74_UI.json').write_text(json.dumps({'status':'CANDIDATE_NOT_APPLIED','campaign_id':CAMPAIGN,'old_campaign_ids':['a8c3c6f9-949d-5b64-8a02-80667c7b4da8','2bd901b7-6ba6-5319-a55a-2d2e2cfcf03b',OLD_CAMPAIGN],'published_ref':'5cbc4fe8103ac97b8907ba752bb643e5fe24314e','files':uirows,'syntax':[x for x in checks if x['file'].startswith('ui/')],'controller_reused':True,'new_polling':False,'automatic_start':False,'journal_scope':'build + authenticated user + campaign + case','existing_E65_E66_E68_E70_E72':'UNCHANGED','version':'mission-combat64-ui/5-editorial74-review73','LAND_build':'C1266-COMBAT64-UI7_UNCHANGED'},ensure_ascii=False,indent=2)+'\n')
 note='''# E74 — adattamento tecnico della preview E73

Delta dalla Edge138 e dai tre asset UI riconciliati su Git main5cbc4fe. Cambiano soltanto due allowlist d’identità nella Edge: il runtime e il consumer della coppia ammettono la nuova campagnaE74 oltre alle precedenti E68/E70/E72. Tutti i testi E73, incluse le 45 regioni nei tre moduli runtime, Narrative Master ed editorial, restano byteidentici, così come schemi, bounds, normalizzatori, validator, quote, autorità e topologia. Nessun nuovo Director viene aggiunto alla narrazione ordinaria.

La UI aggiunge un’istanza del medesimo controller Staff per Verifica E73. Restano i pannelli e i journal precedenti; il nuovo journal ha namespace distinto per build/utente/campagna/caso. Nessun polling, autostart o generazione automatica. I tre asset cambiano solo per gli export d’identità, i link/pin, l’istanza, mount/dispose e la stringa di versione, della stessa lunghezza precedente. Il build generale LAND e tutte le classi e costanti estranee restano invariati.

Prove statiche:15MJS Edge,2MJS UI e gli script LAND eseguibili analizzati con node --check; import relativi risolti. Le sostituzioni inverse ripristinano l’intero runtime, il consumer della coppia e i tre asset UI byte per byte: la prova copre l’intera baseline, non solo tre prompt selezionati. Il rebuild riproduce pacchetto/static/UI/diff. Nessun gameplay, provider, deploy o SQL eseguito da questo contributo. La nuova campagna richiede comunque l’autorità server e l’installazione integrata qualificata; la presenza della UI non abilita la prova.

## Identità

'''
 note+='- Package SHA256: `'+static['package_sha256']+'`.\n- Builder SHA256: `'+static['builder_sha256']+'`.\n- Runtime candidato: `'+sha(after['mission-generic-runtime.mjs'])+'`.\n- Pair candidato: `'+sha(after['mission-staff-editorial-pair.mjs'])+'`.\n\n## Diff Edge esatto\n\n```diff\n'+''.join(diffs)+'```\n'
 (out/'C1266_EDITORIAL74_PROMPT_DIFF.md').write_text(note)
 print(json.dumps({'package_sha256':static['package_sha256'],'changed_edge_files':static['changed_edge_files'],'syntax':len(checks),'campaign_id':CAMPAIGN}))
if __name__=='__main__':main()
