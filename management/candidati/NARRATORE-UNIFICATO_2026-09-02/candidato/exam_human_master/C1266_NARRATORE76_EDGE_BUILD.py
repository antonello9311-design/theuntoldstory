#!/usr/bin/env python3
"""C1266 aggregate26: one private revised narrator preview; static checks only."""
import argparse,hashlib,json,re,posixpath,subprocess,difflib
from pathlib import Path
def sha(b):return hashlib.sha256(b).hexdigest()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--baseline',required=True);ap.add_argument('--site',required=True);ap.add_argument('--output',required=True);a=ap.parse_args()
 baseline=Path(a.baseline).read_bytes();b=json.loads(baseline);assert b['version']==141 and len(b['files'])==16
 old={f['name']:f['content']for f in b['files']};new=dict(old);edits={}
 oldid='07640a7d-73fe-5f9b-b78b-f65199596a2f';newid='bb24b63b-c121-54a3-a43f-6a49135c780f'
 source_use='Usa missione, fase, mappa e mondo per sviluppare il contesto e ciò che può accadervi coerentemente. Le schede orientano carattere, conoscenze e possibilità, senza trasformarne i gesti in una sequenza da ripetere. Dai agli esiti una resa osservabile attraverso reazioni, condotta, voce e parole coerenti dei PNG; l’ambiente partecipa a ciò che accade. Distingui le scelte effettive dall’attesa del turno, senza aggiungere danni o nuove azioni meccaniche.'
 def once(n,before,after):
  assert new[n].count(before)==1,(n,before[:100],new[n].count(before));new[n]=new[n].replace(before,after);edits.setdefault(n,[]).append((before,after))
 runtime='mission-generic-runtime.mjs';handler='mission-staff-editorial.mjs'
 once(runtime,"export const COMBAT_REPORT_CAMPAIGN='"+oldid+"';","export const COMBAT_REPORT_CAMPAIGN='"+newid+"';")
 sysmatch=re.search(r" const sys='staff-combat-report-narrator/1\.[^\n]+",old[runtime]);assert sysmatch
 oldsys=sysmatch.group(0);newsys=oldsys.replace('staff-combat-report-narrator/1.','staff-combat-report-narrator/2.').replace('Restituisci soltanto il testo della scena nel campo text.',source_use+' Restituisci soltanto il testo della scena nel campo text.')
 once(runtime,oldsys,newsys)
 once(handler," const campaign=COMBAT_REPORT_CAMPAIGN,schema='staff-combat-report-request/1';"," const campaign=COMBAT_REPORT_CAMPAIGN,schema='staff-combat-report-request/1';\n const readableCampaigns=new Set(['"+oldid+"',campaign]);")
 once(handler,"if(r?.stage!=='narration'||!sha(r.source_sha256)||r?.campaign_id!==campaign||r.case_no!==1", "if(r?.stage!=='narration'||!sha(r.source_sha256)||!readableCampaigns.has(r?.campaign_id)||r.case_no!==1")
 once(handler,"return {schema_version:'staff-combat-report-public/1',run_id:r.run_id,campaign_id:campaign,case_no:1", "return {schema_version:'staff-combat-report-public/1',run_id:r.run_id,campaign_id:r.campaign_id,case_no:1")
 once(handler,"value.prompt_revision!=='staff-combat-report-narrator/1'", "value.prompt_revision!=='staff-combat-report-narrator/2'")
 # Source/corpus binding, actor projection, worker accounting, validator and old recovery stay exact.
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
  files.append({'name':n,'baseline_sha256':sha(old[n].encode()),'candidate_sha256':sha(s.encode()),'bytes':len(s.encode()),'changed':s!=old[n],'inverse':'EXACT_EDGE141'})
  if s!=old[n]:
   d=out/'diff'/Path(n+'.diff');d.parent.mkdir(parents=True,exist_ok=True);d.write_text(''.join(difflib.unified_diff(old[n].splitlines(True),s.splitlines(True),fromfile='Edge141/'+n,tofile='Narratore76/'+n)))
 pack={'name':'mission_generic_ai','entrypoint_path':'mission-generic-index.ts','verify_jwt':b['verify_jwt'],'files':[{'name':f['name'],'content':new[f['name']]}for f in b['files']]}
 assert pack['verify_jwt'] is False
 package=out/'EDGE_PACKAGE.json';package.write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n')
 # UI retains the complete previous controller and adds one private case with a separate journal.
 site=Path(a.site);uiold=(site/'mission-generic-ui.mjs').read_text();ui=uiold
 expected_ui='9d6c4bd8e726116c2d9819e2f22476e8a60149e175fc8d3d55978943806bd6b4';assert sha(ui.encode())==expected_ui
 ctl=next(line for line in ui.splitlines(True)if line.startswith(' const combatReportPreview='))
 newctl=ctl.replace('combatReportPreview=','combatReportRevision=') .replace(oldid,newid).replace("build:'staff-combat-report-ui/1'","build:'staff-combat-report-ui/2'").replace("title:'Narratore · esito Combat'","title:'Narratore · reazioni e ambiente'").replace("caseLabels:['Esito dello scambio completo']","caseLabels:['Reazioni, condotta e ambiente']")
 assert newctl!=ctl
 uiedits=[(ctl,ctl+newctl),("  combatReportPreview.mount(host);","  combatReportPreview.mount(host);\n  combatReportRevision.mount(host);"),("dispose(){combatReportPreview.dispose();","dispose(){combatReportRevision.dispose();combatReportPreview.dispose();"),("export const VERSION='mission-combat64-ui/5-narratore75-report01';","export const VERSION='mission-combat64-ui/5-narratore76-report02';")]
 for before,after in uiedits:assert ui.count(before)==1;ui=ui.replace(before,after)
 inv=ui
 for before,after in reversed(uiedits):assert inv.count(after)==1;inv=inv.replace(after,before)
 assert inv==uiold
 uidir=out/'ui';uidir.mkdir(exist_ok=True);(uidir/'mission-generic-ui.mjs').write_text(ui)
 q=subprocess.run([node,'--check',str(uidir/'mission-generic-ui.mjs')],capture_output=True,text=True);assert q.returncode==0,q.stderr
 landold=(site/'land.html').read_text();assert sha(landold.encode())=='d2b66813cb8da31dcd4fdfc6585498ea64f9b8349cdbd951b6259137f1a2aee5'
 oldpin="./mission-generic-ui.mjs?v=narratore75-9d6c4bd8e726116c";newpin='./mission-generic-ui.mjs?v=narratore76-'+sha(ui.encode())[:16]
 assert landold.count(oldpin)==1;land=landold.replace(oldpin,newpin);assert land.replace(newpin,oldpin)==landold;(uidir/'land.html').write_text(land)
 # Import pin is the only HTML delta; inline scripts are exact and CSS/markup untouched.
 for name,bs,cs in [('mission-generic-ui.mjs',uiold,ui),('land.html',landold,land)]:
  (out/'diff'/(name+'.diff')).write_text(''.join(difflib.unified_diff(bs.splitlines(True),cs.splitlines(True),fromfile='UI6301/'+name,tofile='Narratore76/'+name)))
 helper=(site/'mission-editorial-staff.mjs').read_bytes();assert sha(helper)=='34fa4e6596cf18d3eb56130e487c8a0f6e0af7f152e06aebbeeca1859567255f'
 remote={'head':'b8207fca1c7b118cb23351a9261993cf96b3e098','tree':'e1a8e8848729e507886cef889367fdcdf83c538f','evidence':'Fresh GitHub ref/tree via connector; local Git blob SHA1 matched tree. This is content-addressed reconciliation, not full remote readback.'}
 uirows=[]
 for n,s in [('land.html',land),('mission-generic-ui.mjs',ui)]:
  bs=(site/n).read_bytes();gitblob=hashlib.sha1(b'blob '+str(len(bs)).encode()+b'\0'+bs).hexdigest();expected={'land.html':'c1a2ac5749f31493242fcb7eba72f4c81fcd6193','mission-generic-ui.mjs':'d9365ed64ace814caff14e0117e2407656424b84'}[n];assert gitblob==expected
  uirows.append({'path':'sito_live/'+n,'baseline_bytes':len(bs),'baseline_sha256':sha(bs),'baseline_git_blob':gitblob,'candidate_bytes':len(s.encode()),'candidate_sha256':sha(s.encode()),'candidate_path':str(uidir/n),'inverse':'EXACT_UI6301'})
 uimanifest={'schema':'narratore76-ui/1','campaign_id':newid,'old_campaign_id':oldid,'module_version':'mission-combat64-ui/5-narratore76-report02','module_pin':'narratore76-'+sha(ui.encode())[:16],'files':uirows,'unchanged_helper_sha256':sha(helper),'remote':remote,'old_pane_preserved':True,'separate_new_journal':True,'no_polling_autostart':True,'html_delta':'one import cache pin only','global_build':'UNCHANGED','syntax':'PASS_MODULE','runtime':'NOT_RUN'}
 (out/'UI.json').write_text(json.dumps(uimanifest,ensure_ascii=False,indent=2)+'\n')
 (out/'PROMPT_DIFF.md').write_text('# Narratore76 · revisione generica\n\nSolo prompt report→Fato; nessun Director, schema editoriale o nuovo controllo bloccante. Fonti sigillate e precedenti risultati invariati.\n\n## Criteri aggiunti\n\n'+source_use+'\n\n## Identità\n\n`staff-combat-report-narrator/1` → `staff-combat-report-narrator/2`.\n\nFonte immutabile: stesso report e stesso snapshot storico, senza reimpostare la missione. Le metriche consultive non sostituiscono la review editoriale.\n')
 static={'aggregate':26,'baseline_edge':141,'baseline_ezbr':b['ezbr_sha256'],'baseline_metadata_sha256':sha(baseline),'package_sha256':sha(package.read_bytes()),'builder_sha256':sha(Path(__file__).read_bytes()),'files':files,'changed_files':sum(f['changed']for f in files),'unchanged_files':sum(not f['changed']for f in files),'syntax':syntax,'relative_imports':'RESOLVED_STATIC','whole_inverse':'EXACT_EDGE141','campaign_id':newid,'old_read_campaign_id':oldid,'source_payload_and_binding':'UNCHANGED','schema_validators_ledger_worker_projection':'UNCHANGED','prompt_revision':'staff-combat-report-narrator/2','provider_calls':0,'runtime_quality':'NOT_RUN','UI':uimanifest}
 (out/'STATIC.json').write_text(json.dumps(static,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({k:static[k]for k in ['aggregate','package_sha256','builder_sha256','changed_files','unchanged_files','provider_calls']}))
if __name__=='__main__':main()
