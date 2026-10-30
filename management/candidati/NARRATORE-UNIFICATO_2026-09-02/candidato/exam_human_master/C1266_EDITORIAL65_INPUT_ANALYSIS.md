# E65 — istruzioni e input effettivi F3–F6

Evidenze raccolte in sola lettura il 30/10/2026, prima delle correzioni E65. Questa sezione descrive la diagnosi iniziale; installazioni e prove successive sono nel referto C1266_EDITORIAL65_REPORT.md. Sei SELECT mirate hanno acquisito payload persistiti, contratti firmati, assessment F5 e richieste complete registrate nel dispatch audit. I testi completi restano nella directory privata. Il rapporto non certifica qualità editoriale né un nuovo collaudo.

## Risultato

Il problema non deriva dall'assenza generale di istruzioni anti-ripetizione. Deriva anche da percorsi che applicano direttive diverse e da una presentazione dell'input che rimette il già narrato vicino alle novità, talvolta qualificandolo come ambientazione. F5 dimostra che una decisione PNG nuova e autorizzata sblocca la progressione; F6 dimostra che le sole istruzioni generali già presenti non eliminano l'eco semantico o la coda ambientale.

## Prove osservabili

| Fato | Percorso persistito | Caratteri / parole* | Massima sequenza comune con le role PG | 5-grammi comuni distinti |
|---|---|---:|---:|---:|
| F3 | Native narration/2 Combat | 470 / 79 | 3 | 0 |
| F4 | Native narration/2 Combat | 1653 / 288 | 22 e 12 | 34 e 15 |
| F5 | Scene5 + combat_peaceful | 642 / 112 | 2 e 2 | 0 e 0 |
| F6 | Scene5 | 479 / 81 | 4 e 3 | 0 e 0 |

*Tokenizzazione minuscola per parole Unicode, apostrofi separati; nessuna attribuzione automatica di plagio dalla sola metrica. F3 ha una sola role PG testuale: il Passa di Tamako era vuoto. Le fonti PNG non sono incluse nella metrica PG. F4 copia segmenti lunghi delle due role accettate, non soltanto termini meccanici necessari. F6 conserva un richiamo semantico a movimento congiunto e spazio lasciato libero, senza 5-grammi PG identici.

F3 ripete una battuta PNG di otto parole già pubblicata nella dichiarazione di Keita. F5 ripete da F4 un frammento PNG di cinque parole relativo alla propria parte; F6 ne riprende semanticamente autonomia e mancata delega. I venditori, le voci e lo spazio tra i banchi ricompaiono come chiusura: descrivono soprattutto il ritorno del fondale, con poche nuove relazioni praticabili. Custodia di foglio e monete resta coerente; questa continuità utile non va eliminata insieme alle ripetizioni.

## Cause provate nell'input e nei consumer

1. **Ultimo Fato classificato come setting in Native2.** F3 riceve come seconda fonte setting il precedente Fato di 552 caratteri; F4 riceve F3, 470 caratteri e SHA `711e7d021d0bc45ce3dec1c0e317d234e9199d650b1426c1b88c69a8353cb1ae`. `shared-scene/editorial.mjs:24–30` presenta ogni setting come `ambientazione_autorizzata`. Lo stesso testo compare nella continuity_delta. È una duplicazione effettiva e un'ambiguità di funzione, distinta dalla validità meccanica della fonte.
2. **Adozione diversa delle direttive.** La fonte corrente Edge126 aggiunge STAFF_RESPONSE_RULE e NATIVE_SCENE_RESPONSE_BOUNDARY al Native2 qualificato (`mission-generic-runtime.mjs:2941–2943`). F3/F4 precedono tale modifica: la fonte conservata Source25 mostra che il ramo Combat terminava con missionCombatDirection, non con STAFF_RESPONSE_RULE. Già esistevano indicazioni anti-ricostruzione in scenePrompts: non è corretto dire che non esistesse alcun divieto. La correzione dell'adozione è già nella versione corrente; non va ripetuta come nuovo fix.
3. **Scene5 invia cronaca letterale e memoria insieme.** F5 contiene quattro Fati per 4037 caratteri complessivi; F6 quattro per 3317. F6 aggiunge integralmente le due nuove role, 1377 caratteri. `narrativeSceneRequest:2362` invia scene_memory, last_fati e accepted_roles nello stesso oggetto, con l'ultima chiave di fase next_steps. Non c'è una proiezione esplicita che separi il materiale acquisito non da riscrivere dal delta pubblico da produrre.
4. **Ricevuta F5 molto ridondante.** Il combat_peaceful.source conserva giustamente prove PG e profili, ma il Writer riceve anche gli stessi profili in snapshot.npcs; la ricevuta privata ripete una parte della base. La ricevuta contiene soltanto l'ID dell'ultima pubblicazione, non una seconda copia del suo corpo. La prova dell'assessment non richiede che ogni copia integrale sia riproposta al Writer come materiale compositivo.
5. **Nuove decisioni minime, ampio materiale statico.** L'assessment privato restituisce per ciascun PNG solo accept/refuse/undetermined, oltre alle prove PG; non produce motivazioni o nuove battute. È intenzionale e sicuro: il Writer Scene5 può sviluppare la decisione nel profilo. Tuttavia il segnale nuovo è molto piccolo rispetto a schede, cronaca e note ripetute. L'ultima decisione non viene evidenziata come centro narrativo separato.
6. **Ambiente disponibile, non assente.** Setting e note di fase contengono attività, materiali, interessi e durate. Le note correnti F5/F6 misurano 4347/3973 caratteri; il Writer riceve le note della fase corrente, non tutte le note delle fasi future (il phase_graph ne proietta soltanto chiavi, obiettivi e transizioni). Il collo di bottiglia non è la mancanza di elenco scenografico, ma il mancato uso delle conseguenze locali come parte dello sviluppo.

