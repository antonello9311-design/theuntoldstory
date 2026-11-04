#!/usr/bin/env python3
"""All-clan Root material contributor. Local deterministic source generation only.

Never connects to a DB, browser, Git or provider. Actual/target captures and final
review/deploy receipts are explicit inputs. No historical validator is invoked.
"""
from pathlib import Path
import argparse,copy,hashlib,importlib.util,json,re,sys
sys.path.insert(0,'/private/tmp/tus-c1266-narratore76-20261101/db/parse_tools312')
from pglast import parse_sql,parse_plpgsql,ast
from pglast.stream import RawStream

C=Path('/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato')
LIBPATH=C/'COMBAT_INNATA_COMPOSE.py'
spec=importlib.util.spec_from_file_location('allclan_pure_catalog_queries',LIBPATH)
lib=importlib.util.module_from_spec(spec);spec.loader.exec_module(lib)
FN_QUERY=lib.FN_QUERY;REL_QUERY=lib.REL_QUERY;pgtext=lib.pgtext
J=lambda x:json.dumps(x,sort_keys=True,separators=(',',':'),ensure_ascii=False)
H=lambda x:hashlib.sha256(x if isinstance(x,bytes)else x.encode()).hexdigest()
Q=lambda x:"'"+str(x).replace("'","''")+"'"
def read(p):return json.loads(Path(p).read_text())
def D(x,label):
    s=J(x);assert '$'+label+'$'not in s
    return '$'+label+'$'+s+'$'+label+'$'
def opaque(s,label):
    assert '$'+label+'$'not in s
    return '$'+label+'$'+s+'$'+label+'$'

PREFIX='allc_pl_'
CHECKS={'clan_innata_narrative_private.contexts_v1':'contexts_v1_staff_ability_profile_check','clan_hyuga_private.staff_profiles':'staff_profiles_profile_version_check'}
LEGACY=['sabaku-l1','sharingan-l1','byakugan-l1','byakugan-l2','byakugan-l3','byakugan-l4']
SHARINGAN=['65b30dec-6f9f-459e-b78c-49173d74f251','f3673da7-42c9-497e-abe1-1c0982429f35','1ab6d359-f337-45ed-839c-4e626d2e2819']
GROUP='innata_all_clan_functions'
TYPE_NAMES={'int4':'integer','int8':'bigint','int2':'smallint','bool':'boolean','float8':'double precision','varchar':'character varying'}
TYPE_OIDS={'uuid':2950,'text':25,'jsonb':3802,'boolean':16,'bigint':20,'integer':23,'void':2278,'trigger':2279}

def type_name(t):
    names=[x.sval for x in t.names if x.sval!='pg_catalog'];s='.'.join(names)
    return TYPE_NAMES.get(s,s)+'[]'*len(t.arrayBounds or [])
def signature(f):
    return '.'.join(x.sval for x in f.funcname)+'('+','.join(type_name(x.argType)for x in f.parameters or []if x.mode.value not in('o','t'))+')'
def header_from_ast(f):
    opts={x.defname:x.arg for x in f.options};params=list(f.parameters or [])
    modes=[('i'if x.mode.value=='d'else x.mode.value)for x in params]
    assert all(m=='i'for m in modes),'Current scope has only IN parameters; do not silently accept new ABI'
    names=[x.name or ''for x in params]or None;types=[type_name(x.argType)for x in params]
    assert all(x in TYPE_OIDS for x in types)
    defaults=[x for x in params if x.defexpr is not None]
    defexpr=[]
    for p in defaults:
        expr=p.defexpr
        if isinstance(expr,ast.TypeCast):expr=expr.arg
        if isinstance(expr,ast.A_Const)and expr.isnull:defexpr.append('NULL::'+type_name(p.argType))
        elif isinstance(expr,ast.A_Const)and isinstance(expr.val,ast.Boolean):defexpr.append('true'if expr.val.boolval else'false')
        else:raise AssertionError('Unexpected default expression in current45 target ABI')
    config=[]
    for opt in f.options:
        if opt.defname=='set':
            assert opt.arg.name=='search_path'
            values=[x.val.sval for x in opt.arg.args];config.append('search_path=""'if values==['']else'search_path='+', '.join(values))
    return {'signature':signature(f),'source_md5':hashlib.md5(opts['as'][0].sval.encode()).hexdigest(),
     'language':opts['language'].sval,'volatility':{'stable':'s','immutable':'i','volatile':'v'}[opts['volatility'].sval if'volatility'in opts else'volatile'],
     'secdef':bool(opts['security'].boolval)if'security'in opts else False,'arg_names':names,'arg_modes':None,'arg_types':' '.join(str(TYPE_OIDS[x])for x in types),
     'returns':type_name(f.returnType),'config':config or None,'strict':bool(opts['strict'].boolval)if'strict'in opts else False,
     'parallel':{'safe':'s','restricted':'r','unsafe':'u'}[opts['parallel'].sval]if'parallel'in opts else'u','leakproof':False,'kind':'f',
     'default_count':len(defaults),'defaults_expr':', '.join(defexpr)or None}

def source_ast(path,expected_fence):
    text=Path(path).read_text();statements=[];functions={};constraints={};fences=0
    for raw in parse_sql(text):
        n=raw.stmt;kind=type(n).__name__
        if kind=='TransactionStmt':continue
        if kind=='DoStmt':
            # Only the named source sentinel is omitted; config DO is preserved byte-exact.
            opts={x.defname:x.arg for x in n.args};body=opts.get('as')
            body=getattr(body,'sval','')
            if expected_fence in body:fences+=1;continue
        fragment=text[raw.stmt_location:raw.stmt_location+raw.stmt_len]if raw.stmt_len else text[raw.stmt_location:]
        fragment=fragment.strip().rstrip(';')+';'
        statements.append(fragment)
        if isinstance(n,ast.CreateFunctionStmt):
            sig=signature(n);assert sig not in functions
            functions[sig]={'ddl':fragment,'node':n,'expected':header_from_ast(n)}
        if isinstance(n,ast.AlterTableStmt):
            rel=(n.relation.schemaname+'.'if n.relation.schemaname else'')+n.relation.relname
            constraints.setdefault(rel,[]).append(fragment)
    assert fences==1,(path,'sentinel count',fences)
    return {'text':text,'sha256':H(text),'statements':statements,'functions':functions,'constraints':constraints}

def aliases(x,path=()):
    out=[]
    if isinstance(x,dict):
        if isinstance(x.get('signature'),str)and'oid'in x:out.append((list(path),x))
        for k,v in x.items():out+=aliases(v,path+(k,))
    elif isinstance(x,list):
        for i,v in enumerate(x):out+=aliases(v,path+(str(i),))
    return out
def project_header(meta,shape):
    out={}
    for k,v in shape.items():
        key='returns'if k=='return'else k;assert key in meta,('unknown header field',k)
        value=meta[key]
        if k=='signature':value=v  # Same OID/ABI: retain public/unqualified spelling of this existing alias.
        if k=='oid':value=int(value)if isinstance(v,int)else str(value)
        out[k]=value
    return out
def bool_checks(x):return bool(x)and all(v is True for v in x.values())

def validate(a,t,source,port,source_plan,port_plan,ui,um,catalog,contract,recovery=False):
    row=a['root_row'];root=json.loads(row['canonical_preimage']);revision=row['revision_sha256']
    assert H(row['canonical_preimage'])==revision and H(pgtext(row))==a['root_row_sha256']
    assert row['state']=='enabled'and row['observed_revision_sha256']==revision and row['staff_guards_verified']and row['published_assets_verified']
    assert bool_checks(a['checks'])and a['profile']['authoring_enabled']and a['profile']['runtime_enabled']
    assert a['gates']['innata']['staff_enabled']and not a['gates']['innata']['public_enabled']
    assert t['root_revision']==revision
    assert len(source['functions'])==44 and len(port['functions'])==1
    assert set(source['functions']).isdisjoint(port['functions'])
    assert source['sha256']==source_plan['source_sha256']and port['sha256']==port_plan['source_sha256']
    assert H(Path(contract).read_bytes())==um['contract_sha256']and H(Path(catalog).read_bytes())==um['catalog_sha256']
    cat=read(catalog)['rows'];assert len(cat)==36 and len({x['technique_id']for x in cat})==36
    assert sum(x['mode']=='passive_permission'for x in cat)==27
    wanted=set(source['functions'])|set(port['functions']);targets={x['signature']:x for x in t['targets']};new={x['signature']:x for x in t['new_functions']}
    assert len(targets)==34 and len(new)==11 and set(targets)|set(new)==wanted
    if recovery:
        installed=root['db_core'][GROUP]
        assert len(installed)==45 and {x['signature']for x in installed.values()}==wanted
        for item in installed.values():
            candidate=(source['functions']|port['functions'])[item['signature']]['expected']
            assert all(item[k]==candidate[k]for k in ('source_md5','language','volatility','secdef','arg_names','arg_modes','arg_types','returns','config','strict','parallel','leakproof','kind'))
    if not recovery:
        assert all(x['oid']is None for x in new.values())
        for f in source_plan['changed_functions']:
            got=targets[f['signature']];old=f['baseline']
            assert got['source_md5']==old['prosrc_md5']and got['ddl_md5']==old['ddl_md5']
            assert got['owner']==old['owner']and got['acl']==old['acl']and got['config']==old['config']
        assert targets[port_plan['function']['signature']]['source_md5']==port_plan['function']['baseline_prosrc_md5']
    groups=['combat_innata_functions','editor_panel_functions','innata_staff_profile_functions','sp07_cost_guard_functions','sp08_rotation_probe_functions']
    oldset={str(v['oid'])for g in groups for v in root['db_core'][g].values()}
    observed={str(f['oid']):f for f in a['functions']};assert len(oldset)==92 and set(observed)==oldset
    for g in groups:
        for old in root['db_core'][g].values():assert project_header(observed[str(old['oid'])],old)==old
    assert len(root['db_core']['innata_staff_profile_functions'])==17
    assert len(root['db_core']['party_launch_functions'])==10 and len(root['db_core']['party_launch_relations'])==2
    assert len(a['custody'])==6
    rels={x['name']:x for x in t['relations']};assert set(CHECKS)<=set(rels)
    for r in a['staff_profile_relations']:assert rels[r['name']]==r
    for name,h in root['db_core']['combat_innata_relations'].items():assert H(pgtext(rels[name]))==h
    live=um['baseline'];assert H(Path(live['path']).read_bytes())==live['sha256']
    if not recovery:assert root['ui']['files']['land.html']['sha256']==live['sha256']
    assert H(Path(ui).read_bytes())==um['logical_assets']['land.html']['sha256']
    for name,v in um['logical_assets'].items():
        if name=='land.html':continue
        if not recovery:assert root['ui']['files'][name]['sha256']==v['sha256']and root['ui']['files'][name]['bytes']==v['bytes']
    return row,root,cat,targets,new,rels

