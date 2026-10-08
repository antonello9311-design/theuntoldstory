import {createNewNativeVariantPreparation} from './mf-new-native-variant-form-af773345364d8e5b5d6d5387c57b5d52f709e75f1edca8ce86e8ad9b2db119e4.mjs';
import {factoryEventProjection,missionD100EventProjection,mountMissionD100Runtime} from './mf-mission-native-bridge-2d2425cd4006f98ee4afa2bc61fbdb2fe4b8d34bd64b60d7c23e3ce8c549d978.mjs';
import {createExistingVariantFormDocument} from './mf-existing-variant-form-2f834639f7bc0191bae0f9abafb34d01665ec036e4051315caa1eb145bd3fe72.mjs';
export const VERSION='mission-creation-ui/1.0+factory-draft/2';
const copy=value=>structuredClone(value);
const uuid=()=>crypto.randomUUID();
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const node=(tag,text,attrs={})=>{const n=document.createElement(tag);if(text!==null)n.textContent=text;for(const [k,v] of Object.entries(attrs))n.setAttribute(k,v);return n;};
const button=(text,fn,secondary=false)=>{const n=node('button',text,{type:'button',class:'mbtn'+(secondary?' ghost':'')});n.addEventListener('click',fn);return n;};
const field=(text,control)=>{const n=node('label',text,{class:'mc-field'});n.append(control);return n;};
const input=(value,fn,{type='text',max=null}={})=>{const n=node('input',null,{type});n.value=value??'';if(max)n.maxLength=max;n.addEventListener('input',()=>fn(n.value));return n;};
const text=(value,fn,max=null)=>{const n=node('textarea',null,{rows:'3'});n.value=value??'';if(max)n.maxLength=max;n.addEventListener('input',()=>fn(n.value));return n;};
const select=(items,value,fn)=>{const n=node('select',null);for(const x of items)n.append(node('option',x.label,{value:x.value}));n.value=value??'';n.addEventListener('change',()=>fn(n.value));return n;};
const check=(label,value,fn)=>{const n=node('label',label,{class:'mc-check'}),c=input('',()=>{}, {type:'checkbox'});c.checked=!!value;c.addEventListener('change',()=>fn(c.checked));n.prepend(c);return n;};
const row=(...items)=>{const n=node('div',null,{class:'mc-row'});n.append(...items);return n;};
const card=title=>{const n=node('section',null,{class:'mc-card'});n.append(node('h3',title));return n;};
const setting=()=>({name:'',description:''});
const phaseEditorial=key=>({step_key:key,setting:setting(),director_notes:'',entry_public:'',actors:[],consequences:[]});
const profileKey=a=>a.mechanical_binding_id?'m:'+a.mechanical_binding_id:a.narrative_version_id?'n:'+a.narrative_version_id:'';
const phaseName=(s,i)=>s.public_objective?.split('\n')[0].slice(0,65)||'Fase '+(i+1);
function styles(){if(document.getElementById('mission-creation-style'))return;const s=node('style',null,{id:'mission-creation-style'});s.textContent=`
.mc-editor,.mc-human{color:var(--ink,#1d1206);font:500 17px/1.5 'Cormorant Garamond',Georgia,serif;min-width:0;color-scheme:light;overflow-wrap:anywhere}.mc-editor *,.mc-human *{box-sizing:border-box}.mc-editor h2,.mc-editor h3,.mc-editor h4,.mc-human h3{font-family:'Cinzel',serif;line-height:1.4;color:var(--ink,#1d1206);margin:0 0 12px}.mc-editor h2{font-size:20px}.mc-editor h3,.mc-human h3{font-size:15px;letter-spacing:.06em}.mc-editor h4{font-size:13px}.mc-card{padding:16px;margin:12px 0;border:1px solid var(--edge,#b79d6c);border-radius:9px;background:rgba(255,252,244,.6)}.mc-field{display:flex;flex-direction:column;gap:5px;margin:10px 0;min-width:0;flex:1;font-weight:600}.mc-row{display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap}.mc-row>.mc-field{flex:1 1 180px}.mc-editor input,.mc-editor select,.mc-editor textarea{width:100%;min-width:0;max-width:100%;min-height:44px;padding:9px 11px;border:1px solid var(--rule,#8a6f43);border-radius:7px;background:rgba(255,252,244,.8);color:var(--ink,#1d1206);font:500 17px/1.4 'Cormorant Garamond',Georgia,serif}.mc-editor textarea{resize:vertical;min-height:90px}.mc-editor .mc-check{display:flex;align-items:center;gap:8px;margin:10px 0}.mc-editor .mc-check input{width:20px;min-height:20px;height:20px;flex:none;accent-color:var(--red,#a6321d)}.mc-editor button,.mc-human button{font:600 11px/1.4 'Cinzel',serif;letter-spacing:.06em;text-transform:uppercase;min-height:44px;padding:10px 14px;border:1px solid var(--red-deep,#7c2413);border-radius:7px;background:var(--red,#a6321d);color:#f6ead0;cursor:pointer;white-space:normal;max-width:100%}.mc-editor button.ghost,.mc-human button.ghost{background:transparent;color:var(--ink,#1d1206);border-color:var(--edge,#b79d6c)}.mc-editor button:disabled,.mc-human button:disabled{opacity:.55;cursor:not-allowed}.mc-editor button:focus-visible,.mc-editor input:focus-visible,.mc-editor select:focus-visible,.mc-editor textarea:focus-visible,.mc-editor summary:focus-visible,.mc-human button:focus-visible,.mc-human summary:focus-visible{outline:2px solid var(--red-deep,#7c2413);outline-offset:3px}.mc-editor summary,.mc-human summary{cursor:pointer;font-family:'Cinzel',serif;font-size:13px;font-weight:600;padding:8px 0}.mc-editor details>section{margin-top:8px}.mc-help{color:var(--ink-soft,#584425);margin:8px 0}.mc-status{min-height:26px;color:var(--red-deep,#7c2413);margin:12px 0}.mc-actions{display:flex;align-items:center;flex-wrap:wrap;gap:10px;padding:14px 0}.mc-private{border-left:3px solid var(--rule,#8a6f43);padding-left:12px;margin:12px 0}.mc-dialog{width:min(1100px,96vw);max-height:calc(100vh - 32px);max-height:calc(100dvh - 32px);overflow:auto;overscroll-behavior:contain;margin:auto;padding:20px;border:1.5px solid var(--rule,#8a6f43);border-radius:9px;background:linear-gradient(var(--paper-hi,#f1e6ca),var(--paper,#e7d6b2));color:var(--ink,#1d1206)}.mc-dialog::backdrop{background:rgba(20,14,6,.5)}.mc-human p{white-space:pre-wrap}.mc-chip{display:inline-block;padding:3px 8px;border:1px solid var(--edge,#b79d6c);border-radius:7px;font-size:14px;margin:4px 0}.mc-summary{display:flex;flex-wrap:wrap;gap:8px;align-items:center}.mc-editor .mc-phase{margin:14px 0}.mc-error{font-weight:600}.mc-editor fieldset{min-width:0;border:0;margin:0;padding:0}.mc-editor fieldset:disabled{opacity:.8}@media(max-width:600px){.mc-dialog{padding:12px}.mc-card{padding:12px}.mc-row{align-items:stretch}.mc-row>.mc-field{flex-basis:100%}.mc-actions{align-items:stretch;flex-direction:column}.mc-actions button{width:100%}.mc-editor .mc-check{align-items:flex-start}}
`;document.head.append(s);}

