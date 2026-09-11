export const VERSION='mission-unified-fato-ui/1.2';
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

export function createMissionUI({client,identity,isStaff,currentLocation,presentCharacters=async()=>[],creationEditor=null,creationBoard=null,notice=()=>{},refresh=()=>{}}){
 let currentDialog=null,roomEpoch=0,roomSignature='',roomState=null;
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
  if(!isStaff())return;if(typeof creationEditor!=='function')throw Error('Editor completo della missione non disponibile.');
  return creationEditor(mission,title,requestedRevision);
 }
 async function board(mission,title){
  if(isStaff()&&typeof creationBoard==='function'&&await creationBoard(mission,title))return;
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
  if(!isStaff())return;const user=identity(),d=dialog('Archivio missioni'),status=el('p','Caricamento…',{role:'status'});d.append(status);
  try{const r=await client.from('missions').select('id,title,status').order('title');if(!valid(user)||!d.isConnected)return;if(r.error)throw Error(r.error.message);
   const items=r.data||[];if(!items.length){status.textContent='Nessuna missione disponibile.';return;}let chosen=items[0].id;
   status.textContent='Puoi configurare o provare anche una missione già conclusa. La prova protetta conserva la missione originale e il suo risultato.';
   d.append(field('Missione sorgente',select(items.map(m=>({value:m.id,label:m.title+' · '+m.status})),chosen,v=>chosen=v)),
    button('Configura missione',()=>{const m=items.find(x=>x.id===chosen);editor(m.id,m.title);}),
    button('Avvio o prova protetta',()=>{const m=items.find(x=>x.id===chosen);board(m.id,m.title);}));
  }catch(e){status.textContent=e.message;}
 }
 async function decorateBoard(host){const user=identity();if(!user||!host)return;
  if(isStaff()&&!host.querySelector('[data-mg-sources]')){const b=button('Archivio missioni e prove',sources);b.setAttribute('data-mg-sources','');host.prepend(b);}
  try{const response=await rpc('mission_generic_board_state_v1',{p_mission:null},user);if(!host.isConnected||!valid(user))return;
   for(const m of response.missions){if(isStaff())continue;const card=[...host.querySelectorAll('[data-mid]')].find(n=>n.getAttribute('data-mid')===m.mission_id);if(!card||card.querySelector('[data-mg-board]'))continue;
    const b=button('Missione IA',()=>board(m.mission_id,m.title));b.setAttribute('data-mg-board',m.mission_id);card.querySelector('.mact')?.append(b);
   }
  }catch{/* Feature availability is not inferred from an absent RPC. */}
 }
 // Processing is a server projection. A read never retries a provider or a choice.
 const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
 const SHA=/^[0-9a-f]{64}$/;
 const workStates=new Set(['ready','claimed','authorized','provider_started','completed','failed','uncertain']);
 let roomScope=null,roomRead=null,roomHost=null,roomError='',cacheUser=null,readSequence=0;
 const attempts=new Map(),choiceRequests=new Map();
 function scopeFor(user,loc){return user&&loc?.id?JSON.stringify([user,loc.id]):null;}
 function syncRoom(host){
  const user=identity(),loc=currentLocation(),scope=scopeFor(user,loc);
  if(cacheUser!==user){cacheUser=user;attempts.clear();choiceRequests.clear();}
  if(scope!==roomScope||host!==roomHost){roomEpoch++;roomRead=null;roomState=null;roomSignature='';roomError='';roomScope=scope;roomHost=host;if(host){host.replaceChildren();host.hidden=true;}}
  return {user,loc,scope,epoch:roomEpoch};
 }
 const roomCurrent=t=>t.scope===roomScope&&t.epoch===roomEpoch&&valid(t.user)&&scopeFor(identity(),currentLocation())===t.scope&&roomHost?.isConnected;
 const choiceKey=s=>JSON.stringify([cacheUser,s.session_id]);
 function processingFor(state){
  if(!state||!UUID.test(state.session_id||'')||!SHA.test(state.progress_key||'')||!Object.hasOwn(state,'processing'))return {valid:false,value:null};
  const p=state.processing;if(p===null)return {valid:true,value:null};
  const q=p?.request;
  if(p?.schema_version!=='mission-generic-processing/1'||!workStates.has(p.state)||!UUID.test(p.work_id||'')||!UUID.test(p.event_id||'')||!UUID.test(p.request_key||'')||!Number.isSafeInteger(p.revision)||p.revision<1
   ||typeof p.created_at!=='string'||!Number.isFinite(Date.parse(p.created_at))||!(p.finalized_at===null||typeof p.finalized_at==='string'&&Number.isFinite(Date.parse(p.finalized_at)))
   ||!(p.message_id===null||UUID.test(p.message_id||''))||q?.schema_version!=='mission-generic-request/1'||q.master_session_id!==state.session_id||q.event_id!==p.event_id||q.request_key!==p.request_key||q.expected_revision!==p.revision)return {valid:false,value:null};
  return {valid:true,value:p};
 }
 function currentAttempt(state){return [...attempts.values()].reverse().find(a=>a.user===cacheUser&&a.session===state.session_id&&(a.key==='tick:'+state.progress_key||a.work===state.processing?.work_id))||null;}
 function liveAttempt(state){return [...attempts.values()].some(a=>a.user===cacheUser&&a.session===state.session_id&&a.inFlight);}
 function statusText(state){
  if(roomError)return roomError;
  if(state.review_required===true)return 'La scena richiede una valutazione dello staff prima di continuare.';
  const choice=choiceRequests.get(choiceKey(state));
  if(choice?.inFlight)return 'Invio della scelta in corso. La lettura della stanza continua.';
  if(choice?.phase==='uncertain')return 'La scelta non è ancora confermata. Verifica la stessa scelta prima di inviarne un’altra.';
  if(choice?.phase==='confirmed')return 'Scelta confermata. Aggiornamento della fase in corso…';
  if(choice?.phase==='rejected')return 'La scelta è stata respinta. Aggiorna lo stato prima di scegliere nuovamente.';
  const parsed=processingFor(state);if(!parsed.valid)return 'Stato di elaborazione non disponibile. Aggiorna; nessun nuovo invio automatico.';
  const p=parsed.value,a=currentAttempt(state);
  if(p?.state==='failed')return 'Il Fato richiede una verifica dello staff. Nessun nuovo tentativo automatico.';
  if(p?.state==='uncertain')return 'L’esito del Fato non è ancora confermato. Lo stato si aggiorna senza ripetere l’invio.';
  if(p&&['ready','claimed','authorized','provider_started'].includes(p.state))return a?.outcome==='uncertain'?'Invio non ancora confermato. Verifica dello stato in corso, senza ripetere la richiesta.':'Il Fato sta preparando la scena. Puoi attendere qui: lo stato si aggiorna automaticamente.';
  if(p?.state==='completed'&&a?.work===p.work_id)return p.message_id?'Il Fato ha pubblicato il racconto nella chat.':'Elaborazione completata. Lo stato della missione si aggiorna automaticamente.';
  if(a?.outcome==='uncertain')return 'Invio non ancora confermato. Lo stato si aggiorna senza ripetere la richiesta.';
  if(a?.outcome==='failed')return 'Il Fato richiede una verifica dello staff. Nessun nuovo tentativo automatico.';
  if(a?.inFlight||a?.outcome==='waiting')return 'Il Fato sta preparando la scena. Puoi attendere qui: lo stato si aggiorna automaticamente.';
  if(p?.state==='completed')return p.message_id?'Il Fato ha pubblicato il racconto nella chat.':'Elaborazione completata. Lo stato della missione si aggiorna automaticamente.';
  return state.state==='preparazione'?'Il Fato sta preparando l’apertura della missione.':state.can_tick?'Missione in corso.':'La missione è in pausa o conclusa.';
 }
 function choicesAllowed(state){
  const parsed=processingFor(state),p=parsed.value,a=currentAttempt(state);
  const unresolved=a&&['uncertain','failed','waiting'].includes(a.outcome)&&!(p?.state==='completed'&&a.work===p.work_id);
  return state.review_required!==true&&parsed.valid&&!unresolved&&Number.isSafeInteger(state.choice_context?.master_control_version)&&Number.isSafeInteger(state.choice_context?.run_control_version)&&!roomError&&!choiceRequests.has(choiceKey(state))&&!liveAttempt(state)&&state.state==='in_corso'
   &&state.choice_context?.narration_pending!==true&&(!p||p.state==='completed');
 }
 function paintRoom(host,state){
  if(!host||!state)return;style();
  let title=host.querySelector('[data-mg-room-title]'),status=host.querySelector('[data-mg-room-status]'),actions=host.querySelector('[data-mg-room-actions]');
  if(!title||!status||!actions){host.replaceChildren();host.className='mg-room';title=el('strong','',{'data-mg-room-title':''});status=el('p','',{'data-mg-room-status':'',role:'status','aria-live':'polite','aria-atomic':'true'});actions=el('div',null,{'data-mg-room-actions':''});host.append(title,status,actions,button('Aggiorna regia',()=>updateRoom(host,{manual:true})));roomSignature='';}
  host.hidden=false;const heading='Missione · '+(state.objective||state.step_key||'');if(title.textContent!==heading)title.textContent=heading;
  const choices=Array.isArray(state.choices)?state.choices:state.choices?.choices||[];
  const sig=JSON.stringify([state.session_id,state.step_key,state.objective,choices,state.choice_context?.master_control_version,state.choice_context?.run_control_version]);
  if(sig!==roomSignature){roomSignature=sig;actions.replaceChildren();
   for(const c of choices){if(typeof c.trigger_key!=='string'||typeof c.label!=='string')continue;const b=button(c.label,()=>submitChoice(host,c.trigger_key));b.setAttribute('data-mg-choice','');actions.append(b);}
  }
  for(const b of actions.querySelectorAll('[data-mg-choice]'))b.disabled=!choicesAllowed(state);
  const pending=choiceRequests.get(choiceKey(state));let retry=host.querySelector('[data-mg-choice-retry]');
  if(pending?.phase==='uncertain'){if(!retry){retry=button('Verifica la stessa scelta',()=>submitChoice(host,null,true));retry.setAttribute('data-mg-choice-retry','');host.append(retry);}retry.disabled=state.review_required===true||pending.inFlight;}
  else if(retry)retry.remove();
  const text=statusText(state);if(status.textContent!==text)status.textContent=text;
 }
 function definitiveChoiceError(error){const code=error?.code;return typeof code==='string'&&(/^(22|23)/.test(code)||['42501','40001','55000','P0001'].includes(code));}
 async function submitChoice(host,trigger,retry=false){
  const t=syncRoom(host),state=roomState;if(!state||!roomCurrent(t)||state.review_required===true)return;
  const key=choiceKey(state);let pending=choiceRequests.get(key);
  if(retry){if(!pending||pending.phase!=='uncertain'||pending.inFlight)return;}
  else{
   if(!choicesAllowed(state)||!Array.isArray(state.choices)||!state.choices.some(c=>c.trigger_key===trigger))return;
   const c=state.choice_context;if(!Number.isSafeInteger(c?.master_control_version)||!Number.isSafeInteger(c?.run_control_version))return;
   pending={user:t.user,phase:'sending',inFlight:false,payload:Object.freeze({p_session:state.session_id,p_trigger:trigger,p_request:id(),p_expected_master_version:c.master_control_version,p_expected_run_version:c.run_control_version})};choiceRequests.set(key,pending);
  }
  pending.inFlight=true;paintRoom(host,state);
  try{
   const response=await client.rpc('mission_generic_choose_v1',clone(pending.payload));
   if(cacheUser!==t.user||choiceRequests.get(key)!==pending)return;
   if(response.error)throw response.error;
   if(response.data===null||response.data===undefined)throw Error('choice_unconfirmed');
   pending.phase='confirmed';pending.settledAfterRead=readSequence;
  }catch(error){if(cacheUser===t.user&&choiceRequests.get(key)===pending){pending.phase=definitiveChoiceError(error)?'rejected':'uncertain';pending.settledAfterRead=readSequence;}}
  finally{
   pending.inFlight=false;
   if(roomCurrent(t)){paintRoom(host,roomState);await updateRoom(host,{manual:true});refresh();}
  }
 }
 function maybeDispatch(state,t){
  const parsed=processingFor(state),p=parsed.value;if(!roomCurrent(t)||!parsed.valid||state.review_required===true||!state.can_tick||choiceRequests.has(choiceKey(state))||liveAttempt(state))return;
  if(p&&['claimed','authorized','provider_started','failed','uncertain'].includes(p.state))return;
  const key=p?.state==='ready'?'work:'+p.work_id+':'+p.revision:'tick:'+state.progress_key;
  const storeKey=JSON.stringify([t.user,state.session_id,key]);if(attempts.has(storeKey))return;
  const body=p?.state==='ready'?clone(p.request):{schema_version:'mission-generic-tick/1',master_session_id:state.session_id,request_key:id()};
  const a={user:t.user,session:state.session_id,key,work:p?.state==='ready'?p.work_id:null,body:Object.freeze(body),inFlight:true,outcome:'pending'};attempts.set(storeKey,a);paintRoom(roomHost,state);
  // Detached from the read lock: polling continues while the provider works.
  void (async()=>{
   try{
    const {data,error}=await client.functions.invoke('mission_generic_ai',{body:clone(a.body)});
    if(error)throw error;
    const code=data?.delivery?.code||data?.code;
    if(code==='MISSION_EVENT_UNCERTAIN'||data?.state==='uncertain')a.outcome='uncertain';
    else if(code==='MISSION_EVENT_FAILED'||data?.state==='failed')a.outcome='failed';
    else if(data?.delivery?.status===202||data?.status===202)a.outcome='waiting';
    else if(data&&typeof data==='object')a.outcome='confirmed';else a.outcome='uncertain';
   }catch{a.outcome='uncertain';}
   finally{a.inFlight=false;if(roomCurrent(t)){paintRoom(roomHost,roomState);await updateRoom(roomHost,{manual:true});refresh();}}
  })().catch(()=>{});
 }
 async function updateRoom(host,{manual=false}={}){
  if(!host)return;const t=syncRoom(host);
  if(!t.user||!t.loc){host.replaceChildren();host.hidden=true;return;}
  if(roomRead)return;t.readSequence=++readSequence;roomRead=t;
  try{
   const state=await rpc('mission_generic_room_state_v1',{p_location:t.loc.id},t.user);
   if(!roomCurrent(t))return;
   if(!state){roomState=null;roomSignature='';roomError='';host.replaceChildren();host.hidden=true;return;}
   if(!UUID.test(state.session_id||'')||typeof state.step_key!=='string')throw Error('room_state_invalid');
   roomState=state;roomError='';
   const key=choiceKey(state),pending=choiceRequests.get(key);
   // Only a confirmed RPC/rejection followed by an authoritative read unlocks choices.
   if(pending&&!pending.inFlight&&['confirmed','rejected'].includes(pending.phase)&&t.readSequence>pending.settledAfterRead)choiceRequests.delete(key);
   paintRoom(host,state);if(!manual)maybeDispatch(state,t);
  }catch(error){if(roomCurrent(t)&&roomState){roomError='Aggiornamento non disponibile. I comandi restano sospesi; premi Aggiorna regia.';paintRoom(host,roomState);}}
  finally{if(roomRead===t)roomRead=null;}
 }
 return {editor,board,decorateBoard,updateRoom,dispose(){roomEpoch++;roomRead=null;roomScope=null;roomHost=null;roomState=null;roomSignature='';roomError='';if(currentDialog)currentDialog.close();},version:VERSION};
}
