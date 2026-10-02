// Consumer candidato PNG media. Il server e l'Edge restano l'autorità di ticket, byte e Builder.
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const SHA=/^[0-9a-f]{64}$/i;
const KINDS=new Set(['portrait','marker']);
const MIME=new Set(['image/png','image/jpeg','image/webp']);
const ASSET=/^npc_(portrait|marker)_[0-9a-f]{32}_[0-9a-f]{64}$/;
const PATH=/^ninja-book\/[a-z0-9_]+\/r[0-9]+\/assets\/[a-z0-9_]+_v1\.(png|jpe?g|webp)$/;
const EDGE='mission_factory_npc_media_attest_v1';
const RELEASE='mission-factory-npc-media/1';
const CERT_STATES=new Set(['review','incomplete','media_pending','ready','adopted']);
const COMBAT_CERT_SCHEMA='mission-factory-npc-combat-certification-state/1';
const fail=message=>{throw Error(message);};
const copy=value=>structuredClone(value);
const equal=(a,b)=>a?.template_id===b?.template_id&&a?.narrative_version_id===b?.narrative_version_id&&
  a?.narrative_content_sha256===b?.narrative_content_sha256&&a?.mechanical_template_id===b?.mechanical_template_id;
const bindingOf=x=>{
  if(!UUID.test(x?.template_id||'')||!UUID.test(x?.narrative_version_id||'')||
     !SHA.test(x?.content_sha256||'')||x?.mechanical_template_id!=null&&!UUID.test(x.mechanical_template_id))
    fail('Versione Ninja Book non attestata per i media.');
  return {template_id:x.template_id,narrative_version_id:x.narrative_version_id,
    narrative_content_sha256:x.content_sha256,mechanical_template_id:x.mechanical_template_id??null,
    review_state:x.review_state,current_version_id:x.current_version_id};
};
const validRegistration=(r,t)=>r?.schema_version==='npc-media-registration/1'&&
  r.request_key===t.request_key&&r.template_id===t.template_id&&
  r.narrative_version_id===t.narrative_version_id&&r.kind===t.kind&&r.media_id===t.media_id&&
  r.asset_id===t.asset_id&&r.bucket==='avatars'&&r.object_path===t.object_path&&r.sha256===t.sha256&&
  r.bytes===t.bytes&&r.mime_type===t.mime_type&&
  r.narrative_content_sha256===t.narrative_content_sha256&&
  r.mechanical_template_id===t.mechanical_template_id&&
  Number.isInteger(r.width_px)&&r.width_px>0&&Number.isInteger(r.height_px)&&r.height_px>0&&r.state==='registered';
const validTicket=(t,b,strict=true)=>t?.schema_version==='npc-media-ticket/1'&&
  UUID.test(t.request_key||'')&&t.template_id===b.template_id&&
  t.narrative_version_id===b.narrative_version_id&&
  (!strict||equal(t,b))&&KINDS.has(t.kind)&&UUID.test(t.media_id||'')&&
  ASSET.test(t.asset_id||'')&&t.asset_id.startsWith(`npc_${t.kind}_`)&&
  PATH.test(t.object_path||'')&&t.object_path.includes(`/assets/${t.asset_id}_v1.`)&&
  t.bucket==='avatars'&&
  SHA.test(t.sha256||'')&&Number.isSafeInteger(t.bytes)&&t.bytes>0&&MIME.has(t.mime_type)&&
  ['pending','registered','approved','expired'].includes(t.state)&&
  (t.state==='registered'||t.state==='approved'?validRegistration(t.registration,t):
    t.registration==null||validRegistration(t.registration,t));
const validPair=(p,b)=>p?.schema_version==='npc-media-pair/1'&&
  UUID.test(p.request_key||'')&&typeof p.replayed==='boolean'&&equal(p,b)&&
  UUID.test(p.portrait_media_id||'')&&UUID.test(p.marker_media_id||'')&&
  SHA.test(p.portrait_sha256||'')&&SHA.test(p.marker_sha256||'')&&p.state==='approved';
