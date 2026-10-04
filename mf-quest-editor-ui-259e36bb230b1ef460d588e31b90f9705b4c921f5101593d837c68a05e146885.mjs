import {createHumanQuestAuthoring} from './mf-human-quest-authoring-ui-2e42cfad969da8713b81aefcd32786fcef7353a9f719c2d7dd4c73722f7fdb8f.mjs';
import {QuestFactoryEditor,isQuestFixed30Policy} from './mf-quest-editor-core-6516a2e40111eb636b8c82fa76c5a40cf1fc72987177fc8d2f33956b4256a0e5.mjs';

// Pannello Quest candidato: usa solo riferimenti e policy attestati dal server.
const node=(tag,text='')=>{const x=document.createElement(tag);if(text)x.textContent=text;return x;};
const button=(text,action)=>{const x=node('button',text);x.type='button';x.addEventListener('click',action);return x;};
const field=(title,value,change,multi=false)=>{const label=node('label'),input=node(multi?'textarea':'input');
  label.append(node('span',title),input);input.value=value??'';input.addEventListener('change',()=>change(input.value));return label;};
const section=title=>{const x=node('section');x.className='mf-card';x.append(node('h3',title));return x;};
const select=(title,value,items,change)=>{const label=node('label'),input=node('select');label.append(node('span',title));
  for(const item of items){const o=node('option',item.label);o.value=item.value;input.append(o);}input.value=value??'';
  input.addEventListener('change',()=>change(input.value));label.append(input);return label;};
const clone=x=>structuredClone(x);
const shapeKey=/^[a-z][a-z0-9_]{1,63}$/;
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const sourceEpisode=(key,ordinal)=>({episode_key:key,ordinal,title:'',incipit_public:'',plot_private:'',
  phases:[],maps:[],npc_actor_keys:[],terminal_rules:{terminal_step_key:'',outcome_capability_key:'',reward_policy_id:null}});
const sourcePhase=key=>({step_key:key,capability_key:'',public_setup:'',private_direction:'',transition_options:[]});
const storageKey='mission-factory-quest-recovery/1';

const PREVIEW_MESSAGES=Object.freeze({
  QUEST_CAPABILITY_UNAVAILABLE:'Questa capacità non è disponibile per una Quest IA. Scegline una fra quelle abilitate.',
  QUEST_DECISION_UNAVAILABLE:'Questa condizione di passaggio non è disponibile per la fase. Scegli una condizione proposta.',
  QUEST_TRANSITION_AMBIGUOUS:'Due passaggi possono attivarsi insieme. Scegli condizioni che non si sovrappongono.',
  QUEST_DESTINATION_MISSING:'La fase di destinazione non esiste in questa puntata.',
  QUEST_TERMINAL_UNREACHABLE:'La puntata deve poter arrivare a una conclusione.',
  QUEST_TERMINAL_OUTCOME_REQUIRED:'Scegli se questa conclusione prevista è riuscita o fallita.',
  QUEST_TERMINAL_OUTCOME_FORBIDDEN:'Rimuovi l’esito da un passaggio che prosegue verso un’altra fase.',
  QUEST_NPC_UNAVAILABLE:'Questo PNG o la sua versione non è pronto per la fase indicata.',
  QUEST_COMBAT_ACTORS_MISSING:'Per aprire uno scontro servono un avversario idoneo e la sua presenza in questa fase.',
  QUEST_ARENA_UNAVAILABLE:'Scegli un’arena di scontro disponibile per questa fase.',
  QUEST_MEDIA_UNAVAILABLE:'La mappa di contesto non è disponibile: scegline una pubblicata.',
  QUEST_REWARD_POLICY_UNAVAILABLE:'Seleziona una regola premio disponibile per questa puntata.',
  MF_QUEST_EPISODES_REQUIRED:'Aggiungi almeno una puntata alla Quest.',
  MF_QUEST_CATALOG_UNQUALIFIED:'Il catalogo Quest non è ancora disponibile. Rileggilo prima di continuare.',
  MF_QUEST_ROSTER_REQUIRED:'Assegna il gruppo iniziale con la Staff.',
  MF_QUEST_VARIANT_REQUIRED:'Completa la variante IA della Quest.',
  MF_QUEST_VARIANT_INVALID:'Correggi la variante IA e confermala di nuovo.',
  MF_QUEST_SENSITIVE_REVIEW_REQUIRED:'La revisione aggiuntiva richiesta deve essere approvata da Admin.',
  MF_QUEST_BUDGET_POLICY_REQUIRED:'Seleziona una policy IA disponibile.',
  MF_QUEST_REWARD_POLICY_UNQUALIFIED:'Seleziona una policy premi qualificata prima della pubblicazione.',
  MF_QUEST_NPC_DUPLICATE:'Ogni PNG deve avere una chiave attore distinta.',
  MF_QUEST_NPC_PHASE_BINDING:'Collega il PNG a una fase valida della puntata.',
  MF_QUEST_NPC_ID:'Scegli una versione PNG certificata.',
  MF_QUEST_NPC_STALE:'La versione del PNG è cambiata. Aggiorna il catalogo e scegli di nuovo.',
  MF_QUEST_NPC_UNQUALIFIED:'Questo PNG non è qualificato per la Quest.',
  MF_QUEST_CAPABILITY_UNQUALIFIED:'Scegli una capacità qualificata per questa fase.',
  MF_QUEST_DECISION_UNQUALIFIED:'Scegli una condizione di passaggio qualificata.',
  MF_QUEST_TRANSITION_TARGET:'Scegli una fase di destinazione valida.',
  MF_QUEST_TERMINAL_STEP:'Scegli una fase terminale valida.',
  MF_QUEST_TERMINAL_CAPABILITY:'La conclusione richiede una capacità terminale qualificata.',
  MF_QUEST_EPISODE_NPC_BINDING:'Controlla i PNG collegati a questa puntata.',
  MF_QUEST_MEDIA_ID:'Scegli un’immagine di contesto attestata.',
  MF_QUEST_MEDIA_STALE:'L’immagine di contesto è cambiata. Aggiorna il catalogo.',
  MF_QUEST_ARENA_VERSION:'Scegli una versione valida dell’arena.',
  MF_QUEST_ARENA_UNQUALIFIED:'Questa arena non è pronta per la Quest.'
});
const PREVIEW_FIELDS=Object.freeze({
  capability_key:'Capacità',decision_key:'Condizione',to_step_key:'Destinazione',
  terminal_outcome:'Esito della conclusione',
  transition_options:'Passaggi',arena_ref:'Arena di scontro',context_media_id:'Immagine di contesto',
  terminal_rules:'Regole di chiusura',npc_actor_keys:'PNG della puntata',
  budget_policy_id:'Policy IA',catalog_version:'Catalogo',sensitive_review:'Revisione aggiuntiva',
  roster_assignment_id:'Gruppo iniziale',variants:'Variante IA',ai:'Variante IA',
  maps:'Mappe',phases:'Fasi',episodes:'Puntate',npc_bindings:'PNG'
});
const pathParts=raw=>{
  if(typeof raw!=='string'||raw.length>180||!raw)return null;
  const normalized=raw.replace(/\[([0-9]{1,2})\]/g,'.$1');
  if(!/^[a-z][a-z0-9_]*(?:\.(?:[a-z][a-z0-9_]*|[0-9]{1,2}))*$/.test(normalized))return null;
  return normalized.split('.');
};
const findPosition=(items,part,key)=>{
  if(!Array.isArray(items)||!part)return -1;
  if(/^[0-9]{1,2}$/.test(part)){const n=Number(part);return n<items.length?n:-1;}
  return items.findIndex(x=>x?.[key]===part);
};
const previewFieldLocation=(rawPath,draft)=>{
  const parts=pathParts(rawPath),quest=draft?.quest;
  if(!parts)return 'Quest';
  if(parts[0]==='npc_bindings'){
    const n=findPosition(draft?.npc_bindings,parts[1],'actor_key');
    return n<0?'PNG':`PNG ${n+1}`;
  }
  if(parts[0]==='variants')return 'Variante IA';
  if(parts[0]!=='quest')return PREVIEW_FIELDS[parts[0]]||'Quest';
  if(parts[1]!=='episodes')return 'Quest';
  const e=findPosition(quest?.episodes,parts[2],'episode_key');
  if(e<0)return 'Puntate';
  const ep=quest.episodes[e],labels=[`Puntata ${e+1}`];
  if(parts[3]==='phases'||parts[3]==='maps'){
    const n=findPosition(ep[parts[3]],parts[4],'step_key');
    if(n<0)return labels.join(' · ');
    labels.push(`Fase ${n+1}`);
    const rest=parts.slice(5);
    if(rest[0]==='transition_options'){
      const t=findPosition(ep.phases?.[n]?.transition_options,rest[1],'transition_key');
      labels.push(t<0?'Passaggi':`Passaggio ${t+1}`);
      if(rest[2]&&PREVIEW_FIELDS[rest[2]])labels.push(PREVIEW_FIELDS[rest[2]]);
    }else if(rest[0]&&PREVIEW_FIELDS[rest[0]])labels.push(PREVIEW_FIELDS[rest[0]]);
  }else if(parts[3]&&PREVIEW_FIELDS[parts[3]])labels.push(PREVIEW_FIELDS[parts[3]]);
  return labels.join(' · ');
};
export const formatQuestPreviewError=(error,draft)=>{
  const code=typeof error?.code==='string'&&/^[A-Z][A-Z0-9_]{2,80}$/.test(error.code)?error.code:'';
  const publicMessage=PREVIEW_MESSAGES[code]||'Controlla questo campo e riprova.';
  // Usa il testo server solo se coincide con il mapping pubblico noto; non mostra detail o messaggi grezzi.
  const message=error?.message===publicMessage?error.message:publicMessage;
  return {location:previewFieldLocation(error?.path,draft),message};
};


