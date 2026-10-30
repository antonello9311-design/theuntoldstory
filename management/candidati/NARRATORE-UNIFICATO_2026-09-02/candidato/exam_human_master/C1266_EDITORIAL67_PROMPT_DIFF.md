# E67 — delta editoriale Scene5

Stato: candidata sorgente, NON installata e NON ancora reviewata. Nessuna chiamata provider, prova, Fato o risorsa modificata. Task C1266-EDITORIAL67-EDGE-20261030, owner NARRATIVE-EDITORIAL67; quattro sorgenti di consegna integrati nei percorsi assegnati con apply del guard e check pulito. Copie private conservate.

Baseline viva acquisita dal PM: Edge131, sedici file. Runtime before SHA `36bfed288c8f8334567e251cdf675a40f2537f6dc30b58a629cd48ce1fb49ee2`; after SHA `a7fd266b1c3228212b817fbfae5fbf0aaa74ea0ffdfe669b1ba0d5337be9c32a`. Cambia un solo file, mission-generic-runtime.mjs. Gli altri quindici restano byteidentici. La candidata non cambia HTTP, DB, finanziamenti, campagne, ammissioni, payload persistiti o UI.

## Problema affrontato

Il report E66 rileva tre catene riuscite su una sola finestra, con poche copie letterali PG ma ambiente spesso in coda e responsabilità/custodia ribadite. Le istruzioni /7 contenevano già quasi tutti i divieti desiderati: aggiungere sinonimi non avrebbe risolto il problema. È emerso invece un conflitto di autorità e una ridondanza concreta nell’input.

Il builder comune inviava sempre al Writer la frase che gli attribuiva la scelta diretta senza Director, anche quando combat_peaceful conteneva la nuova decisione Director e combat_intent iniziative già autorizzate. Inoltre il setting della fase, dentro notes, poteva ripetere integralmente il setting comune. La proiezione E65 eliminava già altre copie esatte; questo duplicato rimaneva.

## Delta e priorità

| Nodo | Prima | Candidata |
|---|---|---|
| NARRATIVE_SCENE_RULE | Autorità diretta dichiarata per ogni variante; acquisito/ambiente ripetuti anche nella policy /7 | Autorità diretta soltanto per Scene5 ordinaria; base conserva apertura, osservabilità, fasi, next_step e limiti meccanici |
| Builder narrativeSceneRequestFromView | Stessa frase sull’assenza Director in tutte le richieste | ordinary authority aggiunta solo se non combat_peaceful e non combat_intent; gli altri due rami conservano le proprie ricevute e istruzioni |
| Scene5 risposta | STAFF_SCENE_RESPONSE_RULE /7, lunga e ripetuta in parte dal base | SCENE_WRITER_RESPONSE_RULE, marker mission-editorial-response/8: risposta attuale, acquisito implicito, seguito consentito, voce e luogo nel momento |
| Scene5 lettura input | input-reading/1 condivisa col Native2 | SCENE_WRITER_INPUT_RULE, marker mission-editorial-input-reading/2: mappa compatta delle sezioni, prove PG e next_step |
| Phase notes nel DTO provider | setting identico presente anche nelle note | Una sola copia quando l’intero oggetto notes.setting è strutturalmente uguale a snapshot.setting; note diverse o non JSON conservate |

La nuova policy resta generale: le convinzioni orientano scelte e modi invece di diventare formule ricorrenti; ciò che è stato stabilito continua a valere e torna nel parlato quando una domanda o conseguenza ne cambia la funzione. La scena termina sul seguito autorizzato o sul reale punto d’intervento dei giocatori. Il luogo mantiene attività e interessi propri e viene scelto per la relazione con il momento, senza quote di dialogo, dettagli, parole o paragrafi.

Le frasi su acquisito e ambiente vengono spostate dal base alla policy dedicata, non aggiunte nuovamente in coda. Restano espliciti gli stessi limiti su scelte PG, conoscenze, indizi, testimoni e conseguenze meccaniche. Il prompt non concede nuove autorità o iniziative per rendere il testo più ricco.

## Scope esatto

