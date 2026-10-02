// Pure preparation contract; not an authoring authority or a backend DTO.
const copy=x=>structuredClone(x),freeze=x=>{if(x&&typeof x==='object'){Object.values(x).forEach(freeze);Object.freeze(x);}return x;};
const fail=message=>{throw Error(message);};
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const metadataKeys=['title','grado','briefing','village','tag_trama','team_min','team_max'];
export function createNewNativeVariantPreparation({sourceMetadata,head,mode}={}){
 if(!['ai','human'].includes(mode)||!head||Object.keys(head).sort().join('|')!==['mission_id','mode','variant_version','base_plan_version_id','source_sha256'].sort().join('|')||!UUID.test(head.mission_id||'')||head.mission_id==='db1588ae-50f2-4c0e-9028-0b94155d94b1'||head.mode!==mode||head.variant_version!==0||head.base_plan_version_id!==null||!/^[0-9a-f]{64}$/.test(head.source_sha256||''))fail('Serve la head zero della fonte e della modalità scelte.');
 if(!sourceMetadata||Object.keys(sourceMetadata).sort().join('|')!==metadataKeys.slice().sort().join('|')||typeof sourceMetadata.title!=='string'||typeof sourceMetadata.briefing!=='string'||!['D','C','B','A','S'].includes(sourceMetadata.grado)||![null,'','Konoha','Suna'].includes(sourceMetadata.village)||!(sourceMetadata.tag_trama===null||typeof sourceMetadata.tag_trama==='string')||!Number.isSafeInteger(sourceMetadata.team_min)||!Number.isSafeInteger(sourceMetadata.team_max)||sourceMetadata.team_min<1||sourceMetadata.team_max>4||sourceMetadata.team_min>sourceMetadata.team_max)fail('Metadati autorevoli della fonte incompleti.');
 const original=freeze(copy(sourceMetadata)),pin=freeze(copy(head));
 const mission={...copy(original),village:original.village||'',tag_trama:original.tag_trama||'',direction_mode:mode,gathering_location_id:''};
 function assertModel(model){if(model.base!==null||!model.mission||metadataKeys.some(k=>model.mission[k]!==mission[k])||model.mission.direction_mode!==mode)fail('Metadati, modalità e head del nuovo piano sono di sola lettura.');}
 return {
  mission:()=>copy(mission),head:()=>copy(pin),assertModel,
  finish(document){if(document?.schema_version!=='mission-creation-document/1'||document.plan?.base_plan_version_id!==null||document.mission?.direction_mode!==mode||metadataKeys.some(k=>document.mission[k]!==(['title','briefing'].includes(k)?mission[k].trim():mission[k])))fail('Il documento proposto non coincide con la fonte e la head zero.');
   return {schema_version:'new-native-variant-form-result/1',state:'prepared_source',head:copy(pin),document:copy(document)};
  }
 };
}
