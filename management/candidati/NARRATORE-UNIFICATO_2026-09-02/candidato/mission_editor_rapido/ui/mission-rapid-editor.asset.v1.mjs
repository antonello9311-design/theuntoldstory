export const VERSION = 'mission-rapid-editor/2026-09-19.mvp3';
export const DRAFT_SCHEMA = 'mission-rapid-draft/1';
export const PREVIEW_SCHEMA = 'mission-rapid-preview/1';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const copy = value => value == null ? value : structuredClone(value);
const clean = value => String(value ?? '').trim();
const slug = value => clean(value).normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
const words = value => new Set(slug(value).split(/\s+/).filter(x => x.length > 1));
const makeUuid = () => crypto.randomUUID();
const GRADE_RANKS = Object.freeze({D: ['deshi','academy'], C: ['genin'], B: ['chunin'], A: ['jonin'], S: ['kage','sannin']});

export function createInitialState(source = {}) {
  return {
    source: {
      plot: clean(source.plot),
      phase_hints: Array.isArray(source.phase_hints) ? source.phase_hints.map(clean).filter(Boolean) : [],
      png_uploads: Array.isArray(source.png_uploads) ? source.png_uploads.map(x => ({upload_key: clean(x?.upload_key), label: clean(x?.label)})).filter(x => x.upload_key) : [],
      has_map_image: source.has_map_image === true,
      map_notes: clean(source.map_notes)
    },
    draftId: null,
    controlVersion: null,
    compileRequest: null, compileDispatched: false,
    compiled: null,
    catalog: null,
    configuration: {
      gathering_location_id: '', village: '', tag_trama: '', actor_bindings: [],
      map: {mode: 'default10', name: '', description: '', objects: [], positions: [], spec: null},
      budget: null
    },
    uploads: [], mapUpload: null, preview: null, previewSeal: null,
    dirty: true, busy: false, uncertainPublish: false, lastPublishRequest: null, published: null, message: ''
  };
}

function actorNames(actor) {
  return [actor?.actor_key, actor?.identity?.name, actor?.identity?.public_name, actor?.name, actor?.role]
    .map(slug).filter(Boolean);
}

export function autoLinkMedia(actors = [], uploads = []) {
  const choices = new Map();
  for (const upload of uploads) {
    const base = slug(clean(upload.file_name).replace(/\.[^.]+$/, ''));
    const tokens = words(base);
    const scored = actors.map(actor => {
      const names = actorNames(actor);
      let score = 0;
      for (const name of names) {
        if (base === name) score = Math.max(score, 100);
        else if (base.includes(name) || name.includes(base)) score = Math.max(score, 70);
        const overlap = [...words(name)].filter(x => tokens.has(x)).length;
        score = Math.max(score, overlap * 10);
      }
      return {actor_key: actor.actor_key, score};
    }).filter(x => x.score > 0).sort((a, b) => b.score - a.score || a.actor_key.localeCompare(b.actor_key));
    if (scored.length && (scored.length === 1 || scored[0].score > scored[1].score)) choices.set(upload, scored[0].actor_key);
  }
  const byActor = new Map();
  for (const [upload, actorKey] of choices) {
    const list = byActor.get(actorKey) || [];
    list.push(upload); byActor.set(actorKey, list);
  }
  const linked = {}, ambiguous = [], unassigned = [];
  for (const [actorKey, list] of byActor) {
    if (list.length === 1) linked[actorKey] = list[0];
    else ambiguous.push({actor_key: actorKey, uploads: list.map(x => x.media_id || x.file_name)});
  }
  for (const upload of uploads) if (![...Object.values(linked)].includes(upload) && !ambiguous.some(a => a.uploads.includes(upload.media_id || upload.file_name))) unassigned.push(upload);
  return {linked, ambiguous, unassigned};
}

