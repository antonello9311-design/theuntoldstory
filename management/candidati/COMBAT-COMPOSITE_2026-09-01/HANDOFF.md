# Handoff · Combat Composite

TASK-ID · COMBAT-TACTICS-DEPENDENCIES-20261107; installazione figlia COMBAT-TACTICS-T3-RANGE10-INSTALL-W8-20261108.

Scope toccato · Fix T3 e QA Copertura/Diversivo/Facing nella sola Staff Test Room.

Contratti usati/modificati · Versione integrata: Root 8f405b2112587dcb882523c551a5a2a312d6273eb13a2789b67576399e8a5d38, DB 1cca1b37cf154fc8cf3a7c6eaa312612d7819ce40f1d28a6b9585a998e3c54a9, Source 8054ddb373d95fd4c8e20a82eb163744e660813f20e02765a565f57c0b0bb777, proof/3 8461d6d39171fd652ee942938cc881fc8102c2da5935c6dbb78bc36dc93765fa. Migrazione 20261108102437; preflight 12/12, review W8 0/0/0, readback 10 funzioni + 11 dipendenze esatti. CHECK OID 677639 accetta 2/3/10; writer range10 riservato tramite il gate Staff esistente, altri nove corpi e ACL/RLS/indice/trigger invariati. Il tentativo atomico fallito del 07/11 resta nello storico.

Decisioni prese / OPEN · T3 installato nella sola Staff e collaudato nel ramo copia a distanza; T5 misto con Master passato nel ramo copia-prima. Facing I ignoto 0 e retro −3 verificati nel solo percorso Master. Restano F1 Ordinary (ignoto, laterale, retro), laterale Master non eseguito e T6–T8 PNG di servizio; F3 due origini nello stesso round resta non rappresentabile nello scope. Pubblico Tactics/Facing OFF; nove Innate mantenute già pubbliche invariate. Non assimilare i riscontri Master alle celle Ordinary. Service fermo fino a composizione e Count/ammissione con un piano finito compatibile; nessuna chiamata Service effettuata.

Prove eseguite e risultato ·

| Caso | Esito circoscritto |
|---|---|
| T3 Ordinary S19 | PASS: copia colpita, offensiva consumata, formazione conclusa, movimento zero, costo Soffio 5 una volta. |
| T5 Master S21 R1 | PASS: Soffio order1 sulla copia, poi colpo Keita order3 normale; nessuna difesa spesa sulla copia. |
| Facing I Master S21 R1 | PASS: orientation_not_known, deduzione 0; orientamento creato solo dalla difesa completata. |
| Facing I Master S21 R2 | PASS: retro true, dot −4, deduzione 3 una sola volta; poi facing Est. |
| F1 Ordinary | PARTIAL: fronte 0 storico; ignoto/laterale/retro ancora NOT_RUN nel percorso Ordinary. |
| T6–T8 Service | NOT_RUN: Count/ammissione 4096 e integrazione Source/Root/DB/Edge pendenti; proposta 42 HTTP incompatibile con i residui. |
| F3 due origini stesso round | NOT_REPRESENTABLE_CURRENT_SCOPE; MAX2/primario e retro III separato conservano il PASS storico. |

Admin 484602 byte, SHA-256 3d4884d61fd37bcf269922958191cad5bd4060202b625b5d53a0d30350e0b26c, commit 08fb2634b8c11f6f2f46bc3fe9c964d562055f79; Pages 42471503885 SUCCESS, Root DOM esatta nel browser interno, 10/10 file Git riletti esatti. LAND/Edge/configurazione invariati. Il pin non attesta il mount dell’editor, estraneo al collaudo.

W8: 08/11/2026 10:14:36–11:44:36 UTC, chiusura propria ultima prova 11:03:30 UTC. Usati 37/38 comandi conservativi, 3/3 scene, 2/5 invii IA, 8455 input + 2639 output, 0,002165 USD; nessun ripristino. Totale storico 321 comandi, 21 scene tutte chiuse, 18 invii IA, 79774 input + 19142 output, 0,0175484 USD su 0,10. Residui numerici 1 comando/0 scene/3 invii: non permettono un nuovo caso completo e non prorogano la finestra.

Rischi o regressioni da verificare · Postflight 11:03:57 UTC: hash di PG reali, Scorta e sei insiemi Party identici alla baseline; gate Tactics/Facing pubblici OFF e nove Innate pubbliche invariati. Controllo terminale 11:04:42 UTC: 0 Combat Staff attivi e 0 Master Staff attivi; values_written=false per S19/S20/S21. Nessun audit o storico cancellato. Nel pannello, dopo alcune transizioni, il contesto non si riallinea fino al normale reload; nessuna azione viene reinviata. Editor mount non qualificato da questa prova.

Passaggio richiesto al PM · Comporre la dipendenza Service e definire una campagna residua finita per F1 Ordinary e T6–T8. Nessun nuovo test avviabile usando la sola durata residua W8: zero scene e un comando conservativo rimasti. Pubblico solo ALL_REQUIRED_CASES_PASS; nessuna richiesta di apertura adesso.

Le nove Innate mantenute già pubbliche restano nello stato qualificato e aperto del 07/11, senza modifiche da questo task; vedere INNATA_QUEST_42501.md e INNATA_DOCUMENTAZIONE.md.
