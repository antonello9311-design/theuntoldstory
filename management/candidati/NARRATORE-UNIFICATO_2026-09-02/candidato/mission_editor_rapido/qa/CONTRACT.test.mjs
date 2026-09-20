import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import path from 'node:path';

const root=new URL('../',import.meta.url);
const read=path=>readFileSync(new URL(path,root),'utf8');
const sql=read('db/INSTALL.sql');
const recovery=read('db/RECOVERY.sql');
const index=read('edge/mission_authoring_ai/index.ts');
const uiSource=read('ui/mission-rapid-editor.mjs');
const uiAsset=read('ui/mission-rapid-editor.asset.v1.mjs');
const dbContract=JSON.parse(read('db/CONTRACT.json'));
const manifest=JSON.parse(read('MANIFEST.json'));
const sha=body=>createHash('sha256').update(body).digest('hex');

test('01 validator canonizza source server-side',()=>{
  assert.match(sql,/src:=mission_rapid_owner\.validate_source\(p_document->'source'\)/);
  assert.match(sql,/if src is distinct from p_source/);
});
test('02 validator ricontrolla compiled editoriale',()=>{
  assert.match(sql,/cmp:=mission_rapid_owner\.validate_compiled\(p_document->'compiled'\)/);
  assert.doesNotMatch(sql,/p_document->'compiled' is distinct from p_compiled/);
});
test('03 salvataggio rende corrente la compiled corretta',()=>assert.match(sql,/set compiled=doc->'compiled',document=doc/));
test('04 source e richiesta mappa restano coerenti',()=>assert.match(sql,/cmp#>>'\{map_request,mode\}'.*case when \(src->>'has_map_image'\)::boolean/s));
test('05 risposte compilazione restituiscono source canonica',()=>{
  assert.match(sql,/'source',d\.source,'compiled',d\.compiled/);
  assert.match(sql,/'source',d\.source,'compiled',doc/);
});
test('06 CORS applicato a successi ed errori POST',()=>{
  assert.match(index,/return json\(result,200,access\.headers\)/);
  assert.match(index,/return json\(\{code,edge_revision:EDGE_REVISION\}.*access\.headers/);
});
test('07 manifest include runtime transitivi',()=>{
  const paths=new Set(manifest.artifacts.map(x=>x.path));
  assert(paths.has('edge/mission_authoring_ai/runtime.mjs'));
  assert(paths.has('media/runtime.mjs'));
  assert(paths.has('db/CONTRACT.json'));
  assert(paths.has('ui/mission-rapid-editor.mjs'));
  assert(paths.has('ui/mission-rapid-editor.test.mjs'));
  assert(paths.has('media/TEST.mjs'));
});
test('08 tutti gli hash dichiarati corrispondono',()=>{
  for(const artifact of manifest.artifacts)assert.equal(sha(read(artifact.path)),artifact.sha256,artifact.path);
});
test('09 import relativi degli entrypoint sono manifestati',()=>{
  const paths=new Set(manifest.artifacts.map(x=>x.path));
  for(const entry of ['edge/mission_authoring_ai/index.ts','media/png_media_attest_v1/index.ts']){
    const base=entry.split('/').slice(0,-1).join('/');
    for(const match of read(entry).matchAll(/from\s+['"](\.\.?\/[^'"]+)['"]/g)){
      const normalized=path.posix.normalize(path.posix.join(base,match[1]));
      assert(paths.has(normalized),`${entry}: ${match[1]}`);
    }
  }
});
test('10 endpoint terminale JSON chiuso e helper nativo privato',()=>{
  assert.match(sql,/raise exception 'MR_TERMINAL_NATIVE_ONLY'/);
  assert.match(sql,/create function mission_rapid_owner\.try_native_terminal\(p_session uuid\)/);
  assert.doesNotMatch(sql,/grant execute on function public\.mission_rapid_terminal_evaluate_v1[^;]+service_role/);
});
test('11 consumer terminale innestato con pin sulla progressione viva',()=>{
  assert.match(sql,/0bc40e0ff963c26a63e218f2aa95dd94/);
  assert.match(sql,/res:=mission_rapid_owner\.try_native_terminal\(p_session\)/);
  assert.match(sql,/if res is not null then return mission_generic_owner\.progress_result\(p_session,p_user,''transitioned''\)/);
});
test('12 raggiungimento posizione richiede movimento nativo consolidato',()=>{
  assert.match(sql,/se\.event_kind='movement_settled'/);
  assert.match(sql,/matched:=movement_event_id is not null/);
});
test('13 evento terminale e hash derivano dallo stesso record autorevole',()=>{
  assert.match(sql,/source_sha:=public\.combat_v2_sha256\(to_jsonb\(native_event\)\)/);
  assert.match(sql,/to_jsonb\(native_event\),source_sha,result/);
});
test('14 recovery ripristina progress_step solo senza drift',()=>{
  assert.match(recovery,/expected_definition:=replace\(baseline,old_fragment,new_fragment\)/);
  assert.match(recovery,/current_definition is distinct from expected_definition/);
  assert.match(recovery,/execute baseline/);
});
test('15 preview mappa usa catalogo vivo e blocca validità o capienza',()=>{
  assert.match(sql,/mapdetail:=public\.mission_map_detail_v1\(c#>>'\{map,template_key\}',\(c#>>'\{map,template_version\}'\)::integer\)/);
  assert.match(sql,/mapspec is distinct from c#>'\{map,spec\}'/);
  assert.match(sql,/'code','MAP_CAPACITY'/);
  assert.match(sql,/mappreview->>'valid'/);
  assert.match(sql,/mappreview->>'can_fit'/);
});
test('16 DB vieta più condizioni native non standard per fase',()=>{
  assert.match(sql,/MR_COMPILED_NATIVE_RULE_AMBIGUOUS/);
  assert.match(sql,/group by rule_item->>'phase_key' having count\(\*\)>1/);
});
test('17 soglie terminali DB ammesse soltanto se intere',()=>{
  assert.match(sql,/\(r->>'threshold'\)::numeric<>trunc\(\(r->>'threshold'\)::numeric\)/);
});
test('18 incontro include PNG di fase e mappa protetti sulla squadra PG',()=>{
  assert.match(sql,/value->>'team' in\('alleati','civili'\)/);
  assert.match(sql,/jsonb_set\(value,'\{team\}',to_jsonb\('squadra'::text\),true\)/);
  assert.match(sql,/jsonb_array_elements\(scene_actors\) x where x->>'team'='avversari'/);
  assert.doesNotMatch(sql,/jsonb_array_elements\(phase_actors\)[^;]+where value->>'team'='avversari'/s);
});
test('19 sorgente UI testata e asset deploy sono identici',()=>assert.equal(uiSource,uiAsset));
test('20 contratto Generic riceve attori scena e incontro JSON-identici',()=>{
  assert.equal(dbContract.upstream_compatibility.encounter_actor_scope,'every encounter actor must be JSON-exactly present in scenes[].actors');
  assert.match(sql,/'pg_team','squadra','actors',scene_actors,'arena_ref','mission'/);
  assert.match(sql,/'step_key',step_key,'actors',scene_actors,'encounters',encounters/);
  assert(dbContract.terminal_rules.semantic_constraints.some(x=>x.includes('exact same normalized actor JSON array')));
});
test('21 confronti map mode racchiudono CASE come espressione SQL',()=>{
  assert.equal([...sql.matchAll(/is distinct from \(case when/g)].length,2);
  assert.doesNotMatch(sql,/is distinct from case when/);
});
test('22 hook terminale compone la guardia unified_batches viva in install e recovery',()=>{
  const liveGuard="if exists(select 1 from public.mission_run_outbox uo where uo.master_session_id=p_session and uo.state=''pending'' and not exists(select 1 from mission_generic_owner.unified_batches ub where ub.master_session_id=p_session and ub.state=''preparing'' and ub.route->>''event_id''=uo.event_id::text))";
  for(const body of [sql,recovery]){
    assert.equal(body.split(liveGuard).length-1,2);
    assert.match(body,/narration_pending''\);end if;\\n res:=mission_rapid_owner\.try_native_terminal\(p_session\)/);
  }
  assert.equal(sql.match(/0bc40e0ff963c26a63e218f2aa95dd94/g)?.length,2);
});
test('23 threshold JSON null resta assente per le regole senza soglia',()=>{
  assert.match(sql,/\(r->'threshold' is not null and r->'threshold'<>'null'::jsonb\)/);
  assert.doesNotMatch(sql,/distinct from \(r->'threshold' is not null\)\)/);
});
test('24 query aggregate non riusano alias delle variabili PLpgSQL',()=>{
  assert.match(sql,/jsonb_array_elements\(p->'actors'\) actor_item group by actor_item->>'actor_key'/);
  assert.match(sql,/jsonb_array_elements\(p->'terminal_rules'\) rule_item[\s\S]+group by rule_item->>'phase_key'/);
  assert.doesNotMatch(sql,/jsonb_array_elements\(p->'actors'\) a group by a->>'actor_key'/);
  assert.doesNotMatch(sql,/jsonb_array_elements\(p->'terminal_rules'\) r group by r->>'rule_key'/);
});
test('25 preview rapida normalizza coordinate catalogo gia validate',()=>{
  assert.match(sql,/mapspec:=jsonb_set\(mapspec,'\{suggested_entries\}'.*\(\(value->>'x_m'\)::numeric\)::integer.*\(\(value->>'y_m'\)::numeric\)::integer/s);
  assert.match(sql,/mapspec:=jsonb_set[\s\S]+mappreview:=public\.mission_map_preview_v1\(mapspec/);
});
test('26 documento tecnico qualifica l attore editoriale laterale',()=>{
  assert.equal(sql.match(/q\.editorial_actor->/g)?.length,6);
  assert.match(sql,/q\(editorial_actor\) on true/);
  assert.doesNotMatch(sql,/q\(actor\) on true/);
});
test('27 concatenazioni delle regole terminali restano testo prima del JSON',()=>{
  assert.match(sql,/'term_'\|\|\(rule->>'rule_key'\)/);
  assert.match(sql,/'Condizione missione: '\|\|\(rule->>'rule_key'\)/);
  assert.doesNotMatch(sql,/'term_'\|\|rule->>/);
});
test('28 mappa default resta globale e solo specific produce arena esplicita',()=>{
  assert.match(sql,/if c#>>'\{map,mode\}'='specific' then\s+arenas:=arenas\|\|jsonb_build_array/s);
  assert.match(sql,/'template_key',c#>>'\{map,template_key\}'.*'template_version',\(c#>>'\{map,template_version\}'\)::integer/s);
  assert.doesNotMatch(sql,/'template_key',case when c#>>'\{map,mode\}'='default10'/);
});
test('29 priorita delle condizioni terminali rispetta il vincolo live',()=>{
  assert.match(sql,/'event_kind',mission_rapid_owner\.rule_transition\(rule\),'priority',0/);
  assert.doesNotMatch(sql,/'priority',-\d+/);
});
