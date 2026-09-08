// Orchestratore candidato: l'adapter owner normalizza SOLO attestazioni server.
// Porte owner concordate; nessuna whitelist Staff o calcolo di gioco.
export const SESSION_VERSION = 'MISSION-EXAM-SESSION-001';
const isUUID = value => typeof value === 'string' && /^[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(value);
const isSHA = value => typeof value === 'string' && /^[a-f0-9]{64}$/i.test(value);
const insist = (value, code) => { if (!value) throw Error(code); };

// Le firme sono concordate con DB; questo adapter non apre o chiude una prova.
export function createSessionAdapter({client, getProva}) {
  async function rpc(name, args) {
    const response = await client.rpc(name, args);
    insist(!response?.error && response?.data != null, 'server_or_uncertain');
    return response.data;
  }
  async function read() {
    const prova = getProva(); insist(isUUID(prova), 'prova_missing');
    const raw = await rpc('esame_session_state', {p_prova:prova});
    insist(raw.ok === true && raw.prova === prova && raw.protected === true &&
      raw.version === SESSION_VERSION && typeof raw.player_ready === 'boolean' &&
      typeof raw.publishing === 'boolean' && typeof raw.closed === 'boolean' &&
      typeof raw.opening_published === 'boolean' &&
      (raw.error === null || typeof raw.error === 'string') &&
      (raw.receipt_id === null || isUUID(raw.receipt_id)), 'owner_state_invalid');
    let next;
    const draft = raw.draft;
    insist(draft === null || (isUUID(draft?.id) &&
      ['autorizzata','generazione','pronta','errore','pubblicata'].includes(draft.status)), 'draft_shape');
    if (raw.closed) next = 'complete';
    else if (raw.error !== null || draft?.status === 'errore') next = 'paused';
    else if (raw.publishing) next = 'waiting';
    else if (raw.player_ready) next = 'player';
    else if (draft === null) next = 'authorize';
    else if (draft.status === 'autorizzata') next = 'generate';
    else if (draft.status === 'pronta') {
      insist(draft.result_ok === true && draft.publishable === true &&
        draft.version === SESSION_VERSION && isSHA(draft.sha), 'draft_not_publishable');
      next = 'publish';
    } else next = 'waiting';
    if (['authorize','generate','publish'].includes(next)) insist(isUUID(raw.receipt_id), 'receipt_missing');
    return {authorized:true, protectedSession:true, sessionPolicy:'SESSION', prova,
      next, actionKey:raw.receipt_id, draft:draft?.id ?? null, sha:draft?.sha ?? null,
      budget:raw.budget, phase:raw.phase, status:raw.status, error:raw.error};
  }
  async function authorize(view) {
    const id = await rpc('esame_session_authorize', {p_prova:view.prova, p_ricevuta:view.actionKey});
    insist(isUUID(id), 'authorization_uncertain');
  }
  async function generate(view) {
    const response = await client.functions.invoke('mission_narratore_ai/exam-session', {body:{draft_id:view.draft}});
    const data = response?.data;
    insist(!response?.error && data?.bozza === view.draft && data.pubblicato === false &&
      isSHA(data.sha) && data.risultato?.ok === true && data.risultato.publishable === true &&
      data.risultato.validator_version === SESSION_VERSION, 'generation_or_uncertain');
  }
  async function publish(view) {
    insist(isSHA(view.sha), 'seal_missing');
    const result = await rpc('esame_session_publish', {p_bozza:view.draft, p_sha:view.sha});
    insist(result.ok === true && result.pubblicato === true, 'publication_or_uncertain');
  }
  return {read, authorize, generate, publish};
}

export function createSessionController({adapter, contextKey, onChange = () => {}}) {
  if (!adapter || typeof contextKey !== 'function') throw Error('adapter_required');
  let epoch = 0, owner = null, busy = false;
  let state = {stage:'idle', view:null, error:null};
  const attempted = new Set();
  const snapshot = () => ({...state, busy});
  const ownsContext = () => owner !== null && owner === contextKey();
  const notify = () => onChange(snapshot());
  function clear() {
    epoch++; owner = null; busy = false;
    state = {stage:'idle', view:null, error:null}; notify();
  }
  function validate(view) {
    // Interfaccia interna, NON shape dichiarata delle RPC live.
    if (!view || view.authorized !== true || view.protectedSession !== true ||
        view.sessionPolicy !== 'SESSION' || typeof view.prova !== 'string' || !view.prova ||
        !['authorize','generate','publish','player','waiting','paused','complete'].includes(view.next) ||
        !Number.isSafeInteger(view.budget?.used) || view.budget.used < 0 ||
        !Number.isSafeInteger(view.budget?.limit) || view.budget.limit < 0) throw Error('owner_state_invalid');
    if (['authorize','generate','publish'].includes(view.next) &&
        (typeof view.actionKey !== 'string' || !view.actionKey)) throw Error('action_key_missing');
    if (['generate','publish'].includes(view.next) &&
        (typeof view.draft !== 'string' || !view.draft)) throw Error('draft_missing');
    return view;
  }
  async function run(advance) {
    if (busy || (advance && state.stage === 'stopped')) return false;
    const key = contextKey();
    if (typeof key !== 'string' || !key) { clear(); return false; }
    if (owner !== null && owner !== key) { clear(); return false; }
    owner = key; busy = true;
    const ticket = epoch;
    const check = () => {
      if (ticket !== epoch || !ownsContext()) throw Error('context_changed');
    };
    const read = async () => {
      check(); const view = await adapter.read(); check();
      return validate(view);
    };
    notify();
    try {
      // Limite di sicurezza locale della catena, non rinnova budget server.
      for (let transitions = 0; transitions < 40; transitions++) {
        const view = await read();
        state = {stage:view.next, view, error:null}; notify();
        if (!advance || !['authorize','generate','publish'].includes(view.next)) return true;
        if (view.next !== 'publish' && view.budget.used >= view.budget.limit) throw Error('call_budget_reached');
        const actionKey = JSON.stringify([owner, view.prova, view.next, view.actionKey]);
        if (attempted.has(actionKey)) throw Error('action_already_attempted');
        attempted.add(actionKey); // Prima dell'attesa: nessun retry dopo risposta incerta.
        check();
        const operation = adapter[view.next];
        if (typeof operation !== 'function') throw Error('adapter_not_bound');
        await operation(view); check();
        // La risposta non avanza localmente il turno: si rilegge l'autorità owner.
      }
      throw Error('transition_limit');
    } catch (error) {
      if (ticket === epoch) {
        state = {stage:'stopped', view:null, error:ownsContext() ? String(error?.message || 'server_or_uncertain') : 'context_changed'};
      }
      return false;
    } finally {
      if (ticket === epoch) {
        busy = false;
        if (!ownsContext()) { epoch++; owner = null; state = {stage:'idle', view:null, error:null}; }
        notify();
      }
    }
  }
  // Mount/osservazione è sola lettura. L'integrazione decide quando resume è autorizzato.
  // Nessun avvio prova, timer, auto-close, vecchio Narratore o uscita reale.
  return {snapshot, ownsContext, observe:() => run(false), resume:() => run(true), clear};
}
