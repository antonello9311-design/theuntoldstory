export const VERSION='mission-generic-ui/1.1';
const id=()=>crypto.randomUUID();
const clone=x=>structuredClone(x);
const el=(tag,text,attrs={})=>{const n=document.createElement(tag);if(text!==null)n.textContent=text;for(const [k,v]of Object.entries(attrs))n.setAttribute(k,v);return n;};
const button=(label,fn)=>{const n=el('button',label,{type:'button',class:'mbtn'});n.addEventListener('click',fn);return n;};
const input=(value,onchange,type='text')=>{const n=el('input',null,{type});n.value=value??'';n.addEventListener('input',()=>onchange(n.value));return n;};
const select=(items,value,onchange)=>{const n=el('select',null);for(const x of items){const o=el('option',x.label,{value:x.value});n.append(o);}n.value=value??'';n.addEventListener('change',()=>onchange(n.value));return n;};
const field=(label,n)=>{const l=el('label',label,{class:'mg-field'});l.append(n);return l;};
let styled=false;
function style(){if(styled)return;styled=true;const n=el('style',null);n.textContent=`
.mg-dialog{width:min(1060px,94vw);max-height:90dvh;box-sizing:border-box;border:1px solid #8e8669;border-radius:12px;padding:20px;background:#f2eee1;color:#252923;overflow:auto}
.mg-dialog::backdrop{background:#0009}.mg-dialog button,.mg-dialog input,.mg-dialog select,.mg-dialog textarea{font:inherit;padding:8px;border-radius:6px;border:1px solid #8e8669;max-width:100%;box-sizing:border-box}.mg-dialog button{cursor:pointer}.mg-dialog button:disabled{opacity:.55;cursor:wait}.mg-dialog textarea{width:100%;min-height:80px}.mg-field{display:flex;flex-direction:column;gap:5px;margin:8px 0}.mg-row{display:flex;flex-wrap:wrap;align-items:end;gap:10px}.mg-row>.mg-field{flex:1;min-width:160px}.mg-scene{border:1px solid #b8b09c;border-radius:8px;padding:14px;margin:12px 0;background:#fff9}.mg-status{min-height:1.4em}.mg-dialog h3,.mg-dialog h4{margin:8px 0}.mg-room{padding:10px 14px;border:1px solid #a89a75;border-radius:8px;margin:8px 0}.mg-room [role=status]{margin:4px 0}.mg-room button{margin:4px}.mg-dialog summary{cursor:pointer;font-weight:bold}.mg-inline-check{display:inline-flex;align-items:center;gap:5px;margin:5px 12px 5px 0}
`;document.head.append(n);}