def custody_expr():
    return "jsonb_build_object('contexts',(SELECT md5(coalesce(jsonb_agg(to_jsonb(cu_x)ORDER BY context_id),'[]'::jsonb)::text)FROM clan_innata_narrative_private.contexts_v1 cu_x),'states',(SELECT md5(coalesce(jsonb_agg(to_jsonb(cu_x)ORDER BY context_id,technique_id),'[]'::jsonb)::text)FROM clan_innata_narrative_private.states_v1 cu_x),'receipts',(SELECT md5(coalesce(jsonb_agg(to_jsonb(cu_x)ORDER BY to_jsonb(cu_x)::text),'[]'::jsonb)::text)FROM clan_innata_narrative_private.receipts_v1 cu_x),'scorta_master',(SELECT md5(to_jsonb(cu_s)::text)FROM public.master_v2_sessions cu_s WHERE id='93d78313-abde-4087-9eb7-7b96bc0fa089'),'scorta_mission',(SELECT md5(to_jsonb(cu_s)::text)FROM public.missions cu_s WHERE id='db1588ae-50f2-4c0e-9028-0b94155d94b1'),'PG',(SELECT jsonb_object_agg(name,md5((to_jsonb(cu_c)-'updated_at'-'last_regen_at')::text))FROM public.characters cu_c WHERE name IN('Riuji','Tamako','testperfunzioni')))"

def expected_constraint(rel,old,cat):
    target=CHECKS[rel];before=next(x for x in old['constraints']if x['name']==target)
    values=[x['profile_key']for x in cat]if'contexts_v1'in rel else['byakugan-l1/1','byakugan-l2/1','byakugan-l3/1','byakugan-l4/1','sharingan-l1/1','sharingan-l2/1','sharingan-l3/1','sharingan-l4/1']
    assert before['validated']is True
    assert len(re.findall(r'ARRAY\[[^\]]*\]',before['ddl']))==1
    after=re.sub(r'ARRAY\[[^\]]*\]','ARRAY['+', '.join(Q(x)+'::text'for x in values)+']',before['ddl'])
    return {'name':target,'ddl':after,'validated':True}

def require_review_reviews(reviews,receipts,inputs,template,um):
    if template:return {'state':'PENDING_REVIEW_AND_REAL_DEPLOY_RECEIPTS'}
    assert reviews and receipts
    assert reviews.get('result')in('PASS','PASS_STATIC','PASS_SOURCE_ONLY','PASS_MATERIAL')and all(reviews[k]==0 for k in('P0','P1','P2'))
    assert reviews['reviewed_inputs']==inputs
    git=receipts['git'];assert re.fullmatch('[0-9a-f]{40}',git['head'])and git['head']!='0'*40 and git['full_blob_readback']is True and git['branch_ref_readback']is True
    assert receipts['pages']['status']=='success'and receipts['pages']['commit_sha']==git['head']
    assert receipts['domain']['authenticated_Staff']is True
    assert receipts['domain']['build_marker']=='innata-all-clan-20261104-1'
    expected={name:{'sha256':v['sha256'],'bytes':v['bytes']}for name,v in um['logical_assets'].items()}
    assert git['files']==expected and receipts['domain']['assets']==expected
    assert receipts['domain']['module_pin']==um['logical_assets']['mission-generic-ui.mjs']['module_pin']
    assert receipts['domain']['commit_sha']==git['head']
    for k in('git','pages','domain'):
        proof=receipts[k]['proof'];assert H(Path(proof['path']).read_bytes())==proof['sha256']
    return {'review_ref':reviews['ref'],'review_sha256':H(J(reviews)),'git_head':git['head']}

def projection_sql(meta,shape):
    # Header shape/return spelling/OID representation are not normalized in stored Root aliases.
    pieces=[]
    for k,v in shape.items():
        key='returns'if k=='return'else k;value='('+meta+'->'+Q(key)+')'
        if k=='signature':value='to_jsonb('+Q(v)+'::text)'
        elif k=='oid'and isinstance(v,int):value='to_jsonb(('+meta+"->>'oid')::bigint)"
        elif k=='oid':value='to_jsonb('+meta+"->>'oid')"
        pieces.extend([Q(k),value])
    return 'jsonb_build_object('+','.join(pieces)+')'

def snapshot_query(table):
    assert re.fullmatch(r'[a-z_]+\.[a-z_0-9]+',table)
    return "(SELECT coalesce(jsonb_agg(to_jsonb(ac_q)ORDER BY to_jsonb(ac_q)::text),'[]'::jsonb)FROM "+table+' ac_q)'

def pre_checks(a,t,targets,new,root,rels,recovery=False):
    checks=[]
    def add(name,expr):checks.append((name,expr))
    row=a['root_row'];revision=row['revision_sha256']
    add('Root_fullrow_and_hash',"(SELECT to_jsonb(ac_r)="+D(row,'allc_root')+'::jsonb AND public.combat_v2_sha256(to_jsonb(ac_r))='+Q(a['root_row_sha256'])+' FROM mission_factory_owner.editor_release_readiness ac_r WHERE singleton)')
    fs={f['signature']:f for f in a['functions']}
    fs.update(targets);fs.update({x['signature']:x for x in t['dependencies']})
    for old in root['db_core']['party_launch_functions'].values():
        # Party uses the canonical FN_QUERY21-field shape in the actual Root.
        fs.setdefault(old['signature'],old)
    if recovery:fs.update({x['signature']:x for x in root['db_core'][GROUP].values()})
    for i,(sig,f)in enumerate(sorted(fs.items())):
        add('function:'+sig,'(SELECT to_jsonb(ac_m)='+D(f,'allc_fn_'+str(i))+'::jsonb FROM('+FN_QUERY(Q(sig))+')ac_m)')
    if not recovery:
        for sig in sorted(new):add('absent:'+sig,'to_regprocedure('+Q(sig)+')IS NULL')
    for i,(name,r)in enumerate(sorted(rels.items())):
        add('relation:'+name,'(SELECT to_jsonb(ac_m)='+D(r,'allc_rel_'+str(i))+'::jsonb FROM('+REL_QUERY(Q(name))+')ac_m)')
    for name,sha in root['db_core']['party_launch_relations'].items():
        add('party_relation:'+name,'public.combat_v2_sha256((SELECT to_jsonb(ac_m)FROM('+REL_QUERY(Q(name))+')ac_m))='+Q(sha))
    tables={'origin':('mission_public_owner.existing_publications_v1','request_key'),'capability':('mission_launch_owner.capabilities','mission_id'),'release':('mission_public_owner.release_admissions_v1','release_sha256'),'qualification':('mission_public_owner.public_qualification_attestations_v1','release_sha256')}
    for key,(table,col)in tables.items():add(key,'(SELECT to_jsonb(ac_row)FROM '+table+' ac_row WHERE '+col+'='+Q(a[key][col])+')='+D(a[key],'allc_'+key)+'::jsonb')
    gates={'innata':'clan_innata_narrative_private.gate_v1','facing':'combat_facing_private.release_gate','tactics':'combat_panel_private.multiplication_tactics_release_gate'}
    native={'eyes':'clan_hyuga_private.release_gate','sabaku':'clan_sabaku_private.release_gate','aburame':'clan_aburame_private.release_gate','inuzuka':'clan_inuzuka_private.release_gate','marionettisti':'clan_marionettisti_private.release_gate'}
    for key,table in gates.items():add('gate:'+key,'(SELECT to_jsonb(ac_g)FROM '+table+' ac_g WHERE singleton)='+D(a['gates'][key],'allc_gate_'+key)+'::jsonb')
    for key,table in native.items():add('native_gate:'+key,'(SELECT to_jsonb(ac_g)FROM '+table+' ac_g WHERE singleton)='+D(t['native_gates'][key],'allc_native_'+key)+'::jsonb')
    for i,(table,rows)in enumerate(sorted(t['config_tables'].items())):add('config:'+table,snapshot_query(table)+'='+D(rows,'allc_config_'+str(i))+'::jsonb')
    ids=[x['id']for x in t['catalog']]
    add('catalog36',"(SELECT jsonb_agg(to_jsonb(ac_t)ORDER BY ac_t.id)FROM public.clan_techniques ac_t WHERE ac_t.id=ANY(ARRAY["+','.join(Q(x)for x in ids)+']::uuid[]))='+D(t['catalog'],'allc_catalog_live')+'::jsonb')
    add('protected_custody',custody_expr()+'='+D(a['custody'],'allc_custody')+'::jsonb')
    add('profile',"mission_public_owner.engine_profile_state_v1("+Q(revision)+",'mission-ai-authoring/1')="+D(a['profile'],'allc_profile')+'::jsonb')
    add('content_admissions',"(SELECT coalesce(jsonb_agg(to_jsonb(ac_c)ORDER BY ac_c.publication_request),'[]'::jsonb)FROM mission_public_owner.mission_content_admissions_v1 ac_c WHERE engine_release_sha256="+Q(revision)+')='+D(a['content_admissions'],'allc_adoptions')+'::jsonb')
    return checks

