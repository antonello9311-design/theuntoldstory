import {MissionFactoryEditor, localErrors, isVariantComplete} from './mf-editor-core-4742f38a2fd9bcad78adde128129fe5221201f99b0d9dc3dc71b50c2dc8254ed.mjs';

// Pannello candidato isolato. Le callback collegano le porte Staff trusted e i consumer già esistenti.
const make = (tag, text = '', attrs = {}) => {
  const node = document.createElement(tag);
  if (text) node.textContent = text;
  for (const [key, value] of Object.entries(attrs)) node.setAttribute(key, String(value));
  return node;
};
const label = (text, control) => { const box = make('label'); box.append(make('span', text), control); return box; };
const textField = (value, onChange, multiline = false) => {
  const node = make(multiline ? 'textarea' : 'input'); node.value = value ?? '';
  node.addEventListener('change', () => onChange(node.value)); return node;
};
const selectField = (value, values, onChange) => {
  const node = make('select');
  for (const item of values) node.append(make('option', item.label, {value:item.value}));
  node.value = value ?? ''; node.addEventListener('change', () => onChange(node.value)); return node;
};
const button = (title, action) => { const node = make('button', title, {type:'button'}); node.addEventListener('click', action); return node; };
const card = title => { const node = make('section'); node.className = 'mf-card'; node.append(make('h3', title)); return node; };
const uuid = value => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value || '');
const digest = value => /^[0-9a-f]{64}$/i.test(value || '');
const certifiedNpcCatalog = items => {
  if (!Array.isArray(items) || items.some(x => !x || x.certified !== true || x.active !== true ||
    !uuid(x.npc_id) || !uuid(x.npc_version_id) || !digest(x.bundle_sha256) ||
    typeof x.name !== 'string' || !x.name.trim() || !Number.isSafeInteger(x.version) || x.version < 1 ||
    typeof x.combat !== 'boolean' ||
    (x.staff_authoring_candidate !== undefined && typeof x.staff_authoring_candidate !== 'boolean'))) throw Error('Catalogo PNG certificati non valido.');
  if (new Set(items.map(x => x.npc_version_id)).size !== items.length) throw Error('Catalogo PNG certificati duplicato.');
  return items;
};

