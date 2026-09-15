// Candidata isolata: nessun bootstrap sul sito. Il server possiede geometria e meccaniche.
export const VERSION = 'map-object-binding-ui/asset-v3';
export const VISUAL_TYPES = Object.freeze(['sasso', 'tronco', 'cassa', 'macerie', 'cespuglio']);
export const ATLAS_SHA256 = '22fa6f419cacf725c5a3e29efc68a49566d9d9d15942b61a51e322edbc42bb63';
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const KEY = /^[a-z0-9][a-z0-9_-]{0,63}$/;
const SCOPES = new Set(['ordinary_location', 'room', 'mission_draft']);
const DISPLAY = Object.freeze({sasso:'Sasso', tronco:'Tronco', cassa:'Cassa', macerie:'Macerie', cespuglio:'Cespuglio'});
const ATLAS = './map-visual-type-atlas.v1.png'; // File locale versionato nel pacchetto; mai URL dal catalogo.

export function bindingPayload({scope_kind, scope_id, step_key='', parent, items, roster, expected_revision}) {
  if (!SCOPES.has(scope_kind) || !(scope_id===null && scope_kind==='mission_draft') && (typeof scope_id !== 'string' || !UUID.test(scope_id))) throw Error('Associazione non valida.');
  if (scope_kind==='mission_draft' ? !KEY.test(step_key) : step_key!=='') throw Error('Fase dell’associazione non valida.');
  if (!parent || !/^mission_map_[a-z0-9_]{1,48}$/.test(parent.template_key) || !Number.isSafeInteger(parent.template_version) || parent.template_version < 1 || !KEY.test(parent.zone_key)) throw Error('Mappa parent non valida.');
  if (!Array.isArray(items) || items.length > 32) throw Error('Massimo 32 elementi per associazione.');
  if (!Number.isSafeInteger(roster?.pg_count) || roster.pg_count < 0 || roster.pg_count > 4 || !Number.isSafeInteger(roster?.png_count) || roster.png_count < 0 || roster.png_count > 12) throw Error('Roster non valido.');
  if (!Number.isSafeInteger(expected_revision) || expected_revision < 0) throw Error('Revisione non valida.');
  const keys = new Set();
  const clean = items.map(item => {
    if (typeof item.instance_key !== 'string' || !KEY.test(item.instance_key) || keys.has(item.instance_key)) throw Error('Chiave istanza non valida o duplicata.');
    keys.add(item.instance_key);
    if (!VISUAL_TYPES.includes(item.visual_type) || !Number.isSafeInteger(item.visual_type_version) || item.visual_type_version < 1) throw Error('Tipo visivo non valido.');
    if (String(item.x_m).trim() === '' || String(item.y_m).trim() === '') throw Error('Inserisci entrambe le coordinate.');
    const x_m = Number(item.x_m), y_m = Number(item.y_m);
    if (!Number.isSafeInteger(x_m) || !Number.isSafeInteger(y_m)) throw Error('Le coordinate degli elementi devono essere numeri interi.');
    return {instance_key:item.instance_key, visual_type:item.visual_type, visual_type_version:item.visual_type_version, x_m, y_m};
  });
  return {p_scope_kind:scope_kind, p_scope_id:scope_id, p_step_key:step_key, p_parent:{template_key:parent.template_key, template_version:parent.template_version, zone_key:parent.zone_key}, p_items:clean, p_pg_count:roster.pg_count, p_png_count:roster.png_count, p_expected_revision:expected_revision};
}

