"""QA locale reale: 4 gruppi fissi, zero provider; database dedicato.
Catalogo PNG narrativo reale, schede statistiche sintetiche e nessun PG/Auth reale.
"""
import json, pathlib, subprocess
root=pathlib.Path(__file__).resolve().parents[2]
rows=json.loads((root/'candidato/db/MISSION_EXAM_PNG_EDITORIAL.json').read_text())['rows']
candidate=(root/'candidato/db/MISSION_EXAM_PNG_EDITORIAL.sql').read_text()
assert '$candidate$' not in candidate
data=json.dumps(rows,ensure_ascii=False)
assert '$source$' not in data
seed="""begin;
create temp table editorial_expected as
select * from jsonb_to_recordset($source$DATA$source$::jsonb)
as x(nome text, agent_id uuid, before jsonb, after jsonb);
insert into public.ai_agents(id,kind,name,village,persona,model)
select agent_id,'png_trama',nome,'konoha',before,'gpt-5.6-luna' from editorial_expected;
insert into public.esame_png_profili(nome,agent_id,stile,villaggio,mente,forza,velocita,resistenza,ninjutsu,genjutsu,taijutsu,fuuinjutsu)
select nome,agent_id,'tecnico','konoha',20,20,20,20,20,20,10,10 from editorial_expected;
create temp table editorial_baseline as select
(select md5(jsonb_agg(to_jsonb(a)-'persona' order by id)::text) from public.ai_agents a) as other_hash,
(select md5(jsonb_agg(to_jsonb(p) order by id)::text) from public.esame_png_profili p) as profiles_hash;
""".replace('DATA',data)
call='execute $candidate$'+candidate+'$candidate$;'
sql=seed+"""
do $qa$
declare before_hash text; after_hash text; caught boolean := false;
begin
CALL
if exists(select 1 from editorial_expected e join public.ai_agents a on a.id=e.agent_id where a.persona<>e.after)
then raise exception 'QA01 output mismatch'; end if;
if (select other_hash from editorial_baseline)<>(select md5(jsonb_agg(to_jsonb(a)-'persona' order by id)::text) from public.ai_agents a)
or (select profiles_hash from editorial_baseline)<>(select md5(jsonb_agg(to_jsonb(p) order by id)::text) from public.esame_png_profili p)
then raise exception 'QA01 changed out of scope'; end if;
raise notice 'QA01 PASS: six exact persona, other columns and profiles unchanged';
select md5(jsonb_agg(to_jsonb(a) order by id)::text) into before_hash from public.ai_agents a;
CALL
select md5(jsonb_agg(to_jsonb(a) order by id)::text) into after_hash from public.ai_agents a;
if before_hash<>after_hash then raise exception 'QA02 not idempotent'; end if;
raise notice 'QA02 PASS: repeated apply inert';
update public.ai_agents a set persona=e.before from editorial_expected e where a.id=e.agent_id;
update public.ai_agents set persona=persona||'{"qa_drift":true}'::jsonb where id=(select agent_id from editorial_expected order by agent_id desc limit 1);
select md5(jsonb_agg(to_jsonb(a) order by id)::text) into before_hash from public.ai_agents a;
begin
CALL
exception when others then
 if sqlerrm<>'EDITORIAL_PERSONA_DRIFT' then raise; end if;
 caught:=true;
end;
select md5(jsonb_agg(to_jsonb(a) order by id)::text) into after_hash from public.ai_agents a;
if not caught or before_hash<>after_hash then raise exception 'QA03 partial mutation'; end if;
raise notice 'QA03 PASS: late drift rolls back every preceding update';
update public.ai_agents a set persona=e.before from editorial_expected e where a.id=e.agent_id;
update public.esame_png_profili set nome='QA different binding' where agent_id=(select agent_id from editorial_expected order by agent_id desc limit 1);
caught:=false;
select md5(jsonb_agg(to_jsonb(a) order by id)::text) into before_hash from public.ai_agents a;
begin
CALL
exception when others then
 if sqlerrm<>'EDITORIAL_PROFILE_MISMATCH' then raise; end if;
 caught:=true;
end;
select md5(jsonb_agg(to_jsonb(a) order by id)::text) into after_hash from public.ai_agents a;
if not caught or before_hash<>after_hash then raise exception 'QA04 partial mutation'; end if;
raise notice 'QA04 PASS: profile mismatch rolls back every preceding update';
end $qa$;
rollback;
""".replace('CALL',call)
r=subprocess.run(['docker','exec','-i','tus_ordinary_compose_qa_db','psql','-U','postgres','-d','tus_exam_editorial_rebuild_001','-v','ON_ERROR_STOP=1','-Atq'],input=sql,text=True,capture_output=True)
print(r.stdout+r.stderr)
raise SystemExit(r.returncode)

