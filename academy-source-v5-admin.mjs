export const VERSION = 'academy-source-v5-admin/1';

const SOURCE = '5878822d-dc03-4ac2-ad0b-1547f0ab3fc0';
const BASE = '2e4d0697-9e18-4578-8f79-477f3b0edc50';
const SOURCE_SHA = '3c0c3f544c0576069702cb0205f66330afb3f38153cbf8936c9f05fb31409a04';
const DOCUMENT_SHA = 'e5086d5bc149fdc8f98ca85bc13bb1f81cd1350cc7bc48fe77a44d18e73bc962';
const EXPECTED_SELECTION = 4;
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function element(tag, text, attrs = {}) {
  const node = document.createElement(tag);
  if (text !== null) node.textContent = text;
  for (const [key, value] of Object.entries(attrs)) node.setAttribute(key, value);
  return node;
}

function assertDocument(doc) {
  if (!doc || typeof doc !== 'object' || Array.isArray(doc)
      || doc.schema_version !== 'mission-creation-document/1'
      || doc.mission?.title !== 'Prima della tempesta'
      || doc.mission?.grado !== 'D'
      || doc.mission?.direction_mode !== 'ai'
      || doc.mission?.team_min !== 1 || doc.mission?.team_max !== 2
      || doc.plan?.schema_version !== 'mission-generic-plan-document/1'
      || doc.plan?.base_plan_version_id !== BASE
      || doc.plan?.initial_step_key !== 'briefing'
      || !Array.isArray(doc.plan.steps) || doc.plan.steps.length !== 5
      || !Array.isArray(doc.plan.transitions) || doc.plan.transitions.length !== 8
      || !Array.isArray(doc.plan.definition?.scenes) || doc.plan.definition.scenes.length !== 5
      || !Array.isArray(doc.editorial?.scenes) || doc.editorial.scenes.length !== 5
      || !Array.isArray(doc.arenas) || doc.arenas.length !== 1
      || doc.arenas[0].step_key !== 'assalto_tattico')
    throw new Error('Documento diverso dalla revisione Suna v5 approvata. Nessuna modifica applicata.');
  const steps = new Map(doc.plan.steps.map(s => [s.step_key, s]));
  const scenes = new Map(doc.plan.definition.scenes.map(s => [s.step_key, s]));
  if (steps.size !== 5 || scenes.size !== 5 || steps.has('valutazione')
      || steps.get('assalto_simulato')?.kind !== 'narrative'
      || steps.get('assalto_tattico')?.kind !== 'mechanical'
      || steps.get('rapid_success')?.kind !== 'narrative'
      || (scenes.get('assalto_simulato')?.encounters || []).length !== 0
      || (scenes.get('assalto_tattico')?.encounters || []).length !== 1)
    throw new Error('Topologia della conclusione Suna v5 non valida. Nessuna modifica applicata.');
  return doc;
}

async function sha256(file) {
  const digest = await crypto.subtle.digest('SHA-256', await file.arrayBuffer());
  return Array.from(new Uint8Array(digest), b => b.toString(16).padStart(2, '0')).join('');
}

export function createAcademySourceV5Admin({ client, identity, isStaff }) {
  if (!client?.rpc || typeof identity !== 'function' || typeof isStaff !== 'function')
    throw new Error('Contesto Staff incompleto.');
  let doc = null;
  let request = null;
  let loadedActor = null;
  let busy = false;
  let status;
  let confirm;
  let apply;
  const message = text => { status.textContent = text; };
  const ready = () => { apply.disabled = busy || !doc || !confirm.checked || !isStaff() || identity() !== loadedActor; };

  async function load(file) {
    doc = null; request = null; loadedActor = null; confirm.checked = false; ready();
    if (!file || file.size < 1 || file.size > 128 * 1024) {
      message('Scegli il JSON locale della revisione Suna v5 (massimo 128 KB).');
      return;
    }
    try {
      const parsed = assertDocument(JSON.parse(await file.text()));
      const hash = await sha256(file);
      if (hash !== DOCUMENT_SHA) throw new Error('Impronta del documento diversa dalla candidata revisionata.');
      const actor = identity();
      if (!UUID.test(actor || '') || !isStaff()) throw new Error('Sessione Admin non disponibile.');
      const key = `academy-source-v5:${actor}:${SOURCE}:${hash}`;
      const saved = localStorage.getItem(key);
      request = UUID.test(saved || '') ? saved : crypto.randomUUID();
      if (!UUID.test(saved || '')) localStorage.setItem(key, request);
      doc = parsed; loadedActor = actor;
      message(`Suna · source v4 → v5 · 5 scene · 8 transizioni · 1 arena tattica. SHA-256 ${hash}. La selezione resta manuale finché non confermi.`);
    } catch (error) {
      message(`Documento non caricato: ${error.message}`);
    }
    ready();
  }

  async function submit() {
    if (!doc || !request || busy || !confirm.checked || !isStaff() || identity() !== loadedActor) return;
    busy = true; ready(); message('Sigillo e selezione in corso. Non ripetere la richiesta.');
    try {
      const { data, error } = await client.rpc('mission_revision_complete_v1', {
        p_mission: SOURCE,
        p_request: request,
        p_expected_mission_sha256: SOURCE_SHA,
        p_expected_selection_version: EXPECTED_SELECTION,
        p_document: doc,
      });
      if (error) throw error;
      if (data?.schema_version !== 'mission-creation-result/1'
          || data?.mission_id !== SOURCE
          || data?.version !== 5
          || data?.selection_control_version !== 5
          || data?.state !== 'configured'
          || !UUID.test(data?.plan_version_id || ''))
        throw new Error('Ricevuta non confermata: verifica il server prima di riprovare con la stessa richiesta.');
      message(`Revisione Suna v5 selezionata: ${data.plan_version_id}. La source resta chiusa; nessun collaudo è stato avviato.`);
      doc = null; confirm.checked = false;
    } catch (error) {
      message(`Esito non confermato: ${error.message}. Non creare una nuova richiesta; riseleziona lo stesso file e verifica il server.`);
    } finally { busy = false; ready(); }
  }

  function mount(root) {
    if (!root || !isStaff()) return;
    const card = element('section', null, { class: 'mr-card', 'aria-label': 'Revisione Suna Staff v5' });
    card.append(element('h3', 'Revisione Suna Staff v5'), element('p', 'Carica il documento JSON locale revisionato. Il testo riservato non viene incorporato nella pagina o salvato nel browser; solo la richiesta idempotente resta memorizzata.'));
    const label = element('label', 'Documento editoriale locale v5');
    const input = element('input', null, { type: 'file', accept: '.json,application/json' });
    input.addEventListener('change', () => { void load(input.files?.[0]); });
    label.append(input);
    const checkLabel = element('label', 'Confermo di sigillare e selezionare la revisione v5 della sola source Suna, senza avviare missioni.');
    confirm = element('input', null, { type: 'checkbox' });
    confirm.addEventListener('change', ready);
    checkLabel.prepend(confirm);
    apply = element('button', 'Sigilla e seleziona Suna v5', { type: 'button' });
    apply.disabled = true;
    apply.addEventListener('click', () => { void submit(); });
    status = element('p', 'In attesa del documento locale.', { role: 'status' });
    card.append(label, checkLabel, apply, status);
    root.append(card);
  }

  return { mount, version: VERSION };
}
