import {createStaffAbortController,guardStaffAbortClient,staffAbortJournalSessions,staffAbortBlocked} from './staff-simulation-abort-ui.mjs?v=abort-availability-7ae3073ad9c3aaaa';
import {createStaffFatoRegen} from './mission-staff-fato-regen.v1.mjs?v=fato-publication-7897dcc449bd7b13';
export const VERSION='mission-academy-flow-v4-staff-client/1-c1266-free-narrative1';
const STAFF_TEST_ROOM='0b85f354-9cdb-47e1-baf9-3d266bb7e06b';
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

export function createMissionUI({client,identity,isStaff,currentLocation,presentCharacters=async()=>[],creationEditor=null,creationBoard=null,notice=()=>{},refresh=()=>{},openCombat=()=>{}}){
 let currentDialog=null,roomEpoch=0,roomSignature='',roomState=null;
 client=guardStaffAbortClient(client,{identity,session:()=>roomState?.session_id,location:()=>currentLocation()?.id});
 const aborts=new Map();let abortActor=null;
 function abortBlocked(id){return staffAbortBlocked(identity(),id);}
 async function mountAborts(host,state,t){
  if(t.loc.id!==STAFF_TEST_ROOM||t.loc.is_test!==true)return;
  if(abortActor!==t.user){for(const c of aborts.values())c.dispose();aborts.clear();abortActor=t.user;}
  const ids=[...new Set([...(state?[state.session_id]:[]),...staffAbortJournalSessions(t.user)])];
  host.querySelector('[data-staff-abort-recovery]')?.remove();
  const recovery=el('div',null,{'data-staff-abort-recovery':''});host.append(recovery);
  for(const id of ids){if(!roomCurrent(t))return;const ah=el('div',null,{'data-staff-abort':''});recovery.append(ah);
   let c=aborts.get(id);if(!c){c=createStaffAbortController({client,identity,hideCommitted:true,hideUnauthorizedAvailability:true,isCurrent:()=>roomCurrent(t),onCommitted:r=>{if(roomCurrent(t)&&roomState?.session_id===r.master_session_id){roomState=null;roomSignature='';const recoveryHost=roomHost?.querySelector('[data-staff-abort-recovery]');if(recoveryHost){roomHost.replaceChildren(recoveryHost);roomHost.hidden=false;}notice('Prova annullata. Fato e storico conservati.');}}});aborts.set(id,c);}
   // Controller contesto catturato: ricrea a ogni epoch stanza, mai riattivare il precedente utente.
   await c.mount(ah,id);if(!roomCurrent(t))return;
  }
  if(!roomState){host.replaceChildren(recovery);host.hidden=!recovery.querySelector('[data-staff-abort]:not([hidden])');}
 }
 const regen=createStaffFatoRegen({client,identity,isStaff,currentLocation,refresh});
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
 // A Staff start has one persisted request identity until server-confirmed closure.
 // This journal is separate from narrative journals1..5 and never clears them.
 const staffStartSchema='mission-staff-start-journal/1';
 const staffStartKey=(user,location)=>`${staffStartSchema}:${user}:${location}`;
 const staffStartReceiptKeys=['schema_version','mission_id','master_session_id','start_receipt_id','event_id','context_fingerprint','step','master_control_version','run_control_version','opening_pending','simulation','source_mission_id','replay'];
 function staffStartReceipt(value,source){
  if(!nativeExact(value,staffStartReceiptKeys)||value.schema_version!=='mission-generic-start/1'
   ||!['mission_id','master_session_id','start_receipt_id','event_id','source_mission_id'].every(k=>UUID.test(value[k]||''))
   ||value.source_mission_id!==source||!SHA.test(value.context_fingerprint||'')||typeof value.step!=='string'||!value.step
   ||!Number.isSafeInteger(value.master_control_version)||value.master_control_version<1
   ||!Number.isSafeInteger(value.run_control_version)||value.run_control_version<1
   ||value.opening_pending!==true||value.simulation!==true||typeof value.replay!=='boolean')throw Error('Ricevuta di avvio non riconosciuta. La richiesta resta conservata.');
  return value;
 }
 function staffStartTerminal(value,session){
  if(!nativeExact(value,['schema','master_session_id','status','can_abort','reason_code','master_control_version','run_control_version','receipt'])
   ||value.schema!=='staff-simulation-abort-state/1'||value.master_session_id!==session
   ||!['active','terminal','annullata'].includes(value.status)||typeof value.can_abort!=='boolean'
   ||!(value.reason_code===null||typeof value.reason_code==='string'))throw Error('Stato della prova non riconosciuto.');
  if(value.status==='annullata'){
   if(value.can_abort!==false||value.receipt?.status!=='annullata'||value.receipt.master_session_id!==session
    ||!UUID.test(value.receipt.request_key||''))throw Error('Chiusura della prova non confermata.');
   return true;
  }
  if(value.receipt!==null||!Number.isSafeInteger(value.master_control_version)||value.master_control_version<1
   ||!Number.isSafeInteger(value.run_control_version)||value.run_control_version<1
   ||value.status==='terminal'&&value.can_abort!==false)throw Error('Stato della prova non riconosciuto.');
  return value.status==='terminal';
 }
 function staffStartResolution(value,attempt){
  if(!nativeExact(value,['schema_version','request_key','request_fingerprint','state','master_session_id','result'])
   ||value.schema_version!=='mission-staff-start-resolution/1'||value.request_key!==attempt.request_key
   ||!SHA.test(value.request_fingerprint||'')||!['committed','rejected_no_commit'].includes(value.state))throw Error('Esito dell’avvio non riconosciuto. La richiesta resta conservata.');
  if(value.state==='rejected_no_commit'){
   if(value.master_session_id!==null||value.result!==null||attempt.receipt!==null)throw Error('Esito dell’avvio incoerente.');
  }else{
   staffStartReceipt(value.result,attempt.source_mission_id);
   if(value.master_session_id!==value.result.master_session_id||attempt.receipt&&staffStartReceiptKeys.some(k=>k!=='replay'&&attempt.receipt[k]!==value.result[k]))throw Error('Sessione dell’avvio incoerente.');
  }
  return value;
 }
 function readStaffStart(user,location){
  let value;try{const raw=localStorage.getItem(staffStartKey(user,location));value=raw?JSON.parse(raw):{schema_version:staffStartSchema,user,location,attempts:[]};}
  catch{throw Error('Recupero locale dell’avvio non disponibile. Nessuna nuova richiesta inviata.');}
  if(!nativeExact(value,['schema_version','user','location','attempts'])||value.schema_version!==staffStartSchema
   ||value.user!==user||value.location!==location||!Array.isArray(value.attempts))throw Error('Richiesta di avvio conservata non riconosciuta.');
  const seen=new Set();
  for(let i=0;i<value.attempts.length;i++){
   const a=value.attempts[i];
   if(!nativeExact(a,['source_mission_id','roster','request_key','receipt','terminal','resolution'])||!UUID.test(a.source_mission_id||'')
    ||!UUID.test(a.request_key||'')||seen.has(a.request_key)||!Array.isArray(a.roster)||a.roster.length<1||a.roster.length>4
    ||a.roster.some(x=>!UUID.test(x||''))||new Set(a.roster).size!==a.roster.length
    ||JSON.stringify(a.roster)!==JSON.stringify([...a.roster].sort()))throw Error('Richiesta di avvio conservata non riconosciuta.');
   seen.add(a.request_key);if(a.receipt!==null)staffStartReceipt(a.receipt,a.source_mission_id);
   if(a.resolution!==null)staffStartResolution(a.resolution,a);
   if(a.terminal!==null&&(!a.receipt||!staffStartTerminal(a.terminal,a.receipt.master_session_id)))throw Error('Chiusura conservata non riconosciuta.');
   if(i<value.attempts.length-1&&a.terminal===null&&a.resolution?.state!=='rejected_no_commit')throw Error('Avvio precedente ancora da completare.');
  }
  return value;
 }
 function writeStaffStart(value){
  const key=staffStartKey(value.user,value.location),text=JSON.stringify(value);localStorage.setItem(key,text);
  if(localStorage.getItem(key)!==text)throw Error('Impossibile conservare la richiesta di avvio. Nessun nuovo invio.');
 }
 async function staffStartLock(user,location,fn){
  if(typeof navigator.locks?.request!=='function')throw Error('Il browser non consente di conservare un avvio unico tra le schede.');
  return navigator.locks.request(staffStartKey(user,location),{mode:'exclusive'},fn);
 }
 async function mountStaffStart(area,status,d,mission,user,loc){
  const same=()=>d.isConnected&&box.isConnected&&valid(user)&&isStaff()&&currentLocation()?.id===loc.id&&currentLocation()?.is_test===true;
  const box=el('section',null),row=el('fieldset',null),actions=el('div',null),abortHost=el('div',null);
  box.append(el('h4','Scegli i presenti e prova'),row,actions,abortHost);area.append(box);
  const picks=new Set();let journal,run=null,busy=false,abortController=null;
  const dispose=()=>{abortController?.dispose();abortController=null;};d.addEventListener('close',dispose,{once:true});
  const latest=j=>{const a=j.attempts.at(-1);return a?.terminal===null&&a.resolution?.state!=='rejected_no_commit'?a:null;};
  const start=button('Avvia prova',()=>void send());
  const change=button('Cambia selezione',()=>void resolveStart());
  const open=button('Apri prova',()=>{if(same()&&run?.receipt){refresh();d.close();}});
  actions.append(start,change,open);
  function sync(){
   row.disabled=busy||!!run;
   start.textContent=run?'Riprendi lo stesso avvio':'Avvia prova';
   start.disabled=busy||!!run?.receipt||(!run&&(picks.size<1||picks.size>4));change.hidden=!run||!!run.receipt;change.disabled=busy;open.hidden=!run?.receipt;open.disabled=busy;
  }
  async function readPrevious(){
   await staffStartLock(user,loc.id,async()=>{
    if(!same())return;journal=readStaffStart(user,loc.id);run=latest(journal);
    if(run?.receipt){
     const state=await rpc('mission_staff_simulation_abort_state_v1',{p_session:run.receipt.master_session_id},user);if(!same())return;
     if(staffStartTerminal(state,run.receipt.master_session_id)){run.terminal=clone(state);writeStaffStart(journal);run=null;}
    }
   });
  }
  async function showRun(){
   dispose();abortHost.replaceChildren();if(!same())return;
   if(run?.receipt){
    status.textContent='Prova aperta nella stanza. Puoi giocare oppure terminarla conservando lo storico.';
    abortHost.append(el('h4','Termina prova'));
    abortController=createStaffAbortController({client,identity,isCurrent:same,onCommitted:async r=>{
     if(!same()||r.master_session_id!==run?.receipt?.master_session_id)return;
     try{await readPrevious();if(same()){if(!run){picks.clear();row.querySelectorAll('input').forEach(n=>n.checked=false);}sync();await showRun();refresh();}}catch(e){if(same())status.textContent=e.message;}
    }});
    await abortController.mount(abortHost,run.receipt.master_session_id);
   }else status.textContent=run?(run.source_mission_id===mission?'Avvio in attesa di conferma.':'C’è un avvio in attesa per un’altra missione nella stanza.')+' Puoi riprenderlo o cambiare selezione; il server conserva l’esito della richiesta precedente.':'Scegli da 1 a 4 personaggi presenti e avvia la prova.';
  }
  async function resolveStart(){
   if(!same()||busy||!run||run.receipt)return;busy=true;sync();
   try{
    await staffStartLock(user,loc.id,async()=>{
     if(!same())return;journal=readStaffStart(user,loc.id);run=latest(journal);if(!run||run.receipt)return;
     const resolution=await rpc('mission_generic_staff_start_resolve_v1',{p_source_mission:run.source_mission_id,p_location:loc.id,p_roster:[...run.roster],p_request:run.request_key},user);
     staffStartResolution(resolution,run);run.resolution=clone(resolution);
     if(resolution.state==='committed')run.receipt=clone(resolution.result);
     writeStaffStart(journal);run=latest(journal);
    });
    if(same()){if(!run){picks.clear();row.querySelectorAll('input').forEach(n=>n.checked=false);}sync();await showRun();}
   }catch(e){if(same())status.textContent='La selezione precedente resta conservata. '+e.message;}
   finally{busy=false;if(same())sync();}
  }
  async function send(){
   if(!same()||busy)return;busy=true;sync();
   try{
    await staffStartLock(user,loc.id,async()=>{
     if(!same())return;journal=readStaffStart(user,loc.id);run=latest(journal);
     if(run?.receipt)return;
     if(!run){
      const roster=[...picks].sort();if(roster.length<1||roster.length>4)return;
      run={source_mission_id:mission,roster,request_key:id(),receipt:null,terminal:null,resolution:null};journal.attempts.push(run);writeStaffStart(journal);
     }
     // Persisted tuple and request are the only input to the mutating RPC.
     const result=await rpc('mission_generic_staff_test_start_v1',{p_source_mission:run.source_mission_id,p_location:loc.id,p_roster:[...run.roster],p_request:run.request_key},user);
     staffStartReceipt(result,run.source_mission_id);run.receipt=clone(result);writeStaffStart(journal);
    });
    if(same()){sync();await showRun();refresh();}
   }catch(e){if(same())status.textContent='Avvio non confermato. La stessa richiesta è conservata. '+e.message;}
   finally{busy=false;if(same()){try{journal=readStaffStart(user,loc.id);run=latest(journal);sync();}catch(e){start.disabled=true;row.disabled=true;status.textContent=e.message;}}}
  }
  try{
   await readPrevious();if(!same())return;
   const roster=await presentCharacters();if(!same())return;
   for(const c of roster){if(!UUID.test(c.id||''))continue;const label=el('label',c.name,{class:'mg-inline-check'}),check=el('input',null,{type:'checkbox'});
    check.checked=!!run?.roster.includes(c.id);check.addEventListener('change',()=>{if(run||busy)return;if(check.checked)picks.add(c.id);else picks.delete(c.id);sync();});label.prepend(check);row.append(label);}
   if(!roster.length)row.textContent='Nessun personaggio presente nella stanza.';
   sync();await showRun();
  }catch(e){if(same()){start.disabled=true;status.textContent=e.message;}}
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
    if(loc?.is_test&&loc.id===STAFF_TEST_ROOM)await mountStaffStart(area,status,d,mission,user,loc);
    else if(loc?.is_test){const details=el('details',null);details.append(el('summary','Prova protetta dello staff in questa stanza'));const picks=new Set(),row=el('div',null);
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
 // C1266 Native preparation: metadata only; server admission remains authoritative.
 const NATIVE_PREPARE_SOURCE='5878822d-dc03-4ac2-ad0b-1547f0ab3fc0';
 const NATIVE_PREPARE_AI='24b1e44a-5597-4fb0-95bd-fb13647764b2';
 const NATIVE_PREPARE_AI_SHA='3d75f8577ac8d173b3f3bf68f3fe7b8bdafd22bf6f2093eadd9882275aebe4d3';
 const nativePrepareBusy=new Set();
 const nativeExact=(v,keys)=>!!v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).sort().join('|')===[...keys].sort().join('|');
 function nativePrepareReceipt(r,e,request){
  const c=r?.configure_receipt,a=r?.ai,h=r?.human;
  if(!nativeExact(r,['schema_version','mission_id','request_key','source_mission_sha256','selection_control_version','ai','human','configure_receipt','config_version','state'])
   ||r.schema_version!=='mission-native-source-prepare/1'||r.mission_id!==e.p_mission||r.request_key!==request||r.source_mission_sha256!==e.p_expected_source_sha256
   ||r.selection_control_version!==e.p_expected_selection_version||r.state!=='draft'||!Number.isSafeInteger(r.config_version)||r.config_version<=0
   ||!nativeExact(a,['plan_version_id','plan_sha256','document_sha256'])||a.plan_version_id!==e.p_ai_plan_version||a.plan_sha256!==e.p_expected_ai_plan_sha256||!SHA.test(a.document_sha256||'')
   ||!nativeExact(h,['plan_version_id','plan_sha256','document_sha256','definition_id','definition_sha256'])||!UUID.test(h.plan_version_id||'')||h.plan_version_id===a.plan_version_id
   ||!UUID.test(h.definition_id||'')||!['plan_sha256','document_sha256','definition_sha256'].every(k=>SHA.test(h[k]||''))
   ||!nativeExact(c,['schema_version','mission_id','config_version','ai_plan_version_id','ai_plan_sha256','human_plan_version_id','human_plan_sha256','capability_sha256','state','request_key'])
   ||c.schema_version!=='mission-launch-configure/1'||c.mission_id!==e.p_mission||c.config_version!==r.config_version||c.state!=='draft'
   ||c.ai_plan_version_id!==a.plan_version_id||c.ai_plan_sha256!==a.plan_sha256||c.human_plan_version_id!==h.plan_version_id||c.human_plan_sha256!==h.plan_sha256
   ||!SHA.test(c.capability_sha256||'')||!UUID.test(c.request_key||'')||c.request_key===request)throw Error('Ricevuta Native non riconosciuta: conserva la stessa richiesta e chiedi verifica allo Staff.');
  return r;
 }
 async function nativePrepareMetadata(user){
  const mission=NATIVE_PREPARE_SOURCE;
  const catalog=await rpc('mission_generic_plan_catalog_v1',{p_mission:mission},user);
  if(catalog?.schema_version!=='mission-generic-plan-catalog/1'||catalog.mission?.mission_id!==mission||!SHA.test(catalog.mission_sha256||'')
   ||catalog.selected_plan_version_id!==NATIVE_PREPARE_AI||!Number.isSafeInteger(catalog.selection_control_version)||catalog.selection_control_version<0||!Array.isArray(catalog.versions))throw Error('La sorgente o la revisione AI non coincide con la predisposizione autorizzata.');
  const matches=catalog.versions.filter(x=>x.plan_version_id===catalog.selected_plan_version_id),ai=matches[0];
  if(matches.length!==1||ai.state!=='approvata'||ai.generic_ready!==true||ai.plan_sha256!==NATIVE_PREPARE_AI_SHA)throw Error('Revisione AI selezionata non pronta.');
  const meta=await rpc('mission_creation_editor_v1',{p_mission:mission,p_plan_version:ai.plan_version_id},user);
  if(meta?.schema_version!=='mission-creation-editor/1'||meta.plan_version_id!==ai.plan_version_id||meta.configured!==true||meta.mission?.direction_mode!=='ai'||meta.mission.gathering_location_id!=='df44f5d3-bff4-4e32-bf29-19c3b0f3b1d2')throw Error('Predisposizione disponibile solo per la sorgente AI con il luogo di raccolta autorizzato.');
  const boardState=await rpc('mission_generic_board_state_v1',{p_mission:mission},user);
  if(!Array.isArray(boardState?.missions))throw Error('Stato degli avvii non disponibile.');
  const boards=boardState.missions.filter(x=>x.mission_id===mission);
  if(boards.length>1||boards.some(x=>x.master_session_id!==null||x.available!==false))throw Error('La sorgente ha un avvio attivo: predisposizione sospesa.');
  // DTO permits CAS0 for the approved first preparation; the RPC rechecks actual capability absence.
  return {p_mission:mission,p_expected_source_sha256:catalog.mission_sha256,p_ai_plan_version:ai.plan_version_id,p_expected_ai_plan_sha256:ai.plan_sha256,p_expected_selection_version:catalog.selection_control_version,p_expected_config_version:0};
 }
 function nativePrepareJournal(key,e){
  const raw=localStorage.getItem(key);if(raw===null)return null;let j;
  try{j=JSON.parse(raw);}catch{throw Error('Journal della predisposizione illeggibile: serve verifica Staff, nessuna nuova richiesta.');}
  if(!nativeExact(j,['schema_version','request_key','expected','receipt'])||j.schema_version!=='c1266-native-prepare-journal/1'||!UUID.test(j.request_key||'')
   ||!nativeExact(j.expected,Object.keys(e))||JSON.stringify(j.expected)!==JSON.stringify(e))throw Error('Journal della predisposizione incoerente: serve verifica Staff, nessuna nuova richiesta.');
  if(j.receipt!==null)nativePrepareReceipt(j.receipt,e,j.request_key);return j;
 }
 async function mountNativePrepare(host,mission,user,current){
  host.replaceChildren();host.hidden=true;
  const inScope=()=>current()&&valid(user)&&isStaff()&&currentLocation()?.id===STAFF_TEST_ROOM&&currentLocation()?.is_test===true&&mission===NATIVE_PREPARE_SOURCE&&!roomState?.session_id;
  if(!inScope())return;
  const status=el('p','Verifica della predisposizione…',{role:'status',class:'mg-status','aria-live':'polite'});host.hidden=false;host.append(status);
  try{
   const expected=await nativePrepareMetadata(user);if(!inScope())return;
   const prefix='tus:c1266:native-prepare:1:'+user+':'+expected.p_mission+':';
   const key=prefix+JSON.stringify([expected.p_ai_plan_version,expected.p_expected_ai_plan_sha256,expected.p_expected_source_sha256,expected.p_expected_selection_version,expected.p_expected_config_version]);
   for(let i=0;i<localStorage.length;i++){const previous=localStorage.key(i);if(previous?.startsWith(prefix)&&previous!==key)throw Error('Metadati cambiati rispetto alla richiesta conservata: serve verifica Staff; nessuna nuova richiesta.');}
   let journal=nativePrepareJournal(key,expected);
   status.textContent='Predisposizione tecnica della prova · richiede abilitazione Staff. Il piano Human non abilita il gioco con Master umano.';
   const action=button(journal?'Verifica predisposizione':'Predisponi prova',async()=>{
    if(!inScope()||nativePrepareBusy.has(key))return;nativePrepareBusy.add(key);action.disabled=true;
    try{
     if(typeof navigator.locks?.request!=='function')throw Error('Il browser non offre il blocco sicuro del journal. Usa un browser supportato per conservare la stessa richiesta.');
     await navigator.locks.request(key,{mode:'exclusive'},async()=>{
      if(!inScope())return;journal=nativePrepareJournal(key,expected);
      if(!journal){journal={schema_version:'c1266-native-prepare-journal/1',request_key:id(),expected,receipt:null};localStorage.setItem(key,JSON.stringify(journal));}
      status.textContent='Verifica della stessa predisposizione…';
      const result=await rpc('mission_native_source_prepare_v1',{...expected,p_request:journal.request_key},user);
      nativePrepareReceipt(result,expected,journal.request_key);journal.receipt=result;localStorage.setItem(key,JSON.stringify(journal));
      if(!inScope())return;
      const fresh=await nativePrepareMetadata(user);if(JSON.stringify(fresh)!==JSON.stringify(expected))throw Error('Ricevuta conservata, ma metadati della sorgente cambiati: serve verifica Staff.');
      status.textContent='Predisposizione tecnica confermata. Il piano Human è un artefatto tecnico; il gioco con Master umano resta disabilitato.';refresh();
     });
    }catch(e){if(inScope())status.textContent='Predisposizione non confermata. La stessa richiesta resta conservata; verifica abilitazione e ricevuta con lo Staff. '+e.message;}
    finally{nativePrepareBusy.delete(key);if(inScope()){action.disabled=false;action.textContent='Verifica predisposizione';}}
   });host.append(action);
  }catch(e){if(inScope())status.textContent='Predisposizione non disponibile. '+e.message;}
 }
 async function sources(){
  if(!isStaff())return;const user=identity(),d=dialog('Archivio missioni'),status=el('p','Caricamento…',{role:'status'});d.append(status);
  try{const r=await rpc('mission_staff_catalog_state_v1',{},user);if(!valid(user)||!d.isConnected)return;
   const uuid=v=>typeof v==='string'&&/^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/i.test(v);
   if(!r||r.schema_version!=='mission-staff-catalog/1'||!Array.isArray(r.missions))throw Error('Catalogo missioni non riconosciuto.');
   const items=r.missions,seen=new Set();for(const m of items){if(!m||!uuid(m.id)||seen.has(m.id)||typeof m.title!=='string'||typeof m.status!=='string'||!['source','protected_test'].includes(m.kind)||typeof m.archived!=='boolean'||!(m.source_id===null||uuid(m.source_id))||m.kind==='source'&&(m.archived||m.source_id!==null)||m.kind==='protected_test'&&m.source_id===null)throw Error('Catalogo missioni non riconosciuto.');seen.add(m.id);}
   let chosen=null,showArchived=false;const controls=el('div',null),picker=select([],null,v=>{chosen=v;sync();}),configure=button('Configura missione',()=>{if(!valid(user)||!isStaff()||!d.isConnected)return;const m=items.find(x=>x.id===chosen);if(m?.kind==='source')editor(m.id,m.title);}),start=button('Avvio o prova protetta',()=>{if(!valid(user)||!isStaff()||!d.isConnected)return;const m=items.find(x=>x.id===chosen);if(m?.kind==='source')board(m.id,m.title);});
   const archivedCount=items.filter(m=>m.archived).length;
   const show=el('input',null,{type:'checkbox'}),toggle=el('label',null,{class:'mg-inline-check'});toggle.append(show,document.createTextNode('Mostra prove concluse ('+archivedCount+')'));show.addEventListener('change',()=>{showArchived=show.checked;render();});
   const sync=()=>{const m=items.find(x=>x.id===chosen),source=m?.kind==='source';configure.disabled=start.disabled=!source;status.textContent=m?.kind==='protected_test'?(m.archived?'Prova conclusa: storico conservato. Per una nuova prova scegli la missione sorgente.':'Prova protetta: conserva la sessione corrente. Per configurare o avviare una nuova prova scegli la missione sorgente.'):'Le prove concluse sono archiviate automaticamente. La missione originale resta disponibile per configurazione e nuove prove.';};
   const render=()=>{const visible=items.filter(m=>showArchived||!m.archived);if(!visible.some(m=>m.id===chosen))chosen=visible[0]?.id??null;picker.replaceChildren();for(const m of visible)picker.append(el('option',m.title+' · '+(m.kind==='protected_test'?(m.archived?'prova conclusa':'prova protetta'):m.status),{value:m.id}));if(chosen)picker.value=chosen;picker.disabled=!visible.length;sync();if(!visible.length)status.textContent='Nessuna missione disponibile.';};
   controls.append(toggle,field('Missione sorgente',picker),configure,start);d.append(controls);render();
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
  const academyStates=new Set(['waiting_roles','evaluating','new_scene','combat_started']);
  const roleReasons=new Set(['own_role_missing','own_role_invalid','waiting_other_roles','ready_to_evaluate','provider_processing','recoverable_not_started','uncertain','failed','review_required','published']);
  const nextActors=new Set(['player','other_players','system','staff','none']);
 let roomScope=null,roomRead=null,roomHost=null,roomError='',cacheUser=null,readSequence=0,staffResumeRead=null,staffRoleRecovery=null,staffChoiceRecovery=null;
 let entryState=null,entryPending=null,entryError='',entryReplayReady=false,countStatusRead=null,countStatusNotice='',countStatusSession=null;
 const entryKey=(user,session)=>`regia-combat-entry/1:${user}:${session}`;
 function validEntry(x,session,request=null){return x?.schema==='regia-combat-entry/1'&&x.master_session_id===session
  &&['unavailable','ready','prepared','open',...(request===null?[]:['not_found'])].includes(x.status)
  &&(x.step_key===null||typeof x.step_key==='string')
  &&(x.run_control_version===null||Number.isSafeInteger(x.run_control_version))
  &&(x.entry_revision===null||Number.isSafeInteger(x.entry_revision))
  &&typeof x.can_prepare==='boolean'&&typeof x.can_open_panel==='boolean'
  &&[null,'REGIA_ENTRY_UNAVAILABLE','REGIA_TURN_AUTHORITY_REQUIRED','REGIA_FATO_PENDING','REGIA_NOT_YOUR_TURN','REGIA_OPERATION_NOT_FOUND'].includes(x.reason_code)
  &&['encounter_id','opening_round_id','public_round_id','publication_id'].every(k=>x[k]===null||UUID.test(x[k]||''))
  &&['main','defense','reaction'].every(k=>typeof x.permissions?.[k]==='boolean')
  &&(request===null?x.request_key===null:x.status==='not_found'?x.request_key===null&&x.reason_code==='REGIA_OPERATION_NOT_FOUND':x.request_key===request);}
 async function readEntry(state,user){
  entryState=null;entryError='';entryPending=null;entryReplayReady=false;
  if(state.state!=='in_corso')return; // La riserva Staff e l'apertura pubblica sono autorità del reader server.
  const key=entryKey(user,state.session_id);let saved=null;
  try{saved=JSON.parse(sessionStorage.getItem(key)||'null');}catch{entryError='Ingresso da verificare: richiesta locale non leggibile.';return;}
  if(saved){if(saved.session!==state.session_id||!UUID.test(saved.request_key||'')){entryError='Ingresso da verificare: richiesta locale non leggibile.';return;}entryPending=saved;}
  try{
   const value=await rpc('regia_combat_entry_state_v1',{p_master_session:state.session_id},user);
   if(!validEntry(value,state.session_id))throw Error('entry_contract');
   entryState=value;
   if(saved){const receipt=await rpc('regia_combat_entry_receipt_v1',{p_master_session:state.session_id,p_request_key:saved.request_key},user);
    if(!validEntry(receipt,state.session_id,saved.request_key))throw Error('entry_receipt');
    if(receipt.status==='not_found'){entryReplayReady=true;entryError='Ricevuta assente: puoi ripetere la stessa apertura conservata.';}
    else if(['prepared','open'].includes(receipt.status)){sessionStorage.removeItem(key);entryPending=null;}
   }
  }catch{entryError='Ingresso Regia non verificabile: nessun comando inviato.';}
 }
 async function prepareEntry(host,state){
  const user=identity(),e=entryState;if(!valid(user)||!e?.can_prepare||entryPending||!Number.isSafeInteger(e.entry_revision)||state.session_id!==roomState?.session_id)return;
  const key=entryKey(user,state.session_id),request_key=id(),saved={session:state.session_id,request_key,revision:e.entry_revision};
  try{sessionStorage.setItem(key,JSON.stringify(saved));entryPending=saved;}catch{entryError='Recupero locale indisponibile: nessun comando inviato.';paintRoom(host,state);return;}
  paintRoom(host,state);
  try{const result=await rpc('regia_combat_entry_prepare_v1',{p_master_session:state.session_id,p_expected_revision:saved.revision,p_request_key:request_key},user);
   if(!validEntry(result,state.session_id,request_key))throw Error('entry_prepare');
   if(['prepared','open'].includes(result.status)){sessionStorage.removeItem(key);entryPending=null;}
  }catch{entryError='Ingresso incerto: verifica la stessa richiesta.';}
  await updateRoom(host,{manual:true});
 }

 async function retryEntry(host,state){
  const t=syncRoom(host);
  if(!roomCurrent(t)||!entryReplayReady||!entryPending||!entryState||roomState?.session_id!==state?.session_id)return;
  const saved=entryPending,user=t.user,session=roomState.session_id;
  if(saved.session!==session||!UUID.test(saved.request_key||'')||!Number.isSafeInteger(saved.revision))return;
  entryReplayReady=false;paintRoom(host,roomState);
  try{
   const receipt=await rpc('regia_combat_entry_receipt_v1',
    {p_master_session:session,p_request_key:saved.request_key},user);
   if(!roomCurrent(t)||!validEntry(receipt,session,saved.request_key))throw Error('entry_receipt_unconfirmed');
   if(receipt.status==='not_found'){
    const result=await rpc('regia_combat_entry_prepare_v1',
     {p_master_session:saved.session,p_expected_revision:saved.revision,p_request_key:saved.request_key},user);
    if(!roomCurrent(t)||!validEntry(result,session,saved.request_key)||!['prepared','open'].includes(result.status))throw Error('entry_retry_unconfirmed');
   }else if(!['prepared','open'].includes(receipt.status))throw Error('entry_receipt_unconfirmed');
   sessionStorage.removeItem(entryKey(user,session));entryPending=null;entryError='';
  }catch{entryError='Ingresso non confermato: richiesta conservata.';}
  if(roomCurrent(t))await updateRoom(host,{manual:true});
 }

 const attempts=new Map(),choiceRequests=new Map(),cachedChoiceRecoveries=new Set(),asyncWorks=new Map();
 function scopeFor(user,loc){return user&&loc?.id?JSON.stringify([user,loc.id]):null;}
 function syncRoom(host){
  const user=identity(),loc=currentLocation(),scope=scopeFor(user,loc);
  if(cacheUser!==user){cacheUser=user;attempts.clear();choiceRequests.clear();cachedChoiceRecoveries.clear();chainFeedback.clear();recoveredWriters.clear();asyncWorks.clear();}
  if(scope!==roomScope||host!==roomHost){for(const c of aborts.values())c.dispose();aborts.clear();abortActor=null;roomEpoch++;roomRead=null;roomState=null;roomSignature='';roomError='';entryState=null;entryPending=null;entryError='';entryReplayReady=false;countStatusRead=null;countStatusNotice='';countStatusSession=null;staffResumeRead=null;staffRoleRecovery=null;staffChoiceRecovery=null;roomScope=scope;roomHost=host;if(host){host.replaceChildren();host.hidden=true;}}
  return {user,loc,scope,epoch:roomEpoch};
 }
 const roomCurrent=t=>t.scope===roomScope&&t.epoch===roomEpoch&&valid(t.user)&&scopeFor(identity(),currentLocation())===t.scope&&roomHost?.isConnected;
 const chainFeedback=new Map(),recoveredWriters=new Set();
 const recoveredWriterKey=(user,session,work)=>JSON.stringify([user,session,work]);
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
 // Read-only receipt for the room chat: it never starts or resumes narrative work.
 function chatPublication(){
  const user=identity(),loc=currentLocation();
  if(!user||!isStaff()||loc?.id!==STAFF_TEST_ROOM||loc.is_test!==true||roomError
   ||scopeFor(user,loc)!==roomScope||!roomHost?.isConnected)return null;
  const parsed=processingFor(roomState),p=parsed.value;
  if(!parsed.valid||p?.state!=='completed'||!UUID.test(p.message_id||'')
   ||typeof p.finalized_at!=='string'||!Number.isFinite(Date.parse(p.finalized_at)))return null;
  return {principal:user,location:loc.id,session:roomState.session_id,work:p.work_id,publication:p.message_id,epoch:roomEpoch};
 }
 // This optional proof permits asking the server for one guarded resume, never provider execution.
 const openingResumeKeys=['schema_version','eligible_to_request','master_session_id','work_id','event_id','request_key','expected_revision','payload_sha256','binding_sha256','release_sha256','source_qualification_sha256','denial_audit_id','proof_sha256'];
 const hasOpeningResume=state=>!!state&&Object.hasOwn(state,'opening_ready_resume');
 function openingResumeProjection(state){
  if(!hasOpeningResume(state))return null;
  const x=state.opening_ready_resume,parsed=processingFor(state),w=parsed.value,q=w?.request;
  if(!nativeExact(x,openingResumeKeys)||x.schema_version!=='mission-opening-ready-resume/1'||x.eligible_to_request!==true
   ||!['master_session_id','work_id','event_id','request_key'].every(k=>UUID.test(x[k]||''))
   ||!['payload_sha256','binding_sha256','release_sha256','source_qualification_sha256','proof_sha256'].every(k=>SHA.test(x[k]||''))
   ||typeof x.denial_audit_id!=='string'||! /^[1-9][0-9]*$/.test(x.denial_audit_id)
   ||!Number.isSafeInteger(x.expected_revision)||x.expected_revision<1||!parsed.valid||w?.state!=='ready'
   ||w.finalized_at!==null||w.message_id!==null||!sameChainRequest(q,q)
   ||x.master_session_id!==state.session_id||x.work_id!==w.work_id||x.event_id!==q.event_id
   ||x.request_key!==q.request_key||x.expected_revision!==q.expected_revision)return null;
  return x;
 }
 const openingResumeTuple=x=>JSON.stringify(openingResumeKeys.map(k=>x[k]));
 function openingResumeAllowed(state,t){return !!(openingResumeProjection(state)&&isStaff()&&t.loc?.id===STAFF_TEST_ROOM
  &&t.loc.is_test===true&&state.can_tick===true&&state.review_required!==true&&!hasCountProjection(state)&&!abortBlocked(state.session_id));}
 // Claimed recovery requires fresh server proof; can_tick and role progress grant nothing.
 // This optional proof permits asking the server for one guarded resume, never provider execution.
 const openingClaimResumeKeys=['schema_version','eligible_to_request','master_session_id','work_id','event_id','request_key','expected_revision','payload_sha256','binding_sha256','release_sha256','source_qualification_sha256','previous_lease_id','dispatch_receipt_id','contract_sha256','contract_release_sha256','resume_audit_id','proof_sha256'];
 const hasOpeningClaimResume=state=>!!state&&Object.hasOwn(state,'opening_claim_resume');
 function openingClaimResumeProjection(state){
  if(!hasOpeningClaimResume(state))return null;
  const x=state.opening_claim_resume,parsed=processingFor(state),w=parsed.value,q=w?.request;
  if(!nativeExact(x,openingClaimResumeKeys)||x.schema_version!=='mission-opening-claim-resume/1'||x.eligible_to_request!==true
   ||!['master_session_id','work_id','event_id','request_key','previous_lease_id','dispatch_receipt_id'].every(k=>typeof x[k]==='string'&&UUID.test(x[k]))
   ||!['payload_sha256','binding_sha256','release_sha256','source_qualification_sha256','contract_sha256','contract_release_sha256','proof_sha256'].every(k=>typeof x[k]==='string'&&SHA.test(x[k]))
   ||typeof x.resume_audit_id!=='string'||! /^[1-9][0-9]*$/.test(x.resume_audit_id)
   ||!Number.isSafeInteger(x.expected_revision)||x.expected_revision<1||!parsed.valid||w?.state!=='uncertain'
   ||w.finalized_at!==null||w.message_id!==null||!sameChainRequest(q,q)
   ||x.master_session_id!==state.session_id||x.work_id!==w.work_id||x.event_id!==q.event_id
   ||x.request_key!==q.request_key||x.expected_revision!==q.expected_revision)return null;
  return x;
 }
 const openingClaimResumePrior13=Object.freeze({"binding_sha256":"d05519cf9ff8fbf845bee6b89006630d4be75661e5846b0d929fe9f1b0c49fb6","contract_release_sha256":"dc602c9eb3e8b6329b0576060f31231c0e942636f2266503c6fffe2a8ec50787","contract_sha256":"11ec71bca76e3be8e9365e435e104a23863b3454b8b98aeb4f62657e21e51533","dispatch_receipt_id":"c9f60059-c2d5-491c-84eb-2a2add3f8431","eligible_to_request":true,"event_id":"7d34505e-35ce-435d-bcef-35532019da7b","expected_revision":1,"master_session_id":"101e5e0a-539d-4173-9b09-ee39003db6a6","payload_sha256":"a8d3b553ed31fdd8b1336fc2e334a23741ce30ff581f4e1aaa45914504a29a8e","previous_lease_id":"b55f8363-6bfd-4907-9059-941eacb7a3b4","proof_sha256":"576dde02b991beaf267eb67526f76dd32c31d631a4fbce1b5f5d0d8c06288579","release_sha256":"6ffb544f8a673da0c13abf815e65910877c3e57ef38a3cf0fcc5d7c199d9c2ac","request_key":"44f24162-a83d-4bbe-ab75-3071f42ce262","resume_audit_id":"23","schema_version":"mission-opening-claim-resume/1","source_qualification_sha256":"050a73ac8536035124c9b8ea53a58f984eb6aef8d7dcf7ac89d57b52f36af935","work_id":"ba93bb63-3d57-4da4-b3d6-3401101ab6af"});
 const openingClaimResumePrior15=Object.freeze({"binding_sha256":"d05519cf9ff8fbf845bee6b89006630d4be75661e5846b0d929fe9f1b0c49fb6","contract_release_sha256":"dc602c9eb3e8b6329b0576060f31231c0e942636f2266503c6fffe2a8ec50787","contract_sha256":"11ec71bca76e3be8e9365e435e104a23863b3454b8b98aeb4f62657e21e51533","dispatch_receipt_id":"c9f60059-c2d5-491c-84eb-2a2add3f8431","eligible_to_request":true,"event_id":"7d34505e-35ce-435d-bcef-35532019da7b","expected_revision":1,"master_session_id":"101e5e0a-539d-4173-9b09-ee39003db6a6","payload_sha256":"a8d3b553ed31fdd8b1336fc2e334a23741ce30ff581f4e1aaa45914504a29a8e","previous_lease_id":"b55f8363-6bfd-4907-9059-941eacb7a3b4","proof_sha256":"4c0e08b891f6f8ca24ed2bb9b794d243518faf0538d722fae8d6e37c48c3115f","release_sha256":"fedcaa039d34a69c39d9b07196e90496eb046fd0228102c1d88d2b5cd6a3b6ee","request_key":"44f24162-a83d-4bbe-ab75-3071f42ce262","resume_audit_id":"23","schema_version":"mission-opening-claim-resume/1","source_qualification_sha256":"050a73ac8536035124c9b8ea53a58f984eb6aef8d7dcf7ac89d57b52f36af935","work_id":"ba93bb63-3d57-4da4-b3d6-3401101ab6af"});
 const openingClaimResumeTuple=x=>JSON.stringify(openingClaimResumeKeys.map(k=>x[k]));
 function openingClaimResumeAllowed(state,t){return !!(openingClaimResumeProjection(state)&&isStaff()&&t.loc?.id===STAFF_TEST_ROOM
  &&t.loc.is_test===true&&state.review_required!==true&&!hasCountProjection(state)&&!abortBlocked(state.session_id));}
 // Count reconciliation is a server-attested technical status action, never a work retry.
 const countProjectionKeys=['schema_version','work_id','master_session_id','event_id','request_key','revision','dispatch_receipt_id','measurement_id','generation_request_sha256','policy_snapshot_sha256','release_sha256','failure_code','operation'];
 const countStatusRequestKeys=['schema_version','work_id','master_session_id','event_id','request_key','expected_revision','dispatch_receipt_id','measurement_id','generation_request_sha256','policy_snapshot_sha256','release_sha256','failure_code'];
 const countStatusResponseKeys=['schema_version','master_session_id','work_id','event_id','request_key','revision','receipt_id','result_sha256','state','retry','provider_retry_allowed'];
 const hasCountProjection=state=>!!state&&Object.hasOwn(state,'count_reconciliation')&&state.count_reconciliation!==null;
 function countStatusProjection(state){
  if(!hasCountProjection(state))return null;
  const x=state.count_reconciliation,p=processingFor(state),w=p.value,q=w?.request;
  if(!nativeExact(x,countProjectionKeys)||x.schema_version!=='mission-generic-count-reconciliation/1'||x.operation!=='status_only'
   ||!['MISSION_INPUT_COUNT_UNKNOWN','MISSION_INPUT_COUNT_OVERFLOW'].includes(x.failure_code)
   ||!['work_id','master_session_id','event_id','request_key','dispatch_receipt_id','measurement_id'].every(k=>UUID.test(x[k]||''))
   ||!['generation_request_sha256','policy_snapshot_sha256','release_sha256'].every(k=>SHA.test(x[k]||''))
   ||!Number.isSafeInteger(x.revision)||x.revision<1||!p.valid||!['claimed','uncertain'].includes(w?.state)
   ||w.finalized_at!==null||w.message_id!==null||x.master_session_id!==state.session_id
   ||x.work_id!==w.work_id||x.event_id!==w.event_id||x.request_key!==w.request_key||x.revision!==w.revision
   ||!nativeExact(q,['schema_version','master_session_id','event_id','request_key','expected_revision'])
   ||q.schema_version!=='mission-generic-request/1'||q.master_session_id!==x.master_session_id
   ||q.event_id!==x.event_id||q.request_key!==x.request_key||q.expected_revision!==x.revision)return null;
  return x;
 }
 function countStatusTuple(x){return JSON.stringify(countProjectionKeys.map(k=>x[k]));}
 function countStatusRequest(x){
  const request={schema_version:'mission-generic-count-status/1',work_id:x.work_id,master_session_id:x.master_session_id,
   event_id:x.event_id,request_key:x.request_key,expected_revision:x.revision,dispatch_receipt_id:x.dispatch_receipt_id,
   measurement_id:x.measurement_id,generation_request_sha256:x.generation_request_sha256,
   policy_snapshot_sha256:x.policy_snapshot_sha256,release_sha256:x.release_sha256,failure_code:x.failure_code};
  if(!nativeExact(request,countStatusRequestKeys))throw Error('count_status_request_shape');return request;
 }
 function countStatusResponse(r,x){
  if(!nativeExact(r,countStatusResponseKeys)||r.schema_version!=='mission-generic-count-status-response/1'
   ||r.master_session_id!==x.master_session_id||r.work_id!==x.work_id||r.event_id!==x.event_id
   ||r.request_key!==x.request_key||r.revision!==x.revision||!UUID.test(r.receipt_id||'')
   ||!SHA.test(r.result_sha256||'')||r.state!=='failed'||r.retry!==false||r.provider_retry_allowed!==false)
   throw Error('count_status_response_unconfirmed');return r;
 }
 async function reconcileCountStatus(host){
  const t=syncRoom(host),old=roomState,proof=countStatusProjection(old);
  if(!roomCurrent(t)||!proof||countStatusRead||liveAttempt(old)||abortBlocked(old.session_id))return;
  const token={scope:t.scope,session:proof.master_session_id,tuple:countStatusTuple(proof),request:Object.freeze(clone(countStatusRequest(proof)))};
  countStatusRead=token;countStatusSession=token.session;countStatusNotice='Verifica tecnica della stessa ricevuta in corso…';paintRoom(host,old);
  try{
   const fresh=await rpc('mission_generic_room_state_v1',{p_location:t.loc.id},t.user);
   if(!roomCurrent(t)||countStatusRead!==token)return;
   const current=countStatusProjection(fresh);roomState=fresh;roomError='';
   if(!current||countStatusTuple(current)!==token.tuple||liveAttempt(fresh)||abortBlocked(fresh.session_id))
    throw Error('count_status_context_changed');
   // This dedicated HTTP shape routes only to db.status; no claim/count/generation is dispatched.
   const result=await client.functions.invoke('mission_generic_ai',{body:clone(token.request)});
   if(!roomCurrent(t)||countStatusRead!==token)return;
   if(result.error)throw Error('count_status_transport_unconfirmed');
   countStatusResponse(result.data,current);
   countStatusNotice='Ricevuta tecnica confermata: il lavoro è fallito, senza nuovo tentativo provider. Lo storico resta conservato.';
   await updateRoom(host,{manual:true,verifyOnly:true});
  }catch{
   if(roomCurrent(t)&&countStatusRead===token){countStatusNotice='Ricevuta tecnica non confermata. Aggiorna la regia per rileggere la stessa richiesta; nessun nuovo Count o racconto è avviato.';paintRoom(host,roomState);}
  }finally{if(countStatusRead===token){countStatusRead=null;if(roomCurrent(t)&&roomState)paintRoom(host,roomState);}}
 }
 function currentAttempt(state){return [...attempts.values()].reverse().find(a=>a.user===cacheUser&&a.session===state.session_id&&(a.key==='tick:'+state.progress_key||a.tickRecoveryKey&&a.key==='tick:'+state.progress_key+':recovery:'+a.tickRecoveryKey||a.work===state.processing?.work_id))||null;}
  function liveAttempt(state){return [...attempts.values()].some(a=>a.user===cacheUser&&a.session===state.session_id&&a.inFlight);}
  function academyFlow(state){
   const hasState=Object.hasOwn(state,'flow_state'),hasPublication=Object.hasOwn(state,'flow_publication_id');
   if(!hasState&&!hasPublication)return null; // Ordinary missions on the published RPC.
   if(!hasState||!hasPublication)throw Error('mission_academy_flow_shape');
   const flow=state.flow_state,publication=state.flow_publication_id;
   if(flow===null&&publication===null)return null;
   if(!academyStates.has(flow)||!(publication===null||UUID.test(publication))
    ||(['new_scene','combat_started'].includes(flow)&&publication===null))throw Error('mission_academy_flow_invalid');
   return flow;
  }
  function roleProgress(state){
   const fields=['flow_reason','next_actor','roles_received','roles_required','source_revision'];
   if(!fields.some(k=>Object.hasOwn(state,k)))return null; // Legacy projection remains readable.
   if(!fields.every(k=>Object.hasOwn(state,k)))throw Error('mission_role_progress_shape');
   const {flow_reason:reason,next_actor:actor,roles_received:received,roles_required:required,source_revision:revision}=state;
   const detail=state.flow_detail;
   if(!roleReasons.has(reason)||!nextActors.has(actor)||!Number.isSafeInteger(required)||required<1||required>4
    ||!Number.isSafeInteger(received)||received<0||received>required||!SHA.test(revision||''))throw Error('mission_role_progress_invalid');
   if(!(detail===undefined||detail===null||['latest_role_not_eligible','character_mismatch','left_before_submission','role_gate_mismatch'].includes(detail)))throw Error('mission_role_detail_invalid');
   if(['latest_role_not_eligible','character_mismatch','left_before_submission'].includes(detail)&&reason!=='own_role_invalid')throw Error('mission_role_detail_reason_invalid');
   return {reason,actor,received,required,revision,detail:detail??null};
  }
  function staffAcademyRole(state,loc=currentLocation()){
   if(!isStaff()||loc?.id!==STAFF_TEST_ROOM||loc?.is_test!==true||academyFlow(state)===null)return null;
   return roleProgress(state);
  }
  function roleStatusText(progress,flow){
   if(!progress)return null;
   const {reason,received,required,detail}=progress;
   switch(reason){
    case 'own_role_missing':return flow==='new_scene'
      ?'Nuova scena · Il Fato ha aperto la fase successiva. Scrivi la tua role per continuare.'
      :'In attesa delle role · Scrivi la tua role per continuare.';
    case 'own_role_invalid':return detail==='left_before_submission'
      ?'La tua partecipazione non è più attiva. Un’altra role non sblocca la missione: contatta lo Staff per verifica o riammissione.'
      :detail==='character_mismatch'||detail==='latest_role_not_eligible'
      ?'La tua ultima role non è collegata al PG iscritto alla missione. Seleziona quel personaggio e invia una nuova role; il messaggio precedente resta nello storico.'
      :'La tua ultima role non è idonea per questa fase. Verifica il motivo con lo Staff prima di inviarne un’altra.';
    case 'waiting_other_roles':return `In attesa delle role · ${received}/${required} ricevute. Manca ${required-received===1?'un partecipante':`${required-received} partecipanti`}; la valutazione partirà quando avranno scritto.`;
    case 'ready_to_evaluate':return 'Il Fato sta valutando la scena · Le role necessarie sono state ricevute; non serve premere Avanza.';
    case 'provider_processing':return 'Il Fato sta elaborando la scena · Attendi l’esito, senza reinviare la stessa role.';
    case 'recoverable_not_started':return 'La valutazione non è confermata come avviata. Le role sono conservate; lo Staff deve verificare la stessa richiesta prima di riprenderla.';
    case 'uncertain':return 'Esito non ancora confermato. Le role sono conservate; lo Staff deve verificare la stessa richiesta, senza ripeterla alla cieca.';
    case 'failed':
    case 'review_required':return detail==='role_gate_mismatch'
      ?'Le role visibili non soddisfano ancora il controllo server della fase. Non inviarne altre alla cieca: lo Staff deve verificare il vincolo e sbloccare la scena.'
      :'Il Fato è fermo. Le role sono conservate; lo Staff deve verificare e sbloccare questa scena.';
    case 'published':return flow==='combat_started'?'Scontro iniziato · Dichiara l’azione nel pannello Scontro.':'Nuova scena · Puoi scrivere una nuova role.';
   }
   return null;
  }
  function driverFor(state){
   if(!state||!Object.hasOwn(state,'driver_state'))return {optedIn:false,valid:true,value:null};
   const d=state.driver_state,fields=['schema_version','master_session_id','source_revision','kind','tick_status'];
   if(!d||Array.isArray(d)||Object.keys(d).length!==fields.length||!fields.every(k=>Object.hasOwn(d,k))
    ||d.schema_version!=='mission-driver-state/1'||!UUID.test(state.session_id||'')||d.master_session_id!==state.session_id
    ||!['tick','native','none'].includes(d.kind)
    ||!(SHA.test(d.source_revision||'')||d.source_revision===null&&d.kind==='none')
    ||!(d.source_revision===state.source_revision
     ||d.kind==='none'&&d.source_revision===null&&!Object.hasOwn(state,'source_revision'))
    ||d.kind!=='tick'&&d.tick_status!==null)return {optedIn:true,valid:false,value:null};
   return {optedIn:true,valid:true,value:d};
  }
  function tickStatusFor(state,t={user:identity(),loc:currentLocation()}){
   const driver=driverFor(state);
   if(driver.optedIn&&!driver.valid)return {applicable:true,valid:false,value:null,driver};
   if(driver.optedIn&&driver.value.kind!=='tick')return {applicable:false,valid:true,value:null,driver};
   const applicable=isStaff()&&t.loc?.id===STAFF_TEST_ROOM&&t.loc?.is_test===true
    &&(driver.optedIn||state?.session_id==='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9');
   if(!applicable)return {applicable:false,valid:true,value:null,driver};
   const x=driver.optedIn?driver.value.tick_status:state.staff_tick_status;
   const fields=['schema_version','master_session_id','source_revision','request_key','owned_by_me','state',
    'work_id','work_state','retry_request_key','can_resume','recovery_key','acknowledged_retry_from_work_id'];
   const noWorkV3=x?.schema_version==='mission-generic-staff-tick-status/3';
   if(noWorkV3)fields.push('recovery_kind','original_result_sha256','acknowledged_recovery_key');
   const uuidOrNull=x=>x===null||UUID.test(x||'');
   if(!x||Array.isArray(x)||Object.keys(x).length!==fields.length||!fields.every(k=>Object.hasOwn(x,k))
    ||!['mission-generic-staff-tick-status/2','mission-generic-staff-tick-status/3'].includes(x.schema_version)||x.master_session_id!==state.session_id
    ||!SHA.test(x.source_revision||'')||x.source_revision!==state.source_revision
    ||!['absent','attested','released','blocked',...(noWorkV3?['no_work_released']:[])].includes(x.state)
    ||typeof x.owned_by_me!=='boolean'||typeof x.can_resume!=='boolean'
    ||!['request_key','work_id','retry_request_key','recovery_key','acknowledged_retry_from_work_id'].every(k=>uuidOrNull(x[k]))
    ||!(x.work_state===null||workStates.has(x.work_state)))return {applicable:true,valid:false,value:null};
   if(noWorkV3&&!(x.recovery_kind==='no_work_progress_receipt'&&SHA.test(x.original_result_sha256||'')
    &&UUID.test(x.recovery_key||'')&&x.recovery_key===x.request_key&&UUID.test(x.retry_request_key||'')&&x.retry_request_key!==x.request_key
    &&(x.acknowledged_recovery_key===null||x.acknowledged_recovery_key===x.recovery_key)
    &&x.acknowledged_retry_from_work_id===null&&['no_work_released','attested'].includes(x.state)))return {applicable:true,valid:false,value:null};
   if(x.state==='no_work_released'){
    if(!noWorkV3||x.work_id!==null||x.work_state!==null||x.acknowledged_recovery_key!==null||x.can_resume&&!x.owned_by_me)return {applicable:true,valid:false,value:null};
   }else if(x.state==='absent'){
    if(x.owned_by_me||x.can_resume||['request_key','work_id','work_state','retry_request_key','recovery_key','acknowledged_retry_from_work_id'].some(k=>x[k]!==null))
     return {applicable:true,valid:false,value:null};
   }else if(x.state==='blocked'){
    if(x.can_resume||['work_id','work_state','retry_request_key','recovery_key','acknowledged_retry_from_work_id'].some(k=>x[k]!==null))
     return {applicable:true,valid:false,value:null};
   }else{
    if(!UUID.test(x.request_key||'')||!UUID.test(x.work_id||'')||!workStates.has(x.work_state))
     return {applicable:true,valid:false,value:null};
    if(x.acknowledged_retry_from_work_id===x.work_id)return {applicable:true,valid:false,value:null};
    if(x.state==='attested'&&(x.can_resume||(!noWorkV3&&(x.retry_request_key!==null||x.recovery_key!==null))||noWorkV3&&x.acknowledged_recovery_key!==x.recovery_key))
     return {applicable:true,valid:false,value:null};
    if(x.state==='released'&&(x.work_state!=='failed'||x.recovery_key!==x.work_id
     ||x.can_resume&&(!x.owned_by_me||!UUID.test(x.retry_request_key||'')||x.retry_request_key===x.request_key)))
     return {applicable:true,valid:false,value:null};
   }
   return {applicable:true,valid:true,value:x};
  }
  function reconcileTickAttempts(state,t,projection=tickStatusFor(state,t)){
   if(!projection.applicable||!projection.valid||!roomCurrent(t))return;
   const receipt=projection.value;
   if(!['attested','released','no_work_released'].includes(receipt.state)||!UUID.test(receipt.request_key||''))return;
   for(const a of attempts.values()){
    if(a.user!==t.user||a.session!==state.session_id||a.kind!=='tick'||a.inFlight||a.outcome!=='uncertain'
     ||a.staffTickSource!==receipt.source_revision||a.body?.schema_version!=='mission-generic-staff-tick/1'
     ||Object.keys(a.body).length!==3||a.body.master_session_id!==state.session_id
     ||a.body.source_revision!==receipt.source_revision)continue;
    // Own retry needs its exact successor ACK; a released predecessor with no successor proves no retry delivery.
    if(receipt.owned_by_me&&a.tickRecoveryKey&&(a.noWorkRecovery?receipt.acknowledged_recovery_key:receipt.acknowledged_retry_from_work_id)!==a.tickRecoveryKey)continue;
    // Unique immutable tick ownership is authoritative; no record/nonce is removed or replaced.
    a.outcome=receipt.owned_by_me?'confirmed':'delegated';
    a.staffTickReceiptKey=receipt.request_key;
    a.staffTickState=receipt.owned_by_me?'replayed':null;
   }
  }
  function mayCreateStaffTick(projection,explicitNoWork=false){
   if(projection.driver?.optedIn&&(!projection.driver.valid||projection.driver.value.kind!=='tick'))return false;
   if(!projection.applicable)return true;
   if(!projection.valid)return false;
   const x=projection.value;
   // Absent is the first-tick case, not evidence of another Staff owner. Existing normal gates still apply.
   return x.state==='absent'||x.state==='released'&&x.owned_by_me&&x.can_resume
    ||explicitNoWork&&x.state==='no_work_released'&&x.owned_by_me&&x.can_resume;
  }
  function unresolvedTickForSession(state){
   if(staffAcademyRole(state)===null)return null;
   const processing=processingFor(state);if(!processing.valid)return null;
   const work=processing.value,publication=state.flow_publication_id??null;
   return [...attempts.values()].reverse().find(a=>a.user===cacheUser&&a.session===state.session_id&&a.kind==='tick'
    &&a.outcome==='uncertain'&&!a.inFlight
    &&!(work?.work_id&&work.work_id!==a.prior_work_id)
    &&!(publication&&publication!==a.prior_publication_id))||null;
  }
  function statusText(state){
  if(roomError)return roomError;
  if(state.review_required===true&&roleProgress(state)===null)return 'La scena richiede una valutazione dello staff prima di continuare.';
  const choice=choiceRequests.get(choiceKey(state));
  if(choice?.inFlight)return 'Invio della scelta in corso. La lettura della stanza continua.';
  if(choice?.phase==='uncertain')return 'La scelta non è ancora confermata. Verifica la stessa scelta prima di inviarne un’altra.';
  if(choice?.phase==='confirmed')return 'Scelta confermata. Aggiornamento della fase in corso…';
  if(choice?.phase==='rejected')return 'La scelta è stata respinta. Aggiorna lo stato prima di scegliere nuovamente.';
  const parsed=processingFor(state);if(!parsed.valid)return 'Stato di elaborazione non disponibile. Aggiorna; nessun nuovo invio automatico.';
   const p=parsed.value,a=currentAttempt(state);
   if(hasOpeningClaimResume(state)){if(!openingClaimResumeProjection(state))return 'Ripresa della lavorazione non verificabile. Aggiorna la regia.';if(openingClaimResumeRecorded(state,cacheUser))return 'Ripresa non disponibile o già registrata in questo browser. Nessun invio viene ripetuto.';return 'Il server consente di riprendere la stessa lavorazione interrotta prima del provider. Usa Riprendi lavorazione.';}
   if(hasOpeningResume(state)){if(!openingResumeProjection(state))return 'Ripresa dell’apertura non verificabile. Aggiorna la regia; nessun nuovo invio automatico.';if(openingResumeRecorded(state,cacheUser))return 'La ripresa della stessa apertura è già registrata. La verifica continua senza ripetere l’invio.';return 'Il server consente di verificare e riprendere la stessa apertura. Usa Riprendi apertura.';}
   const asyncMessage=asyncNotice(state);if(asyncMessage)return asyncMessage;
   const flow=academyFlow(state),role=roleProgress(state);
   if(unresolvedTickForSession(state))return 'Un invio precedente della valutazione non è confermato, anche dopo nuove role. Le role sono conservate; lo Staff può verificare l’invio. Se non compare un work, serve un recupero server, non un nuovo tick.';
   if(a?.staffTickState&&['confirmed','waiting'].includes(a.outcome)&&role?.revision===a.staffTickSource&&role.reason!=='published'){
    if(a.staffTickState==='existing_work')return 'Il server ha trovato una lavorazione già aperta. Nessun nuovo tick è stato creato; verifica lo stato della stessa richiesta.';
    if(a.staffTickState==='replayed')return 'Il server ha riconosciuto la ricevuta della valutazione precedente. Attendi la pubblicazione o verifica il work; non inviare un nuovo tick.';
    if(a.staffTickState==='issued')return 'Valutazione registrata dal server. Il Fato sta preparando la scena; se non compare un work, lo Staff deve verificare la ricevuta.';
   }
   if(flow==='combat_started'&&p?.state==='failed')return 'Scontro iniziato. La lavorazione del PNG richiede una verifica dello Staff; non ripetere l’azione.';
   if(flow==='combat_started'&&p?.state==='uncertain')return 'Scontro iniziato. L’esito non è confermato; lo stato si aggiorna senza ripetere l’azione.';
   if(flow==='combat_started')return 'Scontro iniziato. Il server sta raccogliendo le dichiarazioni e aggiorna il round.';
   if(role){
    if(role.reason==='own_role_invalid'||role.detail==='role_gate_mismatch')return roleStatusText(role,flow);
    if(role.reason==='recoverable_not_started'&&a?.outcome==='uncertain')return 'Ripresa della stessa richiesta non confermata. Le role sono conservate; lo Staff deve controllare la ricevuta prima di qualunque nuovo tentativo.';
    if(role.reason==='recoverable_not_started'&&(a?.inFlight||a?.outcome==='waiting'))return 'Verifica della stessa richiesta in corso. Le role sono conservate; attendi il nuovo stato server.';
    if(p?.state==='uncertain')return roleStatusText({...role,reason:'uncertain'},flow);
    if(p?.state==='failed'&&role.reason==='ready_to_evaluate'&&staffAcademyRole(state)!==null)return roleStatusText(role,flow);
    if(p?.state==='failed')return roleStatusText({...role,reason:'failed'},flow);
    return roleStatusText(role,flow);
   }
   if(p?.state==='failed')return 'Il Fato richiede una verifica dello staff. Nessun nuovo tentativo automatico.';
   if(p?.state==='uncertain')return 'L’esito del Fato non è ancora confermato. Lo stato si aggiorna senza ripetere l’invio.';
   if(flow==='waiting_roles')return 'In attesa delle role';
   if(flow==='evaluating')return 'Il Fato sta valutando la scena';
   if(flow==='new_scene')return 'Nuova scena';
   if(flow==='combat_started')return 'Scontro iniziato';
  if(p&&['ready','claimed','authorized','provider_started'].includes(p.state))return a?.outcome==='uncertain'?'Invio non ancora confermato. Verifica dello stato in corso, senza ripetere la richiesta.':'Il Fato sta preparando la scena. Puoi attendere qui: lo stato si aggiorna automaticamente.';
  if(p?.state==='completed'&&a?.work===p.work_id)return p.message_id?'Il Fato ha pubblicato il racconto nella chat.':'Elaborazione completata. Lo stato della missione si aggiorna automaticamente.';
  if(a?.outcome==='uncertain')return 'Invio non ancora confermato. Lo stato si aggiorna senza ripetere la richiesta.';
  if(a?.outcome==='failed')return 'Il Fato richiede una verifica dello staff. Nessun nuovo tentativo automatico.';
  if(a?.inFlight||a?.outcome==='waiting')return 'Il Fato sta preparando la scena. Puoi attendere qui: lo stato si aggiorna automaticamente.';
  if(p?.state==='completed')return p.message_id?'Il Fato ha pubblicato il racconto nella chat.':'Elaborazione completata. Lo stato della missione si aggiorna automaticamente.';
  return state.state==='preparazione'?'Il Fato sta preparando l’apertura della missione.':state.can_tick?'Missione in corso.':'La missione è in pausa o conclusa.';
 }
  function choicesAllowed(state){
   if(academyFlow(state)!==null)return false;
   const parsed=processingFor(state),p=parsed.value,a=currentAttempt(state);
  const unresolved=asyncBlocked(state)||a&&['uncertain','failed','waiting'].includes(a.outcome)&&!(p?.state==='completed'&&a.work===p.work_id);
  return state.review_required!==true&&parsed.valid&&!unresolved&&Number.isSafeInteger(state.choice_context?.master_control_version)&&Number.isSafeInteger(state.choice_context?.run_control_version)&&!roomError&&!choiceRequests.has(choiceKey(state))&&!liveAttempt(state)&&state.state==='in_corso'
   &&state.choice_context?.narration_pending!==true&&(!p||p.state==='completed');
 }
 function paintRoom(host,state){
  if(!host||!state)return;
  if(currentLocation()?.id===STAFF_TEST_ROOM&&currentLocation()?.is_test===true)host.setAttribute('data-mg-build','C1266-FREE-NARRATIVE-001');
  else host.removeAttribute('data-mg-build');
  if(abortBlocked(state.session_id)){host.querySelectorAll('button').forEach(b=>b.disabled=true);}style();
  let title=host.querySelector('[data-mg-room-title]'),status=host.querySelector('[data-mg-room-status]'),actions=host.querySelector('[data-mg-room-actions]');
  if(!title||!status||!actions){host.replaceChildren();host.className='mg-room';title=el('strong','',{'data-mg-room-title':''});status=el('p','',{'data-mg-room-status':'',role:'status','aria-live':'polite','aria-atomic':'true'});actions=el('div',null,{'data-mg-room-actions':''});host.append(title,status,actions,button('Aggiorna regia',()=>updateRoom(host,{manual:true})));roomSignature='';}
  host.hidden=false;const heading='Missione · '+(state.objective||state.step_key||'');if(title.textContent!==heading)title.textContent=heading;
   const flow=academyFlow(state),choices=flow===null?(Array.isArray(state.choices)?state.choices:state.choices?.choices||[]):[];
   const sig=JSON.stringify([state.session_id,state.step_key,state.objective,flow,state.flow_publication_id,choices,state.choice_context?.master_control_version,state.choice_context?.run_control_version]);
  if(sig!==roomSignature){roomSignature=sig;actions.replaceChildren();
   for(const c of choices){if(typeof c.trigger_key!=='string'||typeof c.label!=='string')continue;const b=button(c.label,()=>submitChoice(host,c.trigger_key));b.setAttribute('data-mg-choice','');actions.append(b);}
  }
  for(const b of actions.querySelectorAll('[data-mg-choice]'))b.disabled=!choicesAllowed(state);
  const pending=choiceRequests.get(choiceKey(state));let retry=host.querySelector('[data-mg-choice-retry]');
  if(pending?.phase==='uncertain'){if(!retry){retry=button('Verifica la stessa scelta',()=>submitChoice(host,null,true));retry.setAttribute('data-mg-choice-retry','');host.append(retry);}retry.disabled=state.review_required===true||pending.inFlight;}
  else if(retry)retry.remove();
  const processing=processingFor(state),claim=processing.value;
  const role=roleProgress(state);
  const countProof=countStatusProjection(state),countReserved=hasCountProjection(state);
  let countCheck=host.querySelector('[data-mg-count-status]'),countNotice=host.querySelector('[data-mg-count-status-notice]');
  if(countProof){
   if(!countCheck){countCheck=button('Verifica la stessa ricevuta tecnica',()=>reconcileCountStatus(host));countCheck.setAttribute('data-mg-count-status','');host.append(countCheck);}
   countCheck.disabled=!!roomError||!!countStatusRead||liveAttempt(state)||abortBlocked(state.session_id);
  }else countCheck?.remove();
  const countText=countReserved&&!countProof?'Ricevuta Count non verificabile: nessun nuovo tentativo è autorizzato. Aggiorna la regia.':state.session_id===countStatusSession?countStatusNotice:'';
  if(countText){if(!countNotice){countNotice=el('p','',{role:'status','data-mg-count-status-notice':''});host.append(countNotice);}countNotice.textContent=countText;}else countNotice?.remove();
  let openingResume=host.querySelector('[data-mg-opening-resume]');
  if(openingResumeAllowed(state,{loc:currentLocation(),user:cacheUser})){
   if(!openingResume){openingResume=button('Riprendi apertura',()=>staffResumeOpening(host));openingResume.setAttribute('data-mg-opening-resume','');host.append(openingResume);}
   const proof=openingResumeProjection(state),key=JSON.stringify([cacheUser,state.session_id,'opening-resume:'+proof.proof_sha256]);
   openingResume.disabled=!!roomError||!!staffResumeRead||liveAttempt(state)||attempts.has(key)||openingResumeRecorded(state,cacheUser)||abortBlocked(state.session_id);
  }else openingResume?.remove();
  let openingClaimResume=host.querySelector('[data-mg-opening-claim-resume]');
  if(openingClaimResumeAllowed(state,{loc:currentLocation(),user:cacheUser})){
   if(!openingClaimResume){openingClaimResume=button('Riprendi lavorazione',()=>staffResumeClaimedOpening(host));openingClaimResume.setAttribute('data-mg-opening-claim-resume','');host.append(openingClaimResume);}
   const proof=openingClaimResumeProjection(state),key=JSON.stringify([cacheUser,state.session_id,'opening-claim-resume:'+proof.proof_sha256]);
   openingClaimResume.disabled=!!roomError||!!staffResumeRead||liveAttempt(state)||attempts.has(key)||openingClaimResumeRecorded(state,cacheUser)||abortBlocked(state.session_id);
  }else openingClaimResume?.remove();
  const readyRecovery=claim?.state==='ready'&&claim.finalized_at===null
   &&(role?.reason==='recoverable_not_started'||recoveredWriters.has(recoveredWriterKey(cacheUser,state.session_id,claim.work_id)));
  const uncertainRecovery=claim?.state==='uncertain'&&(!role||role.reason==='uncertain'||academyFlow(state)==='combat_started');
  const claimedRecovery=processing.valid&&staffClaimReconciliationAllowed(state,{loc:currentLocation(),user:cacheUser},claim);
  const countedRecovery=countedResumeAllowed(state,{loc:currentLocation(),user:cacheUser});
  let resume=host.querySelector('[data-mg-claim-resume]');
  if(isStaff()&&currentLocation()?.id===STAFF_TEST_ROOM&&currentLocation()?.is_test&&processing.valid
   &&!hasOpeningResume(state)&&!hasOpeningClaimResume(state)&&!countReserved&&(claimedRecovery||state.can_tick&&state.review_required!==true&&(readyRecovery||uncertainRecovery))){
   if(!resume){resume=button('',()=>{const s=roomState;if(!s)return;const p=processingFor(s).value,r=roleProgress(s);if(countedResumeAllowed(s,{loc:currentLocation(),user:cacheUser}))void staffResumeCounted(host);else if(p?.state==='claimed')void staffReconcileClaimed(host);else if(p?.state==='ready'&&(r?.reason==='recoverable_not_started'||recoveredWriters.has(recoveredWriterKey(cacheUser,s.session_id,p.work_id))))void staffResumeReady(host);else maybeDispatch(s,syncRoom(host),true);});resume.setAttribute('data-mg-claim-resume','');host.append(resume);}
   resume.textContent=claimedRecovery?'Verifica la stessa ricevuta':readyRecovery?'Verifica e riprendi la stessa richiesta':'Verifica o riprendi la stessa richiesta';
   const suffix=countedRecovery?':counted-resume':claimedRecovery?':reconcile-claimed':readyRecovery?':reclaim-ready':':reclaim';
   const key=JSON.stringify([cacheUser,state.session_id,'work:'+claim.work_id+':'+claim.revision+suffix]);
   resume.disabled=!!roomError||!!staffResumeRead||liveAttempt(state)||attempts.has(key)||abortBlocked(state.session_id)||(countedRecovery&&countedResumeRecorded(cacheUser,state,claim));
  }else if(resume)resume.remove();
  let roleRecovery=host.querySelector('[data-mg-role-recovery]');
  if(isStaff()&&currentLocation()?.id===STAFF_TEST_ROOM&&currentLocation()?.is_test
   &&processing.valid&&claim?.state==='failed'
   &&(scopedFailedNarrationRecovery(state,claim)||state.can_tick&&role?.reason==='failed')){
   if(!roleRecovery){roleRecovery=button('Verifica recupero del Fato o della Regia',()=>staffRecoverIdenticalRole(host));roleRecovery.setAttribute('data-mg-role-recovery','');host.append(roleRecovery);}
   roleRecovery.disabled=!!roomError||!!staffRoleRecovery||liveAttempt(state)||abortBlocked(state.session_id);
  }else if(roleRecovery)roleRecovery.remove();
  let combatRecovery=host.querySelector('[data-mg-combat-recovery]');
  if(isStaff()&&currentLocation()?.id===STAFF_TEST_ROOM&&currentLocation()?.is_test
   &&flow==='combat_started'&&state.can_tick&&state.review_required!==true
   &&processing.valid&&claim?.state==='failed'&&claim.finalized_at!==null){
   if(!combatRecovery){combatRecovery=button('Verifica e recupera la lavorazione dello scontro',()=>staffRecoverCachedChoice(host));combatRecovery.setAttribute('data-mg-combat-recovery','');host.append(combatRecovery);}
   combatRecovery.disabled=!!roomError||!!staffChoiceRecovery||liveAttempt(state)||cachedChoiceRecoveries.has(claim.work_id);
  }else if(combatRecovery)combatRecovery.remove();
  const noWorkTick=tickStatusFor(state);
  let noWorkResume=host.querySelector('[data-mg-no-work-resume]');
  if(noWorkTick.valid&&noWorkTick.value?.state==='no_work_released'&&noWorkTick.value.owned_by_me&&noWorkTick.value.can_resume){
   if(!noWorkResume){noWorkResume=button('Riprendi la valutazione delle role',()=>{const s=roomState;if(s)maybeDispatch(s,syncRoom(host),false,true);});noWorkResume.setAttribute('data-mg-no-work-resume','');host.append(noWorkResume);}
   const proof=noWorkTick.value,journalKey=journalPrefix(cacheUser,state.session_id)+selectorKey({kind:'staff_tick',source_revision:proof.source_revision})+':no-work:'+proof.recovery_key+':'+proof.retry_request_key;
   noWorkResume.disabled=!!roomError||liveAttempt(state)||abortBlocked(state.session_id)||readJournal(journalKey,cacheUser,state.session_id)!==null;
  }else noWorkResume?.remove();
  let tickCheck=host.querySelector('[data-mg-tick-check]');
  if(isStaff()&&currentLocation()?.id===STAFF_TEST_ROOM&&currentLocation()?.is_test&&unresolvedTickForSession(state)){
   if(!tickCheck){tickCheck=button('Verifica invio',()=>updateRoom(host,{manual:true,verifyOnly:true}));tickCheck.setAttribute('data-mg-tick-check','');host.append(tickCheck);}
   tickCheck.disabled=!!roomError;
  }else if(tickCheck)tickCheck.remove();
  let entryButton=host.querySelector('[data-mg-combat-entry]'),panelButton=host.querySelector('[data-mg-combat-panel]'),entryNotice=host.querySelector('[data-mg-combat-notice]'),entryRetry=host.querySelector('[data-mg-combat-entry-retry]');
  if(entryState?.can_prepare&&!entryPending){if(!entryButton){entryButton=button('Apri scontro',()=>prepareEntry(host,roomState));entryButton.setAttribute('data-mg-combat-entry','');host.append(entryButton);}entryButton.disabled=!!roomError;}else entryButton?.remove();
  if(entryState?.can_open_panel){if(!panelButton){panelButton=button('Scegli l’azione nel pannello Scontro',()=>openCombat());panelButton.setAttribute('data-mg-combat-panel','');host.append(panelButton);}panelButton.disabled=!!roomError||!!entryPending;}else panelButton?.remove();
  if(entryPending&&entryReplayReady){if(!entryRetry){entryRetry=button('Ripeti la stessa apertura',()=>retryEntry(host,roomState));entryRetry.setAttribute('data-mg-combat-entry-retry','');host.append(entryRetry);}entryRetry.disabled=!!roomError;}else entryRetry?.remove();
  const entryText=entryError|| (entryPending?'Ingresso incerto: verifica la stessa richiesta prima di agire.':entryState?.reason_code==='REGIA_FATO_PENDING'?'Il Fato deve essere pubblicato prima della scelta meccanica.':entryState?.reason_code==='REGIA_NOT_YOUR_TURN'?'Pannello consultabile: attendi il tuo turno.':'');
  if(entryText){if(!entryNotice){entryNotice=el('p','',{role:'status','data-mg-combat-notice':''});host.append(entryNotice);}entryNotice.textContent=entryText;}else entryNotice?.remove();
  const text=statusText(state);if(status.textContent!==text)status.textContent=text;
  const tickProjection=tickStatusFor(state);
  let tickOwnerNotice=host.querySelector('[data-mg-tick-owner-status]');
  const receipt=tickProjection.value;
  const tickText=tickProjection.applicable&&!tickProjection.valid
   ?'Ricevuta della valutazione non verificabile. Le role restano conservate: usa Verifica invio o Aggiorna regia.'
   :receipt?.state==='blocked'?'Ricevuta della valutazione in attesa di verifica Staff. Nessun nuovo invio automatico.'
   :receipt&&['attested','released','no_work_released'].includes(receipt.state)&&!receipt.owned_by_me
    ?'La valutazione è affidata a un altro Staff. Le tue role e le azioni consentite dal server restano disponibili.'
   :receipt?.state==='released'&&!receipt.can_resume?'La ricevuta precedente è conservata. La ripresa non è ancora autorizzata dal server.':'';
  if(tickText){if(!tickOwnerNotice){tickOwnerNotice=el('p','',{role:'status','data-mg-tick-owner-status':''});host.append(tickOwnerNotice);}tickOwnerNotice.textContent=tickText;}
  else tickOwnerNotice?.remove();

  const feedbackKey=JSON.stringify([cacheUser,state.session_id]),feedback=chainFeedback.get(feedbackKey);
  let chainNotice=host.querySelector('[data-mg-chain-status]');
  const sceneDriver=driverFor(state);
  const staffScene=isStaff()&&currentLocation()?.id===STAFF_TEST_ROOM
   &&(state.session_id==='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'||sceneDriver.optedIn&&sceneDriver.valid);
  if(feedback&&chainPublicationConfirmed(state,feedback))chainFeedback.delete(feedbackKey);
  const activeFeedback=staffScene?chainFeedback.get(feedbackKey):null;
  if(activeFeedback){
   const reasons={child_confirmed:'pubblicazione della stessa richiesta da verificare',parent_unconfirmed:'conferma della valutazione ancora assente',parent_request_unavailable:'ricevuta della richiesta non disponibile',
    server_proof_unconfirmed:'verifica server non confermata',server_proof_invalid:'ricevuta server non riconosciuta',
    server_proof_none:'nessuna prosecuzione attestata dal server',child_request_invalid:'ricevuta del racconto non riconosciuta',
    context_changed:'stanza o accesso cambiati',room_state_changed:'stato della scena cambiato',abort_pending:'annullamento ancora da riconciliare',
    child_review_required:'scena in attesa di verifica Staff',child_tick_suspended:'prosecuzione sospesa dal server',
    child_projection_invalid:'stato del racconto non riconosciuto',child_projection_changed:'lavorazione del racconto cambiata',
    child_tuple_mismatch:'ricevute della richiesta discordanti',child_already_attempted:'richiesta del racconto già inviata',
    child_other_inflight:'un altro invio è ancora in corso',child_failed:'racconto fermato dal server',child_unconfirmed:'pubblicazione non ancora confermata',
    verification_error:'verifica non disponibile'};
   if(!chainNotice){chainNotice=el('p','',{role:'status','data-mg-chain-status':''});host.append(chainNotice);}
   chainNotice.setAttribute('data-mg-chain-reason',activeFeedback.reason);
   chainNotice.textContent='Raccordo del racconto: '+(reasons[activeFeedback.reason]||'verifica richiesta')+'. Le role restano conservate; non reinviarle.';
  }else chainNotice?.remove();
 }
 function definitiveChoiceError(error){const code=error?.code;return typeof code==='string'&&(/^(22|23)/.test(code)||['42501','40001','55000','P0001'].includes(code));}
 async function staffRecoverCachedChoice(host){
  const t=syncRoom(host),state=roomState,parsed=processingFor(state),work=parsed.value;
  if(!roomCurrent(t)||staffChoiceRecovery||!isStaff()||t.loc?.id!==STAFF_TEST_ROOM||!t.loc?.is_test
   ||academyFlow(state)!=='combat_started'||!state?.can_tick||state.review_required===true
   ||!parsed.valid||work?.state!=='failed'||work.finalized_at===null
   ||cachedChoiceRecoveries.has(work.work_id))return;
  const token={session:state.session_id,work:work.work_id,request:JSON.stringify(work.request)};
  staffChoiceRecovery=token;cachedChoiceRecoveries.add(work.work_id);paintRoom(host,state);
  try{
   const {data,error}=await client.functions.invoke('mission_generic_ai',{body:JSON.parse(token.request)});
   const delivery=data?.delivery??data;
   if(error||delivery?.code!=='MISSION_EVENT_COMPLETE'||!UUID.test(delivery.receipt_id||''))
    throw Error('cached_choice_receipt_unconfirmed');
   if(!roomCurrent(t)||staffChoiceRecovery!==token)return;
   const readback=await rpc('mission_generic_room_state_v1',{p_location:t.loc.id},t.user);
   if(!roomCurrent(t)||staffChoiceRecovery!==token)return;
   const fresh=processingFor(readback);
   if(!fresh.valid||readback.session_id!==token.session
    ||fresh.value?.work_id===token.work&&fresh.value.state==='failed')
    throw Error('cached_choice_recovery_not_applied');
   roomState=readback;roomError='';paintRoom(host,readback);
   await updateRoom(host,{manual:true});refresh();
  }catch{
   if(roomCurrent(t)&&staffChoiceRecovery===token){roomError='Lavorazione non recuperata automaticamente. La role e l’esito IA restano conservati; lo Staff deve verificare il work prima di nuove azioni.';paintRoom(host,roomState);}
  }finally{if(staffChoiceRecovery===token){staffChoiceRecovery=null;if(roomCurrent(t)&&roomState)paintRoom(host,roomState);}}
 }
 // This is the existing explicit resume button, not an automatic observer retry.
 function countedResumeAllowed(state,t){
  const p=processingFor(state),driver=driverFor(state);
  return !!(isStaff()&&t?.loc?.id===STAFF_TEST_ROOM&&t.loc.is_test===true
   &&state?.can_tick===true&&state.review_required!==true&&p.valid&&p.value?.state==='uncertain'
   &&p.value.finalized_at===null&&sameChainRequest(p.value.request,p.value.request)
   &&driver.optedIn&&driver.valid&&!hasCountProjection(state)
   &&!hasOpeningResume(state)&&!hasOpeningClaimResume(state)&&!abortBlocked(state.session_id));
 }
 const countedResumeKey=(user,state,work)=>`mission-counted-resume/1:${user}:${state.session_id}:${work.work_id}:${work.revision}`;
 function countedResumeRecorded(user,state,work){
  try{return localStorage.getItem(countedResumeKey(user,state,work))!==null;}catch{return true;}
 }
 function readCountedMarker(key,user,session){
  const raw=localStorage.getItem(key);if(raw===null)return null;const m=JSON.parse(raw);
  if(!nativeExact(m,['schema_version','user','session','work_id','request','started','reads','lastRead','done','original_journal_key','original_journal_raw'])
   ||m.schema_version!=='mission-counted-resume-journal/1'||m.user!==user||m.session!==session||!UUID.test(m.work_id||'')
   ||!sameChainRequest(m.request,m.request)||m.request.master_session_id!==session
   ||key!==countedResumeKey(user,{session_id:session},{work_id:m.work_id,revision:m.request.expected_revision})
   ||!Number.isSafeInteger(m.started)||m.started<=0||!Number.isSafeInteger(m.reads)||m.reads<0||m.reads>asyncBudget.maxReads
   ||!Number.isSafeInteger(m.lastRead)||m.lastRead<0||typeof m.done!=='boolean'
   ||m.original_journal_key!==journalPrefix(user,session)+selectorKey(selectorFor(m.request))
   ||!(m.original_journal_raw===null||typeof m.original_journal_raw==='string'))throw Error('counted_marker_invalid');
  return m;
 }
 function attachCountedMarker(m,key){
  const k='counted:'+key,existing=asyncWorks.get(k);if(existing)return existing.parent;
  const parent={user:m.user,session:m.session,key,kind:'work',work:m.work_id,body:Object.freeze(clone(m.request)),
   inFlight:false,outcome:'waiting',countedObservationKey:k,countedJournalKey:m.original_journal_raw===null?null:m.original_journal_key};
  // accepted selects the status-only read of this known tuple; it does not
  // assert that the handoff POST committed or permit any provider operation.
  const r=asyncRecord(parent,m.request,m.work_id,false,true);r.countedMarkerKey=key;
  r.started=performance.now()-Math.max(0,Date.now()-m.started);r.reads=m.reads;
  r.lastRead=m.lastRead===0?-Infinity:performance.now()-Math.max(0,Date.now()-m.lastRead);
  r.inactive=m.done;
  for(const old of asyncWorks.values())if(old!==r&&old.journalKey===m.original_journal_key)old.inactive=true;
  return parent;
 }
 function restoreCountedMarkers(state,t,settlements=[]){
  if(!asyncCurrent(t))return;const prefix=`mission-counted-resume/1:${t.user}:${state.session_id}:`;let count=0;
  for(let i=0;i<localStorage.length;i++){
   const key=localStorage.key(i);if(!key?.startsWith(prefix))continue;
   if(++count>128)throw Error('counted_marker_limit');const m=readCountedMarker(key,t.user,state.session_id);
   if(m){
    const proof=settlementFor(settlements,selectorFor(m.request),m.work_id);
    if(proof){recordSettlement(proof,t);continue;}
    attachCountedMarker(m,key); // Observation only, including uncertain/no ACK.
   }
  }
 }
 async function staffResumeCounted(host){
  const t=syncRoom(host),old=roomState,work=old&&processingFor(old).value;
  if(!roomCurrent(t)||staffResumeRead||!countedResumeAllowed(old,t)||liveAttempt(old)||!navigator.locks?.request)return;
  const token={session:old.session_id,work:work.work_id,request:clone(work.request)};
  staffResumeRead=token;paintRoom(host,old);
  try{
   const fresh=await rpc('mission_generic_room_state_v1',{p_location:t.loc.id},t.user);
   if(!roomCurrent(t)||staffResumeRead!==token)return;
   const current=processingFor(fresh).value;
   if(!countedResumeAllowed(fresh,t)||fresh.session_id!==token.session||current.work_id!==token.work
    ||!sameChainRequest(current.request,token.request))throw Error('counted_resume_changed');
   roomState=fresh;roomError='';paintRoom(host,fresh);
   const key=countedResumeKey(t.user,fresh,current);
   await navigator.locks.request(key,{mode:'exclusive'},async()=>{
    if(!roomCurrent(t)||staffResumeRead!==token||abortBlocked(token.session)
     ||!countedResumeAllowed(roomState,t)||processingFor(roomState).value.work_id!==token.work
     ||!sameChainRequest(processingFor(roomState).value.request,token.request))throw Error('counted_resume_changed');
    if(localStorage.getItem(key)!==null)throw Error('counted_resume_recorded');
    const originalKey=journalPrefix(t.user,token.session)+selectorKey(selectorFor(token.request));
    const originalRaw=localStorage.getItem(originalKey);
    if(originalRaw!==null){
     const prior=readJournal(originalKey,t.user,token.session),phase=journalPhase(prior);
     if(!prior||phase.done||phase.selector.kind!=='request'||!sameChainRequest(phase.selector.request,token.request))throw Error('counted_resume_journal_mismatch');
    }
    // Preserve the original journal byte-for-byte; this distinct marker records
    // only the explicit gesture and prevents another submission from this browser.
    const marker={schema_version:'mission-counted-resume-journal/1',user:t.user,
     session:token.session,work_id:token.work,request:clone(token.request),started:Date.now(),reads:0,lastRead:0,done:false,
     original_journal_key:originalKey,original_journal_raw:originalRaw};
    localStorage.setItem(key,JSON.stringify(marker));
    const parent=attachCountedMarker(marker,key);parent.inFlight=true;parent.outcome='pending';
    try{
     const response=await client.functions.invoke('mission_generic_ai',{body:{schema_version:'mission-generic-counted-resume-request/1',request:clone(token.request)}});
     if(!roomCurrent(t)||staffResumeRead!==token)return;
     if(response.error)throw Error('counted_resume_unconfirmed');
     if(acceptAsyncPending(response.data,parent,t,false))return;
     const result=response.data;
     if(result?.status===200&&['MISSION_EVENT_COMPLETE','MISSION_EVENT_FAILED'].includes(result.code)
      &&UUID.test(result.receipt_id||'')&&result.retry===false&&result.provider_retry_allowed===false){
      asyncRecord(parent,token.request,token.work,false,true); // Read the exact terminal proof before closing any original journal.
      parent.outcome=result.code==='MISSION_EVENT_COMPLETE'?'confirmed':'failed';return;
     }
     throw Error('counted_resume_unconfirmed');
    }finally{parent.inFlight=false;}
   });
  }catch{
   if(roomCurrent(t)&&staffResumeRead===token)roomError='Ripresa non confermata. La stessa richiesta e il Count già eseguito restano conservati. Aggiorna regia per verificarne lo stato.';
  }finally{
   if(staffResumeRead===token){staffResumeRead=null;if(roomCurrent(t)){await updateRoom(host,{manual:true,verifyOnly:true});refresh();}}
  }
 }
 function scopedFailedNarrationRecovery(state,work){
  return state?.session_id==='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'
   &&['42341080-7f78-494e-9adf-85de7cfce038','c88958e7-8983-4332-a14e-095076f967f4'].includes(work?.work_id)&&work.state==='failed'&&work.finalized_at!==null;
 }
 function staffClaimReconciliationAllowed(state,t,work=state&&processingFor(state).value){
  return isStaff()&&t?.loc?.id===STAFF_TEST_ROOM&&t.loc.is_test===true
   &&(state?.session_id==='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'
     ||state?.session_id==='9ac00210-4c88-4c0c-a443-95e3d6740a28'&&work?.work_id==='d8b37311-6010-4a07-95d3-5e65a33c756d')
   &&['f0856d53-83a6-4de0-bc0c-12c87916e665','b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'].includes(t.user)
   &&work?.state==='claimed'&&work.finalized_at===null;
 }
 async function staffReconcileClaimed(host){
  const t=syncRoom(host),old=roomState,parsed=old&&processingFor(old),claim=parsed?.value;
  if(!roomCurrent(t)||staffResumeRead||!parsed?.valid||!staffClaimReconciliationAllowed(old,t,claim)
   ||liveAttempt(old)||abortBlocked(old.session_id))return;
  const token={session:old.session_id,work:claim.work_id,event:claim.event_id,revision:claim.revision,
   request_key:claim.request_key,request:clone(claim.request)};
  staffResumeRead=token;paintRoom(host,old);
  try{
   const fresh=await rpc('mission_generic_room_state_v1',{p_location:t.loc.id},t.user);
   if(!roomCurrent(t)||staffResumeRead!==token)return;
   const parsedFresh=fresh&&processingFor(fresh),current=parsedFresh?.value;
   if(!fresh||!parsedFresh.valid)throw Error('claimed_readback_invalid');
   roomState=fresh;roomError='';paintRoom(host,fresh);
   if(fresh.session_id!==token.session||!staffClaimReconciliationAllowed(fresh,t,current)
    ||current.work_id!==token.work||current.event_id!==token.event||current.revision!==token.revision
    ||current.request_key!==token.request_key||!sameChainRequest(current.request,token.request)
    ||abortBlocked(fresh.session_id))return;
   // Technical reconciliation of this already-claimed request, never a new tick or new generation.
   // The composed claim/status producer alone attests Count and may terminalize the known overflow.
   maybeDispatch(fresh,t,true);
  }catch{if(roomCurrent(t)&&staffResumeRead===token){roomError='Verifica della stessa ricevuta non riuscita. Nessuna nuova richiesta: aggiorna la regia prima di ricontrollare.';paintRoom(host,roomState);}}
  finally{if(staffResumeRead===token){staffResumeRead=null;if(roomCurrent(t)&&roomState)paintRoom(host,roomState);}}
 }
 function openingResumeRecorded(state,user){
  try{const q=processingFor(state).value?.request;if(!sameChainRequest(q,q))return true;
   const j=readJournal(journalPrefix(user,state.session_id)+selectorKey(selectorFor(q)),user,state.session_id);
   return ['mission-async-journal/2','mission-async-journal/3','mission-async-journal/4','mission-async-journal/5'].includes(j?.schema_version)||j?.done===true;
  }catch{return true;}
 }
 async function staffResumeOpening(host){
  const t=syncRoom(host),old=roomState,x=old&&openingResumeProjection(old);
  if(!roomCurrent(t)||staffResumeRead||!x||!openingResumeAllowed(old,t)||liveAttempt(old)||!navigator.locks?.request)return;
  const request=Object.freeze(clone(processingFor(old).value.request)),proof=Object.freeze(clone(x));
  const selector=selectorFor(request),key=journalPrefix(t.user,old.session_id)+selectorKey(selector);
  const storeKey=JSON.stringify([t.user,old.session_id,'opening-resume:'+proof.proof_sha256]);
  if(attempts.has(storeKey))return;
  const token={session:old.session_id,proof:proof.proof_sha256};staffResumeRead=token;paintRoom(host,old);
  let parent;
  try{
   await navigator.locks.request(key,{mode:'exclusive'},async()=>{
    if(!roomCurrent(t)||staffResumeRead!==token||abortBlocked(token.session))throw Error('async_context_changed');
    const fresh=await rpc('mission_generic_room_state_v1',{p_location:t.loc.id},t.user);
    if(!roomCurrent(t)||staffResumeRead!==token)throw Error('async_context_changed');
    const current=fresh&&openingResumeProjection(fresh);
    if(!current||!openingResumeAllowed(fresh,t)||fresh.session_id!==token.session
     ||openingResumeTuple(current)!==openingResumeTuple(proof)||!sameChainRequest(processingFor(fresh).value.request,request))throw Error('opening_resume_changed');
    roomState=fresh;roomError='';
    const original=readJournal(key,t.user,token.session);
    if(original?.schema_version==='mission-async-journal/2'||original?.done)throw Error('opening_resume_already_recorded');
    // Preserve the exact original journal; null means this browser has no previous local record.
    // This phase is created only by this click after fresh server proof, never restore/timer/none.
    const document={schema_version:'mission-async-journal/2',original,resume:{user:t.user,session:token.session,selector,
     proof_sha256:proof.proof_sha256,started:Date.now(),reads:0,lastRead:0,done:false}};
    saveJournal(key,document);attachJournal(document,key,true);
    const record=asyncWorks.get('journal:'+key);parent=record.parent;
    parent.work=proof.work_id;record.work=proof.work_id;parent.inFlight=true;
    attempts.set(storeKey,parent);paintRoom(host,fresh);
    const {data,error}=await client.functions.invoke('mission_generic_ai',{body:{schema_version:'mission-opening-ready-resume-request/1',request:clone(request),proof:clone(proof)}});
    if(error)throw error;
    if(!asyncCurrent(t)||abortBlocked(token.session))return;
    if(data?.status===202&&data.code==='MISSION_EVENT_PENDING'){
     if(!acceptAsyncPending(data,parent,t,false))throw Error('opening_resume_ack_invalid');
    }else if(data?.status===200&&['MISSION_EVENT_COMPLETE','MISSION_EVENT_FAILED'].includes(data.code)&&UUID.test(data.receipt_id||'')&&data.retry===false&&data.provider_retry_allowed===false){
     document.resume.done=true;saveJournal(key,document);record.inactive=true;parent.outcome=data.code==='MISSION_EVENT_COMPLETE'?'confirmed':'failed';
    }else parent.outcome='uncertain'; // Observe the same tuple; never send a second resume.
   });
  }catch{if(parent)parent.outcome='uncertain';if(roomCurrent(t))roomError='Ripresa non confermata. La stessa richiesta e lo storico sono conservati; aggiorna la regia per verificarli.';}
  finally{if(parent)parent.inFlight=false;if(staffResumeRead===token)staffResumeRead=null;
   if(roomCurrent(t)){paintRoom(host,roomState);await updateRoom(host,{manual:true,verifyOnly:true});refresh();}}
 }
 function openingClaimResumePriorJournal13(j){
  const p=openingClaimResumePrior13,r=j?.recovery,q=r?.selector?.request;
  return j?.schema_version==='mission-async-journal/3'&&r?.done===false&&r.selector.kind==='request'
   &&r.proof_sha256===p.proof_sha256&&r.previous_lease_id===p.previous_lease_id
   &&r.dispatch_receipt_id===p.dispatch_receipt_id&&r.contract_sha256===p.contract_sha256
   &&r.session===p.master_session_id&&q?.master_session_id===p.master_session_id
   &&q?.event_id===p.event_id&&q?.request_key===p.request_key&&q?.expected_revision===p.expected_revision;
 }
 function openingClaimResumePriorJournal15(j){
  const p=openingClaimResumePrior15,r=j?.recovery,q=r?.selector?.request;
  return j?.schema_version==='mission-async-journal/4'&&r?.done===false&&r.selector.kind==='request'
   &&r.proof_sha256===p.proof_sha256&&r.release_sha256===p.release_sha256
   &&r.previous_lease_id===p.previous_lease_id&&r.dispatch_receipt_id===p.dispatch_receipt_id&&r.contract_sha256===p.contract_sha256
   &&r.session===p.master_session_id&&q?.master_session_id===p.master_session_id
   &&q?.event_id===p.event_id&&q?.request_key===p.request_key&&q?.expected_revision===p.expected_revision;
 }
 function openingClaimResumeRepairEligible(original,proof){
  const p=openingClaimResumePrior15;
  return openingClaimResumePriorJournal15(original)&&!!proof
   &&proof.release_sha256!==p.release_sha256&&proof.proof_sha256!==p.proof_sha256
   &&openingClaimResumeKeys.filter(k=>k!=='release_sha256'&&k!=='proof_sha256').every(k=>proof[k]===p[k]);
 }
 function openingClaimResumeRecorded(state,user){
  try{const q=processingFor(state).value?.request;if(!sameChainRequest(q,q))return true;
   const j=readJournal(journalPrefix(user,state.session_id)+selectorKey(selectorFor(q)),user,state.session_id);
   return !openingClaimResumeRepairEligible(j,openingClaimResumeProjection(state));
  }catch{return true;}
 }
 async function staffResumeClaimedOpening(host){
  const t=syncRoom(host),old=roomState,x=old&&openingClaimResumeProjection(old);
  if(!roomCurrent(t)||staffResumeRead||!x||!openingClaimResumeAllowed(old,t)||liveAttempt(old)||!navigator.locks?.request)return;
  const request=Object.freeze(clone(processingFor(old).value.request)),proof=Object.freeze(clone(x));
  const selector=selectorFor(request),key=journalPrefix(t.user,old.session_id)+selectorKey(selector);
  const storeKey=JSON.stringify([t.user,old.session_id,'opening-claim-resume:'+proof.proof_sha256]);
  if(attempts.has(storeKey))return;
  const token={session:old.session_id,proof:proof.proof_sha256};staffResumeRead=token;paintRoom(host,old);
  let parent;
  try{
   await navigator.locks.request(key,{mode:'exclusive'},async()=>{
    if(!roomCurrent(t)||staffResumeRead!==token||abortBlocked(token.session))throw Error('async_context_changed');
    const fresh=await rpc('mission_generic_room_state_v1',{p_location:t.loc.id},t.user);
    if(!roomCurrent(t)||staffResumeRead!==token)throw Error('async_context_changed');
    const current=fresh&&openingClaimResumeProjection(fresh);
    if(!current||!openingClaimResumeAllowed(fresh,t)||fresh.session_id!==token.session
     ||openingClaimResumeTuple(current)!==openingClaimResumeTuple(proof)||!sameChainRequest(processingFor(fresh).value.request,request))throw Error('opening_claim_resume_changed');
    roomState=fresh;roomError='';
    const original=readJournal(key,t.user,token.session);
    if(!openingClaimResumeRepairEligible(original,current))throw Error('opening_claim_resume_prior_mismatch');
    // Preserve the complete validated journal/4, including its unchanged journal/3 history.
    // Only this explicit click can record journal/5; restore and timers only observe it.
    const document={schema_version:'mission-async-journal/5',original,recovery:{user:t.user,session:token.session,selector,
     proof_sha256:proof.proof_sha256,release_sha256:proof.release_sha256,previous_lease_id:proof.previous_lease_id,dispatch_receipt_id:proof.dispatch_receipt_id,contract_sha256:proof.contract_sha256,started:Date.now(),reads:0,lastRead:0,done:false}};
    saveJournal(key,document);attachJournal(document,key,true);
    const record=asyncWorks.get('journal:'+key);parent=record.parent;
    parent.work=proof.work_id;record.work=proof.work_id;parent.inFlight=true;
    attempts.set(storeKey,parent);paintRoom(host,fresh);
    const {data,error}=await client.functions.invoke('mission_generic_ai',{body:{schema_version:'mission-opening-claim-resume-request/1',request:clone(request),proof:clone(proof)}});
    if(error)throw error;
    if(!asyncCurrent(t)||abortBlocked(token.session))return;
    if(data?.status===202&&data.code==='MISSION_EVENT_PENDING'){
     if(!acceptAsyncPending(data,parent,t,false))throw Error('opening_claim_resume_ack_invalid');
    }else if(data?.status===200&&['MISSION_EVENT_COMPLETE','MISSION_EVENT_FAILED'].includes(data.code)&&UUID.test(data.receipt_id||'')&&data.retry===false&&data.provider_retry_allowed===false){
     document.recovery.done=true;saveJournal(key,document);record.inactive=true;parent.outcome=data.code==='MISSION_EVENT_COMPLETE'?'confirmed':'failed';
    }else parent.outcome='uncertain'; // Observe the same tuple; never send a second resume.
   });
  }catch{if(parent)parent.outcome='uncertain';if(roomCurrent(t))roomError='Ripresa non confermata. La stessa richiesta e lo storico sono conservati; aggiorna la regia per verificarli.';}
  finally{if(parent)parent.inFlight=false;if(staffResumeRead===token)staffResumeRead=null;
   if(roomCurrent(t)){paintRoom(host,roomState);await updateRoom(host,{manual:true,verifyOnly:true});refresh();}}
 }
 async function staffResumeReady(host){
  const t=syncRoom(host),old=roomState,oldClaim=old&&processingFor(old).value,oldRole=old&&roleProgress(old);
  if(!roomCurrent(t)||staffResumeRead||!isStaff()||t.loc?.id!==STAFF_TEST_ROOM||!t.loc?.is_test||!old?.can_tick||old?.review_required===true
   ||oldClaim?.state!=='ready'||oldClaim.finalized_at!==null||!oldRole
   ||!(oldRole?.reason==='recoverable_not_started'||recoveredWriters.has(recoveredWriterKey(t.user,old.session_id,oldClaim.work_id))))return;
  const token={session:old.session_id,work:oldClaim.work_id,event:oldClaim.event_id,revision:oldClaim.revision,request_key:oldClaim.request_key,request_json:JSON.stringify(oldClaim.request),source_revision:oldRole.revision};
  staffResumeRead=token;paintRoom(host,old);
  try{
   const fresh=await rpc('mission_generic_room_state_v1',{p_location:t.loc.id},t.user);
   if(!roomCurrent(t)||staffResumeRead!==token)return;
   const parsed=fresh&&processingFor(fresh),claim=parsed?.value,role=fresh&&roleProgress(fresh);
   if(!fresh||!parsed.valid)throw Error('staff_ready_readback_invalid');
   roomState=fresh;roomError='';paintRoom(host,fresh);
   if(fresh.session_id!==token.session||fresh.review_required===true||!fresh.can_tick||claim?.state!=='ready'||claim.finalized_at!==null
    ||claim.work_id!==token.work||claim.event_id!==token.event||claim.revision!==token.revision||claim.request_key!==token.request_key
    ||JSON.stringify(claim.request)!==token.request_json
    ||!(role?.reason==='recoverable_not_started'||recoveredWriters.has(recoveredWriterKey(t.user,fresh.session_id,claim.work_id)))
    ||role.revision!==token.source_revision)return; // State changed: no second request is created.
   maybeDispatch(fresh,t,true); // processing.request is validated and reused byte-for-byte as a JS object.
  }catch{if(roomCurrent(t)&&staffResumeRead===token){roomError='Verifica della richiesta non riuscita. Nessun nuovo invio: aggiorna la regia e ricontrolla la stessa richiesta.';paintRoom(host,roomState);}}
  finally{if(staffResumeRead===token){staffResumeRead=null;if(roomCurrent(t)&&roomState)paintRoom(host,roomState);}}
 }
 async function staffRecoverIdenticalRole(host){
  const t=syncRoom(host),state=roomState,parsed=processingFor(state),work=parsed.value,role=state&&roleProgress(state);
  if(!roomCurrent(t)||staffRoleRecovery||!isStaff()||t.loc?.id!==STAFF_TEST_ROOM||!t.loc?.is_test||abortBlocked(state?.session_id)
   ||!parsed.valid||work?.state!=='failed'
   ||!(scopedFailedNarrationRecovery(state,work)||state?.can_tick&&role?.reason==='failed'))return;
  const token={session:state.session_id,work:work.work_id};staffRoleRecovery=token;paintRoom(host,state);
  try{
   const cached=await client.functions.invoke('mission_generic_ai',{body:{
    schema_version:'mission-generic-staff-cached-publication/1',master_session_id:token.session,work_id:token.work}});
   if(!roomCurrent(t)||staffRoleRecovery!==token)return;
   if(cached.error){
    const context=await cached.error.context?.json?.().catch(()=>null);
    if(context?.status==='failed'&&typeof context.error_code==='string')
     throw Error('Pubblicazione protetta da '+context.error_code);
    throw Error('staff_cached_publication_unconfirmed');
   }
   if(cached.data?.schema_version!=='mission-generic-staff-cached-publication/1'
    ||!['published','not_applicable','recovered'].includes(cached.data.status))
    throw Error('staff_cached_publication_invalid');
   if(cached.data.status==='recovered'){
    const r=cached.data,fields=['schema_version','status','master_session_id','work_id','replayed'];
    if(Object.keys(r).length!==fields.length||!fields.every(k=>Object.hasOwn(r,k))
     ||r.master_session_id!==token.session||!UUID.test(r.work_id||'')||r.work_id===token.work||typeof r.replayed!=='boolean')
     throw Error('staff_count_recovery_invalid');
    recoveredWriters.add(recoveredWriterKey(t.user,token.session,r.work_id));
    await updateRoom(host,{manual:true,verifyOnly:true});
    if(!roomCurrent(t)||staffRoleRecovery!==token)return;
    const fresh=roomState,writer=fresh&&processingFor(fresh);
    if(fresh?.session_id!==token.session||!writer?.valid||writer.value?.work_id!==r.work_id
     ||writer.value.state!=='ready'||writer.value.finalized_at!==null)throw Error('staff_count_recovery_readback_unconfirmed');
    roomError='';paintRoom(host,fresh);refresh();return; // Prepared, never published and never auto-generated here.
   }
   if(cached.data.status==='published'){
    await updateRoom(host,{manual:true});refresh();return;
   }
   const retry=await rpc('mission_staff_retry_failed_director_v1',
    {p_session:token.session,p_failed_director:token.work},t.user);
   if(!roomCurrent(t)||staffRoleRecovery!==token)return;
   if(retry?.schema_version!=='mission-staff-director-retry/1'
    ||!['released','not_applicable'].includes(retry.status))
    throw Error('staff_director_retry_unconfirmed');
   if(retry.status==='released'){
   await updateRoom(host,{manual:false});
   return;
 }

   const result=await rpc('mission_staff_resume_identical_role_v1',
    {p_session:token.session,p_failed_director:token.work},t.user);
   if(!roomCurrent(t)||staffRoleRecovery!==token)return;
   if(result?.schema_version!=='mission-staff-role-resume/1'||result.work?.state!=='ready')
    throw Error('staff_role_recovery_unconfirmed');
   await updateRoom(host,{manual:true});
  }catch(error){
   if(roomCurrent(t)&&staffRoleRecovery===token){roomError=String(error?.message||'').startsWith('Pubblicazione protetta da ')
    ?error.message:'Questa scena non soddisfa i requisiti del recupero sicuro. Le role restano conservate; lo Staff deve verificare il work.';paintRoom(host,roomState);}
  }finally{if(staffRoleRecovery===token){staffRoleRecovery=null;if(roomCurrent(t)&&roomState)paintRoom(host,roomState);}}
 }
  async function submitChoice(host,trigger,retry=false){
   const t=syncRoom(host),state=roomState;if(!state||!roomCurrent(t)||state.review_required===true||academyFlow(state)!==null)return;
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
 function sameChainRequest(a,b){
  const valid=q=>q&&Object.keys(q).length===5&&q.schema_version==='mission-generic-request/1'
   &&UUID.test(q.master_session_id||'')&&UUID.test(q.event_id||'')&&UUID.test(q.request_key||'')
   &&Number.isSafeInteger(q.expected_revision)&&q.expected_revision>0;
  return valid(a)&&valid(b)&&a.master_session_id===b.master_session_id&&a.event_id===b.event_id
   &&a.request_key===b.request_key&&a.expected_revision===b.expected_revision;
 }
 // Async delivery is bound to an authenticated closed acknowledgement. Reservation remains server-side.
 // A status read never claims work or resends role/provider input.
 const asyncPendingKeys=['status','code','schema_version','work_id','master_session_id','event_id','request_key','revision','retry','provider_retry_allowed'];
 const asyncStatusKeys=['schema_version','work_id','master_session_id','event_id','request_key','revision','state','receipt_id','result_sha256','retry','provider_retry_allowed'];
 const asyncStates=new Set(['ready','claimed','authorized','provider_started','uncertain','completed','failed']);
 const asyncBudget=Object.freeze({maxReads:50,maxMs:380000,minReadMs:8000});
 const asyncCurrent=t=>roomCurrent(t)&&valid(t.user);
 const asyncKey=(user,work,request)=>JSON.stringify([user,request.master_session_id,work,request.event_id,request.request_key,request.expected_revision]);
 function asyncStatusProof(value,record){
  const q=record.request;
  if(!nativeExact(value,asyncStatusKeys)||value.schema_version!=='mission-generic-async-status-response/1'
   ||value.work_id!==record.work||value.master_session_id!==q.master_session_id||value.event_id!==q.event_id
   ||value.request_key!==q.request_key||value.revision!==q.expected_revision||!asyncStates.has(value.state)
   ||!(value.receipt_id===null||UUID.test(value.receipt_id||''))||!(value.result_sha256===null||SHA.test(value.result_sha256||''))
   ||value.retry!==false||value.provider_retry_allowed!==false
   ||value.state==='completed'&&(!UUID.test(value.receipt_id||'')||!SHA.test(value.result_sha256||'')))
   throw Error('async_status_unconfirmed');
  return Object.freeze(clone(value));
 }
 function asyncRecord(parent,request,work,allowChain=false,accepted=false){
  if(!sameChainRequest(request,request)||request.master_session_id!==parent.session||!UUID.test(work||'')
   ||parent.work!==null&&parent.work!==work)throw Error('async_request_unconfirmed');
  const k=parent.countedObservationKey??(parent.journalKey?'journal:'+parent.journalKey:asyncKey(parent.user,work,request));let record=asyncWorks.get(k);
  if(!record){record={user:parent.user,session:parent.session,work,request:Object.freeze(clone(request)),parent,
   started:performance.now(),lastRead:-Infinity,reads:0,busy:false,state:'waiting',failure:null,proof:null,
   allowChain,accepted,chainStarted:false,chainDone:false};asyncWorks.set(k,record);}
  else if(accepted){record.accepted=true;record.allowChain=allowChain;record.parent=parent;record.work=work;record.request=Object.freeze(clone(request));}
  if(parent.journalKey)record.journalKey=parent.journalKey;
  parent.work=work;parent.asyncRequest=record.request;parent.asyncKey=k;return record;
 }
 function acceptAsyncPending(data,parent,t,allowChain=true){
  const delivery=data?.delivery??data;if(delivery?.status!==202||!asyncCurrent(t))return false;
  const request=parent.body.schema_version==='mission-generic-request/1'?parent.body:data?.dispatch;
  if(!nativeExact(delivery,asyncPendingKeys)||delivery.schema_version!=='mission-generic-pending/1'
   ||delivery.code!=='MISSION_EVENT_PENDING'||delivery.retry!==false||delivery.provider_retry_allowed!==false
   ||!sameChainRequest(request,request)||delivery.master_session_id!==parent.session
   ||delivery.event_id!==request.event_id||delivery.request_key!==request.request_key||delivery.revision!==request.expected_revision)
   throw Error('async_pending_unconfirmed');
  asyncRecord(parent,request,delivery.work_id,allowChain,true);parent.outcome='waiting';return true;
 }
 function asyncBlocked(state){
  return [...asyncWorks.values()].some(r=>r.user===cacheUser&&r.session===state.session_id
   &&!r.inactive&&(r.accepted||r.journalKey)&&(r.busy||r.state!=='completed'||r.allowChain&&!r.chainDone));
 }
 function asyncNotice(state){
  const records=[...asyncWorks.values()].reverse().filter(r=>r.user===cacheUser&&r.session===state.session_id);
  // An older pending observation can suspend this session too; never hide its blocker behind the current publication.
  const r=records.find(r=>!r.inactive&&(r.accepted||r.journalKey)
   &&(r.busy||r.state!=='completed'||r.allowChain&&!r.chainDone))
   ||records.find(r=>!r.inactive&&(!state.processing||state.processing.work_id===r.work));
  if(!r)return null;
  const previous=!!state.processing&&state.processing.work_id!==r.work;
  if(previous&&r.failure==='budget')return 'La verifica automatica di una richiesta precedente ha raggiunto il limite. Le nuove role sono conservate; il prossimo Fato non è ancora stato avviato.';
  if(previous&&r.failure)return 'Una richiesta precedente non è ancora riconciliata. Le nuove role sono conservate; il prossimo Fato non è ancora stato avviato.';
  if(previous&&!r.inactive&&(r.accepted||r.journalKey)
   &&(r.busy||r.state!=='completed'||r.allowChain&&!r.chainDone))return 'È in corso la verifica di una richiesta precedente. Le nuove role sono conservate; il prossimo Fato non è ancora stato avviato.';
  if(r.failure==='budget')return 'La verifica automatica ha raggiunto il limite. La stessa richiesta resta conservata; serve verifica Staff, senza un nuovo invio.';
  if(r.transportNotice&&!r.failure)return 'Lettura temporaneamente non disponibile. La verifica della stessa richiesta continua entro il limite, senza ripetere la generazione.';
  if(r.failure)return 'Stato della stessa richiesta non confermato. Nessun nuovo invio: verifica la regia con lo Staff.';
  if(r.state==='uncertain')return 'Esito della generazione incerto. Le role restano conservate; nessun nuovo tentativo o racconto viene avviato.';
  if(r.state==='failed')return 'Generazione fermata dal server. Le role e lo storico restano conservati; serve verifica Staff.';
  return null;
 }
 // Journal = reference and observation budget, never ownership or permission to generate.
 const asyncJournalSchema='mission-async-journal/1';
 const recoveryKeys=['schema_version','status','request','work_id','state','receipt_id','result_sha256','kind','retry','provider_retry_allowed'];
 const journalPrefix=(u,s)=>`${asyncJournalSchema}:${u}:${s}:`;
 const selectorKey=s=>s.kind==='staff_tick'?`tick:${s.source_revision}`:`work:${s.request.event_id}:${s.request.request_key}:${s.request.expected_revision}`;
 function selectorFor(body){
  if(sameChainRequest(body,body))return {kind:'request',request:clone(body)};
  if(nativeExact(body,['schema_version','master_session_id','source_revision'])&&body.schema_version==='mission-generic-staff-tick/1'&&UUID.test(body.master_session_id||'')&&SHA.test(body.source_revision||''))return {kind:'staff_tick',source_revision:body.source_revision};
  return null;
 }
 const releasedDirectorWork=id=>['d460a7be-a3a2-4ad8-9d3b-d2e929f2947e','f4f7185e-4aae-4edd-ac24-65f8dcfa36f5'].includes(id);
 const settlementSchema='mission-async-local-settlement/1';
 function sameSelector(a,b){
  return a?.kind===b?.kind&&(a.kind==='request'?sameChainRequest(a.request,b.request)
   :a.kind==='staff_tick'&&SHA.test(a.source_revision||'')&&a.source_revision===b.source_revision);
 }
 function unpublishedReinterpretationRelease(x,r,session){
  return session==='44078c5f-7001-4129-9506-e2f34e68c8ac'
   &&['433ace05-5265-4aad-96a3-5567b6e3480a','310493d3-92d2-4645-ba85-ab42f57dbf9d'].includes(x.work_id)
   &&r.reason==='staff_unpublished_reinterpretation'
   &&r.source_window_id==='433ace05-5265-4aad-96a3-5567b6e3480a'
   &&r.source_revision==='ac9aedbd59dcb835d717f4ddb6ce195e3c2a9d640df576667290fa38b7e6cbbb';
 }
 function settlementItemValid(x,session){
  const p=x?.publication,r=x?.release,s=x?.selector,q=x?.request;
  if(r)return nativeExact(x,['selector','request','work_id','receipt_id','result_sha256','release'])
   &&sameChainRequest(q,q)&&q.master_session_id===session
   &&(nativeExact(s,['kind','request'])&&s.kind==='request'&&sameChainRequest(s.request,q)
    ||nativeExact(s,['kind','source_revision'])&&s.kind==='staff_tick'&&s.source_revision===r.source_revision)
   &&session==='44078c5f-7001-4129-9506-e2f34e68c8ac'&&(releasedDirectorWork(x.work_id)&&r.reason==='staff_preprovider_request_retry'
    ||x.work_id==='e366b9fa-54dc-4abd-8ba6-9ceee83be9a4'&&r.reason==='staff_saved_director_application'
    ||unpublishedReinterpretationRelease(x,r,session))
   &&UUID.test(x.receipt_id||'')&&SHA.test(x.result_sha256||'')
   &&nativeExact(r,['source_window_id','source_revision','reason','audit_sha256'])
   &&(r.source_window_id===x.work_id||unpublishedReinterpretationRelease(x,r,session))&&SHA.test(r.source_revision||'')&&SHA.test(r.audit_sha256||'')
   ;
  return nativeExact(x,['selector','request','work_id','receipt_id','result_sha256','publication'])
   &&sameChainRequest(q,q)&&q.master_session_id===session
   &&(nativeExact(s,['kind','request'])&&s.kind==='request'&&sameChainRequest(s.request,q)
    ||nativeExact(s,['kind','source_revision'])&&s.kind==='staff_tick'&&SHA.test(s.source_revision||''))
   &&UUID.test(x.work_id||'')&&UUID.test(x.receipt_id||'')&&SHA.test(x.result_sha256||'')
   &&nativeExact(p,['writer_work_id','message_id','receipt_id','result_sha256'])
   &&['writer_work_id','message_id','receipt_id'].every(k=>UUID.test(p[k]||''))&&SHA.test(p.result_sha256||'')
   &&(p.writer_work_id!==x.work_id||p.receipt_id===x.receipt_id&&p.result_sha256===x.result_sha256);
 }
 function journalSettlements(state,t){
  if(!Object.hasOwn(state,'journal_settlements'))return [];
  const x=state.journal_settlements;
  if(!isStaff()||t.loc?.id!==STAFF_TEST_ROOM||t.loc.is_test!==true||!asyncCurrent(t)
   ||!nativeExact(x,['schema_version','master_session_id','items'])||!['mission-journal-settlements/1','mission-journal-settlements/2'].includes(x.schema_version)
   ||x.master_session_id!==state.session_id||!Array.isArray(x.items)||x.items.length>128
   ||!x.items.every(i=>settlementItemValid(i,state.session_id)&&(x.schema_version==='mission-journal-settlements/2'||!i.release))
   ||new Set(x.items.map(i=>selectorKey(i.selector)+':'+i.work_id)).size!==x.items.length)throw Error('async_settlements_invalid');
  return x.items;
 }
 function settlementFor(items,selector,work=null,excludeWork=null){
  const matches=items.filter(i=>sameSelector(i.selector,selector)&&(work===null||work===i.work_id)&&i.work_id!==excludeWork);
  return matches.find(i=>i.release)||matches[0]||null;
 }
 function recordSettlement(item,t){
  // Evidence is supplied by this fresh authenticated room read. The sidecar is audit only.
  // Original journals, resume phases and their observation budgets remain byte-identical.
  const key=`${settlementSchema}:${t.user}:${item.request.master_session_id}:${selectorKey(item.selector)}${item.release?':released:'+item.work_id:''}`;
  const proof={schema_version:settlementSchema,user:t.user,session:item.request.master_session_id,proof:clone(item)};
  const raw=localStorage.getItem(key);
  if(raw!==null){const old=JSON.parse(raw);
   if(!nativeExact(old,['schema_version','user','session','proof'])||old.schema_version!==settlementSchema
    ||old.user!==t.user||old.session!==proof.session||!settlementItemValid(old.proof,proof.session)
    ||!sameSelector(old.proof.selector,item.selector)||!sameChainRequest(old.proof.request,item.request)
    ||old.proof.work_id!==item.work_id||old.proof.receipt_id!==item.receipt_id||old.proof.result_sha256!==item.result_sha256
    ||(!!old.proof.release!==!!item.release)||(item.release
     ?['source_window_id','source_revision','reason','audit_sha256'].some(k=>old.proof.release[k]!==item.release[k])
     :['writer_work_id','message_id','receipt_id','result_sha256'].some(k=>old.proof.publication[k]!==item.publication[k])))throw Error('async_settlement_conflict');
   return;
  }
  localStorage.setItem(key,JSON.stringify(proof));
 }
 function settleAsyncRecords(items,t){
  for(const r of asyncWorks.values()){
   if(r.user!==t.user||r.session!==roomState?.session_id||r.inactive)continue;
   const selector=r.selector??selectorFor(r.parent?.body)??(r.request?selectorFor(r.request):null);
   const proof=settlementFor(items,selector,r.work??null,r.releasedPredecessor??null);if(!proof)continue;
   recordSettlement(proof,t);r.terminalSettlement=Object.freeze(clone(proof));r.chainDone=true;r.inactive=true;
  }
 }
 const journalPhase=j=>['mission-async-journal/3','mission-async-journal/4','mission-async-journal/5','mission-async-journal/6','mission-async-journal/7'].includes(j?.schema_version)?j.recovery:j?.schema_version==='mission-async-journal/2'?j.resume:j;
 function journalPhaseValid(j,key,user,session,fields){
  const s=j?.selector;
  const selectorValid=nativeExact(s,['kind','source_revision'])&&s.kind==='staff_tick'&&SHA.test(s.source_revision||'')
   ||nativeExact(s,['kind','request'])&&s.kind==='request'&&sameChainRequest(s.request,s.request)&&s.request.master_session_id===session;
  return nativeExact(j,fields)&&j.user===user&&j.session===session&&selectorValid
   &&key===journalPrefix(user,session)+selectorKey(s)+(Object.hasOwn(j,'no_work_recovery_key')?':no-work:'+j.no_work_recovery_key+':'+j.retry_request_key:Object.hasOwn(j,'released_work_id')?':released:'+j.released_work_id:'')&&Number.isSafeInteger(j.started)&&j.started>0&&j.started<=Date.now()
   &&Number.isSafeInteger(j.reads)&&j.reads>=0&&j.reads<=asyncBudget.maxReads&&Number.isSafeInteger(j.lastRead)&&j.lastRead>=0&&typeof j.done==='boolean';
 }
 function readJournal(key,user,session){
  const raw=localStorage.getItem(key);if(raw===null)return null;const j=JSON.parse(raw);
  const legacyFields=['schema_version','user','session','selector','started','reads','lastRead','done'];
  const legacyValid=x=>journalPhaseValid(x,key,user,session,legacyFields)&&x.schema_version===asyncJournalSchema;
  const journal3Valid=j=>{
   if(j?.schema_version!=='mission-async-journal/3')return false;
   const prior=j.original;
   const priorValid=prior===null||legacyValid(prior)||(nativeExact(prior,['schema_version','original','resume'])
    &&prior.schema_version==='mission-async-journal/2'&&(prior.original===null||legacyValid(prior.original))
    &&journalPhaseValid(prior.resume,key,user,session,['user','session','selector','proof_sha256','started','reads','lastRead','done'])
    &&prior.resume.selector.kind==='request'&&SHA.test(prior.resume.proof_sha256||''));
   if(!nativeExact(j,['schema_version','original','recovery'])||!priorValid
    ||!journalPhaseValid(j.recovery,key,user,session,['user','session','selector','proof_sha256','previous_lease_id','dispatch_receipt_id','contract_sha256','started','reads','lastRead','done'])
    ||j.recovery.selector.kind!=='request'||!['proof_sha256','contract_sha256'].every(k=>typeof j.recovery[k]==='string'&&SHA.test(j.recovery[k]))
    ||!['previous_lease_id','dispatch_receipt_id'].every(k=>typeof j.recovery[k]==='string'&&UUID.test(j.recovery[k])))return false;

   return true;
  };
  const journal4Valid=j=>{
   if(j?.schema_version!=='mission-async-journal/4')return false;
   const r=j.recovery,p=openingClaimResumePrior13;
   if(!nativeExact(j,['schema_version','original','recovery'])||!journal3Valid(j.original)||!openingClaimResumePriorJournal13(j.original)
    ||!journalPhaseValid(r,key,user,session,['user','session','selector','proof_sha256','release_sha256','previous_lease_id','dispatch_receipt_id','contract_sha256','started','reads','lastRead','done'])
    ||r.selector.kind!=='request'||!sameChainRequest(r.selector.request,j.original.recovery.selector.request)
    ||!['proof_sha256','release_sha256','contract_sha256'].every(k=>typeof r[k]==='string'&&SHA.test(r[k]))
    ||r.proof_sha256===p.proof_sha256||r.release_sha256===p.release_sha256
    ||r.previous_lease_id!==p.previous_lease_id||r.dispatch_receipt_id!==p.dispatch_receipt_id||r.contract_sha256!==p.contract_sha256)return false;

   return true;
  };
  if(j?.schema_version==='mission-async-journal/7'){
   const r=j.recovery,baseKey=journalPrefix(user,session)+selectorKey(r?.selector);
   if(!nativeExact(j,['schema_version','original','recovery'])
    ||!journalPhaseValid(r,key,user,session,['user','session','selector','no_work_recovery_key','retry_request_key','original_result_sha256','started','reads','lastRead','done'])
    ||r.selector.kind!=='staff_tick'||!UUID.test(r.no_work_recovery_key||'')||!UUID.test(r.retry_request_key||'')
    ||r.no_work_recovery_key===r.retry_request_key||!SHA.test(r.original_result_sha256||'')
    ||!(j.original===null||j.original?.schema_version===asyncJournalSchema&&journalPhaseValid(j.original,baseKey,user,session,legacyFields)&&sameSelector(j.original.selector,r.selector)))throw Error('async_journal_invalid');
  }else if(j?.schema_version==='mission-async-journal/6'){
   const r=j.recovery,baseKey=journalPrefix(user,session)+selectorKey(r?.selector);
   if(!nativeExact(j,['schema_version','original','recovery'])
    ||!journalPhaseValid(r,key,user,session,['user','session','selector','released_work_id','source_request_key','started','reads','lastRead','done'])
    ||r.selector.kind!=='staff_tick'||session!=='44078c5f-7001-4129-9506-e2f34e68c8ac'
    ||!releasedDirectorWork(r.released_work_id)||!UUID.test(r.source_request_key||'')
    ||!(j.original===null||j.original?.schema_version===asyncJournalSchema
      &&journalPhaseValid(j.original,baseKey,user,session,legacyFields)&&sameSelector(j.original.selector,r.selector)))throw Error('async_journal_invalid');
  }else if(j?.schema_version==='mission-async-journal/5'){
   const r=j.recovery,p=openingClaimResumePrior15;
   if(!nativeExact(j,['schema_version','original','recovery'])||!journal4Valid(j.original)||!openingClaimResumePriorJournal15(j.original)
    ||!journalPhaseValid(r,key,user,session,['user','session','selector','proof_sha256','release_sha256','previous_lease_id','dispatch_receipt_id','contract_sha256','started','reads','lastRead','done'])
    ||r.selector.kind!=='request'||!sameChainRequest(r.selector.request,j.original.recovery.selector.request)
    ||!['proof_sha256','release_sha256','contract_sha256'].every(k=>typeof r[k]==='string'&&SHA.test(r[k]))
    ||r.proof_sha256===p.proof_sha256||r.release_sha256===p.release_sha256
    ||r.previous_lease_id!==p.previous_lease_id||r.dispatch_receipt_id!==p.dispatch_receipt_id||r.contract_sha256!==p.contract_sha256)throw Error('async_journal_invalid');
  }else if(j?.schema_version==='mission-async-journal/4'){
   if(!journal4Valid(j))throw Error('async_journal_invalid');
  }else if(j?.schema_version==='mission-async-journal/3'){
   if(!journal3Valid(j))throw Error('async_journal_invalid');
  }else if(j?.schema_version==='mission-async-journal/2'){
   if(!nativeExact(j,['schema_version','original','resume'])||!(j.original===null||legacyValid(j.original))
    ||!journalPhaseValid(j.resume,key,user,session,['user','session','selector','proof_sha256','started','reads','lastRead','done'])
    ||j.resume.selector.kind!=='request'||!SHA.test(j.resume.proof_sha256||''))throw Error('async_journal_invalid');
  }else if(!legacyValid(j))throw Error('async_journal_invalid');
  return j;
 }
 function saveJournal(key,j){localStorage.setItem(key,JSON.stringify(j));}
 function attachJournal(document,key,explicitResume=false){
  const j=journalPhase(document),existing=[...asyncWorks.values()].find(r=>r.journalKey===key);
  if(!explicitResume&&existing&&(existing.resumeProof??null)===(j.proof_sha256??null))return;
  // A phase recorded by another tab is adopted for observation only, never invocation.
  const body=j.selector.kind==='request'?clone(j.selector.request):{schema_version:'mission-generic-staff-tick/1',master_session_id:j.session,source_revision:j.selector.source_revision};
  const parent={user:j.user,session:j.session,key,kind:j.selector.kind==='staff_tick'?'tick':'work',work:null,body:Object.freeze(body),inFlight:false,outcome:'waiting',journalKey:key};
  const k='journal:'+key;parent.asyncKey=k;
  asyncWorks.set(k,{user:j.user,session:j.session,work:null,request:null,parent,selector:clone(j.selector),journalKey:key,releasedPredecessor:j.released_work_id??null,resumeProof:j.proof_sha256??null,started:performance.now(),lastRead:-Infinity,reads:0,busy:false,state:'waiting',failure:null,proof:null,allowChain:false,accepted:false,chainDone:false});
 }
 function restoreJournals(state,t,settlements=[]){
  if(!asyncCurrent(t))return;const prefix=journalPrefix(t.user,state.session_id);let count=0;
  for(let i=0;i<localStorage.length;i++){const key=localStorage.key(i);if(!key?.startsWith(prefix))continue;
   if(++count>128)throw Error('async_journal_limit');const j=readJournal(key,t.user,state.session_id);
   if(j&&!journalPhase(j).done){
    const proof=settlementFor(settlements,journalPhase(j).selector,null,journalPhase(j).released_work_id??null);
    if(proof){recordSettlement(proof,t);continue;}
    attachJournal(j,key);
   }
  }
 }
 function staffNoWork(data,parent){
  const fields=['schema_version','master_session_id','state','dispatch','staff_tick'];
  if(parent.body.schema_version!=='mission-generic-staff-tick/1'||!data||data.dispatch!==null)return false;
  if(!(nativeExact(data,fields)||nativeExact(data,[...fields,'reason_code'])&&data.reason_code==='MGPG_C7_RUN_BUDGET_STOP'&&data.state==='paused')
   ||data.schema_version!=='mission-generic-progress/1'||data.master_session_id!==parent.session||typeof data.state!=='string'||!/^[a-z][a-z0-9_]{0,63}$/.test(data.state)
   ||!nativeExact(data.staff_tick,['state','source_revision','request_key'])||!['issued','replayed','existing_work'].includes(data.staff_tick.state)
   ||data.staff_tick.source_revision!==parent.body.source_revision||!(data.staff_tick.request_key===null||UUID.test(data.staff_tick.request_key||'')))throw Error('async_no_work_invalid');
  return true; // Authenticated synchronous acknowledgement, no public completion or generated Fato.
 }
 async function invokeAsyncOnce(parent,t){
  const selector=selectorFor(parent.body),driver=driverFor(roomState);
  // This source delta targets the opted-in Staff driver, not unrelated synchronous consumers.
  if(!(selector&&isStaff()&&t.loc?.id===STAFF_TEST_ROOM&&t.loc.is_test===true&&driver.optedIn&&driver.valid))return client.functions.invoke('mission_generic_ai',{body:clone(parent.body)});
  if(!navigator.locks?.request)throw Error('async_journal_lock_unavailable');
  const baseKey=journalPrefix(t.user,parent.session)+selectorKey(selector);
  let release=null;
  if(releasedDirectorWork(parent.tickRecoveryKey)&&parent.session==='44078c5f-7001-4129-9506-e2f34e68c8ac'){
   const projection=tickStatusFor(roomState,t),proof=projection.value;
   if(!projection.applicable||!projection.valid||selector.kind!=='staff_tick'
    ||parent.session!=='44078c5f-7001-4129-9506-e2f34e68c8ac'
    ||!releasedDirectorWork(parent.tickRecoveryKey)
    ||proof.state!=='released'||!proof.owned_by_me||!proof.can_resume
    ||proof.recovery_key!==parent.tickRecoveryKey||proof.source_revision!==selector.source_revision)
    throw Error('async_release_retry_unconfirmed');
   release=proof;
  }
  let noWorkRelease=null;
  if(parent.noWorkRecovery){
   const projection=tickStatusFor(roomState,t),proof=projection.value;
   if(!projection.applicable||!projection.valid||selector.kind!=='staff_tick'||proof.state!=='no_work_released'
    ||!proof.owned_by_me||!proof.can_resume||proof.recovery_key!==parent.tickRecoveryKey
    ||proof.retry_request_key!==parent.noWorkRecovery.retry_request_key||proof.original_result_sha256!==parent.noWorkRecovery.original_result_sha256
    ||proof.source_revision!==selector.source_revision)throw Error('async_no_work_retry_unconfirmed');
   noWorkRelease=proof;
  }
  const key=baseKey+(noWorkRelease?':no-work:'+noWorkRelease.recovery_key+':'+noWorkRelease.retry_request_key:release?':released:'+release.work_id:'');parent.journalKey=key;
  return navigator.locks.request(key,{mode:'exclusive'},async()=>{
   if(!asyncCurrent(t)||abortBlocked(parent.session))throw Error('async_context_changed');
   const old=readJournal(key,t.user,parent.session);if(old){if(!journalPhase(old).done)attachJournal(old,key);throw Error('async_already_submitted');}
   const phase={user:t.user,session:parent.session,selector,started:Date.now(),reads:0,lastRead:0,done:false};
   let j;
   if(noWorkRelease){
    const original=readJournal(baseKey,t.user,parent.session);
    if(original&&original.schema_version!==asyncJournalSchema)throw Error('async_no_work_original_invalid');
    j={schema_version:'mission-async-journal/7',original:original===null?null:clone(original),recovery:{...phase,
     no_work_recovery_key:noWorkRelease.recovery_key,retry_request_key:noWorkRelease.retry_request_key,original_result_sha256:noWorkRelease.original_result_sha256}};
   }else if(release){
    const original=readJournal(baseKey,t.user,parent.session);
    if(original&&original.schema_version!==asyncJournalSchema)throw Error('async_release_original_invalid');
    j={schema_version:'mission-async-journal/6',original:original===null?null:clone(original),
     recovery:{...phase,released_work_id:release.work_id,source_request_key:release.request_key}};
   }else j={schema_version:asyncJournalSchema,...phase};
   saveJournal(key,j);attachJournal(j,key); // Persist before HTTP; an uncertain send is never repeated.
   const response=await client.functions.invoke('mission_generic_ai',{body:clone(parent.body)});
   const delivery=response.data?.delivery??response.data;
   if(!response.error&&((staffNoWork(response.data,parent)&&!noWorkRelease)||delivery?.status===200&&['MISSION_EVENT_COMPLETE','MISSION_EVENT_FAILED'].includes(delivery.code)&&UUID.test(delivery.receipt_id||''))){
    journalPhase(j).done=true;saveJournal(key,j);const r=asyncWorks.get('journal:'+key);if(r)r.inactive=true;
   } // A confirmed synchronous terminal reply needs no new async observer.
   return response;
  });
 }
 function spendAsyncRead(r){
  if(r.countedMarkerKey){const m=readCountedMarker(r.countedMarkerKey,r.user,r.session);
   if(!m||m.done||m.work_id!==r.work||!sameChainRequest(m.request,r.request)
    ||m.reads>=asyncBudget.maxReads||Date.now()-m.started>=asyncBudget.maxMs)throw Error('async_budget');
   m.reads++;m.lastRead=Date.now();localStorage.setItem(r.countedMarkerKey,JSON.stringify(m));r.reads=m.reads;
  }else if(r.journalKey){const document=readJournal(r.journalKey,r.user,r.session),j=journalPhase(document);
   if(!j||j.done||j.reads>=asyncBudget.maxReads||Date.now()-j.started>=asyncBudget.maxMs)throw Error('async_budget');
   if((j.proof_sha256??null)!==(r.resumeProof??null))throw Error('async_phase_changed');
   j.reads++;j.lastRead=Date.now();saveJournal(r.journalKey,document);r.reads=j.reads;
  }else if(r.reads>=asyncBudget.maxReads||performance.now()-r.started>=asyncBudget.maxMs)throw Error('async_budget');else r.reads++;
 }
 const transientReadCodes=new Set(['08000','08001','08003','08006','08007','40001','40P01','55P03','57014','53300','57P01','57P02','57P03']);
 function transientReadCause(e,status){
  const code=typeof e?.code==='string'?e.code:'';
  if(code)return transientReadCodes.has(code);
  return status===0||['AbortError','TimeoutError','FunctionsFetchError'].includes(e?.name)||e?.name==='TypeError'&&/fetch|network/i.test(e.message||'');
 }
 async function boundedAsyncRead(r,read){
  spendAsyncRead(r);
  const remaining=r.countedMarkerKey?asyncBudget.maxMs-(Date.now()-readCountedMarker(r.countedMarkerKey,r.user,r.session).started):r.journalKey?asyncBudget.maxMs-(Date.now()-journalPhase(readJournal(r.journalKey,r.user,r.session)).started):asyncBudget.maxMs-(performance.now()-r.started);
  if(remaining<=0)throw Error('async_budget');
  let timer;const controller=new AbortController();
  try{return await Promise.race([read(controller.signal),new Promise((_,reject)=>{timer=setTimeout(()=>{controller.abort();reject(Object.assign(Error('async_read_timeout'),{asyncRetryable:true}));},Math.min(10000,remaining));})]);}
  finally{clearTimeout(timer);}
 }
 async function asyncRead(body,r){
  return boundedAsyncRead(r,async signal=>{
   let response;try{response=await client.functions.invoke('mission_generic_ai',{body,signal});}
   catch(e){throw Object.assign(Error('async_read_transport'),{asyncRetryable:transientReadCause(e)});}
   if(response.error){
    const status=response.error.context?.status;
    const prefix={'mission-generic-async-recover/1':'MISSION_ASYNC_RECOVERY','mission-generic-async-status/1':'MISSION_ASYNC_STATUS','mission-director-narration-read/1':'MISSION_DIRECTOR_NARRATION_READ'}[body.schema_version];
    let proof;try{proof=await response.error.context?.json();}catch{}
    const retryable=nativeExact(proof,['code','retry','provider_retry_allowed','read_retry_allowed'])&&proof.code===prefix+'_TRANSIENT'&&status===503&&proof.retry===false&&proof.provider_retry_allowed===false&&proof.read_retry_allowed===true;
    throw Object.assign(Error('async_read_unconfirmed'),{asyncRetryable:retryable||status===undefined&&transientReadCause(response.error)});
   }
   return response.data;
  });
 }
 async function asyncRoomRead(r,t){
  return boundedAsyncRead(r,async signal=>{
   if(!valid(t.user))throw Error('async_context_changed');
   let result;try{let query=client.rpc('mission_generic_room_state_v1',{p_location:t.loc.id});if(typeof query.abortSignal==='function')query=query.abortSignal(signal);result=await query;}
   catch(e){throw Object.assign(Error('async_room_read_unconfirmed'),{asyncRetryable:transientReadCause(e)});}
   if(!valid(t.user))throw Error('async_context_changed');
   if(result.error)throw Object.assign(Error('async_room_read_unconfirmed'),{asyncRetryable:transientReadCause(result.error,result.status)});
   return result.data;
  });
 }
 function recoveryProof(v,r){
  if(!nativeExact(v,recoveryKeys)||v.schema_version!=='mission-generic-async-recovery/1'||!['owned','none','no_work'].includes(v.status)||v.retry!==false||v.provider_retry_allowed!==false)throw Error('async_recovery_invalid');
  if(v.status==='none'||v.status==='no_work'){
   if(['request','work_id','state','receipt_id','result_sha256','kind'].some(k=>v[k]!==null)||v.status==='no_work'&&r.selector.kind!=='staff_tick')throw Error('async_recovery_invalid');
   if(v.status==='no_work'){const j=readJournal(r.journalKey,r.user,r.session);if(!j)throw Error('async_journal_invalid');if(j.schema_version==='mission-async-journal/7')return null; journalPhase(j).done=true;saveJournal(r.journalKey,j);r.inactive=true;r.transportNotice=false;}
   return null;
  }
  if(!sameChainRequest(v.request,v.request)||v.request.master_session_id!==r.session||!UUID.test(v.work_id||'')||!['director','narration','choice'].includes(v.kind)
   ||r.selector.kind==='request'&&!sameChainRequest(v.request,r.selector.request))throw Error('async_recovery_invalid');
  const q=v.request,proof=asyncStatusProof({schema_version:'mission-generic-async-status-response/1',work_id:v.work_id,master_session_id:q.master_session_id,event_id:q.event_id,request_key:q.request_key,revision:q.expected_revision,state:v.state,receipt_id:v.receipt_id,result_sha256:v.result_sha256,retry:false,provider_retry_allowed:false},{...r,work:v.work_id,request:q});
  r.work=v.work_id;r.request=Object.freeze(clone(q));r.accepted=true;r.allowChain=v.kind==='director';r.parent.work=v.work_id;r.parent.asyncRequest=r.request;
  return proof; // Server-owned recovery projection; never a synthetic EVENT_COMPLETE ACK.
 }
 function finishJournal(r){
  if(r.countedMarkerKey&&['completed','failed'].includes(r.state)&&UUID.test(r.proof?.receipt_id||'')){
   const marker=readCountedMarker(r.countedMarkerKey,r.user,r.session);
   if(!marker||marker.work_id!==r.work||!sameChainRequest(marker.request,r.request))throw Error('counted_marker_changed');
   marker.done=true;localStorage.setItem(r.countedMarkerKey,JSON.stringify(marker));r.inactive=true;
  }
  if(['completed','failed'].includes(r.state)&&UUID.test(r.proof?.receipt_id||'')&&r.parent.countedJournalKey){
   const key=r.parent.countedJournalKey,j=readJournal(key,r.user,r.session),phase=j&&journalPhase(j);
   if(phase?.selector.kind==='request'&&sameChainRequest(phase.selector.request,r.request)){
    phase.done=true;saveJournal(key,j); // Normal terminal completion, only after the exact server receipt.
    for(const previous of asyncWorks.values())if(previous!==r&&previous.journalKey===key)previous.inactive=true;
   }
  }
  if(r.journalKey&&r.state==='completed'&&(!r.allowChain||r.chainDone)){const j=readJournal(r.journalKey,r.user,r.session);if(j){journalPhase(j).done=true;saveJournal(r.journalKey,j);}}}
 function observeAsyncWork(state,t){
  if(!asyncCurrent(t)||hasCountProjection(state)||abortBlocked(state.session_id)||!processingFor(state).valid)return;
  const r=[...asyncWorks.values()].find(r=>(r.accepted||r.journalKey)&&r.user===t.user&&r.session===state.session_id&&!r.inactive&&!r.busy&&!r.failure&&(!['uncertain','failed'].includes(r.state)||(r.countedMarkerKey&&r.state==='uncertain'))&&(r.state!=='completed'||r.allowChain&&!r.chainDone));
  if(!r||performance.now()-r.lastRead<asyncBudget.minReadMs)return;
  r.busy=true;r.lastRead=performance.now();let parent=null;
  const observe=async()=>{
   parent=r.parent;parent.inFlight=true;
   try{
    if(!asyncCurrent(t)||abortBlocked(r.session))return;
    if(r.countedMarkerKey){const m=readCountedMarker(r.countedMarkerKey,r.user,r.session);
     if(!m||m.work_id!==r.work||!sameChainRequest(m.request,r.request))throw Error('counted_marker_changed');
     if(m.done){r.inactive=true;return;}
     if(Date.now()-m.lastRead<asyncBudget.minReadMs)return;
    }
    if(r.journalKey){const j=journalPhase(readJournal(r.journalKey,r.user,r.session));
     if((j?.proof_sha256??null)!==(r.resumeProof??null)){r.inactive=true;return;}
     if(j?.done){r.inactive=true;return;} // Local closure ends observation only; public completion still needs room/server proof.
     if(j&&Date.now()-j.lastRead<asyncBudget.minReadMs)return;}
    let proof=r.proof;
    if(r.state!=='completed'){
     if(!r.accepted){const data=await asyncRead({schema_version:'mission-generic-async-recover/1',master_session_id:r.session,selector:clone(r.selector)},r);
      if(!asyncCurrent(t)||abortBlocked(r.session))return;proof=recoveryProof(data,r);
      if(r.inactive)return;if(!proof){r.transportNotice=true;return;} // Claim may still be committing: read only, never infer zero sends.
     }else{const data=await asyncRead({schema_version:'mission-generic-async-status/1',request:clone(r.request)},r);if(!asyncCurrent(t)||abortBlocked(r.session))return;proof=asyncStatusProof(data,r);}
     r.proof=proof;r.state=proof.state;r.transportNotice=false;parent.outcome=proof.state==='completed'?'confirmed':['failed','uncertain'].includes(proof.state)?proof.state:'waiting';
    }
    if(r.state==='completed'&&r.allowChain&&!r.chainDone){
     const reason=await continueDirectorNarration(null,parent,t,proof);if(!asyncCurrent(t))return;
     r.chainDone=['server_proof_none','child_confirmed','child_failed','child_unconfirmed','child_already_attempted'].includes(reason);
     if(!r.chainDone&&!['server_proof_unconfirmed','context_changed','room_state_changed','child_other_inflight','child_tick_suspended','abort_pending'].includes(reason))r.failure='status_unconfirmed';
     chainFeedback.set(JSON.stringify([t.user,r.session]),{reason,target:parent.chainTarget??chainTarget(parent,r.request)});
    }
    finishJournal(r);
   }catch(e){if(asyncCurrent(t)){if(e.asyncRetryable)r.transportNotice=true;else{r.failure=e.message==='async_budget'?'budget':'status_unconfirmed';parent.outcome='uncertain';}}}
   finally{r.busy=false;if(parent)parent.inFlight=false;if(asyncCurrent(t)&&roomState?.session_id===r.session){paintRoom(roomHost,roomState);refresh();}}
  };
  const readLock=r.countedMarkerKey??r.journalKey;
  const run=readLock&&navigator.locks?.request?navigator.locks.request(readLock,{mode:'exclusive'},observe):observe();
  void run.catch(()=>{r.busy=false;if(parent)parent.inFlight=false;r.failure='status_unconfirmed';});
 }
 // A work completion alone does not attest a public Fato. Match the exact request and writer.
 function chainPublicationConfirmed(state,feedback){
  const parsed=processingFor(state),p=parsed.value,target=feedback?.target;
  return !!(parsed.valid&&target&&target.user===cacheUser&&target.session===state.session_id
   &&UUID.test(target.work||'')&&p?.work_id===target.work&&p.state==='completed'
   &&p.finalized_at!==null&&UUID.test(p.message_id||'')
   &&sameChainRequest(p.request,target.request)&&p.revision===target.request.expected_revision);
 }
 function chainTarget(attempt,request=attempt.body){
  if(!UUID.test(attempt.work||'')||!sameChainRequest(request,request)
   ||request.master_session_id!==attempt.session)return null;
  return Object.freeze({user:attempt.user,session:attempt.session,work:attempt.work,
   request:Object.freeze(clone(request))});
 }
 // One automatic successor, only through the authenticated server parent-qualified read.
 // Neither a generic ready work nor a failed/uncertain result authorizes this path.
 async function continueDirectorNarration(data,parent,t,completedProof=null){
  const delivery=data?.delivery??data;
  if(!roomCurrent(t))return 'context_changed';
  if(abortBlocked(parent.session))return 'abort_pending';
  const record=parent.asyncKey&&asyncWorks.get(parent.asyncKey);
  if(completedProof){
   if(!asyncCurrent(t)||!record||!record.accepted||!record.allowChain||record.proof!==completedProof||record.state!=='completed'
    ||asyncStatusProof(completedProof,record).state!=='completed')return 'parent_unconfirmed';
  }else if(delivery?.status!==200||delivery.code!=='MISSION_EVENT_COMPLETE'||!UUID.test(delivery.receipt_id||''))return 'parent_unconfirmed';
  const parentReceipt=completedProof?.receipt_id??delivery.receipt_id;
  const parentRequest=completedProof?record.request:parent.body.schema_version==='mission-generic-request/1'?parent.body:data?.dispatch;
  if(!sameChainRequest(parentRequest,parentRequest)||parentRequest.master_session_id!==parent.session)return 'parent_request_unavailable';
  if(!completedProof&&parent.chainReadStarted)return 'child_already_attempted';
  if(!completedProof)parent.chainReadStarted=true; // Legacy synchronous path unchanged. Async readonly errors remain retryable.
  const readBody={schema_version:'mission-director-narration-read/1',parent_request:clone(parentRequest),parent_receipt_id:parentReceipt};
  const read=completedProof?{data:await asyncRead(readBody,record)}:await client.functions.invoke('mission_generic_ai',{body:readBody});
  if(!roomCurrent(t))return 'context_changed';
  if(abortBlocked(parent.session))return 'abort_pending';
  if(read.error)return 'server_proof_unconfirmed';
  const proof=read.data,fields=['schema_version','status','parent_request','parent_receipt_id','parent_work_id','child_work_id','child_kind','source_window_id','child_request'];
  if(!proof||Object.keys(proof).length!==fields.length||!fields.every(k=>Object.hasOwn(proof,k))
   ||proof.schema_version!=='mission-director-narration-chain/1'||!['none','ready'].includes(proof.status)
   ||!sameChainRequest(proof.parent_request,parentRequest)||proof.parent_receipt_id!==parentReceipt)return 'server_proof_invalid';
  if(proof.status==='none'){
   if(['parent_work_id','child_work_id','child_kind','source_window_id','child_request'].some(k=>proof[k]!==null))return 'server_proof_invalid';
   return 'server_proof_none';
  }
  if(completedProof&&proof.parent_work_id!==record.work)return 'server_proof_invalid';
  if(!UUID.test(proof.parent_work_id||'')||!UUID.test(proof.child_work_id||'')||proof.parent_work_id===proof.child_work_id
   ||proof.child_kind!=='narration'||!UUID.test(proof.source_window_id||'')
   ||!sameChainRequest(proof.child_request,proof.child_request)
   ||proof.child_request.master_session_id!==parent.session||proof.child_request.event_id===parentRequest.event_id
   ||proof.child_request.request_key===parentRequest.request_key)return 'child_request_invalid';
  const fresh=completedProof?await asyncRoomRead(record,t):await rpc('mission_generic_room_state_v1',{p_location:t.loc.id},t.user);
  if(!roomCurrent(t)||fresh?.session_id!==parent.session)return 'room_state_changed';
  if(abortBlocked(parent.session))return 'abort_pending';
  if(fresh.review_required===true)return 'child_review_required';
  if(!fresh.can_tick)return 'child_tick_suspended';
  const parsed=processingFor(fresh),work=parsed.value;
  if(!parsed.valid)return 'child_projection_invalid';
  if(work?.state!=='ready'||work.finalized_at!==null||work.work_id!==proof.child_work_id)return 'child_projection_changed';
  if(!sameChainRequest(work.request,proof.child_request))return 'child_tuple_mismatch';
  // REQUEST/1 is an exact typed tuple, not JSON text. Key order is not an idempotency or Count hash input.
  if(JSON.stringify(work.request)!==JSON.stringify(proof.child_request)&&isStaff()&&t.loc?.id===STAFF_TEST_ROOM
   &&parent.session==='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9')
   console.info('regia_chain_diagnostic','child_request_key_order_normalized');
  const key='work:'+work.work_id+':'+work.revision,storeKey=JSON.stringify([t.user,parent.session,key]);
  if(attempts.has(storeKey))return 'child_already_attempted';
  if([...attempts.values()].some(a=>a!==parent&&a.user===t.user&&a.session===parent.session&&a.inFlight))return 'child_other_inflight';
  const a={user:t.user,session:parent.session,key,kind:'work',work:work.work_id,prior_work_id:work.work_id,
   prior_publication_id:fresh.flow_publication_id??null,staffTickSource:null,staffTickState:null,
   body:Object.freeze(clone(proof.child_request)),inFlight:true,outcome:'pending'};
  parent.chainTarget=chainTarget(a);
  attempts.set(storeKey,a);roomState=fresh;paintRoom(roomHost,fresh);
  try{
   const {data:result,error}=await invokeAsyncOnce(a,t);
   if(error)throw error;
   const asyncPending=acceptAsyncPending(result,a,t,false);
   const code=result?.delivery?.code||result?.code;
   if(code==='MISSION_EVENT_UNCERTAIN'||result?.state==='uncertain')a.outcome='uncertain';
   else if(code==='MISSION_EVENT_FAILED'||result?.state==='failed')a.outcome='failed';
   else if(asyncPending||result?.delivery?.status===202||result?.status===202)a.outcome='waiting';
   else if(result&&typeof result==='object')a.outcome='confirmed';else a.outcome='uncertain';
  }catch{a.outcome='uncertain';}
  finally{a.inFlight=false;}
  // No recursion, retry or third work. The caller's normal readback displays the child's authoritative result.
  return a.outcome==='confirmed'?'child_confirmed':a.outcome==='failed'?'child_failed':'child_unconfirmed';
 }
 function maybeDispatch(state,t,reclaim=false,explicitNoWork=false){
  if(hasOpeningResume(state)||hasOpeningClaimResume(state))return; // A proof, even malformed, cannot become an automatic resend.
  if(asyncBlocked(state))return; // An accepted async request is observed, never re-dispatched.
  if(hasCountProjection(state))return; // Only the explicit technical status consumer may handle this proof.
  const parsed=processingFor(state),p=parsed.value;
  const claimedVerification=reclaim&&parsed.valid&&staffClaimReconciliationAllowed(state,t,p);
  const recoveredReady=p?.state==='ready'&&recoveredWriters.has(recoveredWriterKey(t.user,state.session_id,p.work_id));
  if(recoveredReady&&!reclaim)return;
  if(!roomCurrent(t)||!parsed.valid||state.review_required===true&&!claimedVerification
   ||!state.can_tick&&!claimedVerification||choiceRequests.has(choiceKey(state))||liveAttempt(state)||abortBlocked(state.session_id))return;
  if(unresolvedTickForSession(state)&&!claimedVerification)return; // A known claimed request may be reconciled; no new tick is permitted.
  const role=roleProgress(state);
  const staffAcademy=isStaff()&&t.loc?.id===STAFF_TEST_ROOM&&t.loc?.is_test===true&&academyFlow(state)!==null;
  const staffCombat=staffAcademy&&academyFlow(state)==='combat_started'&&UUID.test(state.flow_publication_id||'');
  if(staffAcademy&&!role)return; // Never fall back to a browser UUID when the Staff projection is missing.
  if(role&&!staffCombat&&!claimedVerification&&!(reclaim?role.reason==='uncertain'||role.reason==='recoverable_not_started'||recoveredReady:role.reason==='ready_to_evaluate'))return; // Ready work needs an explicit Staff readback.
  if(reclaim&&(!isStaff()||t.loc?.id!==STAFF_TEST_ROOM||!t.loc?.is_test||!(claimedVerification||p?.state==='uncertain'||p?.state==='ready'&&(role?.reason==='recoverable_not_started'||recoveredReady)&&p.finalized_at===null)))return;
  if(p&&['authorized','provider_started'].includes(p.state)||p?.state==='failed'&&!(staffAcademy&&role?.reason==='ready_to_evaluate')
   ||p&&['claimed','uncertain'].includes(p.state)&&!reclaim)return;
  const staffRole=staffAcademyRole(state,t.loc),staffTick=!reclaim&&!staffCombat&&staffRole?.reason==='ready_to_evaluate'&&(!p||['completed','failed'].includes(p.state));
  const tickProjection=tickStatusFor(state,t);
  if(staffTick&&!mayCreateStaffTick(tickProjection,explicitNoWork))return;
  const recoveryKey=staffTick&&tickProjection.applicable&&tickProjection.valid&&tickProjection.value.can_resume
   ?tickProjection.value.recovery_key:null;
  const noWorkRecovery=staffTick&&explicitNoWork&&tickProjection.valid&&tickProjection.value?.state==='no_work_released'?tickProjection.value:null;
  const key=p&&(p.state==='ready'||reclaim)?'work:'+p.work_id+':'+p.revision+(reclaim?(claimedVerification?':reconcile-claimed':p.state==='ready'?':reclaim-ready':':reclaim'):'')
   :'tick:'+state.progress_key+(recoveryKey?':recovery:'+recoveryKey+(noWorkRecovery?':'+noWorkRecovery.retry_request_key:''):'');
  const storeKey=JSON.stringify([t.user,state.session_id,key]);if(attempts.has(storeKey))return;
  const body=p&&(p.state==='ready'||reclaim)?clone(p.request):staffTick
   ?{schema_version:'mission-generic-staff-tick/1',master_session_id:state.session_id,source_revision:staffRole.revision}
   :{schema_version:'mission-generic-tick/1',master_session_id:state.session_id,request_key:id()};
  const a={user:t.user,session:state.session_id,key,kind:key.startsWith('tick:')?'tick':'work',work:p&&(p.state==='ready'||reclaim)?p.work_id:null,
   prior_work_id:p?.work_id??null,prior_publication_id:state.flow_publication_id??null,staffTickSource:staffTick?staffRole.revision:null,
   staffTickState:null,tickRecoveryKey:recoveryKey,noWorkRecovery:noWorkRecovery?clone(noWorkRecovery):null,body:Object.freeze(body),inFlight:true,outcome:'pending'};attempts.set(storeKey,a);paintRoom(roomHost,state);
  // Detached from the read lock: polling continues while the provider works.
  void (async()=>{
   try{
    const {data,error}=await invokeAsyncOnce(a,t);
    if(error)throw error;
    if(staffTick){
     const tick=data?.staff_tick;
     if(data?.schema_version!=='mission-generic-progress/1'||data.master_session_id!==state.session_id
      ||!['issued','replayed','existing_work'].includes(tick?.state)||tick.source_revision!==a.staffTickSource
      ||!(tick.request_key===null||UUID.test(tick.request_key||'')))throw Error('staff_tick_response_invalid');
     a.staffTickState=tick.state;
    }
    const asyncPending=acceptAsyncPending(data,a,t);
    const code=data?.delivery?.code||data?.code;
    if(code==='MISSION_EVENT_UNCERTAIN'||data?.state==='uncertain')a.outcome='uncertain';
    else if(code==='MISSION_EVENT_FAILED'||data?.state==='failed')a.outcome='failed';
    else if(asyncPending||data?.delivery?.status===202||data?.status===202)a.outcome='waiting';
    else if(data&&typeof data==='object')a.outcome='confirmed';else a.outcome='uncertain';
    const chainReason=a.outcome==='confirmed'?await continueDirectorNarration(data,a,t).catch(()=>'verification_error')
     :a.outcome==='uncertain'?'parent_unconfirmed':null;
    if(chainReason&&roomCurrent(t)&&isStaff()&&t.loc?.id===STAFF_TEST_ROOM
     &&(state.session_id==='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'||driverFor(state).optedIn&&driverFor(state).valid))
     {chainFeedback.set(JSON.stringify([t.user,state.session_id]),{reason:chainReason,target:a.chainTarget??chainTarget(a,data?.dispatch??a.body)});
     console.info('regia_chain_diagnostic',chainReason);}
   }catch{a.outcome='uncertain';}
   finally{a.inFlight=false;if(roomCurrent(t)){paintRoom(roomHost,roomState);await updateRoom(roomHost,{manual:true});refresh();}}
  })().catch(()=>{});
 }
 async function updateRoom(host,{manual=false,verifyOnly=false}={}){
  if(!host)return;const t=syncRoom(host);
  if(!t.user||!t.loc){host.replaceChildren();host.hidden=true;return;}
  if(roomRead)return;t.readSequence=++readSequence;roomRead=t;
  try{
   const state=await rpc('mission_generic_room_state_v1',{p_location:t.loc.id},t.user);
   if(!roomCurrent(t))return;
   if(!state){roomState=null;roomSignature='';roomError='';host.replaceChildren();host.hidden=true;await mountAborts(host,null,t);return;}
    if(!UUID.test(state.session_id||'')||typeof state.step_key!=='string')throw Error('room_state_invalid');
    academyFlow(state); // The server owns both the phase and the Fato publication receipt.
    roleProgress(state); // A partial reason/remedy projection cannot authorize a dispatch.
   roomState=state;roomError='';
   const settlements=journalSettlements(state,t);
   settleAsyncRecords(settlements,t);
   restoreJournals(state,t,settlements);
   restoreCountedMarkers(state,t,settlements);
   reconcileTickAttempts(state,t);
   await readEntry(state,t.user);if(!roomCurrent(t))return;
   const key=choiceKey(state),pending=choiceRequests.get(key);
   // Only a confirmed RPC/rejection followed by an authoritative read unlocks choices.
   if(pending&&!pending.inFlight&&['confirmed','rejected'].includes(pending.phase)&&t.readSequence>pending.settledAfterRead)choiceRequests.delete(key);
   paintRoom(host,state);
   await mountAborts(host,state,t);if(!roomCurrent(t)||!roomState)return;
   if(abortBlocked(state.session_id))return;await regen.update(host,state,processingFor(state));
   observeAsyncWork(state,t);
   const projected=processingFor(state);
   if(!verifyOnly&&(!manual||academyFlow(state)==='combat_started'||staffAcademyRole(state,t.loc)?.reason==='ready_to_evaluate'
    &&projected.valid&&(!projected.value||['completed','failed'].includes(projected.value.state))))maybeDispatch(state,t);
  }catch(error){if(roomCurrent(t)){roomError='Aggiornamento non disponibile. I comandi restano sospesi; premi Aggiorna regia.';if(roomState)paintRoom(host,roomState);else{host.replaceChildren(el('p','Recupero della prova non verificabile. Nessun esito confermato.'));host.hidden=false;}}}
  finally{if(roomRead===t)roomRead=null;}
 }
 async function submitRole({characterId,body,hasCompanion=false,hasTechnique=false}){
  const user=identity(),loc=currentLocation();
  if(loc?.id!==STAFF_TEST_ROOM||loc?.is_test!==true)return {handled:false};
  if(!user)throw Error('Accedi nuovamente prima di inviare la role.');
  const state=await rpc('mission_generic_room_state_v1',{p_location:loc.id},user);
  if(!valid(user)||currentLocation()?.id!==loc.id)throw Error('Invio non confermato: stanza o sessione cambiata. Verifica la chat prima di riprovare.');
  if(!state)return {handled:false};
  if(!UUID.test(state.session_id||''))throw Error('Sessione missione non confermata. Nessun invio: aggiorna la regia.');
  const flow=academyFlow(state);
  if(flow===null)return {handled:false};
  // Durante Combat la role meccanica passa soltanto dal pannello nativo.
  // Una prosa libera resta una chat ordinaria e non avanza il round.
  if(flow==='combat_started'){
   if(hasCompanion||hasTechnique)throw Error('Il Master sta preparando l’esito: usa il pannello dello scontro per la risposta meccanica. La selezione non sarà inviata come chat.');
   return {handled:false};
  }
  if(roleProgress(state)===null)throw Error('Stato delle role non disponibile. Nessun invio: aggiorna la regia.');
  if(hasCompanion||hasTechnique)throw Error('La role della missione non può includere un’azione di compagno o tecnica tramite la chat. Togli la selezione e usa il pannello previsto.');
  if(!UUID.test(characterId||''))throw Error('Seleziona il personaggio partecipante prima di inviare la role.');
  if(typeof body!=='string'||!body.trim())throw Error('Scrivi la role prima di inviarla.');
  const response=await client.rpc('mission_role_submit_v1',{p_session:state.session_id,p_character:characterId,p_body:body});
  if(response.error){
   const raw=String(response.error.message||'');
   const labels={ROLE_SUBMIT_AUTH_REQUIRED:'Sessione scaduta: accedi di nuovo.',ROLE_SUBMIT_SCOPE_CLOSED:'La fase di missione non è più aperta: aggiorna la regia.',
    ROLE_SUBMIT_CHARACTER_INVALID:'Il personaggio selezionato non appartiene al tuo account.',ROLE_SUBMIT_NOT_PARTICIPANT:'Il personaggio selezionato non partecipa a questa missione.',
    ROLE_SUBMIT_EMPTY:'Scrivi la role prima di inviarla.',ROLE_SUBMIT_CHARACTER_DRIFT:'Il personaggio è cambiato durante l’invio: verifica la chat e chiedi allo Staff.'};
   const code=Object.keys(labels).find(k=>raw.includes(k));
   throw Error(code?labels[code]:'Invio non confermato. Verifica la chat e lo stato della missione prima di riprovare.');
  }
  const receipt=response.data;
  if(receipt?.schema_version!=='mission-role-submit/1'||receipt.master_session_id!==state.session_id
   ||receipt.accepted!==true||!UUID.test(receipt.message_id||'')||typeof receipt.mission_valid!=='boolean'
   ||!SHA.test(receipt.source_revision||'')||!(receipt.invalid_reason===null||typeof receipt.invalid_reason==='string'))
   throw Error('Ricevuta della role non confermata. Verifica la chat e lo stato della missione prima di riprovare.');
  if(!valid(user)||currentLocation()?.id!==loc.id)throw Error('Role inviata ma sessione cambiata: verifica la chat prima di continuare.');
  if(roomHost)void updateRoom(roomHost,{manual:true});
  return {handled:true,receipt};
 }
 return {editor,board,decorateBoard,updateRoom,submitRole,chatPublication,sessionId:()=>roomState?.session_id,dispose(){for(const c of aborts.values())c.dispose();aborts.clear();abortActor=null;regen.dispose();roomEpoch++;roomRead=null;roomScope=null;roomHost=null;roomState=null;roomSignature='';roomError='';entryState=null;entryPending=null;entryError='';if(currentDialog)currentDialog.close();},version:VERSION};
}
