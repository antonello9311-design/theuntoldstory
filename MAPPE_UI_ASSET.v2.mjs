// Candidata isolata: non registra asset né genera URL pubblici.
export const VERSION = 'mission-map-asset-ui/2';
export const BUCKET = 'mission-map-images';
export const MAX_BYTES = 4 * 1024 * 1024;
const KEY = /^mission_map_[a-z0-9_]{1,48}$/;
const HASH = /^[a-f0-9]{64}$/;

export function rasterType(bytes, declaredType, size) {
  if (!Number.isSafeInteger(size) || size < 1 || size > MAX_BYTES) throw Error('Immagine oltre 4 MB o vuota.');
  const b = bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes);
  let type = null, ext = null;
  if (b.length >= 8 && [137, 80, 78, 71, 13, 10, 26, 10].every((x, i) => b[i] === x)) { type = 'image/png'; ext = 'png'; }
  else if (b.length >= 3 && b[0] === 255 && b[1] === 216 && b[2] === 255) { type = 'image/jpeg'; ext = 'jpg'; }
  else if (b.length >= 12 && String.fromCharCode(...b.slice(0, 4)) === 'RIFF' && String.fromCharCode(...b.slice(8, 12)) === 'WEBP') { type = 'image/webp'; ext = 'webp'; }
  if (!type || declaredType !== type) throw Error('Usa un file PNG, JPEG o WebP valido.');
  return { contentType: type, extension: ext };
}

export function mapAssetPath(templateKey, version, sha256, extension) {
  if (!KEY.test(templateKey) || !Number.isSafeInteger(version) || version < 1 || !HASH.test(sha256) || !['png', 'jpg', 'webp'].includes(extension))
    throw Error('Versione o impronta asset non valida.');
  return `mission-maps/${templateKey}/v${version}/${sha256}.${extension}`;
}

export function specWithMapAsset(spec, selected) {
  const copy = structuredClone(spec);
  if (!selected) { delete copy.source_asset_sha256; return copy; }
  if (!HASH.test(selected?.inspected?.sha256)) throw Error('Impronta sfondo non valida.');
  copy.source_asset_sha256 = selected.inspected.sha256;
  return copy;
}

export async function inspectMapRaster(file, { subtle = globalThis.crypto?.subtle, decode = globalThis.createImageBitmap } = {}) {
  if (!file || typeof file.arrayBuffer !== 'function') throw Error('Seleziona un’immagine.');
  if (file.size > MAX_BYTES || file.size < 1) throw Error('Immagine oltre 4 MB o vuota.');
  const bytes = new Uint8Array(await file.arrayBuffer());
  if (bytes.byteLength !== file.size) throw Error('Dimensione dell’immagine cambiata.');
  const kind = rasterType(bytes.subarray(0, 12), file.type, file.size);
  if (typeof decode === 'function') {
    const image = await decode(file);
    image?.close?.();
  }
  if (!subtle?.digest) throw Error('Impronta immagine non disponibile nel browser.');
  const digest = new Uint8Array(await subtle.digest('SHA-256', bytes));
  const sha256 = Array.from(digest, b => b.toString(16).padStart(2, '0')).join('');
  if (!HASH.test(sha256)) throw Error('Impronta immagine non valida.');
  return { sha256, contentType: kind.contentType, extension: kind.extension, size: file.size };
}

async function staffSession(client, identity, isStaff) {
  const principal = identity?.();
  if (!principal || !isStaff?.()) throw Error('Accesso staff non disponibile.');
  const session = await client.auth.getSession();
  const token = session?.data?.session?.access_token;
  if (session?.error || session?.data?.session?.user?.id !== principal || typeof token !== 'string' || !token ||
      identity?.() !== principal || !isStaff?.()) throw Error('Accesso cambiato.');
  return { principal, token };
}

function boundAsset(asset, inspected, templateKey, version) {
  const path = mapAssetPath(templateKey, version, inspected.sha256, inspected.extension);
  if (asset?.schema_version !== 'mission-map-asset-bind/1' || asset.template_key !== templateKey || asset.template_version !== version ||
      asset.bucket !== BUCKET || asset.background_path !== path || asset.background_mime !== inspected.contentType ||
      asset.background_sha256 !== inspected.sha256 || asset.status !== 'ready') throw Error('Collegamento asset non confermato.');
  return asset;
}

