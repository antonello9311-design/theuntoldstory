import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {Script} from 'node:vm';
import {createSessionController,createSessionAdapter,SESSION_VERSION} from './session-controller.mjs';
import {composeSessionHook,canCloseSession} from './session-hook.mjs';
const prova='11111111-1111-4111-8111-111111111111',receipt='22222222-2222-4222-8222-222222222222',draft='33333333-3333-4333-8333-333333333333';
const view=(next='player')=>({authorized:true,protectedSession:true,sessionPolicy:'SESSION',prova,next,actionKey:receipt,draft,budget:{used:0,limit:2}});
test('SESSION-UI-01 · mount readonly, scope protetto e input mancanti',async()=>{
  let calls=0;
  const c=createSessionController({contextKey:()=> 'owner',adapter:{read:async()=>view('authorize'),authorize:async()=>{calls++;}}});
  assert.equal(calls,0);assert.equal(await c.observe(),true);assert.equal(calls,0);
  const bad=createSessionController({contextKey:()=> 'owner',adapter:{read:async()=>({...view(),protectedSession:false})}});
  assert.equal(await bad.observe(),false);assert.equal(bad.snapshot().view,null);
  const unknown=createSessionController({contextKey:()=> 'owner',adapter:{read:async()=>({...view(),budget:null})}});
  assert.equal(await unknown.observe(),false);
});
test('SESSION-UI-04 · catena seriale, ricevuta server e monouso',async()=>{
  let stage=0;const calls=[];
  const c=createSessionController({contextKey:()=> 'owner',adapter:{read:async()=>view(['authorize','generate','publish','player'][stage]),
    authorize:async v=>{assert.equal(v.actionKey,receipt);calls.push('authorize');stage++;},
    generate:async()=>{calls.push('generate');stage++;},publish:async()=>{calls.push('publish');stage++;}}});
  await Promise.all([c.resume(),c.resume()]);
  assert.deepEqual(calls,['authorize','generate','publish']);assert.equal(c.snapshot().stage,'player');
  const raw={ok:true,prova,protected:true,version:SESSION_VERSION,player_ready:false,publishing:false,closed:false,opening_published:false,error:null,receipt_id:receipt,budget:{used:0,limit:2},draft:null};
  const rpc=[];const adapter=createSessionAdapter({getProva:()=>prova,client:{rpc:async(name,args)=>{rpc.push([name,args]);return {data:name==='esame_session_state'?raw:draft};}}});
  const observed=await adapter.read();await adapter.authorize(observed);
  assert.deepEqual(rpc[1],['esame_session_authorize',{p_prova:prova,p_ricevuta:receipt}]);
  raw.receipt_id=null;await assert.rejects(adapter.read(),/receipt_missing/);
});
test('SESSION-UI-06 · errore senza retry, revoca e risposta tardiva',async()=>{
  let attempts=0;
  const c=createSessionController({contextKey:()=> 'owner',adapter:{read:async()=>view('generate'),generate:async()=>{attempts++;throw Error('uncertain');}}});
  assert.equal(await c.resume(),false);assert.equal(await c.resume(),false);assert.equal(attempts,1);
  await c.observe();assert.equal(await c.resume(),false);assert.equal(attempts,1);
  let key='first',release;const pending=new Promise(resolve=>{release=resolve;});
  const late=createSessionController({contextKey:()=>key,adapter:{read:async()=>{await pending;return view('generate');},generate:async()=>{throw Error('must_not_run');}}});
  const work=late.resume();key='second';late.clear();release();await work;
  assert.equal(late.snapshot().view,null);assert.equal(late.snapshot().stage,'idle');
});
test('SESSION-UI-13 · budget server, termine protetto e hook senza fallback',async()=>{
  // F3: la disponibilità della chiusura non dipende dalla fase player/uscita.
  for(const stage of ['paused','waiting','stopped','player']){
    assert.equal(canCloseSession({own:true,prova,loading:false,busy:false,closed:false,stage}),true);
  }
  for(const denied of [{own:false},{loading:true},{busy:true},{closed:true},{prova:null}]){
    assert.equal(canCloseSession({own:true,prova,loading:false,busy:false,closed:false,...denied}),false);
  }
  let generated=0;
  const cap=createSessionController({contextKey:()=> 'owner',adapter:{read:async()=>({...view('generate'),budget:{used:2,limit:2}}),generate:async()=>{generated++;}}});
  assert.equal(await cap.resume(),false);assert.equal(generated,0);
  let published=0;
  const ready=createSessionController({contextKey:()=> 'owner',adapter:{read:async()=>({...view(published?'complete':'publish'),budget:{used:2,limit:2}}),publish:async()=>{published++;}}});
  assert.equal(await ready.resume(),true);assert.equal(published,1);
  const base=readFileSync(new URL('../../../../../sito_live/land.html',import.meta.url),'utf8');
  const source=readFileSync(new URL('./session-controller.mjs',import.meta.url),'utf8');
  const composed=composeSessionHook(base,source);
  for(const match of composed.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/gi))if(match[1].trim())new Script('(async function(){'+match[1]+'})');
  assert(composed.includes('function esIASpinta(){\n        if(missionSessionLegacyBlocked())return;'));
  assert(composed.includes("sb.rpc('esame_session_open',{p_request:request})"));
  assert(composed.includes("sb.rpc('esame_session_close',{p_prova:prova,p_request:MS.closeKeys.get(prova)})"));
  assert(composed.includes('if(!missionSessionCanClose())return;'));
  assert(!composed.includes("if(!missionSessionPlayer()||s.view.phase!=='uscita'||MS.loading)return;"));
  assert(composed.includes('if(missionSessionLegacyBlocked()){toast('));
  assert(!source.includes('esame_prova_uscita'));
});