/8 e input-reading/2 governano esclusivamente Scene5 attraverso narrativeSceneRequestFromView: percorso ordinario live, annuncio combat_intent, raccordo combat_peaceful e preview E66 che riusa quel builder. La scelta delle iniziative resta quella appropriata a ciascuna variante.

Restano byteidentiche:

- STAFF_RESPONSE_RULE /6 per gli altri consumer generali/legacy;
- STAFF_SCENE_RESPONSE_RULE /7 e EDITORIAL_INPUT_READING_RULE /1 ancora usate dal Native2 qualificato;
- nativePeacefulAssessmentRequest, marker assessment-editorial/2: resta consent-only, non diventa planner;
- schema di output, checkedNarrativeSceneOutput, normalizer live/preview e verifiche di admission;
- createStaffPairedEditorialWriter, provenienza storica, chain privata e next_step offerto.

I criteri sono generali ma lo scope applicativo è intenzionalmente limitato al percorso del report. Non viene dichiarata una correzione globale di Human, Esame, Unified o Native2 non modificati.

## Dedupe conservativo

projectSceneEditorialInput crea una nuova copia providerPhase soltanto quando:

1. notes è una stringa JSON leggibile e oggetto;
2. contiene setting;
3. retainedJsonEqual(notes.setting, snapshot.setting) è vero sull’intero valore.

In quel solo caso la copia redazionale delle note omette setting; l’oggetto integro rimane in contesto_stabile.setting. Nessun confronto fuzzy, riassunto, taglio di stringhe, cancellazione di conoscenze o deduzione semantica. Se il parsing fallisce o i dati differiscono, la nota originale rimane identica: nessun nuovo errore o blocco.

phase, snapshot e gli oggetti originali non sono modificati; cambia solo il DTO inviato al provider dopo la validazione della fonte. Shape e campi del DTO restano quelli già esistenti; nessun nuovo schema o campo. L’uguaglianza del caso reale è documentata come confronto statico della fonte congelata, senza esecuzione di gameplay.

## Producer, consumer e verifica

Producer: narrativeSceneRequestFromView e projectSceneEditorialInput. Consumer: medesimo provider adapter e checkedNarrativeSceneOutput, senza variazioni. La porta E66 continua a derivare la vista dalla nuova decisione, mantenendo payload e contratto storici originali. Nessun issuer, server event, publisher o controllo di legalità viene cambiato.

Quindici controlli Node sintattici positivi su tutti i moduli MJS del package; ingresso TS e altri sorgenti preservati. Un secondo build produce lo stesso package integrale di sedici file, SHA `4acfe8e6d6710a5633434bee287d8a1034331ac22d508e311e07f019de371b4f`. Il controllo statico registra i blocchi di autorità/output invariati e l’impronta di ogni file.

Riproduzione:

    python3 C1266_EDITORIAL67_EDGE_BUILD.py --baseline /percorso/EDGE_BASELINE.json --output /private/tmp/percorso-candidato

Il builder verifica Edge131 e lo SHA originale del runtime, applica sostituzioni univoche e produce package, sedici sorgenti, diff e report statico. Non usa rete, DB, provider o gameplay. Una baseline diversa richiede riconciliazione, non il cambio del solo pin.

## Limiti e passaggio al PM

Questa è correzione dei sorgenti; nuova qualità narrativa e miglioramento dell’ambiente restano NOT_RUN. Il report E66 PARTIAL_NOT_PASSED non viene riscritto come verde. Il package va composto dal PM con le modifiche future a fasi/schede, revisionato e installato solo nel mandato vigente; nessuna nuova prova è avviata da questo ramo.

Copie per guard: C1266_EDITORIAL67_EDGE_PACKAGE.json, C1266_EDITORIAL67_EDGE_BUILD.py, C1266_EDITORIAL67_PROMPT_DIFF.md, C1266_EDITORIAL67_EDGE_STATIC.json. Nessun apply/deploy backend eseguito: soltanto i quattro sorgenti di consegna sono integrati via guard. Applicativi canonici, Fati e risorse restano immutati.
