import { createGeneralMapForm } from './MAPPE_UI_FORM.mjs';
import { BUCKET, createMapAssetInput, createMapAssetPanel, specWithMapAsset, backgroundUrlFromCatalog } from './MAPPE_UI_ASSET.v2.mjs?v=20260920-preview-fallback-1';

export const VERSION = 'mission-map-picker/default10-candidate-3';
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export function mapChoices(universal, privateCatalog, roster) {
  if (universal?.schema_version !== 'universal-arena-catalog/1' || !Array.isArray(universal.templates)) throw Error('Catalogo mappe non disponibile.');
  if (privateCatalog?.schema_version !== 'mission-map-catalog/1' || !Array.isArray(privateCatalog.maps)) throw Error('Catalogo versioni non disponibile.');
  const counts = Number(roster?.pg_count) + Number(roster?.png_count);
  if (!Number.isSafeInteger(counts) || roster.pg_count < 1 || roster.pg_count > 4 || roster.png_count < 0 || roster.png_count > 12) throw Error('Roster della fase non valido.');
  const known = new Map(privateCatalog.maps.map(row => [`${row.template_key}/${row.template_version}`, row]));
  return universal.templates.flatMap(template => {
    if (!template?.template_key || !Number.isInteger(template.template_version) || !Array.isArray(template.zones)) return [];
    const meta = known.get(`${template.template_key}/${template.template_version}`);
    if (template.template_key.startsWith('mission_map_') && meta?.selectable !== true) return [];
    const capacity = Number.isInteger(meta?.capacity_16) ? meta.capacity_16 : null;
    return template.zones.map(zone => ({ template_key: template.template_key,
      template_version: template.template_version, zone_key: zone.key,
      label: `${meta?.title || template.title} · ${zone.label} · ${template.width_m} × ${template.height_m} m`,
      capacity_16: capacity, can_fit: capacity == null ? null : counts <= capacity,
      background: meta || null }));
  });
}

export function preferredDefaultChoice(rows) {
  return rows.find(row => row.template_key === 'mission_map_default_10x10' && row.template_version === 1 && row.zone_key === 'arena' && row.can_fit === true)
    || rows.find(row => row.template_key === 'master_test_20x20_v1' && row.template_version === 1 && row.zone_key === 'arena' && row.can_fit !== false)
    || null;
}