export function proposeApprovedBundle(actor, bundles = []) {
  const request = actor?.mechanical_request || {};
  const actorTokens = words([actor?.role, actor?.identity, actor?.personality, actor?.behavior, request.combat_role, ...(request.archetype_tags || [])].join(' '));
  const admittedRanks = GRADE_RANKS[request.desired_grade] || [];
  const scored = bundles.filter(bundle => UUID.test(bundle?.bundle_id || '') && bundle?.mechanical_profile && Array.isArray(bundle.mechanical_profile.abilities)).map(bundle => {
    const profile = bundle.mechanical_profile;
    const searchable = words([bundle.display_name, profile.rank, profile.archetype, JSON.stringify(bundle.mechanics?.document?.skeleton || {})].join(' '));
    const overlap = [...actorTokens].filter(token => searchable.has(token)).length;
    const grade = admittedRanks.includes(slug(profile.rank)) ? 4 : 0;
    return {bundle_id: bundle.bundle_id, score: overlap * 10 + grade};
  }).filter(x => x.score > 0).sort((a, b) => b.score - a.score || a.bundle_id.localeCompare(b.bundle_id));
  if (!scored.length || scored.length > 1 && scored[0].score === scored[1].score) return null;
  return scored[0];
}

function mechanicalSummary(bundle) {
  const profile = bundle?.mechanical_profile;
  if (!profile) return 'Profilo meccanico non disponibile.';
  const techniques = (profile.abilities || []).map(x => x?.name || x?.label || x?.ability_key || x?.technique_key).filter(Boolean);
  return `${profile.rank || 'grado n/d'} · PV ${profile.vita_max ?? 'n/d'} · chakra ${profile.chakra_max ?? 'n/d'}${techniques.length ? ` · ${techniques.join(', ')}` : ''}`;
}

export function invalidatePreview(state) {
  state.preview = null; state.previewSeal = null; state.dirty = true; state.published = null;
  return state;
}

export function buildDraftDocument(state) {
  return {schema_version: DRAFT_SCHEMA, source: copy(state.source), compiled: copy(state.compiled), configuration: copy(state.configuration)};
}

export function localBlockingErrors(state) {
  const errors = [];
  if (clean(state.source?.plot).length < 40) errors.push({code: 'PLOT_REQUIRED', detail: 'Inserisci una trama di almeno 40 caratteri.'});
  if (!state.compiled || !Array.isArray(state.compiled.actors) || !Array.isArray(state.compiled.phases)) errors.push({code: 'COMPILE_REQUIRED', detail: 'Compila prima la trama.'});
  if (state.compiled) {
    const actorKeys = new Set(state.compiled.actors.map(a => a.actor_key));
    const bindings = state.configuration.actor_bindings || [];
    for (const key of actorKeys) {
      const binding = bindings.find(x => x.actor_key === key);
      if (!binding) errors.push({code: 'ACTOR_BINDING_MISSING', actor_key: key});
      else {
        if (!UUID.test(binding.base_bundle_id || '')) errors.push({code: 'BUNDLE_REQUIRED', actor_key: key});
        if (!UUID.test(binding.media_id || '')) errors.push({code: 'MEDIA_MISSING', actor_key: key});
        if (!['alleati', 'avversari', 'civili'].includes(binding.team)) errors.push({code: 'TEAM_INVALID', actor_key: key});
        if (binding.approved !== true) errors.push({code: 'PNG_UNAPPROVED', actor_key: key});
      }
    }
    if (bindings.some(x => !actorKeys.has(x.actor_key))) errors.push({code: 'ACTOR_BINDING_UNKNOWN'});
    for (const rule of state.compiled.terminal_rules || []) {
      const phase = state.compiled.phases.find(x => x.step_key === rule.phase_key);
      if (phase?.kind !== 'combat') errors.push({code:'RULE_PHASE_INVALID',rule_key:rule.rule_key});
      if (rule.type === 'victory' && rule.outcome !== 'success' || rule.type === 'defeat' && rule.outcome !== 'failure') errors.push({code:'RULE_OUTCOME_INVALID',rule_key:rule.rule_key});
      if (['escape','protect_subject','reach_position'].includes(rule.type) && !clean(rule.subject_key)) errors.push({code:'RULE_SUBJECT_REQUIRED',rule_key:rule.rule_key});
      if (rule.type === 'escape' && !actorKeys.has(rule.subject_key)) errors.push({code:'RULE_ESCAPE_ACTOR_INVALID',rule_key:rule.rule_key});
      if (['surrender_after_exchanges','survive_rounds'].includes(rule.type) && (!Number.isInteger(rule.threshold) || rule.threshold < 1 || rule.threshold > 99)) errors.push({code:'RULE_THRESHOLD_INVALID',rule_key:rule.rule_key});
    }
    const nativeTypes = new Set(['surrender_after_exchanges','escape','protect_subject','reach_position','survive_rounds']);
    const nativeByPhase = new Map();
    for (const rule of state.compiled.terminal_rules || []) if (nativeTypes.has(rule.type)) nativeByPhase.set(rule.phase_key,(nativeByPhase.get(rule.phase_key)||0)+1);
    for (const [phase_key,count] of nativeByPhase) if (count>1) errors.push({code:'RULE_NATIVE_AMBIGUOUS',phase_key});
  }
  if (!UUID.test(state.configuration.gathering_location_id || '')) errors.push({code: 'LOCATION_REQUIRED'});
  const map = state.configuration.map || {};
  if (!['default10', 'specific'].includes(map.mode)) errors.push({code: 'MAP_INVALID'});
  if (map.mode === 'specific' && (!clean(map.template_key) || !Number.isInteger(Number(map.template_version)) || Number(map.template_version) < 1 || map.spec?.template_key !== map.template_key)) errors.push({code: 'MAP_SPEC_REQUIRED'});
  const budget = state.configuration.budget;
  if (!budget || !Number.isInteger(Number(budget.max_calls)) || Number(budget.max_calls) < 1 || !(Number(budget.max_cost_usd) > 0) || !Number.isInteger(Number(budget.max_input_tokens)) || !Number.isInteger(Number(budget.max_output_tokens))) errors.push({code: 'BUDGET_REQUIRED'});
  return errors;
}

