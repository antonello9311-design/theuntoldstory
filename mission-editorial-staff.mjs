export const EDITORIAL_STAFF_BUILD='staff-editorial-ui/1';
export const EDITORIAL_STAFF_CAMPAIGN='3b320588-6305-57b0-9f3d-5e42a813a803';
export const EDITORIAL_STAFF_VARIANT='baseline';
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const STATES=new Set(['completed','failed','uncertain','ready','count_sent','counted','authorized','provider_started']);
const labels={completed:'Esito disponibile',failed:'Prova non completata',uncertain:'Esito da verificare',ready:'Richiesta accettata',count_sent:'Verifica richiesta in corso',counted:'Richiesta verificata',authorized:'Generazione autorizzata',provider_started:'Scrittura in corso'};
const element=(tag,text)=>{const n=document.createElement(tag);if(text!==undefined)n.textContent=text;return n;};
const action=(label,fn)=>{const n=element('button',label);n.type='button';n.className='mbtn';n.addEventListener('click',fn);return n;};
const scalar=v=>typeof v==='number'&&Number.isFinite(v)&&v>=0||typeof v==='string'&&/^\d+(\.\d+)?$/.test(v);
export function createStaffEditorial({client,identity,isStaff,currentLocation,staffRoom,campaign=EDITORIAL_STAFF_CAMPAIGN,variant=EDITORIAL_STAFF_VARIANT}){
 let root=null,scope=null,opened=false,busy=false,epoch=0;const results=new Map();
 const eligible=()=>isStaff()===true&&UUID.test(identity()||'')&&currentLocation()?.id===staffRoom&&currentLocation()?.is_test===true&&UUID.test(campaign)&&['baseline','canary'].includes(variant);
 const key=(user,no)=>`${EDITORIAL_STAFF_BUILD}:${user}:${campaign}:${variant}:${no}`;
 function journal(user,no){const raw=sessionStorage.getItem(key(user,no));if(raw===null)return null;let v;try{v=JSON.parse(raw);}catch{throw Error('Richiesta locale non leggibile: non viene creato un nuovo avvio.');}
  if(!v||Object.keys(v).some(k=>!['request_key','run_id'].includes(k))||!UUID.test(v.request_key||'')||!(v.run_id===null||UUID.test(v.run_id||'')))throw Error('Richiesta locale non verificabile: avvio conservato.');return v;}
 function save(user,no,value){sessionStorage.setItem(key(user,no),JSON.stringify(value));}
 function validReceipt(v,no,read){
  const allowed=['schema_version','run_id','campaign_id','case_no','variant','state','stage','replayed','retry','provider_retry_allowed',...(read?['result','result_sha256','raw_sha256','receipt_id','cost','reason_code']:[])];
  if(!v||Object.keys(v).some(k=>!allowed.includes(k))||v.schema_version!=='staff-editorial-public/1'||!UUID.test(v.run_id||'')||v.campaign_id!==campaign||v.case_no!==no||v.variant!==variant||!STATES.has(v.state)||(v.stage!==undefined&&v.stage!=='narration')||v.retry!==false||v.provider_retry_allowed!==false)throw Error('Ricevuta della prova non verificata. Nessun nuovo avvio automatico.');
  if(read&&v.result!==null&&v.result!==undefined){const r=v.result;if(!r||Object.keys(r).some(k=>!['text','ok','advisories','failure_codes'].includes(k))||!(r.text===null||typeof r.text==='string')||typeof r.ok!=='boolean'||!Array.isArray(r.advisories)||!Array.isArray(r.failure_codes))throw Error('Esito della prova non verificabile.');}return v;
 }
 async function send(no,read){
  if(busy||!eligible())return;const user=identity(),e=epoch;let saved;
  try{saved=journal(user,no);if(read&&!saved?.run_id)throw Error('Avvio ancora da confermare: usa Verifica lo stesso avvio.');
   if(!saved){saved={request_key:crypto.randomUUID(),run_id:null};save(user,no,saved);}
   if(!read&&saved.run_id)throw Error('La prova è già stata avviata: usa Leggi esito.');
   busy=true;paint();const body=read?{schema_version:'staff-editorial-request/1',operation:'read',run_id:saved.run_id}:{schema_version:'staff-editorial-request/1',operation:'start',campaign_id:campaign,case_no:no,variant,request_key:saved.request_key};
   const response=await client.functions.invoke('mission_generic_ai',{body});if(response.error)throw Error('Risposta non confermata. La richiesta originale è conservata; verifica lo stesso avvio oppure leggi il suo esito.');
   const receipt=validReceipt(response.data,no,read);if(saved.run_id&&saved.run_id!==receipt.run_id)throw Error('Ricevuta riferita a una prova diversa.');save(user,no,{...saved,run_id:receipt.run_id});
   if(e===epoch&&eligible()&&identity()===user)results.set(no,{receipt});
  }catch(error){if(e===epoch&&eligible()&&identity()===user)results.set(no,{error:error.message||'Prova non confermata.'});}
  finally{if(e===epoch){busy=false;if(eligible()&&identity()===user)paint();}}
 }
 function paint(){if(!root||!eligible())return;root.replaceChildren();const toggle=action('Prove editoriali Staff',()=>{opened=!opened;paint();});toggle.setAttribute('aria-expanded',String(opened));root.append(toggle);if(!opened)return;
  root.append(element('p',`Confronto ${variant==='baseline'?'di riferimento':'con nuove istruzioni'}. Gli esiti restano separati dalla chat della missione.`));
  const titles=['Dialogo e domande','Risposta alla proposta','Scontro, ambiente e continuità'];
  for(let no=1;no<=3;no++){
   const row=element('section');row.className='mg-scene';row.append(element('strong',`Caso ${no} · ${titles[no-1]}`));let saved=null,storageError=null;try{saved=journal(identity(),no);}catch(e){storageError=e.message;}
   const start=action(saved?.run_id?'Avvio già accettato':saved?'Verifica lo stesso avvio':'Avvia questa prova',()=>void send(no,false));start.disabled=busy||!!saved?.run_id||!!storageError;
   const read=action('Leggi / aggiorna esito',()=>void send(no,true));read.disabled=busy||!saved?.run_id||!!storageError;row.append(element('br'),start,read);
   const value=results.get(no),status=element('p',storageError||value?.error||(value?.receipt?labels[value.receipt.state]:saved?.run_id?'Prova registrata. Leggi l’esito quando vuoi.':saved?'Avvio da verificare.':'Non avviata.'));status.setAttribute('role','status');row.append(status);
   const v=value?.receipt;if(v?.result?.text){const text=element('div',v.result.text);text.style.whiteSpace='pre-wrap';row.append(text);}
   if(scalar(v?.cost))row.append(element('p',`Costo prudente: ${v.cost} USD`));
   if(UUID.test(v?.receipt_id||''))row.append(element('p','Ricevuta: '+v.receipt_id));
   if(v?.reason_code)row.append(element('p','Motivo registrato: '+String(v.reason_code).slice(0,160)));
   root.append(row);
  }
 }
 return {mount(host){const next=eligible()?`${identity()}:${currentLocation().id}:${campaign}:${variant}`:null;if(next!==scope){epoch++;busy=false;scope=next;results.clear();opened=false;root?.remove();root=null;}if(!next||!host?.parentElement)return;if(!root||!root.isConnected){root=element('div');root.className='mg-room';root.dataset.staffEditorial=EDITORIAL_STAFF_BUILD;host.insertAdjacentElement('afterend',root);paint();}},dispose(){epoch++;scope=null;busy=false;results.clear();root?.remove();root=null;}};
}
