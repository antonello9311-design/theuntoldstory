# Audit LIVE read-only · P1 Combat Esame

Data: 04/09/2026. Nessuna riga applicativa è stata modificata.

## Baseline

- Produzione: head `20260903203601 esame_narratore_finale_ampiezza_006_recovery`.
- Una prova Esame risulta aperta; non è stata identificata o toccata.
- Branch QA: head `20260903111028`, quindi indietro rispetto alla produzione; control plane `MIGRATIONS_FAILED`.

## Componenti Sostituzione già presenti

- `combat_spatial.anchor_is_legal` usa profilo range server-side, distanza euclidea, cooldown `round < last_commit_round + 3` e destinazione fail-closed.
- `combat_spatial.substitution_commit` blocca instance/window/actor/object, rivalida versioni, consuma anchor, sposta l'actor, registra cooldown/event/receipt.
- `combat_v2_substitution_resolve_internal_v1` aggiunge commit chakra5/reazione e payload before/impact/anchor/after.
- Le porte pubbliche Combat sono limitate ad `authenticated`; resolver interno e wrapper Esame non sono eseguibili da `anon` o `authenticated`.
- Tabelle capability/cooldown/link/option/source/receipt pertinenti: zero righe nello snapshot.

## Gap reale di innesto Esame

1. `_esame_prova_opzioni` espone ancora una Sostituzione legacy al beat previsto e non prova l'uso di `exam_substitution_options_v1` con option id opaco.
2. `_esame_risolvi` accetta ancora `reazione='sostituzione'` senza exact option id e sceglie l'ancora tramite `_esame_ancora_scegli` dopo l'esito.
3. `_esame_risolvi` addebita localmente chakra e cooldown; invocare il wrapper esistente senza sostituire questo ramo produrrebbe doppio commit.
4. Il referto Esame espone una sola distanza/fascia legacy e un campo `ancora` testuale; non lega ancora la ricevuta operation-scoped a before/impact/anchor/after.
5. L'iniziativa è costruita come testo dentro lo stesso referto; il contratto P1 richiede un fatto server separato e impedisce che il Narratore la decida o anticipi il contrattacco.

## Conseguenza architetturale

Non serve un nuovo motore spaziale. Serve un delta sugli owner port Esame che:

- materializzi/usi le porte Sostituzione già presenti;
- sostituisca integralmente il ramo legacy per costo, cooldown, anchor e posizione;
- emetta `combat_exam_exchange_identity_v1` e la ricevuta narrativa v1;
- lasci ogni altra difesa sul percorso corrente;
- resti fail-closed se il profilo, l'instance o la capability non sono pronti.
