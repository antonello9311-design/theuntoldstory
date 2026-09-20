export const SCHEMA_VERSION='mission-authoring-output/1';
export const EDGE_REVISION='mission-authoring-ai/2026-09-19.mvp5';
export const TERMINAL_TYPES=Object.freeze(['victory','defeat','surrender_after_exchanges','escape','protect_subject','reach_position','survive_rounds']);
export const NATIVE_TERMINAL_TYPES=Object.freeze(['surrender_after_exchanges','escape','protect_subject','reach_position','survive_rounds']);
export const PHASE_KINDS=Object.freeze(['narrative','exploration','combat']);
export const GRADES=Object.freeze(['D','C','B','A','S']);
export const TEAMS=Object.freeze(['alleati','avversari','civili']);

const text=(maxLength,minLength=1)=>({type:'string',minLength,maxLength});
const nullableText=maxLength=>({type:['string','null'],maxLength});
const stringArray=(maxItems,maxLength)=>({type:'array',maxItems,items:text(maxLength)});

export const AUTHORING_SCHEMA=Object.freeze({
  type:'object',additionalProperties:false,
  required:['schema_version','mission','phases','actors','terminal_rules','map_request'],
  properties:{
    schema_version:{type:'string',const:SCHEMA_VERSION},
    mission:{type:'object',additionalProperties:false,
      required:['title','grade','team_min','team_max','briefing_public','background_private','narrator_instructions','opening'],
      properties:{title:text(120),grade:{type:'string',enum:GRADES},team_min:{type:'integer',minimum:1,maximum:4},team_max:{type:'integer',minimum:1,maximum:4},briefing_public:text(4000),background_private:text(8000),narrator_instructions:text(5000),opening:text(3000)}},
    phases:{type:'array',minItems:1,maxItems:8,items:{type:'object',additionalProperties:false,
      required:['step_key','title','kind','public_objective','private_objective','narrator_notes','actor_keys','transitions'],
      properties:{step_key:text(48),title:text(120),kind:{type:'string',enum:PHASE_KINDS},public_objective:text(1200),private_objective:text(1600),narrator_notes:text(2400),actor_keys:stringArray(12,48),transitions:{type:'array',maxItems:6,items:{type:'object',additionalProperties:false,required:['transition_key','to_step_key','when','public_result','private_note'],properties:{transition_key:text(48),to_step_key:nullableText(48),when:text(800),public_result:text(800),private_note:text(1200)}}}}}},
    actors:{type:'array',maxItems:12,items:{type:'object',additionalProperties:false,
      required:['actor_key','display_name','role','team','identity','personality','behavior','public_knowledge','private_knowledge','limits','mechanical_request'],
      properties:{actor_key:text(48),display_name:text(120),role:text(160),team:{type:'string',enum:TEAMS},identity:text(1200),personality:text(1600),behavior:text(1600),public_knowledge:stringArray(12,600),private_knowledge:stringArray(12,600),limits:stringArray(12,600),mechanical_request:{type:'object',additionalProperties:false,required:['archetype_tags','combat_role','desired_grade'],properties:{archetype_tags:stringArray(8,64),combat_role:text(80),desired_grade:{type:'string',enum:GRADES}}}}}},
    terminal_rules:{type:'array',maxItems:16,items:{type:'object',additionalProperties:false,
      required:['rule_key','phase_key','type','subject_key','threshold','outcome','transition_key'],
      properties:{rule_key:text(48),phase_key:text(48),type:{type:'string',enum:TERMINAL_TYPES},subject_key:nullableText(48),threshold:{type:['integer','null'],minimum:1,maximum:99},outcome:{type:'string',enum:['success','failure']},transition_key:nullableText(48)}}},
    map_request:{type:'object',additionalProperties:false,required:['mode','width_cells','height_cells','important_objects','notes'],properties:{mode:{type:'string',enum:['default10','specific']},width_cells:{type:['integer','null'],minimum:4,maximum:40},height_cells:{type:['integer','null'],minimum:4,maximum:40},important_objects:stringArray(20,160),notes:text(1200,0)}}
  }
});

