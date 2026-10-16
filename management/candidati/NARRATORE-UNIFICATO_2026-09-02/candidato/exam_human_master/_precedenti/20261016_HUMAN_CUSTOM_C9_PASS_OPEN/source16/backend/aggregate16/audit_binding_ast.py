from pathlib import Path
from pglast import parser
import json,re,hashlib
p=Path('/private/tmp/tus-human-custom-ordinary');out=p/'backend/aggregate16'
def walk(x):
 if isinstance(x,dict):
  yield x
  for v in x.values():yield from walk(v)
 elif isinstance(x,list):
  for v in x:yield from walk(v)
def audit(path):
 text=path.read_text();tree=json.loads(parser.parse_sql_json(text));funcs=json.loads(parser.parse_plpgsql_json(text));results=[];issues=[];errors=[]
 for i,f in enumerate(funcs):
  f=f['PLpgSQL_function'];names=set()
  for d in f.get('datums',[]):
   for k,v in d.items():
    if k in ('PLpgSQL_var','PLpgSQL_rec','PLpgSQL_row') and v.get('refname'):names.add(v['refname'].lower())
  ex=0;refs=0;whole=0
  for z in walk(f):
   if 'PLpgSQL_expr'not in z:continue
   ex+=1;q=z['PLpgSQL_expr'];s=q['query'];mode=q.get('parseMode',0)
   if mode in (3,4,5):s='SELECT '+re.split(r':=|(?<![<>!:])=(?!=)',s,maxsplit=1)[1]
   elif mode==2:s='SELECT '+s
   try:t=json.loads(parser.parse_sql_json(s))
   except Exception as e:errors.append({'unit':i,'mode':mode,'query':s,'error':str(e)});continue
   sqlnames=set()
   for n in walk(t):
    # pglast JSON stores alias as an inline object, not an Alias wrapper.
    if 'aliasname'in n:sqlnames.add(n['aliasname'].lower());sqlnames.update(c['String']['sval'].lower()for c in n.get('colnames',[])if'String'in c)
    if 'RangeVar'in n:
     rv=n['RangeVar']
     if not rv.get('alias'):sqlnames.add(rv['relname'].lower())
   shared=sqlnames&names
   for n in walk(t):
    if 'ColumnRef'not in n:continue
    fs=n['ColumnRef']['fields'];strings=[x['String']['sval'].lower()for x in fs if'String'in x]
    if not strings:continue
    refs+=1;whole+=len(fs)==1
    if strings[0]in shared:issues.append({'unit':i,'datum':strings[0],'form':'whole_row_or_column'if len(fs)==1 else'qualified_or_star','query_sha256':hashlib.sha256(s.encode()).hexdigest(),'query':s})
  results.append({'unit':i,'PL_datums':sorted(names),'expressions':ex,'SQL_columnrefs':refs,'unqualified_refs_including_whole_rows':whole})
 return {'path':str(path),'sha256':hashlib.sha256(text.encode()).hexdigest(),'SQL_statements':len(tree['stmts']),'units':results,'issues':issues,'unparsed':errors}
paths=[p/'backend/aggregate16/INSTALL_TEMPLATE.sql',p/'backend/aggregate16/DELTA_SOURCE.sql',p/'backend/aggregate16/OPEN_AFTER_STAFF_PASS_TEMPLATE.sql',p/'backend/aggregate16/RECOVERY_GATE_ONLY_TEMPLATE.sql',p/'backend/aggregate16/PREFLIGHT_READONLY.sql',p/'backend/aggregate16/POSTFLIGHT_READONLY.sql',p/'backend/aggregate16/BUSINESS_RECOVERY.sql']
reports=[audit(x)for x in paths]
(out/'WHOLE_BINDING_AST_PROOF.json').write_text(json.dumps({'method':'Author static complete SQL+PL AST, method adopted from prior independent finding: inline alias objects, implicit relation names, explicit column aliases; all ColumnRef arities including bare whole-row arguments; PL scalars/records/rows and assignment RHS. Older auditor had wrongly searched Alias wrapper nodes; that test was insufficient and is superseded.','files':reports},ensure_ascii=False,indent=2)+'\n')
for x in reports:print(Path(x['path']).name,x['sha256'][:8],sum(y['expressions']for y in x['units']),len(x['issues']),len(x['unparsed']))

assert all(not r["issues"] and not r["unparsed"]for r in reports),"PL binding audit failed"
