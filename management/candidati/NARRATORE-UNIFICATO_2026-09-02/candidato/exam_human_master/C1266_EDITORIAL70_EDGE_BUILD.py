#!/usr/bin/env python3
"""E70 identity-only adaptation of Edge134 and reconciled Staff UI. Static only."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,difflib,posixpath
CAMPAIGN='2bd901b7-6ba6-5319-a55a-2d2e2cfcf03b'
OLD_CAMPAIGN='a8c3c6f9-949d-5b64-8a02-80667c7b4da8'
EXPECTED={'mission-generic-runtime.mjs':'04bedf79e8d0c8518f833d87f83627b6a20c96fb08f7ce8d9b3fab1eceaf0700','mission-staff-editorial-pair.mjs':'abb530e8bfc05a364748f5b7796496b5a9de3aad74589dc63d953a7ab42506d1'}
UI_EXPECTED={'mission-editorial-staff.mjs':'003770c9b5d6fcf387bc97c9f3a90650430092f0026010dbd8e4d2bafe8f2e22','mission-generic-ui.mjs':'74000407048f109bbd36528233f807322303ae7b7bf54836cd100c17e1a00c61','land.html':'963016bf899fbe69c69805396694c8e35afbc77599c7f25633fc9f620d9b66ad'}
def sha(v):return hashlib.sha256(v.encode()).hexdigest()
def once(s,a,b):
 assert s.count(a)==1,(s.count(a),a[:100]);return s.replace(a,b)
def edge_sources(old):
 runtime=old['mission-generic-runtime.mjs'];marker="const EDITORIAL_DIALOGUE_CAMPAIGN='"+OLD_CAMPAIGN+"';"
 runtime=once(runtime,marker,marker+"\nconst EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN='"+CAMPAIGN+"';")
 runtime=once(runtime,'source.campaign_id!==EDITORIAL_DIALOGUE_CAMPAIGN','![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN].includes(source.campaign_id)')
 pair=old['mission-staff-editorial-pair.mjs'];marker="const DIALOGUE_CAMPAIGN='"+OLD_CAMPAIGN+"';"
 pair=once(pair,marker,marker+"\nconst DIALOGUE_REVIEW_CAMPAIGN='"+CAMPAIGN+"';")
 pair=once(pair,'id===DIALOGUE_CAMPAIGN?{work:', '(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN)?{work:')
 return {**old,'mission-generic-runtime.mjs':runtime,'mission-staff-editorial-pair.mjs':pair}
def ui_sources(old):
 module=old['mission-editorial-staff.mjs'];marker="export const DIALOGUE_CAMPAIGN='"+OLD_CAMPAIGN+"';"
 module=once(module,marker,marker+"\nexport const REVIEW_BUILD='staff-editorial-review69-ui/1';\nexport const REVIEW_CAMPAIGN='"+CAMPAIGN+"';")
 main=old['mission-generic-ui.mjs'];modulepin=sha(module)[:16]
 main=once(main,"import {createStaffEditorial,createStaffEditorialPair,DIALOGUE_CAMPAIGN,DIALOGUE_BUILD} from './mission-editorial-staff.mjs?v=editorial68-003770c9b5d6fcf3';","import {createStaffEditorial,createStaffEditorialPair,DIALOGUE_CAMPAIGN,DIALOGUE_BUILD,REVIEW_CAMPAIGN,REVIEW_BUILD} from './mission-editorial-staff.mjs?v=editorial70-"+modulepin+"';")
 main=once(main,"export const VERSION='mission-combat64-ui/5-editorial68-dialogue';","export const VERSION='mission-combat64-ui/5-editorial70-review69';")
 line=next(x for x in main.splitlines()if x.startswith(' const editorialDialogue=createStaffEditorialPair('))
 new=" const editorialReview=createStaffEditorialPair({client,identity,isStaff,currentLocation,staffRoom:STAFF_TEST_ROOM,campaign:REVIEW_CAMPAIGN,build:REVIEW_BUILD,title:'Verifica E69 · Staff',description:'Tre nuove prove private sulle stesse situazioni e domande del confronto precedente, con le istruzioni aggiornate. Gli esiti della missione restano invariati.',caseLabels:['Fatti e aggiunte personali','Motivazioni e dissenso','Rettifica nel mercato']});"
 main=once(main,line,line+'\n'+new)
 main=once(main,'  editorialDialogue.mount(host);','  editorialDialogue.mount(host);\n  editorialReview.mount(host);')
 main=once(main,'dispose(){editorialDialogue.dispose();','dispose(){editorialReview.dispose();editorialDialogue.dispose();')
 land=once(old['land.html'],"import('./mission-generic-ui.mjs?v=editorial68-74000407048f109b')","import('./mission-generic-ui.mjs?v=editorial70-"+sha(main)[:16]+"')")
 return {'mission-editorial-staff.mjs':module,'mission-generic-ui.mjs':main,'land.html':land}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--baseline',required=True);ap.add_argument('--ui-baseline',required=True);ap.add_argument('--output',required=True);ap.add_argument('--node',default='/Users/antonello/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node');a=ap.parse_args()
 b=json.loads(Path(a.baseline).read_text());assert b['version']==134 and len(b['files'])==16
 before={x['name']:x['content']for x in b['files']}
 for n,h in EXPECTED.items():assert sha(before[n])==h,(n,'Edge baseline drift')
 after=edge_sources(before);ub=Path(a.ui_baseline);uiold={n:(ub/n).read_text()for n in UI_EXPECTED}
 for n,h in UI_EXPECTED.items():assert sha(uiold[n])==h,(n,'published UI drift')
 uinew=ui_sources(uiold);out=Path(a.output);out.mkdir(parents=True,exist_ok=True);checks=[];manifest=[]
 def syntax(f,label):
  r=subprocess.run([a.node,'--check',str(f)],capture_output=True,text=True);assert r.returncode==0,(label,r.stderr);checks.append({'file':label,'exit_code':0})
 for item in b['files']:
  n=item['name'];body=after[n];f=out/'edge'/n;f.parent.mkdir(parents=True,exist_ok=True);f.write_text(body)
  manifest.append({'name':n,'baseline_sha256':sha(before[n]),'candidate_sha256':sha(body),'bytes':len(body.encode()),'changed':body!=before[n]})
  if n.endswith('.mjs'):syntax(f,'edge/'+n)
  for imp in re.findall(r"(?:from\s*|import\s*)['\"](\.[^'\"]+)['\"]",body):assert posixpath.normpath(str(Path(n).parent/imp))in after,(n,imp)
  if body!=before[n]:(out/(n+'.diff')).write_text(''.join(difflib.unified_diff(before[n].splitlines(True),body.splitlines(True),fromfile='Edge134/'+n,tofile='E70/'+n)))
 pack={'name':'mission_generic_ai','entrypoint_path':'mission-generic-index.ts','verify_jwt':b['verify_jwt'],'files':[{'name':x['name'],'content':after[x['name']]}for x in b['files']]};pp=out/'C1266_EDITORIAL70_EDGE_PACKAGE.json';pp.write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n')
 uirows=[]
 for n,body in uinew.items():
  f=out/'sito_live'/n;f.parent.mkdir(exist_ok=True);f.write_text(body);uirows.append({'path':'sito_live/'+n,'baseline_sha256':sha(uiold[n]),'baseline_bytes':len(uiold[n].encode()),'candidate_sha256':sha(body),'candidate_bytes':len(body.encode()),'candidate_path':str(f)})
  if n.endswith('.mjs'):syntax(f,'ui/'+n)
  (out/(n+'.diff')).write_text(''.join(difflib.unified_diff(uiold[n].splitlines(True),body.splitlines(True),fromfile='Published/'+n,tofile='E70/'+n)))
 for i,(attrs,body)in enumerate(re.findall(r'<script\b([^>]*)>(.*?)</script\s*>',uinew['land.html'],re.S|re.I)):
  if 'src='in attrs or re.search(r'type=[\'\"](?:application/(?:ld\+)?json|importmap)',attrs):continue
  module=bool(re.search(r'type=[\'\"]module',attrs));f=out/('land-script-'+str(i)+('.mjs'if module else'.js'));f.write_text(body if module else'(async function(){\n'+body+'\n})();');syntax(f,'ui/land script '+str(i))
 # Inverse substitutions prove whole E69 runtime and unchanged pair logic, not just selected prompts.
 reverse=after['mission-generic-runtime.mjs'].replace("\nconst EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN='"+CAMPAIGN+"';",'').replace('![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN].includes(source.campaign_id)','source.campaign_id!==EDITORIAL_DIALOGUE_CAMPAIGN');assert reverse==before['mission-generic-runtime.mjs']
 reverse=after['mission-staff-editorial-pair.mjs'].replace("\nconst DIALOGUE_REVIEW_CAMPAIGN='"+CAMPAIGN+"';",'').replace('(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN)?{work:','id===DIALOGUE_CAMPAIGN?{work:');assert reverse==before['mission-staff-editorial-pair.mjs']
 # Entire existing UI controller unchanged, including auth, idempotency, receipt and no-poll behavior.
 reverse=uinew['mission-editorial-staff.mjs'].replace("\nexport const REVIEW_BUILD='staff-editorial-review69-ui/1';\nexport const REVIEW_CAMPAIGN='"+CAMPAIGN+"';",'');assert reverse==uiold['mission-editorial-staff.mjs']
 static={'status':'SOURCE_FROZEN_NOT_INSTALLED_NOT_REVIEWED','baseline_edge':134,'baseline_metadata_sha256':hashlib.sha256(Path(a.baseline).read_bytes()).hexdigest(),'campaign_id':CAMPAIGN,'files':manifest,'changed_edge_files':sum(x['changed']for x in manifest),'package_sha256':hashlib.sha256(pp.read_bytes()).hexdigest(),'builder_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'syntax':checks,'relative_imports':'RESOLVED_STATIC','preserved':'Whole Edge runtime and pair consumer identical after removing only explicit campaign identity delta; whole old UI controller identical after removing two new constants','prompts_E69':'BYTE_IDENTICAL','schemas_bounds_normalizers':'BYTE_IDENTICAL','provider_calls':0,'gameplay_tests':'NOT_RUN','rebuild':'DETERMINISTIC_PACKAGE_AND_STATIC','start_authority':'Existing authenticated RPC campaign/Root authority remains required; no arbitrary campaign UUID admitted'}
 (out/'C1266_EDITORIAL70_EDGE_STATIC.json').write_text(json.dumps(static,ensure_ascii=False,indent=2)+'\n')
 # Deliberately avoid absolute output paths in canonical manifest so rebuild remains portable.
 for row in uirows:row['candidate_path']='sito_live/'+Path(row['candidate_path']).name
 (out/'C1266_EDITORIAL70_UI.json').write_text(json.dumps({'status':'CANDIDATE_NOT_APPLIED','campaign_id':CAMPAIGN,'old_campaign_id':OLD_CAMPAIGN,'published_ref':'4fa92315caac3fe5bfc2078d8e203687ad703be2','files':uirows,'syntax':[x for x in checks if x['file'].startswith('ui/')],'controller_reused':True,'new_polling':False,'automatic_start':False,'journal_scope':'build + authenticated user + campaign + case','existing_E65_E66_E68':'UNCHANGED'},ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'package_sha256':static['package_sha256'],'changed_edge_files':static['changed_edge_files'],'syntax':len(checks),'campaign_id':CAMPAIGN}))
if __name__=='__main__':main()
