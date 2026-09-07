import {createHash} from 'node:crypto';
const nfc=x=>typeof x==='string'?x.normalize('NFC'):x;
const scalarCompare=(a,b)=>{const ai=a[Symbol.iterator](),bi=b[Symbol.iterator]();for(;;){const av=ai.next(),bv=bi.next();if(av.done||bv.done)return av.done===bv.done?0:av.done?-1:1;const ac=av.value.codePointAt(0),bc=bv.value.codePointAt(0);if(ac!==bc)return ac<bc?-1:1}};
export function canonical(x){if(typeof x==='number'){if(!Number.isSafeInteger(x))throw Error('CANONICAL_NUMBER_DOMAIN');return String(x)}if(Array.isArray(x))return `[${x.map(canonical).join(',')}]`;if(x&&typeof x==='object'){const entries=Object.entries(x).map(([k,v])=>[nfc(k),v]);if(new Set(entries.map(([k])=>k)).size!==entries.length)throw Error('CANONICAL_KEY_COLLISION');entries.sort(([a],[b])=>scalarCompare(a,b));return `{${entries.map(([k,v])=>`${JSON.stringify(k)}:${canonical(v)}`).join(',')}}`}return JSON.stringify(nfc(x))}
export const sha256=x=>createHash('sha256').update(canonical(x),'utf8').digest('hex');

