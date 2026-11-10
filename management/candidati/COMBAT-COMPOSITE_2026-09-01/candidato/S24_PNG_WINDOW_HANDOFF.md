# S24 PNG — finestra installata, collaudo in attesa

TASK-ID: COMBAT-S24-PNG-WINDOW-20261110 · owner PM-COMBAT-S24.

Scope toccato: sola finestra della policy Staff, Root integrata e pin Admin; soli casi T6 Copertura PNG, T7 Diversivo PNG, T8 due attacchi PNG sulla stessa formazione. Punto cieco già PASS escluso; nessun Restore, scelta PNG forzata o apertura pubblica.

Contratti: Root ed742e942e3d421f0272239c51bb55bd820efc9de07c0cb7191bc927269fa917, parent a614eba9e2c8c43042cfcc24ddfe64d1205c84bc85a0315ff940b710dd7654fa; 90 header, un solo DDL con quattro timestamp. Generic160 invariato. Migrazione combat_s24_png_window_20261110 applicata con readback positivo. Admin commit 7f6f425b8b8d8c46078ef55ac2b3a609f853e92c, SHA256 6d4ddde840a3ada33c3a8b683e6ab9b91f0386c8c01caeb1dcac6bd8e9eaa012.

Decisioni: finestra 08:48–10:18 UTC del 10/11/2026, stop nuovi work 10:12 UTC; massimo 12 nuovi work e 24 HTTP incluse anomalie, senza rinnovi durante la prova. Fonte cumulativa 18 Count/18 Gen/36 HTTP/0.0577523 USD. Spesa storica totale 0.0385702 USD; upper pianificato 0.0919462 USD entro 0.10 USD.

Prove: preflight 08:40 UTC con zero sessioni Staff aperte, pending e hold, custodia e fonte immutate; review indipendente 0/0/0, SHA5899bfa1462f891f8bbcf63a33fcb7e30e4f6c487c23cfeb22c3f3e89cc87798. Nessuno Start e nessuna nuova chiamata provider. Recovery precedente chiusa e conservata.

Rischi/OPEN: Pages42786153551 build SUCCESS, deploy timeout durante syncing_files alle09:04 UTC; retry dei soli job falliti accettato alle09:05 ma ancora in coda alle09:08. Dominio Admin ancora al parent. Qualifica runtime T6/T7/T8 NOT_RUN; LifeCore Writer non ancora raggiunto.

Passaggio PM: attendere distribuzione e riscontro del Root corrente nel dominio, poi unico Start della fonte originale, sequenza E1/N2/N3 finita, chiusura nativa e postflight di costo/custodia. Non considerare il commit o l'installazione come PASS.
