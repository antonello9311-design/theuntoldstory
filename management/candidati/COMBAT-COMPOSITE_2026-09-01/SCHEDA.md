Stato: **in lavoro**

# Cantiere · COMBAT-COMPOSITE

## Scopo

Completare la catena Combat Composite senza confondere componenti già LIVE inerti, candidati offline e funzioni ancora mancanti.

## Stato operativo

- **Composite R13** è LIVE inerte a history451: consumer movimento + azione applicato, ma nessuna attivazione pubblica è implicita.
- **Moltiplicazione R4** è un candidato offline con review 0/0/0 e sigilli integri, ma la catena arriva a history453: richiede rebase sulla head LIVE verificata al momento del gate, nuova readiness e nuova review. Migration, rollback, checksum e review correnti non si alterano.
- **Sostituzione comune** è già presente LIVE come resolver R9 e porte Combat/Esame, ma l'Esame usa ancora il ramo legacy: offre senza option id opaco, sceglie localmente l'ancora e addebita localmente costo/cooldown. Il candidato P1-A attesta il resolver comune e vieta di crearne un secondo.
- **Adapter dello scambio e ricevuta spaziale** sono costruiti offline: un'unica identità lega attacco, difesa, eventuale Sostituzione, contrattacco irrisolto e iniziativa server-derived; Luna riceve solo la proiezione narrativa viewer-safe.
- **GitHub**: i 45 file verificati del pacchetto P1 sono pubblicati sul branch `combat-sostituzione-spatial-p1`; proposta aperta come PR #1 verso `main`, non unita e senza deployment.
- La baseline LIVE verificata il 04/09/2026 è head `20260903203601 esame_narratore_finale_ampiezza_006_recovery`; non è un pin permanente.

## Ordine corrente

1. Attendere il reset controllato del branch QA e verificarlo Healthy con head uguale alla produzione.
2. Innestare sul branch il resolver comune della Sostituzione sostituendo integralmente il ramo legacy dell'Esame, senza doppio costo/cooldown.
3. Eseguire sullo stesso revision set la campagna integrata P1-A/P1-B/P1-C e una sola review indipendente 0/0/0.
4. Solo dopo un gate separato potranno esistere apply, enable o smoke; Moltiplicazione resta un lavoro distinto.

## Mandato P1 Esame · 04/09/2026

Autorizzata la costruzione offline coordinata di: resolver Sostituzione, adapter dello scambio e ricevuta spaziale point-of-view. Il piano vincolante è `PIANO_P1_ESAME.md`. I tre verticali condividono una sola identità di scambio e una sola campagna QA; nessun apply, enable, deploy o smoke LIVE è incluso.

Esito offline: tre contratti verdi staticamente e pacchetto integrato `combat_exam_substitution_exchange_integration_v1` verde su 125 banchi. Il gate resta `STOP_BRANCH_QA_NOT_ALIGNED`: il branch QA osservato aveva head `20260903111028` contro produzione `20260903203601`; il reset è coordinato da un owner esterno e non viene duplicato qui.

## Vincoli

Nessun apply, recovery, enable, sessione, canary o caricamento LAND è autorizzato da questa scheda. Il round congelato di prova resta intatto.