export function createMapBindingEditor({client, identity, isStaff, document:doc=globalThis.document, crypto:random=globalThis.crypto, onSaved=()=>{}, onActivated=()=>{}}) {
  if (!client?.rpc || !client?.auth?.getSession || !doc?.createElement || !random?.randomUUID) throw Error('Editor non configurato.');
  let epoch=0, root=null, principal=null, state=null;
  const el=(tag, text, cls) => {const node=doc.createElement(tag);if(text!==undefined && text!==null)node.textContent=text;if(cls)node.className=cls;return node;};
  const button=(label, action) => {const b=el('button',label);b.type='button';b.addEventListener('click',action);return b;};
  const valid=stamp => epoch===stamp && principal && identity?.()===principal && isStaff?.()===true && root?.isConnected;
  async function rpc(name,args,stamp) {
    if(!valid(stamp))throw Error('Accesso cambiato: riapri l’editor.');
    const auth=await client.auth.getSession();
    if(auth?.error || auth?.data?.session?.user?.id!==principal || !valid(stamp))throw Error('Accesso cambiato: riapri l’editor.');
    const result=await client.rpc(name,args);
    if(!valid(stamp))throw Error('Accesso cambiato: riapri l’editor.');
    if(result?.error)throw result.error;
    return result?.data;
  }
  const latestType=(type) => state.types.filter(t=>t.visual_type===type && t.status==='ready').sort((a,b)=>b.visual_type_version-a.visual_type_version)[0] || null;
  const note=(value) => {state.status.textContent=value;};
  function counts() {
    const count=Object.fromEntries(VISUAL_TYPES.map(t=>[t,0]));
    for(const item of state.items)count[item.visual_type]++;
    state.counts.textContent=VISUAL_TYPES.map(t=>`${DISPLAY[t]} ${count[t]}`).join(' · ') + ` · Totale ${state.items.length}/32`;
  }
  function invalidate() {state.editSeq++;state.preview=null;state.save.disabled=true;state.activate.disabled=true;state.connect.disabled=!state.ready||state.connected;state.previewHost.replaceChildren();note('Modifiche da verificare con il server.');}
  function icon(type){const i=el('span',null,'map-binding-icon');i.setAttribute('aria-hidden','true');i.style.display='inline-block';i.style.width='42px';i.style.height='42px';i.style.backgroundImage=`url("${ATLAS}")`;i.style.backgroundSize='500% 100%';i.style.backgroundPosition=`${VISUAL_TYPES.indexOf(type)*25}% 50%`;return i;}
  function rows() {
    state.rows.replaceChildren();
    for(const item of state.items){
      const line=el('div',null,'map-binding-row');line.append(icon(item.visual_type),el('span',`${DISPLAY[item.visual_type]} v${item.visual_type_version}`));
      for(const [axis,label] of [['x_m','X (m)'],['y_m','Y (m)']]){const field=el('label',label),input=el('input');input.type='number';input.step='1';input.inputMode='numeric';input.value=String(item[axis]);input.setAttribute('aria-label',`${label} · ${DISPLAY[item.visual_type]}`);input.addEventListener('input',()=>{if(state.busy)return;item[axis]=input.value;invalidate();});field.append(input);line.append(field);}
      line.append(button('Rimuovi',()=>{if(state.busy)return;state.items=state.items.filter(x=>x!==item);invalidate();rows();}));state.rows.append(line);
    }
    counts();
  }
  function renderPreview(data) {
    state.previewHost.replaceChildren();
    const errors=Array.isArray(data.errors)?data.errors:[];
    for(const error of errors){const message=typeof error==='string'?error:typeof error?.message==='string'?error.message:String(error?.code||'Geometria non valida.');state.previewHost.append(el('p',message,'map-binding-error'));}
    if(Number.isSafeInteger(data.capacity_16))state.previewHost.append(el('p',`Capienza server: ${data.capacity_16} corpi.`));
    const bounds=data.bounds,objects=data.objects;
    if(!bounds || !Number.isFinite(bounds.width_m) || !Number.isFinite(bounds.height_m) || bounds.width_m<=0 || bounds.height_m<=0 || !Array.isArray(objects))return;
    const svg=doc.createElementNS('http://www.w3.org/2000/svg','svg');svg.setAttribute('viewBox',`0 0 ${bounds.width_m} ${bounds.height_m}`);svg.setAttribute('role','img');svg.setAttribute('aria-label','Anteprima degli ingombri calcolati dal server');
    for(const o of objects){if(!state.items.some(i=>i.instance_key===o.instance_key))continue;const shape=o.shape;if(o.shape_kind!=='circle'||!shape||![shape.cx,shape.cy,shape.radius].every(Number.isFinite)||shape.radius<=0)continue;const circle=doc.createElementNS('http://www.w3.org/2000/svg','circle');circle.setAttribute('cx',String(shape.cx));circle.setAttribute('cy',String(shape.cy));circle.setAttribute('r',String(shape.radius));svg.append(circle);}
    state.previewHost.append(svg);
  }
  async function preview() {
    if(state.busy)return;if(state.parentChanged&&!state.migrationChoice){note('Scegli come trattare le coordinate della revisione precedente.');return;}const stamp=epoch, editSeq=state.editSeq;let args;
    try{args=bindingPayload({...state,items:state.items,expected_revision:state.revision});}catch(e){note(e.message);return;}
    state.busy=true;state.previewButton.disabled=true;state.save.disabled=true;note('Verifico geometria e capienza sul server…');
    try{const data=await rpc('map_binding_preview_v1',args,stamp);if(data?.schema_version!=='map-binding-preview/1'||typeof data.valid!=='boolean'||typeof data.can_fit!=='boolean'||!Array.isArray(data.errors))throw Error('Preview server non valida.');
      if(!valid(stamp)||state.editSeq!==editSeq)return;state.preview=data;renderPreview(data);state.save.disabled=!(data.valid===true && data.can_fit===true && typeof data.fingerprint==='string' && /^[a-f0-9]{64}$/.test(data.fingerprint));note(!data.valid?'Correggi gli errori mostrati dal server.':!data.can_fit?'Capienza insufficiente per il roster: scegli una mappa o riduci gli ingombri.':'Anteprima valida. Puoi salvare questa revisione.');
    }catch(e){if(valid(stamp))note(e.message||'Anteprima non disponibile.');}
    finally{if(valid(stamp)){state.busy=false;state.previewButton.disabled=false;}}
  }
  async function save() {
    if(state.busy||state.uncertain||(state.parentChanged&&!state.migrationChoice)||!state.preview?.valid||state.preview?.can_fit!==true||state.save.disabled)return;const stamp=epoch;let args;
    try{args=bindingPayload({...state,items:state.items,expected_revision:state.revision});}catch(e){note(e.message);return;}
    state.busy=true;state.save.disabled=state.previewButton.disabled=true;note('Salvataggio della nuova revisione…');
    try{const data=await rpc('map_binding_save_v1',{...args,p_preview_fingerprint:state.preview.fingerprint},stamp);
      if(data?.schema_version!=='map-binding-save/1'||data.status!=='draft'||data.selectable!==false||data.revision!==state.revision+1||!data.variant?.template_key||!Number.isSafeInteger(data.variant?.template_version)||!UUID.test(data.scope_id||state.scope_id||'')||(state.scope_id&&data.scope_id&&data.scope_id!==state.scope_id))throw Error('Salvataggio non confermato: rileggi prima di riprovare.');
      if(!valid(stamp))return;state.revision=data.revision;state.scope_id=data.scope_id||state.scope_id;state.preview=null;state.ready=false;state.connected=false;state.variant=data.variant;state.parentChanged=false;state.migrationChoice=null;state.transitionHost.replaceChildren();state.activate.disabled=false;state.connect.disabled=true;try{onSaved(data);}catch{}note(`Bozza salvata, revisione ${data.revision}. Verificala e attivala per renderla utilizzabile.`);
    }catch(e){if(valid(stamp)){state.uncertain=true;note(`Salvataggio non confermato. Rileggi l’associazione prima di riprovare. ${e.message||''}`);}}
    finally{if(valid(stamp)){state.busy=false;state.previewButton.disabled=false;}}
  }
  function readyData() {
    return {schema_version:'map-binding-activate/1',status:'ready',selectable:true,scope_kind:state.scope_kind,scope_id:state.scope_id,step_key:state.step_key,revision:state.revision,variant:state.variant};
  }
  async function connectConsumer(data,stamp) {
    try{
      await onActivated(data);
      if(!valid(stamp))return false;
      state.connected=true;state.connect.disabled=true;note(`Revisione ${data.revision} attiva e collegata.`);return true;
    }catch(e){
      if(valid(stamp)){state.connected=false;state.connect.disabled=false;note(`Revisione ${data.revision} attiva. Il collegamento non è confermato: ${e.message||'rileggi e riprova con “Collega revisione pronta”.'}`);}return false;
    }
  }
  async function connect() {
    if(state.busy||state.uncertain||!state.ready||state.connected||!state.variant||state.connect.disabled)return;
    const stamp=epoch;state.busy=true;state.previewButton.disabled=state.save.disabled=state.activate.disabled=state.connect.disabled=true;note('Verifico e collego la revisione pronta…');
    try{await connectConsumer(readyData(),stamp);}
    finally{if(valid(stamp)){state.busy=false;state.previewButton.disabled=false;state.activate.disabled=true;state.connect.disabled=state.connected;}}
  }
  async function activate() {
    if(state.busy||state.uncertain||state.ready||state.revision<1||state.activate.disabled)return;
    const stamp=epoch;
    const name=state.scope_kind==='ordinary_location'?'map_binding_activate_ordinary_v1':'map_binding_activate_scope_v1';
    const args=state.scope_kind==='ordinary_location'?{p_location_id:state.scope_id,p_expected_revision:state.revision}:{p_scope_kind:state.scope_kind,p_scope_id:state.scope_id,p_expected_revision:state.revision,p_step_key:state.step_key};
    state.busy=true;state.previewButton.disabled=state.save.disabled=state.activate.disabled=state.connect.disabled=true;note('Attivazione server della revisione…');
    try{
      const data=await rpc(name,args,stamp);
      if(data?.schema_version!=='map-binding-activate/1'||data.status!=='ready'||data.selectable!==true||data.scope_kind!==state.scope_kind||data.scope_id!==state.scope_id||data.revision!==state.revision||!data.variant?.template_key||!Number.isSafeInteger(data.variant?.template_version)||data.variant?.zone_key!=='arena'||(state.scope_kind==='mission_draft'&&data.step_key!==state.step_key))throw Error('Attivazione non confermata: rileggi prima di riprovare.');
      if(!valid(stamp))return;
      state.ready=true;state.connected=false;state.variant=data.variant;state.activate.disabled=true;state.connect.disabled=false;
      await connectConsumer(data,stamp);
    }catch(e){if(valid(stamp)){state.uncertain=true;note(`Attivazione non confermata. Riapri l’associazione per leggere lo stato server prima di riprovare. ${e.message||''}`);}}
    finally{if(valid(stamp)){state.busy=false;state.previewButton.disabled=false;state.activate.disabled=state.ready||state.uncertain;state.connect.disabled=!state.ready||state.connected;}}
  }
  async function mount(host,{scope_kind,scope_id,step_key='',parent,roster}) {
    dispose();const stamp=epoch;root=host;principal=identity?.();
    if(!principal||!UUID.test(principal)||isStaff?.()!==true)throw Error('Accesso staff richiesto.');
    state={scope_kind,scope_id,step_key,parent,roster,items:[],types:[],revision:0,preview:null,busy:false,uncertain:false,ready:false,connected:false,variant:null,editSeq:0,parentChanged:false,migrationChoice:null};
    bindingPayload({...state,expected_revision:0});
    root.replaceChildren();const panel=el('section',null,'map-binding-editor');panel.append(el('h2','Oggetti della mappa'));
    state.status=el('p','Carico catalogo e associazione…');state.status.setAttribute('role','status');state.transitionHost=el('div',null,'map-binding-parent-change');state.counts=el('p');state.rows=el('div');state.previewHost=el('div',null,'map-binding-preview');
    const chooser=el('select');chooser.setAttribute('aria-label','Tipo visivo da aggiungere');for(const type of VISUAL_TYPES){const option=el('option',DISPLAY[type]);option.value=type;chooser.append(option);}
    const add=button('Aggiungi elemento',()=>{if(state.busy)return;if(state.items.length>=32){note('Massimo 32 elementi.');return;}const type=latestType(chooser.value);if(!type){note('Tipo non pronto nel catalogo.');return;}state.items.push({instance_key:'i_'+random.randomUUID().replaceAll('-',''),visual_type:type.visual_type,visual_type_version:type.visual_type_version,x_m:'',y_m:''});invalidate();rows();});
    state.previewButton=button('Verifica geometria',preview);state.save=button('Salva nuova revisione',save);state.save.disabled=true;state.activate=button('Attiva questa revisione',activate);state.activate.disabled=true;state.connect=button('Collega revisione pronta',connect);state.connect.disabled=true;
    panel.append(state.status,state.transitionHost,chooser,add,state.counts,state.rows,state.previewButton,state.save,state.activate,state.connect,state.previewHost);root.append(panel);
    const empty={schema_version:'map-binding-detail/1',scope_kind,scope_id,step_key,revision:0,status:'draft',selectable:false,parent:null,items:[],variant:null};
    const [catalog,detail]=await Promise.all([rpc('map_binding_catalog_v1',{},stamp),scope_kind==='mission_draft'&&scope_id===null?Promise.resolve(empty):rpc('map_binding_detail_v1',{p_scope_kind:scope_kind,p_scope_id:scope_id,p_step_key:step_key},stamp)]);
    if(!valid(stamp))return null;
    if(catalog?.schema_version!=='map-binding-catalog/1'||!Array.isArray(catalog.types)||detail?.schema_version!=='map-binding-detail/1'||detail.scope_kind!==scope_kind||detail.scope_id!==scope_id||!Number.isSafeInteger(detail.revision)||detail.revision<0||!Array.isArray(detail.items))throw Error('Contratto associazione non valido.');
    if(detail.revision>0&&!detail.parent)throw Error('Parent della revisione precedente assente. Rileggi l’associazione.');
    state.parentChanged=detail.revision>0&&(detail.parent.template_key!==parent.template_key||detail.parent.template_version!==parent.template_version||detail.parent.zone_key!==parent.zone_key);
    state.types=catalog.types.filter(t=>VISUAL_TYPES.includes(t.visual_type)&&Number.isSafeInteger(t.visual_type_version)&&t.visual_type_version>0&&t.status==='ready');
    for(const type of VISUAL_TYPES){const option=[...chooser.options].find(o=>o.value===type);if(option)option.disabled=!latestType(type);}
    state.revision=detail.revision;state.ready=detail.status==='ready'&&detail.selectable===true;if(state.ready&&(!detail.variant?.template_key||!Number.isSafeInteger(detail.variant?.template_version)||detail.variant?.zone_key!=='arena'))throw Error('Variante pronta non valida: rileggi l’associazione.');state.variant=detail.variant;state.activate.disabled=state.ready||state.revision<1;state.connect.disabled=!state.ready;state.items=detail.items.map(i=>({instance_key:i.instance_key,visual_type:i.visual_type,visual_type_version:i.visual_type_version,x_m:String(i.x_m),y_m:String(i.y_m)}));
    bindingPayload({...state,items:state.items,expected_revision:state.revision});rows();
    if(state.parentChanged){
      state.previewButton.disabled=true;
      const previous=detail.parent;
      state.transitionHost.append(el('p',`Revisione ${detail.revision} su ${previous.template_key} v${previous.template_version}, zona ${previous.zone_key}. La nuova mappa è ${parent.template_key} v${parent.template_version}, zona ${parent.zone_key}. Le istanze precedenti sono mostrate sotto; scegli come trasferire le coordinate, poi verifica la geometria server prima di salvare la revisione ${detail.revision+1}. Le scene storiche restano sulla variante precedente.`));
      state.transitionHost.append(button('Mantieni coordinate precedenti',()=>{if(state.busy)return;state.migrationChoice='keep';state.previewButton.disabled=false;invalidate();note('Coordinate mantenute. Verifica geometria e capienza sulla nuova mappa.');}));
      state.transitionHost.append(button('Riposiziona sulla nuova mappa',()=>{if(state.busy)return;state.migrationChoice='move';state.items=state.items.map(i=>({...i,x_m:'',y_m:''}));rows();state.previewButton.disabled=false;invalidate();note('Inserisci le nuove coordinate e verifica geometria e capienza.');}));
      note('Mappa cambiata: scegli come trattare le coordinate della revisione precedente.');
    }else note(state.ready?`Revisione ${state.revision} attiva. Usa “Collega revisione pronta” per verificarne il consumer; una modifica crea una nuova bozza senza alterare le scene già aperte.`:'Scegli gli elementi e verifica la geometria. Salva la bozza, poi attivala esplicitamente.');
    return {dispose};
  }
  function dispose(){epoch++;root?.replaceChildren();root=null;principal=null;state=null;}
  return {mount,dispose,version:VERSION};
}
