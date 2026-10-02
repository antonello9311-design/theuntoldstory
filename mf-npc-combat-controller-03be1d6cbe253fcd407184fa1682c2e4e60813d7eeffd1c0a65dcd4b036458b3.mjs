// Controller candidato del medesimo Ninja Book. Non abilita il cutover Admin.
import {createNpcCombatAdapter} from './mf-npc-combat-adapter-ad070bc367566feddc9d30c2950f6bbfb9e1a0b3c66b0ca9eee8eb85b3926483.mjs';
import {mountNpcCombatPanel} from './mf-npc-combat-panel-c8cc1bb8f946a26a781136809cb0a66a08c71b677e47d104e89499807d66872a.mjs';

const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const SHA=/^[0-9a-f]{64}$/i;
const el=(tag,text='') => {const n=document.createElement(tag);n.textContent=text;return n;};
const same=(a,b)=>a?.template_id===b?.template_id&&a?.narrative_version_id===b?.narrative_version_id;
const identityKey=x=>x ? `${x.template_id}:${x.narrative_version_id}` : '';
const fail=message=>{throw Error(message);};

export function mountNpcCombatController({host,reviewHost,client,role,getIdentity,
  syncNarrativeBinding,readNarrativeBinding,notice=()=>{}}={}) {
  if (!(host instanceof Element) || !(reviewHost instanceof Element) ||
      typeof getIdentity!=='function' || typeof syncNarrativeBinding!=='function' ||
      typeof readNarrativeBinding!=='function') throw Error('Controller PNG non configurato.');
  const status=el('p');status.className='nbe-status';status.setAttribute('role','status');
  const form=el('div'),summary=el('div');
  const saveButton=el('button','Salva scheda PNG');
  const syncButton=el('button','Riprova collegamento Ninja Book');syncButton.id='nbe-combat-sync';
  const reloadButton=el('button','Rileggi stato PNG');
  for(const b of [saveButton,syncButton,reloadButton])b.type='button';
  host.append(form,saveButton,syncButton,reloadButton,status);reviewHost.append(summary);
  let adapter=null,panel=null,identity=null,dirty=false,syncNeeded=true,busy=false,epoch=0;
  let lastReceipt=null;
  const say=(message,error=false)=>{status.textContent=message;notice(message,error);};
  const current=()=>{
    const x=getIdentity();
    return x&&UUID.test(x.template_id||'')&&UUID.test(x.narrative_version_id||'') ?
      {template_id:x.template_id,narrative_version_id:x.narrative_version_id}:null;
  };
  const state=()=>adapter?.snapshot()||null;
  const renderActions=()=>{
    const s=state(),hasIdentity=Boolean(current()),ready=hasIdentity&&Boolean(panel)&&!busy;
    saveButton.disabled=!ready||Boolean(lastReceipt)||Boolean(adapter?.pending())||!['absent','draft'].includes(s?.review_state);
    syncButton.hidden=!syncNeeded||!lastReceipt;
    syncButton.disabled=!ready||!lastReceipt||Boolean(adapter?.pending());
    reloadButton.disabled=!hasIdentity||busy;
  };
  const isSynced=async s=>{
    const binding=await readNarrativeBinding();
    return same(binding,identity)&&binding.mechanical_template_id===s.mechanical_template_id&&
      SHA.test(binding.content_sha256||'')&&binding.lifecycle_state!=='inactive'&&
      (s.review_state==='review'?['review','approved'].includes(binding.review_state):true)&&
      (binding.review_state==='approved'?binding.current_version_id===identity.narrative_version_id:true)&&
      (s.review_state==='approved'?binding.review_state==='approved'&&
        binding.current_version_id===identity.narrative_version_id:true);
  };
  const assertJoint=async (before,result,kind)=>{
    const after=await readNarrativeBinding(),target=kind==='submit'?'review':'approved';
    const accepted=kind==='submit'&&result.receipt.replayed?
      ['review','approved']:[target];
    if((result.review_state!==target&&!(kind==='submit'&&result.receipt.replayed&&result.review_state==='approved'))||
       !same(after,identity)||after.mechanical_template_id!==result.mechanical_template_id||
       after.content_sha256!==before.content_sha256||!SHA.test(after.content_sha256||'')||
       after.lifecycle_state==='inactive'||!accepted.includes(after.review_state)||
       after.review_state==='approved'&&after.current_version_id!==identity.narrative_version_id)
      fail('Transizione PNG non verificata nel Ninja Book. Rileggi lo stato prima di proseguire.');
  };
  const newAdapter=()=>createNpcCombatAdapter({client,getIdentity:current,assertNarrativeSynced:isSynced});
  async function refresh(){
    const ticket=++epoch,next=current();
    if (!next) {identity=null;adapter=null;panel?.dispose();panel=null;form.replaceChildren();summary.replaceChildren();
      dirty=false;syncNeeded=true;lastReceipt=null;say('Crea o seleziona prima il template PNG.');renderActions();return false;}
    if (!same(identity,next)) {identity=next;adapter=newAdapter();panel?.dispose();panel=null;dirty=false;syncNeeded=true;lastReceipt=null;}
    busy=true;renderActions();
    try {
      const loaded=await adapter.load();
      if (ticket!==epoch||!same(next,current())) return;
      panel?.dispose();form.replaceChildren();summary.replaceChildren();
      panel=mountNpcCombatPanel(form,{choices:loaded.choices,initial:loaded.initial,reviewHost:summary,
        onChange:['absent','draft'].includes(loaded.initial.review_state)?
          ()=>{dirty=true;syncNeeded=true;lastReceipt=null;renderActions();}:null});
      syncNeeded=loaded.initial.review_state==='absent'||!await isSynced(loaded.initial);
      if (ticket!==epoch||!same(next,current())) return;
      dirty=false;lastReceipt=syncNeeded&&loaded.initial.review_state==='draft'&&loaded.initial.receipt||null;
      say(loaded.pending?'Richiesta precedente da riconciliare con la stessa chiave.':
        syncNeeded?'Salva la scheda e collega il riferimento alla bozza narrativa prima della Review.':
        'Scheda PNG e bozza narrativa allineate.');
      return true;
    } catch(error) {if(ticket===epoch){panel?.dispose();panel=null;form.replaceChildren();summary.replaceChildren();
      syncNeeded=true;say(error?.message||'Gateway PNG non disponibile.',true);}return false;}
    finally {if(ticket===epoch){busy=false;renderActions();}}
  }
  async function run(action){
    if(busy)return null;busy=true;renderActions();
    try {return await action();}
    catch(error){say(error?.message||'Operazione PNG non completata.',true);return null;}
    finally{busy=false;renderActions();}
  }
  async function syncNow(){
    const s=state(),receipt=lastReceipt;
    if(!s||!receipt||!same(identity,current())||!same(receipt,identity)||
       receipt.mechanical_template_id!==s.mechanical_template_id)fail('Ricevuta PNG da riconciliare.');
    const binding=await syncNarrativeBinding({identity:{...identity},mechanical_template_id:s.mechanical_template_id,
      receipt:{...receipt},button:syncButton});
    if(!same(binding,identity)||binding.mechanical_template_id!==s.mechanical_template_id||
       !SHA.test(binding.content_sha256||''))fail('Il secondo salvataggio Ninja Book non è attestato.');
    syncNeeded=false;lastReceipt=null;say('Scheda PNG salvata e collegata alla stessa versione narrativa.');
  }
  saveButton.addEventListener('click',()=>void run(async()=>{
    const payload=panel?.snapshot();if(!payload)fail('Completa i valori della scheda PNG prima di salvare.');
    const result=await adapter.save(payload);lastReceipt=result.receipt;dirty=false;syncNeeded=true;
    await syncNow();
  }));
  syncButton.addEventListener('click',()=>void run(syncNow));
  reloadButton.addEventListener('click',()=>void refresh());
  const submitReview=()=>run(async()=>{
    if(dirty||syncNeeded)fail('Salva e collega la scheda prima della Review.');
    const before=await readNarrativeBinding();
    if(!same(before,identity)||!SHA.test(before.content_sha256||''))fail('Versione narrativa da rileggere.');
    const result=await adapter.submitReview();await assertJoint(before,result,'submit');
    if(!await refresh())fail('Review NBE verificata; rilettura gateway non disponibile. Rileggi lo stato PNG.');
    say(result.receipt.replayed&&result.review_state==='review'?
      'Review PNG già registrata e verificata.':'PNG narrativo e meccanico in review, stato verificato.');return result;
  });
  const approve=()=>run(async()=>{
    if(role!=='admin'||dirty||syncNeeded)fail('Approvazione PNG non disponibile.');
    const before=await readNarrativeBinding();
    if(!same(before,identity)||!SHA.test(before.content_sha256||''))fail('Versione narrativa da rileggere.');
    const result=await adapter.approve();await assertJoint(before,result,'approve');
    if(!await refresh())fail('Approvazione NBE verificata; rilettura gateway non disponibile. Rileggi lo stato PNG.');
    say(result.receipt.replayed?'Approvazione PNG già registrata e verificata.':
      'PNG narrativo e meccanico approvato, stato verificato.');return result;
  });
  const nativeGate=kind=>{
    const s=state(),pending=adapter?.pending();
    if(!current()||!s||!panel||busy||pending&&pending.operation!==kind)
      return {ok:false,reason:'Carica o riconcilia la scheda PNG prima della Review.'};
    if(!panel.snapshot()||dirty||syncNeeded)return {ok:false,reason:'Salva e collega la scheda PNG alla versione narrativa.'};
    if(kind==='submit'&&s.review_state!=='draft')
      return {ok:false,reason:'La scheda PNG deve essere in bozza.'};
    if(kind==='approve'&&s.review_state!=='review')
      return {ok:false,reason:'Invia prima la scheda PNG in review.'};
    if(kind==='approve'&&role!=='admin')return {ok:false,reason:'Solo Admin può approvare il PNG.'};
    return {ok:true};
  };
  renderActions();
  return {refresh,nativeGate,submitReview,approve,reset:()=>{++epoch;identity=null;adapter=null;panel?.dispose();panel=null;lastReceipt=null;dirty=false;syncNeeded=true;form.replaceChildren();summary.replaceChildren();say('Crea o seleziona prima il template PNG.');renderActions();},
    dispose:()=>{++epoch;panel?.dispose();host.replaceChildren();reviewHost.replaceChildren();}};
}