// Actor identity, per-phase actor specs and native trigger keys follow Generic 1.1.
function newPhase(key,terminal=''){return {step_key:key,kind:'narrative',public_objective:'',actors:[],actor_specs:{},fighters:[],encounter:null,encounter_key:'enc_'+key,pg_team:'squadra',terminal,triggers:[],editorial:phaseEditorial(key),arena:null};}
function blank(){const a=newPhase('inizio'),z=newPhase('conclusione','success');a.triggers=[{trigger_key:'avanti',source_kind:'player_choice',label:'Prosegui',to:'conclusione'}];return {mission:{title:'',grado:'D',briefing:'',village:'',tag_trama:'',team_min:1,team_max:4,direction_mode:'ai',gathering_location_id:''},editorial:{plot_private:'',setting:setting()},actors:[],scenes:[a,z],initial:'inizio',base:null,counter:1,revision:null,catalog:null};}
function loadPlan(model,detail,revision){
 const def=detail.definitions?.find(x=>x.id===revision.definition_id)?.definition;
 if(!detail.plan||!def||!Array.isArray(def.scenes))throw Error('La revisione non contiene un piano completo.');
 if(def.scenes.some(s=>s.encounters.length>1||s.triggers.some(t=>!['player_choice','combat_terminal'].includes(t.source_kind))))throw Error('Questa revisione contiene eventi specializzati non modificabili qui. Nessun dato è stato cambiato.');
 const actors=new Map();for(const s of def.scenes)for(const a of s.actors)if(!actors.has(a.actor_key))actors.set(a.actor_key,copy(a));model.actors=[...actors.values()];
 model.scenes=detail.plan.steps.map(step=>{const cfg=def.scenes.find(s=>s.step_key===step.step_key);if(!cfg)throw Error('Configurazione di una fase mancante.');const s=newPhase(step.step_key);Object.assign(s,{kind:step.kind,public_objective:step.public_objective,actors:cfg.actors.map(a=>a.actor_key),actor_specs:Object.fromEntries(cfg.actors.map(a=>[a.actor_key,copy(a)])),fighters:(cfg.encounters[0]?.actors||[]).map(a=>a.actor_key),encounter:copy(cfg.encounters[0]||null),encounter_key:cfg.encounters[0]?.encounter_key||'enc_'+step.step_key,pg_team:cfg.encounters[0]?.pg_team||'squadra',terminal:revision.settings?.terminal_steps?.find(t=>t.step_key===step.step_key)?.outcome||'',triggers:cfg.triggers.map(t=>{const tr=detail.plan.transitions.find(x=>x.transition_key===t.transition_key);if(!tr)throw Error('Passaggio della fase mancante.');return {...copy(t),transition:copy(tr),to:tr.to_step_key};})});return s;});
 const latestBase=model.catalog?.versions?.filter(v=>v.plan_id===revision.plan_id).sort((a,b)=>b.version-a.version)[0];if(!latestBase?.plan_version_id)throw Error('Baseline del piano non disponibile: riapri la configurazione.');model.initial=detail.plan.initial_step_key;model.base=latestBase.plan_version_id;model.revision=revision;
}
function applyEditorial(model,data){
 model.mission={...model.mission,...copy(data.mission||{})};model.editorial={plot_private:data.editorial?.plot_private||'',setting:{...setting(),...copy(data.editorial?.setting||{})}};
 for(const s of model.scenes){const e=data.editorial?.scenes?.find(x=>x.step_key===s.step_key);s.editorial=e?{...phaseEditorial(s.step_key),...copy(e),setting:{...setting(),...copy(e.setting||{})}}:phaseEditorial(s.step_key);s.arena=copy(data.arenas?.find(x=>x.step_key===s.step_key)||null);}
}
export function buildMissionCreationDocument(model,catalog,{mode=null,factorySource=null,factoryCatalog=null,factoryD100Projections=[]}={}){
 if(mode!==null&&!['ai','human'].includes(mode))throw Error('Modalità variante non valida.');
 if(mode!==null&&model?.mission?.direction_mode!==mode)throw Error('La regia della variante non coincide con la modalità richiesta.');
 const document=value(model,catalog);
 if(factorySource) applyFactoryEvents(document,factorySource,factoryCatalog,mode,factoryD100Projections);
 return document;
}
function applyFactoryEvents(document,source,catalog,mode,d100Projections=[]){
 if(source?.schema_version!=='mission-factory-draft/1'||!Array.isArray(source.phases)||
    !['ai','human'].includes(mode)||document.plan.steps.length!==source.phases.length)
   throw Error('La bozza sorgente della variante non è coerente.');
 for(const phase of source.phases){
  const nativeStep=document.plan.steps.find(x=>x.step_key===phase.step_key);
  const nativeScene=document.plan.definition.scenes.find(x=>x.step_key===phase.step_key);
  if(!nativeStep||!nativeScene||!Array.isArray(phase.transitions)||
     nativeStep.kind!==(phase.kind==='combat'?'mechanical':'narrative')||
     nativeScene.triggers.length!==phase.transitions.length)
    throw Error('Le fasi della variante non coincidono con il canovaccio.');
  for(const transition of phase.transitions){
   const nativeTrigger=nativeScene.triggers.find(x=>x.transition_key===transition.transition_key);
   const nativeTransition=document.plan.transitions.find(x=>x.transition_key===transition.transition_key);
   if(!nativeTrigger||!nativeTransition||nativeTransition.from_step_key!==phase.step_key||
      nativeTransition.to_step_key!==transition.to_step_key)
     throw Error('I passaggi della variante non coincidono con il canovaccio.');
   const expected=phase.kind==='d100'?missionD100EventProjection(transition,mode,catalog,phase,d100Projections.find(x=>x.step_key===phase.step_key)):factoryEventProjection(transition,mode,catalog,phase.kind);
   nativeTrigger.source_kind=expected.source_kind;
   nativeTrigger.fact_code=expected.fact_code;
   if(phase.kind==='combat') nativeTrigger.combat_outcome=expected.combat_outcome;
   nativeTransition.event_kind=transition.transition_key;
   nativeTransition.priority=0;
  }
 }
 if(document.plan.transitions.length!==source.phases.reduce((n,x)=>n+x.transitions.length,0))
   throw Error('La variante contiene passaggi aggiuntivi.');
}
function value(model,catalog){
 const m=model.mission,scenes=model.scenes;
 if(!m.title.trim()||!m.briefing.trim())throw Error('Completa titolo e briefing pubblico.');
 if(!model.editorial.setting.description.trim())throw Error('Descrivi l’ambientazione narrativa della missione, separata dalla chat di ritrovo.');
 if(!catalog.locations.some(l=>l.id===m.gathering_location_id))throw Error('Scegli la chat di ritrovo dall’elenco.');
 if(!catalog.modes.includes(m.direction_mode))throw Error('Scegli il tipo di regia disponibile.');
 if(!Number.isInteger(m.team_min)||!Number.isInteger(m.team_max)||m.team_min<catalog.team_min||m.team_max>catalog.team_max||m.team_min>m.team_max)throw Error('Controlla il numero minimo e massimo dei PG.');
 if(model.actors.some(a=>(!a.mechanical_binding_id&&!a.narrative_version_id)||!a.team?.trim()))throw Error('Completa i profili del Ninja Book e gli schieramenti iniziali dei PNG.');
 if(!scenes.length||!scenes.some(s=>s.step_key===model.initial)||!scenes.some(s=>s.terminal))throw Error('Indica una fase iniziale e almeno una conclusione.');
 const transitions=[],definition={schema_version:'mission-generic-definition/1',scenes:[]},editorial={...copy(model.editorial),scenes:[]},arenas=[];
 for(const s of scenes){
  if(!s.public_objective.trim()||s.actors.some(k=>!s.actor_specs[k]?.team?.trim()))throw Error('Completa gli obiettivi e gli schieramenti di ogni fase.');
  const assigned=s.actors.map(k=>copy(s.actor_specs[k])),key=s.encounter_key||'enc_'+s.step_key;
  const fighters=assigned.filter(a=>s.fighters.includes(a.actor_key));
  if(s.kind==='mechanical'){
   if(!s.pg_team?.trim()||fighters.length<1||fighters.length>12||fighters.some(a=>!a.mechanical_binding_id)||!fighters.some(a=>a.team!==s.pg_team))throw Error('Ogni scontro richiede da 1 a 12 PNG combattenti e almeno un avversario dei PG.');
   if(!s.arena?.template_key||!Number.isInteger(s.arena.template_version)||!s.arena.zone_key)throw Error('Scegli la mappa e la zona di ogni fase di scontro.');
   arenas.push({step_key:s.step_key,template_key:s.arena.template_key,template_version:s.arena.template_version,zone_key:s.arena.zone_key});
  }
  const activeTriggers=s.terminal?[]:s.triggers;if(!s.terminal&&!activeTriggers.length)throw Error('Aggiungi un passaggio alle fasi che non concludono la missione.');
  if(s.kind==='mechanical'){const outcomes=activeTriggers.map(t=>t.combat_outcome||'any');const complete=outcomes.length===1&&outcomes[0]==='any'||outcomes.length===3&&['pg_win','pg_loss','draw'].every(k=>outcomes.includes(k));if(!complete)throw Error('Dopo ogni scontro prevedi un solo passaggio per qualsiasi esito oppure tutti e tre i passaggi: vittoria dei PG, sconfitta dei PG e pareggio. Completa anche le loro destinazioni.');}
  const triggers=activeTriggers.map(t=>{if(!t.to||!scenes.some(x=>x.step_key===t.to)||!t.label?.trim())throw Error('Completa la destinazione e il testo di ogni passaggio.');const tk=t.transition_key||s.step_key+'_'+t.trigger_key;
   transitions.push({transition_key:tk,from_step_key:s.step_key,to_step_key:t.to,event_kind:t.transition?.event_kind||tk,priority:t.transition?.priority??0});
   const x={trigger_key:t.trigger_key,transition_key:tk,source_kind:s.kind==='mechanical'?'combat_terminal':'player_choice',fact_code:t.fact_code||(s.kind==='mechanical'?'combat_terminal_confirmed':'player_choice_confirmed'),label:t.label};
   if(s.kind==='mechanical'){x.encounter_key=key;if(t.combat_outcome!==undefined)x.combat_outcome=t.combat_outcome;}return x;
  });
  const encounter={...(s.encounter||{}),encounter_key:key,pg_policy:'all_active',pg_team:s.pg_team,actors:fighters,arena_ref:'mission'};
  definition.scenes.push({step_key:s.step_key,actors:assigned,encounters:s.kind==='mechanical'?[encounter]:[],triggers});
  const e=copy(s.editorial);e.step_key=s.step_key;e.actors=(e.actors||[]).filter(a=>s.actors.includes(a.actor_key));e.consequences=activeTriggers.map(t=>({transition_key:t.transition_key||s.step_key+'_'+t.trigger_key,public_fact:t.editorial?.public_fact??e.consequences?.find(c=>c.transition_key===(t.transition_key||s.step_key+'_'+t.trigger_key))?.public_fact??'',private_note:t.editorial?.private_note??e.consequences?.find(c=>c.transition_key===(t.transition_key||s.step_key+'_'+t.trigger_key))?.private_note??''}));editorial.scenes.push(e);
 }
 const reachable=new Set([model.initial]);let grew=true;while(grew){grew=false;for(const t of transitions)if(reachable.has(t.from_step_key)&&!reachable.has(t.to_step_key)){reachable.add(t.to_step_key);grew=true;}}
 if(scenes.some(s=>!reachable.has(s.step_key)))throw Error('Collega tutte le fasi a partire dalla fase iniziale.');
 const exits=new Set(scenes.filter(s=>s.terminal).map(s=>s.step_key));grew=true;while(grew){grew=false;for(const t of transitions)if(exits.has(t.to_step_key)&&!exits.has(t.from_step_key)){exits.add(t.from_step_key);grew=true;}}
 if(scenes.some(s=>!exits.has(s.step_key)))throw Error('Ogni fase deve poter raggiungere una conclusione.');
 return {schema_version:'mission-creation-document/1',mission:{title:m.title.trim(),grado:m.grado,briefing:m.briefing.trim(),village:m.village||'',tag_trama:m.tag_trama||'',team_min:m.team_min,team_max:m.team_max,direction_mode:m.direction_mode,gathering_location_id:m.gathering_location_id},plan:{schema_version:'mission-generic-plan-document/1',base_plan_version_id:model.base,initial_step_key:model.initial,steps:scenes.map(s=>({step_key:s.step_key,kind:s.kind,public_objective:s.public_objective})),transitions,definition,terminal_steps:scenes.filter(s=>s.terminal).map(s=>({step_key:s.step_key,outcome:s.terminal}))},editorial,arenas};
}


// Ricostruisce il modello dal documento nativo, senza richiedere una missione pubblicata.
export function loadMissionDraftDocument(document){
 if(document?.schema_version!=='mission-creation-document/1'||document.plan?.schema_version!=='mission-generic-plan-document/1'||
    !Array.isArray(document.plan.steps)||!Array.isArray(document.plan.transitions)||
    !Array.isArray(document.plan.definition?.scenes)||!Array.isArray(document.plan.terminal_steps)||
    !Array.isArray(document.editorial?.scenes)||!Array.isArray(document.arenas))throw Error('Documento variante non valido.');
 const model=blank();model.mission={...model.mission,...copy(document.mission)};
 model.editorial={plot_private:document.editorial.plot_private||'',setting:{...setting(),...copy(document.editorial.setting||{})}};
 model.base=document.plan.base_plan_version_id??null;model.initial=document.plan.initial_step_key;
 const actors=new Map(),scenes=[];
 for(const step of document.plan.steps){
  const cfg=document.plan.definition.scenes.find(x=>x.step_key===step.step_key);
  if(!cfg||!Array.isArray(cfg.actors)||!Array.isArray(cfg.encounters)||cfg.encounters.length>1||!Array.isArray(cfg.triggers))throw Error('Configurazione della fase mancante o non modificabile.');
  const scene=newPhase(step.step_key);scene.kind=step.kind;scene.public_objective=step.public_objective;
  scene.actors=cfg.actors.map(a=>a.actor_key);scene.actor_specs=Object.fromEntries(cfg.actors.map(a=>[a.actor_key,copy(a)]));
  for(const actor of cfg.actors)if(!actors.has(actor.actor_key))actors.set(actor.actor_key,copy(actor));
  const encounter=cfg.encounters[0]||null;scene.encounter=copy(encounter);scene.fighters=(encounter?.actors||[]).map(a=>a.actor_key);
  scene.encounter_key=encounter?.encounter_key||'enc_'+step.step_key;scene.pg_team=encounter?.pg_team||'squadra';
  scene.terminal=document.plan.terminal_steps.find(x=>x.step_key===step.step_key)?.outcome||'';
  scene.triggers=cfg.triggers.map(t=>{const transition=document.plan.transitions.find(x=>x.transition_key===t.transition_key);if(!transition)throw Error('Transizione della variante mancante.');return {...copy(t),transition:copy(transition),to:transition.to_step_key};});
  const editorial=document.editorial.scenes.find(x=>x.step_key===step.step_key);
  scene.editorial=editorial?{...phaseEditorial(step.step_key),...copy(editorial),setting:{...setting(),...copy(editorial.setting||{})}}:phaseEditorial(step.step_key);
  scene.arena=copy(document.arenas.find(x=>x.step_key===step.step_key)||null);scenes.push(scene);
 }
 if(document.plan.definition.scenes.length!==scenes.length||document.editorial.scenes.length!==scenes.length||
    document.arenas.some(x=>!scenes.some(s=>s.step_key===x.step_key))||new Set(scenes.map(x=>x.step_key)).size!==scenes.length)
   throw Error('Fasi della variante incoerenti.');
 model.scenes=scenes;model.actors=[...actors.values()];model.counter=1;
 return model;
}