## Inferenze, non dimostrazioni causali

La prossimità del precedente Fato alle azioni e la sua etichetta setting possono favorire la ripresa del suo stile e la ripetizione del fondale. Ripetere profilo, autonomia e limiti in più campi può renderli più salienti della risposta nuova. Sono spiegazioni coerenti con gli output, non una prova deterministica del ragionamento del modello. F5 non è un esperimento controllato: cambiano sia istruzioni sia percorso e disponibilità di una decisione PNG privata. Non si può assegnare il miglioramento al solo prompt.

Non risultano troncamenti delle role nei payload acquisiti. La selezione Native ha max_input_bytes=49152 e previous_included=0; F4 conserva il precedente via setting e continuity_delta. Non attribuiamo questo caso al compactUnifiedContexts, che appartiene ad altri rami. È stato successivamente acquisito il testo esatto generation_request_text registrato in c8_count_started per F1, F4, F5 e Director F5: SHA e byte verificati 4/4. Questo supera il precedente limite documentale sull’assenza di request. È la richiesta completa congelata al Count; non una cattura del traffico di rete. Pubblicazione e completamento sono prove runtime separate. Nessuna evidenza autorizza a imputare la qualità al modello o al budget di ragionamento.

## Delta generale minimo proposto

- Un'unica regola editoriale adottata dai rami effettivi: le role sono già avvenute, il prossimo Fato mostra risposta nuova e conseguenza; le formule identitarie acquisite operano nelle scelte senza essere ripetute. Non aggiungere altri divieti numerici.
- Solo nella proiezione al provider separare contesto statico, acquisito, nuove azioni/proposte, nuove decisioni autorizzate e fatti server. Conservare payload firmato, hash, ricevute e riferimenti originali; non riscriverli per rendere comodo l'input.
- Riconoscere il vecchio Fato inserito come setting attraverso identità/testo attestato e presentarlo come continuità già pubblicata; eliminare la seconda copia compositiva quando è identica alla continuity_delta. Non trattare arbitrariamente qualsiasi setting come cronaca.
- Per Scene5 mantenere una sola fonte compositiva di schede e cronaca, conservando nella ricevuta di assessment le prove e la decisione corrente; evidenziare cosa cambia adesso. Nessuna sottrazione di conoscenze, custodia o consensi necessari.
- Ambiente come spazio di interazione: usare attività e conseguenze già presenti per dare ritmo, distanze osservabili e rapporti fra interlocutori, senza imporre un paragrafo finale, una quantità di dettagli o una nuova complicazione. Le condizioni del luogo possono continuare senza essere rinominate.
- Schede e fasi distinguano stato iniziale da fatti ormai acquisiti. La personalità offre alternative di condotta; non costituisce una battuta, un gesto o un rifiuto da ripetere. Il Director acquisisce la proposta e il Writer realizza la nuova decisione attestata; nessuno inventa consenso o effetti server.

