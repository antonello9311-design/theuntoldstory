import {generateOpening,PROMPT_VERSION as OPENING_VERSION} from './exam-opening.mjs';
import {generateCycle} from './exam-cycle.mjs';

export const SESSION_VERSION='MISSION-EXAM-SESSION-001';
const uuid=x=>typeof x==='string'&&/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/iu.test(x);

// Genera e deposita soltanto. Pubblicazione e avanzamento passano dalla RPC
// autenticata, che rilegge stato, ricevuta e risultato nella stessa transazione.
export async function runSession({draftId,userId,db,provider}) {
  const no=(status,code)=>({status,code,chiamate:0,pubblicato:false,retry:false});
  if(!userId)return no(401,'USER_JWT_REQUIRED');
  if(!uuid(draftId))return no(400,'DRAFT_ID_REQUIRED');
  const draft=await db.row('esame_supervisione_bozze','prova,tipo,autore,stato',draftId);
  if(!draft||draft.autore!==userId||!['apertura','ciclo'].includes(draft.tipo)||draft.stato!=='autorizzata')
    return no(409,'SESSION_DRAFT_UNAVAILABLE');
  const exam=await db.row('esame_prove','class_session_id,candidate_user,candidate_character,stato',draft.prova);
  if(!exam||exam.stato!=='aperta'||exam.candidate_user!==userId)return no(403,'OWN_TEST_EXAM_REQUIRED');
  // Il principal deriva dal JWT verificato dall'adattatore HTTP. L'RPC interna
  // controlla policy protetta, identità, arena e stato sul server, anche quando
  // la stanza è reale; nessuna whitelist di nomi o fiducia in flag del client.
  let allowed;
  try{allowed=await db.rpc('_esame_session_scope',{p_prova:draft.prova,p_user:userId});}
  catch{return no(503,'SESSION_SCOPE_UNAVAILABLE');}
  if(allowed!==true)return no(403,'PROTECTED_SESSION_REQUIRED');
  const drafts=await db.drafts(draft.prova);
  if(!Array.isArray(drafts))return no(503,'SESSION_SOURCES_UNAVAILABLE');
  const opening=drafts.find(b=>b.tipo==='apertura'&&b.stato==='pubblicata');
  if(draft.tipo==='ciclo'&&(opening?.risultato?.validator_version!==SESSION_VERSION
    ||opening.risultato.publishable!==true||opening.risultato.ok!==true))
    return no(409,'SESSION_OPENING_REQUIRED');
  let claim;
  // Il claim applica atomicamente il budget della prova e la ricevuta monouso.
  try{claim=await db.rpc('_esame_session_claim',{p_bozza:draftId,p_user:userId});}
  catch{return no(409,'CLAIM_UNAVAILABLE');}
  let result;
  if(claim?.bozza!==draftId||claim?.prova!==draft.prova||claim?.tipo!==draft.tipo
    ||!uuid(claim?.ricevuta)||(draft.tipo==='ciclo'&&claim.payload?.ricevuta_id!==claim.ricevuta))
    result={ok:false,chiamate:0,motivi:['CLAIM_MISMATCH']};
  else if(draft.tipo==='apertura')
    result={...await generateOpening(claim.payload,provider),prompt_id:OPENING_VERSION};
  else
    result=await generateCycle(claim.payload,{payload:opening.payload,testo:opening.risultato.testo},provider);
  result={...result,validator_version:SESSION_VERSION,prompt_version:1,
    publishable:result.ok===true,quality_review:'playtest',retry:false};
  try {
    const stored=await db.rpc('_esame_supervisione_deposita',{p_bozza:draftId,p_risultato:result});
    return {status:200,...stored,pubblicato:false,chiamate:result.chiamate,retry:false};
  } catch{return {status:500,code:'DEPOSIT_FAILED_NO_RETRY',chiamate:result.chiamate,pubblicato:false,retry:false};}
}
