// Componente di authoring isolato: raccoglie scelte Staff, senza RPC, provider o certificazione.
const STATS = Object.freeze([
  ['taijutsu','Taijutsu'],['ninjutsu','Ninjutsu'],['genjutsu','Genjutsu'],['forza','Forza'],
  ['velocita','Velocità'],['mente','Mente'],['resistenza','Resistenza'],['fuuinjutsu','Fūinjutsu']
]);
const SOURCES = new Set(['jutsu','clan_techniques']);
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const SHA = /^[0-9a-f]{64}$/i;
const INT4_MAX = 2147483647;
const node = (tag, text = '') => { const el = document.createElement(tag); el.textContent = text; return el; };
const label = (title, control) => { const el = node('label'); el.append(node('span',title),control); return el; };
const option = (value, title) => { const el = node('option',title); el.value = value; return el; };
const refKey = ref => `${ref.source}:${ref.id}`;
function catalogChoices(raw) {
  if (!raw || !SHA.test(raw.catalog_digest || '')) throw Error('Catalogo Combat non attestato.');
  const refs = kind => {
    const source = raw[kind];
    if (!Array.isArray(source)) throw Error(`Catalogo ${kind} non valido.`);
    // Archivio e is_active non qualificano tecniche o abilità per i PNG.
    // Il view model riceve il flag solo dalla proiezione server del consumer Combat PNG.
    const items = source.filter(x => x?.available === true && x.qualified_for_png_combat === true);
    if (items.some(x => !SOURCES.has(x?.source) || !UUID.test(x.id || '') || typeof x.label !== 'string' || !x.label.trim() || !SHA.test(x.definition_digest || ''))) throw Error(`Catalogo ${kind} non valido.`);
    if (new Set(items.map(refKey)).size !== items.length) throw Error(`Catalogo ${kind} duplicato.`);
    return items;
  };
  const named = kind => {
    const items = raw[kind];
    if (!Array.isArray(items) || items.some(x => typeof x?.value !== 'string' || !x.value.trim() || typeof x.label !== 'string' || !x.label.trim() || x.available !== true)) throw Error(`Catalogo ${kind} non valido.`);
    if (new Set(items.map(x => x.value)).size !== items.length) throw Error(`Catalogo ${kind} duplicato.`);
    return items;
  };
  return {catalog_digest:raw.catalog_digest,techniques:refs('techniques'),abilities:refs('abilities'),clans:named('clans'),elements:named('elements')};
}
function integer(text) {
  if (!/^-?\d+$/.test(String(text).trim())) return null;
  const value = Number(text);
  return Number.isSafeInteger(value) ? value : null;
}

