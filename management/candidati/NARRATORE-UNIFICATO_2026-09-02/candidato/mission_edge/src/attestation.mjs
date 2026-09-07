import {canonical} from './canonical/canonical.mjs';
export {canonical};
export async function sha256(x){const raw=typeof x==='string'?x:canonical(x);const b=await crypto.subtle.digest('SHA-256',new TextEncoder().encode(raw));return [...new Uint8Array(b)].map(v=>v.toString(16).padStart(2,'0')).join('')}
export function exact(x,keys){return x&&typeof x==='object'&&!Array.isArray(x)&&Object.keys(x).sort().join('|')===[...keys].sort().join('|')}

