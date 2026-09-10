import {validatePanelEnvelope,classifyPanelRejection,selectionReady,isId,insist} from './validate.mjs';
// Riceve soltanto gruppi già validati (dipendenze acicliche per ID opaco).
export function settleCopyChoices(offer,selected){
  const next=new Set(selected);
  let changed;
  do{
    changed=false;
    for(const group of offer.choices){
      const active=group.depends_on===null||next.has(group.depends_on);
      if(!active){for(const option of group.options)if(next.delete(option.option_id))changed=true;}
      else if(group.purpose==='copies'&&group.selection_mode==='single'&&group.min_selected===1&&group.max_selected===1&&group.options.length===1){
        const id=group.options[0].option_id;if(!next.has(id)){next.add(id);changed=true;}
      }
    }
  }while(changed);
  return [...next];
}
// rpc è una porta iniettata. Costruire il controller non effettua chiamate.
export function createPanelController({rpc,contextKey,locationId,requestKey=()=>crypto.randomUUID(),classifyRejection=classifyPanelRejection,onChange=()=>{}}){
  insist(typeof rpc==='function'&&typeof contextKey==='function'&&isId(locationId)&&typeof requestKey==='function','controller_configuration');
  let epoch=0,owner=null,busy=false,pending=null,envelope=null,optionsReady=false,error=null;
  let selectedOfferId=null,selectedOptionIds=[],inputs=[],narrativeText='';
  let rejection=null,refreshRequired=false;
  const chosen=()=>envelope?.offers.find(o=>o.offer_id===selectedOfferId);
  const canPrepare=()=>!refreshRequired&&!busy&&!pending&&optionsReady&&envelope?.status==='ready'&&envelope.viewer.can_command&&selectionReady(chosen(),selectedOptionIds,inputs,narrativeText);
  const snapshot=()=>({validated:envelope!==null,envelope:envelope?structuredClone(envelope):null,busy,pending:pending!==null,optionsReady,error,rejection:rejection?structuredClone(rejection):null,refreshRequired,selectedOfferId,selectedOptionIds:[...selectedOptionIds],inputs:structuredClone(inputs),narrativeText,canPrepare:!!canPrepare()});
  const notify=()=>onChange(snapshot());
  const resetChoices=()=>{selectedOfferId=null;selectedOptionIds=[];inputs=[];optionsReady=false;};
  function clear(){epoch++;owner=null;busy=false;pending=null;envelope=null;error=null;rejection=null;refreshRequired=false;narrativeText='';resetChoices();notify();}
  function bind(){const key=contextKey();if(typeof key!=='string'||!key){clear();return false;}if(owner!==null&&owner!==key)clear();owner=key;return true;}
  const current=(ticket,key)=>ticket===epoch&&owner===key&&key===contextKey();
  function requireCurrent(){if(owner===null||owner!==contextKey()){clear();throw Error('context_changed');}}
  function apply(e,loaded){
    if(e.status==='ready')insist(e.context.location_id===locationId,'location_mismatch');
    const before=envelope?.context,oldActor=envelope?.viewer.command_actor_id;
    const changed=e.status==='blocked'||!before||before.activity_id!==e.context.activity_id||before.version!==e.context.version||before.scene_version!==e.context.scene_version||oldActor!==e.viewer.command_actor_id;
    const keepOptions=!loaded&&!changed&&optionsReady;
    if(keepOptions)e={...e,offers:envelope.offers};
    envelope=e;if(changed)resetChoices();
    if(e.status==='blocked'){pending=null;narrativeText='';return;}
    if(loaded){optionsReady=true;if(!chosen()){selectedOfferId=null;selectedOptionIds=[];inputs=[];}}
    else if(!keepOptions)optionsReady=false;
  }
  async function read(options=false,actor=envelope?.viewer.command_actor_id??null){
    if(!bind()||busy)return false;if(options&&pending)return false;
    if(options)insist(!refreshRequired&&envelope?.status==='ready'&&envelope.viewer.can_command,'state_refresh_required');
    const ticket=++epoch,key=owner;busy=true;error=null;notify();
    try{
      const name=options?'combat_panel_options_v1':'combat_panel_state_v1';
      const args={p_location:locationId,p_actor:actor};if(options)args.p_context_version=envelope.context.version;
      const raw=await rpc(name,args);if(!current(ticket,key))return false;
      apply(validatePanelEnvelope(raw,{state:!options}),options);
      if(!options){refreshRequired=false;rejection=null;}
      return true;
    }catch(e){if(current(ticket,key)){error=String(e.message||'read_failed');resetChoices();}return false;}
    finally{if(current(ticket,key)){busy=false;notify();}}
  }
  function editable(){requireCurrent();insist(!refreshRequired&&!busy&&!pending&&optionsReady&&envelope?.status==='ready'&&envelope.viewer.can_command,'choices_unavailable');}
  async function selectActor(actor){requireCurrent();insist(!busy&&!pending&&envelope?.viewer.controlled_actors.some(a=>a.actor_id===actor),'actor_unavailable');resetChoices();return read(false,actor);}
  function selectOffer(id){editable();insist(envelope.offers.some(o=>o.offer_id===id),'offer_unavailable');selectedOfferId=id;selectedOptionIds=settleCopyChoices(chosen(),[]);inputs=[];error=null;notify();}
  function selectOption(groupId,id,enabled){
    editable();const o=chosen(),g=o?.choices.find(g=>g.group_id===groupId);insist(g&&g.options.some(x=>x.option_id===id)&&typeof enabled==='boolean','option_unavailable');
    insist(g.depends_on===null||selectedOptionIds.includes(g.depends_on),'dependency_missing');
    const next=new Set(selectedOptionIds);if(g.selection_mode==='single')for(const x of g.options)next.delete(x.option_id);if(enabled)next.add(id);else next.delete(id);
    selectedOptionIds=settleCopyChoices(o,next);error=null;notify();
  }
  function setInput(id,value){editable();const f=chosen()?.input_fields.find(f=>f.input_id===id);insist(f&&(f.value_type==='text'?typeof value==='string':typeof value==='boolean'),'input_unavailable');inputs=inputs.filter(x=>x.input_id!==id);inputs.push({input_id:id,value});notify();}
  function setNarrative(value){requireCurrent();insist(!busy&&!pending&&typeof value==='string','narrative_unavailable');narrativeText=value;notify();}
  function prepare(){
    editable();insist(canPrepare(),'selection_incomplete');const c=envelope.context,o=chosen(),key=requestKey();insist(isId(key),'request_key_invalid');
    return {schema_version:'combat-panel-command/1',request_key:key,location_id:locationId,activity_id:c.activity_id,context_version:c.version,offer_id:o.offer_id,selected_option_ids:[...selectedOptionIds].sort(),inputs:structuredClone(inputs).sort((a,b)=>a.input_id.localeCompare(b.input_id)),narrative_text:o.requires_role?narrativeText:''};
  }
  async function send(){
    requireCurrent();insist(pending&&!busy,'no_pending_command');const ticket=++epoch,key=owner,command=pending;busy=true;error=null;notify();
    try{
      const raw=await rpc('combat_panel_commit_v1',{p_command:structuredClone(command)});if(!current(ticket,key))return null;
      const rejected=classifyRejection(raw,command.request_key);
      if(rejected){
        // La classificazione è una porta, ma non può allentare il contratto pubblico.
        rejection=classifyPanelRejection(rejected,command.request_key);insist(rejection,'rejection_invalid');
        pending=null;optionsReady=false;refreshRequired=true;error=rejection.message;
        return null;
      }
      const e=validatePanelEnvelope(raw),r=e.receipt;insist(r?.request_key===command.request_key,'receipt_mismatch');
      apply(e,true);pending=null;rejection=null;refreshRequired=false;narrativeText='';resetChoices();return structuredClone(r);
    }catch(e){if(current(ticket,key)){error=String(e.message||'commit_uncertain');optionsReady=false;}return null;}
    finally{if(current(ticket,key)){busy=false;notify();}}
  }
  async function submit(){insist(!pending,'pending_command');pending=Object.freeze(prepare());return send();}
  async function retry(){return send();}
  return {snapshot,clear,readState:()=>read(false),readOptions:()=>read(true),selectActor,selectOffer,selectOption,setInput,setNarrative,prepare,submit,retry};
}
