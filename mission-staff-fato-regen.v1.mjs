// Staff-only controller. The server projection remains authoritative.
export const VERSION='mission-staff-fato-regen/1';
const STAFF_ROOM='0b85f354-9cdb-47e1-baf9-3d266bb7e06b';
const uuid=x=>typeof x==='string'&&/^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/i.test(x);
const node=(tag,text)=>{const n=document.createElement(tag);if(text!==null)n.textContent=text;return n;};

export function createStaffFatoRegen({client,identity,isStaff,currentLocation,refresh}){
 let scope='',epoch=0,view=null,request=null,inFlight=false,styleReady=false;
 function enabled(){const loc=currentLocation();return !!identity()&&isStaff()&&loc?.id===STAFF_ROOM&&loc?.is_test===true;}
 function style(){
  if(styleReady)return;styleReady=true;
  const css=node('style',null);css.textContent=`
  .mg-regen{border-top:1px solid var(--rule,#aa9678);padding-top:8px;margin-top:4px;color:var(--ink,#29251f)}
  .mg-regen-title{font:600 11px Cinzel,serif;color:var(--red-deep,#712c29)}
  .mg-regen-actions{display:flex;flex-wrap:wrap;gap:6px;margin:5px 0}
  .mg-regen-status{font-size:13px;line-height:1.4;margin:3px 0}
  .mg-regen-dialog{width:min(740px,94vw);max-height:90dvh;overflow:auto;box-sizing:border-box;border:1px solid var(--rule,#aa9678);border-radius:12px;background:#f2eee1;color:var(--ink,#29251f);padding:18px}
  .mg-regen-dialog::backdrop{background:#0009}
  .mg-regen-dialog h3{font-family:Cinzel,serif;color:var(--red-deep,#712c29)}
  .mg-regen-dialog dt{font-weight:700;margin-top:8px}
  .mg-regen-dialog dd{margin:2px 0 8px;overflow-wrap:anywhere}
  .mg-regen-dialog button{min-height:38px}
  `;document.head.append(css);
 }
 async function read(session){
  const r=await client.rpc('mission_staff_fato_regen_status_v1',{p_session:session});
  if(r.error)throw Error(r.error.message||'Stato rigenerazione non disponibile.');
  if(r.data?.schema_version!==VERSION||r.data.session_id!==session)throw Error('Stato rigenerazione non valido.');
  return r.data;
 }
 function formatCost(provider){
  if(!provider)return 'Non registrato';
  const calls=Number(provider.calls||0),cost=Number(provider.cost_usd||0);
  return calls+' chiamata/e · '+cost.toFixed(4)+' $';
 }
 function showDetails(s,returnTo){
  const d=node('dialog',null);d.className='mg-regen-dialog';d.setAttribute('aria-label','Come è stato prodotto questo Fato');
  const h=node('h3','Come è stato prodotto questo Fato'),close=node('button','Chiudi');
  close.type='button';close.addEventListener('click',()=>d.close());
  const summary=node('p',s.revision?.work_state==='completed'
   ?'Il nuovo Fato è stato pubblicato usando le role e la decisione della scena, senza una nuova Regia o azione Combat.'
   :s.revision?'La richiesta conserva le role e la decisione della scena; il nuovo Fato non è ancora pubblicato.'
    :'Non è ancora registrata una rigenerazione per questo Fato.');
  d.append(h,close,summary);
  const list=node('dl',null);
  const add=(label,value)=>{list.append(node('dt',label),node('dd',value??'Non registrato'));};
  add('Fase',s.target?.step_key);
  add('Role della finestra',String(s.revision?.role_count??s.target?.role_count??'Non registrato'));
  add('Fato corrente',s.target?.message_id||'Non registrato');
  add('Stato',s.revision?.work_state||'Nessuna richiesta');
  add('Prompt/versione',s.revision?.prompt_version||'Non registrato');
  add('Prompt assemblato',s.revision?.prompt_text||'Non registrato');
  add('Chiamata',formatCost(s.revision?.provider));
  add('Token input/output',s.revision?.provider?
    String(s.revision.provider.input_tokens||0)+' / '+String(s.revision.provider.output_tokens||0):'Non registrato');
  add('Errore',s.revision?.failure_code||'Nessuno registrato');
  add('Work',s.revision?.work_id);
  d.append(list);document.body.append(d);
  d.addEventListener('close',()=>{d.remove();returnTo?.focus();},{once:true});d.showModal();close.focus();
 }
 function statusLabel(s){
  const w=s.revision?.work_state;
  if(inFlight)return 'Il Fato è in elaborazione. Il precedente resta visibile.';
  if(w==='ready')return 'Richiesta pronta. Riprendi la stessa richiesta senza crearne un’altra.';
  if(['claimed','authorized','provider_started','uncertain'].includes(w))return 'Rigenerazione in corso; verifica la stessa richiesta.';
  if(w==='failed')return 'Rigenerazione fallita: il Fato precedente resta corrente. '+(s.revision?.failure_code||'Controlla i dettagli.');
  if(w==='completed')return 'Nuovo Fato pubblicato; il precedente è conservato come esito superato.';
  return s.target?.eligible?'Il Fato corrente può essere rigenerato.':(s.target?.reason||'Rigenerazione non disponibile.');
 }
 async function send(s,host,existing=false){
  if(inFlight||!enabled()||!uuid(s?.session_id))return;
  inFlight=true;await paint(host,s);
  const previous=s.target?.message_id;
  try{
   if(!existing){
    if(!s.target?.eligible||!uuid(previous))throw Error(s.target?.reason||'Fato non eleggibile.');
    const key=crypto.randomUUID();request={session:s.session_id,key,target:previous};
    const r=await client.rpc('mission_staff_fato_regenerate_v1',
      {p_session:s.session_id,p_target_message:previous,p_request:key});
    if(r.error)throw Error(r.error.message||'Richiesta non confermata.');
    s=r.data;
   }
   const q=s.revision?.request;
   if(!q||q.schema_version!=='mission-generic-request/1'||q.master_session_id!==s.session_id)
     throw Error('Richiesta non confermata: verifica lo stato.');
   const r=await client.functions.invoke('mission_generic_ai',{body:structuredClone(q)});
   if(r.error)throw Error('Esito di rete incerto: verifica la stessa richiesta.');
  }catch(error){
   const label=host.querySelector('[data-mg-regen-status]');
   if(label)label.textContent=error.message||'Invio non confermato.';
  }finally{
   inFlight=false;
   try{const fresh=await read(s.session_id);if(scope===JSON.stringify([identity(),s.session_id])){view=fresh;await paint(host,fresh);refresh();}}
   catch{/* Keep the local warning; never invent a final state. */}
  }
 }
 async function paint(host,s){
  if(!host?.isConnected||!enabled()||!s)return;
  style();let wrap=host.querySelector('[data-mg-regen]');
  if(!wrap){wrap=node('section',null);wrap.className='mg-regen';wrap.dataset.mgRegen='';
   host.append(wrap);}
  wrap.replaceChildren();
  const title=node('div','Ultimo Fato'+(s.target?.message_at?' · '+new Date(s.target.message_at).toLocaleString('it-IT'):''));title.className='mg-regen-title';
  const actions=node('div',null);actions.className='mg-regen-actions';
  const w=s.revision?.work_state,ongoing=['ready','claimed','authorized','provider_started','uncertain'].includes(w);
  const primary=node('button',ongoing?'Verifica la stessa richiesta':'Rigenera ultimo Fato');
  primary.type='button';primary.disabled=inFlight||(!ongoing&&!s.target?.eligible);
  primary.addEventListener('click',()=>send(s,host,ongoing));
  const info=node('button','Come è stato prodotto?');info.type='button';
  info.addEventListener('click',()=>showDetails(s,info));
  actions.append(primary,info);
  const status=node('p',statusLabel(s));status.className='mg-regen-status';
  status.dataset.mgRegenStatus='';status.setAttribute('role','status');status.setAttribute('aria-live','polite');
  wrap.append(title,actions,status);
 }
 async function update(host,room){
  if(!enabled()||!uuid(room?.session_id)){host?.querySelector('[data-mg-regen]')?.remove();return;}
  const next=JSON.stringify([identity(),room.session_id]);
  if(next!==scope){scope=next;epoch++;view=null;request=null;}
  const current=epoch;
  try{const s=await read(room.session_id);if(current!==epoch||!host?.isConnected)return;view=s;await paint(host,s);}
  catch(error){if(current!==epoch)return;const label=host.querySelector('[data-mg-regen-status]');if(label)label.textContent='Rigenerazione non disponibile: '+error.message;}
 }
 return {update,dispose(){scope='';epoch++;view=null;request=null;inFlight=false;}};
}
