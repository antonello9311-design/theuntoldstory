// Bridge puro, candidato isolato: la proiezione PNG proviene dalla porta Staff CAS.
export const EVENT_PROJECTION_VERSION = 'mission-factory-native-event/1';
const die = code => { const error = new Error(code); error.code = code; throw error; };
const record = x => x !== null && typeof x === 'object' && !Array.isArray(x);
const unique = a => new Set(a).size === a.length;
const sorted = a => [...a].sort().join('\u0000');
const phaseEditorial = key => ({step_key:key,setting:{name:'',description:''},director_notes:'',entry_public:'',actors:[],consequences:[]});
const projection = (key,mode,transitionKey) => {
  if (key === 'role_advance') return {source_kind:mode === 'ai' ? 'narrative_event' : 'player_choice',fact_code:mode === 'ai' ? `mf_${transitionKey}` : 'player_choice_confirmed'};
  const outcome = {combat_any:'any',combat_pg_win:'pg_win',combat_pg_loss:'pg_loss',combat_draw:'draw'}[key];
  if (!outcome) die('MF_NATIVE_EVENT_UNMAPPED');
  return {source_kind:'combat_terminal',fact_code:'combat_terminal_confirmed',combat_outcome:outcome};
};
export function factoryEventProjection(transition,mode,catalog,phaseKind) {
  if (!['ai','human'].includes(mode) || catalog?.event_projection_version !== EVENT_PROJECTION_VERSION ||
      !Array.isArray(catalog.events) || !/^[a-z][a-z0-9_]{0,63}$/.test(transition?.transition_key || '')) die('MF_NATIVE_EVENT_CATALOG');
  const item = catalog.events.find(x => x.key === transition.event_key && x.phase_kind === phaseKind &&
    x.qualified === true && Array.isArray(x.direction_modes) && x.direction_modes.includes(mode));
  if (!item) die('MF_NATIVE_EVENT_UNQUALIFIED');
  return projection(transition.event_key,mode,transition.transition_key);
}
export function seedMissionNativeModel(source,npcProjection,{draftId,expectedVersion,mode,catalog,d100Projections=[]}={}) {
  if (source?.schema_version !== 'mission-factory-draft/1' || !record(source.mission) ||
      !Array.isArray(source.phases) || !source.phases.length || !Array.isArray(source.npc_bindings) || !Array.isArray(source.maps) ||
      npcProjection?.schema_version !== 'mission-factory-variant-npc-projection/1' ||
      npcProjection.draft_id !== draftId || npcProjection.draft_control_version !== expectedVersion ||
      npcProjection.content_kind !== 'mission' || !Array.isArray(npcProjection.items) ||
      !['ai','human'].includes(mode) || catalog?.event_projection_version !== EVENT_PROJECTION_VERSION)
    die('MF_NATIVE_BRIDGE_INPUT');
  const items = new Map(npcProjection.items.map(x => [x.actor_key,x]));
  if (items.size !== npcProjection.items.length || items.size !== source.npc_bindings.length) die('MF_NATIVE_NPC_PROJECTION_DRIFT');
  for (const binding of source.npc_bindings) {
    const ref=items.get(binding.actor_key);
    if (!ref || ref.npc_id !== binding.npc_id || ref.npc_version_id !== binding.npc_version_id ||
        ref.team !== binding.team || ref.combat !== binding.combat ||
        !Array.isArray(ref.phase_keys) || !Array.isArray(binding.phase_keys) ||
        sorted(ref.phase_keys) !== sorted(binding.phase_keys) ||
        ref.reference_version !== 'mission-factory-npc-reference/1' ||
        !ref.narrative_version_id || (binding.combat && !ref.mechanical_binding_id)) die('MF_NATIVE_NPC_PROJECTION_DRIFT');
  }
  const actors = npcProjection.items.map(x => ({actor_key:x.actor_key,narrative_template_id:x.npc_id,
    narrative_version_id:x.narrative_version_id,mechanical_binding_id:x.mechanical_binding_id || null,team:x.team}));
  const byActor = new Map(actors.map(x => [x.actor_key,x]));
  const phaseKeys=source.phases.map(x=>x.step_key);
  if (!unique(phaseKeys) || phaseKeys.some(x=>!x)) die('MF_NATIVE_PHASE_DUPLICATE');
  const scenes=source.phases.map(phase => {
    if (!['narrative','combat','d100'].includes(phase.kind) || !Array.isArray(phase.actor_keys) || !unique(phase.actor_keys) ||
        !Array.isArray(phase.transitions)) die('MF_NATIVE_PHASE_SHAPE');
    const bound=source.npc_bindings.filter(x=>x.phase_keys.includes(phase.step_key)).map(x=>x.actor_key);
    if (sorted(bound)!==sorted(phase.actor_keys)) die('MF_NATIVE_ACTOR_SET_MISMATCH');
    const assigned=phase.actor_keys.map(key=>byActor.get(key));
    if (assigned.some(x=>!x)) die('MF_NATIVE_ACTOR_SET_MISMATCH');
    const map=source.maps.find(x=>x.step_key===phase.step_key);
    if (source.maps.filter(x=>x.step_key===phase.step_key).length>1 ||
        (phase.kind==='combat' && (!map?.combat_map?.template_key || !map.combat_map.zone_key))) die('MF_NATIVE_ARENA_REQUIRED');
    const triggers=phase.transitions.map(t=>{
      if (!phaseKeys.includes(t.to_step_key)) die('MF_NATIVE_TRANSITION_ORPHAN');
      return {trigger_key:t.transition_key,transition_key:t.transition_key,...(phase.kind==='d100'?missionD100EventProjection(t,mode,catalog,phase,d100Projections.find(x=>x.step_key===phase.step_key)):factoryEventProjection(t,mode,catalog,phase.kind)),
        label:'',to:t.to_step_key,transition:{transition_key:t.transition_key,from_step_key:phase.step_key,
          to_step_key:t.to_step_key,event_kind:t.transition_key,priority:0}};
    });
    if (triggers.length===0 && (phase.kind!=='narrative' || !['success','failure'].includes(phase.terminal_outcome)) ||
        triggers.length>0 && phase.terminal_outcome!==null) die('MF_NATIVE_TERMINAL_SHAPE');
    const editorial=phaseEditorial(phase.step_key);
    const scene={step_key:phase.step_key,kind:phase.kind==='combat'?'mechanical':'narrative',
      public_objective:phase.objective_public || '',actors:phase.actor_keys,
      actor_specs:Object.fromEntries(assigned.map(x=>[x.actor_key,structuredClone(x)])),
      fighters:phase.kind==='combat'?assigned.filter(x=>x.mechanical_binding_id).map(x=>x.actor_key):[],
      encounter:null,encounter_key:`enc_${phase.step_key}`,pg_team:'squadra',
      terminal:phase.terminal_outcome || '',triggers,editorial,
      arena:phase.kind==='combat'?{step_key:phase.step_key,...structuredClone(map.combat_map)}:null};
    return scene;
  });
  const mission=source.mission;
  return {mission:{title:mission.title || '',grado:'',briefing:mission.briefing || '',village:'',tag_trama:'',
    team_min:mission.team_min,team_max:mission.team_max,direction_mode:mode,
    gathering_location_id:mission.gathering_location_id || ''},
    editorial:{plot_private:mission.plot_private || '',setting:{name:'',description:''}},
    actors,scenes,initial:phaseKeys[0],base:null,counter:1,revision:null,catalog:null};
}