export function createMissionMapPicker({ client, identity, isStaff, document: doc = globalThis.document }) {
  let epoch = 0, currentDialog = null, currentFinish = null, openingPrincipal = null;
  client.auth.onAuthStateChange((_event, session) => {
    if (currentFinish && session?.user?.id !== openingPrincipal) currentFinish(null);
  });
  function principal() { const id = identity?.(); return typeof id === 'string' && UUID.test(id) && isStaff?.() ? id : null; }
  async function rpc(name, args, expected, stamp) {
    if (principal() !== expected || epoch !== stamp) throw Error('Accesso cambiato: riapri il selettore.');
    const session = await client.auth.getSession();
    if (session?.error || session?.data?.session?.user?.id !== expected || principal() !== expected || epoch !== stamp) throw Error('Accesso cambiato: riapri il selettore.');
    const result = await client.rpc(name, args);
    if (principal() !== expected || epoch !== stamp) throw Error('Accesso cambiato: verifica prima di ripetere.');
    if (result?.error) throw result.error;
    return result?.data;
  }
  function pick(initial = null, title = '', roster = { pg_count: 1, png_count: 1 }) {
    currentFinish?.(null);
    const expected = principal();
    if (!expected) return Promise.reject(Error('Accesso staff non disponibile.'));
    openingPrincipal = expected;
    const stamp = ++epoch;
    return new Promise(resolve => {
      const dialog = doc.createElement('dialog');
      currentDialog = dialog;
      dialog.className = 'mission-map-picker';
      dialog.setAttribute('aria-label', 'Scegli o crea una mappa per lo scontro');
      dialog.style.cssText = 'width:min(900px,96vw);max-height:90vh;overflow:auto;padding:20px;background:#f1e6ca;color:#1d1206;border:2px solid #8a6f43;border-radius:9px';
      const heading = doc.createElement('h2'); heading.textContent = `Mappa e zona dello scontro${title ? ` · ${title}` : ''}`; dialog.append(heading);
      const note = doc.createElement('p'); note.textContent = `Roster previsto: ${roster.pg_count} PG e ${roster.png_count} PNG. Gli ingressi sono indicativi; il server decide le posizioni.`; dialog.append(note);
      const status = doc.createElement('p'); status.setAttribute('role', 'status'); status.setAttribute('aria-live', 'polite'); status.textContent = 'Caricamento mappe…'; dialog.append(status);
      const select = doc.createElement('select'); select.setAttribute('aria-label', 'Mappa e zona'); select.style.cssText = 'width:100%;min-height:44px'; dialog.append(select);
      const capacity = doc.createElement('p'); dialog.append(capacity);
      const savedBackground = doc.createElement('img'); savedBackground.alt = 'Sfondo registrato della mappa selezionata'; savedBackground.hidden = true;
      savedBackground.style.cssText = 'max-width:100%;max-height:250px;object-fit:contain'; dialog.append(savedBackground);
      const actions = doc.createElement('div'); actions.style.cssText = 'display:flex;gap:10px;flex-wrap:wrap;margin:16px 0'; dialog.append(actions);
      const button = (label, parent = actions) => { const b = doc.createElement('button'); b.type = 'button'; b.textContent = label; b.style.cssText = 'min-height:44px;padding:8px 14px'; parent.append(b); return b; };
      const choose = button('Usa questa mappa'), cancel = button('Annulla'); choose.disabled = true;
      const create = doc.createElement('details'); dialog.append(create);
      const summary = doc.createElement('summary'); summary.textContent = 'Crea una nuova versione di mappa'; create.append(summary);
      const formHost = doc.createElement('div'); create.append(formHost);
      const assetHost = doc.createElement('div'); create.append(assetHost);
      const pendingHost = doc.createElement('section'); dialog.append(pendingHost);
      const panelHost = doc.createElement('div'); dialog.append(panelHost);
      let form = null, assetInput = null, assetSelected = null, assetPanel = null,
        rows = [], privateCatalog = null, prepared = null, busy = false, uncertain = false;
      const active = () => currentDialog === dialog && epoch === stamp && principal() === expected;
      const finish = result => { if (currentDialog !== dialog) return; epoch++; currentDialog = null; currentFinish = null; openingPrincipal = null;
        form?.dispose(); assetInput?.dispose(); assetPanel?.dispose(); dialog.close(); dialog.remove(); resolve(result); };
      currentFinish = finish;
      cancel.onclick = () => { if (!busy) finish(null); };
      dialog.addEventListener('cancel', event => { event.preventDefault(); if (!busy) finish(null); });
      function refreshSelection() {
        const selected = rows[Number(select.value)];
        if (!selected) { choose.disabled = true; capacity.textContent = ''; savedBackground.hidden = true; savedBackground.removeAttribute('src'); return; }
        choose.disabled = selected.can_fit === false;
        if (copyVersion) copyVersion.disabled = !selected.template_key.startsWith('mission_map_');
        capacity.textContent = selected.can_fit === true ? `Capienza verificata: ${selected.capacity_16} corpi massimo.` :
          selected.can_fit === false ? `Mappa troppo piccola: massimo ${selected.capacity_16} corpi.` :
            'Capienza verificata dal server al salvataggio della missione.';
        if (Array.isArray(selected.background?.suggestion_warnings) && selected.background.suggestion_warnings.length)
          capacity.textContent += ` ${selected.background.suggestion_warnings.length} ingressi suggeriti saranno ignorati dal server.`;
        try {
          if (selected.background?.background_bucket && selected.background.background_bucket !== BUCKET) throw Error('Bucket dello sfondo non valido.');
          const url = selected.background ? backgroundUrlFromCatalog(client, selected.background) : null;
          savedBackground.hidden = !url;
          if (url) savedBackground.src = url; else savedBackground.removeAttribute('src');
        } catch (error) { savedBackground.hidden = true; savedBackground.removeAttribute('src'); choose.disabled = true; capacity.textContent = error.message; }
      }
      select.onchange = refreshSelection;
      choose.onclick = () => { const selected = rows[Number(select.value)]; if (!busy && selected && selected.can_fit !== false) finish(selected); };
      async function load(prefer = initial) {
        const [universal, versions] = await Promise.all([
          rpc('universal_arena_catalog_v1', {}, expected, stamp),
          rpc('mission_map_catalog_v1', {}, expected, stamp)]);
        if (!active()) return;
        privateCatalog = versions; rows = mapChoices(universal, versions, roster);
        pendingHost.replaceChildren();
        const pending = versions.maps.filter(row => row.status === 'pending_asset' && row.selectable === false);
        if (pending.length) {
          const title = doc.createElement('h3'); title.textContent = 'Versioni in attesa dello sfondo'; pendingHost.append(title);
          for (const row of pending) {
            const resume = button(`${row.title} · versione ${row.template_version} · collega immagine`, pendingHost);
            resume.onclick = async () => {
              if (!active() || busy) return;
              busy = true; status.textContent = 'Carico la versione in attesa…';
              try {
                const detail = await rpc('mission_map_detail_v1', { p_template: row.template_key, p_version: row.template_version }, expected, stamp);
                if (!active()) return;
                if (detail?.schema_version !== 'mission-map-detail/1' || detail.status !== 'pending_asset' || detail.spec?.template_key !== row.template_key || !detail.spec?.source_asset_sha256)
                  throw Error('Versione in attesa non confermata.');
                mountAssetPanel(row.template_key, row.template_version, detail.spec.source_asset_sha256);
                status.textContent = 'Seleziona il file originale e completa il collegamento.';
              } catch (error) { if (active()) status.textContent = error.message; }
              finally { busy = false; }
            };
          }
        }
        select.replaceChildren(); rows.forEach((row, i) => { const option = doc.createElement('option'); option.value = String(i); option.textContent = row.label; select.append(option); });
        let index = rows.findIndex(row => row.template_key === prefer?.template_key && row.template_version === prefer?.template_version && row.zone_key === prefer?.zone_key);
        if (index < 0 && !prefer) index = rows.indexOf(preferredDefaultChoice(rows));
        if (index < 0) index = rows.findIndex(row => row.can_fit === true);
        if (index < 0) index = rows.findIndex(row => row.can_fit !== false);
        select.value = String(index);
        refreshSelection();
        status.textContent = rows.length ? 'Scegli una mappa o crea una nuova versione.' : 'Nessuna mappa disponibile: crea una versione.';
      }
      function mountForm(initialSpec = {}) {
       form?.dispose(); assetInput?.dispose(); formHost.replaceChildren(); assetHost.replaceChildren(); prepared = null; assetSelected = null;
       const initialDraft = { ...initialSpec,
         pg_entries: (initialSpec.suggested_entries || []).filter(row => row.actor_kind === 'PG'),
         png_entries: (initialSpec.suggested_entries || []).filter(row => row.actor_kind === 'PNG') };
       form = createGeneralMapForm(formHost, { initial: initialDraft, roster: { pg: roster.pg_count, png: roster.png_count },
        onPrepare: async (draft, key) => {
          if (!active() || busy || uncertain) return;
          busy = true; prepared = null; status.textContent = 'Verifico geometria e capienza…';
          try {
            const selectedSha = assetSelected?.inspected?.sha256 || null;
            const spec = specWithMapAsset(draft, assetSelected);
            const preview = await rpc('mission_map_preview_v1', { p_spec: spec, p_pg_count: roster.pg_count, p_png_count: roster.png_count }, expected, stamp);
            if (!active() || !form.setCapacity(key, preview) || (assetSelected?.inspected?.sha256 || null) !== selectedSha) return;
            if (!preview.valid) { status.textContent = 'Correggi la mappa prima di creare la versione.'; return; }
            prepared = { draft: spec, key, preview, assetSha: selectedSha };
            status.textContent = preview.can_fit ? 'Mappa pronta per questa fase.' : 'Mappa valida, ma non compatibile con questo roster. Puoi salvarla per altre missioni.';
            if (Array.isArray(preview.suggestion_warnings) && preview.suggestion_warnings.length)
              status.textContent += ` ${preview.suggestion_warnings.length} ingressi suggeriti saranno ignorati dal server.`;
          } catch (error) { if (active()) status.textContent = error.message; }
          finally { busy = false; }
        } });
       assetInput = createMapAssetInput(assetHost, { onSelected(value) {
         assetSelected = value; prepared = null;
         status.textContent = value ? 'Sfondo pronto in anteprima locale. Verifica di nuovo la mappa prima di salvarla.' : 'Nessuno sfondo scelto. Verifica di nuovo la mappa.';
       } });
      }
      function mountAssetPanel(templateKey, version, sha256, selectedAsset = null) {
        assetPanel?.dispose(); panelHost.replaceChildren();
        assetPanel = createMapAssetPanel(panelHost, { client, identity, isStaff, templateKey, version,
          expectedSha256: sha256, selectedAsset, onBound() {
            load({ template_key: templateKey, template_version: version, zone_key: 'arena' })
              .catch(error => { if (active()) status.textContent = error.message; });
          } });
      }
      mountForm();
      const copyVersion = button('Copia la versione selezionata', create);
      copyVersion.onclick = async () => {
        const selected = rows[Number(select.value)];
        if (!active() || busy || uncertain || !selected?.template_key.startsWith('mission_map_')) return;
        busy = true; status.textContent = 'Carico la versione da modificare…';
        try {
          const result = await rpc('mission_map_detail_v1', { p_template: selected.template_key, p_version: selected.template_version }, expected, stamp);
          if (!active()) return;
          if (result?.schema_version !== 'mission-map-detail/1' || result.template_version !== selected.template_version || result.spec?.template_key !== selected.template_key) throw Error('Dettaglio mappa non valido.');
          mountForm(result.spec); create.open = true; status.textContent = 'Versione copiata. Per mantenere lo sfondo scegli di nuovo il file originale; poi verifica la nuova versione.';
        } catch (error) { if (active()) status.textContent = error.message; }
        finally { busy = false; }
      };
      const refresh = button('Rileggi il catalogo', create);
      refresh.onclick = async () => {
        if (!active() || busy) return;
        busy = true; status.textContent = 'Rileggo le versioni…';
        try { await load(); if (active()) uncertain = false; }
        catch (error) { if (active()) status.textContent = error.message; }
        finally { busy = false; }
      };
      const save = button('Salva nuova versione', create);
      save.onclick = async () => {
        if (!active() || busy || uncertain || !prepared || JSON.stringify(form.draft()) !== prepared.key ||
            (assetSelected?.inspected?.sha256 || null) !== prepared.assetSha) { status.textContent = 'Verifica la versione aggiornata prima di salvarla.'; return; }
        const latest = privateCatalog?.maps?.filter(row => row.template_key === prepared.draft.template_key).reduce((n, row) => Math.max(n, row.template_version), 0) ?? 0;
        busy = true; save.disabled = true; assetInput.setDisabled(true); status.textContent = 'Salvataggio versione…';
        try {
          const result = await rpc('mission_map_save_v1', { p_spec: prepared.draft, p_expected_version: latest }, expected, stamp);
          if (!active()) return;
          if (result?.schema_version !== 'mission-map-version/1' || result.template_key !== prepared.draft.template_key ||
              !Number.isInteger(result.template_version) || !['ready', 'pending_asset'].includes(result.status))
            throw Error('Risposta inattesa: rileggi il catalogo prima di ripetere.');
          await load({ template_key: result.template_key, template_version: result.template_version, zone_key: 'arena' });
          if (result.status === 'pending_asset') {
            if (!prepared.assetSha || !assetSelected) throw Error('La versione attende il file originale: selezionalo e riprendi il collegamento.');
            mountAssetPanel(result.template_key, result.template_version, prepared.assetSha, assetSelected);
            status.textContent = 'Versione salvata in attesa dello sfondo. Carica e collega il file per renderla selezionabile.';
          } else status.textContent = 'Versione pronta. Selezionala per questa fase.';
          prepared = null;
        } catch (error) { if (active()) { uncertain = true; prepared = null; status.textContent = `Salvataggio non confermato: ${error.message} Rileggi il catalogo prima di ripetere.`; } }
        finally { busy = false; save.disabled = false; assetInput.setDisabled(false); }
      };
      doc.body.append(dialog); dialog.showModal(); cancel.focus();
      load().catch(error => { if (active()) status.textContent = error.message; });
    });
  }
  async function defaultsFor(rosters) {
    const expected = principal(), stamp = epoch;
    if (!expected) throw Error('Accesso staff non disponibile.');
    if (!Array.isArray(rosters)) throw Error('Roster delle fasi non valido.');
    if (!rosters.length) return [];
    const [universal, versions] = await Promise.all([
      rpc('universal_arena_catalog_v1', {}, expected, stamp),
      rpc('mission_map_catalog_v1', {}, expected, stamp)]);
    if (principal() !== expected || epoch !== stamp) throw Error('Accesso cambiato: riapri la missione.');
    return rosters.map(roster => {
      const selected = preferredDefaultChoice(mapChoices(universal, versions, roster));
      if (!selected) throw Error('Nessuna mappa predefinita disponibile per la capienza della fase. Scegli una mappa.');
      return selected;
    });
  }
  return { pick, defaultsFor, dispose() { if (currentFinish) currentFinish(null); else epoch++; } };
}
