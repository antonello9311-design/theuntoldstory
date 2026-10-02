
export function isQuestFixed30Policy(value){
 const d=value?.document;
 return value?.qualified===true&&d?.schema_version==='mission-factory-quest-reward-policy/2'
   &&Object.keys(d).sort().join()===['schema_version','recipient_mode','xp_per_eligible_recipient','ryo_per_eligible_recipient','items','terminal_outcomes','award_scope'].sort().join()
   &&d.recipient_mode==='uniform'&&d.xp_per_eligible_recipient===30&&d.ryo_per_eligible_recipient===0
   &&Array.isArray(d.items)&&d.items.length===0&&JSON.stringify(d.terminal_outcomes)==='["success","failure"]'
   &&d.award_scope==='arc_once_per_character';
}
// Controller candidato Quest IA v2. Il server resta autorità per roster, fatti e premi.
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const SHA=/^[0-9a-f]{64}$/i;
const KIND='quest_ai';
const copy=value=>structuredClone(value);
const fail=code=>{const e=new Error(code);e.code=code;throw e;};
const id=(value,code)=>UUID.test(value||'')?value:fail(code);
const key=value=>value==null?null:id(value,'MF_QUEST_RECOVERY_KEY');
const requestResult=(value,request,schema)=>{
  if(value?.schema_version!==schema||value.request_key!==request||value.content_kind!==KIND||
     !['unknown','confirmed'].includes(value.state))fail('MF_QUEST_REQUEST_STATE');
  return value;
};
const documentShape=value=>{
  if(value?.schema_version!=='mission-factory-draft/2'||value.content_kind!==KIND||
     value.mission!==undefined||value.quest?.quest_kind!=='one_shot'&&value.quest?.quest_kind!=='trama'||
     !Array.isArray(value.quest.episodes)||!Array.isArray(value.npc_bindings)||
     !value.variants||Object.keys(value.variants).some(k=>k!=='ai'))fail('MF_QUEST_DOCUMENT');
  return value;
};
const previewShape=(value,draftId,version)=>{
  if(value?.schema_version!=='mission-factory-preview/2'||value.content_kind!==KIND||
     value.draft_id!==draftId||value.draft_version!==version||
     value.quest_kind!=='one_shot'&&value.quest_kind!=='trama'||
     value.validation_mode!=='ai_only'||!Array.isArray(value.errors)||
     !Array.isArray(value.required_variants)||!Array.isArray(value.validated_variants))fail('MF_QUEST_PREVIEW');
  return value;
};