export const canPublish = state => Boolean(
  state.preview && state.preview.schema_version === PREVIEW_SCHEMA &&
  Array.isArray(state.preview.errors) && state.preview.errors.length === 0 &&
  typeof state.previewSeal === 'string' && /^[0-9a-f]{64}$/.test(state.previewSeal) &&
  state.preview.draft_version === state.controlVersion && !state.dirty && !state.busy && !state.published
);

export function applyCompiled(state, result, catalog = state.catalog) {
  if (result?.schema_version !== 'mission-rapid-compile-state/1' && result?.schema_version !== 'mission-rapid-compile-result/1') throw Error('Risposta di compilazione non riconosciuta.');
  if (!UUID.test(result.draft_id || '') || !Number.isSafeInteger(result.control_version)) throw Error('Identità della bozza non valida.');
  if (!result.compiled || !Array.isArray(result.compiled.actors) || !Array.isArray(result.compiled.phases)) throw Error('Documento compilato incompleto.');
  state.draftId = result.draft_id; state.controlVersion = result.control_version; state.compiled = copy(result.compiled);
  if (result.source) state.source = copy(result.source);
  state.configuration.actor_bindings = result.compiled.actors.map(actor => ({actor_key: actor.actor_key, base_bundle_id: proposeApprovedBundle(actor, catalog?.bundles || [])?.bundle_id || '', media_id: '', team: actor.team, approved: false}));
  state.configuration.map.mode = result.compiled.map_request?.mode === 'specific' ? 'specific' : 'default10';
  invalidatePreview(state); return state;
}

export async function dispatchCompiler(client, requestKey) {
  if (!UUID.test(requestKey || '') || typeof client?.functions?.invoke !== 'function') throw Error('Servizio di compilazione non disponibile.');
  const response = await client.functions.invoke('mission_authoring_ai', {body: {request_key: requestKey}});
  if (response?.error) return {confirmed: false, error: response.error};
  const result = response?.data;
  if (!result || typeof result !== 'object') return {confirmed: false, error: Error('Risposta Edge non riconoscibile.')};
  return {confirmed: result.schema_version === 'mission-rapid-compile-result/1', result};
}

