#!/usr/bin/env python3
"""E67 reproducible source-only delta. No network, database, provider or gameplay."""
from pathlib import Path
import argparse,hashlib,json,subprocess,difflib
EXPECTED_RUNTIME='36bfed288c8f8334567e251cdf675a40f2537f6dc30b58a629cd48ce1fb49ee2'
RESPONSE="mission-editorial-response/8. Le role dei PG sono fatti e intenzioni da comprendere: il racconto prosegue con la risposta nuova dei PNG e del mondo, senza ripubblicarne parole o ricostruirne i gesti. Parti da ciò che cambia ora nell'interazione e rendi il seguito consentito con voce, modi e toni propri degli interlocutori. Ammissioni, accordi, responsabilità e custodia già stabiliti continuano a valere nello stato della scena; richiamali quando una domanda nuova o una conseguenza ne cambia la funzione. Il profilo orienta la scelta e il modo di compierla: una convinzione acquisita può emergere dal comportamento invece di essere nuovamente dichiarata. Il luogo mantiene attività, interessi e tempi propri. Scegli gli elementi già disponibili che entrano nel momento, danno spazio o ritmo allo scambio, o proseguono un'attività pertinente; intrecciali a ciò che accade anziché riaprire la descrizione del luogo. Lascia che la risposta, l'iniziativa ammessa o il punto reale d'intervento dei giocatori concludano il passaggio. Ampiezza e distribuzione di parlato e descrizione seguono la sostanza della scena, senza quote obbligatorie. Non inventare scelte PG, indizi identificativi, testimoni informati o conseguenze meccaniche; un limite di conoscenza guida ciò che il PNG può dire, senza diventare una dichiarazione rituale. I criteri interni restano fuori dal racconto."
READING="mission-editorial-input-reading/2. contesto_stabile descrive risorse, conoscenze e possibilità; acquisito conserva lo stato raggiunto e la cronaca già pubblicata; nuovi_input apre la risposta corrente. Le prove PG restano attribuite ai rispettivi autori e servono a comprendere richieste e consensi, non sono parlato da ripronunciare. Le nuove decisioni ricevute e i next_steps offerti delimitano il seguito ammesso. I riferimenti rimandano alle fonti integre presenti nell'input; una copia redazionale omessa per piena uguaglianza non rende assente il dato."
DIRECT="In questo percorso scegli direttamente risposte e iniziative narrative ammesse, senza una proposta Director intermedia."
MOVED=["Nella continuazione metti in atto il seguito significativo delle azioni e dei fatti pubblicati, senza riecheggiare la prosa PG o aggiungere loro decisioni.","Ammissioni, accordi e conoscenze acquisite possono restare impliciti e orientare il prossimo comportamento: non riaprirli come se mancasse ogni volta una conferma.","Conserva la continuità di oggetti, persone e attività; lo stato noto di un oggetto non diventa ignoranza per l'assenza di informazioni su un'altra parte della vicenda.","Usa la base concreta del luogo e ciò che vi è cambiato per dare spazio, ritmo e conseguenze locali all'interazione, senza un paragrafo ambientale fisso."]
def replace_once(s,old,new):
 assert s.count(old)==1,(s.count(old),old[:120]);return s.replace(old,new)
