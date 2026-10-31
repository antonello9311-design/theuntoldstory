#!/usr/bin/env python3
"""E71: exact Edge135 editorial delta; source/static only, no model/DB/gameplay."""
from pathlib import Path
import argparse, hashlib, json, re, subprocess, difflib

BASE_RUNTIME='5dac47a9b15811a1c7880ec7c7cb211e2617badf393288b647c55e75e179daf9'
BASE_ROOT='71bd2e9cd39ee9ba7e65ca8aef545d4e5e1618eac6beee49ee393d4af377daa1'
def sha(s): return hashlib.sha256(s.encode()).hexdigest()
def once(s,a,b):
    assert s.count(a)==1,(s.count(a),a[:100])
    return s.replace(a,b)
def constant(s,name,value):
    line=next(x for x in s.splitlines() if x.startswith('const '+name+'='))
    return once(s,line,'const '+name+'='+json.dumps(value,ensure_ascii=False)+';')

DIRECTOR="mission-dialogue-director/3. Leggi tutte le nuove fonti PG come una finestra unica, in ordine cronologico e con autori e conoscenze distinti. Confronta la richiesta attuale con la cronaca e con lo stato acquisito: individua il contenuto ancora mancante e la decisione o il seguito che può cambiare adesso. Il piano sviluppa questa differenza. Un'ammissione, una rettifica o un accordo già avvenuti sono il punto di partenza; una nuova domanda può richiederne una precisazione, non li rende di nuovo atti da compiere. Per ciascun PNG pertinente scegli contenuto, scopo e modo della risposta o iniziativa consentita dal profilo, distinguendoli da ciò che resta affidato agli altri. Una scelta propria già possibile può essere compiuta ora; una proposta resta aperta soltanto per l'adesione che manca davvero. world_reaction_intent collega questo sviluppo alle attività, agli spazi e ai tempi del luogo già disponibili: come incidono sull'attenzione, sulle distanze sociali, sul ritmo o sulle possibilità dell'interazione corrente. Parti dal loro stato raggiunto, senza riavviare un'attività già esaurita o aggiungere un evento solo per variare lo sfondo. La situazione può restare quieta quando non offre uno sviluppo ambientale pertinente. Non determinare azioni, adesioni o reazioni dei PG e di terzi. Intenzioni comunicative e gestuali orientano la realizzazione, non forniscono un copione. Le fonti decisive fondano la proposta; anche le altre ricevono una risposta coerente. La cronaca non è una nuova fonte PG e i segreti non diventano conoscenze dei PNG. Opportunità, capacità e ricevute server delimitano transizioni e fatti meccanici; il progresso narrativo non autorizza nuove prove, indizi o risultati."
WRITER="mission-editorial-response/10. Realizza la risposta e il seguito attuali consentiti dall'autorità ricevuta, partendo dal punto in cui si trova già la scena. Il nuovo passaggio sviluppa ciò che mancava: una precisazione pertinente, una decisione propria, un'iniziativa consentita o la conseguenza osservabile dello scambio. Gli atti già pubblicati restano acquisiti; richiamali solo per il contenuto nuovo richiesto adesso. Ogni PNG risponde con voce, interesse e conoscenze propri, senza ribadire la stessa ammissione o posizione in più battute. Tono, esitazioni, pause, postura, gesti e distanze percepibili rendono il modo di parlare e agire quando hanno una funzione nel momento. Le attività e gli spazi del luogo partecipano allo scambio: incidono sul suo ritmo, su dove avviene o su ciò a cui gli interlocutori prestano attenzione, secondo lo stato e le possibilità ricevuti. Prosegui l'attività pertinente senza riaprire dettagli esauriti o aggiungere una coda ambientale separata. La continuità di oggetti, custodia e accordi vale anche quando non viene nuovamente dichiarata. Mostra l'atto autonomo consentito mentre avviene e lascia aperta la scelta che appartiene davvero a un altro; non occorre spiegare che una proposta è soltanto una proposta o ribadire i confini dell'autorità. Concludi sullo sviluppo effettivo o sul punto concreto d'intervento dei giocatori. Le parole e i gesti dei PG orientano il seguito senza essere ripubblicati o ricostruiti. Ampiezza e distribuzione di dialogo e descrizione seguono il contenuto, senza ripetizioni di rassicurazione. Scrivi soltanto parole, comportamenti e fatti osservabili: criteri interni e interpretazioni restano privati. Non inventare scelte PG, nuove conoscenze, prove, testimoni informati o conseguenze meccaniche."
MEMORY="mission-scene-memory/2. Aggiorna la memoria precedente per differenza dopo il nuovo racconto: conserva le informazioni ancora utili, sostituisci quelle mutate e chiudi le questioni risolte. state fotografa la situazione attuale raggiunta. In known ogni voce esprime un solo fatto autonomo; indica autore, custode o grado di certezza quando necessari al suo significato. Una dichiarazione resta attribuita a chi l'ha fatta e non diventa verità del mondo. open contiene soltanto la domanda, scelta o azione ancora da compiere: distingue proposta, adesione e accordo; una condizione presente o una custodia già stabilita appartengono all'acquisito. used contiene brevi etichette nominali dei motivi e dettagli già narrati, non nuovi riassunti del dialogo. Scegli prima il nucleo utile e formulalo compiutamente con parole essenziali; una voce non deve accumulare fatto, motivazione e conseguenza. I massimi di trasporto non sono lunghezze da raggiungere. Riduci il significato per selezione e sintesi, senza tagliare parole o proposizioni. Evita di registrare lo stesso contenuto in più categorie e conserva l'attribuzione quando un fatto sostituisce il precedente. Le conoscenze private non rivelate restano nello snapshot. Consegna soltanto la memoria finale, senza appunti di lavorazione o istruzioni di riparazione; non è prosa da riutilizzare né prova di fatti meccanici e non compare nel racconto pubblico."
DESCRIPTIONS={
    'state':'Assetto attuale della scena dopo il nuovo esito, in una sintesi compiuta; non elenco di offerte future.',
    'known':'Fatti ancora utili e acquisiti, conservando autore e certezza; ogni voce contiene un solo nucleo informativo.',
    'open':'Soltanto domande, scelte o azioni ancora irrisolte; rimuovi ciò che il nuovo esito ha risolto.',
    'used':'Brevi etichette nominali di motivi e dettagli già narrati; non frasi del racconto o riassunti lunghi.'
}
ITEM_DESCRIPTIONS={
    'known':'Un fatto autonomo sintetico e compiuto, attribuito quando necessario; conserva il pertinente già acquisito.',
    'open':'Una questione realmente aperta, distinguendo chi deve ancora scegliere o agire.',
    'used':'Etichetta breve e semanticamente compiuta del motivo già usato, senza una frase narrativa da troncare.'
}

