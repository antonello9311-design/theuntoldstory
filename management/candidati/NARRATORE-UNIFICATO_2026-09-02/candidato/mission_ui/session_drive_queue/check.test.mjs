import test from 'node:test';
import assert from 'node:assert/strict';
import {runInNewContext} from 'node:vm';
import {sessionRuntime} from '../session-hook.mjs';
import {setImmediate} from 'node:timers/promises';
const prova='11111111-1111-4111-8111-111111111111';
function deferred(){let resolve;const promise=new Promise(r=>resolve=r);return {promise,resolve};}
function harness(){
  let calls=0,next='authorize',busy=false;const started=deferred(),done=deferred();
  const ctx={loggedIn:true,ordinarySigningOut:false,ordinaryAuthId:'owner',myId:'owner',myCharId:'pg',cur:{id:'room',is_exam_room:true},ES:{dato:null},renderEsame(){},loadMsgs(){},esAccetta(){},sb:{rpc:async()=>({data:{prova:{id:prova}},error:null,status:200})}};
  const src=sessionRuntime.toString();const api=runInNewContext(src.slice(src.indexOf('{')+1,src.lastIndexOf('}'))+';({MS,missionSessionKey,missionSessionRefresh,missionSessionDrive,missionSessionAccepted,missionSessionFlushDrive,missionSessionReset})',ctx);
  Object.assign(api.MS,{key:api.missionSessionKey(),prova,auto:true,readiness:{eligible:true,ready:true},controller:{observe:async()=>true,snapshot:()=>({stage:next,view:{next},busy}),resume:async()=>{calls++;started.resolve();return await done.promise;},clear(){}}});
  return {api,ctx,started,done,calls:()=>calls,setNext:n=>next=n,setBusy:b=>busy=b};
}
test('QUEUE01 Accepted durante refresh parte una volta al termine',async()=>{
  const h=harness(),read=deferred(),reading=deferred();h.api.MS.controller.observe=async()=>{reading.resolve();await read.promise;return true;};
  const refresh=h.api.missionSessionRefresh();await reading.promise;h.api.missionSessionAccepted();await Promise.resolve();assert.equal(h.calls(),0);assert.equal(h.api.MS.pendingDrive.prova,prova);
  read.resolve();await refresh;await h.started.promise;assert.equal(h.calls(),1);h.done.resolve(true);
});
test('QUEUE02 cambio contesto/prova, reset, errore e chiusura scartano il segnale',async()=>{
  for(const stop of [h=>h.ctx.myCharId='other',h=>h.api.MS.prova='other',h=>h.api.missionSessionReset(),h=>h.api.MS.auto=false,h=>h.api.MS.error='stopped',h=>h.setNext('complete')]){
    const h=harness();h.api.MS.loading=true;h.api.missionSessionAccepted();stop(h);h.api.MS.loading=false;h.api.missionSessionFlushDrive();await Promise.resolve();assert.equal(h.calls(),0);assert.equal(h.api.MS.pendingDrive,null);
  }
});
test('QUEUE03 segnali duplicati e controller busy non duplicano resume o retry',async()=>{
  const h=harness();h.api.MS.loading=true;h.api.missionSessionAccepted();h.api.missionSessionAccepted();await Promise.resolve();h.api.MS.loading=false;h.setBusy(true);h.api.missionSessionFlushDrive();assert.equal(h.calls(),0);h.setBusy(false);h.api.missionSessionFlushDrive();await h.started.promise;
  h.api.missionSessionAccepted();await h.api.missionSessionDrive();h.api.missionSessionFlushDrive();assert.equal(h.calls(),1);
  h.done.resolve(false);await setImmediate();h.api.missionSessionFlushDrive();assert.equal(h.calls(),1);assert.equal(h.api.MS.auto,false);assert.equal(h.api.MS.driveTicket,null);
});
