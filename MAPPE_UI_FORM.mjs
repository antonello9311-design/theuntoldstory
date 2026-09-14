// Candidata isolata. Nessuna RPC e nessuna modifica al sito live.
export const VERSION = 'mission-map-form/1';

const integer = (value, label, zero = false) => {
  const s = String(value ?? '').trim();
  if (!/^(0|[1-9][0-9]*)$/.test(s)) throw Error(`${label}: usa solo numeri interi.`);
  const n = Number(s);
  if (!Number.isSafeInteger(n) || (!zero && n === 0)) throw Error(`${label}: valore non valido.`);
  return n;
};

const decimal = (value, label) => {
  const s = String(value ?? '').trim().replace(',', '.');
  if (!/^(0|[1-9][0-9]*)(?:\.[0-9]+)?$/.test(s)) throw Error(`${label}: indica un numero valido.`);
  const n = Number(s);
  if (!Number.isFinite(n)) throw Error(`${label}: valore non valido.`);
  return n;
};

function objectSpec(row, index, width, height) {
  const label = String(row?.semantic_label ?? '').trim();
  if (!label) throw Error(`Oggetto ${index + 1}: indica un nome.`);
  const kind = row?.object_kind;
  if (!['blocker', 'substitution_anchor'].includes(kind)) throw Error(`Oggetto ${index + 1}: tipo non valido.`);
  const shape_kind = row?.shape_kind;
  const source = row?.shape ?? row;
  let shape;
  if (shape_kind === 'circle') {
    const cx = decimal(source?.cx, `Oggetto ${index + 1} · X`), cy = decimal(source?.cy, `Oggetto ${index + 1} · Y`);
    const radius = decimal(source?.radius, `Oggetto ${index + 1} · raggio`);
    if (radius <= 0 || cx - radius < 0 || cy - radius < 0 || cx + radius > width || cy + radius > height)
      throw Error(`Oggetto ${index + 1}: cerchio fuori mappa.`);
    shape = { cx, cy, radius };
  } else if (shape_kind === 'aabb') {
    const min_x = decimal(source?.min_x, `Oggetto ${index + 1} · X min`),
      min_y = decimal(source?.min_y, `Oggetto ${index + 1} · Y min`),
      max_x = decimal(source?.max_x, `Oggetto ${index + 1} · X max`),
      max_y = decimal(source?.max_y, `Oggetto ${index + 1} · Y max`);
    if (max_x <= min_x || max_y <= min_y || max_x > width || max_y > height)
      throw Error(`Oggetto ${index + 1}: rettangolo fuori mappa.`);
    shape = { min_x, min_y, max_x, max_y };
  } else throw Error(`Oggetto ${index + 1}: forma non valida.`);
  const substitutable = kind === 'substitution_anchor';
  return { object_key: `obj_${index + 1}`, object_kind: kind, semantic_label: label,
    shape_kind, shape, blocks_movement: true, substitutable,
    lifecycle: substitutable ? 'portable_single_use' : '', geometry_version: 1, is_impervious: false };
}

export function validateGeneralMapDraft(raw, roster = { pg: 1, png: 1 }) {
  const title = String(raw?.title ?? '').trim();
  const templateKey = String(raw?.template_key ?? '').trim();
  if (!title) throw Error('Dai un nome alla mappa.');
  const fullKey = templateKey.startsWith('mission_map_') ? templateKey : `mission_map_${templateKey}`;
  if (!/^mission_map_[a-z0-9_]{1,48}$/.test(fullKey)) throw Error('Identificativo mappa non valido.');
  const width_m = integer(raw?.width_m, 'Larghezza');
  const height_m = integer(raw?.height_m, 'Altezza');
  if (width_m < 2 || width_m > 50 || height_m < 2 || height_m > 50) throw Error('Le mappe di scontro misurano da 2 a 50 metri per asse.');
  const pg = integer(roster.pg, 'PG previsti');
  const png = integer(roster.png, 'PNG previsti', true);
  if (pg > 4 || png > 12) throw Error('La prima versione ammette fino a 4 PG e 12 PNG per scontro.');
  if (raw?.objects != null && !Array.isArray(raw.objects)) throw Error('Oggetti della mappa non validi.');
  if ((raw?.objects?.length ?? 0) > 32) throw Error('La mappa ammette fino a 32 oggetti.');
  const suggested_entries = [];
  const seen = new Set();
  for (const [kind, rows] of [['PG', raw?.pg_entries], ['PNG', raw?.png_entries]]) {
    if (rows != null && !Array.isArray(rows)) throw Error(`Ingressi ${kind} non validi.`);
    for (let i = 0; i < (rows?.length ?? 0); i++) {
      const row = rows[i];
      if (String(row?.x_m ?? '').trim() === '' && String(row?.y_m ?? '').trim() === '') continue;
      const x_m = integer(row?.x_m, `Ingresso ${kind} ${i + 1} · X`, true);
      const y_m = integer(row?.y_m, `Ingresso ${kind} ${i + 1} · Y`, true);
      const slot_key = `${kind.toLowerCase()}_${i + 1}`;
      if (seen.has(slot_key)) throw Error('Identificativo ingresso duplicato.');
      seen.add(slot_key);
      suggested_entries.push({ slot_key, actor_kind: kind, x_m, y_m });
    }
  }
  const objects = (raw?.objects ?? []).map((row, index) => objectSpec(row, index, width_m, height_m));
  const spec = { schema_version: 'arena-template/general-v1', template_key: fullKey,
    title, width_m, height_m, suggested_entries, objects };
  if (raw?.source_asset_sha256) spec.source_asset_sha256 = raw.source_asset_sha256;
  return spec;
}