export class QuestFactoryEditor {
  constructor(api,uuid=()=>crypto.randomUUID()){
    if(!api||typeof api!=='object')fail('MF_QUEST_API');
    this.disposed=false;this.lifecycle=()=>true;this.checkpoint=()=>{};const instance=this;
    this.api=new Proxy(api,{get(target,key){const value=target[key];return typeof value==='function'?(...args)=>{instance.assertActive();return value.apply(target,args);}:value;}});this.uuid=uuid;this.catalog=null;this.draftId=null;this.controlVersion=null;
    this.document=null;this.preview=null;this.receipt=null;this.delivery=null;this.executionContext=null;
    this.proposal=null;this.proposalRequest=null;this.publishedRequest=null;
    this.pendingCreate=null;this.pendingSave=null;this.pendingRoster=null;
    this.pendingCompile=null;this.pendingVariant=null;this.pendingPublish=null;this.pendingRewardPolicy=null;
    this.authoringChecks=new Map();this.authoringEpoch=0;this.authoringRequestSeq=0;this.savedDocument=false;
  }
  setLifecycle(isCurrent,persist){this.lifecycle=isCurrent;this.checkpoint=persist;}
  assertActive(){if(this.disposed||!this.lifecycle())throw Error('Editor chiuso o accesso cambiato.');}
  dispose(){this.invalidateSchedule();this.disposed=true;this.authoringEpoch++;}
  recoverySnapshot(){return {schema_version:'mission-factory-quest-recovery/1',content_kind:KIND,
    draft_id:this.draftId,proposal_request:this.proposalRequest,published_request:this.publishedRequest,
    pending_create:this.pendingCreate?.key??null,pending_save:this.pendingSave?.key??null,
    pending_roster:this.pendingRoster?.key??null,pending_compile:this.pendingCompile,
    pending_variant:this.pendingVariant?.key??null,pending_publish:this.pendingPublish?.key??null,pending_reward_policy:this.pendingRewardPolicy?.key??null,
    pending_payloads:{pendingCreate:copy(this.pendingCreate),pendingSave:copy(this.pendingSave),pendingRoster:copy(this.pendingRoster),pendingCompile:copy(this.pendingCompile),pendingVariant:copy(this.pendingVariant),pendingPublish:copy(this.pendingPublish),pendingRewardPolicy:copy(this.pendingRewardPolicy)}};}
  restoreRecovery(snapshot){this.invalidateSchedule();
    if(snapshot?.schema_version!=='mission-factory-quest-recovery/1'||snapshot.content_kind!==KIND)
      fail('MF_QUEST_RECOVERY_SHAPE');
    this.draftId=key(snapshot.draft_id);this.proposalRequest=key(snapshot.proposal_request);
    this.publishedRequest=key(snapshot.published_request);
    this.pendingCreate=key(snapshot.pending_create)?{key:snapshot.pending_create,payload:null}:null;
    this.pendingSave=key(snapshot.pending_save)?{key:snapshot.pending_save,payload:null}:null;
    this.pendingRoster=key(snapshot.pending_roster)?{key:snapshot.pending_roster,payload:null}:null;
    this.pendingCompile=key(snapshot.pending_compile);
    this.pendingVariant=key(snapshot.pending_variant)?{key:snapshot.pending_variant,payload:null}:null;
    this.pendingPublish=key(snapshot.pending_publish)?{key:snapshot.pending_publish,payload:null}:null;
    this.pendingRewardPolicy=key(snapshot.pending_reward_policy)?{key:snapshot.pending_reward_policy}:null;
    if(snapshot.pending_payloads){for(const property of ['pendingCreate', 'pendingSave', 'pendingRoster', 'pendingCompile', 'pendingVariant', 'pendingPublish', 'pendingRewardPolicy']){const original=this[property],saved=snapshot.pending_payloads[property];const a=typeof original==='string'?original:original?.key,b=typeof saved==='string'?saved:saved?.key;if((a||null)!==(b||null))throw Error('Journal recovery incoerente.');this[property]=copy(saved);}}
  }
  async loadCatalog(){this.invalidateSchedule();
    const value=await this.api.catalog();
    if(value?.schema_version!=='mission-factory-catalog/2'||!Array.isArray(value.content_kinds)||
       !value.content_kinds.some(x=>x.kind===KIND))fail('MF_QUEST_CATALOG');
    this.catalog=copy(value);return copy(value);
  }
  async qualifyRewardPolicy(){
    this.assertActive();this.pendingRewardPolicy??={key:this.uuid()};
    this.checkpoint(this.recoverySnapshot());const request=this.pendingRewardPolicy.key;
    const receipt=await this.api.qualifyRewardPolicy({request_key:request});
    if(receipt.request_key!==request)fail('MF_QUEST_REWARD_POLICY_RECEIPT');
    this.pendingRewardPolicy=null;this.checkpoint(this.recoverySnapshot());await this.loadCatalog();return copy(receipt);
  }
  async readRewardPolicy(){
    if(!this.pendingRewardPolicy)return null;const request=this.pendingRewardPolicy.key;
    const state=await this.api.rewardPolicyRequestState({request_key:request});
    if(state.state==='qualified'){this.pendingRewardPolicy=null;this.checkpoint(this.recoverySnapshot());await this.loadCatalog();}
    return copy(state);
  }
  selectFixedRewardPolicy(policyId){
    const row=this.catalog?.reward_policies?.find(x=>x.id===policyId);
    if(!isQuestFixed30Policy(row))fail('MF_QUEST_FIXED30_POLICY_REQUIRED');
    return this.edit(d=>{const last=d.quest.episodes.at(-1);if(!last)fail('MF_QUEST_EPISODES_REQUIRED');last.terminal_rules.reward_policy_id=policyId;});
  }
  async create({title,quest_kind}){this.invalidateSchedule();
    if(!this.catalog)await this.loadCatalog();
    this.assertActive();
    if(!this.catalog.content_kinds.some(x=>x.kind===KIND&&x.qualified===true))fail('MF_CONTENT_KIND_UNQUALIFIED');
    if(typeof title!=='string'||!title.trim()||!['one_shot','trama'].includes(quest_kind))fail('MF_QUEST_SOURCE');
    const source={schema_version:'mission-factory-create/2',content_kind:KIND,title:title.trim(),quest_kind};
    const payload={source,catalog_version:this.catalog.version};
    if(this.pendingCreate&&JSON.stringify(payload)!==JSON.stringify(this.pendingCreate.payload))
      fail(this.pendingCreate.payload?'MF_QUEST_CREATE_PENDING':'MF_QUEST_RECOVERY_READBACK');
    this.pendingCreate??={key:this.uuid(),payload};
    this.assertActive();this.checkpoint(this.recoverySnapshot());
    const result=await this.api.createDraft({request_key:this.pendingCreate.key,...copy(this.pendingCreate.payload)});
    id(result?.draft_id,'MF_QUEST_CREATED');
    documentShape(result.document);
    this.draftId=result.draft_id;this.controlVersion=result.control_version;
    this.document=copy(result.document);this.pendingCreate=null;this.preview=null;
    this.authoringChecks.clear();this.authoringEpoch++;this.savedDocument=true;
    return copy(this.document);
  }
  async open(draftId){this.invalidateSchedule();
    id(draftId,'MF_QUEST_DRAFT_ID');
    const switching=Boolean(this.draftId&&this.draftId!==draftId);
    if(switching&&(this.pendingCreate||this.pendingSave||this.pendingRoster||this.pendingCompile||
       this.pendingVariant||this.pendingPublish))fail('MF_QUEST_REQUEST_UNCERTAIN');
    const result=await this.api.openDraft({draft_id:draftId,content_kind:KIND});
    if(result.draft_id!==draftId||!Number.isSafeInteger(result.control_version)||result.control_version<1)
      fail('MF_QUEST_OPEN');
    documentShape(result.document);
    if(switching){this.proposal=null;this.proposalRequest=null;this.receipt=null;this.delivery=null;
      this.publishedRequest=null;}
    this.draftId=draftId;this.controlVersion=result.control_version;this.document=copy(result.document);
    this.preview=null;this.authoringChecks.clear();this.authoringEpoch++;this.savedDocument=true;
    if(result.state==='published'&&result.publish_request)
      this.publishedRequest=id(result.publish_request,'MF_QUEST_PUBLISH_KEY');
    return copy(this.document);
  }
  edit(mutator){this.invalidateSchedule();
    this.assertActive();
    if(!this.document||this.pendingCreate||this.pendingSave||this.pendingRoster||this.pendingCompile||
       this.pendingVariant||this.pendingPublish||this.pendingRewardPolicy)fail('MF_QUEST_REQUEST_UNCERTAIN');
    const next=copy(this.document);mutator(next);documentShape(next);
    this.document=next;this.preview=null;this.receipt=null;this.delivery=null;this.proposal=null;this.proposalRequest=null;
    this.authoringChecks.clear();this.authoringEpoch++;this.savedDocument=false;
    return copy(next);
  }
  async save(){this.invalidateSchedule();
    if(!this.draftId||!this.document)fail('MF_QUEST_DRAFT_MISSING');
    this.pendingSave??={key:this.uuid(),payload:{draft_id:this.draftId,expected_version:this.controlVersion,document:copy(this.document)}};
    if(!this.pendingSave.payload)fail('MF_QUEST_RECOVERY_READBACK');
    this.assertActive();this.checkpoint(this.recoverySnapshot());
    const result=await this.api.save({...copy(this.pendingSave.payload),request_key:this.pendingSave.key});
    if(result.request_key!==this.pendingSave.key||result.draft_id!==this.draftId||
       !Number.isSafeInteger(result.control_version))fail('MF_QUEST_SAVE_RECEIPT');
    this.controlVersion=result.control_version;this.pendingSave=null;this.preview=null;
    this.authoringChecks.clear();this.authoringEpoch++;this.savedDocument=true;return copy(result);
  }
  async checkNpcAuthoring(actor_key){
    if(!this.draftId||!this.savedDocument||this.pendingSave)fail('MF_NPC_AUTHORING_SAVE_REQUIRED');
    const binding=this.document?.npc_bindings?.find(x=>x.actor_key===actor_key);
    if(!binding||binding.combat!==true)fail('MF_NPC_AUTHORING_BINDING_INVALID');
    const epoch=this.authoringEpoch,request=++this.authoringRequestSeq,version=this.controlVersion,draft=this.draftId;
    const value=await this.api.npcAuthoringCheck({draft_id:draft,expected_version:version,actor_key});
    if(epoch!==this.authoringEpoch||request!==this.authoringRequestSeq||draft!==this.draftId||version!==this.controlVersion||!this.savedDocument)fail('MF_NPC_AUTHORING_DRAFT_STALE');
    if(value?.schema_version!=='mission-factory-npc-authoring-check/1'||value.draft_id!==draft||
       value.draft_control_version!==version||value.content_kind!=='quest_ai'||value.actor_key!==actor_key||
       !SHA.test(value.draft_sha256||'')||!['selectable','blocked'].includes(value.status)||
       value.staff_selectable!==(value.status==='selectable')||!Array.isArray(value.phase_keys)||
       !Array.isArray(value.errors)||value.errors.some(x=>typeof x.code!=='string'||
         typeof x.path!=='string'||x.phase_key!==null&&typeof x.phase_key!=='string')||
       value.staff_release_sha256!==null&&!SHA.test(value.staff_release_sha256||''))fail('MF_NPC_AUTHORING_SHAPE');
    if(value.status==='selectable'&&(value.npc_id!==binding.npc_id||
       value.npc_version_id!==binding.npc_version_id||!SHA.test(value.bundle_sha256||'')||
       JSON.stringify([...value.phase_keys].sort())!==JSON.stringify([...binding.phase_keys].sort())||
       value.reason_code!==null||value.errors.length))fail('MF_NPC_AUTHORING_BINDING_STALE');
    if(value.status==='blocked'&&(typeof value.reason_code!=='string'||!value.reason_code||
       !value.errors.length||value.npc_id!==null&&!UUID.test(value.npc_id||'')||
       value.npc_version_id!==null&&!UUID.test(value.npc_version_id||'')))fail('MF_NPC_AUTHORING_SHAPE');
    if(value.bundle_sha256!==null&&!SHA.test(value.bundle_sha256||''))fail('MF_NPC_AUTHORING_BUNDLE_SHAPE');
    this.authoringChecks.set(actor_key,copy(value));return copy(value);
  }
  async assignRoster(characterIds){
    if(!this.draftId||!this.document)fail('MF_QUEST_DRAFT_MISSING');
    if(this.pendingSave||this.pendingCompile||this.pendingVariant||this.pendingPublish||this.pendingRewardPolicy)fail('MF_QUEST_REQUEST_UNCERTAIN');
    if(!Array.isArray(characterIds)||characterIds.length<1||characterIds.length>4||
       characterIds.some(x=>!UUID.test(x))||new Set(characterIds).size!==characterIds.length)
      fail('MF_QUEST_ROSTER_INPUT');
    const payload={draft_id:this.draftId,expected_version:this.controlVersion,character_ids:[...characterIds]};
    if(this.pendingRoster&&JSON.stringify(this.pendingRoster.payload)!==JSON.stringify(payload))
      fail(this.pendingRoster.payload?'MF_QUEST_ROSTER_PENDING':'MF_QUEST_RECOVERY_READBACK');
    this.pendingRoster??={key:this.uuid(),payload};
    this.assertActive();this.checkpoint(this.recoverySnapshot());
    const result=await this.api.rosterAssign({...copy(this.pendingRoster.payload),request_key:this.pendingRoster.key});
    if(result.request_key!==this.pendingRoster.key||result.draft_id!==this.draftId||
       !UUID.test(result.assignment?.roster_assignment_id||''))fail('MF_QUEST_ROSTER_RECEIPT');
    await this.open(this.draftId);this.pendingRoster=null;return copy(result);
  }
  async compile(){
    if(!this.draftId||!this.document||this.pendingSave||this.pendingRoster||this.pendingVariant||this.pendingPublish)
      fail('MF_QUEST_REQUEST_UNCERTAIN');
    this.pendingCompile??=this.uuid();
    this.assertActive();this.checkpoint(this.recoverySnapshot());
    const result=await this.api.compileQuest({draft_id:this.draftId,expected_version:this.controlVersion,
      request_key:this.pendingCompile});
    if(result.request_key!==this.pendingCompile)fail('MF_QUEST_COMPILE_RECEIPT');
    return copy(result);
  }
  async readCompile(){
    if(!this.pendingCompile&&!this.proposalRequest)fail('MF_QUEST_COMPILE_MISSING');
    const request=this.pendingCompile||this.proposalRequest;
    const result=await this.api.compileQuestState({request_key:request});
    if(result.request_key!==request)fail('MF_QUEST_COMPILE_STATE');
    if(result.state==='complete'){
      const p=result.result;
      if(p?.schema_version!=='mission-factory-quest-proposal/1'||p.draft_id!==this.draftId||
         !UUID.test(p.proposal_id||'')||!SHA.test(p.proposal_sha256||''))fail('MF_QUEST_PROPOSAL');
      this.proposal=copy(p);this.proposalRequest=request;this.pendingCompile=null;
    }
    return copy(result);
  }
  async commitVariant(document,{manual=false}={}){
    if(!this.draftId||!this.document||this.pendingSave||this.pendingRoster||this.pendingCompile||this.pendingPublish)
      fail('MF_QUEST_REQUEST_UNCERTAIN');
    if(document?.schema_version!=='quest-creation-document/1'||document.direction_mode!=='ai'||
       document.quest_kind!==this.document.quest.quest_kind)fail('MF_QUEST_VARIANT_DOCUMENT');
    if(!manual&&!this.proposalRequest)fail('MF_QUEST_PROPOSAL_REQUIRED');
    const payload={draft_id:this.draftId,expected_version:this.controlVersion,
      proposal_request:manual?null:this.proposalRequest,document:copy(document)};
    if(this.pendingVariant&&JSON.stringify(payload)!==JSON.stringify(this.pendingVariant.payload))
      fail(this.pendingVariant.payload?'MF_QUEST_VARIANT_PENDING':'MF_QUEST_RECOVERY_READBACK');
    this.pendingVariant??={key:this.uuid(),payload};
    this.assertActive();this.checkpoint(this.recoverySnapshot());
    const result=await this.api.commitQuestVariant({...copy(this.pendingVariant.payload),request_key:this.pendingVariant.key});
    if(result.request_key!==this.pendingVariant.key||result.draft_id!==this.draftId)
      fail('MF_QUEST_VARIANT_RECEIPT');
    await this.open(this.draftId);this.pendingVariant=null;this.proposal=null;return copy(result);
  }
  async requestPreview(){
    this.invalidateSchedule();
    if(!this.draftId||this.pendingSave||this.pendingRoster||this.pendingCompile||this.pendingVariant||this.pendingPublish)
      fail('MF_QUEST_REQUEST_UNCERTAIN');
    this.preview=copy(previewShape(await this.api.preview({draft_id:this.draftId,
      expected_version:this.controlVersion,content_kind:KIND}),this.draftId,this.controlVersion));
    return copy(this.preview);
  }
  canPublish(){return Boolean(!this.receipt&&!this.pendingPublish&&this.preview&&
    this.preview.errors.length===0&&SHA.test(this.preview.preview_seal||'')&&
    this.preview.draft_version===this.controlVersion&&
    this.preview.required_variants.length===1&&this.preview.required_variants[0]==='ai'&&
    this.preview.validated_variants.includes('ai'));}
  protectedPublicAvailability(){
    const c=this.catalog?.execution_context;if(!c)return false;
    return c.protected_public_quest_available===true&&c.mode==='staff_simulation'&&c.source_draft_id===this.draftId&&c.source_draft_version===this.controlVersion&&SHA.test(c.source_sha256||'')&&this.savedDocument===true;
  }
  publicAvailability(){return this.protectedPublicAvailability()||this.catalog?.execution_context?.public_general_available===true;}
  invalidateSchedule(){this.scheduleCapability=null;this.scheduleRequestSeq=(this.scheduleRequestSeq||0)+1;}
  scheduleKey(due){
    if(!this.canPublish() || !this.savedDocument || this.disposed || !this.lifecycle() ||
       this.pendingCreate || this.pendingSave || this.pendingCompile || this.pendingNpc ||
       this.pendingRoster || this.pendingVariant || this.pendingRewardPolicy || this.pendingPublish ||
       typeof due!=='string' || !Number.isFinite(Date.parse(due))) return null;
    return JSON.stringify([this.draftId,this.controlVersion,this.preview.preview_seal,
      new Date(due).toISOString(),this.authoringEpoch,this.document]);
  }
  canSchedule(due){const key=this.scheduleKey(due);return key!==null &&
    this.scheduleCapability?.key===key && this.scheduleCapability.value.allowed===true;}
  async checkSchedule(due){
    this.assertActive();this.invalidateSchedule();const seq=this.scheduleRequestSeq,key=this.scheduleKey(due);
    if(key===null)throw Error('Salva la bozza e verifica l’anteprima prima di programmare.');
    const value=await this.api.scheduleCapability({draft_id:this.draftId,expected_version:this.controlVersion,
      preview_seal:this.preview.preview_seal,due:new Date(due).toISOString()});
    this.assertActive();
    if(seq!==this.scheduleRequestSeq || key!==this.scheduleKey(due))throw Error('Programmazione cambiata: ripeti la verifica.');
    this.scheduleCapability={key,value:structuredClone(value)};return structuredClone(value);
  }
  async publish(visibility,scheduledAt=null){
    if(!['staff','scheduled','open'].includes(visibility))fail('MF_QUEST_VISIBILITY');
    if(visibility==='open'&&!this.publicAvailability())
      fail('MF_PUBLIC_OPEN_NOT_QUALIFIED');
    if(!this.canPublish())fail('MF_QUEST_PREVIEW_REQUIRED');
    if(visibility==='scheduled'&&(!scheduledAt||Number.isNaN(Date.parse(scheduledAt))))
      fail('MF_QUEST_SCHEDULE');
    const payload={draft_id:this.draftId,expected_version:this.controlVersion,
      preview_seal:this.preview.preview_seal,content_kind:KIND,visibility,scheduled_at:scheduledAt};
    if(visibility==='scheduled'){
      if(!this.canSchedule(scheduledAt))throw Error('Verifica la programmazione per questa data.');
      const capability=await this.checkSchedule(scheduledAt);
      if(capability.allowed!==true || !this.canSchedule(scheduledAt))throw Error('Programmazione non autorizzata dal server.');
    }
    this.pendingPublish??={key:this.uuid(),payload};
    const request=this.pendingPublish.key;
    this.assertActive();this.checkpoint(this.recoverySnapshot());
    const result=await this.api.publish({...copy(this.pendingPublish.payload),request_key:request});
    if(result.request_key!==request||result.content_kind!==KIND)fail('MF_QUEST_PUBLISH_RECEIPT');
    this.executionContext=copy(this.api.publishedExecutionContext(request));this.receipt=copy(result);this.publishedRequest=request;this.pendingPublish=null;
    return copy(result);
  }
  async refreshDelivery(){
    const request=this.pendingPublish?.key||this.publishedRequest;
    if(!request)fail('MF_QUEST_PUBLISH_MISSING');
    const state=requestResult(await this.api.publishState({request_key:request,content_kind:KIND}),
      request,'mission-factory-publish-state/2');
    if(state.state==='confirmed'){
      if(this.receipt&&JSON.stringify(this.receipt)!==JSON.stringify(state.result))fail('MF_QUEST_RECEIPT_DRIFT');
      this.executionContext=copy(this.api.publishedExecutionContext(request));this.receipt=copy(state.result);this.delivery=copy(state.delivery);
      this.publishedRequest=request;this.pendingPublish=null;
    }
    return copy(state);
  }
  async recoverPending(){
    const states=[];
    for(const [property,operation] of [['pendingCreate','create'],['pendingSave','save'],
      ['pendingRoster','roster'],['pendingVariant','quest_variant']]){
      const request=this[property]?.key;if(!request)continue;
      const state=requestResult(await this.api.requestState({request_key:request,content_kind:KIND}),
        request,'mission-factory-request-state/2');
      states.push({operation,state:state.state});
      if(state.state==='confirmed'){
        const schemas={create:'mission-factory-draft-created/2',save:'mission-factory-draft-save/2',
          roster:'mission-factory-quest-roster-assigned/1',quest_variant:'mission-factory-quest-variant/1'};
        if(state.result?.schema_version!==schemas[operation]||state.result?.request_key!==request)
          fail('MF_QUEST_REQUEST_RECEIPT');
        if(operation==='create')this.draftId=id(state.result.draft_id,'MF_QUEST_CREATED');
        else if(state.result.draft_id!==this.draftId)fail('MF_QUEST_REQUEST_DRAFT');
        this[property]=null;
      }
    }
    if(this.pendingRewardPolicy)states.push({operation:'reward_policy',state:(await this.readRewardPolicy()).state});
    if(this.pendingCompile||this.proposalRequest)states.push({operation:'compile',state:(await this.readCompile()).state});
    if(this.pendingPublish||this.publishedRequest)states.push({operation:'publish',state:(await this.refreshDelivery()).state});
    if(this.draftId&&!states.some(x=>x.state==='unknown'))await this.open(this.draftId);
    return states;
  }
}
