// Stesso runtime, prompt, limiti e provider; solo porte di persistenza dedicate.
import {sceneOrdinary} from './runtime.ts';
const methods=new Map(['acquire','permit','status','save','complete'].map(x=>[
  `combat_consumer_scene_${x}_v2`,`combat_consumer_recovery_${x}_v1`
]));
export async function recoveryOrdinary(body:any,channel:any,dependencies:any){
  if(!body || body.recovery!==true || Object.keys(body).some(k=>!['recovery','ordinary_round_id','report_sha256','request_key'].includes(k)))
    return {status:400,data:{error:'recovery_request_invalid'}};
  const {recovery,...request}=body;
  const adapter={rpc:(name:string,params:any,signal:AbortSignal)=>{
    const method=methods.get(name);
    if(!method)throw new Error('recovery_rpc_not_allowed');
    return channel.rpc(method,params,signal);
  }};
  return sceneOrdinary(request,adapter,dependencies);
}