def abi_guard(expected,old=None):
    # allc_pl_meta is the live canonical metadata read after CREATE; source SHA is not used as DDL SHA.
    keep=['source_md5','language','volatility','secdef','arg_names','arg_modes','arg_types','returns','config','strict','parallel','leakproof','kind']
    eq=' OR '.join("allc_pl_meta->"+Q(k)+' IS DISTINCT FROM '+D(expected.get(k),'allc_expected_'+k)+'::jsonb'for k in keep)
    out="IF allc_pl_meta->>'owner'IS DISTINCT FROM 'postgres'OR "+eq+" THEN RAISE EXCEPTION 'ALLCLAN_POST_SOURCE_ABI:%',allc_pl_signature;END IF;"
    if old:
        out+="IF(allc_pl_meta-ARRAY['source_md5','ddl_md5'])IS DISTINCT FROM("+D(old,'allc_before_'+H(old['signature'])[:12])+"::jsonb-ARRAY['source_md5','ddl_md5'])THEN RAISE EXCEPTION 'ALLCLAN_CHANGED_ABI:%',allc_pl_signature;END IF;"
    out+='IF(SELECT pronargdefaults FROM pg_proc WHERE oid=to_regprocedure(allc_pl_signature))<>'+str(expected['default_count'])+' OR(SELECT pg_get_expr(proargdefaults,0)FROM pg_proc WHERE oid=to_regprocedure(allc_pl_signature))IS DISTINCT FROM '+('NULL'if expected['defaults_expr']is None else Q(expected['defaults_expr']))+" THEN RAISE EXCEPTION 'ALLCLAN_DEFAULT_ABI:%',allc_pl_signature;END IF;"
    return out

def relation_post_sql(rels,cat,changed_sigs,recovery=False):
    out=[];changed_set=set(changed_sigs)
    for i,(name,old)in enumerate(sorted(rels.items())):
        tag='allc_rbefore_'+str(i);before=D(old,tag)+'::jsonb'
        out+=['SELECT to_jsonb(ac_m)INTO allc_pl_relation FROM('+REL_QUERY(Q(name))+')ac_m;',
         'IF(allc_pl_relation-ARRAY[\'constraints\',\'triggers\'])IS DISTINCT FROM('+before+"-ARRAY['constraints','triggers'])THEN RAISE EXCEPTION 'ALLCLAN_RELATION_ABI:%',"+Q(name)+';END IF;']
        expected_constraints=copy.deepcopy(old['constraints'])
        if name in CHECKS and not recovery:
            replacement=expected_constraint(name,old,cat)
            expected_constraints=[replacement if x['name']==replacement['name']else x for x in expected_constraints]
        out.append("IF allc_pl_relation->'constraints'IS DISTINCT FROM "+D(expected_constraints,'allc_constraints_'+str(i))+"::jsonb THEN RAISE EXCEPTION 'ALLCLAN_CONSTRAINT:%',"+Q(name)+';END IF;')
        # Every trigger keeps name/enabled/DDL. Only a changed callback's canonical DDL MD5 may differ.
        out.append("IF(SELECT coalesce(jsonb_agg(ac_tr-'function_md5'ORDER BY ac_tr->>'name'),'[]'::jsonb)FROM jsonb_array_elements(allc_pl_relation->'triggers')ac_tr)IS DISTINCT FROM "+D([{k:v for k,v in x.items()if k!='function_md5'}for x in old['triggers']],'allc_triggers_'+str(i))+"::jsonb THEN RAISE EXCEPTION 'ALLCLAN_TRIGGER_WIRING:%',"+Q(name)+';END IF;')
        for j,tr in enumerate(old['triggers']):
            out.append("SELECT md5(pg_get_functiondef(ac_t.tgfoid))INTO allc_pl_trigger_md5 FROM pg_trigger ac_t WHERE ac_t.tgrelid=to_regclass("+Q(name)+')AND ac_t.tgname='+Q(tr['name'])+'AND NOT ac_t.tgisinternal;')
            # Callback membership is checked by its actual regprocedure, not an inferred table index.
            out.append("SELECT ac_t.tgfoid::regprocedure::text INTO allc_pl_signature FROM pg_trigger ac_t WHERE ac_t.tgrelid=to_regclass("+Q(name)+')AND ac_t.tgname='+Q(tr['name'])+'AND NOT ac_t.tgisinternal;')
            out.append("IF allc_pl_headers?allc_pl_signature THEN IF allc_pl_trigger_md5 IS DISTINCT FROM(allc_pl_headers->allc_pl_signature->>'ddl_md5')THEN RAISE EXCEPTION 'ALLCLAN_CHANGED_CALLBACK';END IF;ELSE IF allc_pl_trigger_md5 IS DISTINCT FROM "+Q(tr['function_md5'])+"THEN RAISE EXCEPTION 'ALLCLAN_IMMUTABLE_CALLBACK';END IF;END IF;")
        out.append('allc_pl_relations:=allc_pl_relations||jsonb_build_object('+Q(name)+',public.combat_v2_sha256(allc_pl_relation));')
    return '\n'.join(out)

def recovery_functions(source):
    """Forward suspension; keep reads, clear, legacy, replay, sustain and cleanup."""
    output={}
    sig='public.clan_innata_staff_profile_set_v2(uuid,uuid,text,uuid,bigint)'
    f=source['functions'][sig];s=f['ddl'];anchor=' IF p_profile_key IS NOT NULL THEN\n'
    assert s.count(anchor)==1
    guard=" IF p_profile_key IS NOT NULL AND p_profile_key NOT IN("+','.join(Q(x)for x in LEGACY)+")THEN RAISE EXCEPTION 'INNATA_ALL_NEW_SELECTION_SUSPENDED' USING ERRCODE='55000';END IF;\n"
    s=s.replace(anchor,guard+anchor,1);output[sig]=s
    sig='clan_innata_narrative_private.activate_v1(uuid,uuid,uuid,uuid,uuid)';f=source['functions'][sig];s=f['ddl']
    anchor=' scope:=clan_innata_narrative_private.scope_v1(p_location,p_master_session,a.id);';assert s.count(anchor)==1
    s=s.replace(anchor," IF p_technique_id IN("+','.join(Q(x)+'::uuid'for x in SHARINGAN)+")THEN RAISE EXCEPTION 'INNATA_ALL_NEW_ACTIVATION_SUSPENDED' USING ERRCODE='55000';END IF;\n"+anchor,1);output[sig]=s
    sig='clan_innata_private.combat_transition(uuid,uuid,text,uuid,bigint)';f=source['functions'][sig];s=f['ddl']
    anchor=" IF p_operation='deactivate'AND a.actor_kind='png'THEN\n  SELECT * INTO STRICT s";assert s.count(anchor)==1
    s=s.replace(anchor," IF p_operation='activate'AND t IN("+','.join(Q(x)+'::uuid'for x in SHARINGAN)+")THEN RAISE EXCEPTION 'INNATA_ALL_NEW_ACTIVATION_SUSPENDED' USING ERRCODE='55000';END IF;\n"+anchor,1);output[sig]=s
    for sig,ddl in output.items():
        old=source['functions'][sig]['ddl'];assert 'RETURN' in old
        # Replay still precedes suspension, and OFF/upkeep have no new rejection.
        assert ddl.index("'replayed',true")<ddl.index("SUSPENDED'")
        parse_sql(ddl)
    return {sig:{'ddl':ddl,'node':parse_sql(ddl)[0].stmt,'expected':header_from_ast(parse_sql(ddl)[0].stmt)}for sig,ddl in output.items()}

