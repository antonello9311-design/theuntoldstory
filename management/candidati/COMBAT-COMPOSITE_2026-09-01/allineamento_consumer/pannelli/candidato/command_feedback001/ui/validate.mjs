// Validazione della nuova famiglia. Nessun allentamento dei contratti legacy.
import {validateMultiplication} from './multiplication.mjs';
export const isId=x=>typeof x==='string'&&/^[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(x);
const nullable=(x,fn)=>x===null||fn(x);
const int=x=>Number.isSafeInteger(x)&&x>=0;
const num=x=>typeof x==='number'&&Number.isFinite(x)&&x>=0;
const str=x=>typeof x==='string';
const name=x=>str(x)&&x.trim().length>0;
const bool=x=>typeof x==='boolean';
const obj=x=>x!==null&&typeof x==='object'&&!Array.isArray(x);
const sha=x=>str(x)&&/^[a-f0-9]{64}$/.test(x);
export function insist(ok,code='panel_projection_invalid'){if(!ok)throw Error(code);}
function shape(x,keys){insist(obj(x)&&Object.keys(x).length===keys.length&&keys.every(k=>Object.hasOwn(x,k)));}
function unique(items,key){insist(new Set(items.map(x=>x[key])).size===items.length);}
const purposes=['generic','target','coverage','technique','mode','copies','movement_direction','movement_distance'];
// Un rifiuto definitivo è riconosciuto solo dalla shape server completa.
export function classifyPanelRejection(raw,requestKey){
  if(raw?.schema_version!=='combat-panel-error/1')return null;
  shape(raw,['schema_version','status','request_key','code','message','recovery']);
  insist(raw.status==='rejected'&&nullable(raw.request_key,isId)&&
    ['authentication_required','request_key_conflict','not_authorized','context_changed','selection_rejected','operation_rejected'].includes(raw.code)&&
    name(raw.message)&&['authenticate','contact_staff','refresh'].includes(raw.recovery),'rejection_invalid');
  insist(raw.request_key===null||raw.request_key===requestKey,'rejection_request_mismatch');
  return structuredClone(raw);
}
// Eccezione di presentazione nominata PM: lifecycle ordinary già offerto dal
// server, non poteri di amministrazione né autorizzazione al commit.
export function isPlayerLifecycle(o,c,v){
  return !v.is_master&&!v.is_admin&&v.can_command===true&&o.kind==='administration'&&
    ((c.activity_kind==='ordinary_v2'&&['open','join','close'].includes(o.operation))||
     (c.activity_kind===null&&c.activity_id===null&&c.phase==='setup'&&['open','join'].includes(o.operation)));
}
function offer(o,c,viewer){
  shape(o,['offer_id','kind','operation','actor_id','label','context_version','scene_version','requires_role','choices','input_fields']);
  insist(isId(o.offer_id)&&['action','defense','control','administration'].includes(o.kind)&&name(o.operation)&&nullable(o.actor_id,isId)&&name(o.label)&&o.context_version===c.version&&o.scene_version===c.scene_version&&bool(o.requires_role)&&Array.isArray(o.choices)&&Array.isArray(o.input_fields));
  insist(o.actor_id===null||o.actor_id===viewer.command_actor_id);
  insist(o.kind!=='administration'||viewer.is_master||viewer.is_admin||isPlayerLifecycle(o,c,viewer));
  unique(o.choices,'group_id');unique(o.input_fields,'input_id');const options=new Map(),groups=new Map();
  for(const g of o.choices){
    shape(g,['group_id','label','selection_mode','purpose','min_selected','max_selected','depends_on','options']);
    insist(isId(g.group_id)&&name(g.label)&&['single','multiple'].includes(g.selection_mode)&&purposes.includes(g.purpose)&&int(g.min_selected)&&int(g.max_selected)&&g.min_selected<=g.max_selected&&nullable(g.depends_on,isId)&&Array.isArray(g.options)&&g.max_selected<=g.options.length);
    insist(g.selection_mode!=='single'||g.max_selected<=1);groups.set(g.group_id,g);
    for(const option of g.options){shape(option,['option_id','label','distance_m','direction']);insist(isId(option.option_id)&&!options.has(option.option_id)&&name(option.label)&&nullable(option.distance_m,num)&&nullable(option.direction,x=>['up','down','left','right','toward_target','away_from_target','stay'].includes(x)));options.set(option.option_id,g);}
  }
  for(const g of groups.values()){
    let p=g;const seen=new Set();
    while(p.depends_on!==null){insist(!seen.has(p.group_id)&&options.has(p.depends_on));seen.add(p.group_id);p=options.get(p.depends_on);}
  }
  for(const f of o.input_fields){shape(f,['input_id','label','value_type','required','max_length']);insist(isId(f.input_id)&&name(f.label)&&bool(f.required)&&(f.value_type==='text'?int(f.max_length):f.value_type==='boolean'&&f.max_length===null));}
}
function receipt(r){
  if(r===null)return;
  shape(r,['receipt_id','request_key','operation','replayed','activity_id','round_id','context_version_before','context_version_after','declaration_id','report_id','values_written','display_events']);
  insist(isId(r.receipt_id)&&isId(r.request_key)&&name(r.operation)&&bool(r.replayed)&&nullable(r.activity_id,isId)&&nullable(r.round_id,isId)&&int(r.context_version_before)&&int(r.context_version_after)&&nullable(r.declaration_id,isId)&&nullable(r.report_id,isId)&&bool(r.values_written)&&Array.isArray(r.display_events));
  unique(r.display_events,'event_id');
  for(const x of r.display_events){shape(x,['event_id','event_kind','actor_id','display_name','label_version','target_actor_id','target_display_name','target_label_version','summary']);insist(isId(x.event_id)&&['movement','action_declared','defense_resolved','control_changed','combat_closed'].includes(x.event_kind)&&str(x.summary));for(const[a,n,v]of [['actor_id','display_name','label_version'],['target_actor_id','target_display_name','target_label_version']])insist(x[a]===null?x[n]===null&&x[v]===null:isId(x[a])&&name(x[n])&&int(x[v])&&x[v]>0);}
}
function narrative(n,c){
  if(n===null)return;
  shape(n,['schema_version','activity_id','round_id','mode','state','reason_code','report_id','report_sha256','last_published']);
  insist(n.schema_version==='combat-panel-narrative/1'&&isId(n.activity_id)&&n.activity_id===c.activity_id&&nullable(n.round_id,isId)&&['human','automatic'].includes(n.mode)&&['idle','waiting','running','published','failed','expired'].includes(n.state)&&nullable(n.reason_code,x=>['validation_rejected','provider_error','configuration_mismatch','timeout','context_changed','narration_unavailable'].includes(x))&&nullable(n.report_id,isId)&&nullable(n.report_sha256,sha));
  if(n.last_published!==null){const p=n.last_published;shape(p,['report_id','round_id','message_id','text']);insist(isId(p.report_id)&&nullable(p.round_id,isId)&&isId(p.message_id)&&str(p.text));}
}
function movement(m,e){
  if(m===null)return;shape(m,['contract_version','context_version','entries']);insist(m.contract_version==='movement-explanations/2'&&m.context_version===e.context.version&&Array.isArray(m.entries));const seen=new Set();
  for(const x of m.entries){shape(x,['offer_id','option_id','effective_distance_m','reasons']);insist(isId(x.offer_id)&&nullable(x.option_id,isId)&&nullable(x.effective_distance_m,num)&&Array.isArray(x.reasons));const key=x.offer_id+':'+x.option_id;insist(!seen.has(key));seen.add(key);const o=e.offers.find(o=>o.offer_id===x.offer_id);insist(o&&(x.option_id===null||o.choices.some(g=>g.options.some(p=>p.option_id===x.option_id))));for(const r of x.reasons){shape(r,['kind','source_kind','label','amount_m']);insist(['budget_reduction','path_surcharge','blocked'].includes(r.kind)&&['environment','jutsu','ability','undisclosed'].includes(r.source_kind)&&name(r.label)&&nullable(r.amount_m,num)&&(r.kind!=='blocked'||r.amount_m===null));}}
}

function roundDetails(d,e){
  if(d===null)return;
  shape(d,['schema_version','round_id','declarations','report']);
  insist(d.schema_version==='combat-panel-round-details/1'&&nullable(d.round_id,isId)&&d.round_id===e.context.round_id&&Array.isArray(d.declarations));
  unique(d.declarations,'declaration_id');
  for(const a of d.declarations){
    shape(a,['declaration_id','actor_id','display_name','kind','label','text','targets','coverage','rating_label','rating_offer_id']);
    insist(isId(a.declaration_id)&&isId(a.actor_id)&&name(a.display_name)&&name(a.kind)&&name(a.label)&&str(a.text)&&Array.isArray(a.targets)&&Array.isArray(a.coverage)&&nullable(a.rating_label,str)&&nullable(a.rating_offer_id,isId));
    for(const list of [a.targets,a.coverage]){unique(list,'actor_id');for(const target of list){shape(target,['actor_id','display_name']);insist(isId(target.actor_id)&&name(target.display_name));}}
    insist(a.rating_offer_id===null||e.offers.some(o=>o.offer_id===a.rating_offer_id&&o.kind==='administration'));
  }
  if(d.report!==null){shape(d.report,['report_id','title','lines']);insist(isId(d.report.report_id)&&name(d.report.title)&&Array.isArray(d.report.lines)&&d.report.lines.every(str));}
}

export function validatePanelEnvelope(raw,{state=false}={}){
  const e=structuredClone(raw);
  shape(e,['schema_version','status','reason_code','context','viewer','actors','map','offers','movement_explanations','companion','sabaku_transport','multiplication','narrative','receipt','round_details']);
  insist(e.schema_version==='combat-panel/1'&&['ready','blocked'].includes(e.status)&&nullable(e.reason_code,str)&&Array.isArray(e.actors)&&Array.isArray(e.offers));
  const v=e.viewer;shape(v,['command_actor_id','controlled_actors','is_master','is_admin','can_command']);insist(nullable(v.command_actor_id,isId)&&Array.isArray(v.controlled_actors)&&bool(v.is_master)&&bool(v.is_admin)&&bool(v.can_command));
  for(const a of v.controlled_actors){shape(a,['actor_id','label']);insist(isId(a.actor_id)&&name(a.label));}unique(v.controlled_actors,'actor_id');
  if(e.status==='blocked'){insist(e.context===null&&!v.can_command&&v.command_actor_id===null&&v.controlled_actors.length===0&&e.actors.length===0&&e.offers.length===0&&['map','movement_explanations','companion','sabaku_transport','multiplication','narrative','receipt','round_details'].every(k=>e[k]===null));return e;}
  const c=e.context;shape(c,['activity_id','activity_kind','location_id','round_id','round_no','phase','phase_label','version','scene_version','policy_id','simulated']);
  insist(nullable(c.activity_id,isId)&&nullable(c.activity_kind,x=>['ordinary_v2','master_v2'].includes(x))&&isId(c.location_id)&&nullable(c.round_id,isId)&&nullable(c.round_no,int)&&['setup','action','defense','review','resolving','resolved','suspended','closed'].includes(c.phase)&&name(c.phase_label)&&int(c.version)&&nullable(c.scene_version,int)&&name(c.policy_id)&&bool(c.simulated));
  insist(c.phase==='setup'||isId(c.activity_id)&&c.activity_kind!==null);
  unique(e.actors,'actor_id');
  for(const a of e.actors){shape(a,['actor_id','kind','body_only','display_name','team','state','mine','action_due','defense_due','resources','distance_from_viewer_m']);insist(isId(a.actor_id)&&['pg','png','companion'].includes(a.kind)&&bool(a.body_only)&&(a.kind==='companion')===a.body_only&&name(a.display_name)&&nullable(a.team,str)&&['active','out','withdrawn'].includes(a.state)&&bool(a.mine)&&a.mine===(a.actor_id===v.command_actor_id)&&bool(a.action_due)&&bool(a.defense_due)&&nullable(a.distance_from_viewer_m,num));if(a.body_only)insist(!a.action_due&&!a.defense_due);if(a.resources!==null){shape(a.resources,['pv','chakra','simulated']);insist(bool(a.resources.simulated));for(const k of ['pv','chakra']){shape(a.resources[k],['current','max']);insist(num(a.resources[k].current)&&num(a.resources[k].max)&&a.resources[k].current<=a.resources[k].max);}}}
  insist(v.command_actor_id===null||v.controlled_actors.some(a=>a.actor_id===v.command_actor_id));
  insist(v.controlled_actors.every(a=>e.actors.some(r=>r.actor_id===a.actor_id&&!r.body_only)));
  insist(!state||e.offers.length===0);insist(v.can_command||e.offers.length===0);unique(e.offers,'offer_id');for(const o of e.offers)offer(o,c,v);
  // Projection geometriche/di dominio hanno validatori propri nei renderer.
  // Qui vengono versionate e isolate; non sono mai lette dal controller comandi.
  for(const [key,version,field]of [['map','combat-map/2','schema_version'],['companion','combat-companion/1','schema_version'],['sabaku_transport','sabaku-transport-view/2','contract_version']])if(e[key]!==null)insist(obj(e[key])&&e[key][field]===version);
  validateMultiplication(e);movement(e.movement_explanations,e);narrative(e.narrative,c);receipt(e.receipt);roundDetails(e.round_details,e);return e;
}

export function selectionReady(offer,selected,inputs,narrativeText){
  if(!offer||!Array.isArray(selected)||new Set(selected).size!==selected.length||!Array.isArray(inputs)||new Set(inputs.map(x=>x.input_id)).size!==inputs.length||!str(narrativeText))return false;
  const active=new Set(selected),ids=new Set(offer.choices.flatMap(g=>g.options.map(o=>o.option_id)));
  if(selected.some(id=>!ids.has(id)))return false;
  for(const g of offer.choices){const n=g.options.filter(o=>active.has(o.option_id)).length,enabled=g.depends_on===null||active.has(g.depends_on);if(enabled?(n<g.min_selected||n>g.max_selected):n!==0)return false;}
  if(inputs.some(x=>!offer.input_fields.some(f=>f.input_id===x.input_id)))return false;
  for(const f of offer.input_fields){const x=inputs.find(x=>x.input_id===f.input_id);if(!x){if(f.required)return false;continue;}if(f.value_type==='text'){if(!str(x.value)||[...x.value].length>f.max_length||(f.required&&!x.value.trim()))return false;}else if(!bool(x.value))return false;}
  return !offer.requires_role||!!narrativeText.trim();
}