// `choices` è un view model attestato dal futuro adapter server, non un payload Builder.
// `onChange` conserva la bozza nel controller proprietario; questo modulo non salva nulla.
export function mountNpcCombatPanel(host, {choices = null, initial = null, onChange = null, reviewHost = null} = {}) {
  if (!(host instanceof Element)) throw Error('Contenitore PNG mancante.');
  const catalog = choices == null ? null : catalogChoices(choices);
  const editable = Boolean(catalog && typeof onChange === 'function');
  const state = {
    combat:initial?.combat === true,
    stats:Object.fromEntries(STATS.map(([key]) => [key, initial?.stats?.[key] == null ? '' : String(initial.stats[key])])),
    vita_max:initial?.vita_max == null ? '' : String(initial.vita_max),
    chakra_max:initial?.chakra_max == null ? '' : String(initial.chakra_max),
    technique_refs:Array.isArray(initial?.technique_refs) ? initial.technique_refs.filter(x => SOURCES.has(x?.source) && UUID.test(x.id || '')).map(x => ({source:x.source,id:x.id})) : [],
    ability_refs:Array.isArray(initial?.ability_refs) ? initial.ability_refs.filter(x => SOURCES.has(x?.source) && UUID.test(x.id || '')).map(x => ({source:x.source,id:x.id})) : [],
    clan_ref:initial?.clan_ref ?? null,
    chakra_element_ref:initial?.chakra_element_ref ?? null
  };
  let mounted=false;
  const panel=node('section');panel.className='nbe-card mf-npc-combat-panel';
  panel.append(node('h3','Scheda Combat'));
  panel.append(node('p','Opzionale per i PNG narrativi. Per un combattente scegli statistiche, tecniche e abilità qualificate per i PNG, clan ed elemento del chakra. I valori non seguono il livello dei PG.'));
  const toggle=node('input');toggle.type='checkbox';toggle.checked=state.combat;toggle.disabled=!editable;
  panel.append(label('Questo PNG può combattere',toggle));
  const body=node('div');body.className='mf-npc-combat-fields';panel.append(body);
  const status=node('p');status.className='nbe-status';status.setAttribute('role','status');panel.append(status);
  const clearStale=node('button','Rimuovi scelte non disponibili');clearStale.type='button';clearStale.hidden=true;panel.append(clearStale);
  const review=reviewHost instanceof Element ? node('section') : null;
  if (review) { review.className='nbe-card mf-npc-combat-review';review.append(node('h3','Riepilogo scheda Combat'));reviewHost.append(review); }
  const renderReview = () => {
    if (!review) return;
    review.replaceChildren(node('h3','Riepilogo scheda Combat'));
    if (!state.combat) { review.append(node('p','PNG narrativo: nessuna scheda Combat richiesta.'));return; }
    const stats=STATS.map(([key,title]) => `${title}: ${state.stats[key] || '—'}`).join(' · ');
    review.append(node('p',stats));
    review.append(node('p',`PV massimi: ${state.vita_max || '—'} · Chakra massimo: ${state.chakra_max || '—'}.`));
    review.append(node('p',`Tecniche: ${state.technique_refs.length} · Abilità: ${state.ability_refs.length} · Clan: ${state.clan_ref || 'nessuno'} · Elemento: ${state.chakra_element_ref || 'nessuno'}.`));
    if (staleSelection()) review.append(node('p','La bozza contiene scelte non più disponibili o qualificate. Rimuovile prima della Review.'));
    review.append(node('p','L’approvazione narrativa e la certificazione del bundle Combat sono passaggi distinti.'));
  };
  const staleSelection = () => Boolean(catalog && (
    state.technique_refs.some(x => !catalog.techniques.some(y => refKey(y)===refKey(x))) ||
    state.ability_refs.some(x => !catalog.abilities.some(y => refKey(y)===refKey(x))) ||
    state.clan_ref !== null && !catalog.clans.some(x => x.value===state.clan_ref) ||
    state.chakra_element_ref !== null && !catalog.elements.some(x => x.value===state.chakra_element_ref)
  ));
  const snapshot = () => {
    if (!state.combat) return {combat:false};
    if (staleSelection()) return null;
    const stats={};
    for (const [key] of STATS) { const n=integer(state.stats[key]); if (n===null || n<0 || n>INT4_MAX) return null; stats[key]=n; }
    const vita_max=integer(state.vita_max),chakra_max=integer(state.chakra_max);
    if (vita_max===null || vita_max<1 || vita_max>INT4_MAX || chakra_max===null || chakra_max<0 || chakra_max>INT4_MAX) return null;
    return {combat:true,stats,vita_max,chakra_max,technique_refs:structuredClone(state.technique_refs),ability_refs:structuredClone(state.ability_refs),clan_ref:state.clan_ref,chakra_element_ref:state.chakra_element_ref,catalog_digest:catalog?.catalog_digest || null};
  };
  const changed = () => {
    renderReview();
    const value=snapshot();
    clearStale.hidden=!editable || !state.combat || !staleSelection();
    status.textContent=!editable ? 'La scheda Combat sarà disponibile dopo il collegamento del catalogo e del salvataggio.' :
      !state.combat ? 'PNG narrativo: nessuna scheda Combat richiesta.' :
      staleSelection() ? 'Una scelta non è più disponibile o qualificata: rimuovila prima della Review.' :
      state.combat && !value ? 'Inserisci statistiche non negative, PV massimi positivi e chakra massimo non negativo come interi rappresentabili.' :
      'Bozza Combat da sottoporre alla stessa Review del PNG.';
    if (editable && mounted) onChange(value ? structuredClone(value) : null);
  };
  const choiceList=(title,items,key) => {
    const group=node('fieldset');group.append(node('legend',title));
    if (!items.length) group.append(node('p',key === 'technique_refs' ? 'Nessuna tecnica collaudata e agganciata al Combat dei PNG è disponibile.' : 'Nessuna abilità qualificata per il Combat dei PNG è disponibile.'));
    for (const item of items) {
      const check=node('input');check.type='checkbox';check.value=refKey(item);
      check.checked=state[key].some(x => refKey(x)===check.value);check.disabled=!editable;
      check.addEventListener('change',() => {state[key]=items.filter(x => group.querySelector(`input[value="${refKey(x)}"]`)?.checked).map(x => ({source:x.source,id:x.id}));changed();});
      group.append(label(item.label,check));
    }
    return group;
  };
  const renderFields=() => {
    body.replaceChildren();body.hidden=!state.combat;
    if (!state.combat) {changed();return;}
    const grid=node('div');grid.className='nbe-grid';
    for (const [key,title] of STATS) {
      const input=node('input');input.type='text';input.inputMode='numeric';input.value=state.stats[key];input.disabled=!editable;
      input.addEventListener('input',() => {state.stats[key]=input.value;changed();});
      grid.append(label(title,input));
    }
    body.append(grid);
    const resources=node('div');resources.className='nbe-grid';
    for (const [key,title] of [['vita_max','PV massimi'],['chakra_max','Chakra massimo']]) {
      const input=node('input');input.type='text';input.inputMode='numeric';input.value=state[key];input.disabled=!editable;
      input.addEventListener('input',() => {state[key]=input.value;changed();});
      resources.append(label(title,input));
    }
    body.append(resources);
    const clan=node('select'),element=node('select');
    clan.append(option('','Nessun clan'),...(catalog?.clans || []).map(x=>option(x.value,x.label)));
    element.append(option('','Nessun elemento'),...(catalog?.elements || []).map(x=>option(x.value,x.label)));
    clan.value=state.clan_ref || '';element.value=state.chakra_element_ref || '';
    clan.disabled=element.disabled=!editable;
    clan.addEventListener('change',() => {state.clan_ref=clan.value || null;changed();});
    element.addEventListener('change',() => {state.chakra_element_ref=element.value || null;changed();});
    body.append(label('Clan',clan),label('Elemento del chakra',element));
    body.append(choiceList('Tecniche conosciute',catalog?.techniques || [],'technique_refs'));
    body.append(choiceList('Abilità',catalog?.abilities || [],'ability_refs'));
    changed();
  };
  clearStale.addEventListener('click',() => {
    if (!editable || !staleSelection()) return;
    state.technique_refs=state.technique_refs.filter(x => catalog.techniques.some(y => refKey(y)===refKey(x)));
    state.ability_refs=state.ability_refs.filter(x => catalog.abilities.some(y => refKey(y)===refKey(x)));
    if (state.clan_ref !== null && !catalog.clans.some(x => x.value===state.clan_ref)) state.clan_ref=null;
    if (state.chakra_element_ref !== null && !catalog.elements.some(x => x.value===state.chakra_element_ref)) state.chakra_element_ref=null;
    renderFields();
  });
  toggle.addEventListener('change',() => {state.combat=toggle.checked;renderFields();});
  host.append(panel);renderFields();mounted=true;
  return {snapshot,dispose:() => {panel.remove();review?.remove();}};
}
