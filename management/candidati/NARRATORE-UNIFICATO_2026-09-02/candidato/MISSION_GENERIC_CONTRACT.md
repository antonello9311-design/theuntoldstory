# MISSION-GENERIC/1 — raccordo missioni configurabili

Stato: candidata A1 congelata dopo prima review; controller fasi e motore riusati. Controverifica indipendente da eseguire, nessuna disponibilità live dedotta da questo contratto.

## Scope

Una missione usa 1..N PG e 0..N PNG presenti per fase; piccoli gruppi come caso ordinario, senza vincolo 2v2. Più incontri possono aprirsi e chiudersi in fasi diverse. Tre missioni distinte devono mantenere chat, roster, stato, mappe, autorizzazioni e budget separati. Roster legale e limiti tecnici derivano dal server; non introdurre un nuovo massimo di gioco. Le scene narrative senza PNG combattenti non aprono incontri fittizi. La capacità attuale del catalogo è 1–4 PG per missione, senza il vecchio vincolo esatto 2PG+2PNG. Ogni fase meccanica della candidata contiene un solo punto di apertura con 1–12 PNG combattenti, di cui almeno uno opposto al team dei PG; gli incontri multipli si distribuiscono in fasi o visite diverse. PvP interno alla missione non è implementato da questa candidata. Il catalogo server espone queste capacità e il validator respinge una configurazione incompatibile prima della sigillatura.

## Fonti canoniche da riusare

- mission_plan_versions/steps/transitions/requirements e mission_run_state/events/outbox: piano, grafo, CAS e avanzamento esistenti. mission_internal.transition è il solo controller di avanzamento; non creare una seconda macchina delle fasi.
- Board start/staff_publish: roster e run già creati atomicamente nel percorso ordinario. Non invocare bind su un run già esistente.
- Regia Combat: actors PG/PNG, offerte Ninja Book e risolutore server. L'adapter di incontro service esistente contiene guardie canary: estrarre il core preservando i controlli, non togliere le protezioni globalmente.
- mission-arena-source/1 e Common panel: fonte scelta prima dell'avvio; configurazioni di incontro referenziano solo fonti/zone approvate.
- shared-scene di mission_narratore_ai v19 e combat_narratore_ai v25: moduli identici. Riutilizzare per scambi risolti, senza action/round fittizi per incipit e dialoghi.

## Configurazione additiva

Estensione versionata collegata al piano approvato, con step esistente, elenco PNG narrativi/profili Combat approvati, schieramenti, arena e zona, trigger ammessi, riferimenti alle transizioni del piano. Nomi/fasi/numero di attori non sono hardcoded nel consumer. Congelare la configurazione nel run prima dell'incipit; cambi editoriali valgono solo per nuovi run.

Non riscrivere nb_mission_packages package/1.0 o le versioni già sigillate. I campi specifici Nodo non diventano requisiti delle nuove definizioni. Contenuti storici sono fonte, non runtime da riattivare automaticamente.

## Autorità dei trigger

Il client o l'IA possono indicare un intento/una scelta offerta, mai inviare evidence valida per arbitrio. Il wrapper server rilegge fonti e costruisce l'evidence richiesta da mission_internal.transition.

- Scelta PG: autore autenticato, partecipazione effettiva, opzione offerta dal piano nello step/versione corrente, richiesta univoca.
- Evento Combat: evento/ricevuta e relativo incontro appartengono alla stessa missione e revisione; esito terminale verificato dal server, non dalla prosa. Il filtro opzionale combat_outcome ammette any (default), pg_win, pg_loss o draw. Vittoria/sconfitta dipendono dagli schieramenti superstiti del resolver; vietata sovrapposizione di due transizioni per lo stesso esito.
- Evento narrativo: interpretazione solo entro le opzioni permesse dal piano e role originali complete; non equivale a riuscita meccanica, acquisizione inventario, scoperta o rivelazione non autorizzata. Se mancano i fatti richiesti, la transizione resta non disponibile.
- Trigger spaziale: coordinate e movimento validati dal motore, entro la zona autorizzata; la sola immagine non costituisce geometria.

La candidata espone scelte PG e terminali Combat. Le interfacce per eventi narrativi/spaziali restano riservate ai rispettivi produttori di evidence; non sono offerte dall’editor né dichiarate implementate senza il produttore verificato.

Gli eventi entrano una sola volta per sessione, richiesta e versione. Replay coerente restituisce la ricevuta originale, collisione o versione superata fallisce; nessun retry automatico di mutazioni dall'esito incerto.

## Incontro e continuità

Un incontro ha identità propria nel run, step e visita, roster esplicito, mapping actor_key→attore nativo e fonte arena congelata. Chiudere un incontro non chiude la missione. Risultati e risorse seguono i percorsi nativi; un nuovo incontro non ripristina PV/chakra arbitrariamente. Ramo pacifico senza apertura Combat. Terminale missione usa chiusura/premi esistenti una sola volta; in simulazione nessun premio/progresso o effetto sulle schede reali.

## Narrativa e scelte PNG

Un work item server per evento e sessione identifica run, step, visita, incontro opzionale, revisione, authority receipt, attore opzionale, kind choice/narration e limiti. Claim/lease/replay sono per evento, non un mutex globale delle missioni.

Choice: un solo PNG per richiesta, con propria persona/proiezione e offerte legali; restituisce selezioni Common, con validazione server completa. Nessun danno, costo, posizione o esito prodotto dal modello.

Narration: il payload viene congelato dopo tutte le scelte e ricevute necessarie a quel segmento; un testo unico coerente sul segmento completo. La fase narrativa usa contesto missione, lo scambio risolto usa shared-scene. Attribuzioni e visibilità per attore preservate.

Pipeline provider: una autorizzazione e un consumo per ogni chiamata effettiva; timeout, usage quando disponibile e limite sessione. Un dispatch lavora un evento e termina. Mai riusare l'incipit Board a tre chiamate non conteggiate come budget corretto.

## Isolamento e compatibilità

Il ramo simulato riusa risorse simulate native in luogo is_test; non modifica characters.is_test, schede, inventario, XP/Ryo/grado né chiude scene altrui. Il vecchio A18 prepare con lock globale e ripristino successivo è escluso. Non aggirare Staff mission_id: integrare il contesto missione nel percorso protetto autorizzato con controlli espliciti, non cancellare la guardia.

Esame, ordinary, Clan e canary storici mantengono contratti e gate esistenti. Editor e pannelli usano le stesse versioni del prodotto nelle superfici autorizzate. Disponibilità iniziale riservata alla prova pertinente; nessuna apertura generale implicita.

## Criteri della verifica

Controlli statici e review indipendente sulla composizione e sui permessi prima del rilascio; collaudo funzionale nel sito, nessun ambiente locale ricreato. Nodo come contenuto di riferimento, nuova esecuzione protetta, storico immutabile. Casi: roster variabile, due incontri successivi, ramo pacifico, replay/ripresa e sessioni indipendenti. Budget provider e roster del collaudo si fissano quando il candidato integrato è pronto; nessuna identità PG inventata per simulare tre sessioni contemporanee.
