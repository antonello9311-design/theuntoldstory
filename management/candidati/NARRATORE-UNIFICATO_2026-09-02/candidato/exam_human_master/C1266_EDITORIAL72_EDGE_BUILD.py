#!/usr/bin/env python3
"""E72 identity-only Staff preview adaptation from exact Edge136/UI69ad. Static only."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,difflib,posixpath
CAMPAIGN='ff79949a-06cb-5749-a33f-3d632d78f3a5'
OLD_CAMPAIGN='2bd901b7-6ba6-5319-a55a-2d2e2cfcf03b'
EXPECTED={'mission-generic-runtime.mjs':'ea7a4be5281e3d850d8d755a3b097202e6382af70651759116626b534504f6ae','mission-staff-editorial-pair.mjs':'e94bbec5db4dc6bdc1f9cea87582df8677f6294217d7f77d30a4589248488b7d'}
UI_EXPECTED={'mission-editorial-staff.mjs':'c3168a3664c231f24be407104429788bdf5689cded30e44c357e1d901998ff76','mission-generic-ui.mjs':'c29a5709ec6d271bca585e346df3cb88183df4471d87cb1a36708bb464bc91e2','land.html':'70f113f83e37e4d665a4e689cc590e5b8e85da7ed3cdcdd494ab6e74b6edbf06'}
def sha(v):return hashlib.sha256(v.encode()).hexdigest()
def once(s,a,b):
 assert s.count(a)==1,(s.count(a),a[:100]);return s.replace(a,b)
def edge_sources(old):
 runtime=old['mission-generic-runtime.mjs'];marker="const EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN='"+OLD_CAMPAIGN+"';"
 runtime=once(runtime,marker,marker+"\nconst EDITORIAL_DIALOGUE_E71_CAMPAIGN='"+CAMPAIGN+"';")
 runtime=once(runtime,'![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN].includes(source.campaign_id)','![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN,EDITORIAL_DIALOGUE_E71_CAMPAIGN].includes(source.campaign_id)')
 pair=old['mission-staff-editorial-pair.mjs'];marker="const DIALOGUE_REVIEW_CAMPAIGN='"+OLD_CAMPAIGN+"';"
 pair=once(pair,marker,marker+"\nconst DIALOGUE_E71_CAMPAIGN='"+CAMPAIGN+"';")
 pair=once(pair,'(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN)?{work:','(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN||id===DIALOGUE_E71_CAMPAIGN)?{work:')
 return {**old,'mission-generic-runtime.mjs':runtime,'mission-staff-editorial-pair.mjs':pair}
def ui_sources(old):
 module=old['mission-editorial-staff.mjs'];marker="export const REVIEW_CAMPAIGN='"+OLD_CAMPAIGN+"';"
 module=once(module,marker,marker+"\nexport const LATEST_BUILD='staff-editorial-review71-ui/1';\nexport const LATEST_CAMPAIGN='"+CAMPAIGN+"';")
 main=old['mission-generic-ui.mjs'];modulepin=sha(module)[:16]
 main=once(main,"import {createStaffEditorial,createStaffEditorialPair,DIALOGUE_CAMPAIGN,DIALOGUE_BUILD,REVIEW_CAMPAIGN,REVIEW_BUILD} from './mission-editorial-staff.mjs?v=editorial70-c3168a3664c231f2';","import {createStaffEditorial,createStaffEditorialPair,DIALOGUE_CAMPAIGN,DIALOGUE_BUILD,REVIEW_CAMPAIGN,REVIEW_BUILD,LATEST_CAMPAIGN,LATEST_BUILD} from './mission-editorial-staff.mjs?v=editorial72-"+modulepin+"';")
 main=once(main,"export const VERSION='mission-combat64-ui/5-editorial70-review69';","export const VERSION='mission-combat64-ui/5-editorial72-review71';")
 line=next(x for x in main.splitlines()if x.startswith(' const editorialReview=createStaffEditorialPair('))
 new=" const editorialLatest=createStaffEditorialPair({client,identity,isStaff,currentLocation,staffRoom:STAFF_TEST_ROOM,campaign:LATEST_CAMPAIGN,build:LATEST_BUILD,title:'Verifica E71 · Staff',description:'Tre nuove prove private con le istruzioni E71 e gli stessi input del confronto precedente. Nessuna role inviata o missione rigiocata; i Fati pubblicati restano invariati.',caseLabels:['Fatti e aggiunte personali','Motivazioni e dissenso','Rettifica nel mercato']});"
 main=once(main,line,line+'\n'+new)
 main=once(main,'  editorialReview.mount(host);','  editorialReview.mount(host);\n  editorialLatest.mount(host);')
 main=once(main,'dispose(){editorialReview.dispose();','dispose(){editorialLatest.dispose();editorialReview.dispose();')
 land=once(old['land.html'],"import('./mission-generic-ui.mjs?v=editorial70-c29a5709ec6d271b')","import('./mission-generic-ui.mjs?v=editorial72-"+sha(main)[:16]+"')")
 # Reversibility of each exact UI delta proves that controller, auth, receipts and no-poll flow remain unchanged.
 reverse=module.replace("\nexport const LATEST_BUILD='staff-editorial-review71-ui/1';\nexport const LATEST_CAMPAIGN='"+CAMPAIGN+"';",'');assert reverse==old['mission-editorial-staff.mjs']
 reverse=main.replace(',LATEST_CAMPAIGN,LATEST_BUILD}', '}').replace('editorial72-'+modulepin,'editorial70-c3168a3664c231f2').replace('mission-combat64-ui/5-editorial72-review71','mission-combat64-ui/5-editorial70-review69').replace('\n'+new,'').replace('\n  editorialLatest.mount(host);','').replace('dispose(){editorialLatest.dispose();','dispose(){');assert reverse==old['mission-generic-ui.mjs']
 reverse=land.replace("import('./mission-generic-ui.mjs?v=editorial72-"+sha(main)[:16]+"')","import('./mission-generic-ui.mjs?v=editorial70-c29a5709ec6d271b')");assert reverse==old['land.html']
 assert len('mission-combat64-ui/5-editorial72-review71')==len('mission-combat64-ui/5-editorial70-review69')
 return {'mission-editorial-staff.mjs':module,'mission-generic-ui.mjs':main,'land.html':land}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--baseline',required=True);ap.add_argument('--ui-baseline',required=True);ap.add_argument('--output',required=True);ap.add_argument('--node',default='/Users/antonello/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node');a=ap.parse_args()
 b=json.loads(Path(a.baseline).read_text());assert b['version']==136 and len(b['files'])==16 and b['verify_jwt']is False
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
   diff=''.join(difflib.unified_diff(before[n].splitlines(True),body.splitlines(True),fromfile='Edge136/'+n,tofile='E72/'+n));(out/(n+'.diff')).write_text(diff);diffs.append(diff)
 pack={'name':'mission_generic_ai','entrypoint_path':'mission-generic-index.ts','verify_jwt':b['verify_jwt'],'files':[{'name':x['name'],'content':after[x['name']]}for x in b['files']]};pp=out/'C1266_EDITORIAL72_EDGE_PACKAGE.json';pp.write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n')
 uirows=[]
 for n,body in uinew.items():
  f=out/'sito_live'/n;f.parent.mkdir(exist_ok=True);f.write_text(body);uirows.append({'path':'sito_live/'+n,'baseline_sha256':sha(uiold[n]),'baseline_bytes':len(uiold[n].encode()),'candidate_sha256':sha(body),'candidate_bytes':len(body.encode()),'candidate_path':'sito_live/'+n})
  if n.endswith('.mjs'):syntax(f,'ui/'+n)
  (out/(n+'.diff')).write_text(''.join(difflib.unified_diff(uiold[n].splitlines(True),body.splitlines(True),fromfile='Published/'+n,tofile='E72/'+n)))
 for i,(attrs,body)in enumerate(re.findall(r'<script\b([^>]*)>(.*?)</script\s*>',uinew['land.html'],re.S|re.I)):
  if 'src='in attrs or re.search(r'type=[\'\"](?:application/(?:ld\+)?json|importmap)',attrs):continue
  module=bool(re.search(r'type=[\'\"]module',attrs));f=out/('land-script-'+str(i)+('.mjs'if module else'.js'));f.write_text(body if module else'(async function(){\n'+body+'\n})();');syntax(f,'ui/land script '+str(i))
 reverse=after['mission-generic-runtime.mjs'].replace("\nconst EDITORIAL_DIALOGUE_E71_CAMPAIGN='"+CAMPAIGN+"';",'').replace('![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN,EDITORIAL_DIALOGUE_E71_CAMPAIGN].includes(source.campaign_id)','![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN].includes(source.campaign_id)');assert reverse==before['mission-generic-runtime.mjs']
 reverse=after['mission-staff-editorial-pair.mjs'].replace("\nconst DIALOGUE_E71_CAMPAIGN='"+CAMPAIGN+"';",'').replace('(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN||id===DIALOGUE_E71_CAMPAIGN)?{work:','(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN)?{work:');assert reverse==before['mission-staff-editorial-pair.mjs']
 static={'status':'SOURCE_FROZEN_NOT_INSTALLED_NOT_REVIEWED','baseline_edge':136,'baseline_metadata_sha256':hashlib.sha256(Path(a.baseline).read_bytes()).hexdigest(),'campaign_id':CAMPAIGN,'files':manifest,'changed_edge_files':sum(x['changed']for x in manifest),'package_sha256':hashlib.sha256(pp.read_bytes()).hexdigest(),'builder_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'syntax':checks,'relative_imports':'RESOLVED_STATIC','preserved':'Whole Edge runtime/pair and all3UI assets identical after inverse identity-only delta; old UI controller is exact','prompts_E71':'BYTE_IDENTICAL','schemas_bounds_normalizers':'BYTE_IDENTICAL','provider_calls':0,'gameplay_tests':'NOT_RUN','rebuild':'DETERMINISTIC_PACKAGE_STATIC_UI_DIFF','start_authority':'Existing authenticated RPC campaign/Root authority remains required; only explicitE68/E70/E72IDs admitted','UI_version_length_unchanged':True}
 assert static['changed_edge_files']==2
 (out/'C1266_EDITORIAL72_EDGE_STATIC.json').write_text(json.dumps(static,ensure_ascii=False,indent=2)+'\n')
 (out/'C1266_EDITORIAL72_UI.json').write_text(json.dumps({'status':'CANDIDATE_NOT_APPLIED','campaign_id':CAMPAIGN,'old_campaign_ids':['a8c3c6f9-949d-5b64-8a02-80667c7b4da8',OLD_CAMPAIGN],'published_ref':'67e5c43253d425b2526f0565654aa6f88d417bef','files':uirows,'syntax':[x for x in checks if x['file'].startswith('ui/')],'controller_reused':True,'new_polling':False,'automatic_start':False,'journal_scope':'build + authenticated user + campaign + case','existing_E65_E66_E68_E70':'UNCHANGED','version':'mission-combat64-ui/5-editorial72-review71','LAND_build':'C1266-COMBAT64-UI7_UNCHANGED'},ensure_ascii=False,indent=2)+'\n')
 note='''# E72 — adattamento tecnico della preview E71

Delta dalla Edge136 e dai tre asset UI riconciliati su Git main67e5. Cambiano soltanto due allowlist d’identità nella Edge: il runtime e il consumer della coppia ammettono la nuova campagnaE72 oltre alle precedentiE68/E70. I prompt E71 Director dialogico/3, Writer response/10 e memoriaScene/2 restano byteidentici, così come schemi, bounds, normalizzatori, validator, quote, autorità e topologia. Nessun nuovo Director viene aggiunto alla narrazione ordinaria.

La UI aggiunge un’istanza del medesimo controller Staff per Verifica E71. Restano i pannelli e i journal precedenti; il nuovo journal ha namespace distinto per build/utente/campagna/caso. Nessun polling, autostart o generazione automatica. I tre asset cambiano solo per gli export d’identità, i link/pin, l’istanza, mount/dispose e la stringa di versione, della stessa lunghezza precedente. Il build generale LAND e tutte le classi e costanti estranee restano invariati.

Prove statiche:15MJS Edge,2MJS UI e gli script LAND eseguibili analizzati con node --check; import relativi risolti. Le sostituzioni inverse ripristinano l’intero runtime, il consumer della coppia e i tre asset UI byte per byte: la prova copre l’intera baseline, non solo tre prompt selezionati. Il rebuild riproduce pacchetto/static/UI/diff. Nessun gameplay, provider, deploy o SQL eseguito da questo contributo. La nuova campagna richiede comunque l’autorità server e l’installazione integrata qualificata; la presenza della UI non abilita la prova.

## Identità

'''
 note+='- Package SHA256: `'+static['package_sha256']+'`.\n- Builder SHA256: `'+static['builder_sha256']+'`.\n- Runtime candidato: `'+sha(after['mission-generic-runtime.mjs'])+'`.\n- Pair candidato: `'+sha(after['mission-staff-editorial-pair.mjs'])+'`.\n\n## Diff Edge esatto\n\n```diff\n'+''.join(diffs)+'```\n'
 (out/'C1266_EDITORIAL72_PROMPT_DIFF.md').write_text(note)
 print(json.dumps({'package_sha256':static['package_sha256'],'changed_edge_files':static['changed_edge_files'],'syntax':len(checks),'campaign_id':CAMPAIGN}))
if __name__=='__main__':main()
