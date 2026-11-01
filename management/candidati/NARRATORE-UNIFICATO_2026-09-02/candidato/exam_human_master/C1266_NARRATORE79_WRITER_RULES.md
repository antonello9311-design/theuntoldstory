# Narratore79 · regola editoriale e consumer

mission-narrative-space/1. Usa missione, fase, mappa, mondo e schede come fonti per creare lo sviluppo della scena. Il Writer sceglie parole, toni, gesti e reazioni osservabili dei PNG presenti e autorizzati e sviluppa l’ambiente coerentemente con la situazione raggiunta; schede e mappe offrono una base da sviluppare, non un inventario chiuso di dettagli. Queste scelte espressive non richiedono una ricevuta dedicata per ogni dettaglio. Dichiarazioni e cronaca danno il punto già acquisito: il Fato ne sviluppa il seguito senza riepilogarle. Mantieni scelte e intenzioni già stabilite. Le conoscenze possedute dal PNG possono emergere nel dialogo secondo persona e situazione, rispettando i confini e le riservatezze esplicite delle fonti; le informazioni ignote restano ignote. Nuove azioni o effetti meccanici, consensi con effetto di gioco, trasferimenti di risorse o custodia certificata, posizioni autorevoli e passaggi condizionati seguono le autorizzazioni server. Gestualità e dettagli di scena non modificano questi valori. Decisioni e battute dei PG restano ai giocatori; turni e attese restano quelli del flusso. Nel testo mostra soltanto la scena.

## Consumer installati interessati
- unified Staff response: single rule definition
- constant STAFF_SCENE_RESPONSE_RULE
- constant SCENE_WRITER_RESPONSE_RULE
- constant NATIVE_SCENE_RESPONSE_BOUNDARY
- Mission IA adapters only: disambiguate inherited expressive vs mechanical language
- ROLE_WRITER_RULE fallback: expression stays tied to current facts/attempts
- ROLE_WRITER_RULE fallback: no invented gameplay justification
- ROLE_WRITER_RULE allowed context: not limited to perception
- roleWriterRule speech-context qualifier stays mechanical
- roleWriterRule npc_speech_context: expressive response vs gameplay
- staffMissionEditorialDirection: same canonical narrative-space rule
- staffMissionEditorialDirection: private storage is not a blanket disclosure ban
- staffMissionEditorialDirection raccordo
- staffMissionEditorialDirection esito
- withDirector Combat mission-only direction
- missionCombatDirection: report facts allow expressive realization
- unified composition entry_png: mechanical attempt vs expressive detail
- unified empty NPC plan: no mechanical initiative, no forced muteness
- unified non-empty NPC plan: intent is not a dialogue script
- unified no baseSystem: no blanket ban on NPC-held knowledge
- unified no baseSystem: distinguish facts and expressive choices
- freeNarrative: same narrative space, mechanics and deferred conditions preserved
- report-only /4: new editorial rule identity, transport and memory unchanged

## Confini della modifica

Solo testo e adattamento del prompt in mission-generic-runtime.mjs. Lo schema, le proiezioni, la memoria7080, i normalizzatori, il Director e le attese restano identici. I moduli condivisi Combat/Esame non cambiano. Il limite report5000car e output20000token resta; i limiti e minimi di altri consumer non vengono ampliati. I blocchi combat_intent descrivono tentativi già autorizzati e non concedono nuovi turni. Gli eventuali passaggi futuri fullflow26 restano solo candidati.

Nessuna prova, generazione, campagna, enable o modifica UI. Qualità narrativa NOT_RUN.
