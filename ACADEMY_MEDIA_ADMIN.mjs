// Candidato Admin inerte: richiede MEDIA_BOOTSTRAP.sql e academy_media_attest_v1 revisionati.
export const RELEASE = 'academy-media-attest/2026-09-23.2';
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const ASSETS = Object.freeze({
  academy_kenta: {path:'ninja-book/academy_kenta_arai/r1/assets/kenta_portrait_v1.png',sha256:'700e069f967cd5441ca9adabc3e422c534904cd16c2207fab512fb89f0eaa14b',bytes:2607305,version:'b0b2e181-3ef4-4030-9a30-905f5479d1b3'},
  academy_nami: {path:'ninja-book/encounter_veil_02/r1/assets/portrait_v1.png',sha256:'7507ddaede8b77c13ed2716895729e80d1c4b8b9c0e60cf43c443b6b4aa59bde',bytes:2774288,version:'daef66b3-3660-443c-af23-6a7b8351e06e'},
  academy_otome: {path:'ninja-book/academy_otome_fujita/r1/assets/otome_portrait_v1.png',sha256:'bf32f4db2f3da0e6097ddb52eaf0594928c4dbc1a34e26be86547d6a0b310756',bytes:2621323,version:'c06afc18-c231-4ccb-a14b-e215f3db075b'},
  academy_tetsuna: {path:'ninja-book/encounter_veil_01/r1/assets/portrait_v1.png',sha256:'316fa42b3a7e85123d9b8e6027182f427a4330cf9b7ab664d665718d76e183b7',bytes:2525641,version:'e962b36d-69ba-41ff-9d9f-4b91934cc226'},
});
const MARKER_SUBJECTS = Object.freeze({
  academy_kenta:'c12c025c-897d-42d8-9dda-2b3d9138f190',
  academy_nami:'82afcf8c-0a2c-447a-b9a5-0cf6a8b067b7',
  academy_otome:'7c1c814b-e178-4b91-8804-3e7e0e2b5276',
  academy_tetsuna:'0aaecee9-7e33-4e91-9a95-af1d691f3a40',
});

