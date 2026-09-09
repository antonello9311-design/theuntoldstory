# HANDOFF · CLAN-COMMON-CONTROLLED-RELEASE-096

## TASK-ID
CLAN-COMMON-CONTROLLED-RELEASE-096 · riparazioni097/098/099, storico candidato100, recovery Staff e raccordo Sabaku · PM/DB-COMBAT · 09/09/2026

## Scope toccato
Rilascio base dei pannelli comuni, runtime Marionettisti/Sabaku e catalogo Controllo/Trasporto/Clone: DB096, configurazione098 e LAND099. L'owner Clan attesta poi la migrazione recovery 20260909093926, Edge23 e il raccordo Sabaku 20260909112705. LAND099 e regole84 risultano pubblicati e riconciliati con GitHub il 09/09; il dominio non è stato riverificato da questo allineamento. StaffPanel e SabakuStaff restano attivi, ordinario/MasterPanel e Sabaku pubblico disattivi secondo l'owner. Nessuna nuova apertura generale. Questo passaggio aggiorna i documenti del cantiere, senza nuove operazioni applicative o DB.

## Contratti usati/modificati
combat-panel/1, combat-map/2, sabaku-transport-view/2.098 corregge solo geometry_sha256 di17scene dopo aggiunta is_impervious=false.099 riusa il consumer originale per apertura/accettazione e Common durante gli scambi. Candidato100 propone tempi di trasporto e recupero esplicito di un tentativo pre-provider, con nuova chiave e audit; NON applicato. Le protezioni e il report meccanico restano invarianti.

## Decisioni prese / OPEN
Mandato storico di Antonello dell’08/09, con decisioni tuttora da conservare: procedere con correzioni ed espansioni notturne, poi altri clan; scelte prodotto effettive al mattino, avanzare gli indipendenti. Stessa prova Staff protetta conRiuji/testperfunzioni aperta fra i blocchi, nessun reset. Utenti rinviati. Flusso offensivoSabaku già ratificato segue questa tranche. Nessuna decisione prodotto richiesta per097–100. Hyuga: distanza/area/bersagli già ratificati; vecchi drain5/10 nel deposito453 sono difetti tecnici da sostituire, non scelte aperte.

## Prove eseguite e risultato

**Checkpoint documentale del 09/09/2026, cutoff owner 11:38:54 UTC:** il recupero Staff è già riuscito con STAFF-AI-RECOVERY-001 (migrazione 20260909093926, Edge 23): Fato pubblicato, nuovo scambio nella stessa scena e parent/report meccanico conservati. Il successivo collaudo marionetta è PASS: Passa e attacco ordinari, 2 chiamate provider / 3847 token, nessun retry; postflight delle 11:12:50 UTC su 2 PG / 12 superfici senza differenze dalla baseline, inclusi i timestamp.

Il nuovo mandato Sabaku ha corretto il banco G02/G08, preservando il precedente referto terminale: matrice di 12 gruppi PASS, 15/15 invii SQL e review indipendente 0/0/0. L'owner attesta l'applicazione della migrazione 20260909112705 e lo smoke bind / Controllo ON riuscito: due Passa ordinari hanno rigenerato le offerte, 2 chiamate provider / 3971 token, entrambi pubblicati senza retry. Postflight delle 11:38:54 UTC contro la baseline delle 11:27:31: 2 PG / 12 superfici senza differenze, inclusi i timestamp. La stessa scena Staff e4f36e1a resta aperta; nessun reset o apertura pubblica generale. Il coordinamento PM riferisce una lettura DB delle 11:32 UTC con 495 migrazioni e head 20260909112705: questo allineamento non esegue nuove verifiche tecniche.

Questi esiti attestano il recupero Staff, il caso marionetta e il bind / Controllo ON Sabaku nei rispettivi perimetri; non certificano l'intero Clan né ricertificano i cicli terminali 100, Hyūga001, SCENE001 e COMBAT-INTEGRAZIONE-CONFIGURATA (31/32). Trasporto e Clone richiedono piano e budget del prossimo blocco prima delle azioni; Moltiplicazione resta sospesa perché il dispatch non è coperto. La task Narratore 01a084ae-ed3e-7061-addd-8bfc0056e3b8 è conclusa e archiviata su richiesta di Antonello, con monitor PAUSED secondo il coordinamento: osservazioni editoriali e audit centrale passano al PM, senza riattivazione della task.

Fonti del checkpoint: management/candidati/CLAN-L1_2026-09-01/HANDOFF.md, runtime/sabaku/candidato/RECOVERY_BIND_LIVE_RESULT.json e RECOVERY_BIND_LIVE_ON.png nello stesso cantiere; evidenze marionetta in runtime/marionettisti/candidato/STAFF_LIVE_ATTACK_RESULT.json. Per i residui narrativi conservare anche management/candidati/NARRATORE-UNIFICATO_2026-09-02/HANDOFF.md. Stato e limiti sono attestazioni documentali degli owner e del coordinamento, non una nuova certificazione.

