// Composizione isolata: ancore uniche, nessuna scrittura sul sito pubblicato.
export function canCloseSession({own,prova,loading,busy,closed}) {
  return own===true&&typeof prova==='string'&&/^[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(prova)&&loading===false&&busy===false&&closed===false;
}
export function sessionRuntime() {
  // Solo categorie pubbliche: mai messaggi arbitrari SQL, token, dettagli o role.
  function missionSessionDiagnostic(result){
    var code=result&&result.error&&result.error.code;
    code=typeof code==='string'&&/^(?:[0-9A-Z]{5}|PGRST[0-9]{3})$/.test(code)?code:'non disponibile';
    var status=result&&result.status;
    status=Number.isInteger(status)&&status>=0&&status<=599?String(status):'non disponibile';
    var data=result&&result.data;
    var shape=data===null?'null':Array.isArray(data)?'array':typeof data;
    var prova=data&&typeof data==='object'&&!Array.isArray(data)?data.prova:null;
    var id=prova&&typeof prova==='object'?prova.id:null;
    var match=typeof id==='string'?(id===MS.prova?'coincidente':'diverso'):'assente';
    return 'HTTP '+status+'; codice '+code+'; risposta '+shape+'; prova '+match+'.';
  }
  var MS={key:null,readiness:null,loading:false,error:null,prova:null,controller:null,auto:false,openKeys:new Set(),closeKeys:new Map(),mechanical:false,pendingDrive:null,driveTicket:null};
  function missionSessionKey(){return loggedIn&&!ordinarySigningOut&&ordinaryAuthId===myId&&myCharId&&cur&&cur.is_exam_room?JSON.stringify([myId,myCharId,cur.id]):null;}
  function missionSessionReset(){
    if(!MS)return;
    if(MS.controller)MS.controller.clear();
    MS.key=null;MS.readiness=null;MS.loading=false;MS.error=null;MS.prova=null;MS.controller=null;MS.auto=false;MS.mechanical=false;MS.pendingDrive=null;MS.driveTicket=null;
  }
  function missionSessionOwn(){return !!(MS&&MS.key===missionSessionKey()&&MS.readiness&&MS.readiness.eligible===true);}
  function missionSessionLegacyBlocked(){return !!(missionSessionKey()&&(!MS||MS.key!==missionSessionKey()||!MS.readiness||MS.readiness.eligible!==false));}
  function missionSessionView(){return MS&&MS.controller?MS.controller.snapshot():null;}
  function missionSessionPlayer(){var s=missionSessionView();return !!(missionSessionOwn()&&!MS.loading&&!s?.busy&&s?.view?.next==='player'&&!MS.error);}
  function missionSessionCanClose(){var s=missionSessionView();return canCloseSession({own:missionSessionOwn(),prova:MS.prova,loading:MS.loading,busy:s?.busy===true,closed:s?.view?.next==='complete'});}
  function missionSessionBind(){
    if(MS.controller||!MS.prova)return;
    MS.controller=missionSessionLibrary.createSessionController({
      adapter:missionSessionLibrary.createSessionAdapter({client:sb,getProva:function(){return MS.prova;}}),
      contextKey:missionSessionKey,onChange:function(){renderEsame();}
    });
  }
  async function missionSessionReadiness(){
    var key=missionSessionKey();if(!key||MS.loading)return;
    if(MS.key!==key){missionSessionReset();MS.key=key;}
    MS.loading=true;MS.error=null;
    try{
      var r=await sb.rpc('esame_session_readiness',{});
      if(key!==missionSessionKey()||key!==MS.key)return;
      var d=r&&r.data;
      if(r.error||!d||d.ok!==true||typeof d.eligible!=='boolean'||typeof d.ready!=='boolean'||typeof d.protected!=='boolean'||d.version!=='MISSION-EXAM-SESSION-001')throw Error('Verifica della prova non disponibile. Nessun avvio eseguito.');
      if(d.eligible&&(d.candidate_character!==myCharId||d.location_id!==cur.id||d.protected!==true||!d.budget||!Number.isSafeInteger(d.budget.used)||!Number.isSafeInteger(d.budget.limit)||d.budget.used<0||d.budget.limit<0))throw Error('Contesto o budget della prova non confermati dal server.');
      if(d.existing_prova!==null&&!missionSessionLibrary.isUUID(d.existing_prova))throw Error('Identificativo della prova non valido.');
      MS.readiness=d;MS.prova=d.eligible?d.existing_prova:null;
      if(MS.prova)missionSessionBind();
    }catch(e){if(key===MS.key){MS.error=String(e.message);MS.auto=false;}}
    finally{if(key===MS.key){MS.loading=false;renderEsame();missionSessionFlushDrive();}}
  }
  async function missionSessionRefresh(){
    var key=missionSessionKey();if(!missionSessionOwn()||MS.loading||!MS.prova)return;
    missionSessionBind();MS.loading=true;
    try{
      await MS.controller.observe();
      if(key!==MS.key||key!==missionSessionKey())return;
      var s=MS.controller.snapshot();
      if(s.stage==='stopped'){MS.error='La prova è in pausa: '+s.error;MS.auto=false;return;}
      if(s.view?.next==='complete'){MS.auto=false;MS.error=null;return;}
      var result=await sb.rpc('esame_prova_stato',{p_prova:MS.prova});
      if(key!==MS.key||key!==missionSessionKey())return;
      if(!result||result.error||result.data?.prova?.id!==MS.prova)throw Error('Stato della prova non disponibile. '+missionSessionDiagnostic(result));
      MS.error=null;MS.mechanical=true;esAccetta(result.data);MS.mechanical=false;
    }catch(e){if(key===MS.key){MS.mechanical=false;MS.error=String(e.message);MS.auto=false;}}
    finally{if(key===MS.key){MS.loading=false;renderEsame();missionSessionFlushDrive();}}
  }
  async function missionSessionDrive(){
    if(!missionSessionOwn()||!MS.auto||!MS.controller||MS.driveTicket)return;
    if(MS.loading||missionSessionView()?.busy){MS.pendingDrive={key:MS.key,prova:MS.prova};return;}
    var ticket={key:MS.key,prova:MS.prova};MS.pendingDrive=null;MS.driveTicket=ticket;
    try{
      var ok=await MS.controller.resume();
      if(ticket.key!==MS.key||ticket.key!==missionSessionKey()||ticket.prova!==MS.prova)return;
      if(!ok){MS.auto=false;MS.error='Narrazione in pausa. Nessuna chiamata viene ripetuta automaticamente.';}
      await missionSessionRefresh();loadMsgs();renderEsame();
    }finally{if(MS.driveTicket===ticket){MS.driveTicket=null;missionSessionFlushDrive();}}
  }
  async function missionSessionStart(){
    if(!missionSessionOwn()||!MS.readiness.ready||MS.loading||MS.prova||MS.openKeys.has(MS.key))return;
    var key=MS.key,request=crypto.randomUUID();MS.openKeys.add(key);MS.loading=true;MS.error=null;renderEsame();
    try{
      var r=await sb.rpc('esame_session_open',{p_request:request}),d=r&&r.data;
      if(key!==MS.key||key!==missionSessionKey())return;
      if(r.error||d?.ok!==true||d.protected!==true||d.version!=='MISSION-EXAM-SESSION-001'||!missionSessionLibrary.isUUID(d.prova)||!missionSessionLibrary.isUUID(d.class_session_id))throw Error('Apertura non confermata. Rileggi lo stato senza avviare una seconda prova.');
      MS.prova=d.prova;ES.sess=d.class_session_id;missionSessionBind();MS.auto=true;
    }catch(e){if(key===MS.key){MS.error=String(e.message);MS.auto=false;}}
    finally{if(key===MS.key){MS.loading=false;renderEsame();}}
    if(key===MS.key&&MS.auto)await missionSessionDrive();
  }
  async function missionSessionClose(){
    if(!missionSessionCanClose())return;
    var key=MS.key,prova=MS.prova;
    if(!MS.closeKeys.has(prova))MS.closeKeys.set(prova,crypto.randomUUID());
    MS.loading=true;MS.auto=false;MS.pendingDrive=null;renderEsame();
    try{
      var r=await sb.rpc('esame_session_close',{p_prova:prova,p_request:MS.closeKeys.get(prova)}),d=r&&r.data;
      if(key!==MS.key||key!==missionSessionKey())return;
      if(r.error||d?.ok!==true||d.prova!==prova||d.closed!==true||d.protected!==true)throw Error('Chiusura non confermata. La prova rimane in pausa: rileggi lo stato.');
    }catch(e){if(key===MS.key)MS.error=String(e.message);}
    finally{if(key===MS.key){MS.loading=false;await missionSessionRefresh();renderEsame();}}
  }
  function missionSessionLoad(){
    var key=missionSessionKey();
    if(!key){if(MS&&MS.key)missionSessionReset();return false;}
    if(MS.key!==key||!MS.readiness){missionSessionReadiness();return true;}
    if(!MS.readiness.eligible)return false;
    missionSessionRefresh();renderEsame();return true;
  }
  function missionSessionAccepted(){
    if(missionSessionOwn()&&!MS.mechanical&&MS.auto&&!MS.driveTicket){MS.pendingDrive={key:MS.key,prova:MS.prova};Promise.resolve().then(missionSessionFlushDrive);}
  }
  function missionSessionFlushDrive(){
    var pending=MS.pendingDrive,s=missionSessionView();if(!pending)return;
    if(!missionSessionOwn()||pending.key!==MS.key||pending.prova!==MS.prova||!MS.auto||MS.error||s?.view?.next==='complete'){MS.pendingDrive=null;return;}
    if(MS.loading||MS.driveTicket||s?.busy)return;
    MS.pendingDrive=null;missionSessionDrive();
  }
  function missionSessionRender(){
    if(!missionSessionKey())return false;
    var card=esEl('esm-card'),body=esEl('esm-body');if(!card||!body)return true;
    if(MS.readiness&&MS.key===missionSessionKey()&&MS.readiness.eligible===false)return false;
    card.hidden=false;
    var own=missionSessionOwn(),s=missionSessionView();
    if(own&&ES.dato?.prova?.id===MS.prova&&s?.view?.next!=='complete')renderEsameLegacy();else {body.replaceChildren();esSig=null;}
    var previous=document.getElementById('mission-session-status');if(previous)previous.remove();
    var panel=document.createElement('section');panel.id='mission-session-status';body.prepend(panel);
    function text(value){var p=document.createElement('p');p.textContent=value;panel.append(p);}
    function button(label,fn,disabled){var b=document.createElement('button');b.type='button';b.className='esm-btn';b.textContent=label;b.disabled=!!disabled;b.addEventListener('click',fn);panel.append(b);}
    text('Campione Esame protetto · nessun premio o avanzamento reale.');
    var budget=s?.view?.budget||MS.readiness?.budget;
    if(budget)text('Chiamate IA: '+budget.used+' / '+budget.limit+'.');
    if(MS.error)text(MS.error);
    else if(!own)text('Verifica del contesto in corso.');
    else if(!MS.readiness.ready)text(MS.readiness.reason||'La prova non è ancora disponibile.');
    else if(s?.view?.next==='complete')text('Campione concluso. Lo storico resta disponibile.');
    else if(!MS.prova)button('Sostieni l’Esame Genin',missionSessionStart,MS.loading||MS.openKeys.has(MS.key));
    else if(!MS.auto&&s?.view?.next!=='complete')button('Riprendi la prova',function(){MS.error=null;MS.auto=true;missionSessionDrive();},MS.loading||s?.busy);
    if(missionSessionOwn()&&MS.prova&&s?.view?.next!=='complete')button('Chiudi il campione',missionSessionClose,!missionSessionCanClose());
    if(MS.error)button('Rileggi lo stato',async function(){MS.error=null;if(!MS.prova)await missionSessionReadiness();else await missionSessionRefresh();},MS.loading);
    var compose=esEl('esm-componi');if(compose)compose.disabled=!missionSessionPlayer();
    var oldStart=esEl('esm-avvia');if(oldStart)oldStart.remove();
    return true;
  }
}

export function composeSessionHook(base, controllerSource) {
  let output=base;
  const once=(old,replacement)=>{
    if(output.split(old).length!==2)throw Error('anchor_not_unique:'+old.slice(0,70));
    output=output.replace(old,replacement);
  };
  const library=controllerSource.replace(/^export /gm,'');
  const runtime=sessionRuntime.toString();
  const body=runtime.slice(runtime.indexOf('{')+1,runtime.lastIndexOf('}'));
  once('      function esAvvia(){',
    '      var missionSessionLibrary=(function(){\n'+library+'\nreturn {createSessionController,createSessionAdapter,isUUID};})();\n'+canCloseSession.toString()+'\n'+body+'\n      function esAvvia(){\n        if(missionSessionLegacyBlocked()){missionSessionStart();return;}');
  once('      function loadEsame(){','      function loadEsame(){if(missionSessionLoad())return;return loadEsameLegacy();}\n      function loadEsameLegacy(){');
  once('      function renderEsame(){','      function renderEsame(){if(missionSessionRender())return;return renderEsameLegacy();}\n      function renderEsameLegacy(){');
  once('      function esIASpinta(){','      function esIASpinta(){\n        if(missionSessionLegacyBlocked())return;');
  once('try{ esIASpinta(); }catch(e){} }','try{ esIASpinta(); }catch(e){} missionSessionAccepted(); }');
  once('      function esEntra(){','      function esEntra(){\n        if(missionSessionLegacyBlocked())return;');
  once('      function esProvaId(){','      function esProvaId(){\n        if(missionSessionOwn())return MS.prova;');
  once('      function esComponi(){','      function esComponi(){\n        if(missionSessionLegacyBlocked()&&!missionSessionPlayer())return;');
  once('      function esInvia(az, testo, grezzo){','      function esInvia(az, testo, grezzo){\n        if(missionSessionLegacyBlocked()&&!missionSessionPlayer()){azErr("Attendi lo stato autorizzato della prova.");return;}');
  once('      function esInviaUscita(testo, grezzo){','      function esInviaUscita(testo, grezzo){\n        if(missionSessionLegacyBlocked()){toast("Usa Chiudi il campione: nessuna uscita con premi reali.");return;}');
  once("if(p.fase==='uscita'){", "if(p.fase==='uscita'&&!missionSessionOwn()){");
  once('&& (esGatePubblico() || esGateQA()));','&& (missionSessionOwn() || esGatePubblico() || esGateQA()));');
  once('      function esReset(){ ES=', '      function esReset(){ missionSessionReset(); ES=');
  once("window.addEventListener('tus:ordinary-logout',function(){esameHoldRevoked=true;esameHoldStop();});", "window.addEventListener('tus:ordinary-logout',function(){missionSessionReset();esameHoldRevoked=true;esameHoldStop();});");
  once('        var nextId=session&&session.user?session.user.id:null;', '        var nextId=session&&session.user?session.user.id:null;\n        if(event===\'SIGNED_OUT\'||nextId!==myId)missionSessionReset();');
  return output.replace('LAND-MARIONETTA-MOVEMENT-PICKER-001','LAND-MISSION-EXAM-SESSION-001');
}