def transform(s):
    s=constant(s,'SCENE_WRITER_RESPONSE_RULE',WRITER)
    s=constant(s,'SCENE_MEMORY_RULE',MEMORY)
    line=next(x for x in s.splitlines() if 'dialogue ? "mission-dialogue-director/2.' in x)
    s=once(s,line,'    dialogue ? '+json.dumps(DIRECTOR,ensure_ascii=False)+' :')
    start=s.index('const sceneMemorySchema=');end=s.index('const SCENE_WRITER_INPUT_RULE=',start)
    previous=s[start:end]
    updated="const sceneMemorySchema={...memorySchema,description:'Memoria privata finale aggiornata per differenza: acquisito, questioni aperte e motivi usati in unità distinte e compiute.',properties:{\n"
    updated+='  state:{...memorySchema.properties.state,description:'+json.dumps(DESCRIPTIONS['state'],ensure_ascii=False)+'},\n'
    for k in ['known','open','used']:
        updated+='  '+k+':{...memorySchema.properties.'+k+',description:'+json.dumps(DESCRIPTIONS[k],ensure_ascii=False)+',items:{...memorySchema.properties.'+k+'.items,description:'+json.dumps(ITEM_DESCRIPTIONS[k],ensure_ascii=False)+'}},\n'
    updated+='}};\n'
    return once(s,previous,updated)

