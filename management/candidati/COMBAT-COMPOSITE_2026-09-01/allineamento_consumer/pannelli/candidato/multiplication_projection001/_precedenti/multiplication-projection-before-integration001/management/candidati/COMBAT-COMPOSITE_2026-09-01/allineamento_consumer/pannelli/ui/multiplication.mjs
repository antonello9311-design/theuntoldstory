// Validazione di presentazione: nessuna formazione o posizione generata dal client.
const uuid=x=>typeof x==='string'&&/^[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(x);
const exact=(x,keys)=>x!==null&&typeof x==='object'&&!Array.isArray(x)&&Object.keys(x).length===keys.length&&keys.every(k=>Object.hasOwn(x,k));
const finite=x=>typeof x==='number'&&Number.isFinite(x);
const check=ok=>{if(!ok)throw Error('multiplication_projection_invalid');};
export function validateMultiplication(envelope){
  const value=envelope.multiplication;
  if(value===null)return [];
  check(envelope.status==='ready'&&envelope.map!==null);
  check(exact(value,['schema_version','formations'])&&value.schema_version==='combat-multiplication-view/1'&&Array.isArray(value.formations));
  const bounds=envelope.map?.bounds,roster=envelope.actors,bodies=envelope.map?.actors;
  check(bounds&&finite(bounds.width_m)&&bounds.width_m>0&&finite(bounds.height_m)&&bounds.height_m>0&&Array.isArray(roster)&&Array.isArray(bodies));
  const owners=new Set(),formations=new Set();
  for(const f of value.formations){
    check(exact(f,['formation_id','actor_id','mode','state_version','figures','original_index']));
    check(uuid(f.formation_id)&&!formations.has(f.formation_id)&&uuid(f.actor_id)&&!owners.has(f.actor_id));
    const owner=roster.find(a=>a.actor_id===f.actor_id);check(owner&&!owner.body_only);
    check(['diversivo','copertura','assalto'].includes(f.mode)&&Number.isSafeInteger(f.state_version)&&f.state_version>0&&Array.isArray(f.figures)&&f.figures.length>=2);
    owners.add(f.actor_id);formations.add(f.formation_id);
    const indices=new Set(),coordinates=new Set();
    for(const point of f.figures){
      check(exact(point,['figure_index','x_m','y_m'])&&Number.isSafeInteger(point.figure_index)&&point.figure_index>=1&&point.figure_index<=f.figures.length&&!indices.has(point.figure_index));
      check(finite(point.x_m)&&finite(point.y_m)&&point.x_m>=0&&point.y_m>=0&&point.x_m<=bounds.width_m&&point.y_m<=bounds.height_m);
      const position=JSON.stringify([point.x_m,point.y_m]);check(!coordinates.has(position));coordinates.add(position);indices.add(point.figure_index);
    }
    for(let a=0;a<f.figures.length;a++)for(let b=a+1;b<f.figures.length;b++){
      const dx=f.figures[a].x_m-f.figures[b].x_m,dy=f.figures[a].y_m-f.figures[b].y_m;check(dx*dx+dy*dy<=25);
    }
    check(f.original_index===null||Number.isSafeInteger(f.original_index)&&indices.has(f.original_index));
    if(f.original_index===null){
      // Non mostrare una seconda sorgente che sveli l'originale implicitamente.
      check(!bodies.some(a=>a.actor_id===f.actor_id)&&owner.distance_from_viewer_m===null&&envelope.map.pov?.actor_id!==f.actor_id);
    }
  }
  return value.formations;
}