export function mountMissionFactoryEditor(root, {api, identity, openNpcBuilder, editVariant, attestMedia, chooseArena, onPublished, notice = () => {}} = {}) {
  if (!(root instanceof Element)) throw Error('Contenitore editor mancante.');
  const editor = new MissionFactoryEditor(api);
  const actor=typeof identity==='function'?identity():null;
  if(!uuid(actor))throw Error('Identità editoriale mancante.');
  let disposed=false,recoveryError=null,actionStamp=null;
  const viewAlive=()=>!disposed&&root.isConnected&&identity()===actor;
  const alive=()=>!disposed&&root.isConnected&&!root.hidden&&identity()===actor&&(!busy||actionStamp===rawApi.lifecycleEpoch());
  const rawApi=api;if(typeof rawApi.setLifecycle!=='function')throw Error('API senza lifecycle irrevocabile.');rawApi.setLifecycle(alive);api=new Proxy(rawApi,{get(target,key){const value=target[key];return typeof value==='function'?(...args)=>{if(!alive())throw Error('Editor chiuso: nuova chiamata bloccata.');return value.apply(target,args);}:value;}});
  const storageKey='mission-factory-editor-recovery/2/'+actor;
  let restored=false;
  try{const saved=sessionStorage.getItem(storageKey);if(saved){editor.restoreRecovery(JSON.parse(saved));restored=true;}else{const legacy=sessionStorage.getItem('mission-factory-editor-recovery/1');if(legacy){const value=JSON.parse(legacy);if(['pending_create','pending_save','pending_compile','pending_npc','pending_publish'].some(k=>value[k]))throw Error('Recupero precedente non attribuibile: conservare la richiesta e riconciliarla prima di nuove mutazioni.');}}}catch(error){recoveryError=error;}
  const persistRecovery=()=>{const raw=JSON.stringify(editor.recoverySnapshot());sessionStorage.setItem(storageKey,raw);if(sessionStorage.getItem(storageKey)!==raw)throw Error('Recupero non conservato: invio bloccato.');};
  editor.setLifecycle(alive,()=>{if(recoveryError)throw recoveryError;persistRecovery();});
  let busy = false, status = '', npcCatalog = [], reviewState = null, visibility = 'staff', scheduledAt = '', activeStage = 'mission';
  const initialSource = {title:'',plot_private:'',briefing:''};
  const seedField = (key, multiline = false) => {
    const control = textField(initialSource[key], value => { initialSource[key] = value; }, multiline);
    control.addEventListener('input', () => { initialSource[key] = control.value; });
    return control;
  };
  const builderHost = make('div'), arenaHost = make('div'), variantHost = make('div');
  builderHost.hidden = arenaHost.hidden = variantHost.hidden = true;
  const stages = [
    {key:'mission',label:'1 · Editoriale: trama, fasi e mappe'},
    {key:'npcs',label:'2 · PNG: scheda e immagini'},
    {key:'variants',label:'3 · Conduzione IA e Master'},
    {key:'publish',label:'4 · Anteprima e Pubblica'}
  ];
  const receiptMessage = receipt => ({staff:'Disponibile solo nella Staff Test Room.',scheduled:'Apertura programmata registrata.',open:'Iscrizioni aperte.',failed_review:'Apertura fermata: revisione necessaria.'})[receipt?.state] || 'Pubblicazione in verifica; aggiorna la ricevuta.';
  const currentPublicationMessage = () => editor.receipt?.state === 'scheduled' ? deliveryMessage(editor.delivery) : receiptMessage(editor.receipt);
  const deliveryMessage = delivery => ({scheduled:'Apertura in attesa dell’ora programmata.',open:'Apertura programmata eseguita.',failed_review:'Apertura programmata fermata: revisione necessaria.',staff:'Disponibile solo nella Staff Test Room.'})[delivery?.state] || 'Stato della consegna non disponibile.';
  const say = (message, isError = false) => { status = message; notice(message, isError); render(); };
  const run = async (action) => {
    if (busy||!alive()) return;
    actionStamp=rawApi.lifecycleEpoch();busy = true; render();
    try { await action(); } catch (error) { if(alive()){status = error?.message || 'Operazione non completata.'; notice(status, true);} }
    finally { try{persistRecovery();}catch(error){recoveryError=error;if(alive())status=error.message;}busy = false; if(alive())render(); }
  };
  const change = mutator => { try { editor.edit(mutator); persistRecovery(); render(); } catch (error) { status = error?.message || 'Richiesta da riconciliare.'; notice(status, true); render(); } };
  async function refreshNpcCatalog() {
    if (!editor.draftId || !editor.document) return [];
    npcCatalog = []; render();
    const items = certifiedNpcCatalog(await api.npcCatalog({scope:'mission'}));
    npcCatalog = items; render(); return items;
  }
  const catalog = () => editor.catalog || {capabilities:[], budget_policies:[], locations:[]};
  const candidateCapabilities = kind => (catalog().capabilities || []).filter(x => x.qualified === true && x.kind === kind).map(x => ({value:x.key,label:x.label || x.key}));
  const eventOptions = kind => catalog().event_projection_version === 'mission-factory-native-event/1' ?
    (Array.isArray(catalog().events) ? catalog().events : []).filter(x => x.qualified === true && x.phase_kind === kind &&
      Array.isArray(x.direction_modes) && x.direction_modes.includes('ai') && x.direction_modes.includes('human'))
      .map(x => ({value:x.key,label:x.label || x.key})) : [];
  const qualifiedKind = kind => (Array.isArray(catalog().phase_kinds) ? catalog().phase_kinds : []).some(x => x.kind === kind && x.qualified === true);
  const phaseOptions = () => (editor.document?.phases || []).map(x => ({value:x.step_key,label:x.title || x.step_key}));

  function renderMission(parent) {
    const doc = editor.document, m = doc.mission, panel = card('Canovaccio, incipit e vincoli');
    panel.append(label('Titolo', textField(m.title, v => change(d => d.mission.title = v))));
    panel.append(label('Trama riservata Staff', textField(m.plot_private, v => change(d => d.mission.plot_private = v), true)));
    panel.append(label('Briefing pubblico', textField(m.briefing, v => change(d => d.mission.briefing = v), true)));
    panel.append(label('Ritrovo', selectField(m.gathering_location_id, [{value:'',label:'Scegli chat…'}, ...(catalog().locations || []).map(x => ({value:x.id,label:x.name}))], v => change(d => d.mission.gathering_location_id = v || null))));
    for (const [key, title] of [['team_min','PG minimi'],['team_max','PG massimi']]) {
      const input = make('input', '', {type:'number',min:1,max:4}); input.value = m[key];
      input.addEventListener('change', () => change(d => d.mission[key] = Number(input.value)));
      panel.append(label(title, input));
    }
    panel.append(label('Policy IA', selectField(doc.budget_policy_id, [{value:'',label:'Scegli policy server…'}, ...(catalog().budget_policies || []).map(x => ({value:x.id,label:x.label || x.id}))], v => change(d => d.budget_policy_id = v || null))));
    parent.append(panel);
  }
  function renderPhases(parent) {
    const panel = card('Fasi e passaggi');
    for (const phase of editor.document.phases) {
      const box = card(phase.step_key);
      box.append(label('Titolo', textField(phase.title, v => change(d => d.phases.find(x => x.step_key === phase.step_key).title = v))));
      box.append(label('Obiettivo pubblico', textField(phase.objective_public, v => change(d => d.phases.find(x => x.step_key === phase.step_key).objective_public = v), true)));
      box.append(label('Capacità', selectField(phase.capability_key, [{value:'',label:'Scegli capacità qualificata…'},...candidateCapabilities(phase.kind)], v => change(d => d.phases.find(x => x.step_key === phase.step_key).capability_key = v))));
      const terminal = selectField(phase.terminal_outcome ?? '', [{value:'',label:'La fase prosegue'},...(Array.isArray(catalog().terminal_outcomes) ? catalog().terminal_outcomes : []).map(x => ({value:x,label:x === 'success' ? 'Missione riuscita' : 'Missione fallita'}))], v => change(d => {
        const target=d.phases.find(x => x.step_key === phase.step_key);
        target.terminal_outcome=v || null;
        if (v) target.transitions=[];
      }));
      if (phase.kind !== 'narrative' || !qualifiedKind('narrative')) terminal.disabled=true;
      box.append(label('Esito terminale esplicito', terminal));
      box.append(label('PNG presenti', textField((phase.actor_keys || []).join(', '), v => change(d => d.phases.find(x => x.step_key === phase.step_key).actor_keys = v.split(',').map(x => x.trim()).filter(Boolean)))));
      for (const transition of phase.transitions || []) {
        const row = make('div'); row.append(make('strong', transition.transition_key));
        const options=eventOptions(phase.kind);
        if (transition.event_key && !options.some(x => x.value === transition.event_key)) options.unshift({value:transition.event_key,label:'Evento non più qualificato · scegli di nuovo'});
        row.append(label('Evento supportato', selectField(transition.event_key, [{value:'',label:'Scegli evento qualificato…'},...options], v => change(d => d.phases.find(x => x.step_key === phase.step_key).transitions.find(x => x.transition_key === transition.transition_key).event_key = v))));
        row.append(label('Fase successiva', selectField(transition.to_step_key, [{value:'',label:'Scegli fase successiva…'}, ...phaseOptions()], v => change(d => d.phases.find(x => x.step_key === phase.step_key).transitions.find(x => x.transition_key === transition.transition_key).to_step_key = v || null))));
        box.append(row);
      }
      if (!phase.terminal_outcome) box.append(button('Aggiungi passaggio', () => change(d => {
        const target = d.phases.find(x => x.step_key === phase.step_key);
        target.transitions ||= []; let n=target.transitions.length+1,key=`${phase.step_key}_passaggio_${n}`;
        const all=d.phases.flatMap(x => x.transitions || []);
        while(all.some(x => x.transition_key === key)) key=`${phase.step_key}_passaggio_${++n}`;
        target.transitions.push({transition_key:key,event_key:'',to_step_key:null});
      })));
      box.append(button('Rimuovi fase', () => change(d => { d.phases = d.phases.filter(x => x.step_key !== phase.step_key); d.maps = d.maps.filter(x => x.step_key !== phase.step_key); })));
      panel.append(box);
    }
    for (const kind of ['narrative','d100','combat']) {
      const add=button(`Aggiungi fase ${kind}`, () => change(d => {
        let n = d.phases.length + 1, key = `fase_${n}`; while (d.phases.some(x => x.step_key === key)) key = `fase_${++n}`;
        d.phases.push({step_key:key,kind,title:'',objective_public:'',actor_keys:[],capability_key:'',terminal_outcome:null,transitions:[]});
      }));
      add.disabled=!qualifiedKind(kind);
      panel.append(add);
      if(!qualifiedKind(kind))panel.append(make('small', `${kind}: ${(catalog().phase_kinds || []).find(x => x.kind === kind)?.reason_code || 'capacità non qualificata'}.`));
    }
    parent.append(panel);
  }
  function syncNpcActors(doc) {
    for (const phase of doc.phases || []) phase.actor_keys = (doc.npc_bindings || [])
      .filter(x => x.phase_keys?.includes(phase.step_key)).map(x => x.actor_key);
  }
  function renderNpcs(parent) {
    const panel = card('PNG canonici · Builder e Ninja Book');
    panel.append(make('p', 'Scheda, ritratto e sagoma mappa si completano nel Builder. La storia conserva solo la versione certificata e la presenza nelle fasi.'));
    for (const binding of editor.document.npc_bindings) {
      const box = make('div'); box.className = 'mf-npc-binding';
      box.append(make('strong', `${binding.actor_key} · ${binding.npc_version_id}`));
      if (binding.combat === true) {
        const checked = editor.authoringChecks.get(binding.actor_key);
        box.append(make('p', checked ? `Verifica Staff: ${checked.status}${checked.reason_code ? ` · ${checked.reason_code}` : ''}. Anteprima e scontro richiedono qualifica server separata.` : 'Combat richiesto: salva e verifica le fasi con il server.'));
        box.append(button('Verifica PNG Combat nella bozza salvata', () => run(async () => {
          const result = await editor.checkNpcAuthoring(binding.actor_key);
          status = result.staff_selectable ? 'Binding selezionabile per l’authoring Staff; anteprima e scontro restano soggetti ai gate server.' : `Binding bloccato: ${result.reason_code || 'controlla fasi e bundle'}.`;
        })));
      }
      box.append(label('Fasi', textField(binding.phase_keys.join(', '), v => change(d => {
        d.npc_bindings.find(x => x.actor_key === binding.actor_key).phase_keys = v.split(',').map(x => x.trim()).filter(Boolean);
        syncNpcActors(d);
      }))));
      box.append(label('Schieramento', selectField(binding.team || '', [{value:'',label:'Scegli schieramento…'},{value:'alleati',label:'Alleati'},{value:'avversari',label:'Avversari'},{value:'civili',label:'Civili'}], v => change(d => d.npc_bindings.find(x => x.actor_key === binding.actor_key).team = v))));
      box.append(button('Rimuovi presenza', () => change(d => {
        d.npc_bindings = d.npc_bindings.filter(x => x.actor_key !== binding.actor_key); syncNpcActors(d);
      })));
      panel.append(box);
    }
    const actor = textField('', () => {}), version = selectField('', [{value:'',label:'Scegli versione certificata…'},...npcCatalog.map(x => ({value:x.npc_version_id,label:`${x.name} · v${x.version} · ${String(x.bundle_sha256 || '').slice(0,8)}`}))], () => {});
    const combat = make('input','',{type:'checkbox'});
    const team = selectField('', [{value:'',label:'Scegli schieramento…'},{value:'alleati',label:'Alleati'},{value:'avversari',label:'Avversari'},{value:'civili',label:'Civili'}], () => {});
    const updateCombatAvailability = () => {
      const selected = npcCatalog.find(x => x.npc_version_id === version.value);
      combat.disabled = selected?.combat !== true && selected?.staff_authoring_candidate !== true;
      if (combat.disabled) combat.checked = false;
    };
    version.addEventListener('change', updateCombatAvailability);
    updateCombatAvailability();
    const phaseChecks = new Map();
    for (const phase of editor.document.phases) {
      const check = make('input','',{type:'checkbox'}); phaseChecks.set(phase.step_key,check);
      panel.append(label(`Presenza nella fase ${phase.title || phase.step_key}`,check));
    }
    panel.append(label('Actor key',actor),label('Versione Ninja Book',version),label('Profilo Combat da verificare sulla bozza salvata',combat),label('Schieramento',team));
    panel.append(button('Collega PNG', () => run(async () => {
      const selected = npcCatalog.find(x => x.npc_version_id === version.value);
      const selectedPhases = [...phaseChecks].filter(([,check]) => check.checked).map(([key]) => key);
      if (!selected || !actor.value.trim() || !team.value || !selectedPhases.length) throw Error('Scegli versione, actor key, schieramento e almeno una fase.');
      if (combat.checked && selected.combat !== true && selected.staff_authoring_candidate !== true) throw Error('PNG Combat non candidato alla verifica contestuale.');
      await editor.bindNpc({actor_key:actor.value.trim(),npc_id:selected.npc_id,npc_version_id:selected.npc_version_id,phase_keys:selectedPhases,combat:combat.checked,team:team.value,staff_authoring_candidate:combat.checked && selected.staff_authoring_candidate === true});
      status = 'PNG collegato; salva e rinnova l’anteprima.';
    })));
    panel.append(button('Aggiorna PNG certificati', () => run(async () => {
      const items = await refreshNpcCatalog(); status = `${items.length} versioni certificate disponibili nel catalogo.`;
    })));
    panel.append(button('Crea PNG nel Ninja Book', () => run(async () => {
      if (typeof openNpcBuilder !== 'function') throw Error('Builder Staff non collegato.');
      builderHost.hidden = false;
      const created = await openNpcBuilder({draft_id:editor.draftId,host:builderHost,scope:'mission'});
      if (created?.opened === true && created?.certified !== true) { builderHost.hidden = true; status = 'Ninja Book aperto. La bozza PNG resta autonoma finché una versione completa e certificata non viene collegata esplicitamente alla storia.'; return; }
      if (created?.certified !== true) throw Error('Il PNG deve essere certificato prima del collegamento.');
      await refreshNpcCatalog(); builderHost.replaceChildren(); builderHost.hidden = true; status = 'Versione PNG certificata disponibile nel catalogo.';
    })));
    panel.append(builderHost); parent.append(panel);
  }
  function renderMaps(parent) {
    const panel = card('Mappe di contesto e arena dello scontro');
    for (const phase of editor.document.phases) {
      const binding = editor.document.maps.find(x => x.step_key === phase.step_key);
      const box = make('div'); box.className = 'mf-map-row'; box.append(make('strong', phase.title || phase.step_key));
      const fileInput = make('input','',{type:'file',accept:'image/png,image/jpeg,image/webp'});
      fileInput.addEventListener('change', () => run(async () => {
        const file = fileInput.files?.[0]; if (!file) return;
        const sender = typeof attestMedia === 'function' ? attestMedia : api.attestMedia;
        if (typeof sender !== 'function') throw Error('Media attestati non collegati.');
        const media = await sender({draft_id:editor.draftId,step_key:phase.step_key,kind:'context',file});
        if (!uuid(media?.media_id) || media.phase_key !== phase.step_key || media.state !== 'registered') throw Error('Attestazione media non confermata.');
        change(d => { const row = d.maps.find(x => x.step_key === phase.step_key) || (d.maps.push({step_key:phase.step_key,context_media_id:null,combat_map:null}), d.maps.at(-1)); row.context_media_id = media.media_id; });
        status = 'Immagine attestata; salva e rinnova l’anteprima.';
      }));
      box.append(label('Immagine di contesto',fileInput));
      if (phase.kind === 'combat') box.append(button('Scegli arena pronta', () => run(async () => {
        if (typeof chooseArena !== 'function') throw Error('Catalogo arene non collegato.');
        arenaHost.hidden = false;
        const roster = {pg_count:editor.document.mission.team_max,png_count:editor.document.npc_bindings.filter(x => x.phase_keys?.includes(phase.step_key)).length};
        const arena = await chooseArena({draft_id:editor.draftId,step_key:phase.step_key,title:phase.title || phase.step_key,roster,current:binding?.combat_map || null,host:arenaHost});
        if (typeof arena?.template_key !== 'string' || !arena.template_key.trim() || !Number.isInteger(arena.template_version) || arena.template_version < 1 || typeof arena.zone_key !== 'string' || !arena.zone_key.trim()) throw Error('Arena pronta e zona non confermate.');
        change(d => { const row = d.maps.find(x => x.step_key === phase.step_key) || (d.maps.push({step_key:phase.step_key,context_media_id:null,combat_map:null}), d.maps.at(-1)); row.combat_map = {template_key:arena.template_key,template_version:arena.template_version,zone_key:arena.zone_key}; });
        arenaHost.replaceChildren(); arenaHost.hidden = true;
      })));
      if (binding) box.append(make('small', `Contesto: ${binding.context_media_id || 'nessuno'} · Arena: ${binding.combat_map ? `${binding.combat_map.template_key} · v${binding.combat_map.template_version} · zona ${binding.combat_map.zone_key || 'da scegliere'}` : 'nessuna'}`));
      panel.append(box);
    }
    panel.append(arenaHost); parent.append(panel);
  }
  function renderVariants(parent) {
    const panel = card('Doppio mandato IA e Master');
    for (const mode of ['ai','human']) {
      const variant = editor.document.variants?.[mode] || {state:'missing'};
      panel.append(make('p', `${mode === 'ai' ? 'IA' : 'Master'}: ${variant.state}`));
      panel.append(button(`Configura ${mode === 'ai' ? 'IA' : 'Master'}`, () => run(async () => {
        if (typeof editVariant !== 'function') throw Error('Editor delle varianti non collegato.');
        const saved = await editor.save();
        if (saved.control_version !== editor.controlVersion) throw Error('Versione della bozza non confermata.');
        variantHost.hidden = false;
        try {
          const result = await editVariant({mode,draft_id:editor.draftId,expected_version:editor.controlVersion,
            document:structuredClone(editor.document),host:variantHost});
          if (result == null) return; // Chiusura o annullamento: la bozza rimane invariata.
          if (!isVariantComplete(result, mode)) throw Error('Documento variante incompleto o non coerente con la modalità scelta.');
          change(d => d.variants[mode] = structuredClone(result));
        } finally {
          variantHost.replaceChildren(); variantHost.hidden = true;
        }
      })));
    }
    panel.append(variantHost); parent.append(panel);
  }
  function renderActions(parent) {
    const panel = card('Anteprima e pubblicazione');
    const errors = editor.catalog ? localErrors(editor.document, editor.catalog, {forPublish:true}) : [];
    if (errors.length) { const list = make('ul'); for (const error of errors) list.append(make('li', `${error.code} · ${error.path}`)); panel.append(list); }
    panel.append(button('Compila proposta IA', () => run(async () => { await editor.save(); const result = await editor.compile(); status = result.state === 'complete' ? 'Proposta pronta da correggere.' : 'Compilazione in corso; conserva la stessa richiesta.'; })));
    if (editor.pendingCompile) panel.append(button('Aggiorna compilazione', () => run(async () => { const result = await editor.resumeCompile(); status = result.state === 'complete' ? 'Proposta pronta da correggere.' : 'Compilazione ancora in corso.'; })));
    panel.append(button('Salva bozza', () => run(async () => { await editor.save(); status = 'Bozza salvata; anteprima invalidata.'; })));
    panel.append(button('Anteprima validata', () => run(async () => { const result = await editor.requestPreview(); status = result.errors.length ? 'Correggi gli errori della preview.' : 'Anteprima server sigillata.'; })));
    if (reviewState) panel.append(make('p',`Revisione sensibile: ${reviewState.status}.`));
    panel.append(button('Richiedi revisione sensibile', () => run(async () => {
      await editor.save();
      reviewState = await api.sensitiveRequest({draft_id:editor.draftId,expected_version:editor.controlVersion,request_key:crypto.randomUUID()});
      await editor.open(editor.draftId); status = 'Revisione richiesta; attesa decisione Admin.';
    })));
    if (reviewState?.can_decide && reviewState.request_key) for (const decision of ['approved','rejected']) {
      panel.append(button(decision === 'approved' ? 'Approva revisione' : 'Respinge revisione', () => run(async () => {
        reviewState = await api.sensitiveDecide({draft_id:editor.draftId,request_key:reviewState.request_key,expected_version:editor.controlVersion,decision,decision_key:crypto.randomUUID()});
        await editor.open(editor.draftId); status = decision === 'approved' ? 'Revisione approvata; rinnova l’anteprima.' : 'Revisione respinta; correggi e richiedi di nuovo.';
      })));
    }
    if (reviewState?.required) panel.append(button('Aggiorna revisione', () => run(async () => { reviewState = await api.sensitiveState({draft_id:editor.draftId}); status = `Revisione: ${reviewState.status}.`; })));
    if (editor.receipt) { panel.append(make('p',currentPublicationMessage()));
      if (editor.receipt.state === 'scheduled') panel.append(button('Aggiorna apertura programmata', () => run(async () => {
        const result = await editor.refreshDelivery(); status = result.state === 'confirmed' ? currentPublicationMessage() : 'Stato della programmazione incerto; verifica Staff.';
      }))); }
    if (editor.preview) {
      const p = editor.preview;
      panel.append(make('h4','Vista PG'),make('p',p.public_summary || 'Nessun riepilogo pubblico.'));
      panel.append(make('h4','Vista Staff'),make('p',p.staff_summary || 'Nessun riepilogo Staff.'));
      for (const error of p.errors) panel.append(make('p',`${error.code} · ${error.detail || ''}`));
    }
    const publicOpen=catalog().public_open_qualified===true;
    if(!publicOpen&&visibility==='open')visibility='staff';
    panel.append(label('Disponibilità',selectField(visibility,[{value:'staff',label:'Riservata Staff'},
      {value:'scheduled',label:'Programmata · verifica destinazione'},
       ...(publicOpen?[{value:'open',label:'Iscrizioni aperte'}]:[])],v => {visibility=v;editor.invalidateSchedule();render();})));
    if(!publicOpen)panel.append(make('small',catalog().public_open_reason_code || 'Apertura pubblica non qualificata; il collaudo resta riservato alla Staff.'));
    const scheduleIso=scheduledAt&&Number.isFinite(Date.parse(scheduledAt))?new Date(scheduledAt).toISOString():null;
    if (visibility === 'scheduled') {
      const date=make('input','',{type:'datetime-local'});date.value=scheduledAt;
      date.addEventListener('input',()=>{scheduledAt=date.value;editor.invalidateSchedule();publish.disabled=true;target.textContent='Data cambiata: ripeti la verifica della programmazione.';});
      date.addEventListener('change',()=>render());panel.append(label('Data e ora',date));
      const verify=button('Verifica programmazione',()=>run(async()=>{
        const value=await editor.checkSchedule(scheduleIso);
        status=value.allowed?(value.target==='staff'?'Programmazione riservata alla Staff Test Room.':'Programmazione pubblica autorizzata dal server.'):'Programmazione non autorizzata per questa bozza e data.';
      }));verify.disabled=busy||!editor.canPublish()||!scheduleIso;panel.append(verify);
      const target=make('p',editor.canSchedule(scheduleIso)?(editor.scheduleCapability.value.target==='staff'?'Destinazione: Staff Test Room. Nessuna apertura generale.':'Destinazione: pubblico.'):'Verifica la destinazione per questa bozza e data.');panel.append(target);
      panel.append(make('small','La scadenza indica una richiesta: la consegna effettiva è confermata dal server.'));
    }
    const publish = button('Pubblica', () => run(async () => { const result = await editor.publish(visibility,visibility === 'scheduled' ? new Date(scheduledAt).toISOString() : null); status = receiptMessage(result); if (result.mission_id && result.state !== 'failed_review') onPublished?.(result); }));
    publish.disabled = !editor.canPublish() || busy || errors.length > 0 || (visibility === 'scheduled' && !editor.canSchedule(scheduleIso)); panel.append(publish);
    if (editor.pendingPublish) panel.append(button('Aggiorna ricevuta', () => run(async () => { const result = await editor.resumePublish(); status = result.state === 'confirmed' ? deliveryMessage(result.delivery) : 'Pubblicazione ancora in verifica; nessuna nuova richiesta.'; if (result.state === 'confirmed' && result.result.mission_id && result.result.state !== 'failed_review') onPublished?.(result.result); })));
    parent.append(panel);
  }
  function render() {
    if(!viewAlive())return;
    root.replaceChildren(); const heading = make('h2','Fabbrica missioni'); root.append(heading);
    root.append(make('p',status,{role:'status',class:'mf-status'}));
    if (!editor.document) {
      const pending = editor.recoverySnapshot();
      if (pending.pending_create || pending.pending_save || pending.pending_compile || pending.pending_npc || pending.pending_publish) root.append(button('Aggiorna richiesta', () => run(async () => { const states = await editor.recoverPending(); status = states.some(x => x.state === 'unknown') ? 'Richiesta ancora incerta: nessun nuovo invio automatico.' : editor.receipt ? currentPublicationMessage() : 'Stato recuperato dal server.'; if (editor.document) { await editor.loadCatalog(); await refreshNpcCatalog(); reviewState = await api.sensitiveState({draft_id:editor.draftId}); } })));
      else {
        const start = card('Canovaccio iniziale');
        start.append(label('Titolo', seedField('title')));
        start.append(label('Trama riservata Staff', seedField('plot_private', true)));
        start.append(label('Briefing pubblico', seedField('briefing', true)));
        start.append(button('Crea bozza e continua', () => run(async () => {
          await editor.create(initialSource);
          await refreshNpcCatalog();
          reviewState = await api.sensitiveState({draft_id:editor.draftId});
          activeStage = 'mission'; status = 'Bozza pronta: completa ritrovo, team e policy IA.';
        })));
        root.append(start);
      }
      return;
    }
    const nav = make('nav'); nav.className = 'mf-stage-nav'; nav.setAttribute('aria-label','Passi dell’editor missioni');
    for (const step of stages) { const tab = button(step.label, () => { activeStage=step.key; render(); }); if (step.key===activeStage) tab.setAttribute('aria-current','step'); nav.append(tab); }
    root.append(nav);
    if (activeStage==='mission') { renderMission(root); renderPhases(root); renderMaps(root); }
    else if (activeStage==='npcs') renderNpcs(root);
    else if (activeStage==='variants') renderVariants(root);
    else renderActions(root);
    const index=stages.findIndex(x=>x.key===activeStage), controls=make('div'); controls.className = 'mf-controls';
    if (index>0) controls.append(button('Passo precedente',()=>{activeStage=stages[index-1].key;render();}));
    if (index<stages.length-1) controls.append(button('Passo successivo',()=>{activeStage=stages[index+1].key;render();}));
    root.append(controls);
    for (const node of root.querySelectorAll('button,input,textarea,select')) if (busy) node.disabled = true;
  }
  render();
  if (restored) run(async () => { const states = await editor.recoverPending(); if (editor.document) { await editor.loadCatalog(); await refreshNpcCatalog(); reviewState = await api.sensitiveState({draft_id:editor.draftId}); } status = states.some(x => x.state === 'unknown') ? 'Richiesta ancora incerta: aggiorna stato prima di modificare.' : editor.receipt ? currentPublicationMessage() : 'Bozza ripresa dal server.'; });
  return {editor,refreshNpcCatalog,open: id => run(async () => { await editor.loadCatalog(); await editor.open(id); await refreshNpcCatalog(); reviewState = await api.sensitiveState({draft_id:editor.draftId}); }),dispose:() => {disposed=true;editor.dispose();root.replaceChildren();}};
}