export function mountQuestFactoryEditor(root,{api,client,role,identity,openNpcBuilder,attestMedia,onPublished,onHumanRuntime=()=>{},notice=()=>{}}={}){
  if(!(root instanceof Element)||!api)throw Error('Editor Quest non configurato.');
  const editor=new QuestFactoryEditor(api);
  const actor=typeof identity==='function'?identity():null;
  if(!uuid.test(actor||''))throw Error('Identità editoriale non disponibile.');
  const recoveryKey=storageKey+'/'+actor;
  let disposed=false,recoveryError=null,actionStamp=null;
  const viewAlive=()=>!disposed&&root.isConnected&&identity()===actor;
  const alive=()=>!disposed&&root.isConnected&&!root.hidden&&identity()===actor&&(!busy||actionStamp===rawApi.lifecycleEpoch());
  const rawApi=api;if(typeof rawApi.setLifecycle!=='function')throw Error('API senza lifecycle irrevocabile.');rawApi.setLifecycle(alive);api=new Proxy(rawApi,{get(target,key){const value=target[key];return typeof value==='function'?(...args)=>{if(!alive())throw Error('Editor chiuso: nuova chiamata bloccata.');return value.apply(target,args);}:value;}});
  const sameActor=()=>{if(!alive())throw Error('Accesso cambiato: riapri l’editor con il profilo corrente.');};
  let compileView=null;
  let restored=false;
  try{const saved=sessionStorage.getItem(recoveryKey);if(saved){editor.restoreRecovery(JSON.parse(saved));restored=true;}}catch(error){recoveryError=error;}
  const persist=()=>{const raw=JSON.stringify(editor.recoverySnapshot());sessionStorage.setItem(recoveryKey,raw);if(sessionStorage.getItem(recoveryKey)!==raw)throw Error('Journal Quest non conservato: invio bloccato.');};
  editor.setLifecycle(alive,()=>{if(recoveryError)throw recoveryError;persist();});
  let busy=false,status='',stage='editorial',roster=null,npcs=[],media=[],eligibleSelection=new Set(),proposalDocument=null;
  const humanAuthoring=createHumanQuestAuthoring({client,api,identity,
    readEditor:()=>({draft_id:editor.draftId,control_version:editor.controlVersion,dirty:!editor.savedDocument,
      pending:!!(editor.pendingCreate||editor.pendingSave||editor.pendingRoster||editor.pendingCompile||editor.pendingVariant||editor.pendingPublish||editor.pendingRewardPolicy)}),
    isCurrent:()=>alive()&&!root.closest('[hidden]'),
    setBusy:value=>{if(value)actionStamp=rawApi.lifecycleEpoch();busy=value;if(!value)actionStamp=null;render();},onPublished,onRuntime:onHumanRuntime});
  const reviewStoragePrefix='mission-factory-quest-sensitive-pending/2/';
  const legacyReviewStorageKey='mission-factory-quest-sensitive-pending/1';
  const pendingReviews=new Map();
  let reviewState=null;
  const pendingReview=()=>{
    const draftId=editor.draftId;if(!draftId)return null;
    if(pendingReviews.has(draftId))return pendingReviews.get(draftId);
    try{
      let saved=sessionStorage.getItem(reviewStoragePrefix+draftId);
      if(!saved){const legacy=sessionStorage.getItem(legacyReviewStorageKey);
        if(legacy&&JSON.parse(legacy)?.draft_id===draftId){saved=legacy;
          sessionStorage.setItem(reviewStoragePrefix+draftId,legacy);
          sessionStorage.removeItem(legacyReviewStorageKey);}}
      const value=saved?JSON.parse(saved):null;
      if(value?.draft_id===draftId&&['request','decision'].includes(value.operation)&&value.key)
        {pendingReviews.set(draftId,value);return value;}
    }catch{}
    return null;
  };
  const setPendingReview=value=>{
    const draftId=value?.draft_id||editor.draftId;if(!draftId)return;
    if(value)pendingReviews.set(draftId,value);else pendingReviews.delete(draftId);
    try{if(value)sessionStorage.setItem(reviewStoragePrefix+draftId,JSON.stringify(value));
      else sessionStorage.removeItem(reviewStoragePrefix+draftId);}catch{}
  };
  const readReview=async()=>{if(role==='admin'&&editor.draftId)reviewState=await api.sensitiveState({draft_id:editor.draftId});
    else reviewState=null;return reviewState;};
  const recoverReview=async()=>{
    const state=await readReview(),pending=pendingReview();
    if(!pending)return state;
    const complete=pending.operation==='request'
      ? state.request_key===pending.key&&state.required===true
      : state.request_key===pending.request_key&&state.status===pending.decision;
    if(complete){setPendingReview(null);await editor.open(editor.draftId);reviewState=await readReview();}
    return reviewState;
  };
  let title='',questKind='one_shot',visibility='staff',scheduledAt='';
  const say=(message,error=false)=>{if(!alive())return;status=message;notice(message,error);render();};
  const run=async action=>{if(busy||!alive())return;actionStamp=rawApi.lifecycleEpoch();busy=true;render();try{sameActor();await action();sameActor();}
    catch(error){say(error?.message||'Operazione Quest non completata.',true);}
    finally{busy=false;try{persist();}catch(error){recoveryError=error;status='Salvataggio del recupero non disponibile: riapri l’editor prima di inviare altre richieste.';}if(alive())render();}};
  const change=mutator=>{try{sameActor();editor.edit(mutator);compileView=null;proposalDocument=null;reviewState=null;persist();render();}
    catch(error){say(error?.message||'Richiesta Quest da rileggere.',true);}};
  const catalog=()=>editor.catalog||{capabilities:[],budget_policies:[]};
  const qualified=family=>(catalog().capabilities||[]).filter(x=>x.qualified===true&&
    x.allowed_content_kinds?.includes('quest_ai')&&(!family||x.family===family));
  const names=items=>[{value:'',label:'Scegli dal catalogo qualificato…'},...items.map(x=>({value:x.capability_key||x.decision_key||x.key,label:x.label||x.capability_key||x.decision_key||x.key}))];
  const loadRoster=async()=>{roster=null;eligibleSelection=new Set();render();
    const next=await api.rosterCatalog({draft_id:editor.draftId});roster=next;
    eligibleSelection=new Set(next.assignment?.member_character_ids||[]);render();};
  const addEpisode=()=>change(doc=>{const episodes=doc.quest.episodes;
    let n=episodes.length+1,key=`puntata_${n}`;while(episodes.some(x=>x.episode_key===key))key=`puntata_${++n}`;
    episodes.push(sourceEpisode(key,episodes.length+1));});
  const removeEpisode=key=>change(doc=>{doc.quest.episodes=doc.quest.episodes.filter(x=>x.episode_key!==key);
    doc.quest.episodes.forEach((x,i)=>x.ordinal=i+1);
    for(const binding of doc.npc_bindings)binding.phase_keys=binding.phase_keys.filter(k=>!k.startsWith(`${key}/`));
    doc.npc_bindings=doc.npc_bindings.filter(x=>x.phase_keys.length);syncActors(doc);});
  const addPhase=episodeKey=>change(doc=>{const ep=doc.quest.episodes.find(x=>x.episode_key===episodeKey);
    let n=ep.phases.length+1,key=`fase_${n}`;while(ep.phases.some(x=>x.step_key===key))key=`fase_${++n}`;
    ep.phases.push(sourcePhase(key));ep.maps.push({step_key:key,context_media_id:null,arena_ref:null});});
  const removePhase=(episodeKey,stepKey)=>change(doc=>{const ep=doc.quest.episodes.find(x=>x.episode_key===episodeKey);
    ep.phases=ep.phases.filter(x=>x.step_key!==stepKey);ep.maps=ep.maps.filter(x=>x.step_key!==stepKey);
    for(const phase of ep.phases)phase.transition_options=phase.transition_options.filter(x=>x.to_step_key!==stepKey);
    if(ep.terminal_rules.terminal_step_key===stepKey)ep.terminal_rules.terminal_step_key='';
    for(const binding of doc.npc_bindings)binding.phase_keys=binding.phase_keys.filter(x=>x!==`${episodeKey}/${stepKey}`);
    doc.npc_bindings=doc.npc_bindings.filter(x=>x.phase_keys.length);syncActors(doc);});
  const episodeOf=key=>editor.document.quest.episodes.find(x=>x.episode_key===key);
  const phaseOf=(ep,key)=>ep.phases.find(x=>x.step_key===key);

  function renderRecovery(){const box=section('Recupero della richiesta Quest');
    box.append(node('p','La richiesta precedente può essere ancora in corso. Rileggi la stessa key prima di creare o modificare la bozza.'));
    box.append(button('Rileggi stato',()=>void run(async()=>{
      const states=await editor.recoverPending();
      npcs=[];media=[];
      if(editor.draftId)await loadRoster();
      if(editor.draftId&&role==='admin')await recoverReview();
      compileView=states.find(x=>x.schema_version==='mission-factory-compile-state/2')||compileView;
      say(states.some(x=>x.state==='unknown')?'Stato ancora incerto: conserva la stessa key.':'Stato recuperato dal server.');
    })));root.append(box);}
  function renderStart(){
    const box=section('Nuova Quest IA');
    box.append(field('Titolo',title,v=>{title=v;}));
    box.append(select('Formato',questKind,[{value:'one_shot',label:'Una puntata'},{value:'trama',label:'Trama a puntate'}],v=>{questKind=v;}));
    box.append(node('p','Il gruppo viene assegnato dallo Staff dopo la creazione. I premi e le puntate successive seguono solo policy server qualificate.'));
    box.append(button('Crea bozza Quest',()=>void run(async()=>{
      await editor.create({title,quest_kind:questKind});npcs=[];media=[];proposalDocument=null;await loadRoster();await readReview();stage='editorial';say('Bozza Quest creata. Completa trama e puntate.');
    })));
    root.append(box);
  }
  function renderEditorial(){
    const doc=editor.document,q=doc.quest,box=section('Trama e puntate');
    box.append(field('Titolo della Quest',q.title,v=>change(d=>d.quest.title=v)));
    box.append(field('Canovaccio privato Staff',q.plot_private,v=>change(d=>d.quest.plot_private=v),true));
    box.append(node('p',q.quest_kind==='trama'?'Le puntate condividono un arco. La successiva usa solo fatti server della precedente.':'Quest completa in una puntata.'));
    box.append(select('Budget IA',doc.budget_policy_id,
      [{value:'',label:'Scegli policy server…'},...(catalog().budget_policies||[])
        .filter(x=>x.qualified===true&&x.allowed_content_kinds?.includes('quest_ai')).map(x=>({value:x.id,label:x.label||x.id}))],
      v=>change(d=>d.budget_policy_id=v||null)));
    for(const ep of q.episodes){const card=section(`Puntata ${ep.ordinal} · ${ep.episode_key}`);
      card.append(field('Titolo',ep.title,v=>change(d=>d.quest.episodes.find(x=>x.episode_key===ep.episode_key).title=v)));
      card.append(field('Incipit pubblico',ep.incipit_public,v=>change(d=>d.quest.episodes.find(x=>x.episode_key===ep.episode_key).incipit_public=v),true));
      card.append(field('Trama privata della puntata',ep.plot_private,v=>change(d=>d.quest.episodes.find(x=>x.episode_key===ep.episode_key).plot_private=v),true));
      for(const phase of ep.phases){const ph=section(`Fase · ${phase.step_key}`);
        const caps=qualified();
        ph.append(select('Capacità',phase.capability_key,names(caps.filter(x=>x.phase_allowed!==false)),v=>change(d=>{const p=phaseOf(d.quest.episodes.find(x=>x.episode_key===ep.episode_key),phase.step_key);p.capability_key=v;if(v!=='d100.native')delete p.d100_binding;})));
        if(phase.capability_key==='d100.native'){
          ph.append(node('p','Tiro d100 Native: guida e un supporto espliciti nella scena. Soglie, bonus ed esiti restano server.'));
          ph.append(button('Leggi policy d100 Native',()=>void run(async()=>{await editor.loadD100Policies();})));
          const c=editor.d100Policies,rows=c?.draft_id===editor.draftId&&c.draft_control_version===editor.controlVersion?c.policies:[];
          const selected=phase.d100_binding?JSON.stringify([phase.d100_binding.policy_mission_id,phase.d100_binding.policy_step_key]):'';
          ph.append(select('Policy Native della fase',selected,[{value:'',label:'Scegli una policy letta dal server…'},...rows.map(x=>({value:JSON.stringify([x.policy_mission_id,x.policy_step_key]),label:`${x.policy_step_key} · ${x.policy_mission_id}`}))],v=>{if(v){try{editor.selectD100Policy(ep.episode_key,phase.step_key,v);compileView=null;proposalDocument=null;reviewState=null;persist();render();}catch(e){say('Rileggi le policy Native prima di scegliere.',true);}}}));
          const row=rows.find(x=>JSON.stringify([x.policy_mission_id,x.policy_step_key])===selected);
          if(row)ph.append(node('p',`Soglia guida ${row.threshold}; soglia supporto ${row.support_threshold}. Valori Native in sola lettura.`));
          if(!phase.d100_binding)ph.append(node('p','Binding mancante: scegli una policy Native prima di salvare o compilare.'));
        }
        ph.append(field('Apertura visibile ai PG',phase.public_setup,v=>change(d=>phaseOf(d.quest.episodes.find(x=>x.episode_key===ep.episode_key),phase.step_key).public_setup=v),true));
        ph.append(field('Direzione privata per la Regia',phase.private_direction,v=>change(d=>phaseOf(d.quest.episodes.find(x=>x.episode_key===ep.episode_key),phase.step_key).private_direction=v),true));
        const selectedCap=caps.find(x=>(x.capability_key||x.key)===phase.capability_key),decisions=selectedCap?.decision_keys;
        if(!Array.isArray(decisions))ph.append(node('p','Passaggi non configurabili: il catalogo non espone ancora i predicati qualificati.'));
        else {
          for(const [transitionIndex,tr] of phase.transition_options.entries()){const row=node('div');
            row.append(select('Condizione',tr.decision_key,names(decisions.map(x=>typeof x==='string'?{key:x}:x)),v=>change(d=>{
              const p=phaseOf(d.quest.episodes.find(x=>x.episode_key===ep.episode_key),phase.step_key);
              p.transition_options[transitionIndex].decision_key=v;})));
            row.append(select('Vai alla fase',tr.to_step_key??'',[...(phase.capability_key==='d100.native'?[{value:'',label:'Scegli la fase successiva…'}]:[{value:'',label:'Conclusione'}]),...ep.phases.map(x=>({value:x.step_key,label:x.step_key}))],v=>change(d=>{
              const p=phaseOf(d.quest.episodes.find(x=>x.episode_key===ep.episode_key),phase.step_key);
              const target=p.transition_options[transitionIndex];target.to_step_key=v||null;
              if(target.to_step_key!==null)delete target.terminal_outcome;})));
            if(phase.capability_key!=='d100.native'&&tr.to_step_key===null)row.append(select('Esito della conclusione prevista',tr.terminal_outcome||'',
              [{value:'',label:'Scegli l’esito…'},{value:'success',label:'Conclusione riuscita'},
               {value:'failure',label:'Conclusione fallita'}],v=>change(d=>{
                const p=phaseOf(d.quest.episodes.find(x=>x.episode_key===ep.episode_key),phase.step_key);
                const target=p.transition_options[transitionIndex];
                if(target.to_step_key!==null)return;
                if(v)target.terminal_outcome=v;else delete target.terminal_outcome;
              })));
            ph.append(row);
          }
          ph.append(button('Aggiungi passaggio',()=>change(d=>phaseOf(d.quest.episodes.find(x=>x.episode_key===ep.episode_key),phase.step_key)
            .transition_options.push({decision_key:'',to_step_key:null}))));
        }
        ph.append(button('Rimuovi fase',()=>removePhase(ep.episode_key,phase.step_key)));
        card.append(ph);
      }
      card.append(button('Aggiungi fase',()=>addPhase(ep.episode_key)));
      card.append(select('Fase terminale',ep.terminal_rules.terminal_step_key,
        [{value:'',label:'Scegli fase terminale…'},...ep.phases.filter(x=>qualified('terminal').some(c=>c.key==='terminal.result'&&c.key===x.capability_key))
          .map(x=>({value:x.step_key,label:x.step_key}))],v=>change(d=>{
            const e=d.quest.episodes.find(x=>x.episode_key===ep.episode_key);
            e.terminal_rules.terminal_step_key=v;e.terminal_rules.outcome_capability_key=e.phases.find(x=>x.step_key===v)?.capability_key||'';
          })));
      if(ep.ordinal===q.episodes.length){
        const rows=(catalog().reward_policies||[]).filter(isQuestFixed30Policy),selected=ep.terminal_rules.reward_policy_id;
        const chosen=rows.find(x=>x.id===selected);
        card.append(node('p',chosen?'Premio uniforme: 30 XP per ogni PG idoneo, sia in successo sia in fallimento. 0 Ryō, nessun oggetto. Gli extra Staff sono separati.':'Seleziona una policy fissa 30 XP qualificata dal server.'));
        if(selected&&!chosen)card.append(node('p','Riferimento premio storico conservato. Non viene convertito automaticamente alla nuova policy.'));
        card.append(select('Policy fissa alla chiusura dell’intero arco','',
          [{value:'',label:chosen?'Policy 30 XP selezionata':'Scegli la policy 30 XP…'},...rows.map(x=>({value:x.id,label:'30 XP · successo/fallimento · 0 Ryō · nessun oggetto'}))],v=>{
            if(!v)return;void run(async()=>{editor.selectFixedRewardPolicy(v);say('Policy fissa selezionata: salva e rileggi l’anteprima.');});
          }));
        card.append(button(editor.pendingRewardPolicy?'Rileggi qualificazione policy':'Qualifica nuova policy 30 XP (Staff)',()=>void run(async()=>{
          if(editor.pendingRewardPolicy){const s=await editor.readRewardPolicy();say(s.state==='unknown'?'Qualificazione non confermata: UUID conservata, nessuna nuova richiesta.':'Policy qualificata dal server.');}
          else {await editor.qualifyRewardPolicy();say('Policy 30 XP qualificata dal server. Selezionala esplicitamente per la bozza.');}
        })));
        if(editor.pendingRewardPolicy)card.append(button('Ripeti la stessa richiesta policy',()=>void run(async()=>{await editor.qualifyRewardPolicy();say('Qualificazione riletta dal server.');})));
      }
      else card.append(node('p','I premi sono valutati solo alla chiusura dell’intera Quest.'));
      if(q.quest_kind==='trama')card.append(button('Rimuovi puntata',()=>removeEpisode(ep.episode_key)));
      box.append(card);
    }
    if(q.quest_kind==='trama'||q.episodes.length===0)box.append(button('Aggiungi puntata',addEpisode));
    box.append(button('Salva bozza',()=>void run(async()=>{await editor.save();say('Bozza Quest salvata.');})));
    root.append(box);
  }
  function renderRoster(){
    const box=section('Gruppo assegnato dallo Staff');
    if(!roster){box.append(button('Carica PG idonei',()=>void run(loadRoster)));root.append(box);return;}
    box.append(node('p',roster.assignment?`Gruppo assegnato · versione ${roster.assignment.roster_version}`:'Nessun gruppo assegnato.'));
    for(const pg of roster.eligible){const line=node('label'),check=node('input');check.type='checkbox';check.checked=eligibleSelection.has(pg.character_id);
      check.addEventListener('change',()=>{if(check.checked)eligibleSelection.add(pg.character_id);else eligibleSelection.delete(pg.character_id);});
      line.append(check,node('span',`${pg.display_name} · ${pg.village_scope||'villaggio non indicato'}`));box.append(line);}
    box.append(button('Assegna gruppo iniziale',()=>void run(async()=>{
      const selected=[...eligibleSelection];
      if(selected.length<1||selected.length>4||selected.some(x=>!roster.eligible.some(y=>y.character_id===x)))
        throw Error('Scegli 1–4 PG idonei dal catalogo Staff.');
      await editor.save();await editor.assignRoster(selected);await loadRoster();say('Gruppo assegnato dal server; anteprima invalidata.');
    })));
    box.append(node('p','La modifica del gruppo tra puntate resta chiusa finché la policy non è decisa e qualificata.'));
    root.append(box);
  }
  const phaseRefs=()=>editor.document.quest.episodes.flatMap(ep=>ep.phases.map(p=>`${ep.episode_key}/${p.step_key}`));
  const syncActors=doc=>{for(const ep of doc.quest.episodes)ep.npc_actor_keys=doc.npc_bindings
    .filter(b=>b.phase_keys.some(k=>k.startsWith(`${ep.episode_key}/`))).map(b=>b.actor_key);};
  const loadNpcs=async()=>{npcs=[];render();const items=await api.npcCatalog({content_kind:'quest_ai'});
    npcs=items;render();return items;};
  const loadMedia=async()=>{media=[];render();const items=await api.questMediaCatalog({draft_id:editor.draftId});
    media=items;render();return items;};
  function renderNpcs(){const box=section('PNG, immagini di contesto e arene');
    box.append(node('p','Le fasi salvano riferimenti a versioni certificate. Scheda, ritratto e sagoma si completano nel Ninja Book.'));
    box.append(button('Aggiorna catalogo PNG',()=>void run(loadNpcs)));
    box.append(button('Crea PNG nel Ninja Book',()=>void run(async()=>{
      if(typeof openNpcBuilder!=='function')throw Error('Ninja Book non collegato.');
      await openNpcBuilder();say('Completa la review del PNG e poi aggiorna il catalogo.');
    })));
    for(const binding of editor.document.npc_bindings){const row=section(`PNG · ${binding.actor_key}`);
      if(binding.combat===true){const checked=editor.authoringChecks.get(binding.actor_key);
        row.append(node('p',checked?`Verifica Staff: ${checked.status}${checked.reason_code?` · ${checked.reason_code}`:''}. Anteprima e scontro richiedono qualifica server separata.`:'Combat richiesto: salva e verifica il binding con il server.'));
        row.append(button('Verifica PNG Combat nella bozza salvata',()=>void run(async()=>{
          const result=await editor.checkNpcAuthoring(binding.actor_key);
          say(result.staff_selectable?'Binding selezionabile per l’authoring Staff; anteprima e scontro richiedono i gate server.':`Binding bloccato: ${result.reason_code||'controlla fasi e bundle'}.`);
        })));
      }
      row.append(field('Ruolo narrativo',binding.role,v=>change(d=>{
        d.npc_bindings.find(x=>x.actor_key===binding.actor_key).role=v.slice(0,80);
      })));
      row.append(select('Squadra',binding.team,['alleati','avversari','civili'].map(v=>({value:v,label:v})),v=>change(d=>{
        d.npc_bindings.find(x=>x.actor_key===binding.actor_key).team=v;
      })));
      for(const ref of phaseRefs()){const line=node('label'),check=node('input');check.type='checkbox';
        check.checked=binding.phase_keys.includes(ref);
        check.addEventListener('change',()=>change(d=>{
          const b=d.npc_bindings.find(x=>x.actor_key===binding.actor_key);
          b.phase_keys=check.checked?[...new Set([...b.phase_keys,ref])]:b.phase_keys.filter(x=>x!==ref);
          syncActors(d);
        }));line.append(check,node('span',ref));row.append(line);}
      row.append(button('Rimuovi PNG dalla Quest',()=>change(d=>{
        d.npc_bindings=d.npc_bindings.filter(x=>x.actor_key!==binding.actor_key);syncActors(d);
      })));
      box.append(row);
    }
    if(npcs.length&&editor.document.npc_bindings.length<12){const row=section('Collega PNG certificato');
      const version=node('select');version.append(node('option','Scegli versione…'));
      version.firstChild.value='';for(const item of npcs){const opt=node('option',item.name||item.npc_version_id);
        opt.value=item.npc_version_id;version.append(opt);}row.append(version);
      const actor=node('input');actor.placeholder='actor_key';actor.setAttribute('aria-label','Chiave attore PNG');row.append(actor);
      const role=node('input');role.placeholder='Ruolo narrativo';role.setAttribute('aria-label','Ruolo PNG');row.append(role);
      const team=node('select');for(const v of ['alleati','avversari','civili']){const o=node('option',v);o.value=v;team.append(o);}row.append(team);
      const combat=node('input');combat.type='checkbox';const combatLabel=node('label');combatLabel.append(combat,node('span','Combat da verificare sulla bozza salvata'));row.append(combatLabel);
      version.addEventListener('change',()=>{const item=npcs.find(x=>x.npc_version_id===version.value);
        combat.disabled=item?.combat!==true&&item?.staff_authoring_candidate!==true;if(combat.disabled)combat.checked=false;});
      combat.disabled=true;
      const phaseChecks=new Map();for(const ref of phaseRefs()){const l=node('label'),c=node('input');c.type='checkbox';phaseChecks.set(ref,c);
        l.append(c,node('span',ref));row.append(l);}
      row.append(button('Collega alle fasi',()=>{try{
        const item=npcs.find(x=>x.npc_version_id===version.value),key=actor.value.trim(),refs=[...phaseChecks].filter(([,c])=>c.checked).map(([r])=>r);
        if(!item||!shapeKey.test(key)||!role.value.trim()||role.value.trim().length>80||!refs.length||
           combat.checked&&item.combat!==true&&item.staff_authoring_candidate!==true)throw Error('Scegli versione, actor key, ruolo e almeno una fase qualificati.');
        change(d=>{if(d.npc_bindings.some(x=>x.actor_key===key))throw Error('Actor key già usata.');
          d.npc_bindings.push({npc_id:item.npc_id,npc_version_id:item.npc_version_id,actor_key:key,
            phase_keys:refs,combat:combat.checked,team:team.value,role:role.value.trim(),presence:'in_scene',reveal:'visible'});
          syncActors(d);});
      }catch(error){say(error?.message||'Binding PNG non valido.',true);}}));box.append(row);}
    box.append(button('Carica media attestati',()=>void run(loadMedia)));
    const arenas=(catalog().map_references||[]).filter(x=>x.schema_version==='map-reference/1'&&x.ready===true&&
      x.qualified===true&&x.allowed_content_kinds?.includes('quest_ai'));
    for(const ep of editor.document.quest.episodes)for(const phase of ep.phases){
      const ref=`${ep.episode_key}/${phase.step_key}`,map=ep.maps.find(x=>x.step_key===phase.step_key),row=section(`Mappa · ${ref}`);
      if(!map){row.append(node('p','Riferimento mappa mancante: correggi la fase.'));box.append(row);continue;}
      const available=media.filter(x=>x.episode_key===ep.episode_key&&x.step_key===phase.step_key&&x.state==='registered');
      if(map.context_media_id&&!available.some(x=>x.media_id===map.context_media_id))
        row.append(node('p',`Media ${map.context_media_id.slice(0,8)} ancora associato: aggiorna il catalogo e verifica l'attestazione.`));
      row.append(select('Illustrazione di contesto',map.context_media_id||'',
        [{value:'',label:'Nessuna'},...available.map(x=>({value:x.media_id,label:`Media ${x.media_id.slice(0,8)}`}))],
        v=>change(d=>d.quest.episodes.find(x=>x.episode_key===ep.episode_key).maps.find(x=>x.step_key===phase.step_key).context_media_id=v||null)));
      if(typeof attestMedia==='function'){
        const upload=node('input');upload.type='file';upload.accept='image/png,image/jpeg,image/webp';
        upload.setAttribute('aria-label',`Carica immagine di contesto ${ref}`);
        upload.addEventListener('change',()=>void run(async()=>{
          const file=upload.files?.[0];if(!file)return;
          await editor.save();
          const registered=await attestMedia({draft_id:editor.draftId,phase_key:ref,content_kind:'quest_ai',file});
          if(registered?.schema_version!=='mission-factory-context-media-registration/2'||
             registered.content_kind!=='quest_ai'||registered.draft_id!==editor.draftId||
             registered.phase_key!==ref||registered.episode_key!==ep.episode_key||
             registered.step_key!==phase.step_key||registered.state!=='registered'||
             !uuid.test(registered.request_key||'')||!uuid.test(registered.media_id||''))
            throw Error('Attestazione media Quest non confermata.');
          const registeredMedia=await loadMedia();
          if(!registeredMedia.some(x=>x.media_id===registered.media_id&&x.phase_key===ref&&x.request_key===registered.request_key))
            throw Error('Media Quest non ancora visibile nel catalogo attestato.');
          change(d=>d.quest.episodes.find(x=>x.episode_key===ep.episode_key)
            .maps.find(x=>x.step_key===phase.step_key).context_media_id=registered.media_id);
          say('Immagine attestata; salva la bozza e rinnova l’anteprima.');
        }));row.append(upload);
      }
      if(qualified('combat').some(x=>x.key===phase.capability_key)){
        const current=map.arena_ref?`${map.arena_ref.template_key}|${map.arena_ref.template_version}|${map.arena_ref.zone_key}`:'';
        if(current&&!arenas.some(x=>`${x.template_key}|${x.template_version}|${x.zone_key}`===current))
          row.append(node('p','Arena ancora associata ma non presente tra le versioni ready/qualificate: scegline una valida.'));
        row.append(select('Arena pronta',current,[{value:'',label:'Scegli arena qualificata…'},...arenas.map(x=>({
          value:`${x.template_key}|${x.template_version}|${x.zone_key}`,label:x.label||x.template_key}))],v=>change(d=>{
          const target=d.quest.episodes.find(x=>x.episode_key===ep.episode_key).maps.find(x=>x.step_key===phase.step_key);
          const selected=arenas.find(x=>`${x.template_key}|${x.template_version}|${x.zone_key}`===v);
          target.arena_ref=selected?{template_key:selected.template_key,template_version:selected.template_version,zone_key:selected.zone_key}:null;
        })));
      }else if(map.arena_ref)row.append(button('Rimuovi arena dalla fase narrativa',()=>change(d=>{
        d.quest.episodes.find(x=>x.episode_key===ep.episode_key).maps.find(x=>x.step_key===phase.step_key).arena_ref=null;
      })));
      box.append(row);
    }
    root.append(box);
  }
  function variantFromSource(){const q=editor.document.quest;
    const arenas=q.episodes.flatMap(ep=>ep.maps.filter(m=>m.arena_ref).map(m=>({episode_key:ep.episode_key,
      step_key:m.step_key,...m.arena_ref})));
    return {schema_version:'quest-creation-document/1',direction_mode:'ai',quest_kind:q.quest_kind,
      arc_plan:{episode_order:q.episodes.map(x=>x.episode_key),continuity_notes:'',inter_episode_policy_key:null},
      episodes:q.episodes.map(x=>({episode_key:x.episode_key,phase_keys:x.phases.map(y=>y.step_key)})),
      editorial:{public_tone:'',private_guardrails:''},arenas};}
  const compileStatusMessage=state=>({
    queued:'Richiesta accodata; il worker non risulta ancora avviato. Rileggi lo stato senza creare una nuova richiesta.',
    running:'Compilazione avviata; esito e costo restano incerti. Rileggi lo stato della stessa richiesta.',
    rejected:'Compilazione non completata. La richiesta resta registrata; verifica il motivo con lo Staff.',
    complete:'Proposta compilata: usa Aggiorna per leggerla.',
    unknown:'Stato non disponibile. Conserva la richiesta e riprova soltanto la lettura.'
  }[state]||'Stato della richiesta non disponibile.');
  const accountingMessage=value=>({
    claimed:'Ricevuta contabile creata; nessuna conferma di invio.',
    reserved:'Budget riservato; nessuna conferma di invio.',
    authorized:'Chiamata autorizzata dal server; invio non ancora confermato.',
    provider_started:'Invio registrato; contabilizzazione ancora in corso.',
    success:'Consumo contabilizzato dal server. L’esito della proposta è indicato separatamente.',
    failed:'Tentativo chiuso dal server senza invio provider.',
    unknown_billable:'Invio con esito incerto: il server conserva il costo massimo. Non ripetere la chiamata.',
    unknown:'Esito contabile non disponibile. Non significa assenza di invio o costo zero.'
  }[value?.status]||'Lettura contabile non disponibile. Conserva la richiesta.');
  function renderCompileState(box){
    if(!compileView)return;
    box.append(node('h4','Stato della proposta'),node('p',compileStatusMessage(compileView.worker_state||compileView.state)));
    box.append(node('h4','Consumo IA'),node('p',accountingMessage(compileView.provider_state)));
    if(compileView.provider_state?.status==='unknown_billable'||compileView.provider_readback==='unavailable')
      box.append(node('p','Usa Aggiorna proposta per rileggere la stessa richiesta. Non verrà avviata un’altra chiamata.'));
  }
  function renderConduction(){const box=section('Conduzione IA · proposta correggibile');
    const variant=editor.document.variants.ai;
    box.append(node('p',`Variante IA: ${variant?.state||'missing'}. La Missione conserva separatamente i due piani IA/Master.`));
    const compileReady=catalog().quest_compile_qualified===true;
    const compileButton=button('Compila proposta IA',()=>void run(async()=>{
      await editor.save();
      editor.pendingCompile??=crypto.randomUUID();persist();
      const result=await editor.compile();compileView=result;
      say(compileStatusMessage(result.worker_state||result.state));}));
    compileButton.disabled=!compileReady||!!editor.pendingCompile;
    box.append(compileButton);
    if(!compileReady)box.append(node('p','Compilazione IA non ancora qualificata dalla policy server. Puoi preparare la variante manualmente.'));
    if(editor.pendingCompile||editor.proposalRequest)box.append(button('Aggiorna proposta',()=>void run(async()=>{
      const state=await editor.readCompile();compileView=state;if(state.state==='complete'){proposalDocument={...variantFromSource(),
        arc_plan:clone(state.result.arc_plan),episodes:clone(state.result.episodes),
        editorial:clone(state.result.editorial),arenas:clone(state.result.arenas)};
        say('Proposta ricevuta: correggi i testi prima del commit.');}
      else say(compileStatusMessage(state.state));
    })));
    renderCompileState(box);
    if(!proposalDocument&&!editor.pendingCompile)box.append(button('Compila manualmente senza provider',()=>{proposalDocument=variantFromSource();render();}));
    if(proposalDocument){box.append(field('Raccordo privato tra puntate',proposalDocument.arc_plan.continuity_notes,v=>{proposalDocument.arc_plan.continuity_notes=v;} ,true));
      box.append(field('Tono pubblico',proposalDocument.editorial.public_tone,v=>{proposalDocument.editorial.public_tone=v;},true));
      box.append(field('Guardie private della Regia',proposalDocument.editorial.private_guardrails,v=>{proposalDocument.editorial.private_guardrails=v;},true));
      box.append(node('p','L’ordine degli episodi e le arene derivano dalla bozza. La policy tra puntate resta server e può bloccare la preview.'));
      box.append(button('Conferma variante IA',()=>void run(async()=>{
        const manual=!editor.proposalRequest;
        await editor.commitVariant(proposalDocument,{manual});proposalDocument=null;
        say('Variante IA registrata dal server; rinnova l’anteprima.');
      })));
    }
    root.append(box);
  }
  function renderSensitive(){
    if(role!=='admin')return;
    const box=section('Revisione sensibile · Admin, facoltativa');
    box.append(node('p',reviewState
      ? `Stato: ${reviewState.status}. ${reviewState.required?'Revisione richiesta per questa bozza.':'Nessuna revisione aggiuntiva richiesta.'}`
      : 'Rileggi lo stato per il documento salvato prima di richiedere una revisione.'));
    if(pendingReview())box.append(node('p','Esito incerto: rileggi la stessa richiesta prima di agire ancora.'));
    box.append(button('Aggiorna stato revisione',()=>void run(async()=>{
      const state=await recoverReview();say(state?.status?`Revisione: ${state.status}.`:'Revisione non disponibile.');
    })));
    if(!pendingReview()&&['not_requested','needs_request'].includes(reviewState?.status))box.append(button('Richiedi revisione facoltativa',()=>void run(async()=>{
      await editor.save();const current=await readReview();
      if(!['not_requested','needs_request'].includes(current.status))throw Error('Revisione già richiesta: rileggi lo stato.');
      const pending={draft_id:editor.draftId,operation:'request',key:crypto.randomUUID(),
        expected_version:editor.controlVersion};setPendingReview(pending);
      const state=await api.sensitiveRequest({draft_id:editor.draftId,expected_version:pending.expected_version,
        request_key:pending.key});
      if(state.request_key!==pending.key||state.status!=='requested')throw Error('Ricevuta della revisione non confermata.');
      setPendingReview(null);await editor.open(editor.draftId);reviewState=await readReview();
      say('Revisione aggiuntiva richiesta. La decisione resta riservata ad Admin.');
    })));
    if(!pendingReview()&&reviewState?.status==='requested'&&reviewState.can_decide){
      for(const [decision,label] of [['approved','Approva revisione'],['rejected','Respingi revisione']])
        box.append(button(label,()=>void run(async()=>{
          const prior=reviewState;await editor.save();const current=await readReview();
          if(current?.status!=='requested'||!current.can_decide||
              current.request_key!==prior.request_key||current.document_sha256!==prior.document_sha256)
            throw Error('Il documento o la richiesta sono cambiati: rileggi la revisione.');
          const pending={draft_id:editor.draftId,operation:'decision',request_key:current.request_key,
            decision,key:crypto.randomUUID(),expected_version:editor.controlVersion};setPendingReview(pending);
          const result=await api.sensitiveDecide({draft_id:editor.draftId,request_key:pending.request_key,
            expected_version:pending.expected_version,decision,decision_key:pending.key});
          if(result.request_key!==pending.request_key||result.status!==decision)
            throw Error('Decisione non confermata: rileggi la stessa richiesta.');
          setPendingReview(null);await editor.open(editor.draftId);reviewState=await readReview();
          say(`Revisione ${decision==='approved'?'approvata':'respinta'}; rinnova l’anteprima.`);
        })));
    }
    root.append(box);
  }
  function renderPublish(){renderSensitive();const box=section('Anteprima e pubblicazione');
    box.append(button('Anteprima server',()=>void run(async()=>{
      await editor.save();const result=await editor.requestPreview();
      say(result.errors.length?'Anteprima con errori: correggi le voci indicate.':result.preview_seal?'Anteprima sigillata dal server.':'Anteprima non sigillata: attendi la qualificazione delle policy server.');
    })));
    if(editor.preview){box.append(node('h4','Esito anteprima'));
      for(const error of editor.preview.errors){const formatted=formatQuestPreviewError(error,editor.document);
        box.append(node('p',`${formatted.location} · ${formatted.message}`));}
      box.append(node('p',`Anteprima della versione ${editor.preview.draft_version} della bozza.`));
      if(!editor.preview.errors.length)box.append(node('p',editor.preview.preview_seal
        ?'Anteprima sigillata. Una modifica alla bozza richiede una nuova anteprima.'
        :'Pubblicazione non disponibile: il server non ha sigillato questa versione.'));
      box.append(node('p','Premi e composizione del gruppo durante una puntata saranno disponibili quando il server ne espone le regole confermate.'));
    }
    const publicOpen=editor.publicAvailability();
    const protectedPublic=editor.protectedPublicAvailability();
    if(protectedPublic)box.append(node('p','Apertura e programmazione di questa fonte sono riservate alla Staff Test Room. Nessuna apertura generale o premio reale.'));
    if(!publicOpen&&visibility==='open')visibility='staff';
    box.append(select('Disponibilità',visibility,[{value:'staff',label:'Solo Staff'},
      {value:'scheduled',label:'Programmata · verifica destinazione'},
       ...(publicOpen?[{value:'open',label:protectedPublic?'Aperta · prova Staff':'Aperta'}]:[])],v=>{visibility=v;editor.invalidateSchedule();render();}));
    if(!publicOpen){box.append(node('p',catalog().public_open_reason_code||'Apertura pubblica non qualificata; il collaudo resta riservato alla Staff.'));
      box.append(node('p','La ricevuta Staff registra soltanto la fonte Quest. Preparazione, iscrizioni e avvio della puntata sono passaggi separati.'));}
    const scheduleIso=scheduledAt&&Number.isFinite(Date.parse(scheduledAt))?new Date(scheduledAt).toISOString():null;
    if(visibility==='scheduled'){
      const date=node('input');date.type='datetime-local';date.value=scheduledAt;date.setAttribute('aria-label','Data e ora di programmazione');
      date.addEventListener('input',()=>{scheduledAt=date.value;editor.invalidateSchedule();publish.disabled=true;target.textContent='Data cambiata: ripeti la verifica della programmazione.';});
      date.addEventListener('change',()=>render());box.append(date);
      const verify=button('Verifica programmazione',()=>void run(async()=>{
        const value=await editor.checkSchedule(scheduleIso);
        say(value.allowed?(value.target==='staff'?'Programmazione riservata alla Staff Test Room.':'Programmazione pubblica autorizzata dal server.'):'Programmazione non autorizzata per questa bozza e data.');
      }));verify.disabled=busy||!editor.canPublish()||!scheduleIso||!!pendingReview();box.append(verify);
      const target=node('p',editor.canSchedule(scheduleIso)?(editor.scheduleCapability.value.target==='staff'?'Destinazione: Staff Test Room. Nessuna apertura generale o premio reale.':'Destinazione: pubblico.'):'Verifica la destinazione per questa bozza e data.');box.append(target);
      box.append(node('p','La consegna alla scadenza è confermata dal server; il timer non certifica l’apertura.'));
    }
    const publish=button(visibility==='staff'?'Registra fonte Quest Staff':'Pubblica Quest',()=>void run(async()=>{
      const when=scheduledAt?new Date(scheduledAt):null;
      if(visibility==='scheduled'&&(!when||Number.isNaN(when.getTime())))throw Error('Scegli una data valida.');
      const iso=visibility==='scheduled'?when.toISOString():null;
      const result=await editor.publish(visibility,iso);
      if(result.quest_arc_id&&result.quest_episode_id)onPublished?.(result);
      say(result.state==='staff'?'Fonte Quest Staff registrata. La puntata non è ancora preparata o avviata.':
        result.state==='scheduled'?'Apertura programmata registrata.':'Ricevuta Quest registrata.');
    }));
    publish.disabled=!editor.canPublish()||busy||!!pendingReview()||visibility==='scheduled'&&!editor.canSchedule(scheduleIso);
    box.append(publish);
    if(editor.pendingPublish||editor.publishedRequest)box.append(button('Rileggi pubblicazione',()=>void run(async()=>{
      const state=await editor.refreshDelivery();say(state.state==='confirmed'&&state.delivery.state==='staff'
        ?'Fonte Quest Staff confermata; la puntata non è ancora preparata o avviata.'
        :state.state==='confirmed'?`Consegna: ${state.delivery.state}.`:'Richiesta ancora incerta: conserva la stessa key.');
    })));
    root.append(box);
  }
  function render(){
    if(!viewAlive())return;root.replaceChildren(node('h2','Quest IA'));
    const state=node('p',status);state.setAttribute('role','status');root.append(state);
    if(!editor.document){if(editor.pendingCreate||editor.pendingSave||editor.pendingRoster||editor.pendingCompile||
      editor.pendingVariant||editor.pendingPublish||editor.pendingRewardPolicy)renderRecovery();else renderStart();return;}
    const nav=node('nav');nav.className='mf-stage-nav';
    for(const [key,label] of [['editorial','Editoriale'],['roster','Gruppo Staff'],['npcs','PNG e mappe'],
      ['conduction','Conduzione IA'],['human','Conduzione Master'],['publish','Anteprima e Pubblica']]){
      const tab=button(label,()=>{stage=key;render();});if(stage===key)tab.setAttribute('aria-current','step');nav.append(tab);}
    root.append(nav);
    if(stage==='editorial')renderEditorial();else if(stage==='roster')renderRoster();
    else if(stage==='npcs')renderNpcs();else if(stage==='conduction')renderConduction();else if(stage==='human'){const slot=node('section');root.append(slot);humanAuthoring.render(slot);}else renderPublish();
    if(busy)for(const control of root.querySelectorAll('button,input,select,textarea'))control.disabled=true;
  }
  render();
  if(restored)void run(async()=>{await editor.loadCatalog();const states=await editor.recoverPending();
    compileView=states.find(x=>x.schema_version==='mission-factory-compile-state/2')||null;
    npcs=[];media=[];if(editor.draftId){await loadRoster();if(role==='admin')await recoverReview();}
    say(states.some(x=>x.state==='unknown')?'Request ancora incerta: rileggi lo stato.':'Bozza Quest ripresa dal server.');});
  return {editor,openConfirmed:async(draftId,expectedVersion)=>{
    if(busy||!alive())throw Error('Editor Quest occupato o non disponibile: completa la richiesta e riprova. Ricevuta import conservata.');
    if(!uuid.test(draftId||'')||!Number.isSafeInteger(expectedVersion)||expectedVersion<1)throw Error('Identità bozza import non valida.');
    let confirmed=false;
    await run(async()=>{await editor.loadCatalog();await editor.open(draftId);
      npcs=[];media=[];proposalDocument=null;compileView=null;await loadRoster();await recoverReview();stage='editorial';
      sameActor();if(editor.draftId!==draftId||editor.controlVersion!==expectedVersion)throw Error('La versione Native è cambiata: rileggi la ricevuta import prima di aprire.');confirmed=true;});
    if(!confirmed||editor.draftId!==draftId||editor.controlVersion!==expectedVersion)throw Error('Apertura import non confermata; ricevuta conservata.');
    return {schema_version:'quest-editor-open-confirmed/1',draft_id:editor.draftId,control_version:editor.controlVersion};
  },open:draftId=>run(async()=>{await editor.loadCatalog();await editor.open(draftId);
    npcs=[];media=[];proposalDocument=null;compileView=null;await loadRoster();await recoverReview();stage='editorial';}),
    refreshNpcCatalog:loadNpcs,dispose:()=>{disposed=true;humanAuthoring.dispose();editor.dispose();root.replaceChildren();}};
}
