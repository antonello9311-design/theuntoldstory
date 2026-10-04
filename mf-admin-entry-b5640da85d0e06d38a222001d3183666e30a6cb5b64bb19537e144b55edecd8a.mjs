import {createQuestRuntimeApi} from './mf-quest-runtime-api-805a43a0eace173a378ca1973e2f174a425748c1e1d74f3f60a9e472f9a9c4af.mjs';
import {mountHumanQuestRuntime} from './mf-human-quest-runtime-ui-dedb9fbea29889e2019e4c002f699afd36ab5df23ac263c52e113e1b6b7f341c.mjs';
import {mountExistingVariantEditor} from './mf-existing-variant-editor-167b031c2670a10bc4c3cc8f454ba5a9820470c8c2084385664cd243401a7d07.mjs';
import {mountQuestStaffRuntime} from './mf-quest-runtime-ui-8760d80ef1a877bb71bdbb6710936e542d6bb4a52ed76c2559066df0f708a3c2.mjs';
import {createMissionFactoryApi} from './mf-editor-api-16d04aefd7c40f7b4231f90907782ea47ac79d7a18eb4064fcad918dfd44b3c0.mjs';
import {mountMissionFactoryEditor} from './mf-editor-ui-8a2adf7de2a09ed479fbec8ecc9da5fed41f074e1755d78b4b7807908206f5cd.mjs';
import {createQuestAwareFactoryApi} from './mf-quest-editor-api-f458ac4f549abbf9da72afc4449bae5fb9172c57939677ba65a575d519ebf908.mjs';
import {mountQuestFactoryEditor} from './mf-quest-editor-ui-259e36bb230b1ef460d588e31b90f9705b4c921f5101593d837c68a05e146885.mjs';
import {createMissionCreationUI} from './mf-mission-creation-ui-draft-candidate-9a9cb6471611b6f57796d239075ca69f6aa550cb1d89940c7193f0778f7ea50a.mjs';
import {createMissionNativeVariantAdapter} from './mf-mission-native-adapter-3a016e919eebead1fd6cacfd1dccc70e91208ababf6c0f71d52428c03058ec5c.mjs';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const node = (tag,text='') => { const el=document.createElement(tag); if(text) el.textContent=text; return el; };

