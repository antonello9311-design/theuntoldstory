// Candidata di sola presentazione combat-panel/1. Nessuna RPC o formula di gioco.
import {renderPanelMap} from './map.mjs';
import {isPlayerLifecycle} from './validate.mjs';
import {renderPanelCompanion,renderPanelSabaku} from './domain-views.mjs';
// Il controller validante è iniettato: questa vista non concede autorità.
const uuid=x=>typeof x==='string'&&/^[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(x);
const text=x=>typeof x==='string';
const integer=x=>Number.isSafeInteger(x)&&x>=0;
const finite=x=>typeof x==='number'&&Number.isFinite(x)&&x>=0;
const purposes=new Set(['generic','target','coverage','technique','mode','copies','movement_direction','movement_distance']);
const narrativeStates={idle:'Nessun esito in attesa',waiting:'Esito in attesa',running:'Narrazione in corso',published:'Esito pubblicato',failed:'Narrazione non riuscita',expired:'Attesa della narrazione scaduta'};

export function changeSingleChoice(group,value,selected,selectOption){
  if(group.options.some(o=>o.option_id===value))return selectOption(group.group_id,value,true);
  if(value===''){
    const previous=group.options.find(o=>selected.has(o.option_id));
    if(previous)return selectOption(group.group_id,previous.option_id,false);
  }
}

export function mountPanelView(root,{readState,readOptions,selectActor,selectOffer,selectOption,setInput,setNarrative,prepare,retry}={},renderers={}){
  renderers={map:renderPanelMap,companion:renderPanelCompanion,sabaku_transport:renderPanelSabaku,...renderers};
  const doc=root.ownerDocument;
  let generation=0,current=null;
  const node=(tag,value,parent)=>{const el=doc.createElement(tag);if(value!==undefined)el.textContent=String(value);if(parent)parent.append(el);return el;};
  const section=(parent,title)=>{const s=node('section',undefined,parent);s.className='mv2-field';node('h4',title,s);return s;};
  const note=(parent,value)=>{const p=node('p',value,parent);p.className='mv2-note';return p;};
  const token=()=>generation;
  const handler=(ticket,fn,...args)=>()=>{if(ticket!==generation||typeof fn!=='function')return;fn(...args);};
  function button(parent,label,fn,disabled=false){const b=node('button',label,parent);b.type='button';b.className='mv2-btn';b.disabled=disabled||typeof fn!=='function';if(fn)b.addEventListener('click',fn);return b;}
  function clear(){generation++;current=null;root.replaceChildren();}
  function renderFeedback(model){
    const last=model?.lastCommand;
    // Opzionale per i consumer privati: preserva anche il loro snapshot/rejection già valido.
    if(last||model?.rejection){
      const feedback=section(root,'Ultimo invio');feedback.setAttribute('role','status');feedback.setAttribute('aria-live','polite');
      const value=last||model.rejection;note(feedback,value.message);
      if(value.status==='rejected')note(feedback,value.recovery==='authenticate'?'Verifica il normale accesso e rileggi lo stato.':value.recovery==='contact_staff'?'Contatta lo staff prima di un nuovo invio.':'Rileggi lo stato prima di scegliere nuovamente.');
    }
    if(model?.interactionError)note(root,model.interactionError);
    if(model?.error)note(root,model.pending&&!last?'Esito incerto. Verifica lo stesso invio senza crearne un secondo.':'Stato non disponibile. Rileggi lo stato.');
  }
  function render(model){
    const active=doc.activeElement;
    const focus=active&&root.contains(active)&&active.getAttribute('data-focus-key')?{key:active.getAttribute('data-focus-key'),start:active.selectionStart,end:active.selectionEnd}:null;
    generation++;current=model;const ticket=token();root.replaceChildren();
    const e=model?.envelope;
    node('h3','Scontro',root);renderFeedback(model);
    if(model?.validated!==true||e?.schema_version!=='combat-panel/1'||!['ready','blocked'].includes(e.status)){
      note(root,'Stato del pannello non disponibile.');button(root,'Rileggi lo stato',handler(ticket,readState),model?.busy===true);if(model?.pending===true)button(root,'Verifica lo stesso invio',handler(ticket,retry),model.busy===true);return;
    }
    if(e.status==='blocked'){
      note(root,'Scontro non disponibile nel contesto corrente.');button(root,'Rileggi lo stato',handler(ticket,readState),model.busy===true);if(model.pending===true)button(root,'Verifica lo stesso invio',handler(ticket,retry),model.busy===true);return;
    }
    const c=e.context,v=e.viewer;
    if(!c||!integer(c.version)||!v||!Array.isArray(v.controlled_actors)||!Array.isArray(e.actors)||!Array.isArray(e.offers)){
      note(root,'Contesto incompleto. Rileggi lo stato.');button(root,'Rileggi lo stato',handler(ticket,readState),model.busy===true);return;
    }
    const locked=model.busy===true||model.pending===true;
    const commandsReady=!locked&&model.optionsReady===true&&v.can_command===true;
    const info=section(root,'Stato e partecipanti');
    note(info,(c.round_no===null?'':`Round ${c.round_no} · `)+c.phase_label);
    if(c.simulated)note(info,'Simulazione protetta · risorse separate dalle schede reali');
    const pickerLabel=node('label','Personaggio controllato',info),picker=node('select',undefined,pickerLabel);
    picker.className='mv2-select';const empty=node('option','Seleziona',picker);empty.value='';
    for(const actor of v.controlled_actors){if(!uuid(actor.actor_id)||!text(actor.label))continue;const option=node('option',actor.label,picker);option.value=actor.actor_id;}
    picker.value=v.command_actor_id||'';picker.disabled=locked||!selectActor||v.controlled_actors.length===0;
    picker.addEventListener('change',()=>{if(ticket!==generation||!selectActor)return;const id=picker.value;if(v.controlled_actors.some(a=>a.actor_id===id))selectActor(id);});
    const roster=node('div',undefined,info);roster.className='mv2-roster';
    for(const actor of e.actors){
      const row=node('div',undefined,roster);row.className='mv2-row';
      node('strong',actor.display_name,row);
      note(row,(actor.team===null?'':`Squadra ${actor.team} · `)+actor.state);
      if(finite(actor.distance_from_viewer_m))note(row,`${actor.distance_from_viewer_m} m dal punto di vista selezionato`);
      if(actor.resources!==null){
        const r=actor.resources;
        for(const [key,label]of [['pv','PV'],['chakra','Chakra']]){const val=r?.[key];if(val&&finite(val.current)&&finite(val.max))note(row,`${label} ${val.current} / ${val.max}`);}
      }
      const due=[];if(actor.action_due===true)due.push('azione');if(actor.defense_due===true)due.push('difesa');
      if(due.length)note(row,'Deve ancora consegnare: '+due.join(' e '));
    }
    const map=section(root,'Arena e posizioni');
    if(e.map!==null&&typeof renderers.map==='function')renderers.map(map,e);
    else note(map,'Mappa non disponibile in questa candidata. Nessuna posizione viene ricostruita.');
    for(const [field,title]of [['companion','Compagno'],['sabaku_transport','Controllo della sabbia']]){
      if(e[field]===null)continue;
      const block=section(root,title);
      if(typeof renderers[field]==='function')renderers[field](block,e);
      else note(block,'Dettagli non ancora collegati alla vista comune.');
    }
    if(e.round_details!==null){
      const details=section(root,'Dichiarazioni ed esito del round');
      for(const declaration of e.round_details.declarations){
        const block=section(details,declaration.display_name+' · '+declaration.label);
        const prose=note(block,declaration.text);prose.style.whiteSpace='pre-wrap';
        if(declaration.targets.length)note(block,'Bersagli: '+declaration.targets.map(a=>a.display_name).join(', '));
        if(declaration.coverage.length)note(block,'Copertura: '+declaration.coverage.map(a=>a.display_name).join(', '));
        if(declaration.rating_label!==null)note(block,declaration.rating_label);
        if(declaration.rating_offer_id!==null)button(block,'Valuta questa dichiarazione',handler(ticket,selectOffer,declaration.rating_offer_id),!commandsReady);
      }
      if(e.round_details.report){const report=section(details,e.round_details.report.title);for(const line of e.round_details.report.lines)note(report,line);}
    }
    const actions=section(root,'Azioni e difese');
    const admin=section(root,'Gestione della scena');
    admin.hidden=!(v.is_master||v.is_admin);
    const available=e.offers.filter(o=>o.context_version===c.version&&o.scene_version===c.scene_version);
    const administrative=o=>o.kind==='administration'&&!isPlayerLifecycle(o,c,v);
    const selected=available.find(o=>o.offer_id===model.selectedOfferId);
    for(const [area,isAdminArea]of [[actions,false],[admin,true]]){
      if(isAdminArea&&admin.hidden)continue;
      const offers=available.filter(o=>administrative(o)===isAdminArea);
      const label=node('label',isAdminArea?'Operazione autorizzata':'Scelta disponibile',area),select=node('select',undefined,label);
      select.className='mv2-select';const placeholder=node('option','Seleziona',select);placeholder.value='';
      for(const offer of offers){const item=node('option',offer.label,select);item.value=offer.offer_id;}
      select.value=selected&&administrative(selected)===isAdminArea?selected.offer_id:'';
      select.disabled=!commandsReady||!selectOffer||offers.length===0;
      select.addEventListener('change',()=>{if(ticket!==generation||!selectOffer)return;if(offers.some(o=>o.offer_id===select.value))selectOffer(select.value);});
      if(!offers.length)note(area,'Nessuna offerta in questo momento.');
    }
    if(selected&&!(administrative(selected)&&admin.hidden)){
      const area=administrative(selected)?admin:actions;
      renderOffer(area,selected,e,model,ticket,!commandsReady);
    }
    button(root,'Rileggi lo stato',handler(ticket,readState),locked);
    button(root,'Aggiorna le scelte',handler(ticket,readOptions),locked||model.refreshRequired===true||!v.can_command);
    if(model.pending===true)button(root,'Verifica lo stesso invio',handler(ticket,retry),model.busy===true);
    renderNarrative(section(root,'Fato e narrazione'),e);
    const receipt=section(root,'Ultima conferma');
    const lastReceipt=model.lastCommand?.status==='confirmed'?model.lastCommand.receipt:e.receipt;
    if(lastReceipt&&uuid(lastReceipt.receipt_id)){
      note(receipt,'Richiesta confermata dal server'+(lastReceipt.replayed?' · ricevuta già acquisita':''));
      // display_events resta al formatter validato: nessuna shape inventata.
      if(typeof renderers.receipt==='function')renderers.receipt(receipt,lastReceipt);
      else for(const event of lastReceipt.display_events)note(receipt,event.summary);
    }else note(receipt,'Nessuna ricevuta disponibile.');
    if(focus){const target=[...root.querySelectorAll('[data-focus-key]')].find(x=>x.getAttribute('data-focus-key')===focus.key);if(target&&!target.disabled){target.focus();if(typeof focus.start==='number'&&typeof target.setSelectionRange==='function')target.setSelectionRange(focus.start,focus.end);}}
  }
  function renderOffer(area,offer,envelope,model,ticket,disabled){
    const selected=new Set(model.selectedOptionIds||[]);
    for(const group of offer.choices){
      if(!purposes.has(group.purpose)||group.depends_on!==null&&!selected.has(group.depends_on))continue;
      const field=node('fieldset',undefined,area);field.disabled=disabled||!selectOption;
      node('legend',group.label,field);
      if(group.selection_mode==='single'){
        const select=node('select',undefined,field);select.className='mv2-select';select.setAttribute('aria-label',group.label);
        const blank=node('option','Seleziona',select);blank.value='';
        for(const option of group.options){const item=node('option',option.label,select);item.value=option.option_id;item.selected=selected.has(option.option_id);}
        select.addEventListener('change',()=>{if(ticket!==generation||!selectOption)return;changeSingleChoice(group,select.value,selected,selectOption);});
      }else if(group.selection_mode==='multiple'){
        note(field,`Selezioni richieste: da ${group.min_selected} a ${group.max_selected}`);
        for(const option of group.options){const label=node('label',undefined,field),input=node('input',undefined,label);input.type='checkbox';input.checked=selected.has(option.option_id);node('span',option.label,label);input.addEventListener('change',()=>{if(ticket===generation&&selectOption)selectOption(group.group_id,option.option_id,input.checked);});}
      }
    }
    for(const spec of offer.input_fields){
      const label=node('label',spec.label,area),input=node('input',undefined,label);input.disabled=disabled||!setInput;input.required=spec.required;
      input.setAttribute('data-focus-key',spec.input_id);
      const prior=(model.inputs||[]).find(x=>x.input_id===spec.input_id);
      if(spec.value_type==='boolean'){input.type='checkbox';input.checked=prior?.value===true;}
      else if(spec.value_type==='text'){input.type='text';input.maxLength=spec.max_length;input.value=typeof prior?.value==='string'?prior.value:'';}
      else {input.disabled=true;continue;}
      input.addEventListener('input',()=>{if(ticket===generation&&setInput)setInput(spec.input_id,spec.value_type==='boolean'?input.checked:input.value);});
    }
    renderMovementReasons(area,envelope,offer,selected);
    if(offer.requires_role){
      const label=node('label','Azione testuale collegata',area),input=node('textarea',undefined,label);input.value=model.narrativeText||'';input.disabled=disabled||!setNarrative;
      input.setAttribute('data-focus-key','role:'+offer.offer_id);
      input.addEventListener('input',()=>{if(ticket===generation&&setNarrative)setNarrative(input.value);});
      note(area,'Testo e scelta saranno collegati alla medesima richiesta. Non inviare una seconda copia in chat.');
    }
    button(area,offer.requires_role?'Invia azione e testo':'Conferma scelta',handler(ticket,prepare),disabled||model.canPrepare!==true);
  }
  function renderMovementReasons(area,e,offer,selected){
    const m=e.movement_explanations;if(m===null)return;
    if(m?.contract_version!=='movement-explanations/2'||m.context_version!==e.context.version||!Array.isArray(m.entries)){note(area,'Dettagli del movimento non disponibili.');return;}
    const ids=new Set(offer.choices.flatMap(g=>g.options.map(o=>o.option_id)));
    for(const item of m.entries){
      if(item.offer_id!==offer.offer_id||item.option_id!==null&&(!ids.has(item.option_id)||!selected.has(item.option_id)))continue;
      if(finite(item.effective_distance_m))note(area,`Distanza effettiva disponibile: ${item.effective_distance_m} m`);
      for(const reason of item.reasons||[]){if(text(reason.label))note(area,reason.label+(finite(reason.amount_m)?` · ${reason.amount_m} m`:''));}
    }
  }
  function renderNarrative(area,e){
    const n=e.narrative;
    if(n===null){note(area,'Nessun esito disponibile.');return;}
    if(n?.schema_version!=='combat-panel-narrative/1'||n.activity_id!==e.context.activity_id||!Object.hasOwn(narrativeStates,n.state)||!['human','automatic'].includes(n.mode)){note(area,'Stato narrativo non disponibile.');return;}
    note(area,narrativeStates[n.state]+(n.mode==='human'?' · gestione Master':''));
    const published=n.last_published;
    if(published!==null&&uuid(published?.message_id)&&uuid(published?.report_id)&&text(published.text)){
      node('h5','Ultimo esito pubblicato',area);const p=node('p',published.text,area);p.style.whiteSpace='pre-wrap';
    }
  }
  return {render,clear};
}
