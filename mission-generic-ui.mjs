export const VERSION='mission-generic-ui/1.2';
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
