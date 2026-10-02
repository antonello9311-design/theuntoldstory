import {createStaffAbortController} from './mf-staff-simulation-abort-ui-690bd0bbb5f02971511480616c5b92b4d3e4d5eb5c3efa23cae1de4894f2298d.mjs';
import {createQuestRuntimeApi,QUEST_STAFF_LOCATION,questRewardServerReason} from './mf-quest-runtime-api-3cece36ec7e80e4e86831eaf81cf79671f331446d240be9a79cdf13122d92b2c.mjs';
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const labels={source_only:'Puntata da preparare',open:'Iscrizioni aperte',in_progress:'Puntata in corso',completed:'Puntata conclusa',failed:'Puntata conclusa',cancelled:'Puntata annullata',enrollment_open:'Iscrizioni aperte',prepared:'Squadra preparata: la scena non è ancora iniziata',opening_pending:'In attesa del Fato iniziale',started:'Scena pubblicata',closing_pending:'In attesa del Fato conclusivo',terminal:'Puntata conclusa',uncertain:'Esito da riconciliare',unavailable:'Puntata non disponibile',unknown:'Richiesta da riconciliare'};
const el=(tag,text='')=>{const n=document.createElement(tag);n.textContent=text;return n;};
function skin(root){root.style.cssText='box-sizing:border-box;max-width:100%;padding:16px;background:#f6edda;color:#302517;border:1px solid #b69a65;border-radius:10px;font-size:18px;font-weight:550;line-height:1.55;overflow-wrap:anywhere';}
const uuid=()=>crypto.randomUUID();
function shell(root,title){skin(root);const heading=el('h3',title),message=el('p'),body=el('div'),tools=el('div');message.setAttribute('role','status');message.setAttribute('aria-live','polite');tools.style.cssText='display:flex;gap:10px;flex-wrap:wrap';root.replaceChildren(heading,message,body,tools);return {message,body,tools};}
function button(root,text,handler,disabled=false){const b=el('button',text);b.type='button';b.disabled=disabled;b.style.cssText='min-height:44px;padding:10px 14px;font:inherit;color:#572d23;border:1px solid #b69a65;border-radius:7px;background:#fff8e7';b.addEventListener('click',handler);root.append(b);return b;}

function rewardSummary(parent,value,{staff=false}={}){
 if(!value)return;
 if(value.state==='legacy'){parent.append(el('p','Premio storico: resta il percorso Staff previsto dalla policy precedente.'));return;}
 parent.append(el('p','Premio base automatico: 30 XP per ogni PG idoneo, sia in successo sia in fallimento. 0 Ryō, nessun oggetto.'));
 if(value.qualification.reason_code)parent.append(el('p',`Motivo restituito dal server: ${value.qualification.reason_code}.`));
 const d=value.decision;
 if(!d){parent.append(el('p',value.state==='not_terminal'?'L’arco non è concluso: la puntata intermedia non assegna il premio base.':value.state==='pending_award'?'L’arco è concluso; il premio automatico è da registrare senza una nuova scelta dell’importo.':'Idoneità o percorso premio non confermati: nessuna attribuzione viene confermata.'));return;}
 if(d.effect_mode==='simulation')parent.append(el('p','Ricevuta automatica simulata: 30 XP calcolati, 0 XP accreditati alle schede reali. Gli eventuali extra richiedono una decisione Staff separata.'));
 else if(staff&&value.availability?.scope!=='public')parent.append(el('p','Ricevuta con effetti reali: questa superficie Staff protetta non può confermarla.'));
 else parent.append(el('p','Il server registra il premio attribuito.'));
 if(!staff)for(const a of value.awards)parent.append(el('p',a.effect_mode==='simulation'?'La tua ricevuta è simulata: nessun XP reale attribuito.':`Premio registrato per il tuo PG: ${a.effective_xp} XP.`));
}