// C670: DTO Mission D100 distinti; nessuna soglia/esito generato dal client.
const D100_UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const D100_SHA=/^[0-9a-f]{64}$/;
const D100_KEY=/^[a-z][a-z0-9_]{0,63}$/;
const closed=(value,keys)=>record(value)&&Object.keys(value).length===keys.length&&keys.every(k=>Object.hasOwn(value,k));
const d100Id=(v,nullable=false)=>nullable&&v===null||D100_UUID.test(v||'');
export function validateMissionD100Offers(v){
 if(!closed(v,['schema_version','can_select','reason_code','policies'])||v.schema_version!=='mission-d100-policy-offers/1'||typeof v.can_select!=='boolean'||!Array.isArray(v.policies)||!(v.reason_code===null||typeof v.reason_code==='string'))die('MF_D100_POLICY_OFFERS');
 const ids=new Set();for(const x of v.policies){if(!closed(x,['policy_mission_id','policy_step_key','native_policy_sha256','label'])||!d100Id(x.policy_mission_id)||!D100_KEY.test(x.policy_step_key)||!D100_SHA.test(x.native_policy_sha256)||typeof x.label!=='string')die('MF_D100_POLICY_OFFER');const k=x.policy_mission_id+'/'+x.policy_step_key;if(ids.has(k))die('MF_D100_POLICY_DUPLICATE');ids.add(k);}
 if(v.can_select&&(v.reason_code!==null||!v.policies.length)||!v.can_select&&(v.reason_code===null||v.policies.length))die('MF_D100_POLICY_GATE');return structuredClone(v);
}
export function validateMissionD100Binding(v,{offer=null,success=null,complication=null}={}){
 if(!closed(v,['schema_version','policy_mission_id','policy_step_key','native_policy_sha256','success_transition_key','complication_transition_key','role_assignment'])||v.schema_version!=='mission-d100-phase-binding/1'||!d100Id(v.policy_mission_id)||!D100_KEY.test(v.policy_step_key)||!D100_SHA.test(v.native_policy_sha256)||!D100_KEY.test(v.success_transition_key)||!D100_KEY.test(v.complication_transition_key)||v.success_transition_key===v.complication_transition_key||v.role_assignment!=='explicit_guide_support/1')die('MF_D100_BINDING');
 if(offer&&(v.policy_mission_id!==offer.policy_mission_id||v.policy_step_key!==offer.policy_step_key||v.native_policy_sha256!==offer.native_policy_sha256)||success!==null&&v.success_transition_key!==success||complication!==null&&v.complication_transition_key!==complication)die('MF_D100_BINDING_DRIFT');return structuredClone(v);
}
export function validateMissionD100Projection(v,phase,mode){
 const b=validateMissionD100Binding(phase?.d100_binding);
 if(!closed(v,['schema_version','step_key','phase_sha256','direction_mode','native_step_kind','transitions'])||v.schema_version!=='mission-d100-native-projection/1'||v.step_key!==phase.step_key||!D100_SHA.test(v.phase_sha256)||v.direction_mode!==mode||!['ai','human'].includes(mode)||v.native_step_kind!=='narrative'||!Array.isArray(v.transitions)||v.transitions.length!==2||!Array.isArray(phase.transitions)||phase.transitions.length!==2)die('MF_D100_NATIVE_PROJECTION');
 const seen=new Set();for(const t of v.transitions){const input=phase.transitions.find(x=>x.transition_key===t.transition_key);if(!closed(t,['schema_version','event_key','direction_mode','phase_kind','transition_key','trigger_key','source_kind','fact_code','combat_outcome'])||t.schema_version!==EVENT_PROJECTION_VERSION||t.direction_mode!==mode||t.phase_kind!=='d100'||t.trigger_key!==t.transition_key||t.source_kind!=='narrative_event'||typeof t.fact_code!=='string'||!t.fact_code||t.combat_outcome!==null||!input||input.event_key!==t.event_key||seen.has(t.transition_key)||!(t.event_key==='d100_success'&&t.transition_key===b.success_transition_key||t.event_key==='d100_complication'&&t.transition_key===b.complication_transition_key))die('MF_D100_NATIVE_TRANSITION');seen.add(t.transition_key);}return structuredClone(v);
}
export function missionD100EventProjection(transition,mode,catalog,phase,server){
 const v=validateMissionD100Projection(server,phase,mode);
 if(catalog?.event_projection_version!==EVENT_PROJECTION_VERSION||!catalog.events?.some(x=>x.key===transition.event_key&&x.phase_kind==='d100'&&x.qualified===true&&x.direction_modes?.includes(mode)))die('MF_D100_EVENT_UNQUALIFIED');
 const t=v.transitions.find(x=>x.transition_key===transition.transition_key&&x.event_key===transition.event_key);if(!t)die('MF_D100_NATIVE_TRANSITION');return {source_kind:t.source_kind,fact_code:t.fact_code};
}
export function validateMissionD100Scope(v,session){
 if(!closed(v,['schema_version','master_session_id','run_control_version','step_key','binding_id','roster_character_ids','guide_character_id','support_character_id','role_assignment','can_bind','reason_code','direction_mode'])||v.schema_version!=='mission-d100-binding-scope/1'||v.master_session_id!==session||!d100Id(session)||!Number.isSafeInteger(v.run_control_version)||v.run_control_version<0||!D100_KEY.test(v.step_key)||!d100Id(v.binding_id,true)||!Array.isArray(v.roster_character_ids)||v.roster_character_ids.length<1||v.roster_character_ids.length>4||v.roster_character_ids.some(x=>!d100Id(x))||!unique(v.roster_character_ids)||!d100Id(v.guide_character_id,true)||!d100Id(v.support_character_id,true)||v.role_assignment!=='explicit_guide_support/1'||typeof v.can_bind!=='boolean'||!['ai','human'].includes(v.direction_mode)||!(v.can_bind?v.reason_code==='role_assignment_available':['role_assignment_unavailable','role_assignment_master_only'].includes(v.reason_code)))die('MF_D100_SCOPE');
 if(v.guide_character_id!==null&&!v.roster_character_ids.includes(v.guide_character_id)||v.support_character_id!==null&&(!v.roster_character_ids.includes(v.support_character_id)||v.support_character_id===v.guide_character_id||v.roster_character_ids.length===1))die('MF_D100_SCOPE_ROSTER');return structuredClone(v);
}
export function validateMissionD100RoleReceipt(v,p){
 if(!closed(v,['schema_version','binding_id','master_session_id','run_control_version','guide_character_id','support_character_id','state'])||v.schema_version!=='mission-d100-binding-receipt/1'||!d100Id(v.binding_id)||v.master_session_id!==p.p_session||v.run_control_version!==p.p_expected_run_cv||!d100Id(v.guide_character_id,true)||!d100Id(v.support_character_id,true)||v.guide_character_id!==null&&v.guide_character_id===v.support_character_id||p.p_guide!==null&&v.guide_character_id!==p.p_guide||p.p_support!==null&&v.support_character_id!==p.p_support||!['bound','waiting_role_assignment'].includes(v.state))die('MF_D100_ROLE_RECEIPT');return structuredClone(v);
}

