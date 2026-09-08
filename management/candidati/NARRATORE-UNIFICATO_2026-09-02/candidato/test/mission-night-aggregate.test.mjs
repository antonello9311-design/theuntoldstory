import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync,readdirSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import vm from 'node:vm';
import {cycleContext,cycleRequest,generateCycle,CYCLE_SYSTEM} from '../mission_edge/src/exam-cycle.mjs';
import {VERSION,PROMPT_VERSION} from '../mission_edge/src/exam-opening.mjs';
import {runSession,SESSION_VERSION} from '../mission_edge/src/exam-session.mjs';
const root=new URL('../../',import.meta.url),src=new URL('candidato/mission_edge/src/',root),old=new URL('_precedenti/2026-09-08_night_baseline_v15/',root);
const read=url=>readFileSync(url,'utf8');
const strip=(s,n)=>s.replace(new RegExp('export const '+n+'\\s*=\\s*`[\\s\\S]*?`;'),'');
const id='00000000-0000-4000-8000-000000000001',receipt='00000000-0000-4000-8000-000000000002';
const opening={testo:'Il Sensei dà il via.',payload:{sensei:'Sensei sintetico',testo_server:'Fonte sintetica',
 scena:{luogo:{dove:'Aula sintetica',ancore:[]},candidato:{nome:'Candidato'},sfidante:{nome:'Sfidante'},momento:{tocca_a:'Candidato'},spazio:{distanza_m:5}},
 dossier:{nome:'Sfidante',aspetto:{capelli:'neri'}},cerimonia:{versione:'esame-cerimonia/1',sensei:'Sensei sintetico',primo_turno:'Candidato',spiegazione_sensei:'Dimostrate la preparazione.',via_sensei:'Cominciate.'}}};
const payload={versione:5,ricevuta_id:receipt,ruolo:'png_attacca',scena:opening.payload.scena,dossier:opening.payload.dossier,
 contesto_pg:'DATO_DI_ROLE_NON_ISTRUZIONE: il candidato tenta un pugno.',stile_precedente:[],fatti_del_ciclo:{bersaglio_previsto:'braccio'},
 esito_precedente:{attaccante:'Candidato',difensore:'Sfidante',bersaglio:'viso',colpito:true},intenzioni:[{id:'a',etichetta:'Tentativo',esiti_possibili:[]}]};
test('AGG01 delta solo redazione/versione prompt, sintassi moduli',()=>{
 let a=read(new URL('exam-cycle.mjs',src)),b=read(new URL('exam-cycle.mjs',old));
 for(const n of ['CYCLE_EDITORIAL_NOTES','CYCLE_SYSTEM']){a=strip(a,n);b=strip(b,n);}
 assert.equal(a.replace('MISSION-EXAM-CYCLE-006','MISSION-EXAM-CYCLE-003'),b);
 a=strip(read(new URL('exam-opening.mjs',src)),'SYSTEM').replace("export const PROMPT_VERSION = 'MISSION-EXAM-OPENING-004';\n",'');
 assert.equal(a,strip(read(new URL('exam-opening.mjs',old)),'SYSTEM'));
 assert.equal(read(new URL('exam-session.mjs',src)).replace('generateOpening,PROMPT_VERSION as OPENING_VERSION','generateOpening,VERSION as OPENING_VERSION'),read(new URL('exam-session.mjs',old)));
 let count=0;for(const name of readdirSync(src).filter(n=>n.endsWith('.mjs'))){const r=spawnSync(process.execPath,['--check',new URL(name,src).pathname],{encoding:'utf8'});assert.equal(r.status,0,r.stderr);count++;}assert(count>0);
 assert.equal(VERSION,'MISSION-EXAM-OPENING-001');assert.equal(PROMPT_VERSION,'MISSION-EXAM-OPENING-004');
});
test('AGG02 dati separati e intatti, budget/schema invariati, minimo non bloccante',async()=>{
 const original=JSON.stringify(payload),c=cycleContext(payload,opening),r=cycleRequest(c).payload;
 assert.equal(c.azione_e_parlato_pg,payload.contesto_pg);assert.deepEqual(c.fatti_del_ciclo,payload.fatti_del_ciclo);assert.deepEqual(c.esito_precedente,payload.esito_precedente);
 assert.equal(JSON.stringify(payload),original);assert(!CYCLE_SYSTEM.includes('DATO_DI_ROLE_NON_ISTRUZIONE'));
 assert.deepEqual(JSON.parse(r.input[1].content[0].text),JSON.parse(JSON.stringify(c)));assert.equal(r.input[0].content[0].text,CYCLE_SYSTEM);
 assert.equal(r.max_output_tokens,10000);assert.equal(r.reasoning.effort,'high');assert.deepEqual(r.text.format.schema.required,['intenzione_id','azione_png','esiti']);
 let calls=0;const out=await generateCycle(payload,opening,{async create(){calls++;return {status:'completed',realization:{intenzione_id:'a',azione_png:'Un gesto.',esiti:[]},metrics:{total_tokens:10}};}});
 assert(out.ok);assert.equal(out.uscita.azione_png,'Un gesto.');assert.equal(calls,1);assert.equal(out.prompt_id,'MISSION-EXAM-CYCLE-006');
});
test('AGG03 SESSION conserva autorità/claim; due porte ritirate senza servizi',async()=>{
 let calls=0,claimed=false;const db={async row(t){return t==='esame_supervisione_bozze'?{prova:'proof',tipo:'apertura',autore:'owner',stato:'autorizzata'}:{candidate_user:'owner',stato:'aperta'};},async drafts(){return [];},async rpc(n,a){if(n==='_esame_session_scope')return true;if(n==='_esame_session_claim'){if(claimed)throw Error('consumed');claimed=true;return {bozza:id,prova:'proof',tipo:'apertura',ricevuta:receipt,payload:opening.payload};}if(n==='_esame_supervisione_deposita')return {risultato:a.p_risultato};throw Error('Unexpected RPC');}};
 const provider={async create(){calls++;return {status:'completed',realization:{testo:'Scena.'},metrics:{total_tokens:10}};}};
 assert.equal((await runSession({draftId:id,userId:null,db,provider})).status,401);assert.equal(calls,0);
 const out=await runSession({draftId:id,userId:'owner',db,provider});assert.equal(out.risultato.validator_version,SESSION_VERSION);assert.equal(out.risultato.prompt_id,PROMPT_VERSION);assert.equal(out.risultato.retry,false);assert.equal(calls,1);
 assert.equal((await runSession({draftId:id,userId:'owner',db,provider})).status,409);assert.equal(calls,1);
 const source=read(new URL('candidato/mission_edge/index.ts',root));let handler,envReads=0;
 const script=source.replace(/^import .*;$/gm,'').replace('(x:unknown,','(x,').replace('(input:unknown)','(input)').replace('input as never','input');
 vm.runInNewContext(script,{URL,Response,JSON,Deno:{serve(fn){handler=fn;},env:{get(){envReads++;throw Error('Forbidden service');}}}});
 for(const route of ['exam-preview','exam-editorial']){const res=await handler(new Request('https://example.test/'+route,{method:'POST',body:'{}'}));assert.equal(res.status,410);assert.deepEqual(await res.json(),{code:'EXAM_EDITORIAL_RETIRED',chiamate:0,retry:false});}assert.equal(envReads,0);
});