export function createMissionRapidEditor({client, identity, isStaff, uploadMedia, chooseMap, notice = () => {}, onPublished = () => {}, pollMs = 900, maxPolls = 80, runtimeBudget = null} = {}) {
  if (!client?.rpc) throw Error('Client RPC richiesto.');
  let state = createInitialState(), host = null, epoch = 0;
  const user = () => typeof identity === 'function' ? identity() : identity;
  const allowed = () => (typeof isStaff === 'function' ? isStaff() : isStaff) === true && UUID.test(user() || '');
  async function rpc(name, args) {
    if (!allowed()) throw Object.assign(Error('Sessione Staff non disponibile.'), {code: '42501'});
    const out = await client.rpc(name, args);
    if (out?.error) throw Object.assign(Error(out.error.message || 'Operazione rifiutata.'), out.error);
    return out?.data ?? out;
  }
  const setMessage = message => { state.message = message; if (host) render(); };
  const edit = fn => { fn(); invalidatePreview(state); render(); };
  const el = (tag, text = null, attrs = {}) => { const n = document.createElement(tag); if (text !== null) n.textContent = text; for (const [k, v] of Object.entries(attrs)) n.setAttribute(k, v); return n; };
  const button = (label, fn, disabled = false) => { const n = el('button', label, {type: 'button'}); n.disabled = disabled; n.addEventListener('click', fn); return n; };
  const input = (value, fn, attrs = {}) => { const n = el(attrs.rows ? 'textarea' : 'input', null, attrs); n.value = value ?? ''; n.addEventListener('input', () => fn(n.value)); return n; };
  const field = (label, control) => { const n = el('label'); n.append(el('span', label), control); return n; };
  function section(title) { const n = el('section', null, {class: 'mr-card'}); n.append(el('h3', title)); return n; }
  function renderErrors(parent, errors) { const ul = el('ul'); for (const e of errors || []) ul.append(el('li', [e.code, e.actor_key, e.detail].filter(Boolean).join(' · '))); parent.append(ul); }
  function actorLabel(actor) { return clean(actor?.display_name || actor?.name || actor?.role || actor?.actor_key); }
  const choice = (items, value, fn) => { const n = el('select'); for (const item of items) { const pair = Array.isArray(item) ? item : [item, item]; n.append(el('option', pair[1], {value: pair[0]})); } n.value = value ?? ''; n.addEventListener('change', () => fn(n.value)); return n; };
  function bindUpload(actorKey, mediaId) { edit(() => { const b = state.configuration.actor_bindings.find(x => x.actor_key === actorKey); if (b) b.media_id = mediaId; }); }
  async function addActorUploads(files, forcedActorKey = null) {
    if (typeof uploadMedia !== 'function') throw Error('Caricamento media non collegato al percorso attestato.');
    state.busy = true; setMessage('Caricamento e attestazione immagini…');
    try {
      for (const file of files) {
        let actorKey = forcedActorKey;
        if (!actorKey) {
          const match = autoLinkMedia(state.compiled?.actors || [], [{file_name: file.name}]);
          const keys = Object.keys(match.linked);
          if (keys.length !== 1 || match.ambiguous.length || match.unassigned.length) throw Error(`Immagine “${file.name}” ambigua: caricala dal riquadro del PNG corretto.`);
          actorKey = keys[0];
        }
        const binding = state.configuration.actor_bindings.find(x => x.actor_key === actorKey);
        if (!binding || !UUID.test(binding.base_bundle_id || '')) throw Error(`Scegli prima il profilo approvato per ${actorKey}.`);
        const result = await uploadMedia({file, kind: 'actor', actor_key: actorKey, base_bundle_id: binding.base_bundle_id, draft_id: state.draftId});
        if (!UUID.test(result?.media_id || '')) throw Error('Attestazione media non valida.');
        const item = {...result, actor_key: actorKey, file_name: file.name};
        state.uploads = state.uploads.filter(x => x.actor_key !== actorKey); state.uploads.push(item); binding.media_id = item.media_id;
      }
      state.message = 'Immagini attestate e associate ai PNG.';
      invalidatePreview(state);
    } finally { state.busy = false; render(); }
  }
  async function selectSpecificMap() {
    if (typeof chooseMap !== 'function') throw Error('Selettore mappa server non collegato.');
    state.busy = true; setMessage('Apro la configurazione della mappa…');
    try {
      const result = await chooseMap({draft_id: state.draftId, compiled: copy(state.compiled), current: copy(state.configuration.map)});
      if (!result) { state.message = 'Selezione mappa annullata.'; return; }
      if (!clean(result.template_key) || !Number.isSafeInteger(result.template_version) || result.template_version < 1) throw Error('Versione mappa non valida.');
      const detail = await rpc('mission_map_detail_v1', {p_template: result.template_key, p_version: result.template_version});
      if (detail?.schema_version !== 'mission-map-detail/1' || detail.status !== 'ready' || detail.selectable !== true || detail.spec?.template_key !== result.template_key || detail.template_version !== result.template_version) throw Error('Dettaglio mappa non selezionabile.');
      state.configuration.map = {...state.configuration.map, ...copy(result), mode: 'specific', spec: copy(detail.spec)};
      invalidatePreview(state); state.message = 'Mappa specifica collegata; l’anteprima server ne controllerà capienza e posizioni.';
    } finally { state.busy = false; render(); }
  }
  async function loadCatalog() {
    const catalog = await rpc('mission_rapid_catalog_v1', {});
    if (catalog?.schema_version !== 'mission-rapid-catalog/1' || !Array.isArray(catalog.bundles)) throw Error('Catalogo editor non disponibile.');
    state.catalog = catalog;
    const budget = catalog.runtime_budget || runtimeBudget;
    if (budget) state.configuration.budget = copy(budget);
  }
  async function compile() {
    if (state.busy) return;
    const errs = localBlockingErrors({...state, compiled: null});
    if (errs.some(x => x.code === 'PLOT_REQUIRED')) { state.message = errs[0].detail; return render(); }
    state.busy = true; state.compileRequest ||= makeUuid(); const stamp = ++epoch; render();
    try {
      const requested = await rpc('mission_rapid_compile_request_v1', {p_request: state.compileRequest, p_source: copy(state.source)});
      if (requested?.schema_version !== 'mission-rapid-compile-request/1') throw Error('Richiesta di compilazione non confermata.');
      state.draftId = requested.draft_id; state.controlVersion = requested.control_version; state.message = 'Compilazione in corso…'; render();
      let dispatchIssue = null;
      if (!state.compileDispatched) {
        state.compileDispatched = true;
        const dispatched = await dispatchCompiler(client, state.compileRequest);
        dispatchIssue = dispatched.error || null;
        if (dispatched.confirmed) { applyCompiled(state, dispatched.result); await loadCatalog(); state.message = 'Bozza pronta: correggi e approva prima dell’anteprima.'; return; }
      }
      for (let i = 0; i < maxPolls && stamp === epoch; i++) {
        const result = await rpc('mission_rapid_compile_state_v1', {p_request: state.compileRequest});
        if (result.state === 'draft') { applyCompiled(state, result, state.catalog); await loadCatalog(); state.message = 'Bozza pronta: correggi e approva prima dell’anteprima.'; return; }
        if (result.state === 'failed') throw Error('Compilazione rifiutata: ' + (result.failure_code || 'errore non specificato'));
        await new Promise(resolve => setTimeout(resolve, pollMs));
      }
      throw Error((dispatchIssue ? 'Risposta della compilazione non confermata. ' : '') + 'Usa “Riprendi compilazione”: verrà riletta la stessa richiesta senza una seconda chiamata IA.');
    } catch (error) { state.message = error.message; }
    finally { state.busy = false; render(); }
  }
  async function saveAndPreview() {
    if (state.busy) return;
    const errors = localBlockingErrors(state); if (errors.length) { state.message = 'Correggi gli errori locali prima dell’anteprima.'; state.preview = {schema_version: PREVIEW_SCHEMA, errors}; return render(); }
    state.busy = true; render();
    try {
      const saved = await rpc('mission_rapid_draft_save_v1', {p_draft: state.draftId, p_expected_version: state.controlVersion, p_document: buildDraftDocument(state)});
      if (saved?.schema_version !== 'mission-rapid-draft-save/1') throw Error('Salvataggio bozza non confermato.');
      state.controlVersion = saved.control_version;
      const preview = await rpc('mission_rapid_preview_v1', {p_draft: state.draftId, p_expected_version: state.controlVersion});
      if (preview?.schema_version !== PREVIEW_SCHEMA || preview.draft_id !== state.draftId || preview.draft_version !== state.controlVersion || !Array.isArray(preview.errors)) throw Error('Anteprima server non valida.');
      state.preview = preview; state.previewSeal = preview.preview_seal || null; state.dirty = false;
      state.message = preview.errors.length ? 'Anteprima bloccata: correggi gli errori indicati.' : 'Anteprima completa e sigillata. Puoi pubblicare.';
    } catch (error) { state.message = error.message; if (error.code === '40001') invalidatePreview(state); }
    finally { state.busy = false; render(); }
  }
  async function publish() {
    if (!canPublish(state)) return;
    state.busy = true; state.lastPublishRequest ||= makeUuid(); render();
    try {
      const result = await rpc('mission_rapid_publish_v1', {p_draft: state.draftId, p_expected_version: state.controlVersion, p_preview_seal: state.previewSeal, p_request: state.lastPublishRequest});
      if (result?.schema_version !== 'mission-rapid-publish-result/1' || result.state !== 'open' || !UUID.test(result.mission_id || '')) throw Error('Pubblicazione non confermata.');
      state.published = result; state.uncertainPublish = false; state.message = 'Missione pubblicata e aperta.'; notice('Missione pubblicata'); onPublished(copy(result));
    } catch (error) {
      if (error.code && (/^(22|23)/.test(error.code) || ['40001', '42501', '55000'].includes(error.code))) state.lastPublishRequest = null;
      else state.uncertainPublish = true;
      state.message = (state.uncertainPublish ? 'Esito non confermato: ripeti con la stessa richiesta. ' : 'Pubblicazione rifiutata. ') + error.message;
    } finally { state.busy = false; render(); }
  }
  function renderCompiled(root) {
    if (!state.compiled) return;
    const mission = section('Missione proposta'), meta = state.compiled.mission;
    mission.append(field('Titolo', input(meta.title, value => edit(() => meta.title = value))), field('Grado', choice(['D','C','B','A','S'], meta.grade, value => edit(() => meta.grade = value))), field('Partecipanti minimi', input(meta.team_min, value => edit(() => meta.team_min = Number(value)), {type:'number', min:'1', max:'4'})), field('Partecipanti massimi', input(meta.team_max, value => edit(() => meta.team_max = Number(value)), {type:'number', min:'1', max:'4'})));
    for (const [label, path] of [['Briefing pubblico', 'briefing_public'], ['Retroscena riservato', 'background_private'], ['Istruzioni Narratore', 'narrator_instructions'], ['Incipit', 'opening']]) mission.append(field(label, input(meta[path], value => edit(() => meta[path] = value), {rows: '3'})));
    mission.append(field('Villaggio', input(state.configuration.village, value => edit(() => state.configuration.village = value))), field('Tag trama', input(state.configuration.tag_trama, value => edit(() => state.configuration.tag_trama = value))));
    mission.append(field('Chat di ritrovo', (() => { const n = el('select'); n.append(el('option', 'Scegli…', {value: ''})); for (const x of state.catalog?.mission_creation?.locations || []) n.append(el('option', x.name || x.label || x.id, {value: x.id})); n.value = state.configuration.gathering_location_id; n.addEventListener('change', () => edit(() => state.configuration.gathering_location_id = n.value)); return n; })()));
    root.append(mission);
    const phases = section('Fasi e transizioni');
    state.compiled.phases.forEach((phase, i) => {
      const box = el('div', null, {class: 'mr-subcard'}); box.append(el('h4', `${i + 1}. ${phase.step_key}`), field('Titolo fase', input(phase.title, v => edit(() => phase.title = v))), field('Tipo', choice(['narrative','exploration','combat'], phase.kind, v => edit(() => phase.kind = v))), field('Obiettivo pubblico', input(phase.public_objective, v => edit(() => phase.public_objective = v), {rows: '2'})), field('Obiettivo riservato', input(phase.private_objective, v => edit(() => phase.private_objective = v), {rows: '2'})), field('Istruzioni di fase', input(phase.narrator_notes, v => edit(() => phase.narrator_notes = v), {rows: '2'})));
      for (const transition of phase.transitions || []) { const tr = el('div', null, {class:'mr-subcard'}); tr.append(el('strong', `Passaggio · ${transition.transition_key}`), field('Quando', input(transition.when, v => edit(() => transition.when = v))), field('Destinazione', choice([['','Conclusione / nessuna'],...state.compiled.phases.map(x=>[x.step_key,x.title||x.step_key])], transition.to_step_key || '', v => edit(() => transition.to_step_key = v || null))), field('Risultato pubblico', input(transition.public_result, v => edit(() => transition.public_result = v), {rows:'2'})), field('Nota riservata', input(transition.private_note, v => edit(() => transition.private_note = v), {rows:'2'}))); box.append(tr); }
      phases.append(box);
    }); root.append(phases);
    const actors = section('PNG proposti e immagini');
    for (const actor of state.compiled.actors) {
      const b = state.configuration.actor_bindings.find(x => x.actor_key === actor.actor_key), box = el('div', null, {class: 'mr-subcard'}); box.append(el('h4', actorLabel(actor)));
      for (const [label, path, rows] of [['Nome','display_name',null],['Ruolo','role',null],['Identità','identity','3'],['Personalità','personality','3'],['Comportamento','behavior','3']]) box.append(field(label,input(actor[path],v=>edit(()=>actor[path]=v),rows?{rows}:{})));
      for (const [label,path] of [['Conoscenze pubbliche','public_knowledge'],['Conoscenze riservate','private_knowledge'],['Limiti','limits']]) box.append(field(label,input((actor[path]||[]).join('\n'),v=>edit(()=>actor[path]=v.split('\n').map(clean).filter(Boolean)),{rows:'3'})));
      const bundle = el('select'); bundle.append(el('option', 'Scegli profilo approvato…', {value: ''})); for (const x of state.catalog?.bundles || []) bundle.append(el('option', `${x.display_name || x.bundle_id} · ${mechanicalSummary(x)}`, {value: x.bundle_id})); bundle.value = b.base_bundle_id; bundle.addEventListener('change', () => edit(() => b.base_bundle_id = bundle.value)); box.append(field('Profilo meccanico approvato', bundle));
      if (b.base_bundle_id) box.append(el('p', `Bozza meccanica proposta: ${mechanicalSummary((state.catalog?.bundles || []).find(x => x.bundle_id === b.base_bundle_id))}`));
      const media = el('select'); media.append(el('option', 'Scegli immagine attestata…', {value: ''})); for (const x of state.uploads.filter(x => x.actor_key === actor.actor_key)) media.append(el('option', x.file_name, {value: x.media_id})); media.value = b.media_id; media.addEventListener('change', () => bindUpload(actor.actor_key, media.value)); box.append(field('Immagine', media));
      const actorFile = el('input', null, {type: 'file', accept: 'image/png,image/jpeg,image/webp'}); actorFile.addEventListener('change', () => addActorUploads([...actorFile.files], actor.actor_key).catch(e => setMessage(e.message))); box.append(field('Carica e attesta per questo PNG', actorFile));
      const team = el('select'); for (const x of ['alleati', 'avversari', 'civili']) team.append(el('option', x, {value: x})); team.value = b.team; team.addEventListener('change', () => edit(() => b.team = team.value)); box.append(field('Schieramento', team));
      const approval = el('input', null, {type: 'checkbox'}); approval.checked = b.approved; approval.addEventListener('change', () => edit(() => b.approved = approval.checked)); box.append(field('Versione approvata dall’editore', approval)); actors.append(box);
    }
    const mediaInput = el('input', null, {type: 'file', accept: 'image/png,image/jpeg,image/webp', multiple: ''}); mediaInput.addEventListener('change', () => addActorUploads([...mediaInput.files]).catch(e => setMessage(e.message))); actors.prepend(field('Associa automaticamente immagini nominate come i PNG', mediaInput)); root.append(actors);
    const map = section('Mappa'); const mode = el('select'); for (const x of [['default10', 'Default 10×10'], ['specific', 'Immagine specifica']]) mode.append(el('option', x[1], {value: x[0]})); mode.value = state.configuration.map.mode; mode.addEventListener('change', () => edit(() => state.configuration.map.mode = mode.value)); map.append(field('Tipo', mode));
    if (state.configuration.map.mode === 'specific') map.append(button(state.configuration.map.template_key ? 'Cambia mappa configurata' : 'Scegli immagine e configura mappa', () => selectSpecificMap().catch(e => setMessage(e.message)), state.busy), el('p', state.configuration.map.template_key ? `${state.configuration.map.template_key} · versione ${state.configuration.map.template_version}` : 'Nessuna mappa specifica collegata.'), field('Nome', input(state.configuration.map.name, v => edit(() => state.configuration.map.name = v))), field('Dimensioni e oggetti importanti', input(state.configuration.map.description, v => edit(() => state.configuration.map.description = v), {rows: '3'})));
    root.append(map);
    const rules = section('Condizioni terminali'), ruleTypes=['victory','defeat','surrender_after_exchanges','escape','protect_subject','reach_position','survive_rounds'];
    for (const rule of state.compiled.terminal_rules || []) { const box=el('div',null,{class:'mr-subcard'}); box.append(el('h4',rule.rule_key),field('Tipo',choice(ruleTypes,rule.type,v=>edit(()=>{rule.type=v;rule.threshold=['surrender_after_exchanges','survive_rounds'].includes(v)?(rule.threshold||1):null;if(v==='victory')rule.outcome='success';if(v==='defeat')rule.outcome='failure';}))),field('Fase',choice(state.compiled.phases.map(x=>[x.step_key,x.title||x.step_key]),rule.phase_key,v=>edit(()=>rule.phase_key=v))),field('Soggetto PNG/oggetto',input(rule.subject_key||'',v=>edit(()=>rule.subject_key=clean(v)||null))),field('Soglia',input(rule.threshold??'',v=>edit(()=>rule.threshold=v===''?null:Number(v)),{type:'number',min:'1',max:'99'})),field('Esito',choice([['success','Successo'],['failure','Fallimento']],rule.outcome,v=>edit(()=>rule.outcome=v))),button('Rimuovi condizione',()=>edit(()=>state.compiled.terminal_rules=state.compiled.terminal_rules.filter(x=>x!==rule))));rules.append(box); }
    rules.append(button('Aggiungi condizione',()=>edit(()=>{let n=state.compiled.terminal_rules.length+1,key=`regola_${n}`;while(state.compiled.terminal_rules.some(x=>x.rule_key===key))key=`regola_${++n}`;state.compiled.terminal_rules.push({rule_key:key,phase_key:state.compiled.phases[0].step_key,type:'victory',subject_key:null,threshold:null,outcome:'success',transition_key:null});}))); root.append(rules);
  }
  function renderPreview(root) {
    if (!state.preview) return; const p = section('Anteprima obbligatoria');
    if (state.preview.errors?.length) renderErrors(p, state.preview.errors);
    else { p.append(el('h4', 'Incipit'), el('p', state.preview.incipit || ''), el('h4', 'Sequenza fasi')); for (const phase of state.preview.phases || []) p.append(el('p', `${phase.step_key} · ${phase.public_objective || ''}`)); p.append(el('h4', 'Schede PNG'), el('pre', JSON.stringify(state.preview.actors || [], null, 2)), el('h4', 'Immagini'), el('pre', JSON.stringify(state.preview.images || [], null, 2)), el('h4', 'Mappa e partecipanti'), el('pre', JSON.stringify(state.preview.map || {}, null, 2)), el('h4', 'Condizioni terminali'), el('pre', JSON.stringify(state.preview.terminal_rules || [], null, 2)), el('h4', 'Budget Narratore'), el('pre', JSON.stringify(state.preview.budget || {}, null, 2))); }
    root.append(p);
  }
  function render() {
    if (!host) return; host.replaceChildren(); host.classList.add('mission-rapid-editor');
    host.append(el('h2', 'Editor rapido missioni'), el('p', state.message || 'Inserisci trama, fasi e immagini. Il server mantiene l’autorità su meccaniche e pubblicazione.', {role: 'status', 'aria-live': 'polite'}));
    const source = section('Trama e immagini'); source.append(field('Trama', input(state.source.plot, v => edit(() => { state.source.plot = v; state.compileRequest = null; state.compileDispatched = false; }), {rows: '8'})), field('Indicazioni sulle fasi · una per riga', input(state.source.phase_hints.join('\n'), v => edit(() => { state.source.phase_hints = v.split('\n').map(clean).filter(Boolean); state.compileRequest = null; state.compileDispatched = false; }), {rows: '4'})), button(state.compileRequest ? 'Riprendi compilazione' : 'Compila bozza', compile, state.busy)); host.append(source);
    renderCompiled(host); renderPreview(host);
    if (state.compiled) { const actions = section('Controllo finale'); actions.append(button('Salva e genera anteprima', saveAndPreview, state.busy), button(state.uncertainPublish ? 'Verifica stessa pubblicazione' : 'Pubblica e apri missione', publish, !canPublish(state))); host.append(actions); }
  }
  async function mount(target, seed = {}) {
    if (!target?.isConnected) throw Error('Contenitore editor non disponibile.'); if (!allowed()) throw Error('Accesso riservato allo Staff.');
    host = target; state = createInitialState(seed); await loadCatalog(); render(); return api;
  }
  function dispose() { epoch++; if (host) host.replaceChildren(); host = null; }
  const api = {mount, dispose, getState: () => copy(state), compile, saveAndPreview, publish};
  return api;
}
