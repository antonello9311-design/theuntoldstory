from pathlib import Path
import json,hashlib,difflib,ast
D=Path('/private/tmp/c1266-diagnostic14-20261017');O=D/'author';P=Path('/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master')
sha=lambda b:hashlib.sha256(b.encode() if isinstance(b,str) else b).hexdigest()
def ref(p):return {'path':str(p),'sha256':sha(p.read_bytes()),'bytes':p.stat().st_size}
def save(n,x):(O/n).write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n')
bundle=json.loads((P/'C1266_COUNT_SCHEMA11_EDGE_BUNDLE.json').read_text());raw=json.loads((D/'BASE_EDGE_RAW.json').read_text());edge=json.loads(raw['content'][0]['text']);assert edge['version']==73 and {x['name']:x['content'] for x in bundle}=={x['name']:x['content'] for x in edge['files']}
old=(P/'C1266_COUNT_SCHEMA10_RUNTIME.mjs').read_text();index=(P/'C1266_COUNT_SCHEMA11_INDEX.ts').read_text();assert sha(old)=='98c2559cf3c7d5deb217fcb2b1a389d85719c787f319600873ffba4e315df1fe';assert sha(index)=='cc91c743e69c25295f7921f3eaf39a1ba7d550321432543b9cc06fba360bd362'
assert next(x['content'] for x in bundle if x['name']=='mission-generic-runtime.mjs')==old
helper="""// Private diagnostics only: neither model output nor arbitrary Error properties are trusted.
// WeakMap identity binds the original error to the same validated work object.
const c1266ProgressBasisErrors=new WeakMap();
const C1266_PROGRESS_BASIS_CHECKS=Object.freeze(['NON_CONTEXT_BASIS','BASIS_QUOTE_SHAPE',
  'PLANNED_LITERAL_BINDING','SOURCE_LITERAL_BINDING','NONE_WITH_BASIS']);
function c1266ProgressBasisScope(work){
  return work?.kind==='director'&&work.payload?.schema_version==='mission-director-work/4'
    &&isCinematic(work)&&hasFeature(work,'director_progression');
}
function c1266ProgressBasisError(check,value,work){
  const error=Error('MISSION_DIRECTOR_PROGRESS_BASIS_INVALID');
  try{
    if(!c1266ProgressBasisScope(work)||!C1266_PROGRESS_BASIS_CHECKS.includes(check))return error;
    const g=value.progression;
    if(!['none','material_obstacle','material_branch','interaction','divergence','conflict'].includes(g.context_basis))return error;
    const quote=g.basis_quote,isString=typeof quote==='string';
    const basis=work.payload.context.sources.find(s=>s.id===g.basis_source_id);
    let literalContains=null,plannedMatchKind=null;
    if(check==='PLANNED_LITERAL_BINDING'){
      const d=work.payload.context.director_context;
      const planned=[['director_notes',d?.director_notes],...(d?.consequences??[]).flatMap(c=>[
        ['public_fact',c?.public_fact],['private_note',c?.private_note]])];
      const match=isString?planned.find(([,s])=>text(s)&&s.includes(quote)):undefined;
      literalContains=match!==undefined;plannedMatchKind=match?.[0]??'none';
    }else if(check==='SOURCE_LITERAL_BINDING'){
      literalContains=Boolean(isString&&basis&&['role','fato'].includes(basis.kind)
        &&typeof basis.body==='string'&&basis.body.includes(quote));
    }
    const diagnostic=Object.freeze({schema_version:'mission-director-progress-basis-diagnostic/1',check,
      action_kind_is_context:value.action_kind==='context',context_basis:g.context_basis,
      basis_quote_type:quote===null?'null':isString?'string':'other',
      basis_quote_utf16_length:isString?quote.length:null,
      basis_quote_utf8_bytes:isString?new TextEncoder().encode(quote).length:null,
      basis_source_id_is_null:g.basis_source_id===null,
      basis_source_id_is_director_context:g.basis_source_id==='director_context',
      source_exists:basis!==undefined,
      source_kind:basis===undefined?'absent':['role','fato'].includes(basis.kind)?basis.kind:'other',
      literal_contains:literalContains,planned_match_kind:plannedMatchKind});
    if(bytes(diagnostic)<=1024)c1266ProgressBasisErrors.set(error,{work,diagnostic});
  }catch{ /* Diagnostic failure must retain the original validator error. */ }
  return error;
}
function c1266ProgressBasisDiagnostic(error,work){
  try{
    const owned=c1266ProgressBasisErrors.get(error);
    if(owned?.work===work&&error.message==='MISSION_DIRECTOR_PROGRESS_BASIS_INVALID'
      &&c1266ProgressBasisScope(work))return owned.diagnostic;
  }catch{ /* Never replace the original failure with a diagnostic error. */ }
  return null;
}

"""
anchor='export function directorDecision(value,work) {';assert old.count(anchor)==1;new=old.replace(anchor,helper+anchor,1)
tags=['NON_CONTEXT_BASIS','BASIS_QUOTE_SHAPE','PLANNED_LITERAL_BINDING','SOURCE_LITERAL_BINDING','NONE_WITH_BASIS'];needle="throw Error('MISSION_DIRECTOR_PROGRESS_BASIS_INVALID')";assert old.count(needle)==5
for tag in tags:new=new.replace(needle,"throw c1266ProgressBasisError('"+tag+"',value,work)",1)
catch_anchor="      failure_codes:[failure==='MISSION_DISPATCH_TIMEOUT'?'provider_outcome_unknown':safeStaffCode]};\n";assert new.count(catch_anchor)==1
catch_add="    const progressBasisDiagnostic=c1266ProgressBasisDiagnostic(error,work);\n    if(progressBasisDiagnostic!==null)result.progress_basis_diagnostic=progressBasisDiagnostic;\n"
new=new.replace(catch_anchor,catch_anchor+catch_add,1)
overflow_anchor='  if(bytes(delivery)>65536){';assert new.count(overflow_anchor)==1
overflow_add="  // Omit optional diagnostics before the unchanged delivery cap/fallback path.\n  if(Object.hasOwn(delivery,'progress_basis_diagnostic')&&bytes(delivery)>65536)\n    delete delivery.progress_basis_diagnostic;\n"
new=new.replace(overflow_anchor,overflow_add+overflow_anchor,1)
reverse=new.replace(helper,'',1).replace(catch_add,'',1).replace(overflow_add,'',1)
for tag in tags:reverse=reverse.replace("throw c1266ProgressBasisError('"+tag+"',value,work)",needle,1)
assert reverse==old
oldbuild="export const BUILD = 'mission-generic-ai/2026-10-17.count-schema11.literal-catalog-observer';";newbuild="export const BUILD = 'mission-generic-ai/2026-10-17.progress-basis-diag14.private-five-checks';";assert index.count(oldbuild)==1;newindex=index.replace(oldbuild,newbuild,1);assert newindex.replace(newbuild,oldbuild,1)==index
runtimepath=O/'C1266_PROGRESS_DIAG14_RUNTIME.mjs';indexpath=O/'C1266_PROGRESS_DIAG14_INDEX.ts';runtimepath.write_text(new);indexpath.write_text(newindex)
newbundle=[];matrix=[]
for x in bundle:
 y=dict(x)
 if x['name']=='mission-generic-runtime.mjs':y['content']=new
 if x['name']=='mission-generic-index.ts':y['content']=newindex
 newbundle.append(y);matrix.append({'name':x['name'],'before_sha256':sha(x['content']),'after_sha256':sha(y['content']),'before_bytes':len(x['content'].encode()),'after_bytes':len(y['content'].encode()),'byteexact':x['content']==y['content']})