def line(s,prefix):return next(x for x in s.splitlines()if x.startswith(prefix))
def build(source):
 s=source
 marker='const EDITORIAL_INPUT_READING_RULE='
 old=line(s,marker);s=replace_once(s,old,old+'\nconst SCENE_WRITER_INPUT_RULE='+json.dumps(READING,ensure_ascii=False)+';\nconst SCENE_WRITER_RESPONSE_RULE='+json.dumps(RESPONSE,ensure_ascii=False)+';')
 old=line(s,'const NARRATIVE_SCENE_RULE=');text=json.loads(old.split('=',1)[1][:-1]);assert text.count(DIRECT)==1;text=text.replace(DIRECT+' ','')
 for sentence in MOVED:assert text.count(sentence)==1;text=text.replace(sentence+' ','')
 # Preserve knowledge/custody meaning once in the compact scene-only policy.
 s=replace_once(s,old,'const NARRATIVE_SCENE_RULE='+json.dumps(text,ensure_ascii=False)+';')
 old=" const system=[NARRATIVE_SCENE_RULE,...(peacefulRule?[peacefulRule]:[])";new=" const system=[NARRATIVE_SCENE_RULE,...(!p.combat_peaceful&&!p.combat_intent?['"+DIRECT+"']:[]),...(peacefulRule?[peacefulRule]:[])";s=replace_once(s,old,new)
 s=replace_once(s,"'Momento della scena: '+sceneMoment+'.',STAFF_SCENE_RESPONSE_RULE,EDITORIAL_INPUT_READING_RULE,memoryRule,","'Momento della scena: '+sceneMoment+'.',SCENE_WRITER_RESPONSE_RULE,SCENE_WRITER_INPUT_RULE,memoryRule,")
 old="export function projectSceneEditorialInput(p,phase){\n let peaceful=null;"
 new="""export function projectSceneEditorialInput(p,phase){
 // Provider-only duplicate removal after the source view has been validated.
 // Notes remain unchanged unless their entire setting equals the shared setting.
 let providerPhase=phase,notes=null;
 if(typeof phase.notes==='string'){try{notes=JSON.parse(phase.notes);}catch{ /* Keep the original notes. */ }}
 if(object(notes)&&Object.hasOwn(notes,'setting')&&retainedJsonEqual(notes.setting,p.snapshot.setting)){
  const {setting,...distinctNotes}=notes;
  providerPhase={...phase,notes:JSON.stringify(distinctNotes)};
 }
 let peaceful=null;"""
 s=replace_once(s,old,new)
 s=replace_once(s,'contesto_stabile:{mission:p.snapshot.mission,setting:p.snapshot.setting,current_phase:phase,','contesto_stabile:{mission:p.snapshot.mission,setting:p.snapshot.setting,current_phase:providerPhase,')
 return s

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--baseline',required=True);ap.add_argument('--output',required=True);ap.add_argument('--node',default='/Users/antonello/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node');args=ap.parse_args();basepath=Path(args.baseline);baseline=json.loads(basepath.read_text());assert baseline['version']==131 and len(baseline['files'])==16
 source=next(x['content']for x in baseline['files']if x['name']=='mission-generic-runtime.mjs');assert hashlib.sha256(source.encode()).hexdigest()==EXPECTED_RUNTIME
 after=build(source);out=Path(args.output);out.mkdir(parents=True,exist_ok=True);files=[];manifest=[];checks=[]
 for item in baseline['files']:
  name=item['name'];text=after if name=='mission-generic-runtime.mjs'else item['content'];target=out/'edge'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_text(text);files.append({'name':name,'content':text});manifest.append({'name':name,'changed':text!=item['content'],'baseline_sha256':hashlib.sha256(item['content'].encode()).hexdigest(),'candidate_sha256':hashlib.sha256(text.encode()).hexdigest(),'baseline_bytes':len(item['content'].encode()),'candidate_bytes':len(text.encode())})
  if name.endswith('.mjs'):
   r=subprocess.run([args.node,'--check',str(target)],capture_output=True,text=True);assert r.returncode==0,(name,r.stderr);checks.append({'file':name,'exit_code':r.returncode})
 preserved=[]
 for prefix in ['const STAFF_RESPONSE_RULE=','const STAFF_SCENE_RESPONSE_RULE=','const EDITORIAL_INPUT_READING_RULE=','const NATIVE_PEACEFUL_ASSESSMENT_SCHEMA=']:
  assert line(source,prefix)==line(after,prefix);preserved.append(prefix)
 for start,end in [('function nativePeacefulAssessmentRequest','function normalizedNativePeacefulAssessment'),('function checkedNarrativeSceneOutput','function validateAttestedNarrativeAdmission'),('function validateNarrativeSceneAdmission','// E65: provider-only projections.')]:
  assert source[source.index(start):source.index(end)]==after[after.index(start):after.index(end)];preserved.append(start)
 start='export async function createStaffPairedEditorialWriter';assert source[source.index(start):]==after[after.index(start):];preserved.append(start)
 schema_line=" const schema={type:'object',additionalProperties:false,required:['text','scene_memory','next_step'],properties:{text:{type:'string',minLength:1,maxLength:limits.transport_max_chars},scene_memory:memorySchema,next_step:{type:'string',enum:[...phase.next_steps]}}};"
 assert source.count(schema_line)==after.count(schema_line)==1;preserved.append('Scene5 output schema exact line')
 package={'name':'mission_generic_ai','entrypoint_path':'mission-generic-index.ts','verify_jwt':baseline['verify_jwt'],'files':files};(out/'C1266_EDITORIAL67_EDGE_PACKAGE.json').write_text(json.dumps(package,ensure_ascii=False,indent=2)+'\n')
 (out/'RUNTIME.diff').write_text(''.join(difflib.unified_diff(source.splitlines(True),after.splitlines(True),fromfile='Edge131/mission-generic-runtime.mjs',tofile='E67/mission-generic-runtime.mjs')))
 static={'status':'SOURCE_PREPARED_NOT_INSTALLED_NOT_REVIEWED','baseline_edge':131,'baseline_metadata_sha256':hashlib.sha256(basepath.read_bytes()).hexdigest(),'files':manifest,'changed_files':sum(x['changed']for x in manifest),'syntax':checks,'preserved_byte_identical':preserved,'provider_calls':0,'gameplay_tests':'NOT_RUN','authority_or_output_schema_changes':False,'new_style_validators':0}
 (out/'C1266_EDITORIAL67_EDGE_STATIC.json').write_text(json.dumps(static,indent=2)+'\n');print(json.dumps({'files':len(files),'changed_files':static['changed_files'],'syntax':len(checks),'runtime_sha256':hashlib.sha256(after.encode()).hexdigest()}))
if __name__=='__main__':main()
