// Nuovo renderer combat-map/2; il validatore exact2 v1 resta invariato.
import {validateMultiplication} from './multiplication.mjs';
const id=x=>typeof x==='string'&&/^[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(x);
const finite=x=>typeof x==='number'&&Number.isFinite(x);
const label=x=>typeof x==='string'&&x.trim().length>0;
const states={available:'disponibile',reserved:'riservato',consumed_non_substitutable:'consumato · non sostituibile',blocked:'bloccato'};
export function renderPanelMap(root,envelope){
  root.replaceChildren();const doc=root.ownerDocument,m=envelope?.map;
  const add=(tag,value,parent=root)=>{const el=doc.createElement(tag);el.textContent=value;parent.append(el);return el;};
  const fail=()=>add('p','Mappa non disponibile per questo contesto.');
  if(envelope?.schema_version!=='combat-panel/1'||envelope.status!=='ready'||m?.schema_version!=='combat-map/2'||m.readonly!==true||!Number.isSafeInteger(m.map_version)||m.map_version<0||!label(m.label))return fail();
  const bounds=m.bounds,roster=envelope.actors;
  if(!finite(bounds?.width_m)||!finite(bounds?.height_m)||bounds.width_m<=0||bounds.height_m<=0||!Array.isArray(roster)||!Array.isArray(m.actors)||!Array.isArray(m.objects))return fail();
  const pos=a=>a&&finite(a.x_m)&&finite(a.y_m)&&finite(a.radius_m)&&a.radius_m>0&&a.x_m>=0&&a.y_m>=0&&a.x_m<=bounds.width_m&&a.y_m<=bounds.height_m;
  const objectPosition=o=>{
    const s=o.shape;
    if(!s||typeof s!=='object'||Array.isArray(s))return false;
    if(o.shape_kind==='circle')return Object.keys(s).length===3&&pos(o)&&s.cx===o.x_m&&s.cy===o.y_m&&s.radius===o.radius_m;
    if(o.shape_kind!=='aabb'||Object.keys(s).length!==4||o.radius_m!==null)return false;
    return ['min_x','min_y','max_x','max_y'].every(k=>finite(s[k]))&&s.min_x>=0&&s.min_y>=0&&s.max_x<=bounds.width_m&&s.max_y<=bounds.height_m&&s.min_x<s.max_x&&s.min_y<s.max_y&&o.x_m===(s.min_x+s.max_x)/2&&o.y_m===(s.min_y+s.max_y)/2;
  };
  const byId=new Map(roster.map(a=>[a.actor_id,a]));
  if(byId.size!==roster.length||new Set(m.actors.map(a=>a.actor_id)).size!==m.actors.length||new Set(m.objects.map(o=>o.object_id)).size!==m.objects.length)return fail();
  if(!m.actors.every(a=>{const r=byId.get(a.actor_id);return id(a.actor_id)&&pos(a)&&typeof a.body_only==='boolean'&&r&&label(r.display_name)&&r.body_only===a.body_only&&['pg','png','companion'].includes(r.kind)&&['active','out','withdrawn'].includes(r.state)&&(r.kind==='companion')===a.body_only;}))return fail();
  if(m.pov===null){if(envelope.viewer.command_actor_id!==null||!(envelope.viewer.is_master||envelope.viewer.is_admin))return fail();}
  else if(!pos(m.pov)||m.pov.actor_id!==envelope.viewer.command_actor_id||m.actors.filter(a=>a.actor_id===m.pov.actor_id).length!==1)return fail();
  if(!m.objects.every(o=>id(o.object_id)&&label(o.label)&&objectPosition(o)&&Object.hasOwn(states,o.state)&&typeof o.substitution_anchor_available==='boolean'&&typeof o.is_impervious==='boolean'&&(!o.is_impervious||(o.state==='available'&&!o.substitution_anchor_available&&(o.shape_kind!=='circle'||(o.x_m-o.radius_m>=0&&o.y_m-o.radius_m>=0&&o.x_m+o.radius_m<=bounds.width_m&&o.y_m+o.radius_m<=bounds.height_m))))&&(o.distance_from_viewer_m===null?m.pov===null:finite(o.distance_from_viewer_m)&&o.distance_from_viewer_m>=0&&m.pov!==null)))return fail();
  const clones=m.sabaku_clones??[];
  const cloneKeys=['clone_id','owner_actor_id','owner_name','state','x_m','y_m','trigger_radius_m'];
  if(!Array.isArray(clones)||new Set(clones.map(c=>c?.clone_id)).size!==clones.length||!clones.every(c=>c&&Object.keys(c).length===cloneKeys.length&&cloneKeys.every(k=>Object.hasOwn(c,k))&&id(c.clone_id)&&id(c.owner_actor_id)&&byId.get(c.owner_actor_id)?.display_name===c.owner_name&&['armed','holding'].includes(c.state)&&finite(c.x_m)&&finite(c.y_m)&&c.x_m>=0&&c.x_m<=bounds.width_m&&c.y_m>=0&&c.y_m<=bounds.height_m&&c.trigger_radius_m===2))return fail();
  let formations;try{formations=validateMultiplication(envelope);}catch{return fail();}
  const formationOwners=new Set(formations.map(f=>f.actor_id));
  add('h4',m.label);add('p',`${bounds.width_m} × ${bounds.height_m} m · mappa di sola lettura`);
  if(m.objects.some(o=>o.is_impervious))add('p','Il malus riguarda i personaggi fisici. Le marionette sono escluse. Trasporto di Sabbia attivo esenta da tutte le aree impervie.');
  if(m.pov===null)add('p','Vista Master · nessun punto di vista attribuito a un personaggio');
  const ns='http://www.w3.org/2000/svg';
  const svg=doc.createElementNS(ns,'svg');svg.setAttribute('viewBox',`0 0 ${bounds.width_m} ${bounds.height_m}`);svg.setAttribute('role','img');svg.setAttribute('aria-label',m.label+' · posizioni autorizzate');svg.classList.add('ordinary-map');root.append(svg);
  const shape=(tag,attrs,parent=svg)=>{const el=doc.createElementNS(ns,tag);for(const[k,v]of Object.entries(attrs))el.setAttribute(k,String(v));parent.append(el);return el;};
  const scale=Math.min(bounds.width_m,bounds.height_m);
  shape('rect',{x:0,y:0,width:bounds.width_m,height:bounds.height_m,fill:'#f4ecd5',stroke:'#9e8b61','stroke-width':scale/150});
  const legend=add('ul','');
  // Le zone stanno sotto i corpi: entrarvi non nasconde PG, PNG o copie.
  const terrainLayer=shape('g',{'data-layer':'impervious'});
  for(const o of m.objects.filter(o=>o.is_impervious)){
    const s=o.shape,attrs={fill:'#c58b28','fill-opacity':0.25,stroke:'#89590e','stroke-width':scale/180,'stroke-dasharray':`${scale/70} ${scale/110}`};
    const area=o.shape_kind==='circle'?shape('circle',{cx:s.cx,cy:s.cy,r:s.radius,...attrs},terrainLayer):shape('rect',{x:s.min_x,y:s.min_y,width:s.max_x-s.min_x,height:s.max_y-s.min_y,...attrs},terrainLayer);
    const description=o.label+' · area impervia · movimento dimezzato';
    shape('title',{},area).textContent=description;
    add('li',description,legend);
  }
  const cloneLayer=shape('g',{'data-layer':'sabaku-clones'});
  for(const c of clones){
    const color=c.state==='armed'?'#9a6c24':'#923c30',description=`Clone di Sabbia di ${c.owner_name} · `+(c.state==='armed'?'innesco entro 2 m':'presa attiva');
    shape('polygon',{points:`${c.x_m-c.trigger_radius_m},${c.y_m} ${c.x_m},${c.y_m-c.trigger_radius_m} ${c.x_m+c.trigger_radius_m},${c.y_m} ${c.x_m},${c.y_m+c.trigger_radius_m}`,fill:color,'fill-opacity':0.10,stroke:color,'stroke-width':scale/170,'stroke-dasharray':`${scale/80} ${scale/100}`},cloneLayer);
    const size=scale/60;
    const marker=shape('path',{d:`M ${c.x_m} ${c.y_m-size} L ${c.x_m+size} ${c.y_m} L ${c.x_m} ${c.y_m+size} L ${c.x_m-size} ${c.y_m} Z`,fill:color},cloneLayer);
    shape('title',{},marker).textContent=description;
    shape('text',{x:c.x_m,y:c.y_m-size*1.5,'text-anchor':'middle','font-size':scale/34,fill:color},cloneLayer).textContent='Clone';
    add('li',description,legend);
  }
  for(const a of m.actors){
    if(formationOwners.has(a.actor_id))continue;
    const r=byId.get(a.actor_id),selected=a.actor_id===m.pov?.actor_id;
    const circle=shape('circle',{cx:a.x_m,cy:a.y_m,r:a.radius_m,fill:a.body_only?'#806336':selected?'#923c30':'#356b91'});
    shape('title',{},circle).textContent=r.display_name;
    shape('text',{x:a.x_m,y:a.y_m-a.radius_m,'text-anchor':'middle','font-size':scale/28,fill:'#352b1e'}).textContent=r.display_name;
    add('li',r.display_name+(a.body_only?' · corpo passivo':'')+(selected?' · selezionato':''),legend);
  }
  for(const formation of formations){
    const owner=byId.get(formation.actor_id);
    for(const point of [...formation.figures].sort((a,b)=>a.figure_index-b.figure_index)){
      const original=formation.original_index!==null&&formation.original_index===point.figure_index;
      const description=`${owner.display_name} · figura ${point.figure_index}`+(original?' · originale':'');
      // Dimensione grafica uniforme: non rappresenta un raggio meccanico.
      const marker=shape('circle',{cx:point.x_m,cy:point.y_m,r:scale/70,fill:original?'#923c30':'#356b91'});
      shape('title',{},marker).textContent=description;
      shape('text',{x:point.x_m,y:point.y_m-scale/55,'text-anchor':'middle','font-size':scale/28,fill:'#352b1e'}).textContent=`${owner.display_name} ${point.figure_index}`;
      add('li',`${description} · (${point.x_m}, ${point.y_m}) m`,legend);
    }
  }
  for(const o of m.objects.filter(o=>!o.is_impervious)){
    const fill=o.state==='available'?'#587349':'#8b8171',s=o.shape;
    const object=o.shape_kind==='circle'?shape('circle',{cx:s.cx,cy:s.cy,r:s.radius,fill}):shape('rect',{x:s.min_x,y:s.min_y,width:s.max_x-s.min_x,height:s.max_y-s.min_y,fill});
    shape('title',{},object).textContent=o.label;
    add('li',o.label+' · '+states[o.state]+(o.distance_from_viewer_m===null?'':` · ${o.distance_from_viewer_m} m dal punto di vista`)+(o.substitution_anchor_available?' · ancora disponibile':''),legend);
  }
  add('p','Movimento e interazioni si scelgono dalle offerte del server, non dalla mappa.');
}
