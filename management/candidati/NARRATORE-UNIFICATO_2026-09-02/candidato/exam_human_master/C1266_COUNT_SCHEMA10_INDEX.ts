import {createClient} from 'jsr:@supabase/supabase-js@2';
import {handleMissionGeneric} from './mission-generic-http.mjs';
import {createResponsesProvider} from './exam_regia17/edge/src/provider.mjs';

export const BUILD = 'mission-generic-ai/2026-10-17.count-schema10.literal-catalog';
const allowedOrigins = ['https://theuntoldstory.it', 'https://www.theuntoldstory.it'];

// Preserve only the qualified Native reserve stop before the shared HTTP adapter
// intentionally normalizes every other RPC error. No full error or token escapes.
function preserveRunBudgetStopClient(client: any) {
  return new Proxy(client, {get(target, property) {
    if (property === 'rpc') return (name: string, args: any) => {
      const original = target.rpc(name, args);
      if (name !== 'mission_generic_dispatch_authorize_v1') return original;
      let pending = original;
      const qualify = (out: any) => {
        if (out?.error?.code === '55000' && out.error.message === 'MGPG_C7_RUN_BUDGET_STOP') {
          const error = Object.assign(Error('MISSION_RPC_REJECTED'), {
            rpcName: name, sqlstate: '55000', serverCode: 'MGPG_C7_RUN_BUDGET_STOP'
          });
          throw error;
        }
        return out;
      };
      const invocation = {
        then(resolve: (value: any) => any, reject: (reason: unknown) => any) { return Promise.resolve(pending).then(qualify).then(resolve, reject); },
        abortSignal(signal: AbortSignal) {
          if (typeof pending.abortSignal === 'function') pending = pending.abortSignal(signal);
          return invocation;
        }
      };
      return invocation;
    };
    const value = Reflect.get(target, property, target);
    return typeof value === 'function' ? value.bind(target) : value;
  }});
}

// Optional count transport stays in this Generic entrypoint and uses the same
// deployment credential closure. Its monetary qualification is Native, never free.
// DIAG3: schema grammar tokens only; enum values and dynamic actor keys are never logged.
const COUNT_SCHEMA_REASON3=Object.freeze(['ANYOF_FIRST_KEYS','ENUM_LIMIT','EMPTY_ENUM','REQUIRED_SET',
  'ADDITIONAL_PROPERTIES','NESTING_LIMIT','UNSUPPORTED_KEYWORD','TYPE_MISSING','REF_INVALID',
  'ENUM_STRING_LIMIT','SCHEMA_STRING_LIMIT','PROPERTY_LIMIT','SCHEMA_REJECTION_UNCLASSIFIED']);
const COUNT_SCHEMA_KEYS3=Object.freeze(['properties','items','anyOf','$defs','schema_version','source_window_id',
  'source_role_ids','source_evidence','role_interpretation','master_session_id','source_revision','roster_sha256',
  'interpretations','user_id','role_id','role_sha256','intents','intent','destination','kind','step_key','public_proof',
  'source_id','source_kind','source_sha256','quote','temporal','timing','anchor_intent_index','prerequisite',
  'condition_quote','relation_evidence','joint_witness','current_intent_index','evidence','opportunity_id','action_kind','entry_side','world_reaction_intent',
  'npc_intents','actor_key','speech_intent','entry_kind','profile_audit','progression','current_intent',
  'movement_role_ids','guidance_fato_id','guidance_quote','context_basis','basis_source_id','basis_quote']);