export function createMissionCreationUI({client,identity,isStaff,mapPicker,currentLocation=()=>null,presentCharacters=async()=>[],openNativeMaster=()=>{},notice=()=>{},refresh=()=>{},onCreated=()=>{}}){
 let epoch=0,currentDialog=null,principal=identity(),createRecord=null;
 const views=new Map(),edits=new Map(),humans=new Map(),humanStarts=new Map(),drafts=new Set(),d100Views=new Map();
 const valid=(user,stamp=epoch)=>!!user&&principal===user&&identity()===user&&stamp===epoch;
 function syncIdentity(){const next=identity();if(next!==principal){clear({forget:true});principal=next;}}
 function clear({forget=false}={}){epoch++;for(const panel of d100Views.values())panel.dispose();d100Views.clear();for(const draft of drafts)draft.finish(null);drafts.clear();for(const host of views.keys())host.replaceChildren();views.clear();for(const host of humans.keys()){host.replaceChildren();host.hidden=true;}humans.clear();if(forget){createRecord=null;edits.clear();humanStarts.clear();}if(currentDialog){currentDialog.close();currentDialog.remove();currentDialog=null;}}
 client.auth?.onAuthStateChange?.((event,session)=>{const next=session?.user?.id||null;if(next!==principal){clear({forget:true});principal=next;}});
 async function rpc(name,args,user=identity(),stamp=epoch){
  if(!valid(user,stamp))throw Error('Accesso cambiato: riapri la missione.');
  const auth=await client.auth.getSession();if(auth?.error||auth?.data?.session?.user?.id!==user||!valid(user,stamp))throw Error('Accesso cambiato: riapri la missione.');
  const r=await client.rpc(name,args);if(!valid(user,stamp))throw Error('Accesso cambiato: verifica lo stato prima di ripetere.');if(r.error){const messages={MGP_BASE_VERSION_STALE:'Il piano è stato aggiornato: riapri l’editor per creare la revisione sulla nuova baseline.',MC_CREATION_EDITORIAL_BUDGET:'Accorcia trama, ambientazione o note della fase: il contesto supera lo spazio disponibile per la regia.',MC_GATHERING_LOCATION_REQUIRED:'Scegli la chat di ritrovo della missione.',MC_CONFIRMED_ROSTER_REQUIRED:'Conferma prima la squadra attraverso le iscrizioni della missione.',MC_COMPLETE_REVISION_REQUIRED:'Completa e salva la configurazione della missione prima di avviarla.',MC_REVISION_REQUIRES_NO_ACTIVE_SESSION:'La missione ha una sessione attiva: potrai salvare la revisione dopo la sua chiusura.',MC_REVISION_BOARD_ALREADY_OPEN:'Le iscrizioni sono già aperte: la configurazione non può essere sostituita durante questo avvio.'};const raw=r.error.message||'Operazione non confermata.',key=Object.keys(messages).find(k=>raw.includes(k));throw Object.assign(Error(key?messages[key]:raw),{code:r.error.code,requiresReload:raw.includes('MGP_BASE_VERSION_STALE')});}return r.data;
 }
 const record=model=>({model,catalog:null,profiles:null,request:null,payload:null,mutation:null,busy:false,uncertain:false,saved:null,message:'',expanded:new Set(['inizio'])});
 function active(view){return views.get(view.host)===view&&view.host.isConnected&&valid(view.user,view.epoch)&&isStaff()&&(!view.existing||view.existing.isCurrent())&&(!view.newNative||view.newNative.isCurrent());}
 function existingGuard(view,action,args={}){if(!view.existing)return true;try{view.existing.adapter.guard(action,{...args,model:view.record.model});view.record.message='Modifica strutturale non ancora disponibile nel contratto del producer. Originale conservato.';render(view);updateRecord(view.record);return false;}catch(e){view.record.message=e.message;render(view);updateRecord(view.record);return false;}}
 function lock(view){if(view.revisionPicker)view.revisionPicker.disabled=!!view.record.payload;view.form.disabled=!!view.record.payload;view.save.disabled=view.record.busy||!!view.record.saved||!!view.record.stale;view.save.textContent=view.newNative?'Prepara nuovo piano':view.existing?'Prepara il delta della variante':view.draft?'Conferma variante nella bozza':view.record.uncertain?'Verifica lo stesso salvataggio':view.mission?'Salva e usa nuova revisione':currentLocation()?.id==='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'&&currentLocation()?.is_test===true?'Prepara prova riservata':'Pubblica missione';}
 function updateRecord(rec){for(const view of views.values())if(view.record===rec&&active(view)){view.status.textContent=rec.message;lock(view);}}
 function freshKey(model,prefix){let key;do{key=prefix+'_'+model.counter++;}while(model.actors.some(a=>a.actor_key===key)||model.scenes.some(s=>s.step_key===key||s.triggers.some(t=>t.trigger_key===key)));return key;}
 function rememberOpen(view){view.host.querySelectorAll('details[data-phase]').forEach(d=>{if(d.open)view.record.expanded.add(d.dataset.phase);else view.record.expanded.delete(d.dataset.phase);});}
 function profilesFor(rec,a){return rec.profiles.mechanical_profiles.find(p=>p.mechanical_binding_id===a.mechanical_binding_id)||rec.profiles.narrative_profiles.find(p=>p.narrative_version_id===a.narrative_version_id);}
 function actorTitle(rec,a){return profilesFor(rec,a)?.display_name||(rec.existing&&profileKey(a)?'PNG '+a.actor_key+' · profilo storico':'PNG da configurare');}
 function render(view){if(!active(view))return;rememberOpen(view);const {record:rec,form}=view,m=rec.model,meta=m.mission;form.replaceChildren();
  const general=card('Missione e ritrovo');general.append(row(field('Titolo pubblico',input(meta.title,v=>meta.title=v,{max:80})),field('Grado',select(['D','C','B','A','S'].map(x=>({value:x,label:x})),meta.grado,v=>meta.grado=v))),
   row(field('Regia',(()=>{const c=select(rec.catalog.modes.map(x=>({value:x,label:x==='ai'?'Intelligenza artificiale':'Master umano'})),meta.direction_mode,v=>meta.direction_mode=v);if(view.draft||view.newNative)c.disabled=true;return c;})()),field('Villaggio',select([{value:'',label:'Ogni villaggio'},{value:'Konoha',label:'Konoha'},{value:'Suna',label:'Suna'}],meta.village,v=>meta.village=v))),
   row(field('PG minimi',select(Array.from({length:rec.catalog.team_max-rec.catalog.team_min+1},(_,i)=>({value:String(i+rec.catalog.team_min),label:String(i+rec.catalog.team_min)})),String(meta.team_min),v=>meta.team_min=Number(v))),field('PG massimi',select(Array.from({length:rec.catalog.team_max-rec.catalog.team_min+1},(_,i)=>({value:String(i+rec.catalog.team_min),label:String(i+rec.catalog.team_min)})),String(meta.team_max),v=>meta.team_max=Number(v)))),
   field('Chat di ritrovo',(()=>{const c=select([{value:'',label:'Scegli dove si incontrano i giocatori'},...rec.catalog.locations.map(l=>({value:l.id,label:l.name}))],meta.gathering_location_id,v=>meta.gathering_location_id=v);c.setAttribute('data-mc-gathering','');return c;})()),
   node('p','La chat indica dove giocare. L’ambientazione della storia si descrive separatamente qui sotto.',{class:'mc-help'}),field('Briefing pubblico sulla bacheca',text(meta.briefing,v=>meta.briefing=v,600)),node('p',view.newNative?'La preparazione conserva la fonte. Il salvataggio della variante non pubblica né avvia la missione.':view.draft?'Premi e progressione seguono la policy server. Confermare qui aggiorna soltanto la variante della bozza Factory.':'XP e Ryo seguono le regole del grado. Pubblicare la missione non la avvia e non chiama l’IA.',{class:'mc-help'}));if(view.existing){general.querySelectorAll('input,select,textarea').forEach(c=>c.disabled=true);general.append(node('p','Metadati missione di sola lettura. Head e baseline arrivano dall’owner; questo form non seleziona una revisione.',{class:'mc-help'}));}if(view.newNative){general.querySelectorAll('input,select,textarea').forEach(c=>c.disabled=!c.hasAttribute('data-mc-gathering'));general.append(node('p','Stai preparando un nuovo piano della fonte scelta. I suoi dati restano invariati; scegli esplicitamente il ritrovo.',{class:'mc-help'}));}form.append(general);
  const story=card('Trama e confini della missione');story.append(row(field('Nome dell’ambientazione narrativa',input(m.editorial.setting.name,v=>m.editorial.setting.name=v))),field('Descrizione dell’ambientazione narrativa',text(m.editorial.setting.description,v=>m.editorial.setting.description=v)),field('Trama e confini · riservati alla regia',text(m.editorial.plot_private,v=>m.editorial.plot_private=v)),field('Tag di trama · collegamento staff',(()=>{const c=text(meta.tag_trama,v=>meta.tag_trama=v,300);if(view.existing||view.newNative)c.disabled=true;return c;})()),node('p','La scena nasce dalle azioni scritte dai giocatori. La regia le legge e le restituisce nel contesto di trama, ambientazione e limiti, senza decidere le azioni dei PG. Gli obiettivi indicano possibilità da perseguire, non eventi già avvenuti.',{class:'mc-help'}));form.append(story);
  const actors=card('PNG della missione · '+m.actors.length);actors.append(node('p','Aggiungi i profili approvati dal Ninja Book. Puoi usare più unità dello stesso profilo e decidere in quali fasi compaiono.',{class:'mc-help'}));
  const items=[{value:'',label:'Scegli dal Ninja Book'},...rec.profiles.mechanical_profiles.map(p=>({value:'m:'+p.mechanical_binding_id,label:p.display_name+' · '+p.rank+' · combattimento e narrazione'})),...rec.profiles.narrative_profiles.map(p=>({value:'n:'+p.narrative_version_id,label:p.display_name+' · solo narrazione'}))];
  for(const a of m.actors){const box=card('Unità '+(m.actors.indexOf(a)+1)+' · '+actorTitle(rec,a));const options=[...items];if(profileKey(a)&&!options.some(p=>p.value===profileKey(a)))options.push({value:profileKey(a),label:view.existing?'Profilo storico fuori catalogo · pin conservato':'Profilo della revisione non più disponibile: scegline un altro'});
   box.append(row(field('Profilo dal Ninja Book',select(options,profileKey(a),v=>{if(view.existing&&!existingGuard(view,'profile-change',{actor:a.actor_key}))return;const mechanical=v.startsWith('m:'),key=v.slice(2),p=mechanical?rec.profiles.mechanical_profiles.find(x=>x.mechanical_binding_id===key):rec.profiles.narrative_profiles.find(x=>x.narrative_version_id===key);const spec={mechanical_binding_id:p&&mechanical?key:null,narrative_template_id:p?.narrative_template_id||null,narrative_version_id:p?.narrative_version_id||null};Object.assign(a,spec);for(const s of m.scenes){if(s.actor_specs[a.actor_key])Object.assign(s.actor_specs[a.actor_key],spec);if(!mechanical||!p)s.fighters=s.fighters.filter(k=>k!==a.actor_key);}render(view);})),field('Schieramento iniziale nelle nuove fasi',(()=>{const c=input(a.team,v=>a.team=v);if(view.existing)c.disabled=true;return c;})())),button('Rimuovi questa unità',()=>{if(!existingGuard(view,'actor-remove',{actor:a.actor_key}))return;m.actors=m.actors.filter(x=>x!==a);for(const s of m.scenes){s.actors=s.actors.filter(k=>k!==a.actor_key);s.fighters=s.fighters.filter(k=>k!==a.actor_key);delete s.actor_specs[a.actor_key];s.editorial.actors=s.editorial.actors.filter(x=>x.actor_key!==a.actor_key);}render(view);},true));actors.append(box);
  }
  actors.append(button('Aggiungi dal Ninja Book',()=>{if(view.existing){rec.message='Aggiunta PNG in attesa del contratto del producer.';updateRecord(rec);return;}m.actors.push({actor_key:freshKey(m,'png'),mechanical_binding_id:null,narrative_template_id:null,narrative_version_id:null,team:'avversari'});render(view);}));form.append(actors);
  const phaseHead=card('Fasi della missione');phaseHead.append(node('p','Puoi creare una missione interamente narrativa o inserire più scontri, ciascuno nella propria fase e con la propria mappa.',{class:'mc-help'}),field('Fase iniziale',select(m.scenes.map((s,i)=>({value:s.step_key,label:phaseName(s,i)})),m.initial,v=>m.initial=v)));form.append(phaseHead);
  for(const s of m.scenes){const d100Source=view.draft?.factorySource?.phases?.find(p=>p.step_key===s.step_key)?.kind==='d100';const box=node('details',null,{class:'mc-card mc-phase','data-phase':s.step_key});box.open=rec.expanded.has(s.step_key);box.addEventListener('toggle',()=>{if(box.open)rec.expanded.add(s.step_key);else rec.expanded.delete(s.step_key);});box.append(node('summary','Fase '+(m.scenes.indexOf(s)+1)+' · '+(s.kind==='mechanical'?'Scontro':'Narrazione')+' · '+phaseName(s,m.scenes.indexOf(s))));const body=node('section',null);
   body.append(row(field('Tipo di fase',select([{value:'narrative',label:'Narrazione'},{value:'mechanical',label:'Scontro'}],s.kind,v=>{if(!existingGuard(view,'phase-kind',{step:s.step_key}))return;s.kind=v;if(v==='mechanical'){s.terminal='';s.encounter_key||='enc_'+s.step_key;s.pg_team||='squadra';}for(const t of s.triggers){t.source_kind=v==='mechanical'?'combat_terminal':'player_choice';t.fact_code=v==='mechanical'?'combat_terminal_confirmed':'player_choice_confirmed';if(v==='mechanical')t.combat_outcome||='any';}render(view);})),field('Esito della missione in questa fase',select([{value:'',label:'La missione continua'},{value:'success',label:'Missione riuscita'},{value:'failure',label:'Missione fallita'}],s.terminal,v=>{if(!existingGuard(view,'phase-terminal',{step:s.step_key}))return;s.terminal=v;if(v&&s.kind!=='narrative'){s.kind='narrative';for(const t of s.triggers){t.source_kind='player_choice';t.fact_code='player_choice_confirmed';}}render(view);}))),field('Situazione e obiettivo pubblici',text(s.public_objective,v=>s.public_objective=v)),field('Testo pubblico d’ingresso · traccia per la regia',text(s.editorial.entry_public,v=>s.editorial.entry_public=v)));
   const location=node('details',null);location.append(node('summary','Ambientazione di questa fase · facoltativa'),field('Nome · lascia vuoto per ereditare quello generale',input(s.editorial.setting.name,v=>s.editorial.setting.name=v)),field('Descrizione · lascia vuota per ereditare quella generale',text(s.editorial.setting.description,v=>s.editorial.setting.description=v)));body.append(location,field('Note di regia e limiti della fase · riservati',text(s.editorial.director_notes,v=>s.editorial.director_notes=v)));
   const roster=card('PNG presenti in questa fase');if(!m.actors.length)roster.append(node('p','Nessun PNG aggiunto alla missione.',{class:'mc-help'}));
   for(const a of m.actors){const present=s.actors.includes(a.actor_key),line=node('section',null,{class:'mc-card'});line.append(check('Unità '+(m.actors.indexOf(a)+1)+' · '+actorTitle(rec,a),present,on=>{if(view.existing){if(!on)existingGuard(view,'phase-actor-remove',{actor:a.actor_key,step:s.step_key});else{rec.message='Modifica roster in attesa del contratto del producer.';render(view);updateRecord(rec);}return;}s.actors=s.actors.filter(k=>k!==a.actor_key);s.fighters=s.fighters.filter(k=>k!==a.actor_key);if(on){s.actors.push(a.actor_key);s.actor_specs[a.actor_key]||=copy(a);}render(view);}));
    if(present){const spec=s.actor_specs[a.actor_key]||(s.actor_specs[a.actor_key]=copy(a));line.append(field('Schieramento in questa fase',(()=>{const c=input(spec.team,v=>{if(view.existing){existingGuard(view,'profile-change',{actor:a.actor_key,step:s.step_key});return;}spec.team=v;});if(view.existing)c.disabled=true;return c;})()));if(s.kind==='mechanical'&&spec.mechanical_binding_id)line.append(check('Combatte in questa fase',s.fighters.includes(a.actor_key),on=>{if(view.existing){existingGuard(view,'fighter-remove',{actor:a.actor_key,step:s.step_key});return;}s.fighters=s.fighters.filter(k=>k!==a.actor_key);if(on)s.fighters.push(a.actor_key);}));
     let ed=s.editorial.actors.find(x=>x.actor_key===a.actor_key);if(!ed){ed={actor_key:a.actor_key,role_in_phase:'',goal_private:'',known_facts_private:'',public_portrayal:''};s.editorial.actors.push(ed);}const notes=node('details',null);notes.append(node('summary','Ruolo e conoscenze di questa unità'),field('Ruolo nella fase',text(ed.role_in_phase,v=>ed.role_in_phase=v)),field('Intenzione e obiettivo · riservati',text(ed.goal_private,v=>ed.goal_private=v)),field('Fatti conosciuti dal PNG · riservati',text(ed.known_facts_private,v=>ed.known_facts_private=v)),field('Descrizione e comportamento visibili ai PG',text(ed.public_portrayal,v=>ed.public_portrayal=v)));line.append(notes);
    }roster.append(line);
   }body.append(roster);
   if(view.existing){const cfg=view.existing.adapter.original().plan.definition.scenes.find(x=>x.step_key===s.step_key);if(cfg.encounters.length){const preserved=card('Incontri della fase · riferimenti conservati');for(const e of cfg.encounters)preserved.append(node('p',e.encounter_key+' · '+e.actors.length+' PNG · '+(e.pg_team||'schieramento originale')));preserved.append(node('p','Gli incontri narrativi e quelli aggiuntivi sono conservati integralmente. Rimozione e struttura richiedono il contratto del producer.',{class:'mc-help'}));body.append(preserved);}}
   if(s.kind==='mechanical'){const arena=card('Scontro e mappa');arena.append(field('Schieramento dei PG',input(s.pg_team,v=>s.pg_team=v)),node('p','Partecipano tutti i PG attivi. Seleziona sopra da 1 a 12 PNG combattenti, con almeno un avversario.',{class:'mc-help'}));const note=node('p',s.arena?.label||s.arena?.template_key&&('Mappa scelta · zona '+s.arena.zone_key)||'Mappa non ancora scelta.',{class:'mc-help',role:'status'}),pick=button(s.arena?'Cambia mappa e zona':'Scegli mappa e zona',async()=>{if(rec.payload||!active(view))return;pick.disabled=true;try{if(typeof mapPicker!=='function')throw Error('Selettore mappe non disponibile.');const selected=await mapPicker(copy(s.arena),phaseName(s,m.scenes.indexOf(s)),{scope:view.newNative?'new_native':view.existing?'existing_native':'ordinary',pg_count:m.mission.team_max,png_count:view.existing?Math.max(0,...view.existing.adapter.original().plan.definition.scenes.find(x=>x.step_key===s.step_key).encounters.map(e=>e.actors.length)):s.fighters.length});if(!active(view)||rec.payload)return;if(selected){s.arena={step_key:s.step_key,...selected};note.textContent=selected.label||'Mappa scelta · zona '+selected.zone_key;pick.textContent='Cambia mappa e zona';}}catch(e){if(active(view))note.textContent=e.message;}finally{if(active(view)&&!rec.payload)pick.disabled=false;}});arena.append(note,pick);body.append(arena);}
   if(!s.terminal||view.existing&&s.triggers.length){const flows=card('Passaggi e conseguenze');
    for(const t of s.triggers){const line=node('section',null,{class:'mc-card'});const choices=s.kind==='mechanical'?[{value:'any',label:'Scontro terminato · qualsiasi esito'},{value:'pg_win',label:'Vittoria dei PG'},{value:'pg_loss',label:'Sconfitta dei PG'},{value:'draw',label:'Nessuna squadra vincitrice'}]:[{value:'player_choice',label:'Scelta del giocatore / passaggio del Master'}];
     line.append(row(field('Quando si attiva',view.existing||d100Source?(()=>{const label={narrative_event:'Evento narrativo della Regia',spatial_event:'Evento spaziale',combat_terminal:'Scontro concluso',player_choice:'Scelta esplicita del giocatore'}[t.source_kind]||t.source_kind;const c=select([{value:t.source_kind,label}],t.source_kind,()=>{});c.disabled=true;return c;})():select(choices,s.kind==='mechanical'?(t.combat_outcome||'any'):'player_choice',v=>{if(s.kind==='mechanical')t.combat_outcome=v;})),field('Etichetta del passaggio',input(t.label,v=>t.label=v))),field('Fase di destinazione',select([{value:'',label:'Scegli una fase'},...m.scenes.map(x=>({value:x.step_key,label:phaseName(x,m.scenes.indexOf(x))+(x===s?' · questa fase':'')}))],t.to,v=>t.to=v)));
     if(view.existing){const outcome={any:'qualsiasi esito',pg_win:'vittoria dei PG',pg_loss:'sconfitta dei PG',draw:'pareggio'}[t.combat_outcome]||t.combat_outcome;line.append(node('p',(outcome?'Esito: '+outcome+'. ':'')+(t.encounter_key?'Incontro: '+t.encounter_key+'. ':'')+'Evento originale conservato; fonte e fatti non vengono convertiti.',{class:'mc-help'}));}
     if(!t.editorial)t.editorial=copy(s.editorial.consequences.find(c=>c.transition_key===(t.transition_key||s.step_key+'_'+t.trigger_key))||{public_fact:'',private_note:''});line.append(field('Conseguenza pubblica possibile · dopo il passaggio',text(t.editorial.public_fact,v=>t.editorial.public_fact=v)),field('Conseguenza riservata alla regia',text(t.editorial.private_note,v=>t.editorial.private_note=v)),button('Rimuovi passaggio',()=>{if(d100Source)return;if(!existingGuard(view,'trigger-remove',{step:s.step_key,trigger:t.trigger_key}))return;s.triggers=s.triggers.filter(x=>x!==t);render(view);},true));flows.append(line);
    }
    if(!d100Source)flows.append(button('Aggiungi passaggio',()=>{if(view.existing){rec.message='Aggiunta eventi in attesa del contratto del producer.';updateRecord(rec);return;}s.triggers.push({trigger_key:freshKey(m,'passaggio'),source_kind:s.kind==='mechanical'?'combat_terminal':'player_choice',label:'Prosegui',to:'',...(s.kind==='mechanical'?{combat_outcome:'any'}:{})});render(view);}));body.append(flows);
   }else body.append(node('p','Questa fase conclude la missione. I premi, se previsti dal percorso, sono gestiti dal server.',{class:'mc-help'}));
   const controls=row();for(const [offset,label]of [[-1,'Sposta prima'],[1,'Sposta dopo']]){const move=button(label,()=>{const from=m.scenes.indexOf(s),to=from+offset;if(to<0||to>=m.scenes.length)return;[m.scenes[from],m.scenes[to]]=[m.scenes[to],m.scenes[from]];render(view);},true);move.disabled=m.scenes.indexOf(s)+offset<0||m.scenes.indexOf(s)+offset>=m.scenes.length;controls.append(move);}const remove=button('Rimuovi fase',()=>{if(!existingGuard(view,'phase-remove',{step:s.step_key}))return;if(m.scenes.length<2)return;m.scenes=m.scenes.filter(x=>x!==s);for(const p of m.scenes)p.triggers=p.triggers.filter(t=>t.to!==s.step_key);if(m.initial===s.step_key)m.initial=m.scenes[0].step_key;render(view);},true);remove.disabled=m.scenes.length<2;controls.append(remove);body.append(controls);if(d100Source){const fixed=body.querySelectorAll('select');if(fixed[0])fixed[0].disabled=true;if(fixed[1])fixed[1].disabled=true;body.append(node('p','Prova D100: struttura, policy e fatti sono congelati dal binding Native.'));}box.append(body);form.append(box);
  }
  form.append(button('Aggiungi fase',()=>{if(view.existing){rec.message='Aggiunta fasi in attesa del contratto del producer.';updateRecord(rec);return;}const s=newPhase(freshKey(m,'fase'));m.scenes.push(s);rec.expanded.add(s.step_key);render(view);}));lock(view);
 }
 const sourceKey=user=>'mission-human-staff-source/1/'+user;
 function sourcePending(user){
  const raw=sessionStorage.getItem(sourceKey(user));if(!raw)return null;const r=JSON.parse(raw);
  if(Object.keys(r).sort().join(',')!=='document,location,request,schema,user'||r.schema!=='mission-human-staff-source/1'||r.user!==user||r.location!=='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'||!UUID.test(r.request||'')||!r.document||typeof r.document!=='object'||Array.isArray(r.document))throw Error('Recupero della fonte non verificabile: nessuna nuova fonte verrà creata.');return r;
 }
 function sourceRemember(user,args){
  const r={schema:'mission-human-staff-source/1',user,location:args.p_location,request:args.p_request,document:copy(args.p_document)},old=sourcePending(user),raw=JSON.stringify(r);
  if(old&&JSON.stringify(old)!==raw)throw Error('Una fonte precedente è da riconciliare: riapri la preparazione.');sessionStorage.setItem(sourceKey(user),raw);if(sessionStorage.getItem(sourceKey(user))!==raw)throw Error('Recupero della fonte non salvato: nessuna richiesta inviata.');
 }
 function sourceForgetRejected(user,request,error){
  if(!/^22/.test(error?.code||'')||!String(error.message||'').includes('H3_STAFF_SOURCE_'))return false;
  const old=sourcePending(user);if(!old||old.request!==request)return false;sessionStorage.removeItem(sourceKey(user));return sessionStorage.getItem(sourceKey(user))===null;
 }
 function sourceRecovery(view){
  const loc=currentLocation();if(view.mission||view.draft||view.existing||view.newNative||loc?.id!=='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'||loc.is_test!==true)return false;
  let pending;try{pending=sourcePending(view.user);}catch(e){view.status.textContent=e.message;return true;}if(!pending)return false;
  view.status.textContent='La fonte riservata è già da confermare o riprendere. Nessuna seconda fonte verrà creata.';
  const b=button('Conferma e riapri la stessa fonte',async()=>{if(!active(view)||currentLocation()?.id!==pending.location)return;b.disabled=true;
   try{const r=await rpc('mission_human_staff_source_create_v1',{p_request:pending.request,p_document:copy(pending.document),p_location:pending.location},view.user,view.epoch);
    if(!active(view)||currentLocation()?.id!==pending.location)return;
    if(r?.schema_version!=='mission-creation-result/1'||!UUID.test(r.mission_id||'')||r.state!=='configured'||r.direction_mode!=='human')throw Error('Fonte non confermata.');
    await routeBoard(r.mission_id,pending.document.mission.title);
   }catch(e){if(active(view)){if(sourceForgetRejected(view.user,pending.request,e)){createRecord=null;await prepare(view.host,{});}else view.status.textContent='Fonte da riconciliare, stessa richiesta conservata. '+e.message;}}finally{if(active(view))b.disabled=false;}});view.host.append(b);return true;
 }
 async function save(view){const rec=view.record;if(!active(view)||rec.busy||rec.saved||rec.stale)return;
  if(view.newNative){try{view.newNative.adapter.assertModel(rec.model);const document=buildMissionCreationDocument(rec.model,rec.catalog,{mode:view.newNative.mode});const result=view.newNative.adapter.finish(document);view.newNative.lastResult=copy(result);rec.message='Nuovo piano preparato. La conferma server appartiene al controller della variante.';updateRecord(rec);view.newNative.onResult(copy(result));}catch(e){rec.message=e.message;updateRecord(rec);}return;}
  if(view.existing){try{const result=view.existing.adapter.finish(rec.model,view.existing.baseline);view.existing.lastResult=copy(result);rec.message=result.blockers.length?result.blockers.map(x=>x.message).join(' '):'Delta preparato nei sorgenti: nessun salvataggio o selezione server effettuati.';updateRecord(rec);view.existing.onResult(copy(result));}catch(e){rec.message=e.message;updateRecord(rec);}return;}
  if(view.draft){try{const document=buildMissionCreationDocument(rec.model,rec.catalog,{mode:view.draft.mode,factorySource:view.draft.factorySource,factoryCatalog:view.draft.factoryCatalog,factoryD100Projections:view.draft.factoryD100Projections});view.draft.finish({mode:view.draft.mode,state:'complete',document:copy(document)});}catch(e){rec.message=e.message;updateRecord(rec);}return;}
  if(!rec.payload){try{rec.payload=value(rec.model,rec.catalog);rec.request=uuid();const room=currentLocation(),staffSource=!view.mission&&room?.id==='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'&&room.is_test===true;if(staffSource&&rec.payload.mission.direction_mode!=='human')throw Error('La prova riservata nella Staff richiede Master umano.');rec.mutation=view.mission?{name:'mission_revision_complete_v1',args:{p_mission:view.mission,p_request:rec.request,p_expected_mission_sha256:rec.model.catalog.mission_sha256,p_expected_selection_version:rec.model.catalog.selection_control_version,p_document:copy(rec.payload)}}:staffSource?{name:'mission_human_staff_source_create_v1',args:{p_request:rec.request,p_document:copy(rec.payload),p_location:room.id}}:{name:'mission_create_complete_v1',args:{p_request:rec.request,p_document:copy(rec.payload)}};}catch(e){rec.payload=null;rec.message=e.message;updateRecord(rec);return;}}
  rec.busy=true;rec.message=rec.uncertain?'Verifica della stessa richiesta…':'Salvataggio di missione, fasi e mappe…';updateRecord(rec);
  try{if(rec.mutation.name==='mission_human_staff_source_create_v1')sourceRemember(view.user,rec.mutation.args);const result=await rpc(rec.mutation.name,copy(rec.mutation.args),view.user,view.epoch);
   if(result?.schema_version!=='mission-creation-result/1'||!UUID.test(result.mission_id||'')||!UUID.test(result.plan_version_id||'')||result.state!=='configured'||result.direction_mode!==rec.payload.mission.direction_mode||view.mission&&result.mission_id!==view.mission)throw Error('La risposta non conferma il salvataggio.');
   rec.saved=result;rec.uncertain=false;rec.message='Missione configurata. La revisione '+result.version+' sarà usata dai nuovi avvii; le sessioni già aperte mantengono la propria configurazione.';updateRecord(rec);
   if(valid(view.user,view.epoch)){const staffSource=rec.mutation.name==='mission_human_staff_source_create_v1';notice(view.mission?'Nuova revisione salvata e selezionata':staffSource?'Fonte della prova riservata alla Staff preparata':'Missione pubblicata');refresh();if(!view.mission){createRecord=null;if(active(view))onCreated(result);if(staffSource&&valid(view.user,view.epoch)){rec.busy=false;await routeBoard(result.mission_id,rec.payload.mission.title);}}}
  }catch(e){if(rec.saved)return;if(!valid(view.user,view.epoch)){rec.uncertain=!!rec.payload;return;}
   if(e.code&&(/^(22|23)/.test(e.code)||['42501','40001','55000','P0001'].includes(e.code))){if(rec.mutation?.name==='mission_human_staff_source_create_v1')sourceForgetRejected(view.user,rec.request,e);rec.payload=null;rec.request=null;rec.mutation=null;rec.uncertain=false;rec.stale=e.code==='40001'||e.requiresReload===true;rec.message=(rec.stale?'La missione è cambiata: riapri l’editor per leggere la versione aggiornata. ':'Salvataggio rifiutato; correggi i dati indicati. ')+e.message;}
   else{rec.uncertain=true;rec.message='Salvataggio non confermato. Usa “Verifica lo stesso salvataggio”: riprende la stessa richiesta senza creare una seconda missione. '+e.message;}
  }finally{rec.busy=false;updateRecord(rec);}
 }
 async function prepare(host,{mission=null,title='',revision=null,draft=null,existing=null,newNative=null}={}){
  syncIdentity();if(!host||!host.isConnected||!isStaff()||!identity())return;styles();const user=identity(),stamp=epoch;
  const view={host,user,epoch:stamp,mission,draft,existing,newNative,record:null,form:null,save:null,status:null};views.set(host,view);host.replaceChildren();host.classList.add('mc-editor');
  const heading=node('h2',newNative?'Nuovo piano · '+newNative.sourceMetadata.title:existing?'Variante esistente · '+existing.document.mission.title:mission?'Modifica missione · '+title:'Crea una missione');view.status=node('p','Caricamento delle opzioni…',{class:'mc-status',role:'status','aria-live':'polite'});host.append(heading,view.status);
  try{
   if(sourceRecovery(view))return;
   const [catalog,profiles]=newNative?[newNative.catalog,newNative.profiles]:existing?[existing.catalog,existing.profiles]:draft?[draft.catalog,draft.profiles]:await Promise.all([rpc('mission_creation_catalog_v1',{},user,stamp),rpc('mission_generic_editor_v1',{p_plan_version:null},user,stamp)]);if(!active(view))return;
   if(catalog?.schema_version!=='mission-creation-catalog/1'||!Array.isArray(catalog.locations)||!Array.isArray(catalog.modes)||!Number.isInteger(catalog.team_min)||!Number.isInteger(catalog.team_max)||catalog.team_min<1||catalog.team_max>4||catalog.team_min>catalog.team_max||profiles?.schema_version!=='mission-generic-editor/1'||!Array.isArray(profiles.mechanical_profiles)||!Array.isArray(profiles.narrative_profiles))throw Error('Opzioni della missione non disponibili.');
   let rec;if(newNative){const model=blank();model.mission=newNative.adapter.mission();model.base=null;rec=record(model);}
   else if(existing){rec=record(existing.adapter.model());rec.existing=true;}
   else if(draft){rec=record(copy(draft.model));rec.model.mission.direction_mode=draft.mode;}
   else if(!mission){rec=createRecord||record(blank());createRecord=rec;}
   else{
    const pending=[...edits.values()].find(x=>x.mission===mission&&x.payload&&!x.saved);if(pending)rec=pending;
    else{
     const [planCatalog,initialMeta]=await Promise.all([rpc('mission_generic_plan_catalog_v1',{p_mission:mission},user,stamp),rpc('mission_creation_editor_v1',{p_mission:mission,p_plan_version:revision},user,stamp)]);if(!active(view))return;
     if(initialMeta?.schema_version!=='mission-creation-editor/1'||!Array.isArray(planCatalog?.versions)||typeof planCatalog.mission_sha256!=='string')throw Error('Configurazione missione non disponibile.');
     const revisions=planCatalog.versions.filter(x=>x.generic_ready).sort((a,b)=>b.version-a.version),chosenId=revision||initialMeta.plan_version_id||planCatalog.selected_plan_version_id||revisions[0]?.plan_version_id||null,chosen=revisions.find(x=>x.plan_version_id===chosenId);
     if(chosenId&&!chosen)throw Error('La revisione richiesta non è modificabile in questo editor.');
     const model=blank();model.catalog=planCatalog;let metadata=initialMeta;
     if(chosen){const detail=await rpc('mission_generic_editor_v1',{p_plan_version:chosen.plan_version_id},user,stamp);if(!active(view))return;loadPlan(model,detail,chosen);if(chosen.plan_version_id!==initialMeta.plan_version_id)metadata=await rpc('mission_creation_editor_v1',{p_mission:mission,p_plan_version:chosen.plan_version_id},user,stamp);}
     if(!active(view))return;if(metadata.configured&&!chosen)throw Error('La configurazione completa non ha una revisione disponibile. Nessuna modifica effettuata.');applyEditorial(model,metadata);rec=record(model);rec.mission=mission;rec.revisions=revisions;edits.set(mission+':'+(chosenId||'legacy'),rec);
    }
   }
   rec.catalog=catalog;rec.profiles=profiles;view.record=rec;view.form=node('fieldset',null);view.save=button(newNative?'Prepara nuovo piano':existing?'Prepara il delta della variante':draft?'Conferma variante nella bozza':mission?'Salva e usa nuova revisione':currentLocation()?.id==='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'&&currentLocation()?.is_test===true?'Prepara prova riservata':'Pubblica missione',()=>save(view));
   if(mission&&rec.revisions?.length){const pick=select(rec.revisions.map(r=>({value:r.plan_version_id,label:'Revisione '+r.version+(r.plan_version_id===rec.model.catalog.selected_plan_version_id?' · scelta per i nuovi avvii':' · salvata')})),rec.model.revision?.plan_version_id,v=>editor(mission,title,v));view.revisionPicker=pick;pick.disabled=!!rec.payload;host.append(field('Revisione da visualizzare e modificare',pick));}
   const actions=node('div',null,{class:'mc-actions'});actions.append(view.save);if(draft)actions.append(button('Annulla',()=>draft.finish(null),true));host.append(view.form,actions);rec.message||=newNative?'Compila e conferma esplicitamente il nuovo piano. Nessuna revisione esistente viene copiata, selezionata o pubblicata.':existing?'Modifica solo i campi dichiarati: il delta conserva eventi, incontri e pin della variante originale. Nessuna chiamata di salvataggio.':draft?'Configura e conferma la variante. La bozza Factory sarà salvata dal pannello principale.':'Configura la missione. Il salvataggio pubblica una revisione completa senza avviarla.';render(view);if(existing)existing.baseline=copy(rec.model);updateRecord(rec);
  }catch(e){if(active(view)){view.status.textContent=e.message;view.status.classList.add('mc-error');}if(draft)draft.finish(null);}
 }
 async function mountCreate(host){return prepare(host);}
 async function mountNewNativeVariantForm(host,{sourceMetadata,head,mode,catalog,profiles,onResult,isCurrent}={}){
  if(typeof onResult!=='function'||typeof isCurrent!=='function'||!isCurrent())throw Error('Controller del nuovo piano non disponibile.');
  const adapter=createNewNativeVariantPreparation({sourceMetadata,head,mode}),newNative={adapter,sourceMetadata:copy(sourceMetadata),mode,catalog:copy(catalog),profiles:copy(profiles),onResult,isCurrent,lastResult:null};
  await prepare(host,{newNative});const view=views.get(host);if(!view?.record||view.newNative!==newNative||!active(view))throw Error('Ingresso nuovo piano non disponibile.');
  return {result:()=>{if(!active(view))throw Error('Accesso o contesto cambiato: riapri il nuovo piano.');return copy(newNative.lastResult);},dispose:()=>{if(views.get(host)===view){views.delete(host);host.replaceChildren();}}};
 }
 async function mountExistingVariantForm(host,{document,head,catalog,profiles,onResult=()=>{},isCurrent=()=>true}={}){
  const adapter=createExistingVariantFormDocument({document,head}),existing={adapter,document:adapter.original(),catalog:copy(catalog),profiles:copy(profiles),onResult,isCurrent,baseline:null,lastResult:null};
  await prepare(host,{existing});const view=views.get(host);if(!view?.record||!existing.baseline||view.existing!==existing)throw Error('Ingresso variante esistente non disponibile.');
  const current=()=>{if(!active(view))throw Error('Accesso o contesto cambiato: riapri la variante.');};
  return {result:()=>{current();return copy(existing.lastResult);},original:()=>{current();return adapter.original();},dispose:()=>{if(views.get(host)===view){views.delete(host);host.replaceChildren();}}};
 }
 async function editor(mission,title='',revision=null){
  if(!isStaff()||!UUID.test(mission||''))return;styles();if(currentDialog){currentDialog.close();currentDialog.remove();}
  const d=node('dialog',null,{class:'mc-dialog','aria-label':'Modifica missione'}),close=button('Chiudi',()=>d.close(),true),host=node('div',null);d.append(close,host);document.body.append(d);const previous=document.activeElement;d.addEventListener('close',()=>{views.delete(host);d.remove();if(currentDialog===d)currentDialog=null;if(previous?.isConnected)previous.focus();});d.showModal();currentDialog=d;return prepare(host,{mission,title,revision});
 }
 function humanContext(host,ctx){if(!ctx)return;const box=node('details',null,{class:'mc-private'});box.append(node('summary','Note riservate al Master'));
  const add=(label,val)=>{if(typeof val==='string'&&val.trim())box.append(node('h4',label),node('p',val));};add('Ambientazione',ctx.setting?.name);add('Descrizione',ctx.setting?.description);add('Trama e confini della missione',ctx.plot_private);add('Note di regia e limiti della fase',ctx.director_notes);add('Traccia d’ingresso',ctx.entry_public);
  for(const a of ctx.actors||[]){add('Ruolo del PNG · '+a.actor_key,a.role_in_phase);add('Obiettivo riservato',a.goal_private);add('Conoscenze del PNG',a.known_facts_private);add('Aspetto pubblico',a.public_portrayal);}
  for(const c of ctx.consequences||[]){add('Conseguenza possibile · '+c.transition_key,c.public_fact);add('Nota riservata',c.private_note);}host.append(box);
 }
 // C53: the journal permits UI recovery; server ownership/protection remain authoritative.
 const STAFF_CLOSE_ROOM='0b85f354-9cdb-47e1-baf9-3d266bb7e06b';
 const closePrefix=who=>'mission-human-close/1/'+who+'/';
 const positive=v=>Number.isSafeInteger(v)&&v>0;
 function validateCloseJournal(v,who,session){
  const a=v?.args;
  if(v?.schema!=='mission-human-close/1'||v.user!==who||v.location!==STAFF_CLOSE_ROOM||v.session!==session||
   !UUID.test(session||'')||!a||Object.keys(a).sort().join(',')!=='p_close_role,p_expected_control_version,p_mission_note,p_mission_outcome,p_request_key,p_session'||
   a.p_session!==session||a.p_close_role!==false||!positive(a.p_expected_control_version)||!UUID.test(a.p_request_key||'')||
   !['successo','fallimento'].includes(a.p_mission_outcome)||(a.p_mission_note!==null&&typeof a.p_mission_note!=='string')||
   (a.p_mission_note?.length||0)>5000||!Number.isSafeInteger(v.completed)||v.completed<0||v.completed>6||!['pending','closed'].includes(v.status))throw Error('Recupero della chiusura non verificabile.');
  return v;
 }
 function pendingHumanCloseSession(){
  syncIdentity();const who=identity();if(!who||currentLocation()?.id!==STAFF_CLOSE_ROOM||currentLocation()?.is_test!==true)return null;
  const found=[];
  for(let i=0;i<sessionStorage.length;i++){const k=sessionStorage.key(i);if(!k?.startsWith(closePrefix(who)))continue;
   const sid=k.slice(closePrefix(who).length),v=validateCloseJournal(JSON.parse(sessionStorage.getItem(k)),who,sid);
   if(v.status==='pending')found.push(sid);
  }
  if(found.length>1)throw Error('Più chiusure pendenti: nessuna sessione scelta automaticamente.');return found[0]||null;
 }
 function protectedStart(session,who){
  const matches=[];
  for(let i=0;i<sessionStorage.length;i++){
   const key=sessionStorage.key(i);if(!key?.startsWith('mission-human-staff-start/5/'+who+':'))continue;
   const v=JSON.parse(sessionStorage.getItem(key)),r=v?.result;
   if(r?.master_session_id!==session)continue;
   if(v.schema_version!=='mission-human-staff-start/5'||v.user!==who||v.location!==STAFF_CLOSE_ROOM||
    !UUID.test(v.mission||'')||key!=='mission-human-staff-start/5/'+who+':'+v.mission+':'+STAFF_CLOSE_ROOM||!UUID.test(v.request||'')||
    !Array.isArray(v.roster)||v.roster.length<1||v.roster.length>4||v.roster.some(x=>!UUID.test(x||''))||new Set(v.roster).size!==v.roster.length||
    r.schema_version!=='mission-human-test-start/1'||r.source_mission_id!==v.mission||r.simulation!==true||r.direction_mode!=='human')throw Error('Ricevuta protetta della prova non verificabile.');
   matches.push(v);
  }
  if(matches.length!==1)throw Error('Recupera la ricevuta originale della preparazione protetta.');return matches[0];
 }
 function phaseForClose(v,session){
  if(!['mission-human-phase-state/1'].includes(v?.schema_version)||v.master_session_id!==session||
   typeof v.closed!=='boolean'||!Array.isArray(v.transitions))throw Error('Stato autorevole della chiusura non verificabile.');return v;
 }
 async function humanCloseControls(host,h,state,context,user,stamp,same){
  h.closeContext=context||h.closeContext;const ctx=h.closeContext;
  if(!ctx||typeof ctx.current!=='function'||typeof ctx.lock!=='function'||typeof ctx.externalBusy!=='function')return;
  const key=closePrefix(user)+h.session;
  const signal=()=>ctx.lock({session:h.session,args:h.closeJournal?.status==='pending'?copy(h.closeJournal.args):null,blocked:!!h.closeError||h.closeJournal?.status==='pending'||h.closeRunning===true,busy:h.busy});
  const persist=v=>{if(!same()||!ctx.current())throw Error('Accesso o stanza cambiati.');try{const raw=JSON.stringify(v);sessionStorage.setItem(key,raw);if(sessionStorage.getItem(key)!==raw)throw Error('Recupero locale non confermato.');h.closeJournal=copy(v);signal();}catch(e){h.closeError=e.message;signal();throw e;}};
  try{const raw=sessionStorage.getItem(key);h.closeJournal=raw?validateCloseJournal(JSON.parse(raw),user,h.session):null;}
  catch(e){h.closeError=e.message;signal();}
  if(h.closeJournal?.status==='pending'&&state.closed===true&&state.session_state==='chiusa'){persist({...h.closeJournal,status:'closed'});h.closeError=null;signal();}
  const pending=h.closeJournal?.status==='pending';
  if(!pending&&!h.closeError&&(!ctx.current()||ctx.masterView!==true||ctx.viewer?.is_master!==true||ctx.master?.id!==h.session||ctx.location?.id!==STAFF_CLOSE_ROOM||ctx.location?.is_test!==true))return;
  if(!pending&&!h.closeError&&!(state.closed===false&&state.phase_kind==='narrative'&&state.transitions.length===0&&state.can_open_encounter===false&&state.awaiting_fato!==true))return;
  let eligibilityError='';if(!pending&&!h.closeError){try{protectedStart(h.session,user);}catch(e){eligibilityError=e.message;}}
  const box=card('Chiusura attività'),status=node('p',h.closeError||eligibilityError||h.closeMessage||'Concludi la prova dopo aver pubblicato il Fato finale. Nessun premio o avanzamento reale viene attribuito.',{class:'mc-status',role:'status','aria-live':'polite'});box.setAttribute('data-mc-human-close','');box.append(status);host.append(box);
  const blocked=()=>h.pending||h.fatoPending||state.awaiting_fato===true||ctx.externalBusy()||ctx.master?.suspended_at!==null;
  const controls=node('div',null,{class:'mc-actions'});box.append(controls);
  const outcome=select([{value:'successo',label:'Successo'},{value:'fallimento',label:'Fallimento'}],h.closeJournal?.args.p_mission_outcome||h.closeOutcome||'successo',v=>h.closeOutcome=v);
  const note=text(h.closeJournal?.args.p_mission_note||h.closeNote||'',v=>h.closeNote=v,5000);
  if(!pending&&!h.closeError){outcome.disabled=note.disabled=false;box.insertBefore(field('Esito della prova',outcome),status);box.insertBefore(field('Nota conclusiva del Master',note),status);}
  async function settleClosed(fresh){
   if(fresh.closed!==true||fresh.session_state!=='chiusa')return false;
   if(h.closeJournal){persist({...h.closeJournal,status:'closed'});}h.closeError=null;signal();status.textContent='Attività chiusa: storico conservato, nessun premio reale assegnato.';notice(status.textContent);refresh();return true;
  }
  async function run(recover){
   if(!same()||!ctx.current()||h.busy||h.closeError)return;
   let attemptedNative=0;h.closeRunning=true;h.busy=true;signal();host.querySelectorAll('button').forEach(b=>b.disabled=true);
   try{
    let fresh=phaseForClose(await rpc('mission_human_phase_state_v1',{p_session:h.session},user,stamp),h.session);
    if(!same()||!ctx.current())throw Error('Contesto cambiato: richiesta conservata.');
    if(await settleClosed(fresh))return;
    protectedStart(h.session,user);
    if(ctx.masterView!==true||ctx.viewer?.is_master!==true||ctx.master?.id!==h.session||ctx.location?.id!==STAFF_CLOSE_ROOM||ctx.location?.is_test!==true||ctx.master.suspended_at!==null||ctx.externalBusy())throw Error('La propria Regia Master deve essere libera e riletta prima della chiusura.');
    if(!recover){
     if(h.closeJournal?.status==='pending'||blocked()||fresh.awaiting_fato!==false||fresh.phase_kind!=='narrative'||fresh.transitions.length!==0||fresh.can_open_encounter!==false||fresh.master_control_version!==ctx.master.control_version)throw Error('La fase conclusiva non è ancora disponibile.');
     const args={p_session:h.session,p_mission_outcome:outcome.value,p_mission_note:note.value.trim()||null,p_close_role:false,p_expected_control_version:fresh.master_control_version,p_request_key:uuid()};
     validateCloseJournal({schema:'mission-human-close/1',user,location:STAFF_CLOSE_ROOM,session:h.session,args,completed:0,status:'pending'},user,h.session);
     // Signal the lock synchronously before persisting or sending any mutation.
     h.closeJournal={schema:'mission-human-close/1',user,location:STAFF_CLOSE_ROOM,session:h.session,args,completed:0,status:'pending'};signal();persist(h.closeJournal);
    }
    if(h.closeJournal?.status!=='pending')throw Error('Nessuna richiesta originale da riprendere.');
    const args=copy(h.closeJournal.args);status.textContent='Chiusura in corso…';
    for(let i=0;i<6;i++){
     if(!same()||!ctx.current())throw Error('Contesto cambiato: richiesta conservata.');
     attemptedNative++;const raw=await rpc('master_v2_close',copy(args),user,stamp);
     const result=raw?.data?.data??raw?.data??raw;
     if(!same()||!ctx.current())throw Error('Contesto cambiato: verifica la stessa chiusura.');
     if(!['chiusura','chiusa'].includes(result?.state)||!Number.isSafeInteger(result.completed_steps)||result.completed_steps<0||result.completed_steps>6||result.completed_steps<h.closeJournal.completed)throw Error('Ricevuta della chiusura non verificabile.');
     persist({...h.closeJournal,completed:result.completed_steps});
     if(result.state==='chiusa'){
      fresh=phaseForClose(await rpc('mission_human_phase_state_v1',{p_session:h.session},user,stamp),h.session);
      if(!same()||!ctx.current()||!await settleClosed(fresh))throw Error('Chiusura ricevuta, conferma autorevole ancora in attesa.');return;
     }
     if(result.next_retry_same_key!==true)throw Error('Avanzamento della chiusura non confermato.');
    }
    throw Error('Limite dei sei passi raggiunto. Verifica la stessa richiesta.');
   }catch(e){if(same()){
    // Only this exact first-call terminal veto is before the Native event and writes.
    if(!recover&&attemptedNative===1&&h.closeJournal?.completed===0&&e.code==='55000'&&String(e.message).includes('MC_TERMINAL_STEP_REQUIRED')){try{sessionStorage.removeItem(key);if(sessionStorage.getItem(key)!==null)throw Error('Recupero locale non confermato.');h.closeJournal=null;signal();}catch(storage){h.closeError=storage.message;signal();}}
    h.closeMessage='Chiusura non confermata. '+e.message;status.textContent=h.closeMessage;
    if(h.closeJournal?.status==='pending')signal();}}
   finally{h.closeRunning=false;h.busy=false;signal();if(same()){h.signature='';await mountHuman(host,h.session,h.closeContext);}}
  }
  if(pending){const b=button('Verifica la stessa chiusura',()=>run(true));b.setAttribute('data-mc-close-recovery','');b.disabled=!!h.closeError;controls.append(b);}
  else if(!h.closeError&&state.closed!==true){const b=button('Chiudi attività',()=>run(false));b.disabled=!!eligibilityError||blocked();controls.append(b);}
  if(h.closeError){const b=button('Rileggi recupero locale',()=>{h.closeError=null;h.signature='';mountHuman(host,h.session,h.closeContext);},true);b.setAttribute('data-mc-close-recovery','');controls.append(b);}
  signal();
 }

 async function mountHuman(host,session,closeContext=null){
  syncIdentity();const user=identity(),stamp=epoch;
  if(!host)return {status:'unconfigured',master_session_id:null};styles();
  if(!user||!UUID.test(session||'')){humans.delete(host);host.replaceChildren();host.hidden=true;return {status:'unconfigured',master_session_id:null};}
  const fatoKey='mission-human-fato/1:'+user+':'+session;
  const saveFato=pending=>{try{const raw=pending?JSON.stringify(pending):null;if(raw)sessionStorage.setItem(fatoKey,raw);else sessionStorage.removeItem(fatoKey);return sessionStorage.getItem(fatoKey)===raw;}catch{return false;}};
  const loadFato=()=>{try{const p=JSON.parse(sessionStorage.getItem(fatoKey)||'null');if(p===null)return null;if(Object.keys(p).sort().join(',')!=='p_body,p_event,p_request,p_session'||p.p_session!==session||!UUID.test(p.p_event||'')||!UUID.test(p.p_request||'')||typeof p.p_body!=='string'||p.p_body.length<1||p.p_body.length>5000)throw Error('Recupero Fato invalido.');return p;}catch{throw Error('Recupero del Fato non verificabile.');}};
  let h=humans.get(host);if(!h||h.session!==session||h.user!==user){h={session,user,signature:'',busy:false,pending:null,fatoPending:loadFato(),fatoDraft:'',readPromise:null,result:null};humans.set(host,h);host.replaceChildren();host.hidden=true;}
  const actionKey='mission-human-action/1:'+user+':'+session;
  const validateAction=p=>{const keys=p?.p_action==='close_noncombat'?'p_action,p_body,p_expected_version,p_request,p_session,p_trigger_key':'p_action,p_expected_version,p_request,p_session,p_trigger_key';if(!p||Object.keys(p).sort().join(',')!==keys||p.p_session!==session||!positive(p.p_expected_version)||!UUID.test(p.p_request||'')||!['advance','open_encounter','close_noncombat'].includes(p.p_action)||(p.p_trigger_key!==null&&typeof p.p_trigger_key!=='string')||(p.p_action==='close_noncombat'&&(typeof p.p_body!=='string'||p.p_body.length<20||p.p_body.length>5000)))throw Error('Richiesta Human originale non verificabile.');return p;};
  const saveAction=p=>{const raw=p?JSON.stringify({schema:'mission-human-action/1',user,session,args:validateAction(p)}):null;if(raw===null)sessionStorage.removeItem(actionKey);else sessionStorage.setItem(actionKey,raw);if(sessionStorage.getItem(actionKey)!==raw)throw Error('Recupero Human non confermato.');h.pending=p?copy(p):null;};
  try{const raw=sessionStorage.getItem(actionKey);if(raw){const v=JSON.parse(raw);if(v.schema!=='mission-human-action/1'||v.user!==user||v.session!==session)throw Error('Identità del recupero Human non verificabile.');h.pending=validateAction(v.args);}}catch(e){h.closeError=e.message;}
  h.closeContext=closeContext||h.closeContext;
  if(h.closeContext){try{const saved=sessionStorage.getItem(closePrefix(user)+session);h.closeJournal=saved?validateCloseJournal(JSON.parse(saved),user,session):null;}catch(e){h.closeError=e.message;}h.closeContext.lock({session,args:h.closeJournal?.status==='pending'?copy(h.closeJournal.args):null,blocked:!!h.closeError||h.closeJournal?.status==='pending'||h.closeRunning===true,busy:h.busy});}
  if(!h.closeContext||typeof h.closeContext.current!=='function'||typeof h.closeContext.lock!=='function'||typeof h.closeContext.externalBusy!=='function'||!h.closeContext.current()||((h.closeContext.masterView!==true||h.closeContext.viewer?.is_master!==true||h.closeContext.master?.id!==session)&&h.closeJournal?.status!=='pending')){h.signature='';host.replaceChildren();host.hidden=true;return {status:'unconfigured',master_session_id:session,master_view:false};}
  if(h.readPromise)return h.readPromise;if(h.busy)return {...(h.result||{status:'error',master_session_id:session}),pending:true};
  const capturedContext=h.closeContext;
  const same=()=>humans.get(host)===h&&host.isConnected&&valid(user,stamp)&&!!capturedContext&&capturedContext.current()&&h.closeContext?.masterView===capturedContext.masterView&&h.closeContext?.master?.id===capturedContext.master?.id;
  const canWrite=()=>same()&&h.closeContext.masterView===true&&h.closeContext.viewer?.is_master===true&&h.closeContext.master?.id===session&&!h.closeContext.externalBusy()&&h.closeContext.master.suspended_at===null;
  const stale=()=>({status:'error',master_session_id:session,stale:true});
  function showError(error){
   if(!same())return stale();const denied=error?.code==='42501',sig='error:'+String(error?.code||'read');
   if(h.signature!==sig){host.replaceChildren();host.hidden=false;host.classList.add('mc-human');host.append(node('p',denied?'Non hai più il permesso di leggere questa regia. I contenuti riservati sono stati rimossi.':'Impossibile leggere le fasi della missione. Aggiorna per riprovare; i comandi precedenti restano sospesi.',{class:'mc-status',role:'status'}),button('Aggiorna fase',()=>{h.signature='';mountHuman(host,session,h.closeContext);},true));}
   h.signature=sig;h.result={status:'error',master_session_id:session,permission_denied:denied};return h.result;
  }
  h.readPromise=(async()=>{
   try{const state=await rpc('mission_human_phase_state_v1',{p_session:session},user,stamp);if(!same())return stale();
    if(state===null){host.replaceChildren();host.hidden=true;h.signature='';h.result={status:'unconfigured',master_session_id:session};return h.result;}
    if(state?.schema_version==='quest-human-runtime-state/1'&&state.native_session_id===session){host.replaceChildren();host.hidden=true;h.signature='';h.result={status:'unconfigured',master_session_id:session,consumer:'human-quest-runtime-ui'};return h.result;}
    if(!['mission-human-phase-state/1'].includes(state?.schema_version)||state.master_session_id!==session||typeof state.closed!=='boolean'||!Array.isArray(state.transitions)||state.transitions.some(t=>!t||typeof t.trigger_key!=='string'||typeof t.label!=='string'))throw Error('Stato delle fasi non disponibile.');
    if(h.closeContext.masterView!==true||h.closeContext.viewer?.is_master!==true||h.closeContext.master?.id!==session){host.replaceChildren();host.hidden=false;await humanCloseControls(host,h,state,h.closeContext,user,stamp,same);h.result={status:'ready',master_session_id:session,closed:state.closed===true,session_state:state.session_state||null,recovery_only:true};return h.result;}
    const fato=state.pending_fato?.schema==='mission-human-fato/1'&&UUID.test(state.pending_fato.event_id||'')?state.pending_fato:null;
    if(state.awaiting_fato===true&&!fato)throw Error('Il fatto da narrare non è disponibile: aggiorna la fase.');
    // La ricevuta perduta viene riconciliata tramite lo stesso p_request, anche oltre la fase.
    h.result={status:'ready',master_session_id:session,session_state:state.session_state||null,closed:state.closed===true,awaiting_fato:state.awaiting_fato===true};
    const signature=JSON.stringify([state,h.pending,h.fatoPending,h.lastError||'',h.closeJournal,h.closeError||'',h.closeContext?.masterView,h.closeContext?.master?.control_version]);if(signature===h.signature)return h.result;const wasOpen=host.querySelector('[data-mc-human-phases]')?.open||false;h.signature=signature;host.replaceChildren();host.hidden=false;host.classList.add('mc-human');const panel=node('details',null,{'data-mc-human-phases':''});panel.open=wasOpen;panel.append(node('summary','Fasi e note della missione'));const content=node('div',null);panel.append(content);host.append(panel);content.append(node('h3',state.closed===true?'Missione conclusa':'Missione · fase corrente'),node('p',state.objective||state.step_key||''));humanContext(content,state.director_context);
    if(Number.isSafeInteger(state.roster_count))content.append(node('p','PG della squadra: '+state.roster_count+(state.roster_ready===true?' · squadra confermata':state.roster_ready===false?' · conferma in attesa':''),{class:'mc-help'}));
    if(state.roster_ready===false||state.blocked_reason){const reasons={'Serve il roster confermato della missione.':'Conferma la squadra della missione con il numero di PG previsto dalle iscrizioni.',MC_CONFIRMED_ROSTER_REQUIRED:'La squadra non è ancora confermata. Completa le iscrizioni e la conferma previste per questa missione.',confirmed_roster_required:'La squadra non è ancora confermata. Completa le iscrizioni e la conferma previste per questa missione.',roster_not_ready:'La squadra non è ancora pronta per iniziare.'};const raw=typeof state.blocked_reason==='string'?state.blocked_reason:'';content.append(node('p',reasons[raw]||raw||'Avvio in attesa della conferma della squadra.',{class:'mc-status',role:'status'}));}
    const status=node('p',h.lastError|| (h.fatoPending?'Il Fato non è ancora confermato. Verifica la stessa pubblicazione.':h.pending?'Un comando non è ancora confermato. Verifica lo stesso comando prima di procedere.':''),{class:'mc-status',role:'status','aria-live':'polite'}),actions=node('div',null,{class:'mc-actions'});content.append(status,actions);
     async function publishFato(){
      if(!canWrite()||h.closeError||h.closeJournal?.status==='pending'||h.busy||h.pending||(!h.fatoPending&&(!fato||fato.can_publish!==true)))return;
      if(!h.fatoPending){if(state.closed===true||state.master_control_version!==h.closeContext.master.control_version)return;const body=(h.fatoDraft||'').trim();if(body.length<1||body.length>5000){status.textContent='Scrivi un Fato di 1–5000 caratteri.';return;}
       const pending={p_session:session,p_event:fato.event_id,p_body:body,p_request:uuid()};
       if(!saveFato(pending)){status.textContent='Impossibile conservare la richiesta nel browser. La pubblicazione è sospesa.';return;}h.fatoPending=pending;}
      h.busy=true;host.querySelectorAll('button').forEach(b=>b.disabled=true);status.textContent='Pubblicazione del Fato in corso…';
      try{const receipt=await rpc('mission_human_fato_publish_v1',copy(h.fatoPending),user,stamp);if(!same())return;
       if(receipt?.schema!=='mission-human-fato-publication/1'||receipt.status!=='published'||receipt.event_id!==h.fatoPending.p_event||receipt.request_key!==h.fatoPending.p_request||!UUID.test(receipt.publication_id||'')||!UUID.test(receipt.message_id||''))throw Error('Ricevuta del Fato non verificabile.');
       if(!saveFato(null))throw Error('Ricevuta ricevuta; recupero locale ancora da riconciliare.');h.fatoPending=null;h.fatoDraft='';h.lastError='';h.signature='';refresh();
      }catch(e){if(!same())return;h.lastError='Pubblicazione non confermata. Verifica la stessa richiesta. '+e.message;if(e.code==='42501')showError(e);else status.textContent=h.lastError;}
      finally{h.busy=false;if(same()){h.signature='';await mountHuman(host,session,h.closeContext);}}
     }
    if(state.awaiting_fato===true){
     const box=card('Fato del Master'),draft=text(h.fatoPending?.p_body||h.fatoDraft||'',v=>{h.fatoDraft=v;},5000);
     draft.setAttribute('aria-label','Racconto del Fato dopo la prova');draft.style.cssText='width:100%;min-height:120px;padding:9px 11px;border:1px solid var(--rule,#8a6f43);border-radius:7px;background:rgba(255,252,244,.8);color:var(--ink,#1d1206);font:600 18px/1.5 Georgia,serif;resize:vertical';draft.disabled=!!h.pending||!!h.fatoPending||fato?.can_publish!==true;
     box.append(node('p','Il fatto della prova è pronto. Racconta l’esito ai giocatori: la fase successiva si aprirà dopo la pubblicazione del Fato.'),field('Testo del Fato',draft));
     const mismatch=!!h.fatoPending&&h.fatoPending.p_event!==fato?.event_id;
     if(mismatch){box.append(node('p','Una pubblicazione precedente è ancora da verificare. Usa la stessa richiesta prima di raccontare il fatto corrente.',{class:'mc-status',role:'status'}),button('Verifica pubblicazione precedente',publishFato));}
     else if(h.fatoPending||fato?.can_publish===true)box.append(button(h.fatoPending?'Verifica la stessa pubblicazione':'Pubblica Fato',publishFato));
     else box.append(node('p','La pubblicazione è in attesa dell’autorizzazione del server.',{class:'mc-status',role:'status'}));
     content.insertBefore(box,status);
    }else if(h.fatoPending){
     const recovery=card('Verifica Fato precedente'),saved=text(h.fatoPending.p_body,()=>{},5000);
     saved.setAttribute('aria-label','Testo del Fato già inviato');saved.style.cssText='width:100%;min-height:100px;padding:9px 11px;border:1px solid var(--rule,#8a6f43);border-radius:7px;background:rgba(255,252,244,.8);color:var(--ink,#1d1206);font:600 18px/1.5 Georgia,serif;resize:vertical';saved.disabled=true;
     recovery.append(node('p','La fase è cambiata, ma la ricevuta della pubblicazione precedente non è stata confermata in questo browser. Verifica la richiesta originale senza crearne una nuova.'),field('Testo già inviato',saved),button('Verifica la stessa pubblicazione',publishFato));
     content.insertBefore(recovery,status);
    }
    async function closePeacefully(){
     if(!canWrite()||h.closeError||h.closeJournal?.status==='pending'||h.busy||(state.awaiting_fato===true&&!h.pending)||h.fatoPending)return;const body=(h.closeDraft||'').trim();if(!h.pending){if(state.closed===true||state.can_close_noncombat!==true||state.master_control_version!==h.closeContext.master.control_version)return;if(body.length<20||body.length>5000){status.textContent='Scrivi un esito del Fato di 20–5000 caratteri.';return;}h.pending={p_action:'close_noncombat',p_session:session,p_expected_version:state.control_version,p_trigger_key:state.peaceful_trigger_key,p_body:body,p_request:uuid()};}
     if(h.pending.p_action!=='close_noncombat')return;try{saveAction(h.pending);}catch(e){h.closeError=e.message;status.textContent=e.message;return;}h.busy=true;host.querySelectorAll('button').forEach(b=>b.disabled=true);status.textContent='Pubblicazione dell’esito e chiusura in corso…';
     try{const args={p_session:h.pending.p_session,p_expected_version:h.pending.p_expected_version,p_trigger_key:h.pending.p_trigger_key,p_body:h.pending.p_body,p_request:h.pending.p_request};await rpc('mission_human_combat_close_peaceful_v1',args,user,stamp);if(!same())return;saveAction(null);h.closeDraft='';h.lastError='';h.signature='';refresh();}
     catch(e){if(!same())return;if(e.code&&(/^(22|23)/.test(e.code)||['42501','40001','55000','P0001'].includes(e.code))){try{saveAction(null);}catch(storage){h.closeError=storage.message;}}h.lastError='Chiusura non confermata. '+e.message;if(e.code==='42501')showError(e);else status.textContent=h.lastError;}
     finally{h.busy=false;if(same()){h.signature='';await mountHuman(host,session,h.closeContext);}}
    }
    if(state.awaiting_fato!==true&&((state.can_close_noncombat===true&&!h.pending)||h.pending?.p_action==='close_noncombat')){
     const closeBox=card('Chiusura senza conflitto'),draft=text(h.pending?.p_body||h.closeDraft||'',v=>{h.closeDraft=v;},5000);draft.setAttribute('aria-label','Esito del Fato che chiude l’incontro');draft.style.cssText='width:100%;min-height:110px;padding:9px 11px;border:1px solid var(--rule,#8a6f43);border-radius:7px;background:rgba(255,252,244,.8);color:var(--ink,#1d1206);font:500 17px/1.4 Georgia,serif;resize:vertical';closeBox.append(node('p','Scrivi come si conclude l’incontro. Il server pubblicherà questo Fato e aprirà la fase narrativa successiva con un solo comando.'),field('Esito del Fato',draft),status,button(h.pending?.p_action==='close_noncombat'?'Verifica la stessa chiusura':'Pubblica Fato e chiudi scontro',closePeacefully));host.prepend(closeBox);
    }
    async function act(action,trigger=null){if(!canWrite()||h.closeError||h.closeJournal?.status==='pending'||h.busy||(state.awaiting_fato===true&&!h.pending)||h.fatoPending)return;if(!h.pending&&(state.closed===true||state.master_control_version!==h.closeContext.master.control_version||(!['advance','open_encounter'].includes(action))||(action==='open_encounter'&&state.can_open_encounter!==true)||(action==='advance'&&!state.transitions.some(t=>t.trigger_key===trigger))))return;if(!h.pending)h.pending={p_session:session,p_expected_version:state.control_version,p_action:action,p_trigger_key:trigger,p_request:uuid()};try{saveAction(h.pending);}catch(e){h.closeError=e.message;status.textContent=e.message;return;}h.busy=true;host.querySelectorAll('button').forEach(b=>b.disabled=true);status.textContent='Esecuzione del comando…';
     try{await rpc('mission_human_phase_action_v1',copy(h.pending),user,stamp);if(!same())return;saveAction(null);h.lastError='';h.signature='';refresh();}
     catch(e){if(!same())return;if(e.code&&(/^(22|23)/.test(e.code)||['42501','40001','55000','P0001'].includes(e.code))){try{saveAction(null);}catch(storage){h.closeError=storage.message;}}h.lastError='Comando non confermato. '+e.message;if(e.code==='42501')showError(e);else status.textContent=h.lastError;}
     finally{h.busy=false;if(same()){h.signature='';await mountHuman(host,session,h.closeContext);}}
    }
    if(state.awaiting_fato===true){if(h.pending)actions.append(button('Verifica lo stesso comando precedente',()=>h.pending.p_action==='close_noncombat'?closePeacefully():act(h.pending.p_action,h.pending.p_trigger_key)));} // Solo replay originale; nessuna nuova intenzione oltre la barriera.
    else if(h.pending?.p_action==='close_noncombat'){}
    else if(h.pending)actions.append(button('Verifica lo stesso comando',()=>act(h.pending.p_action,h.pending.p_trigger_key)));
    else{if(state.can_open_encounter===true)actions.append(button('Apri lo scontro della fase',()=>act('open_encounter')));for(const t of state.transitions){if(typeof t.trigger_key==='string'&&typeof t.label==='string')actions.append(button(t.label,()=>act('advance',t.trigger_key)));}}
    actions.append(button('Aggiorna fase',()=>{h.signature='';mountHuman(host,session,h.closeContext);},true));
    await humanCloseControls(host,h,state,h.closeContext,user,stamp,same);
    if(h.closeError||h.closeJournal?.status==='pending')for(const b of host.querySelectorAll('button:not([data-mc-close-recovery])'))b.disabled=true;
    return h.result;
   }catch(e){return showError(e);}
  })().finally(()=>{h.readPromise=null;});return h.readPromise;
 }

 function mountD100(host,session,{characterId=()=>null,labels={},isCurrent=()=>true,viewerMode='player',locationId=currentLocation()?.id,ensureFato=async()=>false,onState=()=>{},onError=()=>{}}={}){
  syncIdentity();const user=identity(),stamp=epoch;if(!host?.isConnected||!UUID.test(session||'')||!user)throw Error('Contesto D100 non disponibile.');
  d100Views.get(host)?.dispose();const panel=mountMissionD100Runtime(host,{session,identity,characterId,labels,viewerMode,locationId,ensureFato,onState,onError,
   isCurrent:()=>valid(user,stamp)&&isCurrent(),rpc:(name,args)=>rpc(name,args,user,stamp)});
  d100Views.set(host,panel);void panel.refresh();return panel;
 }
 async function routeBoard(mission,title=''){
  syncIdentity();if(!isStaff()||!identity()||!UUID.test(mission||''))return false;const user=identity(),stamp=epoch;
  const meta=await rpc('mission_creation_editor_v1',{p_mission:mission,p_plan_version:null},user,stamp);if(!valid(user,stamp))return true;
  if(meta?.schema_version!=='mission-creation-editor/1')throw Error('Modalità della missione non disponibile.');if(!['ai','human'].includes(meta.mission?.direction_mode))throw Error('Modalità della missione non disponibile.');if(meta.mission.direction_mode!=='human')return false;
  styles();if(currentDialog){currentDialog.close();currentDialog.remove();}const d=node('dialog',null,{class:'mc-dialog mc-editor','aria-label':'Missione con Master umano'});currentDialog=d;
  d.append(button('Chiudi',()=>d.close(),true),node('h2','Master umano · '+title));const status=node('p','',{role:'status',class:'mc-status'}),area=node('div',null);d.append(status,area);document.body.append(d);d.addEventListener('close',()=>{d.remove();if(currentDialog===d)currentDialog=null;});d.showModal();
  const loc=currentLocation(),same=()=>d.isConnected&&valid(user,stamp)&&currentLocation()?.id===loc?.id;
  if(!meta.configured){status.textContent='Completa prima la configurazione della missione.';area.append(button('Configura missione',()=>editor(mission,title)));return true;}
  if(!loc){status.textContent='Entra nella chat di ritrovo della missione per avviarla.';return true;}
  if(!loc.is_test){
   status.textContent='L’avvio segue la Regia Master nativa: il Master rimane il tuo utente e non viene attivata alcuna regia IA.';
   if(meta.mission.gathering_location_id&&meta.mission.gathering_location_id!==loc.id){area.append(node('p','Entra nella chat di ritrovo selezionata per questa missione.'));return true;}
   area.append(button('Apri Regia Master',()=>{if(!same())return;d.close();openNativeMaster(mission);}));return true;
  }
  if(loc.id!=='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'){
   status.textContent='Questa preparazione è disponibile nella sola Staff Test Room.';return true;
  }
  status.textContent='Prova protetta con Master umano. Scegli da 1 a 4 PG presenti; il server verifica stanza, roster e risorse di prova.';
  const key=user+':'+mission+':'+loc.id,storeKey='mission-human-staff-start/5/'+key;
  const startReceipt=r=>r?.schema_version==='mission-human-test-start/1'&&UUID.test(r.master_session_id||'')&&r.source_mission_id===mission&&r.simulation===true&&r.direction_mode==='human';
  const optinReceipt=(r,p)=>!!p&&r?.schema_version==='regia-round-optin/1'&&r.status==='reserved'&&r.master_session_id===p.p_master_session&&r.request_key===p.p_request_key;
  let run=humanStarts.get(key);
  const saveRun=()=>{
   if(!same())throw Error('Accesso o stanza cambiati: riapri la preparazione.');
   const saved=JSON.stringify({schema_version:'mission-human-staff-start/5',user,mission,location:loc.id,
    request:run.request,roster:run.roster,result:run.result,optin:run.optin,optin_receipt:run.optinReceipt});
   try{sessionStorage.setItem(storeKey,saved);if(sessionStorage.getItem(storeKey)!==saved)throw Error('storage');}
   catch{throw Error('Recupero della preparazione non salvato: nessuna ulteriore richiesta può essere inviata.');}
  };
  try{
   if(!run){const raw=sessionStorage.getItem(storeKey);if(raw){const saved=JSON.parse(raw);
    if(saved?.schema_version!=='mission-human-staff-start/5'||saved.user!==user||saved.mission!==mission||saved.location!==loc.id||
       !UUID.test(saved.request||'')||!Array.isArray(saved.roster)||saved.roster.length<1||saved.roster.length>4||
       saved.roster.some(x=>!UUID.test(x||''))||new Set(saved.roster).size!==saved.roster.length||
       (saved.result!==null&&!startReceipt(saved.result))||
       (saved.optin!==null&&(!saved.result||saved.optin.p_master_session!==saved.result.master_session_id||!UUID.test(saved.optin.p_request_key||'')))||
       (saved.optin_receipt!==null&&!optinReceipt(saved.optin_receipt,saved.optin)))throw Error('Recupero della preparazione non verificabile.');
    run={request:saved.request,roster:copy(saved.roster),picks:new Set(saved.roster),result:saved.result,
     optin:saved.optin,optinReceipt:saved.optin_receipt,busy:false};humanStarts.set(key,run);
   }}
  }catch(e){status.textContent='Impossibile recuperare la preparazione precedente. Nessun nuovo avvio è consentito. '+e.message;return true;}
  async function readPreparation(){
   const previous=await rpc('mission_human_phase_state_v1',{p_session:run.result.master_session_id},user,stamp);
   if(!same())throw Error('Accesso o stanza cambiati.');
   if(previous?.schema_version!=='mission-human-phase-state/1'||previous.master_session_id!==run.result.master_session_id||typeof previous.closed!=='boolean'||
      !['preparazione','in_corso','chiusa','annullata'].includes(previous.session_state))throw Error('Stato della prova precedente non confermato.');
   return previous;
  }
  if(run?.result){
   status.textContent='Verifica dello stato della prova precedente…';
   try{const previous=await readPreparation();
    if(previous.closed===true){if(!['chiusa','annullata'].includes(previous.session_state))throw Error('Chiusura della prova precedente non confermata.');
     // Rimuove soltanto il puntatore di recupero alla propria prova terminale; storico server intatto.
     sessionStorage.removeItem(storeKey);run=null;humanStarts.delete(key);status.textContent='La prova precedente è chiusa. Scegli la squadra per una nuova prova protetta.';
    }
   }catch(e){if(same()){status.textContent='Impossibile confermare lo stato della prova precedente. Un nuovo avvio resta disabilitato. '+e.message;area.append(button('Aggiorna stato della prova',()=>routeBoard(mission,title),true));}return true;}
  }
  if(!run){run={request:null,roster:null,picks:new Set(),busy:false,result:null,optin:null,optinReceipt:null};humanStarts.set(key,run);}
  const roster=node('fieldset',null),actions=node('div',null,{class:'mc-actions'}),preparation=node('div',null);area.append(roster,actions,preparation);
  const openConfirmed=()=>{if(!same()||run.busy||!startReceipt(run.result)||!optinReceipt(run.optinReceipt,run.optin))return;d.close();openNativeMaster(mission);};
  const drawPreparation=()=>{
   preparation.replaceChildren();if(!run.result)return;
   if(optinReceipt(run.optinReceipt,run.optin)){
    status.textContent='Preparazione della Regia confermata. Puoi proseguire nella stanza.';
    preparation.append(button('Apri Regia Master',openConfirmed));
   }else{
    status.textContent='Prova creata; preparazione della Regia non ancora confermata. Non avviare una seconda prova.';
    const confirm=button(run.optin?'Conferma la stessa preparazione':'Conferma preparazione Regia',()=>confirmOptin());confirm.disabled=run.busy;preparation.append(confirm);
   }
  };
  async function confirmOptin(){
   if(!same()||run.busy||!startReceipt(run.result)||optinReceipt(run.optinReceipt,run.optin))return;
   run.busy=true;start.disabled=true;preparation.querySelectorAll('button').forEach(b=>b.disabled=true);
   try{
    saveRun(); // Anche la receipt start deve essere durevole prima di qualsiasi passo successivo.
    // La cattura server start→session_open lascia la nuova sessione in preparazione.
    // Il reader conferma lo stato; la RPC optin verifica anche l'assenza di encounter.
    const previous=await readPreparation();
    if(previous.closed||previous.session_state!=='preparazione')throw Error('La sessione non è più in preparazione. La richiesta resta conservata; aggiorna lo stato con lo Staff.');
    run.optin??={p_master_session:run.result.master_session_id,p_request_key:uuid()};
    if(run.optin.p_master_session!==run.result.master_session_id)throw Error('Sessione di recupero differente.');
    saveRun();status.textContent='Conferma della preparazione Regia…';
    const receipt=await rpc('regia_round_human_optin_v1',copy(run.optin),user,stamp);
    if(!same())return;
    if(!optinReceipt(receipt,run.optin))throw Error('Ricevuta della preparazione non verificabile.');
    // Solo una conferma salvata abilita l'apertura; errore storage conserva la UUID per il replay.
    const old=run.optinReceipt;run.optinReceipt=copy(receipt);
    try{saveRun();}catch(e){run.optinReceipt=old;throw e;}
    refresh();
   }catch(e){if(same())status.textContent='Preparazione non confermata. Conserva la stessa sessione e richiesta. '+e.message;}
   finally{run.busy=false;if(same()){const message=status.textContent;drawPreparation();if(!optinReceipt(run.optinReceipt,run.optin))status.textContent=message;start.disabled=!!run.result;}}
  }
  const start=button(run.request?'Verifica lo stesso avvio':'Avvia prova protetta',async()=>{
   if(!same()||run.busy||run.result)return;
   if(!run.request){if(run.picks.size<1||run.picks.size>4)return;run.request=uuid();run.roster=[...run.picks];}
   run.busy=true;start.disabled=true;roster.disabled=true;status.textContent='Avvio della prova protetta…';
   let startStored=false;
   try{
    saveRun();
    const receipt=await rpc('mission_human_staff_test_start_v1',{p_source_mission:mission,p_location:loc.id,p_roster:copy(run.roster),p_request:run.request},user,stamp);
    if(!same())return;
    if(!startReceipt(receipt))throw Error('Avvio non confermato.');
    run.result=copy(receipt);saveRun();startStored=true;refresh();
   }catch(e){if(same())status.textContent='Avvio non confermato. Conserva lo stesso avvio, senza aprire una seconda prova. '+e.message;}
   finally{run.busy=false;if(same()){start.textContent=run.request?'Verifica lo stesso avvio':'Avvia prova protetta';start.disabled=!!run.result||(!run.request&&(run.picks.size<1||run.picks.size>4));}}
   if(same()&&run.result){const message=status.textContent;drawPreparation();if(startStored)await confirmOptin();else status.textContent=message;}
  });start.disabled=true;actions.append(start,button('Aggiorna avvio',()=>routeBoard(mission,title),true));
  try{const characters=await presentCharacters();if(!same())return true;
   for(const c of characters){if(!UUID.test(c.id||''))continue;roster.append(check(c.name,run.picks.has(c.id),on=>{if(run.request)return;if(on)run.picks.add(c.id);else run.picks.delete(c.id);start.disabled=run.picks.size<1||run.picks.size>4;}));}
   if(!characters.length)roster.append(node('p','Nessun PG presente nella stanza.'));
   roster.disabled=!!run.request;start.disabled=run.busy||!!run.result||(!run.request&&(run.picks.size<1||run.picks.size>4));drawPreparation();
  }catch(e){if(same())status.textContent='Elenco dei presenti non disponibile. '+e.message;}
  return true;
 }
 function mountDraftVariant(host,{draft_id,mode,model,existing=null,catalog,profiles,factorySource=null,factoryCatalog=null,factoryD100Projections=[]}={}){
  if(!host?.isConnected||!UUID.test(draft_id||'')||!['ai','human'].includes(mode)||
     !catalog||!Array.isArray(catalog.locations)||!Array.isArray(catalog.modes)||!catalog.modes.includes(mode)||
     !Number.isInteger(catalog.team_min)||!Number.isInteger(catalog.team_max)||
     !profiles||!Array.isArray(profiles.mechanical_profiles)||!Array.isArray(profiles.narrative_profiles)||
     (!model&&!existing)||factorySource?.schema_version!=='mission-factory-draft/1'||
     factoryCatalog?.event_projection_version!=='mission-factory-native-event/1'||
     !isStaff()||!identity())throw Error('Catalogo o modello di variante non qualificato.');
  for(const pending of [...drafts])if(pending.host===host)pending.finish(null);
  const loaded=existing?loadMissionDraftDocument(existing):copy(model);
  if(!loaded?.mission||!Array.isArray(loaded.scenes)||!Array.isArray(loaded.actors))throw Error('Modello variante incompleto.');
  loaded.mission.direction_mode=mode;
  return new Promise((resolve,reject)=>{
   let done=false;const draft={host,mode,catalog:copy(catalog),profiles:copy(profiles),model:loaded,
    factorySource:factorySource?copy(factorySource):null,factoryCatalog:factoryCatalog?copy(factoryCatalog):null,factoryD100Projections:copy(factoryD100Projections),finish:result=>{
    if(done)return;done=true;drafts.delete(draft);views.delete(host);host.replaceChildren();resolve(result);
   }};drafts.add(draft);
   void prepare(host,{draft}).catch(e=>{draft.finish(null);reject(e);});
  });
 }
 return {mountNewNativeVariantForm,mountExistingVariantForm,mountCreate,editor,mountHuman,mountD100,routeBoard,mountDraftVariant,pendingHumanCloseSession,dispose:()=>clear(),version:VERSION};
}