export async function uploadMapRasterViaEdge({ client, file, inspected, templateKey, version, identity, isStaff }) {
  mapAssetPath(templateKey, version, inspected?.sha256, inspected?.extension);
  if (inspected.size !== file?.size || inspected.contentType !== file?.type) throw Error('File cambiato dopo la verifica.');
  const { principal, token } = await staffSession(client, identity, isStaff);
  if (typeof client.functions?.invoke !== 'function') throw Error('Servizio di caricamento non disponibile.');
  const response = await client.functions.invoke('mission-map-upload', { body: file, headers: {
    'Content-Type': inspected.contentType, 'x-map-template-key': templateKey,
    'x-map-template-version': String(version), 'x-map-sha256': inspected.sha256,
    Authorization: `Bearer ${token}` } });
  if (identity?.() !== principal || !isStaff?.()) throw Error('Accesso cambiato dopo il caricamento: verifica lo stato della versione.');
  let result = response?.data;
  if (!result && typeof response?.error?.context?.json === 'function')
    result = await response.error.context.json().catch(() => null);
  if (identity?.() !== principal || !isStaff?.()) throw Error('Accesso cambiato dopo la risposta: verifica lo stato della versione.');
  if (result?.schema_version === 'mission-map-upload/1' && result.ok === false && result.retry === false) {
    const error = Error(`Il server non ha collegato lo sfondo (${String(result.code || 'errore')}).`);
    error.retry = false; throw error;
  }
  if (response?.error) throw Error('Risposta del caricamento non confermata: verifica lo stato della versione.');
  if (result?.schema_version !== 'mission-map-upload/1' || result.ok !== true || result.code !== 'READY' ||
      result.sha256 !== inspected.sha256 || result.bytes !== inspected.size) throw Error('Risposta del caricamento non valida.');
  return boundAsset(result.asset, inspected, templateKey, version);
}

export function backgroundUrlFromCatalog(client, row) {
  if (!row?.background_path) return null;
  const ext = row.background_mime === 'image/png' ? 'png' : row.background_mime === 'image/jpeg' ? 'jpg' : row.background_mime === 'image/webp' ? 'webp' : null;
  if ((row.background_bucket ?? row.bucket) !== BUCKET || !ext || row.background_path !== mapAssetPath(row.template_key, row.template_version, row.background_sha256, ext)) throw Error('Percorso sfondo del catalogo non valido.');
  const url = client.storage.from(BUCKET).getPublicUrl(row.background_path)?.data?.publicUrl;
  if (typeof url !== 'string' || !url) throw Error('URL sfondo non disponibile.');
  return url;
}

export function createMapAssetInput(host, { onSelected = () => {}, URLObject = globalThis.URL } = {}) {
  if (!host?.ownerDocument) throw Error('Contenitore asset non disponibile.');
  const doc = host.ownerDocument;
  const label = doc.createElement('label'); label.textContent = 'Immagine di sfondo · PNG, JPEG o WebP, massimo 4 MB';
  const input = doc.createElement('input'); input.type = 'file'; input.accept = 'image/png,image/jpeg,image/webp'; label.append(input);
  const preview = doc.createElement('img'); preview.alt = 'Anteprima locale dello sfondo scelto'; preview.hidden = true;
  preview.style.cssText = 'max-width:100%;max-height:300px;object-fit:contain';
  const status = doc.createElement('p'); status.setAttribute('role', 'status'); status.setAttribute('aria-live', 'polite');
  host.append(label, preview, status);
  let objectUrl = null, sequence = 0, selected = null;
  const clear = () => { if (objectUrl) URLObject.revokeObjectURL(objectUrl); objectUrl = null; preview.removeAttribute('src'); preview.hidden = true; selected = null; };
  input.addEventListener('change', async () => {
    const stamp = ++sequence; clear(); const file = input.files?.[0];
    if (!file) { status.textContent = 'Nessuna immagine selezionata.'; onSelected(null); return; }
    status.textContent = 'Verifico il file…';
    try {
      const inspected = await inspectMapRaster(file);
      if (stamp !== sequence) return;
      objectUrl = URLObject.createObjectURL(file); preview.src = objectUrl; preview.hidden = false;
      selected = { file, inspected }; status.textContent = 'Anteprima locale pronta. Il caricamento non è ancora avvenuto.';
      onSelected(selected);
    } catch (error) { if (stamp === sequence) { status.textContent = error.message; onSelected(null); } }
  });
  return { getSelected: () => selected, setDisabled: value => { input.disabled = !!value; },
    dispose() { sequence++; clear(); label.remove(); preview.remove(); status.remove(); } };
}

