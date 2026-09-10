import {renderCombatCompanion} from '../../consumer/combat-companion.mjs';
const uuid=x=>typeof x==='string'&&/^[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(x);
const integer=x=>Number.isSafeInteger(x)&&x>=0;
const exact=(x,keys)=>x!==null&&typeof x==='object'&&!Array.isArray(x)&&Object.keys(x).length===keys.length&&keys.every(k=>Object.hasOwn(x,k));

export function renderPanelCompanion(root,envelope){
  // Alias soltanto per il renderer legacy; mai incluso in un comando.
  return renderCombatCompanion(root,{...envelope,viewer:{...envelope.viewer,actor_id:envelope.viewer.command_actor_id}});
}

export function renderPanelSabaku(root,envelope){
  root.replaceChildren();root.hidden=true;
  const value=envelope.sabaku_transport;if(value===null)return;
  const add=(tag,text)=>{const el=root.ownerDocument.createElement(tag);el.textContent=text;root.append(el);return el;};
  const fail=()=>{root.hidden=false;add('p','Stato della sabbia non disponibile.');};
  if(envelope.status!=='ready'||!uuid(envelope.viewer.command_actor_id)||!exact(value,['contract_version','context_version','is_test','innata','reserve','transport'])||value.contract_version!=='sabaku-transport-view/2'||value.context_version!==envelope.context.version||typeof value.is_test!=='boolean')return fail();
  const {innata:i,reserve:r,transport:t}=value;
  if(!exact(i,['active','activation_chakra','upkeep_chakra','deactivation_chakra'])||typeof i.active!=='boolean'||i.activation_chakra!==5||i.upkeep_chakra!==5||i.deactivation_chakra!==0)return fail();
  if(!exact(r,['current','committed','capacity','available'])||!Object.values(r).every(integer)||r.committed>r.current||r.current>r.capacity||r.available!==r.current-r.committed)return fail();
  if(!exact(t,['active','activation_chakra','sand_commit','upkeep_chakra','movement_bonus_m','expires_context'])||typeof t.active!=='boolean'||t.activation_chakra!==5||t.sand_commit!==5||t.upkeep_chakra!==0)return fail();
  if(t.active){const end=t.expires_context;if(!i.active||t.movement_bonus_m!==5||r.committed<5||!exact(end,['kind','id','label'])||!['ordinary_exchange','master_actor_turn'].includes(end.kind)||!uuid(end.id)||typeof end.label!=='string'||!end.label.trim())return fail();}
  else if(t.movement_bonus_m!==0||t.expires_context!==null)return fail();
  root.hidden=false;add('h4','Controllo della sabbia');add('p',value.is_test?'Riserva di prova · separata dalla giara reale':'Riserva personale di sabbia');
  add('p','Innata: '+(i.active?'attiva':'inattiva'));add('p',`Attivazione ${i.activation_chakra} chakra · mantenimento ${i.upkeep_chakra} chakra al proprio turno · disattivazione ${i.deactivation_chakra} chakra.`);
  add('p',`Sabbia disponibile: ${r.available} · impegnata: ${r.committed} · corrente: ${r.current} / ${r.capacity}.`);
  add('h4','Trasporto di Sabbia · '+(t.active?'attivo':'inattivo'));add('p',`Attivazione ${t.activation_chakra} chakra · impegno ${t.sand_commit} sabbia · mantenimento ${t.upkeep_chakra} chakra.`);
  if(t.active){add('p',`Bonus al movimento ordinario: +${t.movement_bonus_m} m.`);add('p','Ignora il sovraccosto di tutte le aree impervie. Ostacoli e immobilizzazione restano validi.');add('p','Validità: '+t.expires_context.label);}
  add('p','Le attivazioni disponibili si scelgono dalle offerte del server.');
}
