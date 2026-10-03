import {mountExistingVariantEditor} from './mf-existing-variant-editor-167b031c2670a10bc4c3cc8f454ba5a9820470c8c2084385664cd243401a7d07.mjs';
import {mountQuestStaffRuntime} from './mf-quest-runtime-ui-bf395ffe09ad828eb346de99720fc198e2ee1b1d40be0cf79226518db3fc0740.mjs';
import {createMissionFactoryApi} from './mf-editor-api-2f2db279da127b0da4aef965b7f6646054be525a095c117f62cb3af35c1a5457.mjs';
import {mountMissionFactoryEditor} from './mf-editor-ui-fe3ba13485419d7ce772f5e3e477934df67cb4e02655af953cb3d22355d4803f.mjs';
import {createQuestAwareFactoryApi} from './mf-quest-editor-api-4166af82d0fe7da693c31f18816ec8045316c0b753c73312ebd75e20069fbd89.mjs';
import {mountQuestFactoryEditor} from './mf-quest-editor-ui-0a3ae075b7dab4dbc33cb3db9281f79a69f8ca4941e0abf677673afa2d644959.mjs';
import {createMissionCreationUI} from './mf-mission-creation-ui-draft-candidate-6c93dc710283312075ccf24cfe66b1038eeb3ca8a5561339441b8da095e58a7c.mjs';
import {createMissionNativeVariantAdapter} from './mf-mission-native-adapter-b106c71bb5ffd7e2892297acc01924f43f1c9489cbf96d85ecc4588eb26dd06d.mjs';

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
  const legacyButton=node('button','Bozze precedenti'); legacyButton.type='button';
  const draftInput=node('input'); draftInput.type='text'; draftInput.placeholder='ID bozza Factory'; draftInput.setAttribute('aria-label','ID bozza Factory da riaprire');
  const openButton=node('button','Apri bozza'); openButton.type='button';
  const status=node('p'); status.setAttribute('role','status'); status.setAttribute('aria-live','polite');
  const factoryHost=node('div'), questHost=node('div'), npcHost=node('div'), legacyHost=node('div'); factoryHost.className='mission-factory-editor'; questHost.className='mission-factory-editor mission-factory-quest-editor'; questHost.hidden=true; npcHost.className='mission-factory-npc-workspace'; legacyHost.className='mission-factory-legacy'; npcHost.hidden=legacyHost.hidden=true;
  const nativeButton=node('button','Missioni esistenti');nativeButton.type='button';nativeButton.hidden=typeof mountNativeSources!=='function';
  const nativeHost=node('div');nativeHost.hidden=true;nativeHost.className='mission-factory-editor';
  const missionHost=node('div'),sourceCard=node('section');sourceCard.className='mf-card';
  sourceCard.append(node('h3','Scegli la fonte della missione'),node('p','Crea una bozza oppure apri una fonte esistente. Permessi e possibilità di modifica sono verificati dal server.'),draftButton,nativeButton);
  missionHost.append(sourceCard,factoryHost,nativeHost);
  toolbar.append(factoryButton,questButton,questRuntimeButton,npcButton,newNpcButton,legacyButton,draftInput,openButton);
  const runtimeHost=node('div');runtimeHost.hidden=true;
  shell.append(heading,intro,toolbar,status,missionHost,questHost,npcHost,legacyHost,runtimeHost); root.replaceChildren(shell);
  let npcWorkspace=null;
  const questRuntime=mountQuestStaffRuntime(runtimeHost,{client,identity,onScene:async value=>{
    if(typeof openQuestScene==='function')return openQuestScene(value);
    // Collegamento normale alla Land: la sessione/azioni sono rilette dal reader partecipante e dai pannelli nativi.
    window.location.assign('./land.html?quest_staff_episode='+encodeURIComponent(value.episode));
  }});
  function hideQuestRuntime(){missionHost.hidden=false;runtimeHost.hidden=true;questRuntimeButton.removeAttribute('aria-current');}
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
  const quest=mountQuestFactoryEditor(questHost,{api:questApi,role,identity,
    openNpcBuilder:async()=>{if(!showNpcs(true))throw Error('Ninja Book non collegato.');return {opened:true};},
    attestMedia:attestQuestMedia||questApi.attestQuestMedia,onPublished,notice});
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
  let legacyStarted=false, legacy=null;
  function showFactory() {
    leaveNative();
    hideQuestRuntime();
    const returningFromNpcs=!npcHost.hidden;
    selectedKind='mission';factoryHost.hidden=false; questHost.hidden=npcHost.hidden=legacyHost.hidden=true; factoryButton.setAttribute('aria-current','page'); questButton.removeAttribute('aria-current'); npcButton.removeAttribute('aria-current'); legacyButton.removeAttribute('aria-current'); status.textContent='';
    if (returningFromNpcs && factory.editor?.draftId) void factory.refreshNpcCatalog().then(items => { status.textContent=`Catalogo aggiornato: ${items.length} PNG certificati. Scegli actor key e fasi per collegarne uno.`; }).catch(e => { status.textContent=e?.message||'Catalogo PNG non disponibile: il collegamento resta chiuso.'; });
  }
  async function showLegacy() {
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
    dispose:()=>{disposed=true;leaveNative();nativeAuth?.data?.subscription?.unsubscribe?.();questRuntime.dispose();legacy?.dispose?.();npcWorkspace?.dispose?.();quest.dispose();factory.dispose();nativeUI.dispose();root.replaceChildren();}};
}