// Porta UI collegabile alla stanza normale: non chiama post_dice né un provider.
// Facts/history richiedono il futuro producer pubblico: non sono dedotti dai messaggi o dalla fase.
export function mountMissionD100Roles(host,{rpc,identity,isCurrent=()=>true,session,characterId=()=>null,onConfirmed=()=>{},labels={},viewerMode=null,viewerCharacter=null,stateReader=null}={}){
 if(!host?.isConnected||typeof rpc!=='function'||typeof identity!=='function'||!d100Id(identity())||!d100Id(session))throw Error('Contesto della prova D100 non disponibile.');
 const principal=identity(),key='mission-d100-role-journal/1/'+principal+'/'+session+(viewerMode?'/'+viewerMode+'/'+(viewerCharacter||'master'):'');let disposed=false,epoch=0,scope=null,pending=null,receipt=null,busy=false,error='',journalError='',readPromise=null,runtimeState=null;
 const alive=()=>!disposed&&host.isConnected&&identity()===principal&&isCurrent();
 const el=(tag,text='')=>{const n=document.createElement(tag);n.textContent=text;return n;};
 const btn=(text,fn)=>{const n=el('button',text);n.type='button';n.className='mbtn';n.disabled=busy;n.addEventListener('click',()=>{if(alive()&&!busy)Promise.resolve().then(fn).catch(e=>{if(alive()){error=e.message;render();}});});return n;};
 const persist=()=>{const raw=JSON.stringify({schema_version:'mission-d100-role-journal/1',principal_id:principal,master_session_id:session,pending,receipt});sessionStorage.setItem(key,raw);if(sessionStorage.getItem(key)!==raw)throw Error('Richiesta non conservata: assegnazione sospesa.');};
 try{const raw=sessionStorage.getItem(key);if(raw){const j=JSON.parse(raw);if(!closed(j,['schema_version','principal_id','master_session_id','pending','receipt'])||j.schema_version!=='mission-d100-role-journal/1'||j.principal_id!==principal||j.master_session_id!==session)throw Error('Journal non attribuibile.');if(j.pending!==null){const p=j.pending;if(!closed(p,['p_session','p_expected_run_cv','p_guide','p_support','p_request'])||p.p_session!==session||!Number.isSafeInteger(p.p_expected_run_cv)||p.p_expected_run_cv<0||!d100Id(p.p_guide,true)||!d100Id(p.p_support,true)||!d100Id(p.p_request))throw Error('Richiesta di recupero non valida.');pending=structuredClone(p);}receipt=j.receipt;}}catch(e){journalError=e.message;error=e.message;}
 function render(){if(!alive())return;host.replaceChildren();host.classList.add('mc-human');const box=el('section');box.className='mc-card';box.append(el('h3','Prova D100 · guida e supporto'));host.append(box);
  if(error)box.append(el('p',error));if(journalError){box.append(el('p','Recupero locale non verificabile: nessuna nuova assegnazione consentita.'));return;}if(pending){box.append(el('p','Assegnazione non ancora confermata. Verifica la stessa richiesta prima di scegliere altri ruoli.'),btn('Verifica assegnazione',()=>send(true)));return;}
  if(!scope){box.append(el('p','Ruoli non disponibili in questa fase.'),btn('Aggiorna ruoli',refresh));return;}
  const name=id=>typeof labels[id]==='string'?labels[id]:id;box.append(el('p','Guida: '+(scope.guide_character_id?name(scope.guide_character_id):'da assegnare')));
  box.append(el('p',scope.roster_character_ids.length===1?'Un solo PG: non è previsto un supporto.':'Supporto: '+(scope.support_character_id?name(scope.support_character_id):'da assegnare')));
  const complete=scope.guide_character_id!==null&&(scope.roster_character_ids.length===1||scope.support_character_id!==null);
  if(complete)box.append(el('p','Ruoli confermati. I tiri si effettuano dalla stanza; l’esito appartiene al Fato della scena.'));
  const own=characterId();if(own&&scope.roster_character_ids.includes(own)&&![scope.guide_character_id,scope.support_character_id].includes(own))box.append(el('p','Non sei assegnato a guida o supporto.'));
  if(scope.can_bind&&!error&&(!viewerMode||runtimeState?.interaction_state==='active')){if(scope.direction_mode==='human'){const chooser=(title,value)=>{const label=el('label',title),s=el('select');const empty=el('option','Scegli PG…');empty.value='';s.append(empty);for(const id of scope.roster_character_ids.filter(id=>!viewerMode||runtimeState.role_offers.some(o=>o.character_id===id&&o.role===(title==='Guida'?'guide':'support')&&o.can_select||id===value))){const o=el('option',name(id));o.value=id;s.append(o);}s.value=value||'';s.disabled=value!==null;label.append(s);box.append(label);return s;};const g=chooser('Guida',scope.guide_character_id);let t=null;if(scope.roster_character_ids.length>1)t=chooser('Supporto',scope.support_character_id);box.append(btn('Conferma guida e supporto',()=>send(false,g.value,t?t.value:null)));}
   else if(own&&scope.roster_character_ids.includes(own)){if((scope.guide_character_id===null||scope.guide_character_id===own)&&scope.support_character_id!==own&&(!viewerMode||runtimeState.role_offers.some(o=>o.character_id===own&&o.role==='guide'&&o.can_select)))box.append(btn('Sono la guida',()=>send(false,own,scope.support_character_id)));if(scope.roster_character_ids.length>1&&((scope.support_character_id===null||scope.support_character_id===own)&&scope.guide_character_id!==own&&(!viewerMode||runtimeState.role_offers.some(o=>o.character_id===own&&o.role==='support'&&o.can_select))))box.append(btn('Sono il supporto',()=>send(false,scope.guide_character_id,own)));}}
  box.append(btn('Aggiorna ruoli',refresh));
 }
 async function refresh(){if(!alive()||busy)return;if(readPromise)return readPromise;const stamp=++epoch;scope=null;render();readPromise=(async()=>{try{let v;if(stateReader){const current=await stateReader();if(!alive()||stamp!==epoch)return;runtimeState=current;v=current.role_scope;const found=pending&&current.role_receipts.find(x=>x.request_key===pending.p_request);if(found){const confirmed=validateMissionD100RoleReceipt(found.receipt,pending),before=receipt,sent=pending;receipt=confirmed;pending=null;try{persist();}catch(storage){pending=sent;receipt=before;throw storage;}}}else v=validateMissionD100Scope(await rpc('mission_factory_mission_d100_scope_v1',{p_session:session}),session);if(!alive()||stamp!==epoch)return;scope=v;error=journalError;}catch(e){if(alive()&&stamp===epoch){scope=null;error='Ruoli non disponibili: '+(e.message||'aggiorna la scena.');}}finally{if(alive()&&stamp===epoch)render();readPromise=null;}})();return readPromise;}
 async function send(replay,guide=null,support=null){if(!alive()||busy||journalError)return;if(!replay){if(!scope?.can_bind||pending||error||viewerMode&&runtimeState?.interaction_state!=='active'||viewerMode==='player'&&scope.direction_mode==='human')return;if(!d100Id(guide,true)||!d100Id(support,true)||guide&&support===guide||guide!==null&&!scope.roster_character_ids.includes(guide)||support!==null&&(!scope.roster_character_ids.includes(support)||scope.roster_character_ids.length===1))throw Error('Scegli ruoli distinti tra i PG della squadra.');if(scope.direction_mode==='ai'){const own=characterId();if(!d100Id(own)||!(guide===own&&support===scope.support_character_id||support===own&&guide===scope.guide_character_id))throw Error('Puoi scegliere soltanto il tuo ruolo.');}pending={p_session:session,p_expected_run_cv:scope.run_control_version,p_guide:guide,p_support:support,p_request:crypto.randomUUID()};try{persist();}catch(e){pending=null;error=e.message;render();return;}}
  if(!pending||viewerMode&&(!runtimeState||viewerMode==='player'&&runtimeState.direction_mode==='human'))return;const sent=structuredClone(pending),stamp=++epoch;busy=true;render();try{const r=validateMissionD100RoleReceipt(await rpc('mission_factory_mission_d100_bind_v1',sent),sent);if(!alive()||stamp!==epoch)return;const previousReceipt=receipt;receipt=r;pending=null;error='';try{persist();}catch(storage){pending=sent;receipt=previousReceipt;throw storage;}onConfirmed(structuredClone(r));}catch(e){if(alive()&&stamp===epoch){error='Assegnazione non confermata: '+(e.message||'verifica la stessa richiesta.');try{persist();}catch(storage){error=storage.message;}}}finally{busy=false;if(alive()&&stamp===epoch){render();if(!pending)await refresh();}}
 }
 render();return {refresh,recover:()=>send(true),snapshot:()=>({scope:scope?structuredClone(scope):null,pending:pending?structuredClone(pending):null,receipt:receipt?structuredClone(receipt):null}),afterNativeDice:()=>refresh(),dispose:()=>{disposed=true;epoch++;host.replaceChildren();}};
}