def post_configs(t,cat,recovery=False):
    if recovery:return copy.deepcopy(t['config_tables'])
    rows=copy.deepcopy(t['config_tables'])
    for d in cat:
        if d['family']!='sharingan'or d['tier']<2:continue
        pre={'technique_id':d['technique_id'],'config_version':1,'activation_cost':d['activation_cost'],'upkeep_cost':d['upkeep_cost']};seal=H(pgtext(pre))
        values={
         'clan_innata_private.config_versions':pre|{'editorial_seal':seal,'reviewed':True,'active':True},
         'clan_innata_private.editorial_approvals':{'technique_id':d['technique_id'],'config_version':1,'approval_sha256':seal,'canonical_preimage':pre,'approved':True},
         'clan_innata_narrative_private.config_quotes_v1':pre|{'source_kind':'canonical_config','source_preimage':pre,'source_sha256':seal}}
        for table,v in values.items():
            old=[x for x in rows[table]if x['technique_id']==d['technique_id']and x['config_version']==1]
            assert not old or old==[v]
            if not old:rows[table].append(v)
    return rows

def emitted_capsules(sql):
    # Parse top-level DO body first: no regex can correctly inspect nested dollar-quoted source functions.
    out={}
    for m in re.finditer(r'\$([A-Za-z_][A-Za-z_0-9]*)\$',sql):
        label=m[1]
        if label.startswith('allc_data_'):
            end=sql.find('$'+label+'$',m.end())
            if end>=0:out.setdefault(label,sql[m.end():end])
    return out