assert len(matrix)==14 and sum(x['byteexact'] for x in matrix)==12
save('C1266_PROGRESS_DIAG14_EDGE_BUNDLE.json',newbundle)
for name,a,b in [('RUNTIME',old,new),('INDEX',index,newindex)]:
 (O/(name+'.diff')).write_text(''.join(difflib.unified_diff(a.splitlines(True),b.splitlines(True),fromfile='Edge73/'+name,tofile='DIAG14/'+name)))
save('SOURCE_PROOF.json',{'classification':'STATIC_TEXT_TRANSFORMATION_ONLY_NO_RUNTIME_EXECUTION','baseline_edge':ref(D/'BASE_EDGE_RAW.json'),'baseline_bundle':ref(P/'C1266_COUNT_SCHEMA11_EDGE_BUNDLE.json'),'baseline_runtime':ref(P/'C1266_COUNT_SCHEMA10_RUNTIME.mjs'),'baseline_index':ref(P/'C1266_COUNT_SCHEMA11_INDEX.ts'),'runtime':ref(runtimepath),'index':ref(indexpath),'exact_reverse_restores_runtime73':True,'exact_reverse_BUILD_only_restores_index73':True,'five_tags_in_original_throw_order':tags,'modules':matrix,'DB_delta':0,'provider_schema_prompt_codec_catalogue_unchanged':True,'original_error_message_failure_codes_and_predicates_unchanged':True,'scope':'same Error/work identity; director/work4/cinematic/director_progression; private result field only','diagnostic_bytes_cap':1024,'delivery_cap':65536,'overflow':'Optional diagnostic omitted before original delivery overflow guard; base failure, fallback and hash flow preserved.','semantic_or_runtime_PASS':False})
assert ast.parse(Path(__file__).read_text())
print(json.dumps({'runtime':ref(runtimepath),'index':ref(indexpath),'bundle':ref(O/'C1266_PROGRESS_DIAG14_EDGE_BUNDLE.json')}))