def erase_delta(s):
    s=re.sub(r'^const (?:SCENE_MEMORY_RULE|SCENE_WRITER_RESPONSE_RULE)=.*$', '__EDITORIAL_CONSTANT__',s,flags=re.M)
    s=re.sub(r'^    dialogue \? "mission-dialogue-director/[23]\..* :$', '__EDITORIAL_DIRECTOR__',s,flags=re.M)
    a=s.index('const sceneMemorySchema=');b=s.index('const SCENE_WRITER_INPUT_RULE=',a)
    return s[:a]+'__SCENE_MEMORY_DESCRIPTIONS__\n'+s[b:]

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--baseline',required=True);ap.add_argument('--output',required=True)
    ap.add_argument('--node',default='/Users/antonello/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node');a=ap.parse_args()
    base=json.loads(Path(a.baseline).read_text());assert base['version']==135 and len(base['files'])==16
    old={x['name']:x['content'] for x in base['files']};before=old['mission-generic-runtime.mjs'];assert sha(before)==BASE_RUNTIME
    after=transform(before);assert erase_delta(before)==erase_delta(after)
    new={**old,'mission-generic-runtime.mjs':after};out=Path(a.output);out.mkdir(parents=True,exist_ok=True);rows=[];checks=[]
    for name,body in new.items():
        f=out/'edge'/name;f.parent.mkdir(parents=True,exist_ok=True);f.write_text(body)
        rows.append({'name':name,'baseline_sha256':sha(old[name]),'candidate_sha256':sha(body),'bytes':len(body.encode()),'changed':body!=old[name]})
        if name.endswith('.mjs'):
            r=subprocess.run([a.node,'--check',str(f)],capture_output=True,text=True);assert r.returncode==0,(name,r.stderr)
            checks.append({'file':name,'syntax':'PASS'})
        for imp in re.findall(r"(?:from\s*|import\s*)['\"](\.[^'\"]+)['\"]",body):
            target=str(Path(name).parent/imp).removeprefix('./');assert target in new,(name,imp)
    package={'name':'mission_generic_ai','entrypoint_path':'mission-generic-index.ts','verify_jwt':base['verify_jwt'],'files':[{'name':f['name'],'content':new[f['name']]} for f in base['files']]}
    pp=out/'C1266_EDITORIAL71_EDGE_PACKAGE.json';pp.write_text(json.dumps(package,ensure_ascii=False,indent=2)+'\n')
    diff=''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='Edge135/mission-generic-runtime.mjs',tofile='E71/mission-generic-runtime.mjs'))
    (out/'RUNTIME.diff').write_text(diff)
    static={'status':'SOURCE_FROZEN_NOT_INSTALLED','schema':'editorial71-edge-static/1','aggregate':16,'prior_aggregates_preserved':list(range(1,16)),
            'baseline_edge':135,'baseline_root':BASE_ROOT,'files':rows,'changed_files':sum(x['changed'] for x in rows),'syntax':checks,
            'relative_imports':'RESOLVED_STATIC','package_sha256':hashlib.sha256(pp.read_bytes()).hexdigest(),
            'runtime_sha256':sha(after),'builder_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
            'delta_only':'Three editorial instruction paragraphs and descriptions-only sceneMemorySchema; erased-delta comparison byte-identical',
            'preserved_byte_identical':['Other 15 Edge files','All selectors/callsites, request builders, output normalizers, validators and authority code','Legacy MEMORY_RULE and memorySchema (600/180/180/90;16/10/20)','SCENE_WRITER_INPUT_RULE, NARRATIVE_SCENE_RULE and private EDITORIAL_DIALOGUE_WRITER_RULE','Director non-dialogue branch, /1,/3,/4, Native peaceful and ordinary narrative topology'],
            'provider_calls':0,'gameplay_tests':'NOT_RUN','editorial_effectiveness':'NOT_RUN','memory_effectiveness':'NOT_RUN',
            'schema_change':'Only descriptions; same keys/types/required/bounds/validators and transport budgets',
            'no_new_block_retry_or_call':True,'callsite_audit':[{'caller':'directorRequest','condition':"!role && p.schema_version === 'mission-director-work/2'",'rule':'mission-dialogue-director/3'},{'caller':'createStaffDialogueEditorialDirector','condition':'editorial_question','rule':'mission-dialogue-director/3'},{'caller':'narrativeSceneRequestFromView','condition':'all Scene5 including private preview','rules':['mission-editorial-response/10','mission-scene-memory/2']}],
            'memory_cause_limit':'E70 fragments already present in final provider JSON; internal generation/decoder cause and effectiveness of semantic correction remain unproven.'}
    (out/'C1266_EDITORIAL71_EDGE_STATIC.json').write_text(json.dumps(static,ensure_ascii=False,indent=2)+'\n')
    intro='''# E71 — correzioni generali dal report E70\n\nDelta minimo da Edge135 / Root71bd: cambia soltanto mission-generic-runtime.mjs. Gli altri quindici file restano byte-identici. Nessun deploy, apply DB, provider o collaudo funzionale eseguito da questo contributo.\n\nIl Director dialogico /3 pianifica la differenza fra cronaca acquisita e richiesta aperta, evitando di trattare un atto già pubblico come nuovo avanzamento. world_reaction_intent collega lo sviluppo alle attività e agli spazi disponibili nel loro stato corrente; non impone nuovi eventi, reazioni di terzi o una coda descrittiva. Le intenzioni restano proposte di contenuto, scopo e modo, senza nuova autorità.\n\nWriter response/10 realizza il seguito autorizzato con voci e modi osservabili. Acquisito, custodia e confini restano impliciti salvo funzione nuova; ambiente e interazione procedono insieme. Il criterio evita ripetizioni della medesima ammissione e spiegazioni rituali delle scelte, senza quote, blacklist, filtri o retry.\n\nMemoriaScene/2 aggiorna per differenza. known conserva nuclei autonomi e attribuiti; open solo questioni irrisolte; used etichette nominali brevi anziché riassunti narrativi. Le descrizioni provider sono specifiche per categoria. La selezione del significato precede la serializzazione: i limiti sono capienza, non obiettivi di lunghezza. Shape, cardinalità e limiti600/180/90 restano invariati con tutti i consumer. Nessuna memoria o Fato precedente è corretto.\n\nLa causa interna dei frammenti nel JSON finale E70 non è dimostrata; questo intervento ne affronta la pressione semantica senza dichiarare risolto il difetto. Efficacia editoriale e della memoria NOT_RUN: nessuna nuova prova è autorizzata.\n\n## Controlli statici\n\nQuindici MJS verificati con node --check e import relativi risolti sul pacchetto16file. Eliminando solo i tre paragrafi editoriali e le descrizioni dello schema, runtime prima e dopo coincidono byte per byte: selector, builder, normalizzatori, validatori, memoria legacy, topologia, autorità, quote e recupero non cambiano. Ricostruzione ripetibile del pacchetto e del referto verificata separatamente dall'integrazione.\n\n## Identità\n\n'''
    intro+='- Runtime prima: `'+sha(before)+'`.\n- Runtime candidato: `'+sha(after)+'`.\n- Package: `'+static['package_sha256']+'`.\n- Builder: `'+static['builder_sha256']+'`.\n\n## Diff esatto\n\n```diff\n'+diff+'```\n'
    (out/'C1266_EDITORIAL71_PROMPT_DIFF.md').write_text(intro)
    print(json.dumps({k:static[k] for k in ['runtime_sha256','package_sha256','changed_files','provider_calls']}))
if __name__=='__main__':main()