function status(row, message, error=false) {
  const target = row.querySelector('[role=status]');
  target.textContent = message;
  target.style.color = error ? 'var(--red-deep)' : '';
}
async function sha256(file) {
  const digest = await crypto.subtle.digest('SHA-256', await file.arrayBuffer());
  return Array.from(new Uint8Array(digest), b => b.toString(16).padStart(2, '0')).join('');
}
function stateKey(key) { return 'tus_academy_media_' + key; }
function readState(key) {
  try {
    const state = JSON.parse(localStorage.getItem(stateKey(key)) || 'null');
    return state && state.asset_key === key && UUID.test(state.request_key) ? state : null;
  } catch { return null; }
}
function saveState(key, state) { localStorage.setItem(stateKey(key), JSON.stringify(state)); }
function clearState(key) { localStorage.removeItem(stateKey(key)); }
function validTicket(ticket, key, asset) {
  return ticket && ticket.schema_version === 'academy-media-ticket/1'
    && ticket.asset_key === key && ticket.template_version_id === asset.version
    && ticket.bucket === 'avatars' && ticket.object_path === asset.path
    && ticket.sha256 === asset.sha256 && ticket.bytes === asset.bytes
    && ticket.width_px === 1024 && ticket.height_px === 1536;
}
async function ticketFor(client, key, asset) {
  const result = await client.rpc('academy_media_ticket_v1', {p_asset_key:key});
  if (result.error) throw result.error;
  if (!validTicket(result.data, key, asset)) throw Error('Il contratto media del server non coincide con il PNG previsto.');
  return result.data;
}
async function upload(client, key, asset, file, requestKey) {
  if (!file || file.type !== 'image/png' || file.size !== asset.bytes)
    throw Error('Seleziona il PNG esatto previsto per questo personaggio.');
  if (await sha256(file) !== asset.sha256)
    throw Error('Il contenuto del PNG non coincide con l’asset approvato.');
  const result = await client.functions.invoke('academy_media_attest_v1', {
    body:file,
    headers:{'Content-Type':'image/png','x-ac-asset-key':key,'x-ac-request-key':requestKey,'x-ac-expected-release':RELEASE},
  });
  if (result.error) throw result.error;
  const data = result.data;
  if (!data || data.schema_version !== 'academy-media-registration/1' || data.asset_key !== key
    || data.template_version_id !== asset.version || data.sha256 !== asset.sha256
    || data.state !== 'review' || data.active !== false || !UUID.test(data.media_id || ''))
    throw Error('La registrazione del PNG non è verificabile.');
  return data;
}
async function complete(client, row) {
  const key = row.getAttribute('data-academy-media'), asset = ASSETS[key];
  const button = row.querySelector('button'), input = row.querySelector('input[type=file]');
  if (!asset || !button || !input) return;
  button.disabled = true;
  status(row, 'Verifica dello stato server…');
  try {
    let ticket = await ticketFor(client, key, asset);
    if (ticket.registered === true && ticket.active === true && ticket.media_state === 'approved') {
      clearState(key); status(row, 'Ritratto collegato e approvato.'); return;
    }
    let saved = readState(key);
    if (ticket.registered !== true) {
      const requestKey = saved?.request_key || crypto.randomUUID();
      saved = {asset_key:key, request_key:requestKey, media_id:null, approval_key:null};
      saveState(key, saved);
      status(row, 'Caricamento attestato senza sovrascrittura…');
      const registration = await upload(client, key, asset, input.files[0], requestKey);
      saved.media_id = registration.media_id;
      saveState(key, saved);
      ticket = await ticketFor(client, key, asset);
    }
    if (ticket.registered !== true || !UUID.test(ticket.media_id || '')
      || ticket.media_state !== 'review' || ticket.active !== false)
      throw Error('Il media è in uno stato inatteso; non viene approvato.');
    if (saved?.media_id && saved.media_id !== ticket.media_id)
      throw Error('La ripresa non coincide con il media registrato.');
    const approvalKey = saved?.approval_key || crypto.randomUUID();
    saveState(key, {asset_key:key, request_key:ticket.request_key, media_id:ticket.media_id, approval_key:approvalKey});
    status(row, 'Approvazione nel Ninja Book…');
    const args = {p_media:ticket.media_id,p_template_version:asset.version,p_expected_control_version:Number(ticket.control_version),p_request_key:approvalKey};
    const approved = await client.rpc('nb_admin_media_approve', args);
    if (approved.error || approved.data?.media_id !== ticket.media_id || approved.data?.state !== 'approved' || approved.data?.active !== true)
      throw approved.error || Error('Approvazione non verificabile.');
    const finalTicket = await ticketFor(client, key, asset);
    if (finalTicket.media_id !== ticket.media_id || finalTicket.media_state !== 'approved' || finalTicket.active !== true)
      throw Error('Il server non conferma il media approvato.');
    clearState(key); status(row, 'Ritratto collegato e approvato.');
  } catch (error) {
    status(row, error?.message || 'Operazione incompleta. Ripeti senza cambiare PNG.', true);
  } finally { button.disabled = false; }
}

export function bindAcademyMediaPanel({client, role, principalId}) {
  const nav = document.getElementById('academy-media-nav');
  const page = document.getElementById('academy-media-page');
  if (!nav || !page) return;
  const admin = role === 'admin';
  nav.hidden = !admin;
  page.hidden = !admin;
  if (!admin || !UUID.test(principalId || '') || page.dataset.bound === '1') return;
  page.dataset.bound = '1';
  let markerEditor;
  page.addEventListener('click', event => {
    const row = event.target.closest('[data-academy-media]');
    if (row && event.target.closest('[data-academy-upload]')) complete(client, row);
    if (row && event.target.closest('[data-academy-marker]')) {
      const key = row.getAttribute('data-academy-media');
      if (!Object.hasOwn(MARKER_SUBJECTS, key) || !window.TUSMapFigures?.createMapFigureEditor) return;
      markerEditor ||= window.TUSMapFigures.createMapFigureEditor({client,document,identity:() => ({principal_id:principalId})});
      markerEditor.open('nb_template', MARKER_SUBJECTS[key]);
    }
  });
  for (const row of page.querySelectorAll('[data-academy-media]')) {
    const key = row.getAttribute('data-academy-media');
    ticketFor(client, key, ASSETS[key]).then(ticket => {
      status(row, ticket.registered && ticket.active && ticket.media_state === 'approved'
        ? 'Ritratto collegato e approvato.' : ticket.registered ? 'Registrato: manca l’approvazione.' : 'Ritratto PNG da caricare.');
    }).catch(() => status(row, 'Stato non disponibile: verifica l’installazione media.', true));
  }
}