export function createMissionUI({client,identity,isStaff,currentLocation,presentCharacters=async()=>[],notice=()=>{},refresh=()=>{}}){
 let currentDialog=null,roomBusy=false,roomEpoch=0,roomSignature='',roomState=null;
 const dispatched=new Set();
 const valid=(user)=>!!user&&identity()===user;
 async function rpc(name,args,user=identity()){
  if(!valid(user))throw Error('Accedi nuovamente per continuare.');
  const r=await client.rpc(name,args);if(!valid(user))throw Error('Sessione cambiata.');
  if(r.error)throw Error(r.error.message||'Operazione non confermata.');return r.data;
 }
 function dialog(title){style();if(currentDialog){currentDialog.close();currentDialog.remove();}
  const d=el('dialog',null,{class:'mg-dialog','aria-label':title});const top=el('div',null,{class:'mg-row'});
  top.append(el('h3',title),button('Chiudi',()=>d.close()));d.append(top);document.body.append(d);d.addEventListener('close',()=>{d.remove();if(currentDialog===d)currentDialog=null;});d.showModal();currentDialog=d;return d;
 }
 async function editor(mission,title,requestedRevision=null){
  if(!isStaff())return;const user=identity(),d=dialog('Regia IA · '+title),status=el('p','Caricamento configurazione…',{class:'mg-status',role:'status'});d.append(status);
  try{
   let [catalog,profiles]=await Promise.all([rpc('mission_generic_plan_catalog_v1',{p_mission:mission},user),rpc('mission_generic_editor_v1',{p_plan_version:null},user)]);
   if(!d.isConnected)return;
   const revisions=catalog.versions.filter(x=>x.generic_ready).sort((a,b)=>b.version-a.version);
   const latest=requestedRevision?revisions.find(x=>x.plan_version_id===requestedRevision):revisions[0];
   if(requestedRevision&&!latest)throw Error('Revisione non disponibile: riapri il catalogo.');
   let base=null,scenes=[],actors=[],counter=1,selected=catalog.selected_plan_version_id;
   if(latest){
    const detail=await rpc('mission_generic_editor_v1',{p_plan_version:latest.plan_version_id},user);
    base=revisions.find(x=>x.plan_id===latest.plan_id)?.plan_version_id||latest.plan_version_id;
    const def=detail.definitions.find(x=>x.id===latest.definition_id)?.definition;if(!def)throw Error('Definizione della revisione non disponibile.');
    if(def.scenes.some(s=>s.triggers.some(t=>!['player_choice','combat_terminal'].includes(t.source_kind))))throw Error('Questa revisione usa eventi automatici specializzati: la modifica va completata dal relativo editor.');
    const actorMap=new Map();for(const s of def.scenes)for(const a of s.actors)if(!actorMap.has(a.actor_key))actorMap.set(a.actor_key,clone(a));actors=[...actorMap.values()];
    scenes=detail.plan.steps.map((s)=>{const cfg=def.scenes.find(x=>x.step_key===s.step_key);if(!cfg)throw Error('Configurazione di una fase mancante.');return {...s,actors:cfg.actors.map(x=>x.actor_key),actor_specs:Object.fromEntries(cfg.actors.map(x=>[x.actor_key,clone(x)])),fighters:(cfg.encounters[0]?.actors||[]).map(x=>x.actor_key),encounter:clone(cfg.encounters[0]||null),
      terminal:latest.settings.terminal_steps.find(x=>x.step_key===s.step_key)?.outcome||'',
      triggers:cfg.triggers.map(t=>{const transition=detail.plan.transitions.find(x=>x.transition_key===t.transition_key);if(!transition)throw Error('Passaggio della fase mancante.');return {...clone(t),transition:clone(transition),to:transition.to_step_key};}),
      encounter_key:cfg.encounters[0]?.encounter_key||('enc_'+s.step_key),pg_team:cfg.encounters[0]?.pg_team||'squadra'};});
    if(def.scenes.some(s=>s.encounters.length>1))throw Error('Questa revisione ha più scontri nella stessa fase: richiede l’editor completo prima della modifica.');
   }else{
    scenes=[{step_key:'inizio',kind:'narrative',public_objective:'',actors:[],terminal:'',triggers:[{trigger_key:'avanti',to:'scontro',source_kind:'player_choice',label:'Prosegui'}]},
     {step_key:'scontro',kind:'mechanical',public_objective:'',actors:[],terminal:'',encounter_key:'primo_scontro',pg_team:'squadra',triggers:[{trigger_key:'fine_scontro',to:'conclusione',source_kind:'combat_terminal',combat_outcome:'any',label:'Scontro concluso'}]},
     {step_key:'conclusione',kind:'narrative',public_objective:'',actors:[],terminal:'success',triggers:[]}];
   }
   let initial=latest? (await rpc('mission_generic_editor_v1',{p_plan_version:latest.plan_version_id},user)).plan.initial_step_key:'inizio';
   for(const s of scenes){s.actor_specs||={};s.fighters||=[];}
   if(revisions.length){d.append(field('Revisione da visualizzare',select(revisions.map(x=>({value:x.plan_version_id,label:'Revisione '+x.version+(x.plan_version_id===selected?' · scelta per i nuovi avvii':' · salvata')})),latest.plan_version_id,v=>editor(mission,title,v))));
    d.append(el('p','Il salvataggio crea una nuova revisione. La selezione per i nuovi avvii è separata; le missioni aperte mantengono la propria configurazione.'));}
   const area=el('div',null),actions=el('div',null,{class:'mg-row'});status.textContent='Configura le fasi e scegli dove si apre e termina ogni scontro. La mappa è quella associata alla missione.';d.append(area,actions);
   const profileItems=[{value:'',label:'Scegli dal Ninja Book'},...profiles.mechanical_profiles.map(p=>({value:'m:'+p.mechanical_binding_id,label:p.display_name+' · '+p.rank})),...profiles.narrative_profiles.map(p=>({value:'n:'+p.narrative_version_id,label:p.display_name+' · solo narrazione'}))];
   function render(){area.replaceChildren();
    const ar=el('section',null,{class:'mg-scene'});ar.append(el('h4','PNG della missione'));
    for(const a of actors){const row=el('div',null,{class:'mg-row'});row.append(field(a.actor_key,select(profileItems,a.mechanical_binding_id?'m:'+a.mechanical_binding_id:a.narrative_version_id?'n:'+a.narrative_version_id:'',v=>{
      const mechanical=v.startsWith('m:'),key=v.slice(2);const p=mechanical?profiles.mechanical_profiles.find(x=>x.mechanical_binding_id===key):profiles.narrative_profiles.find(x=>x.narrative_version_id===key);if(!p)return;
      const profile={mechanical_binding_id:mechanical?key:null,narrative_template_id:p.narrative_template_id,narrative_version_id:p.narrative_version_id};
      Object.assign(a,profile);for(const s of scenes){if(s.actor_specs[a.actor_key])Object.assign(s.actor_specs[a.actor_key],profile);if(!mechanical)s.fighters=s.fighters.filter(k=>k!==a.actor_key);}render();
     })),field('Schieramento iniziale per le nuove fasi',input(a.team,v=>a.team=v)),button('Rimuovi PNG',()=>{actors=actors.filter(x=>x!==a);for(const s of scenes){s.actors=s.actors.filter(x=>x!==a.actor_key);s.fighters=s.fighters.filter(x=>x!==a.actor_key);delete s.actor_specs[a.actor_key];}render();}));ar.append(row);}
    ar.append(button('Aggiungi PNG',()=>{let key;do{key='png_'+counter++;}while(actors.some(a=>a.actor_key===key));actors.push({actor_key:key,mechanical_binding_id:'',team:'avversari'});render();}));area.append(ar);
    area.append(field('Fase iniziale',select(scenes.map(s=>({value:s.step_key,label:s.public_objective.split('\n')[0].slice(0,55)||'Fase '+(scenes.indexOf(s)+1)})),initial,v=>initial=v)));
    for(const s of scenes){const box=el('section',null,{class:'mg-scene'}),row=el('div',null,{class:'mg-row'});box.append(el('h4','Fase '+(scenes.indexOf(s)+1)));
     row.append(field('Tipo',select([{value:'narrative',label:'Narrazione'},{value:'mechanical',label:'Scontro'}],s.kind,v=>{s.kind=v;if(v==='mechanical'){s.terminal='';s.encounter_key||='enc_'+s.step_key;s.pg_team||='squadra';}s.triggers=[];render();})),
      field('Conclusione',select([{value:'',label:'La missione continua'},{value:'success',label:'Missione riuscita'},{value:'failure',label:'Missione fallita'}],s.terminal,v=>{s.terminal=v;if(v){s.kind='narrative';s.triggers=[];}render();})));
     const ta=el('textarea',null);ta.value=s.public_objective;ta.addEventListener('input',()=>s.public_objective=ta.value);box.append(row,field('Situazione e obiettivo della fase',ta));
     const roster=el('div',null);for(const a of actors){const line=el('div',null,{class:'mg-row'}),l=el('label',(profiles.mechanical_profiles.find(p=>p.mechanical_binding_id===a.mechanical_binding_id)||profiles.narrative_profiles.find(p=>p.narrative_version_id===a.narrative_version_id))?.display_name||'PNG '+(actors.indexOf(a)+1),{class:'mg-inline-check'}),ch=el('input',null,{type:'checkbox'});
      ch.checked=s.actors.includes(a.actor_key);ch.addEventListener('change',()=>{s.actors=s.actors.filter(x=>x!==a.actor_key);s.fighters=s.fighters.filter(x=>x!==a.actor_key);if(ch.checked){s.actors.push(a.actor_key);s.actor_specs[a.actor_key]||=clone(a);if(s.kind==='mechanical'&&a.mechanical_binding_id)s.fighters.push(a.actor_key);}render();});l.prepend(ch);line.append(l);
      if(ch.checked){const spec=s.actor_specs[a.actor_key]||(s.actor_specs[a.actor_key]=clone(a));line.append(field('Schieramento in questa fase',input(spec.team,v=>spec.team=v)));
       if(s.kind==='mechanical'&&spec.mechanical_binding_id){const fighter=el('input',null,{type:'checkbox'}),label=el('label','Partecipa allo scontro',{class:'mg-inline-check'});fighter.checked=s.fighters.includes(a.actor_key);fighter.addEventListener('change',()=>{s.fighters=s.fighters.filter(k=>k!==a.actor_key);if(fighter.checked)s.fighters.push(a.actor_key);});label.prepend(fighter);line.append(label);}}
      roster.append(line);}box.append(roster);
     if(s.kind==='mechanical'){box.append(field('Schieramento dei PG',input(s.pg_team,v=>s.pg_team=v)));if(s.encounter?.zone_key)box.append(el('p','Zona della mappa: '+s.encounter.zone_key));}
     if(!s.terminal){
      for(const t of s.triggers){const line=el('div',null,{class:'mg-row'}),opts=s.kind==='mechanical'?[{value:'any',label:'Scontro terminato'},{value:'pg_win',label:'Vittoria dei PG'},{value:'pg_loss',label:'Sconfitta dei PG'},{value:'draw',label:'Nessuna squadra vincitrice'}]:[{value:'player_choice',label:'Scelta del giocatore'}];
       line.append(field('Quando',select(opts,s.kind==='mechanical'?(t.combat_outcome||'any'):'player_choice',v=>{if(s.kind==='mechanical')t.combat_outcome=v;})),field('Testo della scelta',input(t.label,v=>t.label=v)),
        field('Passa alla fase',select(scenes.filter(x=>x!==s).map(x=>({value:x.step_key,label:x.public_objective.split('\n')[0].slice(0,55)||'Fase '+(scenes.indexOf(x)+1)})),t.to,v=>t.to=v)),button('Rimuovi passaggio',()=>{s.triggers=s.triggers.filter(x=>x!==t);render();}));box.append(line);
      }
      box.append(button('Aggiungi passaggio',()=>{s.triggers.push({trigger_key:'passaggio_'+counter++,to:scenes.find(x=>x!==s)?.step_key||'',source_kind:s.kind==='mechanical'?'combat_terminal':'player_choice',label:'Prosegui',combat_outcome:'any'});render();}));
     }
     box.append(button('Rimuovi fase',()=>{if(scenes.length<2)return;scenes=scenes.filter(x=>x!==s);for(const x of scenes)x.triggers=x.triggers.filter(t=>t.to!==s.step_key);if(initial===s.step_key)initial=scenes[0].step_key;render();}));area.append(box);
    }
    area.append(button('Aggiungi fase',()=>{let key;do{key='fase_'+counter++;}while(scenes.some(s=>s.step_key===key));scenes.push({step_key:key,kind:'narrative',public_objective:'',actors:[],actor_specs:{},fighters:[],terminal:'',triggers:[]});render();}));
   }
   function documentValue(){
    if(actors.some(a=>(!a.mechanical_binding_id&&!a.narrative_version_id)||!a.team.trim()))throw Error('Completa i PNG della missione.');
    if(scenes.some(s=>!s.public_objective.trim()||s.actors.some(k=>!s.actor_specs[k]?.team?.trim())))throw Error('Completa gli obiettivi e gli schieramenti di ogni fase.');
    if(scenes.some(s=>s.kind==='mechanical'&&(!s.fighters.length||!s.fighters.some(k=>s.actor_specs[k]?.mechanical_binding_id&&s.actor_specs[k].team!==s.pg_team))))throw Error('Ogni scontro richiede almeno un PNG combattente avversario dei PG. Le fasi narrative possono avere zero PNG.');
    const transitions=[],definition={schema_version:'mission-generic-definition/1',scenes:[]};
    for(const s of scenes){const assigned=s.actors.map(k=>clone(s.actor_specs[k]));const key=s.encounter_key||'enc_'+s.step_key;
     const triggers=s.triggers.map(t=>{if(!t.to||!t.label.trim())throw Error('Completa ogni passaggio.');const tk=t.transition_key||s.step_key+'_'+t.trigger_key;
      transitions.push({transition_key:tk,from_step_key:s.step_key,to_step_key:t.to,event_kind:t.transition?.event_kind||tk,priority:t.transition?.priority??0});
      const x={trigger_key:t.trigger_key,transition_key:tk,source_kind:s.kind==='mechanical'?'combat_terminal':'player_choice',
       fact_code:t.fact_code||(s.kind==='mechanical'?'combat_terminal_confirmed':'player_choice_confirmed'),label:t.label};
      if(s.kind==='mechanical'){x.encounter_key=key;if(t.combat_outcome!==undefined)x.combat_outcome=t.combat_outcome;}return x;});
     const encounter={...(s.encounter||{}),encounter_key:key,pg_policy:'all_active',pg_team:s.pg_team,actors:assigned.filter(a=>s.fighters.includes(a.actor_key)),arena_ref:'mission'};
     definition.scenes.push({step_key:s.step_key,actors:assigned,encounters:s.kind==='mechanical'?[encounter]:[],triggers});
    }
    return {schema_version:'mission-generic-plan-document/1',base_plan_version_id:base,initial_step_key:initial,
     steps:scenes.map(s=>({step_key:s.step_key,kind:s.kind,public_objective:s.public_objective})),transitions,definition,
     terminal_steps:scenes.filter(s=>s.terminal).map(s=>({step_key:s.step_key,outcome:s.terminal}))};
   }
   let sealed=null,uncertain=false;
   const save=button('Salva nuova revisione',async()=>{if(uncertain)return;let doc;try{doc=documentValue();}catch(e){status.textContent=e.message;return;}
    save.disabled=true;status.textContent='Salvataggio della revisione…';
    try{sealed=await rpc('mission_generic_plan_seal_v1',{p_mission:mission,p_request:id(),p_expected_mission_sha256:catalog.mission_sha256,p_document:doc},user);
     status.textContent='Revisione '+sealed.version+' salvata. Puoi usarla per i prossimi avvii.';use.disabled=false;area.querySelectorAll('button,input,textarea,select').forEach(n=>n.disabled=true);
    }catch(e){uncertain=true;status.textContent='Salvataggio non confermato: riapri la configurazione per verificarlo. '+e.message;}
   });
   const use=button('Usa per i prossimi avvii',async()=>{use.disabled=true;try{const pv=sealed?.plan_version_id||latest?.plan_version_id;if(!pv)throw Error('Salva prima la revisione.');
    const r=await rpc('mission_generic_plan_select_v1',{p_mission:mission,p_plan_version:pv,p_expected_selection_version:catalog.selection_control_version,p_request:id()},user);
    selected=r.plan_version_id;status.textContent='Revisione selezionata per le nuove missioni. Le scene già aperte mantengono la propria versione.';refresh();
   }catch(e){status.textContent='Selezione non confermata: riapri per verificare. '+e.message;}});
   use.disabled=!latest||selected===latest.plan_version_id;area.addEventListener('input',()=>{if(!sealed)use.disabled=true;});area.addEventListener('change',()=>{if(!sealed)use.disabled=true;});actions.append(save,use);render();
  }catch(e){status.textContent=e.message;}
 }
 async function board(mission,title){
  const user=identity(),d=dialog('Missione IA · '+title),status=el('p','Caricamento…',{role:'status'}),area=el('div',null);d.append(status,area);
  async function load(){const response=await rpc('mission_generic_board_state_v1',{p_mission:mission},user);if(!d.isConnected)return;
   const state=response.missions.find(x=>x.mission_id===mission);area.replaceChildren();
   if(!state){status.textContent='La regia IA non è configurata per questa missione.';}
   else{status.textContent=(state.master_session_id?'Missione avviata.':state.available?'Iscrizioni aperte.':'Avvio non disponibile.')+' Partecipanti: '+state.participants+' (da '+state.team_min+' a '+state.team_max+').';
    async function act(fn){area.querySelectorAll('button').forEach(b=>b.disabled=true);try{await fn();await load();refresh();}catch(e){status.textContent='Operazione non confermata: aggiorna prima di ripetere. '+e.message;}}
    if(state.can_join)area.append(button('Partecipa',()=>act(()=>rpc('mission_generic_board_join_v1',{p_mission:mission,p_request:id()},user))));
    if(state.joined&&!state.master_session_id){area.append(button(state.ready?'Non sono pronto':'Sono pronto',()=>act(()=>rpc('mission_ai_board_ready_toggle',{p_mission:mission,p_ready:!state.ready,p_expected_version:state.control_version,p_request_key:id()},user))),
      button('Ritira partecipazione',()=>act(()=>rpc('mission_ai_board_withdraw',{p_mission:mission,p_expected_version:state.control_version,p_request_key:id()},user))));}
    if(state.can_start)area.append(button('Inizia missione',()=>act(()=>rpc('mission_generic_board_start_v1',{p_mission:mission,p_expected_version:state.control_version,p_request:id()},user))));
   }
   area.append(button('Aggiorna',()=>load().catch(e=>status.textContent=e.message)));
   if(isStaff()){
    const loc=currentLocation();
    if(loc&&!loc.is_test&&!state?.master_session_id)area.append(button('Apri iscrizioni in questa stanza',async e=>{e.currentTarget.disabled=true;try{await rpc('mission_generic_board_open_v1',{p_mission:mission,p_location:loc.id,p_request:id()},user);await load();}catch(err){status.textContent=err.message;}}));
    if(loc?.is_test){const details=el('details',null);details.append(el('summary','Prova protetta dello staff in questa stanza'));const picks=new Set(),row=el('div',null);
     details.append(row);area.append(details);const start=button('Avvia prova protetta',async e=>{if(!picks.size)return;e.currentTarget.disabled=true;try{
       await rpc('mission_generic_staff_test_start_v1',{p_source_mission:mission,p_location:loc.id,p_roster:[...picks],p_request:id()},user);
       status.textContent='Prova creata. La regia prepara l’apertura nella chat.';refresh();d.close();
      }catch(err){status.textContent='Avvio non confermato: aggiorna per verificare. '+err.message;}});start.disabled=true;details.append(start);
     const roster=await presentCharacters();if(!d.isConnected||currentLocation()?.id!==loc.id)return;
     for(const c of roster){const label=el('label',c.name,{class:'mg-inline-check'}),check=el('input',null,{type:'checkbox'});check.addEventListener('change',()=>{if(check.checked)picks.add(c.id);else picks.delete(c.id);start.disabled=picks.size<1||picks.size>4;});label.prepend(check);row.append(label);}
     if(!roster.length)row.textContent='Nessun personaggio presente nella stanza.';
    }
   }
  }
  try{await load();}catch(e){status.textContent=e.message;}
 }
 async function sources(){
  if(!isStaff())return;const user=identity(),d=dialog('Archivio missioni · Regia IA'),status=el('p','Caricamento…',{role:'status'});d.append(status);
  try{const r=await client.from('missions').select('id,title,status').order('title');if(!valid(user)||!d.isConnected)return;if(r.error)throw Error(r.error.message);
   const items=r.data||[];if(!items.length){status.textContent='Nessuna missione disponibile.';return;}let chosen=items[0].id;
   status.textContent='Puoi configurare o provare anche una missione già conclusa. La prova protetta conserva la missione originale e il suo risultato.';
   d.append(field('Missione sorgente',select(items.map(m=>({value:m.id,label:m.title+' · '+m.status})),chosen,v=>chosen=v)),
    button('Configura regia IA',()=>{const m=items.find(x=>x.id===chosen);editor(m.id,m.title);}),
    button('Avvio o prova protetta',()=>{const m=items.find(x=>x.id===chosen);board(m.id,m.title);}));
  }catch(e){status.textContent=e.message;}
 }
 async function decorateBoard(host){const user=identity();if(!user||!host)return;
  if(isStaff()&&!host.querySelector('[data-mg-sources]')){const b=button('Archivio missioni e prove IA',sources);b.setAttribute('data-mg-sources','');host.prepend(b);}
  try{const response=await rpc('mission_generic_board_state_v1',{p_mission:null},user);if(!host.isConnected||!valid(user))return;
   for(const m of response.missions){if(isStaff())continue;const card=[...host.querySelectorAll('[data-mid]')].find(n=>n.getAttribute('data-mid')===m.mission_id);if(!card||card.querySelector('[data-mg-board]'))continue;
    const b=button('Missione IA',()=>board(m.mission_id,m.title));b.setAttribute('data-mg-board',m.mission_id);card.querySelector('.mact')?.append(b);
   }
  }catch{/* Feature availability is not inferred from an absent RPC. */}
 }
 async function tick(state,user){
  const loc=currentLocation();if(!loc||!valid(user)||!state.can_tick)return;
  const key=state.session_id+':'+state.step_key+':'+JSON.stringify(state.request);
  if(dispatched.has(key))return;dispatched.add(key);
  const {data,error}=await client.functions.invoke('mission_generic_ai',{body:{schema_version:'mission-generic-tick/1',master_session_id:state.session_id,request_key:id()}});
  if(!valid(user)||currentLocation()?.id!==loc.id)return;
  if(error||data?.delivery?.status===202||data?.code==='MISSION_EVENT_UNCERTAIN'){
   notice('La risposta della regia non è ancora confermata. Aggiorna per verificarne lo stato.');return;
  }
  dispatched.delete(key);if(data?.delivery?.code==='MISSION_EVENT_FAILED')notice('La regia richiede una verifica dello staff.');
 }
 async function updateRoom(host){
  if(!host||roomBusy)return;const user=identity(),loc=currentLocation();
  if(!user||!loc){host.replaceChildren();host.hidden=true;return;}
  roomBusy=true;const epoch=roomEpoch;
  try{
   const state=await rpc('mission_generic_room_state_v1',{p_location:loc.id},user);
   if(epoch!==roomEpoch||!valid(user)||currentLocation()?.id!==loc.id)return;
   if(!state){roomState=null;roomSignature='';host.replaceChildren();host.hidden=true;return;}
   roomState=state;const sig=JSON.stringify(state);host.hidden=false;
   if(sig!==roomSignature){roomSignature=sig;host.replaceChildren();host.className='mg-room';
    host.append(el('strong','Missione · '+(state.objective||state.step_key)),el('p',state.state||'',{role:'status'}));
    const choiceData=Array.isArray(state.choices)?state.choices:state.choices?.choices||[];
    for(const c of choiceData){const b=button(c.label,async()=>{host.querySelectorAll('button').forEach(x=>x.disabled=true);
     try{await rpc('mission_generic_choose_v1',{p_session:state.session_id,p_trigger:c.trigger_key,p_request:id(),
       p_expected_master_version:state.choice_context.master_control_version,p_expected_run_version:state.choice_context.run_control_version},user);
       roomSignature='';refresh();
     }catch(e){notice('Scelta non confermata: aggiorna prima di ripetere. '+e.message);roomSignature='';}
    });host.append(b);}
    host.append(button('Aggiorna regia',()=>{dispatched.clear();roomSignature='';updateRoom(host);}));
   }
   await tick(state,user);
  }catch(e){if(epoch===roomEpoch&&valid(user)&&currentLocation()?.id===loc.id&&roomState){const n=host.querySelector('[role=status]');if(n)n.textContent='Aggiornamento non disponibile. Riprova con Aggiorna regia.';}}
  finally{roomBusy=false;}
 }
 return {editor,board,decorateBoard,updateRoom,dispose(){roomEpoch++;roomState=null;roomSignature='';if(currentDialog)currentDialog.close();dispatched.clear();},version:VERSION};
}