// La Edge attesta i byte e rende ready la versione. Nessun upload Storage dal client.
export function createMapAssetPanel(host, { client, identity, isStaff, templateKey, version, expectedSha256, selectedAsset = null, initial = null, onBound = () => {} }) {
  if (!host?.ownerDocument) throw Error('Pannello asset non disponibile.');
  if (!HASH.test(expectedSha256)) throw Error('Questa versione non attende uno sfondo: creane una nuova con il digest del file.');
  const doc = host.ownerDocument;
  const section = doc.createElement('section'); host.append(section);
  const heading = doc.createElement('h3'); heading.textContent = 'Sfondo della versione'; section.append(heading);
  const saved = doc.createElement('img'); saved.alt = 'Sfondo collegato alla mappa'; saved.hidden = true;
  saved.style.cssText = 'max-width:100%;max-height:300px;object-fit:contain'; section.append(saved);
  const status = doc.createElement('p'); status.setAttribute('role', 'status'); status.setAttribute('aria-live', 'polite'); section.append(status);
  const chooseHost = doc.createElement('div'); section.append(chooseHost);
  let selected = selectedAsset?.inspected?.sha256 === expectedSha256 ? selectedAsset : null, busy = false, terminal = false;
  const selector = createMapAssetInput(chooseHost, { onSelected(value) {
    selected = value?.inspected?.sha256 === expectedSha256 ? value : null;
    terminal = false; uploadButton.disabled = false;
    if (value && !selected) status.textContent = 'Il file non coincide con l’impronta fissata nella versione. Scegli quello originale.';
  } });
  const action = label => { const button = doc.createElement('button'); button.type = 'button'; button.textContent = label; section.append(button); return button; };
  const uploadButton = action('Verifica e collega lo sfondo');
  const checkButton = action('Verifica stato della versione');
  function showBound(row) {
    const url = backgroundUrlFromCatalog(client, row);
    saved.src = url || ''; saved.hidden = !url;
    uploadButton.disabled = !!url; selector.setDisabled(!!url);
    status.textContent = url ? 'Sfondo collegato alla versione.' : 'Questa versione non ha uno sfondo collegato.';
  }
  if (initial?.background_path) showBound(initial);
  else status.textContent = selected ? 'File selezionato prima del salvataggio: pronto per la verifica server.' : 'Seleziona il file originale: l’impronta è già fissata nella versione.';
  async function readReady() {
    const {principal} = await staffSession(client, identity, isStaff);
    const response = await client.rpc('mission_map_detail_v1', { p_template: templateKey, p_version: version });
    if (identity?.() !== principal || !isStaff?.()) throw Error('Accesso cambiato durante la verifica.');
    if (response?.error) throw response.error;
    const detail = response?.data;
    if (detail?.schema_version !== 'mission-map-detail/1' || detail.spec?.template_key !== templateKey || detail.template_version !== version)
      throw Error('Versione mappa non confermata.');
    if (detail.status !== 'ready' || detail.background_sha256 !== expectedSha256) return false;
    showBound({ ...detail, template_key: templateKey }); onBound(detail); return true;
  }
  uploadButton.onclick = async () => {
    if (busy || terminal || !selected) { status.textContent = 'Seleziona il file originale PNG, JPEG o WebP.'; return; }
    busy = true; uploadButton.disabled = checkButton.disabled = true; selector.setDisabled(true);
    try {
      const bound = await uploadMapRasterViaEdge({ client, file: selected.file, inspected: selected.inspected, templateKey, version, identity, isStaff });
      showBound(bound); onBound(bound);
    } catch (error) {
      const recovered = await readReady().catch(() => false);
      if (!recovered) {
        terminal = error.retry === false;
        status.textContent = terminal ? `${error.message} Crea una nuova versione o rivolgiti allo staff.` : `${error.message} Verifica lo stato prima di riprovare manualmente.`;
      }
    } finally { busy = false; uploadButton.disabled = terminal || !saved.hidden; checkButton.disabled = false; selector.setDisabled(!saved.hidden); }
  };
  checkButton.onclick = async () => {
    if (busy) return;
    busy = true; uploadButton.disabled = checkButton.disabled = true;
    try { if (!await readReady()) status.textContent = 'Versione ancora in attesa dello sfondo.'; }
    catch (error) { status.textContent = `Stato non confermato: ${error.message}`; }
    finally { busy = false; uploadButton.disabled = terminal || !saved.hidden; checkButton.disabled = false; }
  };
  return { showBound, dispose() { selector.dispose(); section.remove(); } };
}
