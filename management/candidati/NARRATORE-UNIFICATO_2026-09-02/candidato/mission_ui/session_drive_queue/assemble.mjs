import {readFileSync,writeFileSync,existsSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {Script} from 'node:vm';
import {sessionRuntime} from '../session-hook.mjs';
const sha=b=>createHash('sha256').update(b).digest('hex');
const base=readFileSync(new URL('../session_panel_fix/land.html',import.meta.url));
if(base.length!==776143||sha(base)!=='6a6db1af7bf816878190b6db799e1f549b90fdaf3209e30d3b4cf758bf49b35a')throw Error('baseline_drift');
const text=base.toString(),anchor='  // Solo categorie pubbliche:',start=text.indexOf(anchor),end=text.indexOf('\n      function esAvvia(){',start);
if(start<0||end<start||text.indexOf(anchor,start+1)!==-1)throw Error('anchor_not_unique');
const runtime=sessionRuntime.toString(),body=runtime.slice(runtime.indexOf('{')+1,runtime.lastIndexOf('}'));
const output=Buffer.from((text.slice(0,start)+body+text.slice(end)).replace('content="LAND-EXAM-PANEL-RECOVERY-001"','content="LAND-EXAM-DRIVE-QUEUE-001"'));
let scripts=0;for(const m of output.toString().matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/gi)){if(m[1].trim()){new Script('(async function(){\n'+m[1]+'\n})');scripts++;}}
const manifest={status:'candidate_not_published',baseline:{commit:'e20c9f2d838c793622d63a0f456d29c0b74a1a6e',bytes:base.length,sha256:sha(base)},output:{bytes:output.length,sha256:sha(output),build:'LAND-EXAM-DRIVE-QUEUE-001'},syntaxScripts:scripts,scope:'Segnale Accepted accodato per contesto e prova; flush dopo sola lettura, singolo drive in volo, scarto su revoca/errore/chiusura. Nessun timer, nuova RPC, reinvio azione o retry provider.',budget:{groups:3,provider:0,minutes:10}};
for(const[name,data]of [['land.html',output],['MANIFEST.json',Buffer.from(JSON.stringify(manifest,null,2)+'\n')]]){const url=new URL(name,import.meta.url);if(existsSync(url)&&!readFileSync(url).equals(data))throw Error('candidate_drift:'+name);if(!existsSync(url))writeFileSync(url,data,{flag:'wx'});}
console.log(JSON.stringify(manifest));
