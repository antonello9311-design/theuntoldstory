// Documento puro: nessuna selezione di revisione, RPC, catalogo remoto o autorità di gioco.
const clone=v=>structuredClone(v),same=(a,b)=>JSON.stringify(a)===JSON.stringify(b);
const freeze=v=>{if(v&&typeof v==='object'){Object.values(v).forEach(freeze);Object.freeze(v);}return v;};
const fail=message=>{throw Error(message);};
function index(items,key,label){if(!Array.isArray(items))fail(`${label}: elenco mancante.`);const map=new Map();for(const v of items){if(!v||typeof v[key]!=='string'||!v[key]||map.has(v[key]))fail(`${label}: chiave mancante o duplicata.`);map.set(v[key],v);}return map;}
const mentions=(v,key)=>v===key||!!v&&typeof v==='object'&&Object.values(v).some(x=>mentions(x,key));
const actorFields=['mechanical_binding_id','narrative_template_id','narrative_version_id','team'];
const setting=()=>({name:'',description:''});
const editorial=key=>({step_key:key,setting:setting(),director_notes:'',entry_public:'',actors:[],consequences:[]});
export function createExistingVariantFormDocument({document,head}={}){
 if(document?.schema_version!=='mission-creation-document/1'||document.plan?.schema_version!=='mission-generic-plan-document/1'||document.plan.definition?.schema_version!=='mission-generic-definition/1'||!['ai','human'].includes(document.mission?.direction_mode))fail('Documento nativo della variante non valido.');
 if(head===null||head===undefined)fail('Serve la head autorevole della variante; il form non sceglie la revisione più recente.');
 const original=freeze(clone(document)),opaqueHead=freeze(clone(head));
 const steps=index(original.plan.steps,'step_key','Fasi'),scenes=index(original.plan.definition.scenes,'step_key','Scene'),transitions=index(original.plan.transitions,'transition_key','Passaggi');
 const eds=index(original.editorial.scenes,'step_key','Note di fase'),terminals=index(original.plan.terminal_steps,'step_key','Conclusioni'),arenas=index(original.arenas,'step_key','Mappe');
 if(steps.size!==scenes.size||[...scenes.keys()].some(k=>!steps.has(k))||!steps.has(original.plan.initial_step_key))fail('Fasi e scene non coincidono.');
 for(const t of transitions.values())if(!steps.has(t.from_step_key)||!steps.has(t.to_step_key))fail('Passaggio riferito a una fase assente.');
 for(const [k,s] of scenes){index(s.actors,'actor_key',`Attori ${k}`);index(s.encounters,'encounter_key',`Incontri ${k}`);index(s.triggers,'trigger_key',`Eventi ${k}`);for(const e of s.encounters)index(e.actors,'actor_key',`Attori incontro ${e.encounter_key}`);for(const t of s.triggers){const tr=transitions.get(t.transition_key);if(!tr||tr.from_step_key!==k)fail('Evento senza passaggio coerente.');}}
 function model(){const actors=new Map();return {mission:clone(original.mission),editorial:{plot_private:original.editorial.plot_private??'',setting:{...setting(),...clone(original.editorial.setting??{})}},base:original.plan.base_plan_version_id??null,initial:original.plan.initial_step_key,counter:1,revision:null,catalog:null,actors:[...scenes.values()].flatMap(s=>s.actors).filter(a=>{if(actors.has(a.actor_key))return false;actors.set(a.actor_key,true);return true;}).map(clone),scenes:original.plan.steps.map(step=>{const cfg=scenes.get(step.step_key),e=cfg.encounters[0]??null;return {step_key:step.step_key,kind:step.kind,public_objective:step.public_objective,actors:cfg.actors.map(a=>a.actor_key),actor_specs:Object.fromEntries(cfg.actors.map(a=>[a.actor_key,clone(a)])),fighters:(e?.actors??[]).map(a=>a.actor_key),encounter:clone(e),encounter_key:e?.encounter_key??'enc_'+step.step_key,pg_team:e?.pg_team??'squadra',terminal:terminals.get(step.step_key)?.outcome??'',triggers:cfg.triggers.map(t=>({...clone(t),transition:clone(transitions.get(t.transition_key)),to:transitions.get(t.transition_key).to_step_key})),editorial:{...editorial(step.step_key),...clone(eds.get(step.step_key)??{}),setting:{...setting(),...clone(eds.get(step.step_key)?.setting??{})}},arena:clone(arenas.get(step.step_key)??null)};})};}
 // Conservative guard: dependencies are not removed or reinterpreted to make a form edit fit.
 function guard(action,{actor=null,step=null,trigger=null,model:m}={}){
  const s=m?.scenes.find(x=>x.step_key===step),cfg=scenes.get(step);
  if(action==='phase-kind'||action==='phase-terminal'){
   if(s?.triggers.length||cfg?.encounters.length||cfg?.arrival_conflict||cfg?.entry_policy)fail('La fase ha eventi, incontri o regole d’ingresso collegati. Modificare il tipo o la conclusione richiede un adattatore qualificato; nessun evento è stato riscritto.');
  }else if(action==='actor-remove'){
   if(m?.scenes.some(x=>x.actors.includes(actor)||x.fighters.includes(actor))||mentions(original,actor))fail('Il PNG è referenziato da fasi o configurazioni: rimuovi prima i collegamenti tramite un percorso qualificato.');
  }else if(action==='phase-actor-remove'||action==='fighter-remove'||action==='profile-change'){
   const relevant=action==='profile-change'?[...scenes.values()]:cfg?[cfg]:[];
   if(relevant.some(x=>mentions(x.encounters,actor)||mentions(x.triggers,actor)||mentions(x.arrival_conflict,actor)||mentions(x.entry_policy,actor)))fail('Il profilo/attore è usato da incontri o eventi: il form non elimina quei riferimenti implicitamente.');
  }else if(action==='phase-remove'){
   if(m?.initial===step||m?.scenes.some(x=>x.step_key!==step&&x.triggers.some(t=>t.to===step))||cfg?.actors.length||cfg?.encounters.length||cfg?.triggers.length||cfg?.arrival_conflict||cfg?.entry_policy)fail('La fase è iniziale o contiene riferimenti: rimozione bloccata senza cancellare eventi o attori.');
  }else if(action==='trigger-remove'){
   const target=s?.triggers.find(t=>t.trigger_key===trigger),tk=target?.transition_key;
   if(tk&&([...scenes.values()].some(x=>x.triggers.some(t=>t.trigger_key!==trigger&&mentions(t,tk)))||mentions(transitions.get(tk)?.payload,tk)))fail('Il passaggio è referenziato da altri eventi o payload.');
   // Opaque config may refer to event identities: don't silently repair unknown references.
   if(cfg&&Object.entries(cfg).some(([k,v])=>!['step_key','actors','encounters','triggers'].includes(k)&&(mentions(v,tk)||mentions(v,trigger))))fail('Il passaggio è referenziato da una configurazione specializzata.');
  }else fail('Operazione strutturale non prevista dal contratto del form.');
  // Same structural whitelist for UI handlers and the public pure finalizer.
  // Dependency diagnostics above never grant permission when no link exists.
  fail('Tipo, conclusione, profilo, schieramento e struttura sono di sola lettura in questa tranche.');
 }
 function finish(m,before){
  if(!before||!same(m.mission,before.mission)||!same(m.mission,original.mission)||m.base!==before.base)fail('Metadati missione e baseline sono di sola lettura.');
  if(!same(m.actors,before.actors))fail('Roster e profili globali sono di sola lettura in questa tranche.');
  const out=clone(original),patch=[];const beforeScenes=index(before.scenes,'step_key','Modello iniziale'),next=index(m.scenes,'step_key','Modello modificato');
  if(next.size!==beforeScenes.size||[...beforeScenes.keys()].some(k=>!next.has(k)))fail('Aggiunta/rimozione di fasi richiede il contratto del producer; documento originale conservato.');
  function set(object,k,v,path){object[k]=clone(v);patch.push({op:'set',path:[...path,k],value:clone(v)});}
  function fields(obj,b,a,names,path){for(const k of names)if(!same(b?.[k],a?.[k]))set(obj,k,a[k],path);}
  function notes(obj,b,a,path){fields(obj,b,a,['plot_private','director_notes','entry_public'],path);for(const k of ['name','description'])if(!same(b?.setting?.[k],a?.setting?.[k])){obj.setting??={};set(obj.setting,k,a.setting[k],[...path,'setting']);}}
  const outSteps=index(out.plan.steps,'step_key','Output fasi'),outScenes=index(out.plan.definition.scenes,'step_key','Output scene'),outTransitions=index(out.plan.transitions,'transition_key','Output passaggi');
  if(m.initial!==before.initial){if(!next.has(m.initial))fail('Fase iniziale assente.');set(out.plan,'initial_step_key',m.initial,['plan']);}
  const order=m.scenes.map(s=>s.step_key);if(!same(order,before.scenes.map(s=>s.step_key))){out.plan.steps=order.map(k=>outSteps.get(k));patch.push({op:'order',path:['plan','steps'],keys:order});}
  notes(out.editorial,before.editorial,m.editorial,['editorial']);
  for(const [k,s] of next){const b=beforeScenes.get(k),dst=outScenes.get(k),path=['plan','definition','scenes',{step_key:k}],step=outSteps.get(k);
   if(s.kind!==b.kind)guard('phase-kind',{step:k,model:before});if(s.terminal!==b.terminal)guard('phase-terminal',{step:k,model:before});fields(step,b,s,['kind','public_objective'],['plan','steps',{step_key:k}]);
   if(s.terminal!==b.terminal){const old=out.plan.terminal_steps.find(x=>x.step_key===k);if(s.terminal){if(!['success','failure'].includes(s.terminal))fail('Conclusione non valida.');if(old)set(old,'outcome',s.terminal,['plan','terminal_steps',{step_key:k}]);else{out.plan.terminal_steps.push({step_key:k,outcome:s.terminal});patch.push({op:'add',path:['plan','terminal_steps'],value:{step_key:k,outcome:s.terminal}});}}else{out.plan.terminal_steps=out.plan.terminal_steps.filter(x=>x.step_key!==k);patch.push({op:'remove',path:['plan','terminal_steps',{step_key:k}]});}}
   if(!same(s.actors,b.actors))fail('Modifica del roster di fase richiede il contratto del producer; nessun attore rimosso implicitamente.');
   const sourceActors=index(dst.actors,'actor_key','Output attori');for(const actor of s.actors){const aa=s.actor_specs[actor],bb=b.actor_specs[actor];if(!aa||!bb)fail('Specifica attore assente.');if(actorFields.some(f=>!same(aa[f],bb[f]))){guard('profile-change',{actor,step:k,model:before});fields(sourceActors.get(actor),bb,aa,actorFields,[...path,'actors',{actor_key:actor}]);}}
   // Encounters, including narrative and additional encounters, are never rebuilt from the phase kind.
   if(!same(s.fighters,b.fighters))fail('Modifica combattenti richiede un delta incontri qualificato.');
   if(s.pg_team!==b.pg_team){const e=dst.encounters[0];if(!e||dst.encounters.length!==1)fail('Incontro principale ambiguo.');set(e,'pg_team',s.pg_team,[...path,'encounters',{encounter_key:e.encounter_key}]);}
   const bt=index(b.triggers,'trigger_key','Eventi iniziali'),nt=index(s.triggers,'trigger_key','Eventi modificati');
   if(bt.size!==nt.size||[...bt.keys()].some(t=>!nt.has(t)))fail('Aggiunta/rimozione eventi richiede il contratto del producer; originale conservato.');
   for(const [tk,t] of nt){const old=bt.get(tk),actual=dst.triggers.find(x=>x.trigger_key===tk),tr=outTransitions.get(actual.transition_key),tp=[...path,'triggers',{trigger_key:tk}];
    // Source, facts, event family, encounter and outcome are opaque until their producer contract is frozen.
    for(const f of ['source_kind','fact_code','encounter_key','combat_outcome','transition_key'])if(!same(t[f],old[f]))fail(`Evento ${tk}: ${f} non è modificabile senza contratto qualificato.`);
    fields(actual,old,t,['label'],tp);
    if(!same(t.editorial,old.editorial)){let ed=out.editorial.scenes.find(x=>x.step_key===k);if(!ed){ed={step_key:k};out.editorial.scenes.push(ed);}ed.consequences??=[];let consequence=ed.consequences.find(x=>x.transition_key===actual.transition_key);if(!consequence){consequence={transition_key:actual.transition_key};ed.consequences.push(consequence);}fields(consequence,old.editorial,t.editorial,['public_fact','private_note'],['editorial','scenes',{step_key:k},'consequences',{transition_key:actual.transition_key}]);}
    if(t.to!==old.to){if(!next.has(t.to))fail('Destinazione passaggio assente.');set(tr,'to_step_key',t.to,['plan','transitions',{transition_key:actual.transition_key}]);}
   }
   // Materialize only an actually edited editorial field; untouched absent/defaulted fields stay absent.
   let e=out.editorial.scenes.find(x=>x.step_key===k);if(!same(s.editorial,b.editorial)){if(!e){e={step_key:k};out.editorial.scenes.push(e);}notes(e,b.editorial,s.editorial,['editorial','scenes',{step_key:k}]);
    for(const group of ['actors','consequences']){const key=group==='actors'?'actor_key':'transition_key',names=group==='actors'?['role_in_phase','goal_private','known_facts_private','public_portrayal']:['public_fact','private_note'],bb=index(b.editorial[group]??[],key,'Note iniziali'),aa=index(s.editorial[group]??[],key,'Note modificate');for(const [id,n] of aa){const previous=bb.get(id);if(!previous||same(previous,n))continue;let target=e[group]?.find(x=>x[key]===id);if(!target){e[group]??=[];target={[key]:id};e[group].push(target);}fields(target,previous,n,names,['editorial','scenes',{step_key:k},group,{[key]:id}]);}}
   }
   if(!same(s.arena,b.arena)){if(!s.arena)fail('Rimozione mappa non disponibile.');let a=out.arenas.find(x=>x.step_key===k);if(!a){a={step_key:k};out.arenas.push(a);}fields(a,b.arena,s.arena,['template_key','template_version','zone_key'],['arenas',{step_key:k}]);}
  }
  if(!same(m.actors,before.actors))fail('Modifica dei profili globali in attesa del contratto del producer. Nessuna sostituzione implicita dei pin.');
  const blockers=[];if(original.mission.direction_mode==='human'&&[...scenes.values()].some(s=>s.triggers.some(t=>t.source_kind==='spatial_event')))blockers.push({code:'EXISTING_HUMAN_SPATIAL_VALIDATOR_UNSUPPORTED',message:'Il validatore nativo umano non accetta spatial_event. Serve adattatore server: nessun evento convertito in scelta PG.'});
  return {schema_version:'existing-variant-form-result/1',state:blockers.length?'blocked_native_validator':'prepared_source',head:clone(opaqueHead),document:blockers.length?clone(original):out,proposed_document:blockers.length?out:null,dirty_patch:{schema_version:'existing-variant-form-patch/1',operations:patch},blockers};
 }
 return Object.freeze({model,guard,finish,original:()=>clone(original),head:()=>clone(opaqueHead)});
}
