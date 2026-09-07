from pathlib import Path
import hashlib, json, shutil, re
root = Path(__file__).resolve().parent
base = root.parents[2] / 'sito_live/scheda.html'
baseline = '9b8ce06bf7dbdf3388a8d4b152bcb8245478e37b43688ba7caa54c7bc8f6f795'
raw = base.read_bytes()
assert hashlib.sha256(raw).hexdigest() == baseline, 'STOP: baseline cambiata'
backup = root / '_precedenti/baseline'
backup.mkdir(parents=True, exist_ok=True)
if not (backup / 'scheda.html').exists(): shutil.copy2(base, backup / 'scheda.html')
s = raw.decode()
def replace(old, new):
    global s
    assert s.count(old) == 1, (old[:60], s.count(old))
    s = s.replace(old, new)
replace('<title>La tua scheda — The Untold Story</title>', '<title>La tua scheda — The Untold Story</title>\n<meta name="tus-build" content="SCHEDA-BACKGROUND-SICURO-001">')
replace('  .toast.err{background:var(--red-deep)}', '  .toast.err{background:var(--red-deep)}\n  .bg-frame{display:block;width:100%;height:520px;border:1px solid var(--edge);border-radius:8px;background:#fbf4e1}\n  .bg-actions{display:flex;flex-wrap:wrap;gap:8px;margin:10px 0}\n  #background-reader [hidden],#f-background[hidden]{display:none!important}\n  @media(max-width:640px){.bg-frame{height:440px}.bg-actions .mini-btn{white-space:normal}}')
replace('<textarea id="f-background" class="fin" style="min-height:180px" placeholder="Scrivi qui la storia del tuo personaggio…"></textarea></div>', '<textarea id="f-background" class="fin" aria-label="Modifica il background: testo o HTML protetto" style="min-height:180px" placeholder="Scrivi qui la storia del tuo personaggio…"></textarea>\n              <div id="background-reader"></div>\n              <details class="hint"><summary>Formattazione consentita</summary><p>Puoi usare paragrafi, titoli, grassetto, corsivo, elenchi, citazioni e sezioni espandibili con details/summary. Sono esclusi script, pulsanti personalizzati, moduli, link attivi, fogli di stile, classi e identificativi. Gli stili in linea consentono allineamento, enfasi, testo da 14 a 28 px e i colori #2b1d0e, #6a5231, #7c2413, #245a9c, #3f6d3a. Le immagini devono avere un indirizzo HTTPS diretto a PNG, JPG, WebP o GIF su i.postimg.cc o i.imgur.com, senza parametri. Limiti: 50.000 caratteri, 1.000 elementi, 30 livelli e 8 immagini; oltre questi limiti il contenuto viene mostrato come testo. Il sorgente salvato resta disponibile in Modifica.</p></details></div>')
purify = (root / 'node_modules/dompurify/dist/purify.min.js').read_text()
purify = re.sub(r'\n?//# sourceMappingURL=.*', '', purify)
purify = '/*\n' + (root / 'node_modules/dompurify/LICENSE').read_text() + '\n*/\n' + purify
assert '</script' not in purify.lower()
module = (root / 'candidato/background.js').read_text()
assert '</script' not in module.lower()
replace('  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>', '  <!-- DOMPurify 3.4.15, cure53, licenze Apache-2.0 OR MPL-2.0; copia locale fissata. -->\n  <script>\n' + purify + '\n</script>\n  <script>\n' + module + '\n</script>\n  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>')
replace('    function applyMode(){', "    var backgroundReader = window.TUSBackground.mount($('f-background'), $('background-reader'));\n    function applyMode(){")
replace("      ['f-element','f-background','f-off','f-prestavolto'].forEach(function(id){var el=$(id); if(el) el.disabled=!oEdit;});", "      ['f-element','f-background','f-off','f-prestavolto'].forEach(function(id){var el=$(id); if(el) el.disabled=!oEdit;});\n      backgroundReader.setEditable(oEdit);")
p = root / 'candidato/scheda.html'; p.write_text(s)
for name in ('LICENSE','LICENSE-MPL'):
    q = root / 'node_modules/dompurify' / name
    if q.exists(): shutil.copy2(q, root / 'candidato' / ('DOMPurify-' + name))
manifest = {'baseline_sha256':baseline,'baseline_remote':'db3306f8f8c8b8c0273c7bcfa0848614d142c903','baseline_check':'GitHub textarea integrale + LF finale MATCH','build':'SCHEDA-BACKGROUND-SICURO-001','dompurify':'3.4.15','files':{}}
for q in (p,root/'candidato/background.js',root/'build.py'):
    manifest['files'][str(q.relative_to(root))]={'bytes':q.stat().st_size,'sha256':hashlib.sha256(q.read_bytes()).hexdigest()}
(root / 'referti/MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps(manifest,indent=2))
