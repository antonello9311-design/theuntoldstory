/* SCHEDA-BACKGROUND-SICURO-001. Il sorgente dell'autore non entra nel DOM della scheda. */
(function () {
  'use strict';
  var LIMIT = { chars: 50000, elements: 1000, depth: 30, images: 8 };
  var TAGS = ['p','br','h2','h3','h4','b','strong','i','em','u','s','ul','ol','li','div','span','blockquote','hr','img','details','summary'];
  var HOSTS = ['i.postimg.cc','i.imgur.com'];
  var purifier = window.DOMPurify && window.DOMPurify(window);
  var sources = new WeakMap();
  function imageURL(value) {
    // Solo URL assoluti di immagini statiche, niente query, credenziali o URL relativi.
    if (!/^https:\/\/(?:i\.postimg\.cc|i\.imgur\.com)\/[A-Za-z0-9_\/-]+\.(?:png|jpe?g|webp|gif)$/i.test(value || '')) return '';
    try { var u = new URL(value); return HOSTS.indexOf(u.hostname) !== -1 && !u.port && !u.username && !u.password && !u.search && !u.hash ? u.href : ''; } catch (_) { return ''; }
  }
  function safeStyle(value) {
    var out = [];
    String(value || '').split(';').forEach(function (part) {
      var bits = part.split(':'); if (bits.length !== 2) return;
      var key = bits[0].trim().toLowerCase(), v = bits[1].trim().toLowerCase();
      // Palette leggibile sul fondo chiaro comune; valori enumerati o numeri limitati.
      if (key === 'color' && /^(#2b1d0e|#6a5231|#7c2413|#245a9c|#3f6d3a)$/.test(v)) out.push(key + ':' + v);
      if (key === 'text-align' && /^(left|center|right|justify)$/.test(v)) out.push(key + ':' + v);
      if (key === 'font-size' && /^(1[4-9]|2[0-8])px$/.test(v)) out.push(key + ':' + v);
      if (key === 'font-weight' && /^(normal|bold|[4-7]00)$/.test(v)) out.push(key + ':' + v);
      if (key === 'font-style' && /^(normal|italic)$/.test(v)) out.push(key + ':' + v);
      if (key === 'text-decoration' && /^(none|underline|line-through)$/.test(v)) out.push(key + ':' + v);
    });
    return out.join(';');
  }
  if (purifier && purifier.isSupported) {
    purifier.addHook('uponSanitizeAttribute', function (node, data) {
      if (data.attrName === 'src') {
        if (node.nodeName === 'IMG') sources.set(node, imageURL(data.attrValue));
        data.keepAttr = false; // Anche prima del consenso nessun src viene inserito.
      } else if (data.attrName === 'style') {
        data.attrValue = safeStyle(data.attrValue); if (!data.attrValue) data.keepAttr = false;
      } else if (data.attrName === 'alt') {
        if (node.nodeName !== 'IMG') data.keepAttr = false;
        else data.attrValue = data.attrValue.slice(0, 160);
      } else if (data.attrName === 'open') {
        data.keepAttr = node.nodeName === 'DETAILS';
      }
    });
  }
  function compile(raw, showImages) {
    raw = String(raw || '');
    if (raw.length > LIMIT.chars) return { error: 'Background oltre 50.000 caratteri: mostrato come testo, senza eseguire codice.' };
    if (!purifier || !purifier.isSupported) return { error: 'Formattazione protetta non disponibile: mostrato soltanto il testo.' };
    try {
      var plain = !/<\/?[a-z][^>]*>/i.test(raw);
      sources = new WeakMap();
      var fragment;
      if (plain) { fragment = document.createDocumentFragment(); fragment.appendChild(document.createTextNode(raw || 'Il background non è ancora stato scritto.')); }
      else fragment = purifier.sanitize(raw, {
        ALLOWED_TAGS: TAGS, ALLOWED_ATTR: ['style','src','alt','open'],
        ALLOW_DATA_ATTR: false, ALLOW_ARIA_ATTR: false,
        ALLOWED_NAMESPACES: ['http://www.w3.org/1999/xhtml'],
        RETURN_DOM_FRAGMENT: true, SANITIZE_DOM: true, SANITIZE_NAMED_PROPS: true,
        FORBID_CONTENTS: ['script','style','iframe','object','embed','svg','math','template','head','title'],
        FORBID_TAGS: ['script','style','iframe','object','embed','svg','math','template','meta','link','base','form','input','button','select','textarea']
      });
      var nodes = Array.from(fragment.querySelectorAll('*')), images = 0, validImages = 0;
      if (nodes.length > LIMIT.elements) return { error: 'Background troppo complesso (oltre 1.000 elementi): mostrato come testo.' };
      for (var i = 0; i < nodes.length; i++) {
        var el = nodes[i], depth = 0, parent = el;
        while (parent && parent !== fragment) { depth++; parent = parent.parentNode; }
        if (depth > LIMIT.depth) return { error: 'Background troppo annidato (oltre 30 livelli): mostrato come testo.' };
        if (el.localName === 'img') {
          images++; if (images > LIMIT.images) return { error: 'Background con oltre 8 immagini: mostrato come testo.' };
          var url = sources.get(el) || '';
          if (url) validImages++;
          if (url && showImages === true) {
            el.setAttribute('referrerpolicy','no-referrer');
            el.setAttribute('crossorigin','anonymous');
            el.setAttribute('loading','lazy'); el.setAttribute('decoding','async');
            el.setAttribute('src', url);
          } else {
            var placeholder = document.createElement('p');
            placeholder.textContent = url ? '[Immagine esterna nascosta]' : '[Immagine esclusa: indirizzo non consentito]';
            el.replaceWith(placeholder);
          }
        }
      }
      // Serializzazione del solo frammento già filtrato, mai del sorgente originale.
      var holder = fragment.ownerDocument.createElement('div'); holder.appendChild(fragment);
      var csp = "default-src 'none'; script-src 'none'; style-src 'unsafe-inline'; img-src " + (showImages === true ? 'https://i.postimg.cc https://i.imgur.com' : "'none'") + "; connect-src 'none'; font-src 'none'; media-src 'none'; object-src 'none'; frame-src 'none'; base-uri 'none'; form-action 'none'";
      var css = 'html{color-scheme:light}body{margin:0;padding:18px;font:18px/1.65 Georgia,serif;color:#2b1d0e;background:#fbf4e1;overflow-wrap:anywhere;white-space:' + (plain ? 'pre-wrap' : 'normal') + '}*{box-sizing:border-box;max-width:100%}p,ul,ol,blockquote{margin:0 0 1em}h2,h3,h4{line-height:1.3;color:#7c2413;margin:1em 0 .5em}img{display:block;max-width:100%;max-height:480px;width:auto;height:auto;object-fit:contain;margin:14px auto}blockquote{border-left:3px solid #b79d6c;padding-left:16px}details{border:1px solid #b79d6c;border-radius:6px;padding:12px;margin:12px 0}summary{cursor:pointer;font-weight:bold;color:#7c2413}summary:focus-visible{outline:2px solid #245a9c}details[open]>summary{margin-bottom:12px}';
      return { images: validImages, html: holder.innerHTML, srcdoc: '<!doctype html><html lang="it"><head><meta http-equiv="Content-Security-Policy" content="' + csp + '"><meta name="referrer" content="no-referrer"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>' + css + '</style></head><body>' + holder.innerHTML + '</body></html>' };
    } catch (_) { return { error: 'Formattazione non leggibile in sicurezza: mostrato soltanto il testo.' }; }
  }
  function mount(source, host) {
    var last = null, imagesAllowed = false, textOnly = false;
    var info = document.createElement('p'); info.className = 'hint';
    var actions = document.createElement('div'); actions.className = 'bg-actions';
    var imagesButton = document.createElement('button'); imagesButton.type = 'button'; imagesButton.className = 'mini-btn';
    var textButton = document.createElement('button'); textButton.type = 'button'; textButton.className = 'mini-btn';
    var refreshButton = document.createElement('button'); refreshButton.type = 'button'; refreshButton.className = 'mini-btn'; refreshButton.textContent = 'Aggiorna anteprima';
    var frame = document.createElement('iframe'); frame.title = 'Background del personaggio'; frame.className = 'bg-frame'; frame.setAttribute('sandbox',''); frame.referrerPolicy = 'no-referrer';
    var fallback = document.createElement('textarea'); fallback.className = 'fin'; fallback.readOnly = true; fallback.rows = 12; fallback.setAttribute('aria-label','Background come testo');
    actions.append(imagesButton,textButton,refreshButton); host.append(info,actions,frame,fallback);
    function render() {
      var raw = source.value;
      if (raw !== last) { imagesAllowed = false; last = raw; }
      var result = compile(raw,imagesAllowed);
      var isText = textOnly || !!result.error;
      info.textContent = result.error || 'HTML protetto: script e stili non consentiti esclusi. Le immagini esterne restano nascoste finché scegli di mostrarle.';
      frame.hidden = isText; fallback.hidden = !isText;
      fallback.value = raw;
      if (isText) frame.removeAttribute('srcdoc'); else frame.srcdoc = result.srcdoc;
      imagesButton.hidden = isText || !result.images;
      imagesButton.textContent = imagesAllowed ? 'Nascondi immagini' : 'Mostra immagini esterne (' + result.images + ')';
      imagesButton.title = 'Carica immagini da Postimages o Imgur: il servizio riceverà il tuo indirizzo IP.';
      textButton.textContent = textOnly ? 'Mostra formattazione' : 'Leggi come testo';
      textButton.hidden = !!result.error;
    }
    imagesButton.addEventListener('click',function(){ imagesAllowed = !imagesAllowed; render(); });
    textButton.addEventListener('click',function(){ textOnly = !textOnly; imagesAllowed = false; render(); });
    refreshButton.addEventListener('click',function(){ imagesAllowed = false; render(); });
    source.addEventListener('input',function(){
      // Rimuove subito eventuali immagini già autorizzate; la nuova bozza si vede su richiesta.
      imagesAllowed = false; frame.removeAttribute('srcdoc'); frame.hidden = true; fallback.hidden = true;
      info.textContent = 'Testo modificato: premi Aggiorna anteprima per vedere il risultato protetto.';
      imagesButton.hidden = true;
    });
    return { setEditable: function(editable){
      source.hidden = !editable; refreshButton.hidden = !editable;
      imagesAllowed = false; render();
    }};
  }
  window.TUSBackground = Object.freeze({ compile: compile, mount: mount, limits: Object.freeze(LIMIT) });
})();
