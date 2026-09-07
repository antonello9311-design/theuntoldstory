import {RPC} from './contracts.mjs';
export function createRpcClient({url,publishableKey,fetchFn=fetch}){return {async call(name,args){if(!Object.values(RPC).includes(name))throw Error('RPC_NOT_ALLOWED');const r=await fetchFn(`${url}/rest/v1/rpc/${name}`,{method:'POST',headers:{apikey:publishableKey,'content-type':'application/json'},body:JSON.stringify(args)});if(!r.ok)throw Object.assign(Error('RPC_FAILED'),{status:r.status,code:'RPC_FAILED'});return r.json()}}}

