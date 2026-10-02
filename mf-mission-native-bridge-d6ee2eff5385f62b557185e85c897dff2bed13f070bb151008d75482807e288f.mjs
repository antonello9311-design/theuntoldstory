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
export function seedMissionNativeModel(source,npcProjection,{draftId,expectedVersion,mode,catalog}={}) {
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
    if (!['narrative','combat'].includes(phase.kind) || !Array.isArray(phase.actor_keys) || !unique(phase.actor_keys) ||
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
      return {trigger_key:t.transition_key,transition_key:t.transition_key,...factoryEventProjection(t,mode,catalog,phase.kind),
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