Nessun minimo di parole, dedup bloccante, retry editoriale, nuova autorità meccanica o rilassamento Auth/knowledge è richiesto. Le metriche restano consultative. Il prossimo confronto deve valutare insieme risposta alle domande, seguito concreto, uso funzionale del luogo e assenza di ricapitolazione, senza richiedere una lunghezza uniforme.


## Richieste reali acquisite: storico e baseline corrente distinti

`WIRE_EVIDENCE_SANITIZED.json` registra hash, byte, timestamp, modello, marker e shape delle quattro richieste, senza testo delle role o schede. Il raw rimane esclusivamente `private/WIRE_F1_F4_F5_DIRECTOR.json`.

| Richiesta storica | Audit | Byte verificati | Marker effettivo |
|---|---:|---:|---|
| F1 Scene5 | 1552 | 27749 | mission-editorial-response/6 |
| F4 Native2 | 1594 | 40219 | narrative-editorial/11 + narrative-master/4-npc-expression + scene-redaction/6; manca mission-editorial-response |
| Director proposta F5 | 1604 | 16499 | valutazione privata originaria senza nuova direttiva editoriale |
| F5 Scene5 peaceful | 1609 | 46035 | mission-editorial-response/6 + istruzione peaceful |

Tutte le richieste attestano gpt-6-luna, reasoning high, max_output_tokens 20000 e store=false. Nessuna contiene una richiesta di almeno 500 caratteri. Il wire F4 conferma direttamente sia l’assenza della direttiva aggiunta dopo quel Fato, sia la doppia funzione assegnata al Fato precedente: fonti.setting/ambientazione_autorizzata e fati_successivi_alla_memoria. Il wire F5 conferma che anti-ripresa PG/PNG e ambiente intrecciato erano già richiesti: non basta descrivere il difetto come prompt assente. La nuova proiezione E65 lavora su organizzazione, duplicazioni e distinzione delle novità.

La baseline dell’eventuale confronto sarà il builder vivo Edge126, non il vecchio request F4: Edge126 applica già mission-editorial-response/6 al Native2 qualificato. Il canary E65 introduce /7 e nuove proiezioni provider. Il confronto baseline/canary con le medesime fonti congela la decisione del Director; non prova da solo il comportamento di nuove decisioni o la missione completa.

### Fonti e aspettative per i tre casi proposti

1. **F1 / domanda e confronto iniziale.** Work 26a1729a-aed0-b808-0ea0-2779d8f935e5, due role accettate con autori distinti e una sola cronaca precedente. La scheda stabilisce le conoscenze private: il testo non può trasformarle tutte in rivelazioni pubbliche o attribuire nuove domande ai PG. Atteso: risposta alle richieste effettive e cambiamento locale coerente, senza ripetere la role. Custodia privata e stato iniziale degli oggetti si conservano; un oggetto non ancora pubblicamente mostrato non deve essere automaticamente esibito per arricchire il testo.
2. **F5 / proposta e nuove decisioni.** Work b6579393-9310-5c09-c26c-895d557638a6; fonte PG nel receipt, accepted_roles vuoto, nuove decisioni PNG già validate. Atteso: mettere in atto la risposta corrente; separare offerta, consenso PG provato e scelta PNG. Chiusura e fase sono quelle del receipt, non decisioni dello stile. Foglio e monete non cambiano custode senza fatto autorizzato; accettare un accompagnamento non equivale a consegnare già gli oggetti. Non recitare nuovamente promesse equivalenti o formule di autonomia.
3. **F4 / Native, ambiente ed eco.** Work bbac2a58-e2cc-4057-aef1-66f495a9b4f2; due role PG, intenzioni PNG private distinte e report risolto. Atteso: fatti meccanici immutati e nuove risposte consentite, nessun dialogo PG copiato o parafrasato. Il passato F3 è cronaca, non nuova ambientazione. Non inventare l’accettazione della proposta che allora non aveva una decisione peaceful attestata. Custodia e attività del luogo restano continue, con ambiente intrecciato quando pertinente invece della ripetizione della stessa coda.

Queste aspettative sono criteri di lettura consultativi: non nuovi validator, minimi, obblighi di passaggio o autorizzazioni mancanti. Conservare anche gli esiti brevi o editorialmente insufficienti; nessun retry per selezionare il testo migliore.
