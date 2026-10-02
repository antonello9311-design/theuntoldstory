import {createExistingVariantApi} from './mf-existing-variant-api-4da016a95b0df7af39cf9ef8f47cffd6737cc42656c5788cc1eb923caace462a.mjs';
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const copy=x=>structuredClone(x);
const node=(tag,text='',attrs={})=>{const n=document.createElement(tag);n.textContent=text;for(const [k,v]of Object.entries(attrs))n.setAttribute(k,v);return n;};
const button=(text,fn)=>{const b=node('button',text,{type:'button','data-variant-control':''});b.addEventListener('click',()=>void fn());return b;};
const sourceFields=['title','grado','briefing','village','tag_trama','team_min','team_max'];
export function mountExistingVariantEditor({host,client,identity,nativeUI,isCurrent,storage}={}){
 if(!host?.isConnected||typeof identity!=='function'||typeof isCurrent!=='function'||typeof nativeUI?.mountExistingVariantForm!=='function'||typeof nativeUI?.mountNewNativeVariantForm!=='function')throw Error('Editor delle fonti native non disponibile.');
 const actor=identity();if(!UUID.test(actor||''))throw Error('Accesso autenticato richiesto.');
 const api=createExistingVariantApi({client,identity,storage});let epoch=0,disposed=false,busy=false,view=null;
 const retained=new Map();
 const shell=node('section','',{class:'mc-card'}),title=node('h3','Varianti della missione esistente'),input=node('input','',{type:'text','aria-label':'ID della missione esistente',placeholder:'ID missione'}),tools=node('div','',{class:'mc-actions'}),status=node('p','',{class:'mc-status',role:'status','aria-live':'polite'}),operation=node('div','',{class:'mc-card'}),summary=node('div','',{class:'mc-card'}),form=node('div'),commands=node('div','',{class:'mc-actions'}),configuration=node('div','',{class:'mc-card'});
 shell.append(title,input,tools,status,operation,summary,form,commands,configuration);host.replaceChildren(shell);
 const active=()=>!disposed&&host.isConnected&&identity()===actor&&isCurrent(),current=v=>active()&&view===v&&v.epoch===epoch;
 function invalidate(){epoch++;view?.handle?.dispose();view=null;form.replaceChildren();summary.replaceChildren();commands.replaceChildren();configuration.replaceChildren();operation.replaceChildren();}
 function lock(){for(const b of shell.querySelectorAll('button[data-variant-control]'))b.disabled=busy||b.dataset.unavailable==='true';input.disabled=busy;const fields=form.querySelector('fieldset');if(fields)fields.disabled=busy||!!view?.pending||!!view?.completed;}
 function permitted(b,yes){b.dataset.unavailable=String(!yes);lock();}
 function inform(message){if(active())status.textContent=message;}
 function keep(v,result){if(current(v)){v.result=copy(result);retained.set(v.mission+':'+v.mode,{head:copy(v.bundle.head),result:copy(result)});permitted(v.seal,result?.state==='prepared_source'&&v.bundle.reader.scope.can_seal&&v.bundle.state['can_seal_'+v.mode]&&!v.pending&&!v.completed);}}
 async function action(v,run){if(!current(v)||busy)return;busy=true;lock();try{const r=await run();if(current(v))return r;}catch(e){if(current(v)){if(e?.request_key){await showJournal(v);if(e.definitiveRejected){v.completed=true;v.handle?.dispose();form.replaceChildren();if(v.seal)permitted(v.seal,false);}}inform(e?.definitiveRejected?e.message:e?.code==='40001'?'La fonte è cambiata. Proposta e richiesta conservate; rileggi esplicitamente prima di un nuovo gesto.':e?.message||'Operazione non confermata.');if(e?.code==='42501'){v.handle?.dispose();form.replaceChildren();summary.replaceChildren();commands.replaceChildren();configuration.replaceChildren();v.result=null;retained.clear();}}}finally{busy=false;if(active())lock();}}
 async function showJournal(v){const j=await api.journal(v.mission);if(!current(v))return;v.pending=j?.phase==='pending';operation.replaceChildren();if(!j)return;operation.append(node('p',j.phase==='committed'?'Ultima operazione confermata dalla ricevuta.':j.phase==='rejected_no_commit'?'Sigillo respinto senza commit: '+j.rejection.message+'. Rileggi esplicitamente la fonte prima di una nuova proposta.':'Richiesta conservata e non confermata. Un esito assente non autorizza una seconda richiesta.'));
  operation.append(button('Verifica ricevuta',()=>action(v,async()=>{const r=await api.recover(v.mission);if(current(v)){if(r.status==='committed'){v.completed=true;v.handle?.dispose();form.replaceChildren();}inform(r.status==='committed'?'Operazione confermata. Rileggi esplicitamente la fonte.':r.journal.phase==='rejected_no_commit'?'Rifiuto definitivo conservato. Rileggi esplicitamente la fonte.':'Nessuna ricevuta ancora leggibile: richiesta conservata.');await showJournal(v);}})));
  if(j.phase==='pending')operation.append(button('Ripeti la stessa richiesta',()=>action(v,async()=>{const r=await api.retry(v.mission,()=>current(v));if(current(v)){if(r.status==='committed'){v.completed=true;v.handle?.dispose();form.replaceChildren();}inform(r.status==='committed'?'Operazione confermata. Rileggi la fonte prima di proseguire.':'Richiesta ancora pendente.');await showJournal(v);}})));
  if(v.seal)permitted(v.seal,!!v.result&&v.result.state==='prepared_source'&&v.bundle?.reader.scope.can_seal&&!v.pending&&!v.completed);
 }
 async function showConfiguration(v){if(!current(v))return;configuration.replaceChildren();configuration.append(node('h4','Coppia IA / Master'),node('p','Configurare la coppia salva una capability in bozza. Non pubblica e non avvia la missione.'));
  const read=button('Leggi coppia da configurare',()=>action(v,async()=>{const pair=await api.configurationPair(v.mission);if(!current(v))return;v.pair=pair;configuration.replaceChildren();configuration.append(node('h4','Coppia IA / Master pronta alla conferma'),node('p','Entrambi i piani correnti dispongono di fingerprint autorevoli. Conferma separatamente la configurazione.'));
   const save=button('Configura coppia in bozza',()=>action(v,async()=>{const j=await api.journal(v.mission);if(j?.phase==='pending')throw Error('Prima recupera la richiesta pendente.');const r=await api.configure(v.mission,v.pair,()=>current(v));if(current(v)){v.completed=true;v.result=null;v.handle?.dispose();form.replaceChildren();v.pair=null;configuration.replaceChildren();inform('Configurazione confermata dalla propria ricevuta. Nessuna apertura effettuata.');await showJournal(v);}return r;}));configuration.append(save);lock();
  }));configuration.append(read);permitted(read,!v.pending&&!!v.bundle&&v.bundle.reader.scope.can_seal&&['absent','draft'].includes(v.bundle.state.configuration.state));
 }
 async function open(mission,mode){if(!active()||busy)return;if(!UUID.test(mission||'')||!['ai','human'].includes(mode)){inform('Scegli una missione valida e la sua modalità.');return;}
  invalidate();const v={epoch,mission,mode,handle:null,bundle:null,result:null,pending:false,pair:null};view=v;inform('Lettura della fonte e della head della variante…');busy=true;lock();
  try{
   // Recover own receipt even if a source reader is unavailable or authority was revoked.
   await showJournal(v);if(!current(v))return;
   const bundle=await api.load(mission,mode);if(!current(v))return;v.bundle=bundle;
   summary.append(node('h4',bundle.reader.source_metadata.title+' · '+(mode==='ai'?'IA':'Master')),node('p',bundle.reader.status==='ready'?'Documento completo della variante corrente.':'Questa modalità non ha ancora un piano.'),node('p',bundle.reader.scope.can_seal?'Salvataggio disponibile nel perimetro Staff.':'Salvataggio disabilitato: '+bundle.reader.scope.blocked_reason));
   if(bundle.reader.scope.academy_source)summary.append(node('p','Fonte Academy: authoring in bozza. L’accesso al runtime e la qualifica restano separati.'));
   const old=retained.get(mission+':'+mode);if(old)summary.append(node('p','Una proposta precedente è conservata in questa sessione. Non è riapplicata o ribasata automaticamente.'));
   const options=await api.options();if(!current(v))return;
   const seal=button('Sigilla questa variante',()=>action(v,async()=>{if(!v.result||v.result.state!=='prepared_source')throw Error('Prepara prima una proposta sigillabile.');const r=await api.seal(v.bundle,v.result,()=>current(v));if(current(v)){v.completed=true;v.result=null;v.handle?.dispose();form.replaceChildren();permitted(v.seal,false);inform('Variante confermata dalla ricevuta. Rileggi la fonte: nessuna selezione o pubblicazione effettuata.');await showJournal(v);}return r;}));v.seal=seal;commands.append(seal);permitted(seal,false);
   const common={head:bundle.head,...options,onResult:r=>keep(v,r),isCurrent:()=>current(v)&&!v.pending&&!v.completed};
   if(v.pending){form.append(node('p','Prima recupera la richiesta pendente della fonte.'));inform('Richiesta pendente: nessuna nuova proposta abilitata.');return;}
   if(bundle.reader.document!==null)v.handle=await nativeUI.mountExistingVariantForm(form,{...common,document:bundle.reader.document});
   else if(bundle.reader.can_author_new){const sourceMetadata=Object.fromEntries(sourceFields.map(k=>[k,bundle.reader.source_metadata[k]]));v.handle=await nativeUI.mountNewNativeVariantForm(form,{...common,sourceMetadata,mode});}
   else form.append(node('p','Creazione del primo piano non disponibile: '+bundle.reader.author_new_reason));
   if(!current(v)){v.handle?.dispose();return;}if(v.pending){v.handle?.dispose();form.replaceChildren(node('p','Prima recupera la richiesta pendente. Nessun nuovo piano viene preparato.'));permitted(seal,false);}
   await showConfiguration(v);inform('Fonte letta. Prepara esplicitamente la proposta prima del sigillo.');
  }catch(e){if(current(v)){v.handle?.dispose();form.replaceChildren();summary.replaceChildren();commands.replaceChildren();configuration.replaceChildren();inform(e?.message||'Contratto non disponibile. Nessun percorso alternativo è attivato.');}}
  finally{busy=false;if(active())lock();}
 }
 for(const [mode,label]of [['ai','Apri variante IA'],['human','Apri variante Master']])tools.append(button(label,()=>open(input.value.trim(),mode)));
 input.addEventListener('input',()=>{if(!busy){invalidate();inform('Fonte cambiata: apri esplicitamente la variante.');}});
 const subscription=client.auth.onAuthStateChange((_event,session)=>{if(session?.user?.id!==actor){invalidate();retained.clear();shell.replaceChildren(node('p','Accesso cambiato. Riapri l’editor con l’utente corrente.'));}});
 return {open:(mission,mode='ai')=>{input.value=mission;return open(mission,mode);},dispose:()=>{disposed=true;invalidate();retained.clear();subscription?.data?.subscription?.unsubscribe?.();if(shell.parentNode===host)host.replaceChildren();}};
}
