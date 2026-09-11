# MISSION_GENERIC_PANEL · A2 sintassi installazione · candidato congelato

Task MISSION-GENERIC-A2-SYNTAX. Stessa aggregata A2 avviata dal PM dopo rollback completo dell'installazione A1; il primo guard non acquisito per lock del manifest non crea un nuovo budget. Nessun apply o provider in questo incarico. Correzione solo grammaticale, senza cambio comportamento, dati, GRANT, vincoli o gate.

Nessun delta al SQL: byte e SHA A1 invariati.

SQL SHA256 `03ee8476754f4c231a0b5142f57bfb8d86c7b46f7432dc57bf966ff87242d2f9` · 25769 byte. SHA A1 `03ee8476754f4c231a0b5142f57bfb8d86c7b46f7432dc57bf966ff87242d2f9`. Controlli statici: 17 statement SQL top-level, 5 funzioni PL/pgSQL dirette e 1 blocchi DO analizzati. Nelle sole copie passate al parser sono stati sostituiti tipi compositi con RECORD e nomi funzione normalizzati; i file consegnati mantengono i tipi reali. È controllo di grammatica, non compilazione/schema resolution o test funzionale. Il serializer JSON del parser sui trigger è incompleto: usata la porta raw parse_plpgsql_json per attestare assenza di ParseError, senza utilizzare l'AST serializzato malformato.

Pin di composizione: le quattro funzioni interessate non sono target di pin prosrc nei moduli dipendenti; i pin SQL rimangono invariati. Sette pin prosrc tra candidate (OUTCOME, CHOICE_SOURCES, PROVIDER_GATE) ricalcolati PASS sulla composizione corrente. Manifest di modulo riallineato ai file SQL correnti. Le patch DO e i nuovi IF emessi da Progress/ProviderGate sono stati censiti: i CASE dentro argomenti di funzione sono già delimitati; nessun cambio ai loro testi dinamici richiesto da questo difetto. Il parsing del DO non esegue né materializza automaticamente i DDL dinamici.

Consegna al PM: unica freeze A2, controverifica indipendente pertinente ancora richiesta. Nessuna autoreview 0/0/0 dedotta dalla statica. Recovery e contratto funzionale seguono la consegna precedente riportata qui come contesto; nessun SQL applicato dall'owner A2.

## Contratto funzionale precedente conservato

TASK-ID · MISSION-GENERIC-PANEL-001 · candidata preparata, nessun apply

Scope toccato · Autorizzazione server per un singolo PNG, lavoro e transazione; offerte e commit del pannello Common. Due tabelle private RLS panel_permits/panel_choices, cinque helper privati, tre estensioni precise agli hook condivisi. Non crea utenti né assegna privilegi master al worker.

Contratti usati/modificati · Dipende da MISSION_GENERIC_DB.sql e MISSION_GENERIC_COMBAT.sql. choice_options(session,actor,work,request) restituisce capability_id, actor_id, legal_options, context_version, request_key, persona privata PNG, encounter_id, authority_receipt_id (capability_id) e authorized_context. choice_commit(work,capability,command) valida scadenza, hash, controllo attore, offerta server e comando Common; replay identico restituisce ricevuta senza secondo commit. Helpers revocati anche a service_role: accesso solo dal dispatcher proprietario.

Decisioni prese / OPEN · Principal distinto per attore, derivato da uuid5(actor,'mission-generic-principal'), mai auth.uid simulato. Permessi per backend_pid/txid e 150 secondi, consumati dopo uso. Gli utenti autentici e l'autorità Esame conservano precedenza; autorità simultanee diverse falliscono. L'IA riceve la persona del solo PNG approvato per orientare scelta e tentativo, senza anticipare esiti. Il dispatcher deve aggiungere alla proiezione le role pubbliche pertinenti alla scelta, non chat o profili altrui indiscriminati. Nessun grant esterno nuovo sulle tre funzioni sostituite.

Prove eseguite e risultato · Baseline e firme pertinenti lette dal DB vivo. Parser SQL pglast PASS 17 statement; controllo firme/grant e delimitatori PASS. Il parser non compila i corpi PL/pgSQL contro schema privato. Nessun test funzionale locale, SQL applicato, provider o scena modificata. Review indipendente della composizione ancora necessaria.

Rischi o regressioni da verificare · Native Common options/commit dipendono da arena e dalle guardie di ingresso del modulo Combat. Il candidato non costituisce missioni funzionanti da solo. Verificare su sito protetto scelte PNG, passaggio azioni/difese, tecniche effettivamente nel profilo e non accesso a privilegi staff; preservare percorso Esame/PG umano. Scadenza offerte non autorizza ripetizione di una chiamata provider incerta.

Passaggio richiesto al PM · Comporre dopo DB e Combat, prima dispatcher; review aggregata e preflight dei tre MD5. Recupero conservativo disabilita runtime generico, conserva ricevute/storico; baseline JSON contiene le definizioni precedenti per recupero selettivo compatibile, non rollback indiscriminato di modifiche concorrenti.

SHA-256 SQL · 03ee8476754f4c231a0b5142f57bfb8d86c7b46f7432dc57bf966ff87242d2f9
