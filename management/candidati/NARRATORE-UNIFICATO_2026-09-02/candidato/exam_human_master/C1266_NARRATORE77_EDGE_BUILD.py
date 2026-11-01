#!/usr/bin/env python3
"""C1266 aggregate27: structured source roles and private memory; static checks only."""
import argparse,hashlib,json,re,posixpath,subprocess,difflib
from pathlib import Path
def sha(b):return hashlib.sha256(b).hexdigest()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--baseline',required=True);ap.add_argument('--site',required=True);ap.add_argument('--output',required=True);a=ap.parse_args()
 baseline=Path(a.baseline).read_bytes();b=json.loads(baseline);assert b['version']==142 and len(b['files'])==16
 old={f['name']:f['content']for f in b['files']};new=dict(old);edits={}
 previous='bb24b63b-c121-54a3-a43f-6a49135c780f';historical='07640a7d-73fe-5f9b-b78b-f65199596a2f';campaign='e0b73266-f03f-5e6d-a54f-d025f5673615'
 def once(n,before,after):
  assert new[n].count(before)==1,(n,before[:100],new[n].count(before));new[n]=new[n].replace(before,after);edits.setdefault(n,[]).append((before,after))
 runtime='mission-generic-runtime.mjs';handler='mission-staff-editorial.mjs'
 once(runtime,"export const COMBAT_REPORT_CAMPAIGN='"+previous+"';","export const COMBAT_REPORT_CAMPAIGN='"+campaign+"';")
 helper="// Provider-only projection after the immutable report, scene and history checks.\n// It labels source roles without changing the sealed source or evaluating transitions.\nfunction narratorStructuredValue(value){\n if(typeof value!=='string')return value;\n try{return JSON.parse(value);}catch{return value;}\n}\nfunction projectCombatReportNarratorInput(p,b,data,actors,context,memory,delta){\n const publishedByHash=new Map(delta.map(event=>[event.sha256,event]));\n const historyAliases=[],settings=[],declarations=[],otherSources=[];\n for(const source of p.scene.snapshot.sources){\n  const identity={source_id:source.id,sha256:source.sha256,kind:source.kind,actor_id:source.actor_id,\n   round_id:source.round_id,session_id:source.session_id,sequence:source.sequence};\n  const published=publishedByHash.get(source.sha256);\n  if(source.kind==='setting'&&published){historyAliases.push({...identity,published_message_id:published.id,published_sequence:published.sequence});continue;}\n  if(source.kind==='role'){declarations.push({...identity,text:source.body});continue;}\n  if(source.kind==='setting'){\n   settings.push(source.body===context?.setting?.description?{...identity,content_reference:'stable_context.mission_setting.description'}:{...identity,text:source.body});\n   continue;\n  }\n  otherSources.push({...identity,text:source.body});\n }\n const characters=actors.map(actor=>{\n  const persona=narratorStructuredValue(actor.persona);\n  if(!object(persona))return {identity:{id:actor.id,kind:actor.kind,name:actor.name,may_speak:actor.may_speak},profile:persona};\n  const {voice,gestures,conduct,fallback,...profile}=persona;\n  const phaseActor=context?.actors?.find(row=>row.actor_key===persona.mission_actor_key)??null;\n  return {identity:{id:actor.id,kind:actor.kind,name:actor.name,may_speak:actor.may_speak,mission_actor_key:persona.mission_actor_key??null},\n   profile,voice:voice??null,gesture_repertoire:gestures??null,\n   possible_conduct:{conduct:conduct??null,fallback:fallback??null,phase_goal:phaseActor?.goal_private??null,portrayal:phaseActor?.public_portrayal??null},\n   phase_role:phaseActor?.role_in_phase??null,\n   private_background_and_initial_knowledge:phaseActor?.known_facts_private??null};\n });\n return {schema_version:'mission-narrator-report-input/2',\n  provenance:{report_binding:b,source_cursor:p.source_cursor,history_chain_sha256:p.history_chain_sha256??null,\n   history_count:p.history_count??null,selected_context:data.continuita_selezionata,history_source_aliases:historyAliases},\n  attested_server_facts:{resolved_report:narratorStructuredValue(p.scene.snapshot.resolved_facts),technical_catalog_sources:data.fonti_tecniche_catalogo},\n  current_declarations:{action_references:data.azioni,sources:declarations},\n  stable_context:{location:data.luogo,mission_setting:context?.setting??null,setting_sources:settings,other_authored_sources:otherSources},\n  characters,\n  private_knowledge_boundaries:p.knowledge_context,\n  phase_possibilities:{conditional_consequences:(context?.consequences??[]).map(item=>({transition_key:item.transition_key,\n   condition_from_mission:item.private_note,possible_consequence:item.public_fact,source_role:'conditional_not_current_fact'})),\n   authored_background_and_initial_situation:context?.plot_private??null,authored_guidance:context?.director_notes??null},\n  acquired_history:{previous_private_memory:memory,published_events:delta},\n  private_memory_output:{scope:'this_preview_result',input_history_chain_sha256:p.history_chain_sha256??null,input_history_count:p.history_count??null}};\n}\n"
 boundary='export async function combatReportNarratorRequest(p,b,limits){'
 once(runtime,boundary,helper+'\n'+boundary)
 once(runtime,' const input={...data,contesto_missione_e_fase:context,conoscenze_private_png:p.knowledge_context,memoria_di_continuita:memory,fati_successivi_alla_memoria:delta};',
  ' const input=projectCombatReportNarratorInput(p,b,data,actors,context,memory,delta);')
 match=re.search(r" const sys='staff-combat-report-narrator/2\.[^\n]+",old[runtime]);assert match;oldsys=match.group(0)
 sys='staff-combat-report-narrator/3. Sei l’unico narratore della scena. Dai un seguito ai fatti definitivi del server, usando le dichiarazioni per comprenderne il senso e la storia acquisita per conservare ciò che è già avvenuto. Missione, mappa e mondo offrono il contesto da sviluppare; schede e conoscenze orientano voce, reazioni e condotta dei PNG, mentre il repertorio gestuale e le possibilità della fase non descrivono eventi già accaduti. Rendi osservabili gli effetti degli esiti e le scelte effettive attraverso parole, comportamenti e ambiente coerenti, senza riprendere le parole delle azioni o spiegare come interpretarle. Le conseguenze condizionali attendono la conferma del server; danni, azioni meccaniche e decisioni dei PG restano alle rispettive autorità. Restituisci text come unico Fato e scene_memory come promemoria privato aggiornato.'
 newsys=' const sys='+json.dumps(sys,ensure_ascii=False)+"+'\\n'+SCENE_MEMORY_RULE;"
 once(runtime,oldsys,newsys)
 oldformat="text:{format:{type:'json_schema',name:'staff_combat_report_narrative',strict:true,schema:{type:'object',properties:{text:{type:'string'}},required:['text'],additionalProperties:false}}}};"
 newformat="text:{format:{type:'json_schema',name:'staff_combat_report_narrative_memory',strict:true,schema:{type:'object',properties:{text:{type:'string'},scene_memory:sceneMemorySchema},required:['text','scene_memory'],additionalProperties:false}}}};"
 once(runtime,oldformat,newformat)
 oldnormal="  if(!exact(value,['text'])||typeof value.text!=='string'||!value.text.trim()||Array.from(value.text).length>limits.transport_max_chars)bad();\n  return {ok:true,origin:'combat_report',text:value.text,advisories:[],failure_codes:[]};"
 newnormal="  if(!exact(value,['text','scene_memory'])||typeof value.text!=='string'||!value.text.trim()||Array.from(value.text).length>limits.transport_max_chars||!narrativeSceneMemoryShape(value.scene_memory))bad();\n  return {ok:true,origin:'combat_report',text:value.text,scene_memory:value.scene_memory,advisories:[],failure_codes:[]};"
 once(runtime,oldnormal,newnormal)
 once(handler," const readableCampaigns=new Set(['"+historical+"',campaign]);"," const readableCampaigns=new Set(['"+historical+"','"+previous+"',campaign]);")
 once(handler,"value.prompt_revision!=='staff-combat-report-narrator/2'","value.prompt_revision!=='staff-combat-report-narrator/3'")
 # All original checks run before the new provider-only projection. No source rows change.
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
  files.append({'name':n,'baseline_sha256':sha(old[n].encode()),'candidate_sha256':sha(s.encode()),'bytes':len(s.encode()),'changed':s!=old[n],'inverse':'EXACT_EDGE142'})
  if s!=old[n]:
   d=out/'diff'/Path(n+'.diff');d.parent.mkdir(parents=True,exist_ok=True);d.write_text(''.join(difflib.unified_diff(old[n].splitlines(True),s.splitlines(True),fromfile='Edge142/'+n,tofile='Narratore77/'+n)))
 for term,end in [('function narrativeActorPersonaView(','function nativeWriterActors('),('function narrativeSceneMemoryShape(','function checkedNarrativeSceneOutput('),('const SCENE_MEMORY_RULE=',"// The same short rule")]:
  start=old[runtime].find(term)
  assert start>=0
  if end in old[runtime][start:]:stop=old[runtime].find(end,start)
  else:stop=old[runtime].find('\n}',start)+2
  assert old[runtime][start:stop]in new[runtime],term
 pack={'name':'mission_generic_ai','entrypoint_path':'mission-generic-index.ts','verify_jwt':b['verify_jwt'],'files':[{'name':f['name'],'content':new[f['name']]}for f in b['files']]};assert pack['verify_jwt']is False
 package=out/'EDGE_PACKAGE.json';package.write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n')
 site=Path(a.site);uiold=(site/'mission-generic-ui.mjs').read_text();ui=uiold;assert sha(ui.encode())=='dfbf9b1ea689c20e4954cd186c71413163bffb0bc20d9eefbc07166084fede79'
 ctl=next(line for line in ui.splitlines(True)if line.startswith(' const combatReportRevision='))
 newctl=ctl.replace('combatReportRevision=','combatReportStructured=') .replace(previous,campaign).replace("build:'staff-combat-report-ui/2'","build:'staff-combat-report-ui/3'").replace("title:'Narratore · reazioni e ambiente'","title:'Narratore · fonti e memoria'").replace("caseLabels:['Reazioni, condotta e ambiente']","caseLabels:['Fatti, reazioni e memoria privata']")
 uiedits=[(ctl,ctl+newctl),("  combatReportRevision.mount(host);","  combatReportRevision.mount(host);\n  combatReportStructured.mount(host);"),("dispose(){combatReportRevision.dispose();","dispose(){combatReportStructured.dispose();combatReportRevision.dispose();"),("export const VERSION='mission-combat64-ui/5-narratore76-report02';","export const VERSION='mission-combat64-ui/5-narratore77-report03';")]
 for before,after in uiedits:assert ui.count(before)==1;ui=ui.replace(before,after)
 inv=ui
 for before,after in reversed(uiedits):assert inv.count(after)==1;inv=inv.replace(after,before)
 assert inv==uiold
 uidir=out/'ui';uidir.mkdir(exist_ok=True);(uidir/'mission-generic-ui.mjs').write_text(ui)
 q=subprocess.run([node,'--check',str(uidir/'mission-generic-ui.mjs')],capture_output=True,text=True);assert q.returncode==0,q.stderr
 landold=(site/'land.html').read_text();assert sha(landold.encode())=='319c4accdff7938356e47a694d24d8e7bfdae5126f69ebfcb4aa19fdcc9b405d'
 oldpin='./mission-generic-ui.mjs?v=narratore76-dfbf9b1ea689c20e';newpin='./mission-generic-ui.mjs?v=narratore77-'+sha(ui.encode())[:16]
 assert landold.count(oldpin)==1;land=landold.replace(oldpin,newpin);assert land.replace(newpin,oldpin)==landold;(uidir/'land.html').write_text(land)
 for name,bs,cs in [('mission-generic-ui.mjs',uiold,ui),('land.html',landold,land)]:
  (out/'diff'/(name+'.diff')).write_text(''.join(difflib.unified_diff(bs.splitlines(True),cs.splitlines(True),fromfile='UI9ef8/'+name,tofile='Narratore77/'+name)))
 helper_hash=sha((site/'mission-editorial-staff.mjs').read_bytes());assert helper_hash=='34fa4e6596cf18d3eb56130e487c8a0f6e0af7f152e06aebbeeca1859567255f'
 remote={'head':'fb88a0bdb0de9d3879f7ac2c8761d19c28e245e3','tree':'a2e99c7945db9dcabd15d89705fb0cdb9e09e218','evidence':'Fresh GitHub ref/tree via connector; local Git blob SHA1 matched tree. Content-addressed reconciliation, not full remote readback.'}
 uirows=[]
 for n,s in [('land.html',land),('mission-generic-ui.mjs',ui)]:
  bs=(site/n).read_bytes();blob=hashlib.sha1(b'blob '+str(len(bs)).encode()+b'\0'+bs).hexdigest();expected={'land.html':'58773be61e07f840ad75f7494cb1e7fb7ef163eb','mission-generic-ui.mjs':'7ea47e57895ab8b051ed1ffc43540437ff0f57a6'}[n];assert blob==expected
  uirows.append({'path':'sito_live/'+n,'baseline_bytes':len(bs),'baseline_sha256':sha(bs),'baseline_git_blob':blob,'candidate_bytes':len(s.encode()),'candidate_sha256':sha(s.encode()),'candidate_path':str(uidir/n),'inverse':'EXACT_UI9ef8'})
 uimanifest={'schema':'narratore77-ui/1','campaign_id':campaign,'historical_read_campaigns':[historical,previous],'module_version':'mission-combat64-ui/5-narratore77-report03','module_pin':'narratore77-'+sha(ui.encode())[:16],'files':uirows,'unchanged_helper_sha256':helper_hash,'remote':remote,'old_panes_preserved':True,'separate_new_journal':True,'no_polling_autostart':True,'html_delta':'one import cache pin only','global_build':'UNCHANGED','syntax':'PASS_MODULE','runtime':'NOT_RUN'}
 (out/'UI.json').write_text(json.dumps(uimanifest,ensure_ascii=False,indent=2)+'\n')
 contract={'schema':'mission-narrator-report-input/2','campaign_id':campaign,'prompt_revision':'staff-combat-report-narrator/3',
  'projection_order':'existing immutable scene/report/source/history validation, then provider-only projection',
  'source_roles':{'attested_server_facts':'Resolved report and receipt define mechanical facts; decoded JSON preserves values.','current_declarations':'Declared attempts and speech, not automatic outcomes.','stable_context':'Mission map/setting/world when supplied; context source hash references prevent duplicated setting text.','characters':'Profile/voice separate from gesture repertoire, possible conduct and private authored background.','phase_possibilities':'Original transition condition and candidate consequence are conditional, never promoted to current facts.','acquired_history':'Exact published events with IDs, hashes, sequence; source aliases use equality of verified body hashes.','private_memory_output':'Same Generation returns memory bound through the actual run/request/source/result receipts; never gameplay authority.'},
  'history_bootstrap':'Use actual stored memory when present; otherwise null plus verified published events. No manual summary, fixture or second model call.',
  'output':{'required':['text','scene_memory'],'memory_shape':'existing sceneMemorySchema and narrativeSceneMemoryShape unchanged','normalized_keys':['ok','origin','text','scene_memory','advisories','failure_codes'],'storage':'private editorial_runs.result.scene_memory; publicResult whitelist unchanged'},
  'limits':'Existing memory capacities only; no semantic gate, mandatory reaction, phrase ban, invented damage, new mechanics or state transition.',
  'not_proved_by_one_preview':['subsequent-turn memory consumption','full mission flow','global Director removal','editorial success before actual Staff result review']}
 (out/'INPUT_CONTRACT.json').write_text(json.dumps(contract,ensure_ascii=False,indent=2)+'\n')
 (out/'PROMPT_DIFF.md').write_text('# Narratore77 · proiezione strutturale\n\nIl prompt precedente è sostituito, non accumulato. Le fonti sigillate restano identiche; cambia la proiezione privata verso il modello.\n\n## Prompt nuovo\n\n'+sys+'\n\nSegue `SCENE_MEMORY_RULE` già esistente, byte identico.\n\n## Delta contrattuale\n\nFatti attestati, dichiarazioni, storia acquisita, contesto stabile, schede/repertorio e conseguenze condizionali hanno sezioni distinte. Il Fato antecedente mascherato da setting viene deduplicato solo per hash verificato. La stessa Generation produce `text` e `scene_memory`; la memoria resta nel risultato privato della preview. Nessuna decisione PG, nuova conseguenza meccanica o transizione è applicata dal modello.\n')
 static={'aggregate':27,'baseline_edge':142,'baseline_ezbr':b['ezbr_sha256'],'baseline_metadata_sha256':sha(baseline),'package_sha256':sha(package.read_bytes()),'builder_sha256':sha(Path(__file__).read_bytes()),'projection_source_sha256':sha(helper.encode()),'files':files,'changed_files':sum(f['changed']for f in files),'unchanged_files':sum(not f['changed']for f in files),'syntax':syntax,'relative_imports':'RESOLVED_STATIC','whole_inverse':'EXACT_EDGE142','campaign_id':campaign,'historical_read_campaigns':[historical,previous],'source_payload_and_binding':'UNCHANGED','existing_validator_actor_projection_memory_helpers_ledger_worker':'UNCHANGED','prompt_revision':'staff-combat-report-narrator/3','output_memory':'private result.scene_memory same Generation','pre_freeze_selfcheck':['Hash dedup restricted to setting sources; current role declarations never consumed by history aliasing.','Unknown history count remains null, not an invented zero.'],'provider_calls':0,'runtime_quality':'NOT_RUN','UI':uimanifest}
 (out/'STATIC.json').write_text(json.dumps(static,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({k:static[k]for k in ['aggregate','package_sha256','builder_sha256','projection_source_sha256','changed_files','unchanged_files','provider_calls']}))
if __name__=='__main__':main()