const own=(o,k)=>Object.prototype.hasOwnProperty.call(o,k);
const object=(v,label)=>{if(!v||typeof v!=='object'||Array.isArray(v))throw new Error(`AUTHORING_${label}_OBJECT`);return v};
const exact=(o,keys,label)=>{object(o,label);const actual=Object.keys(o);if(actual.some(k=>!keys.includes(k))||keys.some(k=>!own(o,k)))throw new Error(`AUTHORING_${label}_KEYS`)};
const str=(v,label,max,empty=false)=>{if(typeof v!=='string'||(!empty&&!v.trim())||v.length>max)throw new Error(`AUTHORING_${label}_TEXT`);return v.trim()};
const key=(v,label)=>{const x=str(v,label,48);if(!/^[a-z][a-z0-9_]{1,47}$/.test(x))throw new Error(`AUTHORING_${label}_KEY`);return x};
const strings=(v,label,maxItems,maxLength)=>{if(!Array.isArray(v)||v.length>maxItems)throw new Error(`AUTHORING_${label}_ARRAY`);return v.map((x,i)=>str(x,`${label}_${i}`,maxLength))};
const unique=(items,label)=>{if(new Set(items).size!==items.length)throw new Error(`AUTHORING_${label}_DUPLICATE`)};
const forbidden=new Set(['stats','statistics','pv','hp','chakra','techniques','tecniche','jutsu','chakra_cost','damage','danno','potenza','disciplina']);
function rejectMechanics(value,path='root'){
  if(Array.isArray(value)){value.forEach((v,i)=>rejectMechanics(v,`${path}_${i}`));return}
  if(!value||typeof value!=='object')return;
  for(const [k,v] of Object.entries(value)){if(forbidden.has(k.toLowerCase()))throw new Error(`AUTHORING_FORBIDDEN_MECHANIC_${path}_${k}`);rejectMechanics(v,`${path}_${k}`)}
}

