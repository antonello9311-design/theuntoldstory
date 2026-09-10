import fs from 'node:fs';
import path from 'node:path';
import {Script,createContext} from 'node:vm';
import {createHash,randomUUID} from 'node:crypto';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
const root=process.argv[2],pkg=process.argv[3],out=process.argv[4];
if(!root||!pkg||!out)throw Error('Usage: runner ROOT PACKAGE OUTPUT_NEW');
if(fs.existsSync(out))throw Error('output_exists_no_retry');
const sha=b=>createHash('sha256').update(b).digest('hex'),read=n=>fs.readFileSync(path.join(pkg,n),'utf8');
const manifest=JSON.parse(read('MANIFEST.json')),baseline=JSON.parse(read('BASELINE.json')),html=read('LAND.html');
const expectedManifest='84ae057cac775185b61fd7d85c779c802b907584f291896ec4f6befb325b41df';
const pins={};let setupError=null,qa,inlineScripts=0;
try{
 assert.equal(sha(read('MANIFEST.json')),expectedManifest);
 for(const[n,p]of Object.entries(manifest.files)){const b=fs.readFileSync(path.join(pkg,n));assert.equal(sha(b),p.sha256,'candidate_pin:'+n);pins[n]=sha(b);}
 for(const[n,p]of Object.entries(manifest.source_inputs)){const b=fs.readFileSync(path.join(root,n));assert.equal(sha(b),p.sha256,'source_pin:'+n);pins[n]=sha(b);}
 for(const n of ['impervious-map.test.mjs','single-blank.test.mjs']){const f=path.join(root,baseline.source_dir,n);pins[n]=sha(fs.readFileSync(f));}
 for(const m of html.matchAll(/<script\b([^>]*)>([\s\S]*?)<\/script>/gi)){if(/\bsrc\s*=|application\/ld\+json|application\/json/i.test(m[1]))continue;new Script(m[2]);inlineScripts++;}
 const match=html.match(/<script id="common-panel-bundle">([\s\S]*?)<\/script>/);assert.ok(match);
 const anchor='window.TUSCommonPanel=module0;';assert.equal(match[1].split(anchor).length,2);
 const context=createContext({window:{},structuredClone,crypto:{randomUUID},queueMicrotask});
 new Script(match[1].replace(anchor,anchor+'window.projectionQA={validateMultiplication:module4.validateMultiplication,renderPanelMap:module6.renderPanelMap,createPanelController:module2.createPanelController,changeSingleChoice:module5.changeSingleChoice};')).runInContext(context);
 qa=context.window.projectionQA;assert.equal(typeof qa.renderPanelMap,'function');
}catch(e){setupError=String(e.message||e);}
const id=n=>'00000000-0000-4000-8000-'+String(n).padStart(12,'0');
const clone=x=>structuredClone(x),plain=x=>JSON.parse(JSON.stringify(x));
// DOM minimo derivato dal banco impervious-map; nessuna superficie reale.
class Element{
 constructor(tag,doc){this.tagName=tag;this.ownerDocument=doc;this.children=[];this.attributes={};this.ownText='';this.classList={add:()=>{}};}
 append(el){this.children.push(el);}
 replaceChildren(){this.children=[];this.ownText='';}
 setAttribute(k,v){this.attributes[k]=String(v);}
 set textContent(v){this.children=[];this.ownText=String(v);}
 get textContent(){return this.ownText+this.children.map(x=>x.textContent).join('');}
}
const document={createElement:t=>new Element(t,document),createElementNS:(_,t)=>new Element(t,document)};
const walk=n=>[n,...n.children.flatMap(walk)];
const markers=n=>walk(n).filter(x=>Object.hasOwn(x.attributes,'data-figure-index'));
const rootNode=()=>new Element('div',document);
function fixture(points=[[7,7],[7,7]],original=null){
 const actor=(n,name,mine)=>({actor_id:id(n),kind:'pg',body_only:false,display_name:name,team:null,state:'active',mine,action_due:mine,defense_due:false,resources:null,distance_from_viewer_m:null});
 const opts=points.map((_,i)=>({option_id:id(100+i),label:'Figura '+(i+1),distance_m:null,direction:null}));
 return {schema_version:'combat-panel/1',status:'ready',reason_code:null,
 context:{activity_id:id(20),activity_kind:'ordinary_v2',location_id:id(21),round_id:null,round_no:null,phase:'action',phase_label:'Azione',version:1,scene_version:null,policy_id:'test',simulated:true},
 viewer:{command_actor_id:id(1),controlled_actors:[{actor_id:id(1),label:'Osservatore sintetico'}],is_master:false,is_admin:false,can_command:true},
 actors:[actor(1,'Osservatore sintetico',true),actor(2,'Figure sintetiche',false)],
 map:{schema_version:'combat-map/2',map_version:1,readonly:true,label:'Arena sintetica',bounds:{width_m:20,height_m:20},
 pov:{actor_id:id(1),x_m:5,y_m:5,radius_m:0.5},actors:[{actor_id:id(1),x_m:5,y_m:5,radius_m:0.5,body_only:false}],
 objects:[{object_id:id(30),label:'Terreno sintetico',shape_kind:'aabb',shape:{min_x:2,min_y:2,max_x:8,max_y:8},x_m:5,y_m:5,radius_m:null,state:'available',distance_from_viewer_m:0,substitution_anchor_available:false,is_impervious:true}]},
 offers:[{offer_id:id(40),kind:'action',operation:'declare',actor_id:id(1),label:'Scelta nativa sintetica',context_version:1,scene_version:null,requires_role:false,
 choices:[{group_id:id(41),label:'Figura',selection_mode:'single',purpose:'generic',min_selected:1,max_selected:1,depends_on:null,options:opts}],input_fields:[]}],
 multiplication:{schema_version:'combat-multiplication-view/1',formations:[{formation_id:id(60),actor_id:id(2),mode:'copertura',state_version:1,figures:points.map(([x_m,y_m],i)=>({figure_index:i+1,x_m,y_m})),original_index:original}]},
 movement_explanations:null,companion:null,sabaku_transport:null,narrative:null,receipt:null,round_details:null};
}
function render(e,node=rootNode()){qa.renderPanelMap(node,e);return node;}
function assertMarkers(e,node){
 const ps=e.multiplication.formations.flatMap(f=>f.figures),ms=markers(node);
 assert.equal(ms.length,ps.length);
 ps.forEach((p,i)=>{assert.equal(ms[i].attributes['data-figure-index'],String(p.figure_index));assert.equal(ms[i].attributes.cx,String(p.x_m));assert.equal(ms[i].attributes.cy,String(p.y_m));});
 assert.equal(walk(node).filter(n=>n.tagName==='li'&&n.textContent.includes(' · figura ')).length,ps.length);
}
const groups=[
 ['G1',async()=>{
  for(const points of [[[7,7],[7,7]],[[7,7],[7,7],[7,7]]]){
   const e=fixture(points),before=clone(e),forms=qa.validateMultiplication(e);assert.equal(forms.length,1);assert.equal(forms[0].figures.length,points.length);
   const n=render(e);assertMarkers(e,n);assert.equal(walk(n).filter(x=>x.tagName==='text'&&x.textContent.includes('stessa posizione')).length,1);
   assert.deepEqual(e,before);assert.equal(e.offers[0].choices[0].options.length,points.length);
   assert.deepEqual(e.offers[0].choices[0].options.map(x=>x.option_id),before.offers[0].choices[0].options.map(x=>x.option_id));
  }
  return '2 e3indici coincidenti conservati;DTO eIDimmutati';
 }],
 ['G2',async()=>{
  for(const points of [[[2,2],[4,5]],[[2,2],[8,2]]]){
   const e=fixture(points),before=clone(e);qa.validateMultiplication(e);const n=render(e);assertMarkers(e,n);assert.deepEqual(e,before);
  }
  return 'L1=5 e secondo vettore L1=6/euclidea2=36 rappresentati senza clamp; secondo vettore NONqualificato come mossa lecita';
 }],
 ['G3',async()=>{
  const mutations=[
   ['missing',e=>delete e.multiplication],
   ['extra',e=>e.multiplication.extra=true],
   ['uuid',e=>e.multiplication.formations[0].formation_id='invalid'],
   ['mode',e=>e.multiplication.formations[0].mode='invalid'],
   ['version',e=>e.multiplication.formations[0].state_version=0],
   ['duplicate_index',e=>e.multiplication.formations[0].figures[1].figure_index=1],
   ['index_domain',e=>e.multiplication.formations[0].figures[1].figure_index=3],
   ['nonfinite',e=>e.multiplication.formations[0].figures[1].x_m=Infinity],
   ['bounds',e=>e.multiplication.formations[0].figures[1].y_m=21]
  ];const details=[];
  for(const[name,mutate]of mutations){try{const old=render(fixture());assert.ok(walk(old).some(n=>n.tagName==='svg'));const e=fixture();mutate(e);assert.throws(()=>qa.validateMultiplication(e));render(e,old);assert.equal(walk(old).some(n=>n.tagName==='svg'),false);assert.match(old.textContent,/Mappa non disponibile/);details.push({name,status:'PASS'});}catch(err){details.push({name,status:'FAIL',reason:String(err.message||err)});}}
  if(details.some(d=>d.status==='FAIL'))throw Object.assign(Error('structural_variants_failed'),{details});
  return details;
 }],
 ['G4',async()=>{
  const e=fixture([[7,7],[7,7],[7,7]]),n=render(e),ms=markers(n);assert.equal(new Set(ms.map(m=>m.attributes.fill)).size,1);assert.doesNotMatch(n.textContent,/originale/);assert.equal(walk(n).filter(x=>x.tagName==='circle'&&!Object.hasOwn(x.attributes,'data-figure-index')).length,1);
  assert.doesNotMatch(n.textContent,/[0-9a-f]{8}-[0-9a-f-]{27,}/i);
  for(const mutate of [x=>x.map.actors.push({actor_id:id(2),x_m:7,y_m:7,radius_m:0.5,body_only:false}),x=>x.actors[1].distance_from_viewer_m=0,x=>x.map.pov.actor_id=id(2)]){
   const leak=fixture();mutate(leak);assert.throws(()=>qa.validateMultiplication(leak));assert.match(render(leak).textContent,/Mappa non disponibile/);
  }
  const auth=fixture([[7,7],[7,7],[7,7]],2),a=render(auth),am=markers(a);assert.equal(am.filter(x=>x.attributes['aria-label'].includes('originale')).length,1);assert.equal(am[1].attributes.fill,'#923c30');assert.equal(am[0].attributes.fill,am[2].attributes.fill);
  for(const node of walk(a))for(const[k,v]of Object.entries(node.attributes))if(['title','aria-label'].includes(k))assert.doesNotMatch(v,/[0-9a-f]{8}-[0-9a-f-]{27,}/i);
  return 'pubblico neutro;3fughe respinte;soloindiceesplicito evidenziato';
 }],
 ['G5',async()=>{
  const e=fixture(),before=clone(e),n=render(e);
  for(const m of markers(n)){assert.equal(m.attributes.tabindex,'0');assert.equal(m.attributes.role,'img');assert.ok(m.attributes['aria-label'].includes('figura'));assert.equal(m.children.find(x=>x.tagName==='title').textContent,m.attributes['aria-label']);}
  assert.equal(walk(n).filter(x=>x.tagName==='text'&&x.textContent.includes('stessa posizione')).length,1);
  const calls=[],c=qa.createPanelController({locationId:id(21),contextKey:()=>id(80),requestKey:()=>id(81),rpc:async(name)=>{calls.push(name);const dto=clone(e);if(name!=='combat_panel_options_v1')dto.offers=[];return dto;}});
  assert.equal(await c.readState(),true);assert.equal(await c.readOptions(),true);c.selectOffer(id(40));const g=e.offers[0].choices[0],commands=[];
  for(const opt of g.options){qa.changeSingleChoice(g,opt.option_id,new Set(c.snapshot().selectedOptionIds),c.selectOption);const cmd=plain(c.prepare());assert.deepEqual(cmd.selected_option_ids,[opt.option_id]);assert.deepEqual(Object.keys(cmd).sort(),['schema_version','request_key','location_id','activity_id','context_version','offer_id','selected_option_ids','inputs','narrative_text'].sort());assert.deepEqual(cmd.inputs,[]);assert.equal(cmd.narrative_text,'');commands.push(cmd);}
  assert.notEqual(commands[0].selected_option_ids[0],commands[1].selected_option_ids[0]);assert.equal(calls.filter(x=>x==='combat_panel_commit_v1').length,0);assert.deepEqual(e,before);
  return 'markerfocusabili/legenda e2ID selezionabili;prepare solo contratto canonico,0commit';
 }],
 ['G6',async()=>{
  const bundled=s=>s.replace(/^import\s*\{([^}]+)\}\s*from\s*['"]\.\/([^'"]+)['"];?\s*$/gm,(_,names,file)=>'const {'+names+'}='+baseline.modules[file]+';').replace(/\bexport (function|const)\s+(\w+)/g,'$1 $2');
  let inverse=html;for(const file of [...baseline.patched].reverse()){const after=bundled(read('ui/'+file)),before=bundled(fs.readFileSync(path.join(root,baseline.source_dir,file),'utf8'));assert.equal(inverse.split(after).length,2,'embedded:'+file);inverse=inverse.replace(after,before);}
  const oldMarker='content="LAND-COMMAND-FEEDBACK-CANDIDATE-001"',newMarker='content="LAND-MULTIPLICATION-PROJECTION-ALIGNMENT-001"';assert.equal(inverse.split(newMarker).length,2);inverse=inverse.replace(newMarker,oldMarker);assert.equal(sha(inverse),baseline.land_sha256_expected);assert.equal(inverse,fs.readFileSync(path.join(root,baseline.land_source),'utf8'));
  const baselineBundle=inverse.match(/<script id="common-panel-bundle">([\s\S]*?)<\/script>/)[1],ctx=createContext({window:{},structuredClone,crypto:{randomUUID},queueMicrotask});new Script(baselineBundle.replace('window.TUSCommonPanel=module0;','window.TUSCommonPanel=module0;window.oldMap=module6.renderPanelMap;')).runInContext(ctx);
  const e=fixture([[7,7],[8,7]]);e.map.sabaku_clones=[{clone_id:id(70),owner_actor_id:id(1),owner_name:'Osservatore sintetico',state:'armed',x_m:6,y_m:5,trigger_radius_m:2}];const before=clone(e),current=render(e),old=rootNode();ctx.window.oldMap(old,clone(e));assertMarkers(e,current);
  const layer=(r,name)=>walk(r).find(x=>x.attributes['data-layer']===name);
  const tree=n=>({tag:n.tagName,attrs:n.attributes,text:n.ownText,children:n.children.map(tree)});
  assert.deepEqual(tree(layer(current,'impervious')),tree(layer(old,'impervious')));assert.deepEqual(tree(layer(current,'sabaku-clones')),tree(layer(old,'sabaku-clones')));assert.deepEqual(e,before);
  const empty=clone(e);empty.multiplication=null;const n1=render(empty),n2=rootNode();ctx.window.oldMap(n2,clone(empty));assert.deepEqual(tree(n1),tree(n2));
  return 'inverse2blocchi+marker byteidentico;terrain/Clone invariati e mappa senzaMolti identica';
 }]
];
const started=new Date().toISOString(),start=performance.now(),results=[];
for(const[id,run]of groups){
 if(setupError){results.push({id,status:'NOT_RUN',reason:setupError});continue;}
 try{results.push({id,status:'PASS',detail:await run()});}catch(e){results.push({id,status:'FAIL',reason:String(e.message||e),details:e.details??null});}
}
const postPins={};for(const[n]of Object.entries(pins)){const f=manifest.files[n]?path.join(pkg,n):['impervious-map.test.mjs','single-blank.test.mjs'].includes(n)?path.join(root,baseline.source_dir,n):path.join(root,n);postPins[n]=sha(fs.readFileSync(f));}
const drift=Object.keys(pins).filter(n=>pins[n]!==postPins[n]);
const result={task_id:'QA-MULTIPLICATION-PROJECTION-001',state:results.every(r=>r.status==='PASS')&&drift.length===0?'COMPONENT_PASS':'COMPONENT_NOT_QUALIFIED',started_at:started,finished_at:new Date().toISOString(),elapsed_ms:performance.now()-start,groups:6,passed:results.filter(r=>r.status==='PASS').length,results,setup_error:setupError,inline_scripts_compiled:inlineScripts,runner_sha256:sha(fs.readFileSync(fileURLToPath(import.meta.url))),candidate_manifest_sha256:sha(read('MANIFEST.json')),input_pins:pins,postflight_drift:drift,limits:{SQL:0,API:0,Docker:0,browser:0,provider:0,retries:0,DOM:'sintetico minimo',RPC:'fixture in memoria;prepare noncommit',gameplay:'NONQUALIFICATO',Auth:'NONQUALIFICATO',visual_accessibility:'NONQUALIFICATO',UI_privata003:'non eseguita'}};
fs.writeFileSync(out,JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({state:result.state,groups:result.groups,passed:result.passed,results:result.results,drift}));if(result.state!=='COMPONENT_PASS')process.exitCode=1;