// Il pannello legge il proprio PG; nessuna receipt Staff o continuity entra nel DOM.
export function mountQuestParticipant(root,{client,identity,isCurrent=()=>true,onScene=()=>{}}={}){
 const api=createQuestRuntimeApi(client,{identity,isCurrent:()=>!disposed&&root.isConnected&&isCurrent()}),ui=shell(root,'Quest assegnata');let episode=null,state=null,rewardView=null,rewardReadReason=null,epoch=0,disposed=false,busy=false;
 const actor=identity();
 const valid=t=>!disposed&&root.isConnected&&identity()===actor&&isCurrent()&&t===epoch;
 function inactive(){ui.body.replaceChildren();ui.tools.replaceChildren();ui.message.textContent='Contesto cambiato: riapri Quest dalla scheda Missioni.';}
 function controls(){ui.tools.replaceChildren();if(!valid(epoch)){inactive();return;}const pending=api.journal(episode).pending;
  button(ui.tools,'Aggiorna stato',()=>void refresh(),busy);
  if(pending){button(ui.tools,'Ripeti la stessa richiesta',()=>void act(()=>api.replay(episode)),busy);return;}
  if(!state||busy)return;
  const request=(operation,ready)=>({p_episode:episode,p_operation:operation,p_ready:ready,p_expected_version:operation==='join'?null:state.enrollment_control_version,p_request:uuid()});
  if(state.actions.join)button(ui.tools,'Iscriviti',()=>void act(()=>api.send(episode,'enrollment',request('join',null))));
  if(state.actions.withdraw)button(ui.tools,'Ritira iscrizione',()=>void act(()=>api.send(episode,'enrollment',request('withdraw',null))));
  if(state.actions.ready)button(ui.tools,state.ready?'Non sono pronto':'Sono pronto',()=>void act(()=>api.send(episode,'enrollment',request('ready',!state.ready))));
  if(state.phase==='started')button(ui.tools,'Vai alla scena',()=>void scene());
 }
 function draw(){ui.body.replaceChildren();ui.body.append(el('p',labels[state.phase]));ui.body.append(el('p',`Iscrizione: ${state.enrollment_state==='joined'?'confermata':state.enrollment_state==='withdrawn'?'ritirata':'da confermare'}. Prontezza: ${state.ready?'confermata':'da confermare'}.`));ui.body.append(el('p',`Presenza nella chat: ${state.present_now===null?'non disponibile':state.present_now?'presente':'non presente'}.`));if(state.terminal){ui.body.append(el('p',state.terminal.outcome==='success'?'Puntata riuscita.':'Puntata conclusa senza successo.'));if(rewardView)rewardSummary(ui.body,rewardView);else ui.body.append(el('p','Stato premi da verificare. L’eventuale puntata successiva richiede una nuova iscrizione.'));if(rewardReadReason)ui.body.append(el('p',rewardReadReason));}controls();}
 async function refresh(){if(!episode||busy)return;api.invalidate();const t=++epoch;busy=true;ui.message.textContent='Lettura dello stato…';controls();try{const recovery=await api.recover(episode);if(!valid(t))return;const value=await api.participant(episode);if(!valid(t))return;state=value;rewardView=null;rewardReadReason=null;
 if(value.terminal){
   try{const r=await api.rewardByEpisode(episode,value.character_id,value.terminal.native_terminal_receipt_id);if(!valid(t))return;rewardView=r.reward;
   }catch(error){if(!valid(t))return;const reason=questRewardServerReason(error);rewardReadReason=reason?`Lettura premi non disponibile: ${reason}.`:'Lettura premio non confermata.';}
 }
 ui.message.textContent=recovery&&['unknown','uncertain'].includes(recovery.state)?'Richiesta ancora da riconciliare: nessun comando reinviato.':'';draw();}catch(e){if(valid(t)){state=null;ui.body.replaceChildren();ui.message.textContent='Stato Quest non disponibile. Nessuna azione viene confermata.';}}finally{busy=false;if(valid(t))controls();else inactive();}}
 async function act(fn){if(busy||!valid(epoch))return;const t=epoch;busy=true;controls();let error=null;try{await fn();}catch(e){error=e.message||'Operazione non confermata.';}finally{busy=false;}if(!valid(t)){inactive();return;}await refresh();if(error&&valid(epoch))ui.message.textContent=error;}
 async function scene(){if(busy||!valid(epoch))return;const t=epoch;busy=true;controls();try{const latest=await api.participant(episode);if(!valid(t))return;state=latest;draw();if(latest.phase==='started')await onScene({session:latest.native_session_id,character:latest.character_id,episode});else ui.message.textContent='La scena non è disponibile per nuove azioni.';}catch{if(valid(t))ui.message.textContent='Scena non confermata: aggiorna lo stato.';}finally{busy=false;if(valid(t))controls();}}
 return {open:async id=>{if(busy)throw Error('Lettura in corso: attendi.');if(!UUID.test(id||'')||identity()!==actor)throw Error('Puntata non disponibile.');episode=id;state=null;epoch++;await refresh();},dispose:()=>{api.dispose();disposed=true;epoch++;root.replaceChildren();}};
}
// N+1 è un gesto Staff esplicito su una puntata esistente: nessuna generazione client.
export function mountQuestStaffRuntime(root,{client,identity,isCurrent=()=>true,onScene=()=>{}}={}){
 const api=createQuestRuntimeApi(client,{identity,isCurrent:()=>!disposed&&root.isConnected&&isCurrent(),currentSession:()=>state?.native_session_id}),ui=shell(root,'Gestione puntata Quest');let episode=null,state=null,run=null,rewardView=null,rewardPolicies=[],rewardReadReason=null,locations=[],selectedLocation='',epoch=0,disposed=false,busy=false;
 const actor=identity(),valid=t=>!disposed&&root.isConnected&&identity()===actor&&isCurrent()&&t===epoch;
 const abortHost=el('div');abortHost.hidden=true;root.append(abortHost);
 let abortBinding=null;
 const abort=createStaffAbortController({client,identity,isCurrent:()=>!!abortBinding&&valid(abortBinding.epoch)&&episode===abortBinding.episode&&state?.native_session_id===abortBinding.session,onCommitted:r=>{if(!abortBinding||!valid(abortBinding.epoch)||episode!==abortBinding.episode||state?.native_session_id!==r.master_session_id)return;state=run=null;ui.tools.replaceChildren();ui.body.replaceChildren(el('p','Prova annullata. Fato e storico conservati; nessun esito o premio attribuito.'));ui.message.textContent='';}});

 const form=el('div'),input=el('input'),rosterInput=el('textarea');input.placeholder='ID della puntata pubblicata';input.setAttribute('aria-label','ID puntata Quest');rosterInput.placeholder='Da 1 a 4 ID PG assegnabili, uno per riga';rosterInput.setAttribute('aria-label','Roster della puntata successiva');for(const n of [input,rosterInput])n.style.cssText='box-sizing:border-box;width:100%;font:inherit;padding:10px;color:#302517;background:#fff8e7;border:1px solid #b69a65';form.append(input);ui.body.before(form);button(form,'Apri puntata',()=>void open(input.value.trim()));
 function controls(){ui.tools.replaceChildren();if(!valid(epoch)){ui.message.textContent='Accesso cambiato: riapri l’editor.';return;}button(ui.tools,'Aggiorna stato',()=>void refresh(),busy||!episode);if(!state||busy||!episode||state.execution_context?.mode==='staff_simulation'&&abort.blocked(state.native_session_id))return;const pending=api.journal(episode).pending;
 if(pending){button(ui.tools,'Ripeti la stessa richiesta',()=>void act(()=>api.replay(episode)));return;}
 if(state.actions.assign_roster&&state.episode_ordinal>1&&state.previous_episode_terminal_receipt_id){if(!rosterInput.isConnected)ui.body.append(rosterInput);button(ui.tools,'Assegna squadra alla puntata',()=>{const ids=rosterInput.value.split(/[\s,;]+/).filter(Boolean);if(ids.length<1||ids.length>4||new Set(ids).size!==ids.length||ids.some(x=>!UUID.test(x))){ui.message.textContent='Scegli da 1 a 4 PG distinti.';return;}void act(()=>api.send(episode,'assign',{p_episode:episode,p_character_ids:ids,p_request:uuid()}));});}
 if(state.actions.prepare&&state.prepare_ready){
   const publicScope=state.execution_context?.mode==='public_real';
   if(publicScope){const location=el('select');location.setAttribute('aria-label','Chat della puntata Quest');location.style.cssText=input.style.cssText;const empty=el('option','Scegli la chat della puntata…');empty.value='';location.append(empty);for(const row of locations){const option=el('option',row.name);option.value=row.id;location.append(option);}location.value=selectedLocation;location.addEventListener('change',()=>{selectedLocation=location.value;controls();});ui.tools.append(location);}
   button(ui.tools,publicScope?'Prepara la squadra nella chat scelta':'Prepara la squadra nella Staff Test Room',()=>void act(()=>api.send(episode,'prepare',{p_arc:state.quest_arc_id,p_episode:episode,p_location:publicScope?selectedLocation:state.execution_context.location_id,p_roster:state.assignment.member_character_ids,p_request:uuid()})),publicScope&&!locations.some(x=>x.id===selectedLocation));
 }
 if(state.actions.start&&run?.state==='prepared'&&run.operation==='prepare'&&state.prepare_request_key===run.request_key)button(ui.tools,'Avvia Quest IA',()=>void act(()=>api.send(episode,'start',{p_prepare_request:state.prepare_request_key,p_expected_control_version:run.run_control_version,p_request:uuid()})));
 if(run?.state==='started')button(ui.tools,'Vai alla scena',()=>void scene());
 }

 function drawRewards(){
 const box=el('section'),tools=el('div');box.append(el('h4','Premio Quest · base automatico ed extra Staff'));
 if(rewardView)rewardSummary(box,rewardView,{staff:true});
 else box.append(el('p','Stato premio non confermato dal server.'));
 if(rewardReadReason)box.append(el('p',`Motivo restituito dal server: ${rewardReadReason}.`));
 const pending=api.rewardJournal(state.quest_arc_id).pending;
 const publicReward=rewardView?.execution_context?.mode==='public_real';
 const binding=publicReward?rewardView?.public_writer_binding:rewardView?.abort_binding;
 const bindingReady=!!binding&&binding.actor_auth_id===actor&&binding.arc_id===state.quest_arc_id&&binding.terminal_receipt_id===rewardView.terminal_receipt_id&&binding.arc_source_sha256===rewardView.source_sha256&&binding.policy_sha256===rewardView.policy_sha256&&binding.decision_id===(rewardView.decision?.decision_id??null)&&(publicReward?binding.schema_version==='quest-reward-public-writer-binding/3'&&binding.effect_mode==='real'&&rewardView.qualification.real_qualified&&rewardView.qualification.public_admitted:binding.schema_version==='quest-reward-abort-binding/1'&&binding.effect_mode==='simulation'&&!abort.blocked(binding.native_session_id));
 const baseAllowed=rewardView?.actions.base_recover===true&&bindingReady,extraAllowed=rewardView?.actions.staff_extra===true&&bindingReady;
 if(!bindingReady)box.append(el('p',rewardView?.qualification.reason_code?`Premi non disponibili: ${rewardView.qualification.reason_code}.`:binding?'Binding premio non coerente o annullamento da riconciliare: rileggi lo stato.':'Binding premio non disponibile: nessuna richiesta mutante può partire.'));
 if(pending){box.append(el('p','Una richiesta premio è da riconciliare: UUID e payload conservati.'));
   button(tools,'Rileggi la stessa richiesta premio',()=>void act(()=>api.rewardRecover(state.quest_arc_id)));
   button(tools,'Ripeti la stessa richiesta premio',()=>void act(()=>api.rewardReplay(state.quest_arc_id)),pending.operation==='base'?!baseAllowed:!extraAllowed);
 }
 if(rewardView?.actions.base_recover===true)button(tools,'Recupera la registrazione del premio automatico',()=>void act(()=>api.rewardSend(state.quest_arc_id,'base',{
   p_arc:state.quest_arc_id,p_terminal_receipt:rewardView.terminal_receipt_id,p_expected_arc_source_sha256:rewardView.source_sha256,
   p_expected_policy_sha256:rewardView.policy_sha256,p_request:uuid()})),!!pending||!baseAllowed);
 const recipient=el('select'),amount=el('input'),reason=el('textarea');recipient.setAttribute('aria-label','Destinatario extra Staff');
 recipient.append(el('option','Scegli destinatario…'));recipient.firstChild.value='';
 for(const a of rewardView?.awards||[]){const o=el('option',a.character_id);o.value=a.character_id;recipient.append(o);}
 amount.type='number';amount.min='1';amount.step='1';amount.value='';amount.setAttribute('aria-label','XP extra Staff espliciti');reason.setAttribute('aria-label','Motivazione extra Staff');reason.maxLength=1000;
 for(const control of [recipient,amount,reason])control.disabled=!extraAllowed||!!pending;
 box.append(el('p','Extra Staff separato dal premio base; nessun importo precompilato.'),recipient,amount,reason);
 if(!extraAllowed)box.append(el('p',rewardView?.qualification.reason_code?`Extra non disponibile: ${rewardView.qualification.reason_code}.`:'Il server non offre un extra Staff per questo stato.'));
 button(tools,'Registra extra Staff separato',()=>void act(()=>api.rewardSend(state.quest_arc_id,'extra',{
   p_arc:state.quest_arc_id,p_character:recipient.value,p_amount:Number(amount.value),p_reason:reason.value.trim(),p_request:uuid()})),!extraAllowed||!!pending);
 box.append(tools);ui.body.append(box);
 }

 function draw(){ui.body.replaceChildren();ui.body.append(el('p',`Puntata ${state.episode_ordinal} · ${labels[run?.state]||labels[state.state]||'Stato non operativo'}`));ui.body.append(el('p',`Squadra assegnata: ${state.assignment.member_count} PG. Iscrizioni ${state.enrollment_open?'aperte':'chiuse'}; preparazione ${state.prepare_ready?'disponibile':'non disponibile'}.`));ui.body.append(el('p','L’assegnazione non iscrive i PG e non conferma la loro prontezza o presenza.'));ui.body.append(el('p','Annullamento protetto ancora da integrare: questa candidata non è abilitabile al collaudo. Le sostituzioni durante la puntata restano da qualificare.'));if(state.episode_ordinal>1)ui.body.append(el('p','La puntata precedente deve avere il Fato conclusivo pubblicato. Nessun avvio automatico della successiva.'));drawRewards();controls();}
 async function refresh(){if(!episode||busy)return;api.invalidate();abort.invalidate();abortBinding=null;abortHost.hidden=true;const t=++epoch;busy=true;controls();ui.message.textContent='Lettura dello stato…';try{const recovery=await api.recover(episode);if(!valid(t))return;const s=await api.episode(episode);if(!valid(t))return;state=s;locations=s.actions.prepare&&s.prepare_ready?await api.locations(s.availability,s.execution_context):[];if(!valid(t))return;if(!locations.some(x=>x.id===selectedLocation))selectedLocation='';if(s.execution_context?.mode==='staff_simulation'&&s.native_session_id){abortBinding={epoch:t,episode,session:s.native_session_id};await abort.mount(abortHost,s.native_session_id);if(!valid(t))return;if(abort.blocked(s.native_session_id)){ui.tools.replaceChildren();return;}}else{abortBinding=null;abort.invalidate();abortHost.hidden=true;}let r=null;const request=s.start_request_key||s.prepare_request_key;if(request)r=await api.runState(request);if(!valid(t))return;if(r?.receipt?.native_session_id&&r.receipt.native_session_id!==s.native_session_id)throw Error('Sessione divergente.');run=r;rewardView=null;rewardPolicies=[];rewardReadReason=null;
 try{await api.rewardRecover(s.quest_arc_id);if(!valid(t))return;rewardView=await api.rewardState(s.quest_arc_id);if(!valid(t))return;
   rewardPolicies=(await api.rewardCatalog()).reward_policies;if(!valid(t))return;
 }catch(error){if(!valid(t))return;rewardReadReason=questRewardServerReason(error);}
 ui.message.textContent=recovery&&['unknown','uncertain'].includes(recovery.state)?'Richiesta da riconciliare: UUID e payload conservati.':'';draw();}catch(e){if(valid(t)){state=run=null;ui.body.replaceChildren();ui.message.textContent='Puntata non disponibile: nessun avvio confermato.';}}finally{busy=false;if(valid(t))controls();}}
 async function act(fn){if(busy||!valid(epoch))return;const t=epoch;busy=true;controls();let error=null;try{await fn();}catch(e){error=e.message||'Operazione non confermata.';}finally{busy=false;}if(!valid(t))return;await refresh();if(error&&valid(epoch))ui.message.textContent=error;}
 async function scene(){if(busy||!valid(epoch)||!state?.start_request_key)return;const t=epoch;busy=true;controls();try{const fresh=await api.runState(state.start_request_key);if(!valid(t))return;if(fresh.state!=='started'||!fresh.opening_publication_id){ui.message.textContent='Attendi la conferma del Fato iniziale.';return;}await onScene({session:state.native_session_id,episode});}catch{if(valid(t))ui.message.textContent='Scena non confermata.';}finally{busy=false;if(valid(t))controls();}}
 async function open(id){if(busy)return;if(!UUID.test(id||'')){ui.message.textContent='Inserisci un ID puntata valido.';return;}api.invalidate();abort.invalidate();abortBinding=null;abortHost.hidden=true;episode=id;input.value=id;state=run=null;epoch++;await refresh();}
 return {open,dispose:()=>{api.dispose();abort.dispose();disposed=true;epoch++;root.replaceChildren();}};
}