export function validateAuthoringOutput(value,{hasMapImage=false}={}){
  const root=object(value,'ROOT');
  exact(root,['schema_version','mission','phases','actors','terminal_rules','map_request'],'ROOT');
  if(root.schema_version!==SCHEMA_VERSION)throw new Error('AUTHORING_SCHEMA_VERSION');
  rejectMechanics(root);
  const m=root.mission;exact(m,['title','grade','team_min','team_max','briefing_public','background_private','narrator_instructions','opening'],'MISSION');
  str(m.title,'TITLE',120);if(!GRADES.includes(m.grade))throw new Error('AUTHORING_GRADE');
  if(!Number.isInteger(m.team_min)||!Number.isInteger(m.team_max)||m.team_min<1||m.team_max>4||m.team_min>m.team_max)throw new Error('AUTHORING_TEAM');
  str(m.briefing_public,'BRIEFING',4000);str(m.background_private,'BACKGROUND',8000);str(m.narrator_instructions,'NARRATOR',5000);str(m.opening,'OPENING',3000);
  if(!Array.isArray(root.actors)||root.actors.length>12)throw new Error('AUTHORING_ACTORS_ARRAY');
  const actorKeys=root.actors.map((a,i)=>{exact(a,['actor_key','display_name','role','team','identity','personality','behavior','public_knowledge','private_knowledge','limits','mechanical_request'],`ACTOR_${i}`);const ak=key(a.actor_key,`ACTOR_${i}`);str(a.display_name,'DISPLAY_NAME',120);str(a.role,'ROLE',160);if(!TEAMS.includes(a.team))throw new Error('AUTHORING_ACTOR_TEAM');str(a.identity,'IDENTITY',1200);str(a.personality,'PERSONALITY',1600);str(a.behavior,'BEHAVIOR',1600);strings(a.public_knowledge,'PUBLIC_KNOWLEDGE',12,600);strings(a.private_knowledge,'PRIVATE_KNOWLEDGE',12,600);strings(a.limits,'LIMITS',12,600);exact(a.mechanical_request,['archetype_tags','combat_role','desired_grade'],`MECHANICAL_${i}`);strings(a.mechanical_request.archetype_tags,'ARCHETYPE_TAGS',8,64);str(a.mechanical_request.combat_role,'COMBAT_ROLE',80);if(!GRADES.includes(a.mechanical_request.desired_grade))throw new Error('AUTHORING_ACTOR_GRADE');return ak});
  unique(actorKeys,'ACTOR_KEY');const actorSet=new Set(actorKeys);
  if(!Array.isArray(root.phases)||root.phases.length<1||root.phases.length>8)throw new Error('AUTHORING_PHASES_ARRAY');
  const phaseKeys=root.phases.map((p,i)=>key(p.step_key,`PHASE_${i}`));unique(phaseKeys,'PHASE_KEY');const phaseSet=new Set(phaseKeys);const phaseKinds=new Map(root.phases.map(p=>[p.step_key,p.kind]));const transitions=[];
  root.phases.forEach((p,i)=>{exact(p,['step_key','title','kind','public_objective','private_objective','narrator_notes','actor_keys','transitions'],`PHASE_${i}`);str(p.title,'PHASE_TITLE',120);if(!PHASE_KINDS.includes(p.kind))throw new Error('AUTHORING_PHASE_KIND');str(p.public_objective,'PUBLIC_OBJECTIVE',1200);str(p.private_objective,'PRIVATE_OBJECTIVE',1600);str(p.narrator_notes,'PHASE_NOTES',2400);const aks=strings(p.actor_keys,'PHASE_ACTORS',12,48);unique(aks,`PHASE_ACTORS_${i}`);if(aks.some(x=>!actorSet.has(x)))throw new Error('AUTHORING_PHASE_ACTOR_REF');if(!Array.isArray(p.transitions)||p.transitions.length>6)throw new Error('AUTHORING_TRANSITIONS_ARRAY');p.transitions.forEach((t,j)=>{exact(t,['transition_key','to_step_key','when','public_result','private_note'],`TRANSITION_${i}_${j}`);const tk=key(t.transition_key,`TRANSITION_${i}_${j}`);transitions.push(tk);if(t.to_step_key!==null&&!phaseSet.has(t.to_step_key))throw new Error('AUTHORING_TRANSITION_PHASE_REF');str(t.when,'TRANSITION_WHEN',800);str(t.public_result,'TRANSITION_PUBLIC',800);str(t.private_note,'TRANSITION_PRIVATE',1200)})});
  unique(transitions,'TRANSITION_KEY');const transitionSet=new Set(transitions);
  if(!Array.isArray(root.terminal_rules)||root.terminal_rules.length>16)throw new Error('AUTHORING_RULES_ARRAY');const ruleKeys=[];
  const nativeByPhase=new Map();
  root.terminal_rules.forEach((r,i)=>{exact(r,['rule_key','phase_key','type','subject_key','threshold','outcome','transition_key'],`RULE_${i}`);ruleKeys.push(key(r.rule_key,`RULE_${i}`));if(!phaseSet.has(r.phase_key)||!TERMINAL_TYPES.includes(r.type)||!['success','failure'].includes(r.outcome))throw new Error('AUTHORING_RULE_ENUM');if(phaseKinds.get(r.phase_key)!=='combat')throw new Error('AUTHORING_RULE_PHASE');if((r.type==='victory'&&r.outcome!=='success')||(r.type==='defeat'&&r.outcome!=='failure'))throw new Error('AUTHORING_RULE_OUTCOME');const needsSubject=['escape','protect_subject','reach_position'].includes(r.type),hasStableSubject=typeof r.subject_key==='string'&&/^[a-z][a-z0-9_]{1,47}$/.test(r.subject_key);if((needsSubject&&!hasStableSubject)||(r.subject_key!==null&&!hasStableSubject))throw new Error('AUTHORING_RULE_SUBJECT');if(r.type==='escape'&&!actorSet.has(r.subject_key))throw new Error('AUTHORING_RULE_ESCAPE_ACTOR');const needsThreshold=['surrender_after_exchanges','survive_rounds'].includes(r.type);if(needsThreshold?(!Number.isInteger(r.threshold)||r.threshold<1||r.threshold>99):r.threshold!==null)throw new Error('AUTHORING_RULE_THRESHOLD');if(r.transition_key!==null&&!transitionSet.has(r.transition_key))throw new Error('AUTHORING_RULE_TRANSITION');if(NATIVE_TERMINAL_TYPES.includes(r.type)){const count=(nativeByPhase.get(r.phase_key)||0)+1;nativeByPhase.set(r.phase_key,count);if(count>1)throw new Error('AUTHORING_RULE_NATIVE_AMBIGUOUS')}});unique(ruleKeys,'RULE_KEY');
  const map=root.map_request;exact(map,['mode','width_cells','height_cells','important_objects','notes'],'MAP');if(!['default10','specific'].includes(map.mode)||map.mode!==(hasMapImage?'specific':'default10'))throw new Error('AUTHORING_MAP_MODE');if(map.mode==='default10'?(map.width_cells!==null||map.height_cells!==null):(!Number.isInteger(map.width_cells)||!Number.isInteger(map.height_cells)||map.width_cells<4||map.width_cells>40||map.height_cells<4||map.height_cells>40))throw new Error('AUTHORING_MAP_SIZE');strings(map.important_objects,'MAP_OBJECTS',20,160);str(map.notes,'MAP_NOTES',1200,true);
  return structuredClone(root);
}