const validState=(s,b)=>{
  if(s?.schema_version!=='npc-media-state/1'||!equal(s,b)||typeof s.current!=='boolean'||
     !Array.isArray(s.tickets)||s.tickets.some(t=>!validTicket(t,b,false))||
     s.pair!=null&&!validPair(s.pair,b))fail('Stato media PNG non verificabile.');
  return s;
};
const fingerprint=(kind,file,sha)=>`${kind}:${sha}:${file.size}:${file.type}`;
const validCertification=(value,b,request)=>{
  if(value?.template_id!==b.template_id||value.narrative_version_id!==b.narrative_version_id||
     value.bundle_kind!=='narrative'||value.combat!==false||!CERT_STATES.has(value.status))
    fail('Stato certificazione PNG discordante.');
  const receipt=value.schema_version==='mission-factory-npc-certification/1';
  if(!receipt&&value.schema_version!=='mission-factory-npc-certification-state/1')
    fail('Stato certificazione PNG non riconosciuto.');
  if(receipt&&(value.status!=='adopted'||value.request_key!==request))
    fail('Ricevuta certificazione PNG discordante.');
  if(value.status==='adopted'){
    if(value.npc_id!==b.template_id||!UUID.test(value.npc_version_id||'')||
       !SHA.test(value.bundle_sha256||''))fail('Bundle PNG adottato non verificabile.');
  }else if((value.npc_id!=null)||(value.npc_version_id!=null)||(value.bundle_sha256!=null))
    fail('Certificazione PNG non adottata con riferimento inatteso.');
  return value;
};

const validCombatCertification=(value,b,request,receiptRequired=false)=>{
  if(value?.schema_version!==COMBAT_CERT_SCHEMA||value.template_id!==b.template_id||
     value.narrative_version_id!==b.narrative_version_id||value.bundle_kind!=='combat'||
     !CERT_STATES.has(value.status)||value.combat_eligible!==false)
    fail('Stato certificazione Combat PNG discordante.');
  const receipt=Object.hasOwn(value,'request_key')||Object.hasOwn(value,'replayed');
  if(receiptRequired&&!receipt||receipt&&(value.request_key!==request||typeof value.replayed!=='boolean'))
    fail('Ricevuta certificazione Combat PNG discordante.');
  if(value.status==='adopted'){
    if(value.npc_id!==b.template_id||!UUID.test(value.npc_version_id||'')||
       !SHA.test(value.bundle_sha256||''))fail('Bundle Combat PNG non verificabile.');
  }else if(value.npc_id!==null||value.npc_version_id!==null||value.bundle_sha256!==null)
    fail('Stato Combat non adottato con riferimenti inattesi.');
  return value;
};

