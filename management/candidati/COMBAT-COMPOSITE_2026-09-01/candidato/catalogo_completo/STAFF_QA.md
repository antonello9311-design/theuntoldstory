# Collaudo catalogo · Staff 18/11/2026

TASK-ID: COMBAT-CATALOGO-STAFF-QA-20261118. Esito: bloccato prima del gameplay; nessuna qualifica delle tecniche e nessuna apertura pubblica.

Versione: Root `f460be0a321e1640d7993a15285cf1b6352166cda41e991f0c644f29bd6a3658`, bundle `825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5`, Combat Edge45. Fonte riservata Staff verificata prima della prova.

Finestra effettiva 14:00:29–14:27:14 UTC, entro60min. Massimi dichiarati:9casi,6chiamate provider,24000token input,6000output,USD0.10,180operazioni UI. Effettivi:0provider,0token,USD0,0azioni gameplay; conteggio conservativo massimo95operazioni UI. Nessun retry narrativo, grant/acquisizione reale o SQL mutante di test.

Ordinary C01: soltanto Riuji presente, nessun opponente selezionabile. Nessuna sfida creata. Master C02: creata soltanto la scena propria con Riuji e PNG legacy Keita Uro. Preparazione e mappa10×10 attraverso UI; dopo placement policy `staff_test_no_persistent_resources_v1`, simulated_pools=true, values_written=false, arena attiva. Nessuna azione dichiarata, danno, cura, difesa, passaggio o Fato.

La presenza scaduta ha inizialmente restituito `location_unavailable`; rientro normale Staff ha risolto questo solo blocco. Successivamente `combat_panel_state_v2` restituiva ready con simulazione e roster corretti, mentre `combat_panel_options_ui_v1` per Riuji restituiva HTTP400/P0001 `runtime_eligibility_full_seal_drift`. Le offerte PG mancavano; il percorso PNG conservava movimento e gestione scena. Questo è il difetto concreto da correggere; nessun PASS meccanico è deducibile dal setup.

C03,C04,G01–G04 NOT_RUN. G05 fuori campagna: il raccordo NinjaBook approvato è ancora source-only. X01 parziale: chiusura nativa e risorse protette verificate; idempotenza di azioni/costi non esercitata.

Master `e031a914-27c9-43ad-9ca6-b3f0a2195f1b` annullata via UI alle14:27:13.899951UTC; Combat `2114d8b7-7c9d-4232-85ad-cfd0a78f65bc` annullato alle14:27:13.853837UTC. Motivo audit conservato. Postflight:0Master e0Combat Staff aperti; digest prima/dopo identici per schede dei2PG autorizzati, inventario, abilità e jutsu. Dettagli SHA in STAFF_QA.json. Ripristinata vista PG, browser lasciato nella stanza. Nessuna cancellazione dello storico.

Passaggio PM: comporre delta minimo della guardia di compatibilità con i corpi realmente installati, review indipendente e versione Root coerente prima del nuovo collaudo. Nessun allentamento generico del seal, cambio dei soli pin o reinstallazione di corpi obsoleti. Attivazione Sigilli resta da definire su decisione dell'utente; Capolavoro usa azione condivisa; fuori_scontro restano narrative.