const element = (doc, tag, label, parent) => {
  const n = doc.createElement(tag);
  if (label != null) n.textContent = label;
  parent.append(n);
  return n;
};

// Il chiamante integra solo dopo il contratto backend. onPrepare riceve un draft locale;
// l'eventuale diagnostica di capienza è mostrata solo se riferita allo stesso draft.
export function createGeneralMapForm(host, { initial = {}, roster = { pg: 1, png: 1 }, onPrepare } = {}) {
  if (!host?.ownerDocument) throw Error('Contenitore non disponibile.');
  const doc = host.ownerDocument;
  const form = element(doc, 'form', null, host);
  form.setAttribute('aria-label', 'Nuova versione della mappa');
  const status = element(doc, 'p', 'Capienza da verificare sul server.', form);
  status.setAttribute('role', 'status');
  status.setAttribute('aria-live', 'polite');
  const fields = {};
  const addField = (label, key, value, numeric = false) => {
    const wrapper = element(doc, 'label', label, form);
    const input = element(doc, 'input', null, wrapper);
    input.name = key;
    input.type = 'text';
    if (numeric) { input.inputMode = 'numeric'; input.pattern = '[0-9]*'; }
    input.value = String(value ?? '');
    fields[key] = input;
    return input;
  };
  addField('Nome', 'title', initial.title);
  addField('Identificativo (dopo mission_map_)', 'template_key', initial.template_key?.replace(/^mission_map_/, ''));
  addField('Larghezza in metri (2–50)', 'width_m', initial.width_m, true);
  addField('Altezza in metri (2–50)', 'height_m', initial.height_m, true);
  const keyPreview = element(doc, 'p', '', form);
  function updateKey() { keyPreview.textContent = `Chiave completa: mission_map_${fields.template_key.value.replace(/^mission_map_/, '')}`; }
  fields.template_key.addEventListener('input', updateKey); updateKey();
  element(doc, 'p', 'Ingressi suggeriti: facoltativi. Il server decide le posizioni effettive. Un corpo occupa 0,5 m di raggio.', form);
  const groups = { PG: [], PNG: [] };
  const objectRows = [];
  const containers = {};
  for (const kind of ['PG', 'PNG']) {
    const box = element(doc, 'fieldset', null, form);
    element(doc, 'legend', kind === 'PG' ? 'Ingressi PG' : 'Ingressi PNG', box);
    containers[kind] = box;
    const add = element(doc, 'button', 'Aggiungi ingresso suggerito', box);
    add.type = 'button';
    add.addEventListener('click', () => addEntry(kind));
  }
  const objectBox = element(doc, 'fieldset', null, form);
  element(doc, 'legend', 'Oggetti della mappa', objectBox);
  element(doc, 'p', 'Fino a 32 ostacoli o appigli per Sostituzione. Le forme possono avere misure decimali; il server controlla la geometria.', objectBox);
  const addObjectButton = element(doc, 'button', 'Aggiungi oggetto', objectBox);
  addObjectButton.type = 'button';
  addObjectButton.addEventListener('click', () => addObject());
  function addObject(row = {}) {
    if (objectRows.length >= 32) { status.textContent = 'La mappa ammette fino a 32 oggetti.'; return; }
    const wrap = element(doc, 'fieldset', null, objectBox);
    element(doc, 'legend', `Oggetto ${objectRows.length + 1}`, wrap);
    const control = (label, value = '') => {
      const holder = element(doc, 'label', label, wrap);
      const input = element(doc, 'input', null, holder);
      input.type = 'text'; input.value = String(value ?? '');
      return input;
    };
    const list = (label, values, value) => {
      const holder = element(doc, 'label', label, wrap), select = element(doc, 'select', null, holder);
      for (const [id, text] of values) { const opt = element(doc, 'option', text, select); opt.value = id; }
      select.value = value ?? values[0][0];
      return select;
    };
    const name = control('Nome', row.semantic_label);
    const kind = list('Uso', [['blocker', 'Ostacolo'], ['substitution_anchor', 'Appiglio per Sostituzione']], row.object_kind);
    const shape = list('Forma', [['circle', 'Cerchio'], ['aabb', 'Rettangolo']], row.shape_kind);
    const values = {};
    for (const [key, label] of [['cx', 'Centro X'], ['cy', 'Centro Y'], ['radius', 'Raggio'],
      ['min_x', 'X min'], ['min_y', 'Y min'], ['max_x', 'X max'], ['max_y', 'Y max']]) values[key] = control(label, row.shape?.[key] ?? row[key]);
    const updateShape = () => {
      for (const [key, input] of Object.entries(values)) input.parentElement.hidden = shape.value === 'circle' ? !['cx', 'cy', 'radius'].includes(key) : ['cx', 'cy', 'radius'].includes(key);
    };
    shape.addEventListener('change', updateShape); updateShape();
    const remove = element(doc, 'button', 'Rimuovi oggetto', wrap);
    remove.type = 'button';
    remove.addEventListener('click', () => { const i = objectRows.findIndex(x => x.wrap === wrap); if (i >= 0) objectRows.splice(i, 1); wrap.remove(); invalidate(); });
    objectRows.push({ wrap, name, kind, shape, values }); invalidate();
  }
  function addEntry(kind, row = {}) {
    const index = groups[kind].length + 1;
    const wrap = element(doc, 'div', null, containers[kind]);
    const input = (axis) => {
      const label = element(doc, 'label', `${kind} ${index} · ${axis.toUpperCase()}`, wrap);
      const n = element(doc, 'input', null, label);
      n.type = 'text'; n.inputMode = 'numeric'; n.pattern = '[0-9]*';
      n.value = String(row[`${axis}_m`] ?? '');
      return n;
    };
    const x = input('x'), y = input('y');
    const remove = element(doc, 'button', 'Rimuovi', wrap);
    remove.type = 'button';
    remove.addEventListener('click', () => { groups[kind] = groups[kind].filter(v => v.wrap !== wrap); wrap.remove(); invalidate(); });
    groups[kind].push({ wrap, x, y });
    invalidate();
  }
  function raw() { return { title: fields.title.value, template_key: fields.template_key.value,
    width_m: fields.width_m.value, height_m: fields.height_m.value,
    pg_entries: groups.PG.map(v => ({ x_m: v.x.value, y_m: v.y.value })),
    png_entries: groups.PNG.map(v => ({ x_m: v.x.value, y_m: v.y.value })),
    objects: objectRows.map(v => ({ semantic_label: v.name.value, object_kind: v.kind.value, shape_kind: v.shape.value,
      shape: Object.fromEntries(Object.entries(v.values).map(([k, field]) => [k, field.value])) })),
    source_asset_sha256: initial.source_asset_sha256 }; }
  let currentKey = null;
  function invalidate() { currentKey = null; status.textContent = 'Capienza da verificare sul server.'; }
  form.addEventListener('input', invalidate);
  const prepare = element(doc, 'button', 'Prepara la versione', form);
  prepare.type = 'submit';
  form.addEventListener('submit', async event => {
    event.preventDefault();
    try {
      const draft = validateGeneralMapDraft(raw(), roster);
      currentKey = JSON.stringify(draft);
      if (typeof onPrepare !== 'function') throw Error('Collegamento al server non ancora disponibile.');
      await onPrepare(draft, currentKey);
    } catch (error) { status.textContent = error.message; }
  });
  for (const kind of ['PG', 'PNG']) for (const row of initial[kind === 'PG' ? 'pg_entries' : 'png_entries'] ?? []) addEntry(kind, row);
  for (const row of initial.objects ?? []) addObject(row);
  return { dispose: () => form.remove(), draft: () => validateGeneralMapDraft(raw(), roster),
    setCapacity(key, result = {}) {
      if (key !== currentKey) return false;
      if (result.schema_version !== 'mission-map-preview/1') throw Error('Risposta capienza non valida.');
      const errors = Array.isArray(result.errors) ? result.errors.join('; ') : '';
      status.textContent = result.valid === false ? `Mappa non valida: ${errors || 'controlla la configurazione.'}` :
        result.can_fit === true ? 'Capienza verificata dal server per il gruppo indicato.' :
          result.can_fit === false ? `Mappa incompatibile con il gruppo: ${errors || 'non c’è spazio per tutti i combattenti.'}` :
            'Capienza da verificare sul server.';
      return true;
    } };
}