**Rilascio base e primo scambio dell’08/09 — evidenze storiche conservate:**
DB096 migration20260908213806,293/293funzioni esatte, catalogo3tecniche aggiornato. Edge22ACTIVE,9/9file esatti.098 review0/0/0 e2casi localiPASS. LAND099 commit0b83cbd502be8ebba40405949556aaeed3c1cb64,841954B/SHA01daea519b8b4adb9fe8411799a46432c009c02f6a6d68b8dbfe772f248a648d; dominio verificato22:10UTC e invito/accettazione riusciti nei due browser.

Staff sessione e4f36e1a-afaf-4d30-a06d-f2f17e6ac391 aperta22:11UTC. Area impervia[7,9]–[17,14], marionetta30/30/Fili. Movimento marionetta2m/costo2 e PG3m/costo6 PASS. Primo attacco/parata risolto, reportf4afa3e0, danno22 simulato/values_written=false. Narratore HTTP503 ordinary_claim_unavailable; claim01fadb09 creato dopo rispostaEdge e ora scaduto, zero provider. Il ciclo è PARTIAL/ROSSO sul raccordo, non un collaudoClan completo. Scena preservata.

Postflight22:39UTC:2PG/12superfici, tutti i campi di gioco e gli insiemi invariati; soltanto updated_at/last_regen_at cambiano per rigenerazione ordinaria. Screenshot in pannelli/: tre schedeSabaku, mappa/marionetta e STAFF_PRIMO_SCAMBIO_ATTESA_SCADUTA.png.

## Rischi o regressioni da verificare
Il blocco Sabaku sulla parent storica è superato dal raccordo applicato e dallo smoke bind / Controllo ON; restano da collaudare Trasporto, Clone, presa/liberazione e lifecycle. Moltiplicazione resta sospesa per dispatch non coperto, come comunicato dal coordinamento. Il PASS di questa tranche non certifica l'intero ciclo Sabaku, il collaudo congiunto o la nuova architettura narrativa.

Il precedente RECOVERY_BIND terminale è conservato nel cantiere Clan, runtime/sabaku/candidato/_precedenti/recovery-bind-terminal-before-authorization/: 10 gruppi PASS e 2 casi non validanti del banco non costituivano due nuovi bug di prodotto. Anche il ciclo 100 resta ROSSO: codice 0/0/0, 3 gruppi trasporto e 4 gruppi DB PASS; T8 arrestato nel runner prima di esercitare la concorrenza. Il recupero successivo non ricertifica 100; conservare NARRATIVE_RECOVERY_100_PLAN.md e i referti originari.

Residui UI osservati: distanze duplicate, difesa etichettata con il proprietario anziché la marionetta, ultima ricevuta che scompare dal pannello, etichette mappa sovrapposte e pannello PC stretto. La scomparsa della ricevuta dalla UI non dimostra un'assenza nel DB. Chiarezza narrativa del danno residuo, numerazione round e audit centrale restano nel backlog PM dopo l'archiviazione della task Narratore; nessun retry editoriale autorizzato da questo documento.

## Passaggio richiesto al PM
Conservare la stessa scena Staff e4f36e1a, parent, referti e storico; non ripetere il recupero, l'apply 096 o il bind / Controllo ON già riusciti. L'owner Clan prepara il piano e dichiara il budget prima delle azioni del prossimo blocco Trasporto/Clone, poi verifica effetti, screenshot e isolamento per le funzioni effettivamente provate. Presa/liberazione e lifecycle restano nel seguito assegnato; Moltiplicazione è sospesa per dispatch non coperto. Nessuna chiusura/reset automatici. Test Room utenti rinviata in questo collaudo.

Proseguono soltanto i verticali Clan indipendenti già assegnati, inclusi i raccordi Uchiha di identità/catalogo/prerequisiti/modalità descritti nell'handoff dell'owner. Conservare le decisioni valide e le domande già inviate su richiamo marionetta e reintegro/Flusso Sabaku; non presentarle come nuove scelte da risolvere qui. La task Narratore è conclusa e archiviata su richiesta di Antonello, monitor PAUSED: il PM acquisisce i residui editoriali, di audit e di architettura, senza riattivare la task.

Questo allineamento documentale non autorizza nuove chiamate, apply, enable o cicli di QA. Il budget della campagna originaria fino alle 23:40:40 UTC (10 blocchi / 12 provider / 200000 token / 90 minuti, 0 provider registrati allora) è storico e non viene rinnovato. I consumi della recovery, del collaudo marionetta e dello smoke Sabaku appartengono a blocchi distinti: non si riusano automaticamente. Sorgenti e referti da depositare selettivamente tramite owner; sito099 e regole84 già caricati secondo l'handoff Clan. I precedenti referti rossi rimangono disponibili.
