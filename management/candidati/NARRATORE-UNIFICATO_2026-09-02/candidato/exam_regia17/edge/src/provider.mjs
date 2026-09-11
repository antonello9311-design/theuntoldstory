export function createResponsesProvider({apiKey,fetchFn=fetch}) {
 return {async create({payload,signal}) {
  const r=await fetchFn('https://api.openai.com/v1/responses',{method:'POST',headers:{authorization:`Bearer ${apiKey}`,'content-type':'application/json'},body:JSON.stringify(payload),signal});
  if(!r.ok)throw Error('PROVIDER_HTTP');
  const x=await r.json(),raw=x.output?.flatMap(o=>o.content??[]).find(c=>c.type==='output_text')?.text,u=x.usage;
  const metrics=u?{input_tokens:Number(u.input_tokens??0),output_tokens:Number(u.output_tokens??0),reasoning_tokens:Number(u.output_tokens_details?.reasoning_tokens??0),total_tokens:Number(u.total_tokens??Number(u.input_tokens??0)+Number(u.output_tokens??0))}:null;
  let realization;
  try {if(typeof raw!=='string'||!u)throw Error('schema');realization=JSON.parse(raw);}
  catch {
   // Il consumer missioni continua a ricevere un errore; il campione può
   // conservarne risposta/consumi disponibili senza generare un ripiego.
   const e=Error('PROVIDER_SCHEMA');
   e.provider_result={status:x.status??null,raw_output:typeof raw==='string'?raw:null,provider_output:x.output??null,metrics};
   throw e;
  }
  return {realization,status:x.status,raw_output:raw,metrics};
 }};
}
