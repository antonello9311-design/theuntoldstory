# Contratto offline · Adapter dello scambio Esame/Combat

Profilo: `combat_exam_exchange_adapter_v1`  
Identità condivisa: `combat_exam_exchange_identity_v1`  
Consumer: `NARRATORE-UNIFICATO 4.8`  
Stato: candidato offline; nessun apply, enable, deploy o smoke LIVE.

## Scopo

L'adapter compone in un solo piano immutabile:

1. l'azione del candidato già eseguita;
2. la difesa e l'esito del PNG già risolti dal server;
3. l'eventuale contrattacco del PNG già dichiarato dal server ma ancora
   irrisolto;
4. la prossima iniziativa già determinata dal server.

Il Narratore collega questi fatti in prosa. Non sceglie azione, difesa,
bersaglio, tecnica, esito, posizione, danno o iniziativa.

## Identità unica e ordine canonico

`combat_exam_exchange_identity_v1` contiene, nell'ordine:

- `exchange_id`;
- `exchange_version`;
- `root_application_id`;
- `attack_application_id`;
- `defense_application_id`;
- `substitution_event_id`, nullo salvo Sostituzione committata;
- `resolution_revision`.

La stessa identità è usata dal resolver Sostituzione, dalla ricevuta spaziale e
dall'adapter. Non esistono alias per Esame e Combat. Un consumer può aggiungere
il proprio namespace solo fuori dall'identità.

## Input server-only

`adaptExchange(input, replayRecord?)` accetta esclusivamente:

- `authority = server_snapshot`;
- identità completa e versionata;
- azione candidata `executed` con gesto, traiettoria, arto e bersaglio già
  autorizzati;
- difesa PNG `resolved` ed esito nel vocabolario chiuso;
- proiezione spaziale viewer-safe
  `combat_exam_narrative_spatial_receipt_v1`, legata alla stessa identità;
- al massimo un contrattacco `declared_unresolved`, con exact application e
  exact intent già scelti dal server;
- direttiva d'iniziativa server-side e relativa barriera di rilascio;
- sole proiezioni narrative già autorizzate per scena, dossier, schede tecniche
  e memoria stilistica.

Il client e l'IA non costruiscono questo input. Coordinate, statistiche, pool,
roll, opzioni scartate, reason code interni e identità raw non entrano nella
proiezione Narratore.

## Output

L'output separa:

- `audit_binding`: identità e digest, server/audit only;
- `narrator_payload`: payload V5 viewer-safe;
- `release_directive`: prossima fase/attore già decisi dal server, rilasciabili
  solo dopo `narrative_published`;
- `state = plan_frozen`.

Con contrattacco l'output usa `ruolo = png_attacca` e contiene una sola
intenzione: quella già dichiarata dal server. Il suo stato è
`pending_unresolved`; non contiene un esito. Senza contrattacco usa
`ruolo = png_esito` e una sola intenzione tecnica di chiusura priva di branche.

## Macchina a stati

`facts_bound → plan_frozen → narration_pending → validated → published → next_initiative_released`

- `facts_bound`: tutti gli application/event id sono già server-side;
- `plan_frozen`: digest e proiezioni sono immutabili;
- `narration_pending`: Luna può soltanto raccordare gli atomi;
- `validated`: il validatore conferma corrispondenza agli atomi;
- `published`: la prosa approvata è resa visibile;
- `next_initiative_released`: il server espone la direttiva già fotografata.

Un fallimento di Luna o del validatore non riapre né ricalcola lo scambio e non
rilascia l'iniziativa. La policy di ripiego narrativa resta del consumer 4.8 e
deve riusare lo stesso piano congelato.

## Ordine causale della prosa

1. gesto/traiettoria/bersaglio dell'azione candidata;
2. tentativo difensivo del PNG;
3. esito e conseguenza già risolti;
4. continuità spaziale della ricevuta, inclusa Sostituzione quando presente;
5. eventuale gesto/traiettoria/bersaglio del contrattacco, esplicitamente
   ancora irrisolto;
6. assetto e prossima iniziativa server-side.

Il contrattacco non può avere contatto, danno o risultato nel medesimo piano.
La sua risoluzione appartiene alla successiva exchange identity/version.

## Failure fedele, replay e concorrenza

- snapshot incompleto, incoerente o non server-side: reject senza piano;
- identità della ricevuta spaziale diversa: `exchange_identity_mismatch`;
- difesa non risolta: `defense_not_resolved`;
- più contrattacchi o esito prematuro: `counterattack_not_pending`;
- iniziativa non server-derived o barriera diversa da
  `after_narrative_published`: reject;
- stessa `request_key` e stesso digest: restituzione byte-equivalente del piano;
- stessa `request_key` con digest diverso: `exchange_request_key_conflict`;
- due builder sulla stessa exchange identity: un solo claim `plan_frozen`, loser
  stale; nessun merge o auto-switch;
- retry di generazione/validazione: stessa identità, stesso digest, stessi atomi
  e stessa direttiva; mai un nuovo contrattacco.

## Anti-leakage

La proiezione Narratore non espone coordinate raw, id di attori, id di ancora,
id di application/event, pool, chakra, PV, roll, soglie, opzioni non scelte o
reason code interni. Espone soltanto etichette/handle opachi già autorizzati,
relazioni semantiche e la ricevuta spaziale point-of-view. Il payload audit non
viene passato a Luna.

## Compatibilità con 4.8

Il contratto riusa il ruolo V5 `png_attacca`: `esito_precedente` porta il fatto
risolto; `intenzioni` contiene esattamente il contrattacco server-selected;
`scena.spazio` contiene la proiezione spaziale. Per chiudere il verticale,
NARRATIVE-AI deve sostituire l'attuale selezione deterministica fra più
intenzioni con il vincolo cardinalità uno quando è presente
`combat_exam_exchange_adapter_v1`. Non cambia alcuna meccanica.

