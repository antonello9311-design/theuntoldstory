#!/usr/bin/env python3
"""C1266 aggregate31: one shared Mission IA rule constant; static checks only."""
import argparse,hashlib,json,re,posixpath,subprocess,difflib
from pathlib import Path
def sha(value):return hashlib.sha256(value).hexdigest()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--baseline',required=True);ap.add_argument('--output',required=True);args=ap.parse_args()
 raw=Path(args.baseline).read_bytes();base=json.loads(raw)
 assert base['version']==146 and base['ezbr_sha256']=='b620d625d255db35698d61379e1ff6b371702ad1b766a602e419d0e19d3f6760'and len(base['files'])==16
 old={file['name']:file['content']for file in base['files']};new=dict(old);name='mission-generic-runtime.mjs'
 prefix='const MISSION_NARRATIVE_SPACE_RULE='
 before=next(line for line in old[name].splitlines()if line.startswith(prefix));oldrule=json.loads(before[len(prefix):-1]);assert oldrule.startswith('mission-narrative-space/1. ')
 reply='Durante il Combat sviluppa anche il confronto verbale: alle domande, provocazioni o richiami rivolti ai PNG dai giocatori fai seguire risposte proprie, coerenti con personalità, rapporti, motivazioni e momento, attraverso parole, tono e gesti osservabili che proseguano lo scambio senza riecheggiare la formulazione dei PG; rispetta eventuali impedimenti attestati e mantieni questa risposta espressiva distinta da nuovi attacchi, azioni meccaniche o turni.'
 attack='Quando un PNG compie un attacco o un contrattacco già autorizzato dal server, intreccia alla sua iniziativa l’interazione con il bersaglio attraverso parole, tono e gesti coerenti con la sua intenzione, la personalità e il momento, lasciando al giocatore le risposte del proprio personaggio.'
 anchor='Queste scelte espressive non richiedono una ricevuta dedicata per ogni dettaglio.';assert oldrule.count(anchor)==1
 rule=oldrule.replace('mission-narrative-space/1. ','mission-narrative-space/2. ',1).replace(anchor,anchor+' '+reply+' '+attack)
 inverse_rule=rule.replace(anchor+' '+reply+' '+attack,anchor).replace('mission-narrative-space/2. ','mission-narrative-space/1. ',1);assert inverse_rule==oldrule
 after=prefix+json.dumps(rule,ensure_ascii=False)+';';assert old[name].count(before)==1;new[name]=old[name].replace(before,after);assert new[name].replace(after,before)==old[name]
 out=Path(args.output);out.mkdir(parents=True,exist_ok=True)
 node='/Users/antonello/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node';files=[];syntax=[];exports={}
 def exported(text):return sorted(re.findall(r'(?m)^export\s+(?:(?:async\s+)?function|const|let|var|class)\s+([A-Za-z_$][A-Za-z0-9_$]*)',text))
 for path,text in new.items():
  candidate=out/'edge'/path;candidate.parent.mkdir(parents=True,exist_ok=True);candidate.write_text(text)
  if path.endswith('.mjs'):
   result=subprocess.run([node,'--check',str(candidate)],capture_output=True,text=True);assert result.returncode==0,(path,result.stderr);syntax.append(path)
  for imp in re.findall(r"(?:from\s*|import\s*)['\"](\.[^'\"]+)['\"]",text):assert posixpath.normpath(str(Path(path).parent/imp))in new
  assert exported(text)==exported(old[path]);exports[path]=exported(text)
  files.append({'name':path,'baseline_sha256':sha(old[path].encode()),'candidate_sha256':sha(text.encode()),'bytes':len(text.encode()),'changed':text!=old[path],'inverse':'EXACT_EDGE146'})
 assert sum(row['changed']for row in files)==1
 (out/'diff').mkdir(exist_ok=True);(out/'diff'/'mission-generic-runtime.mjs.diff').write_text(''.join(difflib.unified_diff(old[name].splitlines(True),new[name].splitlines(True),fromfile='Edge146/'+name,tofile='Narratore81/'+name)))
 # The complete runtime except this one constant is byte-identical. Extra proof
 # labels identify the frozen contracts without executing a projector or gameplay.
 frozen=[]
 for start in ['const NARRATOR_MEMORY_TOTAL_VERSION=','const NARRATOR_MEMORY_TOTAL_CAP=','const NARRATOR_MEMORY_TOTAL_RULE=','const SCENE_MEMORY_RULE=',' const sys=\'staff-combat-report-narrator/4.']:
  line=next(line for line in old[name].splitlines()if line.startswith(start));assert line in new[name];frozen.append({'source':start,'sha256':sha(line.encode()),'status':'BYTE_IDENTICAL'})
 i=old[name].index('function narratorStructuredValue(');projection=old[name][i:];assert projection in new[name];frozen.append({'source':'projection + memory schema/validator + report payload/output/normalize to EOF','sha256':sha(projection.encode()),'status':'BYTE_IDENTICAL'})
 pack={'name':'mission_generic_ai','entrypoint_path':'mission-generic-index.ts','verify_jwt':base['verify_jwt'],'files':[{'name':file['name'],'content':new[file['name']]}for file in base['files']]};assert pack['verify_jwt']is False
 package=out/'EDGE_PACKAGE.json';package.write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n')
 consumers=['SCENE_WRITER_RESPONSE_RULE alias: narrative Scene5','STAFF_SCENE_RESPONSE_RULE alias: Native Combat report path','STAFF_RESPONSE_RULE alias: unified/free Staff writer','staffMissionEditorialDirection: ordinary mission scenes','missionCombatDirection: withDirector Combat mission adapter','combatReportNarratorRequest: private report/4 preview']
 contract={'schema':'mission-narrative-space/2','aggregate':31,'baseline_edge':146,'change':'One existing shared Mission IA constant; version1 becomes2 and exactly two generic sentences are inserted.','new_sentences':[reply,attack],
  'player_authority':'Addressed PG speech comes from an accepted player role; the Writer never adds PG words or decisions. When the assistant plays a PG in a future authorized test, the normal role includes relevant speech directed at the target.',
  'npc_authority':'NPC responds through its own words, tone and observable conduct from personality, relationships, motives and current moment; a server-authorized NPC attack or counterattack includes interaction with its target, without invented PG replies.',
  'limits':'Respect attested impediments. No new attack, mechanical action or turn is introduced merely to speak; no fixed quota or scripted reply.','consumers':consumers,
  'unchanged':['transport report/4','source/campaign routing and historical policies','projection','memory7080','schemas','normalizers','exports','provider/accounting','Director','WAIT','turns and server mechanics','shared Combat/Exam modules','UI'],
  'provider_calls':0,'new_campaigns':0,'new_tests':0,'UI_changes':0,'runtime_quality':'NOT_RUN'}
 (out/'INPUT_CONTRACT.json').write_text(json.dumps(contract,ensure_ascii=False,indent=2)+'\n')
 (out/'PROMPT_DIFF.md').write_text('# Narratore81 · interazione verbale nel Combat\n\nUnica costante `MISSION_NARRATIVE_SPACE_RULE`: identità `/1` → `/2`; due frasi generiche aggiunte. Il resto della regola resta identico.\n\n## Aggiunte\n\n'+reply+'\n\n'+attack+'\n\n## Conservazione\n\nLe parole PG provengono dalle role accettate, mai dal Writer. La descrizione dei tentativi e degli esiti segue sempre lo stato server: parlare non apre un attacco, un turno o una risposta PG. Nessun numero di battute o parole, dettaglio di missione, controllo editoriale, taglio o retry. Nessuna nuova prova o campagna.\n')
 (out/'WRITER_RULES.md').write_text('# mission-narrative-space/2\n\n'+rule+'\n\n## Consumer\n\n'+'\n'.join('- '+consumer for consumer in consumers)+'\n\nNessuna nuova generazione: efficacia editoriale NOT_RUN. La modifica non inserisce retroattivamente dialoghi nei Fati né nelle role esistenti. La fonte delle future parole PG resta il rispettivo autore.\n')
 static={'aggregate':31,'baseline_edge':146,'baseline_ezbr':base['ezbr_sha256'],'baseline_metadata_sha256':sha(raw),'package_sha256':sha(package.read_bytes()),'builder_sha256':sha(Path(__file__).read_bytes()),'files':files,'changed_files':1,'unchanged_files':15,'syntax':syntax,'relative_imports':'RESOLVED_STATIC','whole_inverse':'EXACT_EDGE146','single_constant_delta':True,'old_rule_sha256':sha(oldrule.encode()),'new_rule_sha256':sha(rule.encode()),'sentences_added':2,'frozen_proofs':frozen,'export_sets':exports,'export_api':'EXACT_EDGE146','consumer_map':consumers,'schema_projection_normalizer_memory_flow':'BYTE_IDENTICAL','provider_calls':0,'new_campaigns':0,'new_tests':0,'UI_changes':0,'runtime_quality':'NOT_RUN'}
 (out/'STATIC.json').write_text(json.dumps(static,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({key:static[key]for key in ['aggregate','package_sha256','builder_sha256','changed_files','unchanged_files','sentences_added','provider_calls']}))
if __name__=='__main__':main()
