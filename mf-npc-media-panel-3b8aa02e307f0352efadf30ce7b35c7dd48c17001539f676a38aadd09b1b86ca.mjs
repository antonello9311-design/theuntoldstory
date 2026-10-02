// Pannello candidato per ritratto e sagoma PNG nello stesso Ninja Book.
const node=(tag,text='')=>{const x=document.createElement(tag);x.textContent=text;return x;};
const KINDS=[['portrait','Ritratto'],['marker','Sagoma per la mappa']];
const short=x=>`${String(x||'').slice(0,10)}…`;

export function mountNpcMediaPanel({host,reviewHost,adapter,role,getBinding,notice=()=>{}}={}){
  if(!(host instanceof Element)||!(reviewHost instanceof Element)||!adapter||typeof getBinding!=='function')
    throw Error('Pannello media PNG non configurato.');
  const card=node('section');card.className='nbe-card mf-npc-media-panel';
  card.append(node('h3','Ritratto e sagoma mappa'),node('p',
    'Prepara due immagini distinte per questo PNG. La selezione resta in attesa fino alla Review e all’approvazione Admin.'));
  const rows={},urls={portrait:null,marker:null};
  let state=null,binding=null,certification=null,certError='',busy=false,disposed=false;
  const status=node('p');status.className='nbe-status';status.setAttribute('role','status');
  const say=(message,error=false)=>{status.textContent=message;notice(message,error);};
  const read=node('button','Rileggi media PNG');read.type='button';
  const approval=node('div');approval.className='nbe-card mf-npc-media-review';
  approval.append(node('h3','Media del PNG'));
  const pairStatus=node('p');approval.append(pairStatus);
  const certificationStatus=node('p');approval.append(certificationStatus);
  const certify=node('button','Certifica PNG narrativo nel Builder');certify.type='button';approval.append(certify);
  const certifyCombat=node('button','Certifica PNG Combat nel Builder');certifyCombat.type='button';approval.append(certifyCombat);
  const selects={};
  for(const [kind,title] of KINDS){
    const row=node('div');row.className='nbe-subcard mf-npc-media-row';
    row.append(node('h4',title));
    const file=node('input');file.type='file';file.accept='image/png,image/jpeg,image/webp';
    file.setAttribute('aria-label',`${title} PNG`);
    const preview=node('img');preview.alt=`Anteprima locale ${title.toLowerCase()}`;preview.hidden=true;
    preview.style.cssText='max-width:180px;max-height:180px;object-fit:contain;margin:8px 0';
    const upload=node('button',`Registra ${title.toLowerCase()}`);upload.type='button';
    const expired=node('button','Nuovo ticket dopo scadenza');expired.type='button';expired.hidden=true;
    const info=node('p');info.className='nbe-help';
    row.append(file,preview,upload,expired,info);card.append(row);
    const label=node('label',`${title} registrato`),select=node('select');label.append(select);approval.append(label);
    selects[kind]=select;rows[kind]={file,preview,upload,expired,info};
    file.addEventListener('change',()=>{
      if(urls[kind])URL.revokeObjectURL(urls[kind]);urls[kind]=null;
      const selected=file.files?.[0];preview.hidden=!selected;
      if(selected){urls[kind]=URL.createObjectURL(selected);preview.src=urls[kind];}
      else preview.removeAttribute('src');
      render();
    });
    upload.addEventListener('click',()=>void act(async()=>{
      const selected=file.files?.[0];if(!selected)throw Error(`Scegli ${title.toLowerCase()} prima di registrare.`);
      await adapter.upload(kind,selected);await refresh();
      say(`${title} registrato come media pending. Attendi l’approvazione della coppia.`);
    }));
    expired.addEventListener('click',()=>void act(async()=>{
      adapter.resetExpired(kind);await refresh();say(`Ticket ${title.toLowerCase()} scaduto rimosso dal tentativo corrente. Seleziona il file per un nuovo ticket.`);
    }));
  }
  const approve=node('button','Approva ritratto e sagoma');approve.type='button';approve.className='nbe-admin';
  approval.append(approve);reviewHost.append(approval);card.append(read,status);host.append(card);
  const options=(kind)=>state?.tickets?.filter(t=>t.kind===kind&&t.registration&&
    t.narrative_content_sha256===binding?.content_sha256&&
    t.mechanical_template_id===(binding?.mechanical_template_id??null))||[];
  function render(){
    const editable=binding?.review_state==='draft'&&!busy;
    for(const [kind,title] of KINDS){
      const r=rows[kind],pending=adapter.pending(kind),items=options(kind),selected=selects[kind].value;
      r.file.disabled=!editable;r.upload.disabled=!editable||!r.file.files?.[0];
      r.expired.hidden=!pending?.expired;r.expired.disabled=busy;
      r.info.textContent=pending?.expired?'Ticket scaduto: scegli un nuovo tentativo.':
        pending&&!pending.registered?'Richiesta conservata: seleziona lo stesso file per riprovare.':
        items.length?`${items.length} ${title.toLowerCase()} registrato/i in attesa o approvati.`:
        'Nessun file registrato per questa versione e questo hash.';
      const select=selects[kind];select.replaceChildren(node('option','Seleziona media registrato'));
      select.firstElementChild.value='';
      for(const t of items){const opt=node('option',`${short(t.sha256)} · ${t.bytes} byte · ${short(t.request_key)}`);
        opt.value=t.request_key;select.append(opt);}
      if(items.some(t=>t.request_key===selected))select.value=selected;
      else if(state?.pair){const id=kind==='portrait'?state.pair.portrait_media_id:state.pair.marker_media_id;
        select.value=items.find(t=>t.media_id===id)?.request_key||'';}
      else if(items.length===1)select.value=items[0].request_key;
      select.disabled=busy||!items.length||Boolean(state?.pair&&state.current);
    }
    const current=Boolean(state?.current&&binding?.review_state==='approved'&&
      binding.current_version_id===binding.narrative_version_id);
    const paired=Boolean(current&&state?.pair?.state==='approved');
    pairStatus.textContent=paired?'Ritratto e sagoma approvati. Certificazione Builder e qualifica per la storia sono passaggi successivi.':
      current?'Scegli i due media registrati per l’approvazione Admin.':
      'Le immagini registrate restano pending fino all’approvazione narrativa della versione corrente.';
    approve.hidden=role!=='admin';
    approve.disabled=busy||role!=='admin'||!current||paired||
      !selects.portrait.value||!selects.marker.value;
    certificationStatus.textContent=!state?'Carica la scheda e i media PNG per verificare la certificazione.':
      certError||(!certification?
      'Certificazione Builder non disponibile per questa versione.':certification.bundle_kind==='combat'?({
        review:'Scheda Combat ancora in Review. Nessun bundle selezionabile.',
        incomplete:'Scheda o dipendenze Combat incomplete. Nessun bundle selezionabile.',
        media_pending:'Attendi ritratto e sagoma approvati. Nessun bundle selezionabile.',
        ready:'Versione Combat e media verificate: puoi chiedere la certificazione Builder.',
        adopted:'Bundle Combat adottato dal Builder, ma non ancora idoneo agli scontri: attendi la qualifica Combat server.'
      })[certification.status]:({
        review:'Versione narrativa ancora in Review. Nessun bundle selezionabile.',
        incomplete:'Scheda narrativa incompleta o versione cambiata. Nessun bundle selezionabile.',
        media_pending:'Attendi ritratto e sagoma approvati. Nessun bundle selezionabile.',
        ready:'Versione narrativa e media verificati: puoi chiedere la certificazione Builder.',
        adopted:'Bundle narrativo adottato dal server. Nell’Archivio resta autonomo; nell’editor scegli una storia solo dal catalogo qualificato.'
      })[certification.status]);
    certify.hidden=certification?.bundle_kind!=='narrative'||certification.status==='adopted';
    certify.disabled=busy||certification?.status!=='ready'||!paired;
    certifyCombat.hidden=certification?.bundle_kind!=='combat'||certification.status==='adopted';
    certifyCombat.disabled=busy||certification?.status!=='ready'||!paired;
    read.disabled=busy;
  }
  async function refresh(){
    if(disposed)return false;
    try{binding=await getBinding();state=await adapter.load();}
    catch(error){state=null;certification=null;certError='';render();say(error?.message||'Media PNG non disponibili.',true);return false;}
    certification=null;certError='';
    try{certification=await adapter.certificationStatus();}
    catch(error){certError=error?.message||'Certificazione PNG non disponibile.';}
    render();return true;
  }
  async function act(action){
    if(busy||disposed)return;busy=true;render();
    try{await action();}catch(error){say(error?.message||'Operazione media PNG non completata.',true);}
    finally{busy=false;render();}
  }
  read.addEventListener('click',()=>void act(refresh));
  certify.addEventListener('click',()=>void act(async()=>{
    await adapter.certifyNarrative();
    if(!await refresh()||certification?.status!=='adopted')
      throw Error('Certificazione inviata: rileggi lo stato della stessa richiesta.');
    say('PNG narrativo adottato. Resta autonomo nell’Archivio; per usarlo in una storia aggiorna il catalogo qualificato e scegli le fasi.');
  }));
  certifyCombat.addEventListener('click',()=>void act(async()=>{
    await adapter.certifyCombat();
    if(!await refresh()||certification?.status!=='adopted'||certification.combat_eligible!==false)
      throw Error('Certificazione Combat inviata: rileggi lo stato della stessa richiesta.');
    say('Bundle PNG Combat registrato. Il PNG sarà selezionabile soltanto dopo la qualifica Combat del server.');
  }));
  approve.addEventListener('click',()=>void act(async()=>{
    const result=await adapter.approvePair(selects.portrait.value,selects.marker.value);
    if(!result||!await refresh())throw Error('Approvazione media da rileggere prima di proseguire.');
    say('Ritratto e sagoma approvati. La certificazione Builder è ancora necessaria.');
  }));
  render();
  const clear=()=>{state=binding=certification=null;certError='';adapter.reset();for(const kind of Object.keys(rows)){
    if(urls[kind])URL.revokeObjectURL(urls[kind]);urls[kind]=null;
    rows[kind].file.value='';rows[kind].preview.removeAttribute('src');rows[kind].preview.hidden=true;
  }render();};
  return {refresh,reset:clear,dispose:()=>{disposed=true;clear();card.remove();approval.remove();}};
}