// Un solo ingresso editoriale. I consumer storici sono montati soltanto su richiesta
// nel sottopannello di recupero e continuano a leggere le proprie bozze.
export function mountUnifiedMissionAdmin(root, {
  client, role, identity, mountNpcWorkspace, editVariant, attestMedia, attestQuestMedia, chooseArena,
  mountLegacyDrafts, mountRapidExisting, mountNativeSources=mountExistingVariantEditor, chooseNativeMap, disposeNativeMap, onPublished, openQuestScene, notice = () => {}
} = {}) {
  if (!(root instanceof Element) || !['admin','master'].includes(role) || typeof identity !== 'function' || !identity())
    throw Error('Editor missioni riservato ad Admin e Master autenticati.');
  let nativeSources=null,nativeEpoch=0,disposed=false;
  const entryActor=identity(),entryCurrent=()=>!disposed&&root.isConnected&&identity()===entryActor;
  const api=createMissionFactoryApi(client,{identity,isCurrent:entryCurrent});
  const nativeUI=createMissionCreationUI({client,identity,isStaff:()=>['admin','master'].includes(role) && !!identity(),
    mapPicker:async(current,title,context)=>{if(!['existing_native','new_native'].includes(context?.scope)||typeof chooseNativeMap!=='function')throw Error('Modifica la mappa e la zona nella sezione Editoriale.');return chooseNativeMap({current,title,roster:{pg_count:context.pg_count,png_count:context.png_count}});},notice});
  const variantAdapter=editVariant || createMissionNativeVariantAdapter({api,nativeUI});
  const questApi=createQuestAwareFactoryApi(client,{identity,isCurrent:entryCurrent});
  const nativePrincipal=identity();
  function leaveNative(){api.invalidateEpoch();questApi.invalidateEpoch();const owned=!!nativeSources||!nativeHost.hidden;nativeEpoch++;nativeSources?.dispose?.();nativeSources=null;if(owned)disposeNativeMap?.();nativeHost.hidden=true;nativeButton.removeAttribute('aria-current');}
  const shell=node('section'); shell.className='mission-factory-admin-entry';
  const heading=node('h2','Editor missioni');
  const intro=node('p','Un solo percorso editoriale: componi Missioni e Quest, oppure crea PNG nell’archivio senza assegnarli a una storia o a una scena. La disponibilità delle Quest dipende dalla policy server: una policy chiusa mantiene il percorso bloccato.');
  const toolbar=node('div'); toolbar.className='mission-factory-entry-toolbar';
  const factoryButton=node('button','Missione'); factoryButton.type='button';
  const draftButton=node('button','Nuova bozza / bozze Factory');draftButton.type='button';
  const questButton=node('button','Quest IA'); questButton.type='button';
  const questRuntimeButton=node('button','Puntate Quest');questRuntimeButton.type='button';
  const npcButton=node('button','Archivio PNG'); npcButton.type='button';
  const newNpcButton=node('button','Crea PNG libero'); newNpcButton.type='button';
  const rapidButton=node('button','Genera da trama');rapidButton.type='button';rapidButton.hidden=role!=='admin'||typeof mountRapidExisting!=='function';
  const legacyButton=node('button','Bozze precedenti'); legacyButton.type='button';
  const draftInput=node('input'); draftInput.type='text'; draftInput.placeholder='ID bozza Factory'; draftInput.setAttribute('aria-label','ID bozza Factory da riaprire');
  const openButton=node('button','Apri bozza'); openButton.type='button';
  const status=node('p'); status.setAttribute('role','status'); status.setAttribute('aria-live','polite');
  const factoryHost=node('div'), questHost=node('div'), npcHost=node('div'), legacyHost=node('div'); factoryHost.className='mission-factory-editor'; questHost.className='mission-factory-editor mission-factory-quest-editor'; questHost.hidden=true; npcHost.className='mission-factory-npc-workspace'; legacyHost.className='mission-factory-legacy'; npcHost.hidden=legacyHost.hidden=true;
  const nativeButton=node('button','Missioni esistenti');nativeButton.type='button';nativeButton.hidden=typeof mountNativeSources!=='function';
  const nativeHost=node('div');nativeHost.hidden=true;nativeHost.className='mission-factory-editor';
  const missionHost=node('div'),sourceCard=node('section');sourceCard.className='mf-card';
  sourceCard.append(node('h3','Scegli la fonte della missione'),node('p','Crea una bozza oppure apri una fonte esistente. Permessi e possibilità di modifica sono verificati dal server.'),draftButton,nativeButton,rapidButton);
  missionHost.append(sourceCard,factoryHost,nativeHost);
  toolbar.append(factoryButton,questButton,questRuntimeButton,npcButton,newNpcButton,legacyButton,draftInput,openButton);
  const runtimeHost=node('div');runtimeHost.hidden=true;
  shell.append(heading,intro,toolbar,status,missionHost,questHost,npcHost,legacyHost,runtimeHost); root.replaceChildren(shell);
  const humanRuntimeHost=node('div');humanRuntimeHost.hidden=true;shell.append(humanRuntimeHost);
  const humanRuntimeApi=createQuestRuntimeApi(client,{identity,isCurrent:()=>entryCurrent()&&!humanRuntimeHost.hidden});
  const humanRuntime=mountHumanQuestRuntime(humanRuntimeHost,{client,identity,api:humanRuntimeApi,isCurrent:()=>entryCurrent()&&!humanRuntimeHost.hidden,
    onScene:async v=>{if(!entryCurrent())throw Error('Accesso cambiato.');window.location.assign('./land.html?quest_human_episode='+encodeURIComponent(v.episode));},onNext:async v=>{if(!entryCurrent())throw Error('Accesso cambiato.');const e=await humanRuntimeApi.episode(v.episode);if(!entryCurrent()||e.source_sha256!==v.source_sha256)throw Error('Fonte della puntata successiva cambiata.');notice('Puntata successiva identificata. Seleziona la sua versione Master immutabile prima della preparazione; nessun avvio automatico.');}});
  async function openHumanRuntime(v){if(!entryCurrent())throw Error('Accesso cambiato.');leaveNative();hideQuestRuntime();missionHost.hidden=true;factoryHost.hidden=questHost.hidden=npcHost.hidden=legacyHost.hidden=runtimeHost.hidden=true;humanRuntimeHost.hidden=false;await humanRuntime.open(v);}
  let npcWorkspace=null;
  const questRuntime=mountQuestStaffRuntime(runtimeHost,{client,identity,onScene:async value=>{
    if(typeof openQuestScene==='function')return openQuestScene(value);
    // Collegamento normale alla Land: la sessione/azioni sono rilette dal reader partecipante e dai pannelli nativi.
    window.location.assign('./land.html?quest_staff_episode='+encodeURIComponent(value.episode));
  }});
  function hideQuestRuntime(){humanRuntime.suspend();humanRuntimeHost.hidden=true;missionHost.hidden=false;runtimeHost.hidden=true;questRuntimeButton.removeAttribute('aria-current');}
  questRuntimeButton.addEventListener('click',()=>{leaveNative();missionHost.hidden=true;factoryHost.hidden=questHost.hidden=npcHost.hidden=legacyHost.hidden=true;runtimeHost.hidden=false;
    for(const b of [factoryButton,questButton,npcButton,legacyButton])b.removeAttribute('aria-current');questRuntimeButton.setAttribute('aria-current','page');status.textContent='Avvio e seguito espliciti sulla puntata pubblicata Staff.';});
  function showNpcs(startNew=false) {
    leaveNative();
    hideQuestRuntime();missionHost.hidden=true;
    if (typeof mountNpcWorkspace!=='function') { status.textContent='Ninja Book esistente non ancora collegato al pannello unico.'; return false; }
    if (!npcWorkspace) npcWorkspace=mountNpcWorkspace({host:npcHost,role});
    if (!npcWorkspace) { status.textContent='Ninja Book non disponibile.'; return false; }
    factoryHost.hidden=questHost.hidden=legacyHost.hidden=true; npcHost.hidden=false;
    npcButton.setAttribute('aria-current','page'); factoryButton.removeAttribute('aria-current'); questButton.removeAttribute('aria-current'); legacyButton.removeAttribute('aria-current');
    if (startNew) npcWorkspace.startNew?.(); else npcWorkspace.showCatalog?.();
    status.textContent=startNew?'Nuova bozza PNG autonoma: nessuna presenza, scena o storia viene creata.':'Archivio PNG canonico: scegli una versione o crea un personaggio autonomo.';
    return true;
  }
  const factory=mountMissionFactoryEditor(factoryHost,{api,identity,openNpcBuilder:async () => {
    if (!showNpcs(true)) throw Error('Ninja Book non collegato.');
    return {opened:true,certified:false};
  },editVariant:variantAdapter,attestMedia,chooseArena,onPublished,notice});
  const quest=mountQuestFactoryEditor(questHost,{api:questApi,client,role,identity,
    openNpcBuilder:async()=>{if(!showNpcs(true))throw Error('Ninja Book non collegato.');return {opened:true};},
    attestMedia:attestQuestMedia||questApi.attestQuestMedia,onPublished,onHumanRuntime:openHumanRuntime,notice});
  let selectedKind='mission';
  function showQuest(){
    leaveNative();
    hideQuestRuntime();missionHost.hidden=true;
    const returningFromNpcs=!npcHost.hidden;
    selectedKind='quest_ai';factoryHost.hidden=npcHost.hidden=legacyHost.hidden=true;questHost.hidden=false;
    questButton.setAttribute('aria-current','page');factoryButton.removeAttribute('aria-current');
    npcButton.removeAttribute('aria-current');legacyButton.removeAttribute('aria-current');status.textContent='';
    if(returningFromNpcs&&quest.editor.draftId)void quest.refreshNpcCatalog().then(()=>{
      status.textContent='Catalogo PNG Quest aggiornato: scegli la versione certificata e le fasi.';
    }).catch(e=>{status.textContent=e?.message||'Catalogo PNG Quest non disponibile.';});
  }
  let rapidMounted=null,rapidEpoch=0;
  async function showRapidGenerator(){
    leaveNative();hideQuestRuntime();if(!entryCurrent()||role!=='admin'||typeof mountRapidExisting!=='function')return;
    missionHost.hidden=true;factoryHost.hidden=questHost.hidden=npcHost.hidden=true;legacyHost.hidden=false;
    const e=++rapidEpoch;rapidMounted?.dispose?.();rapidMounted=null;legacy?.dispose?.();legacy=null;legacyStarted=false;
    const target=node('div');legacyHost.replaceChildren(target);status.textContent='Genera la bozza, verifica l’anteprima e portala nell’Editor.';
    try{const mounted=await mountRapidExisting({host:target,snapshot:null,existingOnly:false});
      if(!entryCurrent()||e!==rapidEpoch){mounted?.dispose?.();return;}rapidMounted=mounted;
    }catch(error){if(entryCurrent()&&e===rapidEpoch)status.textContent=error?.message||'Generatore non disponibile.';}
  }
  const importedDraft=event=>{const v=event.detail;
    event.completion=(async()=>{
      if(!entryCurrent()||v?.schema_version!=='rapid-unified-import-ui/1'||!UUID.test(v.current_draft?.draft_id||'')||v.receipt?.draft_id!==v.current_draft.draft_id||v.receipt?.publication_ready!==false||!Number.isSafeInteger(v.current_draft.control_version))throw Error('Ricevuta import non collegata alla vista corrente.');
      showQuest();try{const result=await quest.openConfirmed(v.current_draft.draft_id,v.current_draft.control_version);
        if(result.draft_id!==v.current_draft.draft_id||result.control_version!==v.current_draft.control_version)throw Error('Apertura Native non confermata.');
        return result;
      }catch(e){if(entryCurrent())status.textContent=e?.message||'Import conservato: apri la bozza dal suo ID.';throw e;}
    })();
  };
  legacyHost.addEventListener('mission-rapid-unified-draft',importedDraft);
  rapidButton.addEventListener('click',()=>{void showRapidGenerator();});
  let legacyStarted=false, legacy=null;
  function showFactory() {
    leaveNative();
    hideQuestRuntime();
    const returningFromNpcs=!npcHost.hidden;
    selectedKind='mission';factoryHost.hidden=false; questHost.hidden=npcHost.hidden=legacyHost.hidden=true; factoryButton.setAttribute('aria-current','page'); questButton.removeAttribute('aria-current'); npcButton.removeAttribute('aria-current'); legacyButton.removeAttribute('aria-current'); status.textContent='';
    if (returningFromNpcs && factory.editor?.draftId) void factory.refreshNpcCatalog().then(items => { status.textContent=`Catalogo aggiornato: ${items.length} PNG certificati. Scegli actor key e fasi per collegarne uno.`; }).catch(e => { status.textContent=e?.message||'Catalogo PNG non disponibile: il collegamento resta chiuso.'; });
  }
  async function showLegacy() {
    rapidEpoch++;rapidMounted?.dispose?.();rapidMounted=null;
    leaveNative();
    hideQuestRuntime();missionHost.hidden=true;
    if (typeof mountLegacyDrafts!=='function') { status.textContent='Il recupero delle bozze precedenti non è ancora collegato.'; return; }
    if (!legacyStarted) {
      legacyStarted=true;
      try { legacy=await mountLegacyDrafts({host:legacyHost,client,role,existingOnly:true,mountRapidExisting}); }
      catch(e) { legacyStarted=false; status.textContent=e?.message||'Bozze precedenti non disponibili.'; return; }
    }
    factoryHost.hidden=questHost.hidden=npcHost.hidden=true; legacyHost.hidden=false; legacyButton.setAttribute('aria-current','page'); factoryButton.removeAttribute('aria-current'); questButton.removeAttribute('aria-current'); npcButton.removeAttribute('aria-current'); status.textContent='Le bozze precedenti conservano ID, contenuti e percorso di recupero originali.';
  }
  function showNativeSources(){
    leaveNative();hideQuestRuntime();
    if(disposed||typeof mountNativeSources!=='function'||identity()!==nativePrincipal)return;
    factoryHost.hidden=questHost.hidden=npcHost.hidden=legacyHost.hidden=true;nativeHost.hidden=false;
    for(const b of [factoryButton,questButton,npcButton,legacyButton])b.removeAttribute('aria-current');nativeButton.setAttribute('aria-current','page');
    const stamp=nativeEpoch,isCurrent=()=>!disposed&&stamp===nativeEpoch&&root.isConnected&&!nativeHost.hidden&&identity()===nativePrincipal;
    try{const catalogHost=node('section'),editorHost=node('div');nativeHost.replaceChildren(catalogHost,editorHost);
      const mounted=mountNativeSources({host:editorHost,client,identity,nativeUI,isCurrent});
      if(!mounted||typeof mounted.dispose!=='function'||typeof mounted.then==='function')throw Error('Consumer delle fonti native non disponibile.');
      if(!isCurrent()){mounted.dispose();return;}nativeSources=mounted;void sourceCatalog(catalogHost,mounted,isCurrent);status.textContent='Le possibilità di modifica sono lette dalla fonte autorevole.';
    }catch(e){leaveNative();nativeHost.replaceChildren();status.textContent=e?.message||'Fonti native non disponibili.';}
  }
  async function sourceCatalog(host,mounted,isCurrent){
    let page=0,items=[];const msg=node('p'),list=node('div'),back=node('button','Precedenti'),next=node('button','Successive');back.type=next.type='button';host.append(node('h4','Fonti dal catalogo missioni'),node('p','La presenza in elenco non autorizza la modifica: aprendo una fonte il reader verifica owner, stato e head.'),msg,list,back,next);
    function render(){if(!isCurrent())return;list.replaceChildren();for(const item of items.slice(page*8,page*8+8)){const row=node('button',item.title+' · '+item.grado+' · '+item.status);row.type='button';row.addEventListener('click',()=>{if(isCurrent())void mounted.open(item.id,'ai');});list.append(row);}back.disabled=page===0;next.disabled=(page+1)*8>=items.length;msg.textContent=items.length?'Pagina '+(page+1)+' di '+Math.ceil(items.length/8):'Nessuna fonte leggibile nel catalogo. Puoi verificare un ID tramite il reader.';}
    back.onclick=()=>{if(page>0){page--;render();}};next.onclick=()=>{if((page+1)*8<items.length){page++;render();}};
    try{const auth=await client.auth.getSession();if(!isCurrent()||auth.error||auth.data?.session?.user?.id!==nativePrincipal)return;const result=await client.from('missions').select('id,title,grado,status').order('created_at',{ascending:false});const after=await client.auth.getSession();if(!isCurrent()||after.error||after.data?.session?.user?.id!==nativePrincipal)return;if(result.error)throw result.error;if(!Array.isArray(result.data)||result.data.some(x=>!UUID.test(x.id||'')||['title','grado','status'].some(k=>typeof x[k]!=='string')))throw Error('Catalogo fonti non compatibile.');items=result.data;render();}catch(e){if(isCurrent()){back.disabled=next.disabled=true;msg.textContent=e?.message||'Catalogo non disponibile: verifica una fonte tramite ID.';}}
  }
  draftButton.addEventListener('click',showFactory);
  nativeButton.addEventListener('click',showNativeSources);
  const nativeAuth=client.auth.onAuthStateChange((_event,session)=>{if(session?.user?.id!==nativePrincipal){leaveNative();nativeHost.replaceChildren();}});
  factoryButton.addEventListener('click',showFactory);
  questButton.addEventListener('click',showQuest);
  npcButton.addEventListener('click',()=>showNpcs(false));
  newNpcButton.addEventListener('click',()=>showNpcs(true));
  legacyButton.addEventListener('click',()=>{void showLegacy();});
  openButton.addEventListener('click',()=>{const id=draftInput.value.trim(); if(!UUID.test(id)){status.textContent='Inserisci un ID bozza valido.';return;} const target=selectedKind==='quest_ai'?quest:factory;
    if(selectedKind==='quest_ai')showQuest();else showFactory(); void Promise.resolve(target.open(id)).catch(e=>{status.textContent=e?.message||'Bozza non disponibile.';});});
  showFactory();
  return {editor:factory.editor,questEditor:quest.editor,questRuntime,open:(id,kind='mission')=>{
    if(kind==='quest_ai'){showQuest();return quest.open(id);}showFactory();return factory.open(id);},
    dispose:()=>{disposed=true;rapidEpoch++;rapidMounted?.dispose?.();legacyHost.removeEventListener('mission-rapid-unified-draft',importedDraft);leaveNative();nativeAuth?.data?.subscription?.unsubscribe?.();questRuntime.dispose();humanRuntime.dispose();legacy?.dispose?.();npcWorkspace?.dispose?.();quest.dispose();factory.dispose();nativeUI.dispose();root.replaceChildren();}};
}