export function createNpcMediaAdapter({client,getBinding}={}){
  if(typeof client?.rpc!=='function'||typeof client?.functions?.invoke!=='function'||
     typeof client?.auth?.getSession!=='function'||typeof getBinding!=='function')
    fail('Gateway media PNG non configurato.');
  let binding=null,state=null,pending={portrait:null,marker:null},pairPending=null,certPending=null,combatCertPending=null,busy=false,storageKey='';
  const rpc=async(name,args)=>{const r=await client.rpc(name,args);if(r?.error)throw r.error;return r?.data;};
  const current=async()=>bindingOf(await getBinding());
  const persist=()=>{
    if(!storageKey)fail('Recupero request media non configurato.');
    window.localStorage.setItem(storageKey,JSON.stringify({pending,pairPending,certPending,combatCertPending}));
  };
  const ensure=async()=>{
    const next=await current();
    const session=await client.auth.getSession(),actor=session?.data?.session?.user?.id;
    if(session?.error||!UUID.test(actor||''))fail('Sessione Staff non disponibile.');
    const key=`mf-png-media/1:${actor}:${next.template_id}:${next.narrative_version_id}:${next.narrative_content_sha256}:${next.mechanical_template_id||'none'}`;
    if(!equal(next,binding)||storageKey!==key){
      binding=next;state=null;pending={portrait:null,marker:null};pairPending=certPending=combatCertPending=null;storageKey=key;
      const stored=window.localStorage.getItem(key);
      if(stored){
        let value;try{value=JSON.parse(stored);}catch(_error){fail('Request media salvata non leggibile.');}
        for(const kind of KINDS){
          const p=value?.pending?.[kind];
          if(p&&UUID.test(p.request_key||'')&&typeof p.fingerprint==='string')pending[kind]=p;
        }
        const pp=value?.pairPending;
        if(pp&&UUID.test(pp.request_key||'')&&typeof pp.fingerprint==='string')pairPending=pp;
        if(UUID.test(value?.certPending?.request_key||''))certPending={request_key:value.certPending.request_key};
        if(UUID.test(value?.combatCertPending?.request_key||''))
          combatCertPending={request_key:value.combatCertPending.request_key};
      }
    }
    return next;
  };
  const load=async()=>{
    const b=await ensure();
    const raw=await rpc('npc_media_status_v1',{p_template:b.template_id,p_narrative_version:b.narrative_version_id});
    if(!equal(await current(),b))fail('Versione PNG cambiata durante la lettura media.');
    state=copy(validState(raw,b));
    for(const kind of KINDS){
      const p=pending[kind];if(!p)continue;
      const found=state.tickets.find(t=>t.request_key===p.request_key&&equal(t,b));
      if(found?.state==='registered'||found?.state==='approved')p.registered=true;
      if(found?.state==='expired')p.expired=true;
    }
    persist();
    return copy(state);
  };
  const upload=async(kind,file)=>{
    if(busy)fail('Operazione media già in corso.');
    if(!KINDS.has(kind)||!(file instanceof File)||!MIME.has(file.type)||!Number.isSafeInteger(file.size)||file.size<1)
      fail('Scegli PNG, JPEG o WebP non vuoto.');
    busy=true;
    try{
      const b=await ensure();
      if(b.review_state!=='draft')fail('I media si preparano nella bozza PNG corrente.');
      const hash=await crypto.subtle.digest('SHA-256',await file.arrayBuffer());
      const sha=Array.from(new Uint8Array(hash),x=>x.toString(16).padStart(2,'0')).join('');
      const fp=fingerprint(kind,file,sha);
      let p=pending[kind];
      if(p&&p.fingerprint!==fp){
        if(!p.registered)fail('La richiesta precedente è incerta: rileggi lo stato prima di cambiare file.');
        p=pending[kind]=null;persist();
      }
      if(!p){
        const old=state?.tickets.find(t=>equal(t,b)&&t.kind===kind&&t.sha256===sha&&t.bytes===file.size&&
          t.mime_type===file.type&&t.state!=='expired');
        p={request_key:old?.request_key||crypto.randomUUID(),fingerprint:fp,registered:Boolean(old?.registration),expired:false};
        pending[kind]=p;persist();
      }
      if(p.expired)fail('Ticket scaduto. Rileggi lo stato e scegli un nuovo file.');
      const ticket=await rpc('npc_media_ticket_v1',{p_template:b.template_id,p_narrative_version:b.narrative_version_id,
        p_kind:kind,p_request:p.request_key,p_sha256:sha,p_bytes:file.size,p_mime:file.type});
      if(!validTicket(ticket,b)||ticket.request_key!==p.request_key||ticket.kind!==kind||
         ticket.sha256!==sha||ticket.bytes!==file.size||ticket.mime_type!==file.type)
        fail('Ricevuta ticket PNG discordante.');
      if(ticket.state==='expired'){p.expired=true;persist();fail('Ticket scaduto. Rileggi lo stato e scegli un nuovo file.');}
      if(ticket.registration){p.registered=true;persist();await load();return copy(ticket.registration);}
      const session=await client.auth.getSession(),token=session?.data?.session?.access_token;
      if(session?.error||!token)fail('Sessione Staff non disponibile.');
      const r=await client.functions.invoke(EDGE,{body:file,headers:{Authorization:`Bearer ${token}`,
        'Content-Type':file.type,'x-mf-template-id':b.template_id,
        'x-mf-narrative-version-id':b.narrative_version_id,'x-mf-kind':kind,
        'x-mf-request-key':p.request_key,'x-mf-sha256':sha,'x-mf-expected-release':RELEASE}});
      if(r?.error)throw r.error;
      if(!validRegistration(r?.data,ticket))fail('Attestazione media PNG discordante.');
      p.registered=true;persist();
      const readback=await load();
      if(!readback.tickets.some(t=>t.request_key===p.request_key&&t.registration))
        fail('Registrazione media non confermata dal readback.');
      return copy(r.data);
    }finally{busy=false;}
  };
  const approvePair=async(portraitRequest,markerRequest)=>{
    if(busy)fail('Operazione media già in corso.');busy=true;
    try{
      const b=await ensure(),s=await load();
      if(b.review_state!=='approved'||b.current_version_id!==b.narrative_version_id||!s.current)
        fail('Approva prima il PNG nella versione narrativa corrente.');
      const portrait=s.tickets.find(t=>equal(t,b)&&t.kind==='portrait'&&t.request_key===portraitRequest&&t.registration);
      const marker=s.tickets.find(t=>equal(t,b)&&t.kind==='marker'&&t.request_key===markerRequest&&t.registration);
      if(!portrait||!marker||portraitRequest===markerRequest)fail('Servono ritratto e sagoma registrati.');
      if(s.pair&&s.pair.portrait_media_id===portrait.media_id&&s.pair.marker_media_id===marker.media_id)
        return copy(s.pair);
      const fp=`${b.template_id}:${b.narrative_version_id}:${b.narrative_content_sha256}:${b.mechanical_template_id||''}:${portraitRequest}:${markerRequest}`;
      if(pairPending&&pairPending.fingerprint!==fp)fail('La coppia PNG è cambiata: rileggi lo stato.');
      if(!pairPending){pairPending={fingerprint:fp,request_key:crypto.randomUUID()};persist();}
      const result=await rpc('npc_media_approve_pair_v1',{p_template:b.template_id,p_narrative_version:b.narrative_version_id,
        p_portrait_request:portraitRequest,p_marker_request:markerRequest,p_request_key:pairPending.request_key});
      if(!validPair(result,b)||result.request_key!==pairPending.request_key||
         result.portrait_media_id!==portrait.media_id||result.marker_media_id!==marker.media_id||
         result.portrait_sha256!==portrait.sha256||result.marker_sha256!==marker.sha256)
        fail('Ricevuta coppia PNG discordante.');
      const readback=await load();
      if(!readback.current||!readback.pair||readback.pair.portrait_media_id!==result.portrait_media_id||
         readback.pair.marker_media_id!==result.marker_media_id||
         readback.pair.narrative_content_sha256!==result.narrative_content_sha256)
        fail('Coppia PNG non confermata dal readback.');
      pairPending=null;persist();return copy(result);
    }finally{busy=false;}
  };
  const certificationStatus=async()=>{
    const b=await ensure();
    const mechanical=await rpc('npc_combat_read_v1',{p_template:b.template_id});
    if(mechanical?.schema_version!=='npc-combat-state/1'||
       mechanical.template_id!==b.template_id||mechanical.narrative_version_id!==b.narrative_version_id||
       typeof mechanical.combat!=='boolean')fail('Profilo narrativo PNG non attestato.');
    if(mechanical.combat===true){
      if(!UUID.test(mechanical.mechanical_template_id||'')||
         mechanical.mechanical_template_id!==b.mechanical_template_id)
        fail('Profilo Combat PNG non allineato alla versione narrativa.');
      const request=combatCertPending?.request_key||null;
      const result=await rpc('mission_factory_npc_combat_status_v1',{
        p_template:b.template_id,p_narrative_version:b.narrative_version_id,p_request:request});
      if(!equal(await current(),b))fail('Versione PNG cambiata durante la certificazione Combat.');
      const checked=copy(validCombatCertification(result,b,request));
      if(checked.status==='adopted'&&combatCertPending&&checked.request_key===request){
        combatCertPending=null;persist();
      }
      return checked;
    }
    if(mechanical.mechanical_template_id!==null)fail('Profilo PNG narrativo con meccanica inattesa.');
    const request=certPending?.request_key||null;
    const result=await rpc('mission_factory_npc_certification_status_v1',{
      p_template:b.template_id,p_narrative_version:b.narrative_version_id,p_request:request});
    if(!equal(await current(),b))fail('Versione PNG cambiata durante la certificazione.');
    const checked=copy(validCertification(result,b,request));
    if(checked.status==='adopted'&&certPending){certPending=null;persist();}
    return checked;
  };
  const certifyNarrative=async()=>{
    if(busy)fail('Operazione media o certificazione già in corso.');
    busy=true;
    try{
      const b=await ensure();
      const before=await certificationStatus();
      if(!before||before.status!=='ready')
        fail('Completa Review e media prima della certificazione narrativa.');
      certPending||={request_key:crypto.randomUUID()};persist();
      const request=certPending.request_key;
      const receipt=await rpc('mission_factory_npc_certify_narrative_v1',{
        p_template:b.template_id,p_narrative_version:b.narrative_version_id,p_request:request});
      validCertification(receipt,b,request);
      if(receipt.schema_version!=='mission-factory-npc-certification/1')
        fail('Ricevuta certificazione PNG non confermata.');
      const after=await certificationStatus();
      if(after?.status!=='adopted'||after.npc_version_id!==receipt.npc_version_id||
         after.bundle_sha256!==receipt.bundle_sha256)
        fail('Adozione PNG da rileggere con la stessa richiesta.');
      return copy(after);
    }finally{busy=false;}
  };
  const certifyCombat=async()=>{
    if(busy)fail('Operazione media o certificazione già in corso.');
    busy=true;
    try{
      const b=await ensure();
      const before=await certificationStatus();
      if(before?.bundle_kind!=='combat'||before.status!=='ready')
        fail('Completa Review Combat e media prima della certificazione.');
      combatCertPending||={request_key:crypto.randomUUID()};persist();
      const request=combatCertPending.request_key;
      const receipt=await rpc('mission_factory_npc_certify_combat_v1',{
        p_template:b.template_id,p_narrative_version:b.narrative_version_id,p_request:request});
      validCombatCertification(receipt,b,request,true);
      if(receipt.status!=='adopted')fail('Ricevuta certificazione Combat non adottata.');
      const after=await certificationStatus();
      if(after?.status!=='adopted'||after.npc_version_id!==receipt.npc_version_id||
         after.bundle_sha256!==receipt.bundle_sha256||after.combat_eligible!==false)
        fail('Adozione Combat da rileggere con la stessa richiesta.');
      return copy(after);
    }finally{busy=false;}
  };
  return {load,upload,approvePair,certificationStatus,certifyNarrative,certifyCombat,snapshot:()=>state?copy(state):null,
    pending:kind=>kind?pending[kind]&&{...pending[kind]}:{portrait:pending.portrait&&{...pending.portrait},marker:pending.marker&&{...pending.marker},pair:pairPending&&{...pairPending},certification:certPending&&{...certPending},combatCertification:combatCertPending&&{...combatCertPending}},
    resetExpired:kind=>{if(!KINDS.has(kind)||!pending[kind]?.expired)fail('Il ticket non è confermato scaduto.');
      pending[kind]=null;persist();},
    reset:()=>{binding=state=pairPending=certPending=combatCertPending=null;pending={portrait:null,marker:null};}};
}