def emit(a,t,source,port,source_plan,port_plan,ui,um,catalog,contract,reviews,receipts,out,template=True,recovery=False,input_files=None):
    row,root,cat,targets,new,rels=validate(a,t,source,port,source_plan,port_plan,ui,um,catalog,contract,recovery)
    inputs={'source':source['sha256'],'port':port['sha256'],'UI':H(Path(ui).read_bytes()),'UI_manifest':input_files['UI_manifest'],'contract':H(Path(contract).read_bytes()),'catalog':H(Path(catalog).read_bytes())}
    inputs.update(input_files)
    inputs['composer']=H(Path(__file__).read_bytes());inputs['pure_library']=H(LIBPATH.read_bytes())
    proof=require_review_reviews(reviews,receipts,inputs,template,um)
    definitions=recovery_functions(source)if recovery else source['functions']|port['functions']
    statements=[x['ddl']for x in definitions.values()]if recovery else source['statements']+port['statements']
    before_headers=dict(targets)
    if recovery:before_headers.update({x['signature']:x for x in root['db_core'][GROUP].values()})
    changed_sigs=set(definitions)
    checks=pre_checks(a,t,targets,new,root,rels,recovery)
    pf='WITH checks(name,ok)AS(\n'+'\nUNION ALL\n'.join('SELECT '+Q(n)+'::text,coalesce(('+e+'),false)'for n,e in checks)+"\n)SELECT jsonb_build_object('total',count(*),'passed',count(*)FILTER(WHERE ok),'all_ok',bool_and(ok),'failed',jsonb_agg(name)FILTER(WHERE NOT ok))AS preflight FROM checks;\n"
    identity={'schema_version':'innata-all-clan-cutover/2','operation':'SUSPEND_NEW_INGRESS_FORWARD'if recovery else'INSTALL_RESERVED_STAFF',
     'parent_release':row['revision_sha256'],'inputs':inputs,'review_and_deploy_binding':proof,'runtime':'NOT_RUN','provider_calls':0,'new_world_open':False,
     'source_semantics':{'catalog36':36,'passive_permission':27,'maintained':9,'resource_engines_added':0},
     'recovery_scope':'only fresh set2 nonlegacy selections and fresh3Sharingan activations; existing reads/permits/ON/upkeep/OFF/clear/replay/carry remain'if recovery else'forward suspension, never oldRoot or data reset'}
    decl='''DECLARE
 allc_pl_before mission_factory_owner.editor_release_readiness;
 allc_pl_db jsonb;allc_pl_root jsonb;allc_pl_ui jsonb;allc_pl_config jsonb;allc_pl_identity jsonb;
 allc_pl_headers jsonb:='{}'::jsonb;allc_pl_relations jsonb:='{}'::jsonb;allc_pl_group jsonb:='{}'::jsonb;
 allc_pl_meta jsonb;allc_pl_old jsonb;allc_pl_header jsonb;allc_pl_item jsonb;allc_pl_key text;allc_pl_value jsonb;
 allc_pl_path text[];allc_pl_signature text;allc_pl_relation jsonb;allc_pl_trigger_md5 text;
 allc_pl_text text;allc_pl_revision text;allc_pl_binding jsonb;allc_pl_qualification jsonb;allc_pl_certificate jsonb;
 allc_pl_request uuid;allc_pl_sessions jsonb;allc_pl_session jsonb;
BEGIN
'''
    sql=['-- SOURCE REVIEW MATERIAL; generated locally only. Single atomic Root cutover.','BEGIN;','DO $allc_cutover$',decl]
    sql.append("IF current_user<>'postgres'OR session_user<>'postgres'OR auth.uid()IS NOT NULL THEN RAISE EXCEPTION 'ALLCLAN_OPERATOR_REQUIRED';END IF;IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'ALLCLAN_RELEASE_BUSY';END IF;SELECT * INTO STRICT allc_pl_before FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;")
    for name,expr in checks:sql.append('IF NOT coalesce(('+expr+"),false)THEN RAISE EXCEPTION 'ALLCLAN_PRE_DRIFT:%',"+Q(name)+';END IF;')
    if template:sql.append("RAISE EXCEPTION 'INNATA_ALL_CLAN_TEMPLATE_REQUIRES_REAL_RECEIPTS_AND_FINAL_REVIEW';")
    sql.append("IF nullif(current_setting('app.innata_all_clan_material_review_ref',true),'')IS NULL OR coalesce(current_setting('app.innata_all_clan_material_review_sha256',true),'')!~'^[0-9a-f]{64}$'THEN RAISE EXCEPTION 'ALLCLAN_MATERIAL_REVIEW_REQUIRED';END IF;")
    if recovery:
        # Advisory/location locks serialize profile/role writers; session NOWAIT leaves active cleanup intact.
        # The operator certifies a quiet command boundary; in-flight accepted work is not cancelled or refunded.
        sql.append("IF nullif(current_setting('app.innata_all_clan_recovery_quiescent_ref',true),'')IS NULL THEN RAISE EXCEPTION 'ALLCLAN_RECOVERY_QUIET_BOUNDARY_REQUIRED';END IF;PERFORM 1 FROM public.locations WHERE id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid FOR UPDATE NOWAIT;PERFORM 1 FROM public.combat_v2_sessions ac_lock WHERE ac_lock.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND ac_lock.closed_at IS NULL ORDER BY ac_lock.id FOR UPDATE NOWAIT;")
    sql.append("SELECT coalesce(jsonb_agg(jsonb_build_object('session_id',ac_ad.master_session_id,'admission',to_jsonb(ac_ad))ORDER BY ac_ad.master_session_id),'[]'::jsonb)INTO allc_pl_sessions FROM mission_public_owner.session_admissions_v1 ac_ad WHERE mission_public_owner.role_session_allowed_v1(ac_ad.master_session_id);")
    for i,stmt in enumerate(statements):sql.append('EXECUTE '+opaque(stmt,'allc_ddl_'+str(i))+';')
    for i,(sig,f)in enumerate(definitions.items()):
        sql.append('allc_pl_signature:='+Q(sig)+';SELECT to_jsonb(ac_m)INTO allc_pl_meta FROM('+FN_QUERY('allc_pl_signature')+')ac_m;')
        sql.append(abi_guard(f['expected'],before_headers.get(sig)))
        if sig not in before_headers:
            roles=['authenticated','postgres']if sig.startswith('public.')else['postgres']
            sql.append("IF(SELECT coalesce(jsonb_agg(ac_role.rolname ORDER BY ac_role.rolname),'[]'::jsonb)FROM aclexplode(coalesce((SELECT proacl FROM pg_proc WHERE oid=to_regprocedure(allc_pl_signature)),acldefault('f','postgres'::regrole)))ac_acl LEFT JOIN pg_roles ac_role ON ac_role.oid=ac_acl.grantee WHERE ac_acl.privilege_type='EXECUTE')IS DISTINCT FROM "+D(roles,'allc_new_roles_'+str(i))+"::jsonb THEN RAISE EXCEPTION 'ALLCLAN_NEW_ACL:%',allc_pl_signature;END IF;")
        if sig not in before_headers:
            sql.append("IF EXISTS(SELECT 1 FROM aclexplode(coalesce((SELECT proacl FROM pg_proc WHERE oid=to_regprocedure(allc_pl_signature)),acldefault('f','postgres'::regrole)))ac_acl WHERE ac_acl.grantor<>'postgres'::regrole OR ac_acl.is_grantable)THEN RAISE EXCEPTION 'ALLCLAN_NEW_ACL_DELEGATION:%',allc_pl_signature;END IF;")
        sql.append('allc_pl_headers:=allc_pl_headers||jsonb_build_object(allc_pl_signature,allc_pl_meta);')
    sql.append('allc_pl_db:=(allc_pl_before.canonical_preimage::jsonb)->\'db_core\';')
    # Update only existing aliases of changed functions. Never append entries to an old fixed header group.
    changed_by_oid={str(before_headers[sig]['oid']):sig for sig in changed_sigs if sig in before_headers}
    affected=[{'path':path,'header':header,'canonical_signature':changed_by_oid[str(header['oid'])]}for path,header in aliases(root['db_core'])if str(header['oid'])in changed_by_oid]
    for i,item in enumerate(affected):
        header=item['header'];sig=item['canonical_signature'];expr=projection_sql("(allc_pl_headers->"+Q(sig)+')',header)
        path='ARRAY['+','.join(Q(x)for x in item['path'])+']::text[]'
        sql.append('allc_pl_db:=jsonb_set(allc_pl_db,'+path+','+expr+',false);')
    # Preserve the existing45 group on recovery, replacing only its3 changed entries.
    if recovery:sql.append("allc_pl_group:=allc_pl_db->'"+GROUP+"';")
    sql.append("FOR allc_pl_signature,allc_pl_meta IN SELECT ac_e.key,ac_e.value FROM jsonb_each(allc_pl_headers)ac_e LOOP allc_pl_group:=allc_pl_group||jsonb_build_object(allc_pl_meta->>'oid',allc_pl_meta);END LOOP;")
    sql.append("IF(SELECT count(*)FROM jsonb_object_keys(allc_pl_group))<>45 THEN RAISE EXCEPTION 'ALLCLAN_GROUP45_CARDINALITY';END IF;allc_pl_db:=jsonb_set(allc_pl_db,'{"+GROUP+"}',allc_pl_group,true);")
    sql.append(relation_post_sql(rels,cat,changed_sigs,recovery))
    for name in root['db_core']['combat_innata_relations']:
        sql.append("allc_pl_db:=jsonb_set(allc_pl_db,ARRAY['combat_innata_relations',"+Q(name)+"],allc_pl_relations->"+Q(name)+',false);')
    sql.append("allc_pl_db:=jsonb_set(allc_pl_db,'{innata_all_clan_relations}',allc_pl_relations,true);")
    for i,(table,rows)in enumerate(sorted(post_configs(t,cat,recovery).items())):
        expected=sorted(rows,key=lambda x:(x['technique_id'],x['config_version']))
        expr="(SELECT coalesce(jsonb_agg(to_jsonb(ac_q)ORDER BY ac_q.technique_id,ac_q.config_version),'[]'::jsonb)FROM "+table+' ac_q)'
        sql.append('IF '+expr+'IS DISTINCT FROM '+D(expected,'allc_post_config_'+str(i))+"::jsonb THEN RAISE EXCEPTION 'ALLCLAN_CONFIG_APPEND_ONLY';END IF;")
    sql.append("IF allc_pl_db->'party_launch_functions'IS DISTINCT FROM(allc_pl_before.canonical_preimage::jsonb#>'{db_core,party_launch_functions}')OR allc_pl_db->'party_launch_relations'IS DISTINCT FROM(allc_pl_before.canonical_preimage::jsonb#>'{db_core,party_launch_relations}')THEN RAISE EXCEPTION 'ALLCLAN_PARTY_DRIFT';END IF;allc_pl_db:=jsonb_set(allc_pl_db,'{sha256}',to_jsonb(public.combat_v2_sha256(allc_pl_db-'sha256')),false);")
    sql.append('allc_pl_identity:='+D(identity,'allc_data_identity')+'::jsonb;allc_pl_root:=jsonb_set(allc_pl_before.canonical_preimage::jsonb,\'{db_core}\',allc_pl_db,false);allc_pl_ui:=allc_pl_root->\'ui\';')
    if not recovery:
        land=um['logical_assets']['land.html'];head=receipts['git']['head']if receipts else'0'*40
        sql.append("allc_pl_ui:=jsonb_set(allc_pl_ui,'{files,land.html}',"+D({'sha256':land['sha256'],'bytes':land['bytes']},'allc_ui_land')+"::jsonb,false);allc_pl_ui:=jsonb_set(allc_pl_ui,'{git_head}',to_jsonb("+Q(head)+"::text),false);allc_pl_ui:=allc_pl_ui||jsonb_build_object('innata_all_clan_graph',jsonb_build_object('schema_version','innata-all-clan-ui-graph/2','parent_graph_sha256',allc_pl_ui->>'import_graph_sha256','land_sha256',"+Q(land['sha256'])+",'GenericUI_sha256',"+Q(um['logical_assets']['mission-generic-ui.mjs']['sha256'])+"));allc_pl_ui:=jsonb_set(allc_pl_ui,'{import_graph_sha256}',to_jsonb(public.combat_v2_sha256(allc_pl_ui->'innata_all_clan_graph')),false);")
    sql.append("allc_pl_config:=(allc_pl_root->'config')||jsonb_build_object("+Q('innata_all_clan_recovery'if recovery else'innata_all_clan')+",allc_pl_identity);allc_pl_config:=jsonb_set(allc_pl_config,'{sha256}',to_jsonb(public.combat_v2_sha256(allc_pl_config-'sha256')),false);allc_pl_root:=jsonb_set(jsonb_set(allc_pl_root,'{ui}',allc_pl_ui,false),'{config}',allc_pl_config,false);allc_pl_root:=jsonb_set(allc_pl_root,'{contract,code_identity_sha256}',to_jsonb(public.combat_v2_sha256(allc_pl_identity)),false);allc_pl_root:=jsonb_set(allc_pl_root,'{recovery,semantic_identity_sha256}',to_jsonb(public.combat_v2_sha256(allc_pl_identity)),false);")
    sql.append("IF allc_pl_root->'edge_bundles'IS DISTINCT FROM(allc_pl_before.canonical_preimage::jsonb)->'edge_bundles'OR allc_pl_root#>'{config,combat_innata}'IS DISTINCT FROM allc_pl_before.canonical_preimage::jsonb#>'{config,combat_innata}'OR allc_pl_root#>'{config,c1266_opening}'IS DISTINCT FROM allc_pl_before.canonical_preimage::jsonb#>'{config,c1266_opening}'OR((allc_pl_ui->'files')-'land.html')IS DISTINCT FROM((allc_pl_before.canonical_preimage::jsonb#>'{ui,files}')-'land.html')THEN RAISE EXCEPTION 'ALLCLAN_UNRELATED_ROOT_MUTATION';END IF;allc_pl_text:=allc_pl_root::text;IF octet_length(allc_pl_text)>524288 THEN RAISE EXCEPTION 'ALLCLAN_ROOT_SIZE';END IF;allc_pl_revision:=encode(extensions.digest(convert_to(allc_pl_text,'UTF8'),'sha256'),'hex');UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=allc_pl_text,revision_sha256=allc_pl_revision,observed_revision_sha256=allc_pl_revision,client_build='mission-factory-admin/2:'||allc_pl_revision,independent_review_ref=current_setting('app.innata_all_clan_material_review_ref',true),published_assets_verified=true,updated_at=clock_timestamp()WHERE singleton;")
    sql+=adopt_sql(a)
    # Postflight function/gate/custody checks come after adoption, still inside the transaction.
    post_untouched={f['signature']:f for f in a['functions']}
    post_untouched.update({f['signature']:f for f in t['dependencies']})
    post_untouched.update({f['signature']:f for f in root['db_core']['party_launch_functions'].values()})
    for f in post_untouched.values():
        if f['signature']not in changed_sigs:
            sql.append('IF(SELECT to_jsonb(ac_m)FROM('+FN_QUERY(Q(f['signature']))+')ac_m)IS DISTINCT FROM '+D(f,'allc_post_old_'+str(f['oid']))+"::jsonb THEN RAISE EXCEPTION 'ALLCLAN_OLD_FUNCTION_DRIFT';END IF;")
    sql.append("FOR allc_pl_meta IN SELECT value FROM jsonb_each(allc_pl_group)LOOP SELECT to_jsonb(ac_m)INTO allc_pl_header FROM("+FN_QUERY("allc_pl_meta->>'signature'")+")ac_m;IF allc_pl_header IS DISTINCT FROM allc_pl_meta THEN RAISE EXCEPTION 'ALLCLAN_GROUP45_POST_DRIFT';END IF;END LOOP;")
    sql.append('IF NOT coalesce(('+custody_expr()+'='+D(a['custody'],'allc_post_custody')+"::jsonb),false)THEN RAISE EXCEPTION 'ALLCLAN_POST_CUSTODY';END IF;")
    for name,expr in checks:
        if name.startswith(('gate:','native_gate:','party_relation:'))or name=='catalog36':sql.append('IF NOT coalesce(('+expr+"),false)THEN RAISE EXCEPTION 'ALLCLAN_POST_INVARIANT:%',"+Q(name)+';END IF;')
    sql.append("FOR allc_pl_session IN SELECT value FROM jsonb_array_elements(allc_pl_sessions)LOOP IF NOT mission_public_owner.role_session_allowed_v1((allc_pl_session->>'session_id')::uuid)OR allc_pl_session->'admission'IS DISTINCT FROM(SELECT to_jsonb(ac_a)FROM mission_public_owner.session_admissions_v1 ac_a WHERE ac_a.master_session_id=(allc_pl_session->>'session_id')::uuid)THEN RAISE EXCEPTION 'ALLCLAN_SESSION_CONTINUITY';END IF;END LOOP;RAISE NOTICE 'INNATA_ALL_CLAN_ROOT:%',allc_pl_revision;END $allc_cutover$;COMMIT;\n")
    text='\n'.join(sql);parse_sql(text);parse_sql(pf)
    parse_plpgsql(text.replace('allc_pl_before mission_factory_owner.editor_release_readiness','allc_pl_before record'))
    out=Path(out);out.mkdir(parents=True,exist_ok=True)
    basename=('RECOVERY_TEMPLATE.sql'if template else'RECOVERY.sql')if recovery else('INSTALL_TEMPLATE.sql'if template else'INSTALL.sql')
    (out/basename).write_text(text);(out/('RECOVERY_PREFLIGHT.sql'if recovery else'PREFLIGHT.sql')).write_text(pf)
    if not recovery:
        rec=recovery_functions(source)
        recovery_text="-- FORWARD RECOVERY SOURCE ONLY; compose with a fresh installed Root/group45 capture.\nDO $allc_recovery_not_installable$BEGIN RAISE EXCEPTION 'INNATA_ALL_RECOVERY_FRESH_ROOT_COMPOSITION_REQUIRED';END $allc_recovery_not_installable$;\nBEGIN;\n"+'\n'.join(f['ddl']for f in rec.values())+'\nCOMMIT;\n'
        parse_sql(recovery_text);(out/'RECOVERY_FORWARD_SOURCE.sql').write_text(recovery_text)
    postflight_checks=None
    if not recovery:
        postflight_text,postflight_checks=emit_postflight(a,t,source,port,source_plan,port_plan,ui,um,catalog,contract,input_files,receipts)
        (out/'POSTFLIGHT.sql').write_text(postflight_text)
    manifest={'schema_version':'innata-all-clan-root-contribution/2','status':'TEMPLATE_ABORTS_REVIEW_REQUIRED'if template else'BOUND_MATERIAL_STILL_REQUIRES_FINAL_REVIEW','parent_root':row['revision_sha256'],'inputs':inputs,'mode':'recovery_forward'if recovery else'install_staff','target_function_count':45,'emitted_function_DDL':len(definitions),'source_statement_count':len(statements),'old92_untouched_except_targets':True,'all_alias_paths_updated':len(affected),'relation_fingerprints_by_name':sorted(rels),'new_columns':0,'new_tables':0,'changed_checks':0 if recovery else 2,'config_append_max':0 if recovery else 9,'Party10_2_preserved':True,'runtime':'NOT_RUN','review':'REQUIRED','pure_library_sha256':H(LIBPATH.read_bytes()),'outputs':{basename:{'sha256':H(text),'bytes':len(text.encode())}}}
    if not recovery:
        manifest['postflight_checks']=postflight_checks
        manifest['outputs']['POSTFLIGHT.sql']={'sha256':H(postflight_text),'bytes':len(postflight_text.encode())}
    manifest['Root_contribution_provenance']={'base_composer_sha256':'3e712e8861aa5a85636018eb1a2aa8d4c381962e1af46938b510167b7582a041','postflight_helper_sha256':'8e8a4b893e75f82d4921b05fe40507402450cef0ad1b66aef0cbf0a1ef14bdaa','Root_delta':'embed readonly postflight and bind composer/library in reviewed_inputs before aggregate freeze'}
    (out/'CONTRIBUTION_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
    return manifest

def adopt_sql(a):
    ar=a['release'];aq=a['qualification'];s=[]
    s.append("allc_pl_binding:=jsonb_build_object('db_sha256',allc_pl_root#>>'{db_core,sha256}','edge_sha256',"+Q(ar['edge_sha256'])+",'client_sha256',public.combat_v2_sha256(allc_pl_ui),'configuration_sha256',allc_pl_root#>>'{config,sha256}');INSERT INTO mission_public_owner.release_admissions_v1(release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)VALUES(allc_pl_revision,allc_pl_binding->>'db_sha256',allc_pl_binding->>'edge_sha256',allc_pl_binding->>'client_sha256',allc_pl_binding->>'configuration_sha256','mission-public-admission/1',current_setting('app.innata_all_clan_material_review_ref',true),"+Q(ar['staff_evidence_ref'])+",clock_timestamp(),true);INSERT INTO mission_public_owner.engine_profile_events_v1(event_id,engine_release_sha256,profile_key,expected_control_version,control_version,authoring_enabled,runtime_enabled,reason)VALUES(extensions.uuid_generate_v5('3ff627ec-dbee-423a-9879-8e37f7ad5510',allc_pl_revision||':profile:1'),allc_pl_revision,'mission-ai-authoring/1',0,1,true,true,'All-clan Staff-only forward delta; existing public authoring/runtime unchanged, no new World Innata qualification');")
    s.append('allc_pl_qualification:='+D(aq['payload'],'allc_data_qualification')+"::jsonb;allc_pl_qualification:=allc_pl_qualification||jsonb_build_object('revision_sha256',allc_pl_revision,'bindings',allc_pl_binding,'independent_review',jsonb_build_object('ref',current_setting('app.innata_all_clan_material_review_ref',true),'sha256',current_setting('app.innata_all_clan_material_review_sha256',true),'P0',0,'P1',0,'P2',0));INSERT INTO mission_public_owner.public_qualification_attestations_v1(release_sha256,request_key,payload,payload_sha256,positive_staff_evidence_ref,authorized_test_manifest_ref,created_by)VALUES(allc_pl_revision,extensions.uuid_generate_v5('3ff627ec-dbee-423a-9879-8e37f7ad5510',allc_pl_revision||':qualification'),allc_pl_qualification,mission_factory_owner.sha(allc_pl_qualification),"+Q(aq['positive_staff_evidence_ref'])+','+Q(aq['authorized_test_manifest_ref'])+','+Q(aq['created_by'])+");IF mission_public_owner.engine_qualification_v1(allc_pl_revision,true)IS NULL THEN RAISE EXCEPTION 'ALLCLAN_EXISTING_ENGINE_QUALIFICATION';END IF;")
    for i,c in enumerate(a['content_admissions']):
        s.append('allc_pl_certificate:='+D(c['payload'],'allc_data_certificate_'+str(i))+"::jsonb;allc_pl_request:=extensions.uuid_generate_v5("+Q(c['publication_request'])+"::uuid,allc_pl_revision||':content-adoption');allc_pl_certificate:=allc_pl_certificate||jsonb_build_object('request_key',allc_pl_request,'engine_release_sha256',allc_pl_revision,'created_at',clock_timestamp());INSERT INTO mission_public_owner.mission_content_admissions_v1(request_key,mission_id,config_version,engine_release_sha256,publication_request,payload,payload_sha256)VALUES(allc_pl_request,"+Q(c['mission_id'])+'::uuid,'+str(int(c['config_version']))+',allc_pl_revision,'+Q(c['publication_request'])+"::uuid,allc_pl_certificate,mission_factory_owner.sha(allc_pl_certificate));IF mission_public_owner.content_admission_v1("+Q(c['mission_id'])+'::uuid,allc_pl_revision,'+Q(c['publication_request'])+"::uuid,true)IS NULL THEN RAISE EXCEPTION 'ALLCLAN_EXISTING_ADOPTION';END IF;")
    return s

def emit_postflight(actual, targets, source, port, plan, portplan, ui, um, catalog, contract, input_files, receipts=None):
    (row, oldroot, cat, olds, new, rels) = validate(actual, targets, source, port, plan, portplan, ui, um, catalog, contract)
    fs = source['functions'] | port['functions']
    changed = set(fs)
    before_by_oid = {str(x['oid']): x for x in targets['targets']}
    inputs = {'source': source['sha256'], 'port': port['sha256'], 'UI': H(Path(ui).read_bytes()), 'contract': H(Path(contract).read_bytes()), 'catalog': H(Path(catalog).read_bytes())} | input_files
    inputs['composer'] = H(Path(__file__).read_bytes())
    inputs['pure_library'] = H(LIBPATH.read_bytes())
    checks = []

    def add(name, expr):
        checks.append((name, expr))
    body = 'pf_r.body'
    rev = "pf_r.row->>'revision_sha256'"
    group = "pf_r.body#>'{db_core," + GROUP + "}'"

    def root_header(sig):
        return '(SELECT pf_g.value FROM jsonb_each(' + group + ")pf_g WHERE pf_g.value->>'signature'=" + Q(sig) + ')'
    add('AFTER_INSTALL_ONLY', rev + '<>' + Q(row['revision_sha256']) + " AND pf_r.body#>>'{config,innata_all_clan,parent_release}'=" + Q(row['revision_sha256']))
    add('Root_enabled_hash_observed', "pf_r.row->>'state'='enabled' AND(pf_r.row->>'staff_guards_verified')::boolean AND(pf_r.row->>'published_assets_verified')::boolean AND pf_r.row->>'observed_revision_sha256'=" + rev + " AND encode(extensions.digest(convert_to(pf_r.row->>'canonical_preimage','UTF8'),'sha256'),'hex')=" + rev + " AND pf_r.row->>'client_build'='mission-factory-admin/2:'||" + rev)
    add('Root_inputs_exact', "pf_r.body#>'{config,innata_all_clan,inputs}'=" + D(inputs, 'allp_inputs') + '::jsonb')
    add('Root_staff_only_semantics', "pf_r.body#>>'{config,innata_all_clan,operation}'='INSTALL_RESERVED_STAFF'AND pf_r.body#>'{config,innata_all_clan,new_world_open}'='false'::jsonb AND pf_r.body#>>'{config,innata_all_clan,runtime}'='NOT_RUN'")
    add('Root_internal_digests', "pf_r.body#>>'{db_core,sha256}'=public.combat_v2_sha256((pf_r.body->'db_core')-'sha256')AND pf_r.body#>>'{config,sha256}'=public.combat_v2_sha256((pf_r.body->'config')-'sha256')AND pf_r.body#>>'{contract,code_identity_sha256}'=public.combat_v2_sha256(pf_r.body#>'{config,innata_all_clan}')AND pf_r.body#>>'{recovery,semantic_identity_sha256}'=public.combat_v2_sha256(pf_r.body#>'{config,innata_all_clan}')")
    add('Root_other_families_exact', "pf_r.body->'edge_bundles'=" + D(oldroot['edge_bundles'], 'allp_edges') + "::jsonb AND pf_r.body#>'{config,combat_innata}'=" + D(oldroot['config']['combat_innata'], 'allp_combat') + "::jsonb AND pf_r.body#>'{config,c1266_opening}'=" + D(oldroot['config']['c1266_opening'], 'allp_opening') + '::jsonb')
    add('group45_shape', 'jsonb_typeof(' + group + ")='object'AND(SELECT count(*)FROM jsonb_each(" + group + "))=45 AND(SELECT jsonb_agg(pf_g.value->>'signature'ORDER BY pf_g.value->>'signature')FROM jsonb_each(" + group + ')pf_g)=' + D(sorted(fs), 'allp_signatures') + '::jsonb')
    keep = ['source_md5', 'language', 'volatility', 'secdef', 'arg_names', 'arg_modes', 'arg_types', 'returns', 'config', 'strict', 'parallel', 'leakproof', 'kind']
    for (i, (sig, f)) in enumerate(fs.items()):
        ref = root_header(sig)
        live = '(SELECT pf_f.meta FROM pf_function_live pf_f WHERE pf_f.signature=' + Q(sig) + ')'
        e = f['expected']
        add('live_Root_header:' + sig, live + '=' + ref)
        add('Source_ABI:' + sig, ' AND '.join(('(' + live + '->' + Q(k) + ')=' + D(e[k], 'allp_expected_' + str(i) + '_' + k) + '::jsonb' for k in keep)))
        add('defaults:' + sig, '(SELECT pronargdefaults=' + str(e['default_count']) + ' AND pg_get_expr(proargdefaults,0)IS NOT DISTINCT FROM ' + ('NULL' if e['defaults_expr'] is None else Q(e['defaults_expr'])) + ' FROM pg_proc WHERE oid=to_regprocedure(' + Q(sig) + '))')
        if sig in olds:
            old = olds[sig]
            add('ABI_ACL_baseline:' + sig, '(' + live + "-ARRAY['source_md5','ddl_md5'])=" + '(' + D(old, 'allp_old_' + str(i)) + "::jsonb-ARRAY['source_md5','ddl_md5'])")
        else:
            roles = ['authenticated', 'postgres'] if sig.startswith('public.') else ['postgres']
            add('new_ACL:' + sig, "(SELECT coalesce(jsonb_agg(pf_role.rolname ORDER BY pf_role.rolname),'[]'::jsonb)=" + D(roles, 'allp_roles_' + str(i)) + "::jsonb AND bool_and(pf_acl.grantor='postgres'::regrole AND NOT pf_acl.is_grantable)FROM aclexplode(coalesce((SELECT proacl FROM pg_proc WHERE oid=to_regprocedure(" + Q(sig) + ")),acldefault('f','postgres'::regrole)))pf_acl LEFT JOIN pg_roles pf_role ON pf_role.oid=pf_acl.grantee WHERE pf_acl.privilege_type='EXECUTE')")
    oldids = sorted((str(x['oid']) for x in actual['functions']))
    add('function_union_OID', '(SELECT count(DISTINCT pf_id)FROM(SELECT jsonb_array_elements_text(' + D(oldids, 'allp_old_ids') + "::jsonb)pf_id UNION SELECT pf_g.value->>'oid'FROM jsonb_each(" + group + ')pf_g)pf_u)=(SELECT count(*)FROM jsonb_array_elements(' + D(oldids, 'allp_old_ids_count') + '::jsonb))+(SELECT count(*)FROM jsonb_each(' + group + ')pf_g WHERE NOT(' + D(oldids, 'allp_old_ids_members') + "::jsonb? (pf_g.value->>'oid')))")
    for (path, header) in aliases(oldroot['db_core']):
        oid = str(header['oid'])
        sig = before_by_oid.get(oid, {}).get('signature')
        expression = projection_sql(root_header(sig), header) if sig else D(header, 'allp_alias_' + H(J(path))[:16]) + '::jsonb'
        add('Root_alias:' + '/'.join(path), "pf_r.body#>ARRAY['db_core'," + ','.join((Q(x) for x in path)) + ']=' + expression)
    unchanged = {x['signature']: x for x in actual['functions'] if x['signature'] not in changed}
    unchanged.update({x['signature']: x for x in targets['dependencies'] if x['signature'] not in changed})
    unchanged.update({x['signature']: x for x in oldroot['db_core']['party_launch_functions'].values()})
    for (i, (sig, f)) in enumerate(unchanged.items()):
        add('old_live:' + sig, '(SELECT to_jsonb(pf_m)FROM(' + FN_QUERY(Q(sig)) + ')pf_m)=' + D(f, 'allp_immutable_' + str(i)) + '::jsonb')
    add('relation_group25_shape', "(SELECT jsonb_agg(pf_k ORDER BY pf_k)FROM jsonb_object_keys(pf_r.body#>'{db_core,innata_all_clan_relations}')pf_k)=" + D(sorted(rels), 'allp_relation_names') + '::jsonb')
    for (i, (name, r)) in enumerate(sorted(rels.items())):
        live = '(SELECT pf_s.meta FROM pf_relation_live pf_s WHERE pf_s.name=' + Q(name) + ')'
        add('relation_fingerprint:' + name, 'public.combat_v2_sha256(' + live + ")=pf_r.body#>>ARRAY['db_core','innata_all_clan_relations'," + Q(name) + ']')
        add('relation_schema:' + name, '(' + live + "-ARRAY['constraints','triggers'])=" + '(' + D(r, 'allp_rel_' + str(i)) + "::jsonb-ARRAY['constraints','triggers'])")
        cons = [expected_constraint(name, r, cat) if x['name'] == CHECKS.get(name) else x for x in r['constraints']]
        add('relation_constraints:' + name, live + "->'constraints'=" + D(cons, 'allp_cons_' + str(i)) + '::jsonb')
        add('relation_trigger_wiring:' + name, "(SELECT coalesce(jsonb_agg(pf_t-'function_md5'ORDER BY pf_t->>'name'),'[]'::jsonb)FROM jsonb_array_elements(" + live + "->'triggers')pf_t)=" + D([{k: v for (k, v) in x.items() if k != 'function_md5'} for x in r['triggers']], 'allp_tr_' + str(i)) + '::jsonb')
        if name in oldroot['db_core']['combat_innata_relations']:
            add('legacy_relation_alias:' + name, "pf_r.body#>>ARRAY['db_core','combat_innata_relations'," + Q(name) + "]=pf_r.body#>>ARRAY['db_core','innata_all_clan_relations'," + Q(name) + ']')
    for (i, (table, rows)) in enumerate(sorted(post_configs(targets, cat).items())):
        expected = sorted(rows, key=lambda x: (x['technique_id'], x['config_version']))
        add('config_append_exact:' + table, "(SELECT coalesce(jsonb_agg(to_jsonb(pf_c)ORDER BY pf_c.technique_id,pf_c.config_version),'[]'::jsonb)FROM " + table + ' pf_c)=' + D(expected, 'allp_postconfig_' + str(i)) + '::jsonb')
    base = pre_checks(actual, targets, olds, new, oldroot, rels)
    for (n, expr) in base:
        if n.startswith(('gate:', 'native_gate:', 'party_relation:')) or n in ('catalog36', 'protected_custody', 'origin', 'capability', 'release', 'qualification', 'content_admissions', 'profile'):
            add(n, expr)
    add('engine_profile', 'mission_public_owner.engine_profile_state_v1(' + rev + ",'mission-ai-authoring/1')=" + D(actual['profile'], 'allp_engine_profile') + '::jsonb')
    ar = actual['release']
    binding = "jsonb_build_object('db_sha256',pf_r.body#>>'{db_core,sha256}','edge_sha256'," + Q(ar['edge_sha256']) + ",'client_sha256',public.combat_v2_sha256(pf_r.body->'ui'),'configuration_sha256',pf_r.body#>>'{config,sha256}')"
    add('new_admission', 'EXISTS(SELECT 1 FROM mission_public_owner.release_admissions_v1 pf_ad WHERE pf_ad.release_sha256=' + rev + ' AND pf_ad.public_enabled AND pf_ad.contract_version=' + Q(ar['contract_version']) + ' AND pf_ad.staff_evidence_ref=' + Q(ar['staff_evidence_ref']) + " AND pf_ad.independent_review_ref=pf_r.row->>'independent_review_ref'AND(jsonb_build_object('db_sha256',pf_ad.db_sha256,'edge_sha256',pf_ad.edge_sha256,'client_sha256',pf_ad.client_sha256,'configuration_sha256',pf_ad.configuration_sha256))=" + binding + ')')
    aq = actual['qualification']
    payload = D(aq['payload'], 'allp_old_qualification') + '::jsonb'
    add('engine_qualification_adopted', 'EXISTS(SELECT 1 FROM mission_public_owner.public_qualification_attestations_v1 pf_q WHERE pf_q.release_sha256=' + rev + " AND pf_q.payload_sha256=mission_factory_owner.sha(pf_q.payload)AND pf_q.payload->>'revision_sha256'=" + rev + " AND pf_q.payload->'bindings'=" + binding + " AND(pf_q.payload-ARRAY['revision_sha256','bindings','independent_review'])=(" + payload + "-ARRAY['revision_sha256','bindings','independent_review'])AND pf_q.positive_staff_evidence_ref=" + Q(aq['positive_staff_evidence_ref']) + ' AND pf_q.authorized_test_manifest_ref=' + Q(aq['authorized_test_manifest_ref']) + " AND pf_q.payload#>>'{independent_review,ref}'=pf_r.row->>'independent_review_ref'AND pf_q.payload#>'{independent_review,P0}'='0'::jsonb AND pf_q.payload#>'{independent_review,P1}'='0'::jsonb AND pf_q.payload#>'{independent_review,P2}'='0'::jsonb)")
    for (i, c) in enumerate(actual['content_admissions']):
        add('certificate_request:' + c['mission_id'], 'EXISTS(SELECT 1 FROM mission_public_owner.mission_content_admissions_v1 pf_c WHERE pf_c.engine_release_sha256=' + rev + ' AND pf_c.publication_request=' + Q(c['publication_request']) + '::uuid AND pf_c.request_key=extensions.uuid_generate_v5(' + Q(c['publication_request']) + '::uuid,' + rev + "||':content-adoption')AND pf_c.payload->>'request_key'=pf_c.request_key::text)")
        add('certificate_adoption:' + c['mission_id'], 'EXISTS(SELECT 1 FROM mission_public_owner.mission_content_admissions_v1 pf_c WHERE pf_c.engine_release_sha256=' + rev + ' AND pf_c.mission_id=' + Q(c['mission_id']) + '::uuid AND pf_c.publication_request=' + Q(c['publication_request']) + '::uuid AND pf_c.config_version=' + str(c['config_version']) + " AND pf_c.payload_sha256=mission_factory_owner.sha(pf_c.payload)AND pf_c.payload->>'engine_release_sha256'=" + rev + " AND(pf_c.payload-ARRAY['request_key','engine_release_sha256','created_at'])=(" + D(c['payload'], 'allp_cert_' + str(i)) + "::jsonb-ARRAY['request_key','engine_release_sha256','created_at']))")
    add('new_adoption_count', '(SELECT count(*)FROM mission_public_owner.mission_content_admissions_v1 pf_c WHERE pf_c.engine_release_sha256=' + rev + ')=' + str(len(actual['content_admissions'])))
    add('UI_land', "pf_r.body#>'{ui,files,land.html}'=" + D({k: um['logical_assets']['land.html'][k] for k in ('sha256', 'bytes')}, 'allp_land') + '::jsonb')
    add('UI_module_pin', "pf_r.body#>>'{ui,module_pin}'=" + Q(um['logical_assets']['mission-generic-ui.mjs']['module_pin']))
    add('UI_graph_binding', "pf_r.body#>>'{ui,import_graph_sha256}'=public.combat_v2_sha256(pf_r.body#>'{ui,innata_all_clan_graph}')AND pf_r.body#>>'{ui,innata_all_clan_graph,parent_graph_sha256}'=" + Q(oldroot['ui']['import_graph_sha256']))
    add('UI_other_assets_unchanged', "((pf_r.body#>'{ui,files}')-'land.html')=" + D({k: v for (k, v) in oldroot['ui']['files'].items() if k != 'land.html'}, 'allp_otherassets') + '::jsonb')
    add('UI_Generic_pin', "pf_r.body#>>'{ui,files,mission-generic-ui.mjs,sha256}'=" + Q(um['logical_assets']['mission-generic-ui.mjs']['sha256']) + " AND pf_r.body#>'{ui,files,mission-generic-ui.mjs,bytes}'=" + Q(str(um['logical_assets']['mission-generic-ui.mjs']['bytes'])) + '::jsonb')
    if receipts:
        add('UI_publication_head', "pf_r.body#>>'{ui,git_head}'=" + Q(receipts['git']['head']))
    fvalues = ','.join(('(' + Q(sig) + ')' for sig in fs))
    rvalues = ','.join(('(' + Q(name) + ')' for name in rels))
    text = "-- READONLY POST-INSTALL ONLY. Before installation AFTER_INSTALL_ONLY fails; no gameplay qualification.\nWITH pf_current AS(SELECT to_jsonb(pf_x)row FROM mission_factory_owner.editor_release_readiness pf_x WHERE singleton),pf_root AS(SELECT row,(row->>'canonical_preimage')::jsonb body FROM pf_current),pf_defs(signature)AS(VALUES " + fvalues + '),pf_function_live AS(SELECT pf_d.signature,to_jsonb(pf_m)meta FROM pf_defs pf_d LEFT JOIN LATERAL(' + FN_QUERY('pf_d.signature') + ')pf_m ON true),pf_relation_names(name)AS(VALUES ' + rvalues + '),pf_relation_live AS(SELECT pf_d.name,to_jsonb(pf_m)meta FROM pf_relation_names pf_d LEFT JOIN LATERAL(' + REL_QUERY('pf_d.name') + ')pf_m ON true),pf_checks(name,ok)AS(\n' + '\nUNION ALL\n'.join(('SELECT ' + Q(n) + '::text,coalesce((' + expr + '),false)FROM pf_root pf_r' for (n, expr) in checks)) + ")SELECT jsonb_build_object('schema_version','innata-all-root-postflight/1','root_revision',(SELECT row->>'revision_sha256'FROM pf_root),'checks',count(*),'passed',count(*)FILTER(WHERE ok),'all_ok',bool_and(ok),'failed',coalesce(jsonb_agg(name)FILTER(WHERE NOT ok),'[]'::jsonb),'old92'," + str(len(actual['functions'])) + ",'group45',(SELECT count(*)FROM pf_root pf_r,jsonb_each(pf_r.body#>'{db_core," + GROUP + "}')pf_g),'function_union_OID_count',(SELECT count(DISTINCT id)FROM(SELECT jsonb_array_elements_text(" + D(oldids, 'allp_report_oldids') + "::jsonb)id UNION SELECT pf_g.value->>'oid'FROM pf_root pf_r,jsonb_each(pf_r.body#>'{db_core," + GROUP + "}')pf_g)pf_union),'runtime','NOT_RUN','provider_calls',0)AS postflight FROM pf_checks;\n"
    parse_sql(text)
    return (text, len(checks))

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--actual',type=Path,required=True);ap.add_argument('--targets','--target-capture',dest='targets',type=Path,required=True)
    ap.add_argument('--source',type=Path,default=C/'INNATA_ALL_CLAN_SOURCE.sql');ap.add_argument('--source-plan',type=Path,default=C/'INNATA_ALL_CLAN_SOURCE_PLAN.json')
    ap.add_argument('--port',type=Path,default=C/'INNATA_ALL_QA_RESOURCE_PORT_SOURCE.sql');ap.add_argument('--port-plan',type=Path,default=C/'INNATA_ALL_QA_RESOURCE_PORT_PLAN.json')
    ap.add_argument('--ui',type=Path,default=C/'INNATA_ALL_CLAN_LAND.html');ap.add_argument('--ui-manifest',type=Path,default=C/'INNATA_ALL_CLAN_UI_MANIFEST.json')
    ap.add_argument('--catalog',type=Path,default=C/'INNATA_ALL_CLAN_CATALOG.json');ap.add_argument('--contract',type=Path,default=C/'INNATA_ALL_CLAN_CONTRACT.md')
    ap.add_argument('--review',type=Path);ap.add_argument('--receipts',type=Path);ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--template',action='store_true');ap.add_argument('--recovery',action='store_true');o=ap.parse_args()
    assert o.template or(o.review and o.receipts),'Bound material needs actual review and deploy receipts'
    source=source_ast(o.source,'INNATA_ALL_CLAN_ROOT_COMPOSITION_REQUIRED');port=source_ast(o.port,'INNATA_ALL_QA_RESOURCE_PORT_COMPOSITION_REQUIRED')
    result=emit(read(o.actual),read(o.targets),source,port,read(o.source_plan),read(o.port_plan),o.ui,read(o.ui_manifest),o.catalog,o.contract,read(o.review)if o.review else None,read(o.receipts)if o.receipts else None,o.out,o.template,o.recovery,{k:H(v.read_bytes())for k,v in {'actual_capture':o.actual,'target_capture':o.targets,'source_plan':o.source_plan,'port_plan':o.port_plan,'UI_manifest':o.ui_manifest}.items()})
    print(J(result))
if __name__=='__main__':main()