// C679 · unico DTO Mission D100, viste PG/Master esplicite; nessun fatto dedotto dalla chat.
const d100Bool=x=>typeof x==='boolean',d100CV=x=>Number.isSafeInteger(x)&&x>=0,d100Roll=x=>Number.isInteger(x)&&x>=1&&x<=100;
const d100RoleOffer=x=>closed(x,['character_id','role','can_select'])&&d100Id(x.character_id)&&['guide','support'].includes(x.role)&&d100Bool(x.can_select);
export function validateMissionD100State(v,{session,view,character,location}){
 const fail=()=>die('MF_D100_STATE_DTO');
 if(!closed(v,['schema_version','master_session_id','viewer_mode','viewer_character_id','direction_mode','location_id','visible_step_key','visible_run_control_version','interaction_state','role_scope','role_offers','role_receipts','bindings','reason_code'])||v.schema_version!=='mission-d100-runtime-state/1'||v.master_session_id!==session||v.viewer_mode!==view||v.viewer_character_id!==(view==='master'?null:character)||!['ai','human'].includes(v.direction_mode)||v.location_id!==location||!d100CV(v.visible_run_control_version)||!(v.visible_step_key===null||D100_KEY.test(v.visible_step_key))||!['active','fato_pending','read_only'].includes(v.interaction_state)||v.reason_code!==({active:null,fato_pending:'MF_D100_FATO_PENDING',read_only:'MF_D100_READ_ONLY'}[v.interaction_state])||!Array.isArray(v.bindings)||!Array.isArray(v.role_offers)||!Array.isArray(v.role_receipts)||v.role_offers.some(x=>!d100RoleOffer(x)))fail();
 if(view==='master'&&(character!==null||v.direction_mode!=='human')||view==='player'&&!d100Id(character))fail();
 if(v.role_scope!==null){const s=validateMissionD100Scope(v.role_scope,session);if(s.run_control_version!==v.visible_run_control_version||s.step_key!==v.visible_step_key||s.direction_mode!==v.direction_mode||v.interaction_state!=='active')fail();if(view==='player'&&v.direction_mode==='human'&&s.can_bind)fail();}
 else if(v.role_offers.length)fail();
 const offered=new Set();for(const x of v.role_offers){const k=x.character_id+'/'+x.role;if(offered.has(k)||view==='player'&&x.character_id!==character||!v.role_scope?.roster_character_ids.includes(x.character_id)||x.role==='support'&&v.role_scope.roster_character_ids.length===1||x.can_select&&(!v.role_scope.can_bind||v.interaction_state!=='active'))fail();offered.add(k);}
 const ids=new Set();for(const b of v.bindings){if(!closed(b,['binding_id','step_key','run_control_version','native_policy_sha256','guide_character_id','support_character_id','progress','role_offers','rolls','receipt','master_report'])||!d100Id(b.binding_id)||ids.has(b.binding_id)||!D100_KEY.test(b.step_key)||!d100CV(b.run_control_version)||!D100_SHA.test(b.native_policy_sha256)||!d100Id(b.guide_character_id,true)||!d100Id(b.support_character_id,true)||b.guide_character_id!==null&&b.guide_character_id===b.support_character_id||!closed(b.progress,['state','guide_complete','support_required','support_complete','can_roll','can_bind','role_assignment_frozen','fato_pending'])||!['resolved','awaiting_fato','waiting_role_assignment','waiting_native_roles'].includes(b.progress.state)||Object.keys(b.progress).filter(k=>k!=='state').some(k=>!d100Bool(b.progress[k]))||!Array.isArray(b.role_offers)||b.role_offers.some(x=>!d100RoleOffer(x))||!Array.isArray(b.rolls))fail();ids.add(b.binding_id);
  if(view==='master'&&b.progress.can_roll||view==='player'&&v.direction_mode==='human'&&b.progress.can_bind||v.interaction_state!=='active'&&(b.progress.can_roll||b.progress.can_bind))fail();
  const rolls=new Set();for(const r of b.rolls){if(!closed(r,['character_id','role','message_id','result'])||!d100Id(r.character_id)||!['guide','support'].includes(r.role)||!d100Id(r.message_id)||!d100Roll(r.result)||rolls.has(r.role)||r.character_id!==(r.role==='guide'?b.guide_character_id:b.support_character_id))fail();rolls.add(r.role);}
  if(b.receipt!==null){const r=b.receipt;if(!closed(r,['schema_version','binding_id','event_id','request_key','facts_sha256','success','next_step_key','run_control_version','fato_message_id'])||r.schema_version!=='mission-d100-visible-receipt/1'||r.binding_id!==b.binding_id||!d100Id(r.event_id)||!d100Id(r.request_key)||!D100_SHA.test(r.facts_sha256)||!d100Bool(r.success)||!(r.next_step_key===null||D100_KEY.test(r.next_step_key))||!d100CV(r.run_control_version)||!d100Id(r.fato_message_id,true)||view==='player'&&r.fato_message_id===null)fail();}
  if(b.master_report!==null){const r=b.master_report;if(view!=='master'||!closed(r,['schema_version','binding_id','guide_result','support_result','base_threshold','support_threshold','effective_threshold','success'])||r.schema_version!=='mission-d100-master-report/1'||r.binding_id!==b.binding_id||!d100Roll(r.guide_result)||!(r.support_result===null||d100Roll(r.support_result))||['base_threshold','support_threshold','effective_threshold'].some(k=>!(r[k]===null||Number.isFinite(r[k])))||!d100Bool(r.success))fail();}
  if(view==='player'&&b.role_offers.some(x=>x.character_id!==character)||b.progress.state==='resolved'&&(!b.receipt?.fato_message_id||b.progress.fato_pending))fail();
 }
 const requests=new Set();for(const j of v.role_receipts){if(!closed(j,['request_key','binding_id','receipt'])||!d100Id(j.request_key)||!d100Id(j.binding_id)||requests.has(j.request_key)||!ids.has(j.binding_id)||!closed(j.receipt,['schema_version','binding_id','master_session_id','run_control_version','guide_character_id','support_character_id','state']))fail();validateMissionD100RoleReceipt(j.receipt,{p_session:session,p_expected_run_cv:j.receipt.run_control_version,p_guide:j.receipt.guide_character_id,p_support:j.receipt.support_character_id});if(j.binding_id!==j.receipt.binding_id||!d100CV(j.receipt.run_control_version))fail();requests.add(j.request_key);}
 if(view==='player'&&v.direction_mode==='human'&&v.role_receipts.length)fail();
 return structuredClone(v);
}
export function mountMissionD100Runtime(host,{rpc,identity,isCurrent=()=>true,session,viewerMode,characterId=()=>null,locationId,ensureFato=async()=>false,onState=()=>{},onError=()=>{},labels={}}={}){
 if(!['player','master'].includes(viewerMode)||!d100Id(locationId))throw Error('Vista D100 non disponibile.');
 const principal=identity(),character=viewerMode==='master'?null:characterId();if(!d100Id(principal)||viewerMode==='player'&&!d100Id(character))throw Error('Identità della vista D100 mancante.');
 let disposed=false,readEpoch=0,state=null,error=null,reading=null;const alive=()=>!disposed&&host.isConnected&&identity()===principal&&isCurrent()&&(viewerMode==='master'||characterId()===character);
 const node=(tag,text='')=>{const n=document.createElement(tag);n.textContent=text;return n;};
 const roles=document.createElement('section'),history=document.createElement('section');host.replaceChildren(roles,history);host.classList.add('mc-human');
 const name=id=>typeof labels[id]==='string'?labels[id]:id;
 function draw(){if(!alive())return;history.replaceChildren();history.append(node('h3',viewerMode==='master'?'D100 · rapporto riservato al Master':'D100 · fatti della scena'));
  if(error)history.append(node('p',error));if(!state)return;
  history.append(node('p',state.interaction_state==='fato_pending'?'Il Fato è in pubblicazione: attori e passaggi restano in attesa.':state.interaction_state==='read_only'?'Storico in sola lettura. Nessun nuovo tiro o comando è disponibile.':'Prova Native della missione.'));
  for(const b of state.bindings){const section=node('section');section.className='mc-card';section.append(node('strong','Fase '+b.step_key+' · versione '+b.run_control_version));
   const status={resolved:'Prova risolta e Fato pubblicato.',awaiting_fato:'Esito server risolto: attende il Fato.',waiting_role_assignment:'Assegna esplicitamente guida e supporto.',waiting_native_roles:'Attende i tiri dei ruoli assegnati.'};section.append(node('p',status[b.progress.state]));
   section.append(node('p','Guida: '+(b.guide_character_id?name(b.guide_character_id):'da assegnare')+' · Supporto: '+(b.progress.support_required?(b.support_character_id?name(b.support_character_id):'da assegnare'):'non previsto')));
   for(const r of b.rolls)section.append(node('p',(r.role==='guide'?'Guida':'Supporto')+' '+name(r.character_id)+' · D100 '+r.result+' · ricevuta '+r.message_id));
   section.append(node('p','Guida '+(b.progress.guide_complete?'completata':'in attesa')+'; supporto '+(!b.progress.support_required?'non richiesto':!b.support_character_id?'da assegnare':b.progress.support_complete?'completato':'in attesa')+'.'));
   if(b.receipt?.fato_message_id)section.append(node('p',(b.receipt.success?'Prova riuscita.':'Prova non riuscita.')+' Fato '+b.receipt.fato_message_id+(b.receipt.next_step_key?' · fase successiva '+b.receipt.next_step_key:' · conclusione')));
   if(viewerMode==='master'&&b.master_report){const r=b.master_report;section.append(node('p','Rapporto meccanico riservato · guida '+r.guide_result+(r.support_result===null?'':' · supporto '+r.support_result)+' · soglia base '+r.base_threshold+' · soglia supporto '+r.support_threshold+' · soglia effettiva '+r.effective_threshold+' · '+(r.success?'riuscita':'non riuscita')));}
   if(b.progress.can_roll)section.append(node('p','È il tuo tiro: usa il dado D100 della stanza.'));history.append(section);
  }
  if(!state.bindings.length)history.append(node('p','Nessun tiro registrato. La prima assegnazione crea la ricevuta Native.'));
 }
 async function read(){if(!alive())throw Error('Vista D100 chiusa.');if(reading)return reading;const stamp=++readEpoch;state=null;onState(null);reading=(async()=>{try{const next=validateMissionD100State(await rpc('mission_factory_mission_d100_state_v1',{p_session:session,p_view:viewerMode,p_character:character}),{session,view:viewerMode,character,location:locationId});if(!alive()||stamp!==readEpoch)throw Error('Contesto D100 cambiato.');
    const published=next.bindings.map(b=>b.receipt).filter(r=>r?.fato_message_id).sort((a,b)=>b.run_control_version-a.run_control_version);for(const id of published.length?[published[0].fato_message_id]:[]){if(!(await ensureFato(id))||!alive()||stamp!==readEpoch)throw Error('Fato non ancora visibile: aggiorna la scena prima di agire.');}
    state=next;error=null;onState(structuredClone(state));draw();return structuredClone(state);
   }catch(e){if(alive()&&stamp===readEpoch){state=null;error=e.message||'Stato Native non disponibile.';onState(null);onError(e);draw();}throw e;}finally{reading=null;}})();return reading;}
 const panel=mountMissionD100Roles(roles,{rpc,identity,isCurrent:alive,session,characterId,labels,viewerMode,viewerCharacter:character,stateReader:read,onConfirmed:()=>{void refresh();}});
 async function refresh(){try{await panel.refresh();}catch{}draw();return state?structuredClone(state):null;}
 return {refresh,recover:async()=>{await panel.refresh();await panel.recover();await refresh();},afterNativeDice:refresh,snapshot:()=>({state:state?structuredClone(state):null,roles:panel.snapshot()}),diceAllowed:()=>{if(!state)return false;return state.interaction_state==='active'&&state.bindings.some(b=>b.step_key===state.visible_step_key&&b.run_control_version===state.visible_run_control_version&&b.progress.can_roll);},dispose:()=>{disposed=true;readEpoch++;panel.dispose();host.replaceChildren();onState(null);}};
}
