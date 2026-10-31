export const EDITORIAL_STAFF_BUILD='staff-editorial-ui/1';
export const EDITORIAL_STAFF_CAMPAIGN='3b320588-6305-57b0-9f3d-5e42a813a803';
export const EDITORIAL_STAFF_VARIANT='canary';
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

// E66 is separate from the unchanged E65 history controller above.
export const PAIR_BUILD='staff-editorial-pair-ui/1';
export const PAIR_CAMPAIGN='23c83d81-3e37-5a7e-8056-45b009992a3f';
export const DIALOGUE_BUILD='staff-editorial-dialogue-ui/1';
export const DIALOGUE_CAMPAIGN='a8c3c6f9-949d-5b64-8a02-80667c7b4da8';
export const REVIEW_BUILD='staff-editorial-review69-ui/1';
export const REVIEW_CAMPAIGN='2bd901b7-6ba6-5319-a55a-2d2e2cfcf03b';
export const LATEST_BUILD='staff-editorial-review71-ui/1';
export const LATEST_CAMPAIGN='ff79949a-06cb-5749-a33f-3d632d78f3a5';
export const E73_BUILD='staff-editorial-review73-ui/1';
export const E73_CAMPAIGN='beabfc88-ae45-53b1-b081-d137cd8eac41';
const PAIR_SHA=/^[0-9a-f]{64}$/;
const pairExact=(v,keys)=>v!==null&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===keys.length&&keys.every(k=>Object.hasOwn(v,k));
const pairId=v=>v===null||UUID.test(v||'');
const pairHash=v=>v===null||typeof v==='string'&&PAIR_SHA.test(v);
export function createStaffEditorialPair({client,identity,isStaff,currentLocation,staffRoom,campaign=PAIR_CAMPAIGN,build=PAIR_BUILD,title='Prove Director + Fato · Staff',description='Tre campioni indipendenti dello stesso turno. Ogni avvio produce una nuova valutazione dei PNG e poi un nuovo Fato privato, senza modificare la missione.',caseLabels=null}){
 let root=null,scope=null,opened=false,busy=false,epoch=0;const values=new Map();
 const eligible=()=>isStaff()===true&&UUID.test(identity()||'')&&currentLocation()?.id===staffRoom&&currentLocation()?.is_test===true&&UUID.test(campaign);
 const journalKey=(user,no)=>`${build}:${user}:${campaign}:${no}`;
 function journal(user,no){
  const raw=sessionStorage.getItem(journalKey(user,no));if(raw===null)return null;let v;try{v=JSON.parse(raw);}catch{throw Error('Avvio locale non leggibile: nessuna nuova richiesta creata.');}
  if(!pairExact(v,['request_key','run_id','writer_run_id'])||!UUID.test(v.request_key||'')||!pairId(v.run_id)||!pairId(v.writer_run_id)||v.run_id===null&&v.writer_run_id!==null)throw Error('Avvio locale non verificabile: richiesta conservata.');return v;
 }
 const save=(user,no,value)=>sessionStorage.setItem(journalKey(user,no),JSON.stringify(value));
 function stage(value,writer=false){
  if(!pairExact(value,['run_id','state','receipt_id','raw_sha256','result_sha256','cost','reason_code',...(writer?['result']:[])])||!UUID.test(value.run_id||'')||!STATES.has(value.state)||!pairId(value.receipt_id)||!pairHash(value.raw_sha256)||!pairHash(value.result_sha256)||!scalar(value.cost)||!(value.reason_code===null||typeof value.reason_code==='string'))throw Error('Stato della coppia non verificabile.');
  if(value.state==='completed'&&(!UUID.test(value.receipt_id||'')||!PAIR_SHA.test(value.raw_sha256||'')||!PAIR_SHA.test(value.result_sha256||'')))throw Error('Ricevuta di completamento non verificabile.');
  if(writer&&value.result!==null){const r=value.result;if(!pairExact(r,['text','ok','advisories','failure_codes'])||!(r.text===null||typeof r.text==='string')||typeof r.ok!=='boolean'||!Array.isArray(r.advisories)||!r.advisories.every(x=>typeof x==='string')||!Array.isArray(r.failure_codes)||!r.failure_codes.every(x=>typeof x==='string'))throw Error('Testo finale non verificabile.');}
  return value;
 }
 function receipt(value,no,saved){
  if(!pairExact(value,['schema_version','run_id','campaign_id','case_no','replayed','retry','provider_retry_allowed','director','writer','cost'])||value.schema_version!=='staff-editorial-pair-public/1'||!UUID.test(value.run_id||'')||value.campaign_id!==campaign||value.case_no!==no||typeof value.replayed!=='boolean'||value.retry!==false||value.provider_retry_allowed!==false||!scalar(value.cost))throw Error('Ricevuta della coppia non verificabile.');
  stage(value.director);if(value.director.run_id!==value.run_id||saved.run_id!==null&&saved.run_id!==value.run_id)throw Error('Valutazione riferita a un altro avvio.');
  if(value.writer!==null){stage(value.writer,true);if(value.writer.run_id===value.run_id||saved.writer_run_id!==null&&saved.writer_run_id!==value.writer.run_id)throw Error('Fato riferito a un’altra coppia.');}
  else if(saved.writer_run_id!==null)throw Error('Il collegamento al Fato già ricevuto è cambiato.');
  return value;
 }
 function canContinue(v){return v?.director.state==='completed'&&(v.writer===null||v.writer.state==='ready');}
 async function send(no,operation){
  if(busy||!eligible())return;const user=identity(),e=epoch;let saved;
  try{
   saved=journal(user,no);
   if(operation!=='start'&&!saved?.run_id)throw Error('Avvio ancora da confermare: verifica la stessa richiesta.');
   if(operation==='continue_writer'&&!canContinue(values.get(no)?.receipt))throw Error('Leggi prima lo stato: il seguito non è disponibile.');
   if(operation==='start'&&saved?.run_id)throw Error('Campione già avviato: usa Aggiorna esito.');
   if(!saved){saved={request_key:crypto.randomUUID(),run_id:null,writer_run_id:null};save(user,no,saved);}
   busy=true;paint();const body=operation==='start'?{schema_version:'staff-editorial-pair-request/1',operation,campaign_id:campaign,case_no:no,request_key:saved.request_key}:{schema_version:'staff-editorial-pair-request/1',operation,run_id:saved.run_id};
   const response=await client.functions.invoke('mission_generic_ai',{body});if(response.error)throw Error('Risposta non confermata. L’avvio originale è conservato; verifica la stessa richiesta o aggiorna il suo esito.');
   const v=receipt(response.data,no,saved);save(user,no,{...saved,run_id:v.run_id,writer_run_id:v.writer?.run_id??saved.writer_run_id});
   if(e===epoch&&eligible()&&identity()===user)values.set(no,{receipt:v});
  }catch(error){if(e===epoch&&eligible()&&identity()===user)values.set(no,{error:error.message||'Operazione non confermata.'});}
  finally{if(e===epoch){busy=false;if(eligible()&&identity()===user)paint();}}
 }
 function stageLine(label,value){const line=element('p',label+': '+(value?labels[value.state]:'non ancora preparato'));line.setAttribute('role','status');return line;}
 function paint(){
  if(!root||!eligible())return;root.replaceChildren();const toggle=action(title,()=>{opened=!opened;paint();});toggle.setAttribute('aria-expanded',String(opened));root.append(toggle);if(!opened)return;
  root.append(element('p',description));
  for(let no=1;no<=3;no++){
   const row=element('section');row.className='mg-scene';row.append(element('strong',Array.isArray(caseLabels)&&caseLabels.length===3?'Caso '+no+' · '+caseLabels[no-1]:'Campione '+no));let saved=null,error=null;try{saved=journal(identity(),no);}catch(e){error=e.message;}
   const v=values.get(no),r=v?.receipt;
   const start=action(saved?.run_id?'Avvio già accettato':saved?'Verifica lo stesso avvio':'Avvia questo campione',()=>void send(no,'start'));start.disabled=busy||!!saved?.run_id||!!error;
   const read=action('Aggiorna esito',()=>void send(no,'read'));read.disabled=busy||!saved?.run_id||!!error;row.append(element('br'),start,read);
   if(r){row.append(stageLine('Valutazione PNG',r.director),stageLine('Fato',r.writer));
    if(canContinue(r)){const next=action('Prosegui con lo stesso Writer',()=>void send(no,'continue_writer'));next.disabled=busy;row.append(next);}
    if(r.writer?.result?.text){const text=element('div',r.writer.result.text);text.style.whiteSpace='pre-wrap';row.append(text);}
    row.append(element('p',`Costo prudente della coppia: ${r.cost} USD`));
    for(const s of [r.director,r.writer])if(s?.reason_code)row.append(element('p','Motivo registrato: '+s.reason_code.slice(0,160)));
    if(r.writer?.receipt_id)row.append(element('p','Ricevuta del Fato: '+r.writer.receipt_id));
   }else{const status=element('p',error||v?.error||(saved?.run_id?'Avvio registrato. Aggiorna per leggere i due stati.':saved?'Avvio da verificare.':'Non avviato.'));status.setAttribute('role','status');row.append(status);}
   root.append(row);
  }
 }
 return {mount(host){const next=eligible()?`${identity()}:${currentLocation().id}:${campaign}`:null;if(next!==scope){epoch++;busy=false;scope=next;values.clear();opened=false;root?.remove();root=null;}if(!next||!host?.parentElement)return;if(!root||!root.isConnected){root=element('div');root.className='mg-room';root.dataset.staffEditorialPair=build;host.insertAdjacentElement('afterend',root);paint();}},dispose(){epoch++;scope=null;busy=false;values.clear();root?.remove();root=null;}};
}