function countSchemaDiagnosticContext3(path,schema){
  if(!Array.isArray(path)||path.length>24||!schema||typeof schema!=='object'||Array.isArray(schema))return null;
  let cursor=schema;
  for(const token of path){
    if(typeof token==='number'){
      if(!Number.isSafeInteger(token)||token<0||token>9999||!Array.isArray(cursor)||token>=cursor.length)return null;
    }else{
      if(typeof token!=='string'||!(COUNT_SCHEMA_KEYS3.includes(token)||/^c1266Literal[0-9]{1,3}$/.test(token))
        ||!cursor||typeof cursor!=='object'||Array.isArray(cursor)||!Object.hasOwn(cursor,token))return null;
    }
    cursor=cursor[token];
  }
  // Context must be a schema node, never an enum/required value or a prose leaf.
  if(!cursor||typeof cursor!=='object'||Array.isArray(cursor)
    ||!['type','anyOf','$ref','properties','enum'].some(k=>Object.hasOwn(cursor,k)))return null;
  return path.slice();
}
function countSchemaDiagnosticMessage3(error,payload,status){
  const out={schemaReason:null,schemaContext:null};
  if(status!==400||error?.code!=='invalid_json_schema'||error?.param!=='text.format.schema'
    ||typeof error.message!=='string'||error.message.length>4096)return out;
  const name=payload?.text?.format?.name,schema=payload?.text?.format?.schema;
  if(typeof name!=='string'||!/^[A-Za-z0-9_-]{1,64}$/.test(name))return out;
  // The error must be the provider's framed schema rejection for THIS named schema.
  const prefixes=[`Invalid schema for response_format '${name}': `,`Invalid schema for text.format '${name}': `];
  const prefix=prefixes.find(x=>error.message.startsWith(x));if(!prefix)return out;
  let reason=error.message.slice(prefix.length),context=null;
  if(reason.startsWith('In context=')){
    const match=/^In context=\(([^\r\n]{0,1024})\),\s*/.exec(reason);if(!match)return out;
    reason=reason.slice(match[0].length);
    const tokens=[];let rest=match[1].trim(),valid=true;
    while(rest){
      const part=/^(?:'([A-Za-z0-9_$-]{1,64})'|([0-9]{1,4}))\s*(,\s*|$)/.exec(rest);
      if(!part||tokens.length>=24){valid=false;break;}
      const token=part[1]!==undefined?part[1]:Number(part[2]);
      // Quoted numeric indexes are normalized only when they resolve an actual array.
      tokens.push(typeof token==='string'&&/^(0|[1-9][0-9]{0,3})$/.test(token)?Number(token):token);
      rest=rest.slice(part[0].length);
    }
    if(valid)context=countSchemaDiagnosticContext3(tokens,schema);
  }
  // Fixed anchored reason prefixes only. Never classify words inside a quoted value.
  const rules=[
    ['ANYOF_FIRST_KEYS',/^Objects provided via ['"]anyOf['"] must not share identical first keys(?:[.!]|$)/],
    ['ENUM_LIMIT',/^(?:Exceeded maximum enum count of 1000|The schema must not have more than 1000 enum values|Too many enum values|This schema has [0-9]{1,9} enum values, which exceeds the limit of 1000|The total number of enum values across all enum properties must not exceed 1000)(?:[.!:]|$)/],
    ['ENUM_STRING_LIMIT',/^(?:Exceeded maximum enum string length of [0-9]{1,9}|Total string length of enum values exceeds [0-9]{1,9})(?:[.!:]|$)/],
    ['SCHEMA_STRING_LIMIT',/^(?:Exceeded maximum total schema string length of [0-9]{1,9}|Total schema string length exceeds [0-9]{1,9})(?:[.!:]|$)/],
    ['PROPERTY_LIMIT',/^(?:Exceeded maximum property count of [0-9]{1,9}|Too many object properties|This schema has [0-9]{1,9} properties, which exceeds the limit of [0-9]{1,9})(?:[.!:]|$)/],
    ['EMPTY_ENUM',/^['"]enum['"] must be a non-empty array(?:[.!]|$)/],
    ['REQUIRED_SET',/^['"]required['"] is required to be supplied and to be an array including every key in properties(?:[.!]|$)/],
    ['ADDITIONAL_PROPERTIES',/^['"]additionalProperties['"] is required to be supplied and to be false(?:[.!]|$)/],
    ['NESTING_LIMIT',/^(?:Exceeded maximum nesting depth of 10|Schema exceeds maximum nesting depth(?: of 10)?)(?:[.!:]|$)/],
    ['UNSUPPORTED_KEYWORD',/^['"](?:allOf|oneOf|not|if|then|else|dependentRequired|dependentSchemas|minLength|maxLength|pattern|format|minimum|maximum|multipleOf|minItems|maxItems)['"] is not permitted(?:[.!]|$)/],
    ['TYPE_MISSING',/^(?:['"]type['"] is required|schema must have a ['"]type['"] key)(?:[.!]|$)/],
    ['REF_INVALID',/^(?:Invalid ['"]\$ref['"] reference|Unresolved ['"]\$ref['"] reference)(?:[.!:]|$)/]
  ];
  const classified=rules.find(([,pattern])=>pattern.test(reason));
  out.schemaReason=classified?classified[0]:'SCHEMA_REJECTION_UNCLASSIFIED';
  out.schemaContext=context;return out;
}

// PROPOSAL ONLY: bounded structural codes, never a provider message or payload fragment.
const COUNT_SCHEMA_WORDS4=Object.freeze({schema:'SCHEMA',schemas:'SCHEMA',object:'OBJECT',objects:'OBJECT',
  array:'ARRAY',arrays:'ARRAY',string:'STRING',strings:'STRING',enum:'ENUM',enums:'ENUM',
  value:'VALUE',values:'VALUE',required:'REQUIRED',property:'PROPERTY',properties:'PROPERTY',
  anyof:'ANYOF',allof:'ALLOF',oneof:'ONEOF','$ref':'REF','$defs':'DEFS',reference:'REF',references:'REF',
  type:'TYPE',types:'TYPE',must:'MUST',not:'NOT',first:'FIRST',same:'SAME',identical:'IDENTICAL',
  maximum:'MAXIMUM',minimum:'MINIMUM',total:'TOTAL',length:'LENGTH',exceeds:'EXCEEDS',exceeded:'EXCEEDS',
  limit:'LIMIT',limits:'LIMIT',nesting:'NESTING',depth:'DEPTH',count:'COUNT',empty:'EMPTY',
  unique:'UNIQUE',duplicate:'DUPLICATE',duplicates:'DUPLICATE',missing:'MISSING',invalid:'INVALID',
  unsupported:'UNSUPPORTED',permitted:'PERMITTED',additionalproperties:'ADDITIONAL_PROPERTIES',
  key:'KEY',keys:'KEY',share:'SHARE',including:'INCLUDING',contain:'CONTAIN',contains:'CONTAIN',
  containing:'CONTAIN',every:'EVERY',each:'EACH',false:'FALSE',true:'TRUE',null:'NULL'});
function countSchemaSignature4(reason){
  if(typeof reason!=='string'||reason.length>4096)return null;
  const tokens=[];let truncated=false,at=0;
  const emit=code=>{
    if(tokens.length>=64||JSON.stringify({tokens:[...tokens,code],truncated:false}).length>512){truncated=true;return false;}
    tokens.push(code);return true;
  };
  const skipQuote=()=>{
    const quote=reason[at++];
    while(at<reason.length){const c=reason[at++];if(c==='\\'){if(at<reason.length)at++;}else if(c===quote)return true;}
    return false;
  };
  while(at<reason.length){
    const c=reason[at];
    if(/\s|[,.;:!?]/.test(c)){at++;continue;}
    if(c==="'"||c==='"'||c==='`'){
      const closed=skipQuote();if(!emit('QUOTED'))break;if(!closed){truncated=true;break;}continue;
    }
    if(c==='{'||c==='['||c==='('){
      const stack=[];let closed=false;
      while(at<reason.length){const item=reason[at];
        if(item==="'"||item==='"'||item==='`'){if(!skipQuote())break;continue;}
        at++;
        if(item==='{'||item==='['||item==='('){stack.push(item);if(stack.length>16){at=reason.length;break;}}
        else if(item==='}'||item===']'||item===')'){
          const expected=({'{':'}','[':']','(':')'})[stack.at(-1)];
          if(item===expected){stack.pop();if(!stack.length){closed=true;break;}}
        }
      }
      if(!emit('FRAGMENT'))break;if(!closed){truncated=true;break;}continue;
    }
    const url=/^https?:\/\/[^\s]*/i.exec(reason.slice(at));
    if(url){at+=url[0].length;if(!emit('REDACTED'))break;continue;}
    const atom=/^[^\s,.;:!?(){}\[\]'"`]+/.exec(reason.slice(at));
    if(!atom){at++;if(!emit('REDACTED'))break;continue;}
    at+=atom[0].length;
    const word=atom[0].toLowerCase();
    const code=Object.hasOwn(COUNT_SCHEMA_WORDS4,word)?COUNT_SCHEMA_WORDS4[word]:/^[0-9]+$/.test(word)?'NUMBER':'REDACTED';
    if(!emit(code))break;
  }
  return {tokens,truncated};
}

// PROPOSAL ONLY: one private observation alongside the existing failure. No request/retry/receipt changes.
function countSchemaObservationReason4(error,payload,diagnostic){
  const result={state:'FRAME_UNKNOWN',signature:null,context:diagnostic.schemaContext};
  if(typeof error?.message!=='string'||error.message.length>4096)return result;
  const prefixes=["Invalid schema for response_format 'mission_unified_director': ","Invalid schema for text.format 'mission_unified_director': "];
  const prefix=prefixes.find(x=>error.message.startsWith(x));if(!prefix)return result;
  let reason=error.message.slice(prefix.length);
  if(reason.startsWith('In context=')){
    const match=/^In context=\(([^\r\n]{0,1024})\),\s*/.exec(reason);
    if(!match){result.state='CONTEXT_REDACTED';return result;}
    reason=reason.slice(match[0].length);
    if(result.context===null){
      // A $ref terminal is a structural field only: validate its parent and internal target, emit no ref value.
      const path=[];let rest=match[1].trim(),valid=true;
      while(rest){const part=/^(?:'([A-Za-z0-9_$-]{1,64})'|([0-9]{1,4}))\s*(,\s*|$)/.exec(rest);
        if(!part||path.length>=24){valid=false;break;}
        const token=part[1]!==undefined?part[1]:Number(part[2]);
        path.push(typeof token==='string'&&/^(0|[1-9][0-9]{0,3})$/.test(token)?Number(token):token);rest=rest.slice(part[0].length);
      }
      const schema=payload.text.format.schema;
      if(valid&&path.at(-1)==='$ref'&&countSchemaDiagnosticContext3(path.slice(0,-1),schema)!==null){
        let node=schema;for(const key of path.slice(0,-1))node=node[key];
        const ref=typeof node?.$ref==='string'?/^#\/\$defs\/(c1266Literal[0-9]{1,3})$/.exec(node.$ref):null;
        const target=ref&&schema.$defs&&Object.hasOwn(schema.$defs,ref[1])?schema.$defs[ref[1]]:null;
        if(target&&typeof target==='object'&&!Array.isArray(target)&&['type','anyOf','$ref','properties','enum'].some(k=>Object.hasOwn(target,k)))result.context=path;
      }
    }
  }
  result.state=diagnostic.schemaReason==='SCHEMA_REJECTION_UNCLASSIFIED'?'UNCLASSIFIED':'CLASSIFIED';
  if(result.state==='UNCLASSIFIED')result.signature=countSchemaSignature4(reason);
  return result;
}
// Structural log filter only. Runtime attestation/authority remains unchanged and is not inferred here.
function countSchemaC1266Wire4(schema){
  const record=value=>value!==null&&typeof value==='object'&&!Array.isArray(value);
  const single=node=>record(node)&&node.type==='string'&&Array.isArray(node.enum)&&node.enum.length===1&&typeof node.enum[0]==='string'?node.enum[0]:null;
  const uuid=value=>typeof value==='string'&&/^[a-fA-F0-9]{8}(?:-[a-fA-F0-9]{4}){3}-[a-fA-F0-9]{12}$/.test(value);
  const sha=value=>typeof value==='string'&&/^[a-f0-9]{64}$/.test(value);
  if(!record(schema)||schema.type!=='object'||schema.additionalProperties!==false||!record(schema.properties)
    ||!Array.isArray(schema.required)||!schema.required.includes('role_interpretation')
    ||!['mission-director-proposal/4','mission-director-joint-witness/1'].includes(single(schema.properties.schema_version)))return false;
  const role=schema.properties.role_interpretation;
  const fields=['schema_version','master_session_id','source_window_id','source_revision','roster_sha256','interpretations'];
  if(!record(role)||role.type!=='object'||role.additionalProperties!==false||!record(role.properties)
    ||Object.keys(role.properties).length!==fields.length||!fields.every(k=>Object.hasOwn(role.properties,k))
    ||!Array.isArray(role.required)||role.required.length!==fields.length||!fields.every(k=>role.required.includes(k))
    ||single(role.properties.schema_version)!==(single(schema.properties.schema_version)==='mission-director-joint-witness/1'?'mission-role-joint-witness/1':'mission-role-interpretation/2')
    ||!uuid(single(role.properties.master_session_id))||!uuid(single(role.properties.source_window_id))
    ||single(role.properties.source_window_id)!==single(schema.properties.source_window_id)
    ||!sha(single(role.properties.source_revision))||!sha(single(role.properties.roster_sha256)))return false;
  const rows=role.properties.interpretations;
  if(!record(rows)||rows.type!=='array'||!Number.isInteger(rows.minItems)||rows.minItems<1
    ||rows.maxItems!==rows.minItems||!Array.isArray(rows.items?.anyOf)||rows.items.anyOf.length!==rows.minItems)return false;
  if(!record(schema.$defs))return false;
  const names=Object.keys(schema.$defs);
  return names.length>0&&names.length<=1000&&names.every(name=>{
    if(!/^c1266Literal[0-9]{1,3}$/.test(name))return false;
    const def=schema.$defs[name];
    return record(def)&&def.type==='string'&&def.minLength===1&&def.maxLength===300
      &&Array.isArray(def.enum)&&def.enum.length>0&&def.enum.length<=200;
  });
}
function observeCountSchemaFailure4(error,payload,status,headers,diagnostic){
  try{
    // Observe only the failed C1266-shaped Director wire; this filter grants no execution authority.
    if(status!==400||error?.code!=='invalid_json_schema'||error?.param!=='text.format.schema'
      ||payload?.text?.format?.name!=='mission_unified_director')return;
    const schema=payload.text.format.schema;
    if(!countSchemaC1266Wire4(schema))return;
    const observed=countSchemaObservationReason4(error,payload,diagnostic);
    const requestId=headers.get('x-request-id');
    const providerRequestId=typeof requestId==='string'&&/^req_[A-Za-z0-9_-]{8,96}$/.test(requestId)?requestId:null;
    console.warn('mission_count_schema_observation',{schema_version:'mission-count-schema-observation/1',
      format_name:'mission_unified_director',provider_request_id:providerRequestId,
      http_status:400,error_code:'invalid_json_schema',error_param:'text.format.schema',
      schema_reason:diagnostic.schemaReason,schema_context:observed.context,parse_state:observed.state,signature:observed.signature});
  }catch{/* Observation is best effort: no message, raw error, retry or outcome change. */}
}

function createCountedProvider(apiKey: string) {
  const native=createResponsesProvider({apiKey});
  return {
    create(request: any) {
      if(request.request_snapshot===undefined)return native.create(request);
      const payload=JSON.parse(request.request_snapshot);
      if(JSON.stringify(payload)!==request.request_snapshot||JSON.stringify(request.payload)!==request.request_snapshot)
        throw Error('MISSION_PROVIDER_INPUT_SNAPSHOT_INVALID');
      return native.create({payload,signal:request.signal});
    },
    async count({payload,signal}: any) {
      const fail=(name: string,httpStatus: number|null=null)=>Object.assign(
        Error('MISSION_PROVIDER_INPUT_COUNT_FAILED'),{countDiagnostic:name,httpStatus});
      let response;
      try{
        response=await fetch('https://api.openai.com/v1/responses/input_tokens',{
          method:'POST',headers:{authorization:`Bearer ${apiKey}`,'content-type':'application/json'},
          body:JSON.stringify(payload),signal});
      }catch{throw fail('TRANSPORT');}
      if(!response.ok){
        const safe={errorCode:null,errorType:null,errorParam:null,schemaReason:null,schemaContext:null};
        // Private bounded parsing, no message/raw body is returned or logged.
        try{
          const reader=response.body?.getReader();let total=0;const chunks=[];
          if(reader){
            try{while(true){const part=await reader.read();if(part.done)break;
              total+=part.value.byteLength;if(total>4096){await reader.cancel();break;}chunks.push(part.value);}}
            finally{reader.releaseLock();}
          }
          if(reader&&total<=4096){
            const bytes=new Uint8Array(total);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.byteLength;}
            const error=JSON.parse(new TextDecoder().decode(bytes))?.error;
            if(['invalid_json_schema','context_length_exceeded','unsupported_value','model_not_found','rate_limit_exceeded','insufficient_quota'].includes(error?.code))safe.errorCode=error.code;
            if(['invalid_request_error','rate_limit_error','server_error'].includes(error?.type))safe.errorType=error.type;
            if(['model','input','reasoning.effort','text.format.schema'].includes(error?.param))safe.errorParam=error.param;
            Object.assign(safe,countSchemaDiagnosticMessage3(error,payload,response.status));
            observeCountSchemaFailure4(error,payload,response.status,response.headers,safe);
          }
        }catch{/* Unrecognized/oversized/malformed body has null diagnostics; Count remains unknown. */}
        throw Object.assign(Number.isInteger(response.status)&&response.status>=400&&response.status<=599
          ?fail('HTTP',response.status):fail('UNKNOWN'),safe);
      }
      let raw;
      try{raw=await response.text();}catch{throw fail('TRANSPORT');}
      if(new TextEncoder().encode(raw).length>4096)throw fail('FORMAT');
      try{return JSON.parse(raw);}catch{throw fail('JSON');}
    }
  };
}

// Only the deployed runtime resolves these credentials. Nothing is returned or logged.
// Auth.getUser and the service-only RPC adapter live in the shared HTTP handler.
Deno.serve(async req => {
  try {
    const url = Deno.env.get('SUPABASE_URL') ?? '';
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const apiKey = Deno.env.get('OPENAI_API_KEY') ?? '';
    const workerToken = Deno.env.get('MISSION_NARRATIVE_WORKER_TOKEN') ?? '';
    const admin = url && serviceKey
      ? preserveRunBudgetStopClient(createClient(url, serviceKey, {auth: {persistSession: false, autoRefreshToken: false, detectSessionInUrl: false}}))
      : null;
    const provider = apiKey ? createCountedProvider(apiKey) : null;
    const response = await handleMissionGeneric(req, {admin, provider, workerToken, allowedOrigins, waitUntil: (task: Promise<unknown>) => EdgeRuntime.waitUntil(task)});
    response.headers.set('x-mission-build', BUILD);
    return response;
  } catch {
    // Keep provider, Auth and configuration details out of public errors.
    const headers = new Headers({'content-type': 'application/json', 'cache-control': 'no-store',
      'vary': 'Origin', 'x-mission-build': BUILD});
    const origin = req.headers.get('origin');
    if (origin && allowedOrigins.includes(origin)) headers.set('access-control-allow-origin', origin);
    return new Response(JSON.stringify({code: 'MISSION_SERVICE_UNAVAILABLE', retry: false}), {status: 503, headers});
  }
});
