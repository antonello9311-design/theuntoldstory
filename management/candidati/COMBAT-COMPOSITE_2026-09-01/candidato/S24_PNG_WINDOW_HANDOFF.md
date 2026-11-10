# S24 PNG — prova fermata, chiusura completata

TASK-ID: COMBAT-S24-PNG-WINDOW-20261110 · owner PM-COMBAT-S24.

## Scope toccato
Nuova finestra finita della fonte Staff originale per T6 Copertura PNG, T7 Diversivo PNG e T8 due attacchi PNG contro la stessa formazione. Punto cieco F1 già PASS escluso. Correzione del solo percorso di chiusura resa necessaria dal Writer terminale fallito.

## Contratti usati/modificati
QA su Root ed742e942e3d421f0272239c51bb55bd820efc9de07c0cb7191bc927269fa917, Generic160 invariata, Combat42 invariata. Finestra08:48–10:18 UTC/cutoff10:12, massimo12work/24HTTP; per richiesta24000input/4096output e costo cumulativo0.10USD. Migrazione iniziale combat_s24_png_window_20261110, sola policy temporale.
Cleanup: Root744f6553a4ea0585547834713aa1fad91c3e0c4031221da59b375859a72a4725; unico DDL mission_staff_abort_private.quiescent_v1(uuid),91header/90precedenti invariati. Installer83edf000ceb14b7450896a02f37460c36165afa5038539f2848121a3075fa74e; review1e18b05f7cfb772bb61b300130d67f123f6f0a38b56703d4e82f7b9b832dc81a finale0/0/0. Migrazione combat_s24_paid_writer_terminal_cleanup_20261110, readback completo PASS. Unico pin Admin aggiornato, SHA2f122262adc87c02f84923cebc464af3588e979f0de2c5d324d49cc9c8ea8597,484602byte.

## Decisioni / OPEN
Il predicato di chiusura ora copre un singolo Writer narration/2 combat fallito con risposta incomplete/max_output_tokens, esito certo, consumo dimostrato e Count/Gen saldati. È ristretto alla fonte/plan/definition/hash Staff immutabili, non al solo UUID di questa prova. Tutti gli altri work e i pools conservano la prova nativa esistente; autenticazione, lock e permessi del caller restano invariati. Nessun nuovo helper/grant, nessun costo trasformato in no_http, reset o cancellazione. La chiusura resta possibile dopo scadenza della finestra e non autorizza nuove prove.
Stop al primo blocco Writer: nessun aumento outputcap, retry, nuovo tentativo, Restore, scelta PNG forzata o ripetizioneF1. La guardia di finanziamento T8 ereditata dall'installer d'avvio è stata rimossa soltanto dall'installer cleanup; controlli sui pools e sulle risorse protette conservati.

## Prove eseguite e risultato
S24 PNG nuova finestra · 10/11/2026 · QA FERMATA, CHIUSURA PASS. Fonte originale avviata09:28 UTC su Rooted742/Generic160 e Pages42790618685 SUCCESS. Incipit, raccordo e Choice completati; E1 risolto ma Writer fallito per MISSION_PROVIDER_INCOMPLETE/max_output_tokens: HTTP200, usageVALID, parseNOT_ATTEMPTED, nessun Fato Combat. T6/T7/T8 NOT_RUN, N2/N3 non raggiunti; F1 PASS non ripetuto e nessun Restore. 4work,4Count+4Gen=8HTTP nuovi,0,0059070USD; totale assestato/impegnato0,0444772USD entro0,10. Corretto solo quiescent_v1 per Writer terminale pagato e certo della fonte Staff immutabile; review finale0/0/0 dopo una correzione installer, Root744f6553/91header/90precedenti invariati, migrazione combat_s24_paid_writer_terminal_cleanup_20261110. Annulla nativo commesso09:55:38 UTC; postflight09:56:15 PASS: Master e Combat annullati,45righe contabili/report/audit identiche, custodia5sezioni identica,0Staffaperte/pendenze/riserve/hold. PubblicoOFF; nessun nuovo provider per cleanup. Admin nuovo pin preparato per deposito selettivo; ricevuta di pubblicazione nel registro.

Master1f750288-91b4-4f32-bd55-e57e49c2275b, Combat0cc8d460-aea4-4243-8bd9-e601b098510b. Opening/raccordo/Choice completati; Writer25e58eda-5ab3-4aa9-a0d6-a441278342f3 fallito ma contabilizzato. Fonte cumulativa10Count9Gen19HTTP +1no_http storico; spesa fonte0.0102833USD e parte precedente nonService0.0341939USD. Nuovi8HTTP costano0.0059070USD; totale0.0444772USD, nessuna riserva.
Annullamento nativo09:55:38.601984UTC, audit92c9a9fb-3d12-4f5d-a73a-46b9a9686cd5. Postflight SHA47ad9cb61b784cf42ea4bb5aa58d29ed069140e26b95efa1deb68610535ee53e: scene chiuse,45righe immutate, nessun effetto reale e custodia esatta. Report Combat storico resta attesa senza messaggio: non è stato pubblicato un Fato fittizio.

## Rischi o regressioni da verificare
T6/T7/T8 non raggiunti e non qualificati. LifeCore supera la validazione pre-provider, ma il Writer non completa entro il limite di output: qualità narrativa e ciclo Combat completo non qualificati. Cleanup PASS non implica rilascio pubblico; pubblico Tactics/Facing OFF.

## Passaggio richiesto al PM
Prossimo passo: correggere nello scope pertinente la generazione Writer che raggiunge il limite di output, mantenendo tetto economico e storico; una futura prova deve fissare nuovamente i soli casi mancanti. Non rilanciare automaticamente il Writer, non riaprire la scena annullata, non ripetere F1 PASS. La chiusura riuscita non qualifica T6/T7/T8.

Deposito selettivo: Admin e quattro referti PNG PLAN/REVIEW/RELEASE/HANDOFF; ricevuta commit/Pages/dominio nel registro PUBBLICAZIONE e nel referto utente. Installer SQL, Root/proof/raw e dossier cumulativi restano locali per evidenze private e WIP non riconciliati. I freeze precedenti e la correzione P1 sono conservati in work/png-window-20261110/FROZEN e work/png-terminal-cleanup-20261110/REVIEW1_ARCHIVE; non reinstallarli. Recovery precedente e tentativi annullati preservati.
