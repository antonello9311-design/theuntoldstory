# MISSION-GENERIC — controverifica Sources C1

Esito: VERDE nel perimetro assegnato · P0=0 / P1=0 / P2=0. MG-SRC-R1-01 risolto nella correzione aggregata A1. Reviewer NARRATIVE-REVIEW-SOURCES-C1. Unico referto C1, budget massimo30min, zero provider/gameplay. Data11/09/2026.

## Freeze verificata

Manifest integrato A1: `9064ed3428975a78135228b57e527b3b957fdbe90111d0c6c750b8d59599bf3b`.
Contratto aggiornato: `326ec822ab5516a587967bf6818048277fc876a986d27f3bef252da7ef2efa68`.

| Modulo | SHA256 |
|---|---|
| PANEL | 03ee8476754f4c231a0b5142f57bfb8d86c7b46f7432dc57bf966ff87242d2f9 |
| SOURCES | b00cb739df02342f218575ef7f2b5359a439495ccb2fbfb65500165b50876152 |
| CHOICE_SOURCES | f9f7135332725e49a29946b58c1bfa0b96ed20e6b724823346a4744a67f71102 |
| CLAN_OPTIONS nuovo | 1af3ee0aaf385591b0af05bcb9d112878982f06483b38fcf68d3b355fcd225c4 |

I primi tre moduli sono byte-identici alla review R1. Il contratto ora rende espliciti 1–4PG, una apertura Combat per fase/visita con PNG avversario, incontri in fasi distinte e assenza del PvP interno; questa controverifica non estende le capacità Clan ai PNG. Dispatch/runtime/ProviderGate sono soltanto dipendenze e non ricevono autoreview formale da questo reviewer.

## Chiusura del finding R1

MG-SRC-R1-01 nasceva da due SELECT INTO STRICT in helper delle offerte che usavano controller_user=auth.uid(), quindi non trovavano il PNG service con entrambi i valori NULL. CLAN_OPTIONS righe9–15 e24–30 sostituisce esclusivamente la condizione di proprietà:

- con auth.uid non NULL mantiene esattamente controller_user=auth.uid();
- senza Auth richiede actor_kind PNG, controller NULL e uguaglianza fra il principal del solo attore e il principal generico della transazione corrente.

Il contesto Common rimane validato da owned_context prima del SELECT. PANEL64–88 limita il principal generico a service, gate runtime/luogo, permesso vivo nel backend e nella transazione, attore appartenente a encounter/capability attivi. Principal assente, diverso o ambiguo non autorizza il nuovo ramo. Nessuna identità Auth viene simulata.

Sono state lette nuovamente sul vivo le due baseline: Hyūga bodyMD5 `7f9bdd705b4bd629401c7315f2ec2bc7`, Sharingan `110e2293ac42e3817ae977ccc92e9fe5`. Entrambe corrispondono ai pin del delta, owner postgres, SECURITY DEFINER, search_path vuoto e ACL solo postgres. Confronto testuale statico: per ciascun corpo l'anchor compare una volta; sostituzione e inversione restituiscono il corpo originario byte-identico. Non sono cambiati offerte, costi, gate o controlli successivi.

## Regressioni pertinenti verificate sulle fonti

I quattro helper di preparazione staff sono rimasti invariati. `staff_bind_ready` e `sharingan_staff_bind_ready` restituiscono false perché il SELECT non STRICT con controller_user=auth.uid NULL non trova righe; `offensive_staff_bind_ready` e `fireball_staff_bind_ready` restituiscono false già sull'assenza di Auth. Il PNG non ottiene pertanto offerte di preparazione staff o profili Clan artificiali.

Letti anche i due scope effettivi e la dipendenza combat_context. I wrapper chiamano combat_scope_core/sharingan_combat_scope_core; per un PNG registrato il contesto Common è ricostruibile, poi le guardie attore nonPG/controllerNULL respingono con SQLSTATE42501. Se manca la registrazione Common, combat_context respinge anch'esso con42501. Questi rifiuti sono dentro il blocco EXCEPTION WHEN insufficient_privilege dei due helper offerte e diventano RETURN: non bloccano più il catalogo generale e non generano tecniche non supportate. Non esiste una nuova catch globale che nasconda altri errori.

Auth umano conserva il predicato e tutta la logica precedente. Il ramo Esame non riceve automaticamente il principal generico: usa le proprie autorità preesistenti; il delta non apre né cambia il suo gate. Si attesta conservazione del comportamento precedente, non una nuova prova funzionale dell'Esame.

I filtri source/visibility, l'attribuzione PG senza nuove azioni/parole, la barriera report e la pubblicazione attraverso store nativo restano quelli già esaminati in R1, perché PANEL/SOURCES/CHOICE_SOURCES non cambiano. La nuova condizione di proprietà non aggiunge un ingresso pubblico alla loro pubblicazione e non consuma risorse o avanza un round.

## Installazione, controlli e limiti

L'ordine del manifest colloca CLAN_OPTIONS dopo Combat/PANEL, quindi le funzioni private richiamate esistono. Le due patch controllano hash del corpo, metadati/ACL e unicità dell'anchor nella stessa transazione; un drift annulla l'operazione. CREATE OR REPLACE conserva le ACL: nessun GRANT nuovo al pubblico o al service client, nessuna tabella, configurazione o tecnica abilitata.

Parsing SQL esterno pglast: PANEL17statement, SOURCES7, CHOICE_SOURCES6, CLAN_OPTIONS4, PASS. Non compilati né eseguiti i corpi PL/pgSQL. Verifiche svolte: confronto dei pin e dei delta, lettura readonly degli helper e dei rispettivi scope; nessun test locale ricreato, provider, browser, apply, enable o gameplay.

Questo verde chiude il solo perimetro Sources/Panel e MG-SRC-R1-01 nella C1 aggregata. Non certifica funzionalità live, qualità della prosa, throughput o gli altri moduli; il PM deve raccogliere i restanti referti della stessa freeze prima dell'operazione dipendente. Nessun finding residuo, microfinding o autopatch.
