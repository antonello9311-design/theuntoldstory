# Regia con Master, PNG e mappe

**Regia Human aperta in LAND dal 15/10/2026.** Il collaudo Staff di Fato, Combat, chiusura e seconda puntata è stato accettato da Antonello per il rilascio. Apertura verificata sul backend alle18:17 italiane: 17/17 controlli positivi, provider IA di LAND a zero e WIP conservato. Il collaudo ordinario e i premi reali non sono stati rieseguiti.

## Cosa si può riutilizzare

Il Master umano scrive il Fato e conduce i PNG; il server controlla azioni, difese, costi, esiti e passaggi di fase. Questa modalità non richiede un narratore IA: nella campagna autorizzata chiamate e token ai provider restano zero.

La quest collega contenuti tramite identificativi e versioni: non contiene una lista rigida di nomi Nami/Tetsuna. Nuovi contenuti che rispettano i contratti già esistenti non richiedono una funzione o modifica del codice server specifica per ogni quest. Restano necessarie le normali registrazioni, approvazioni e certificazioni dei contenuti. Questo NON significa accettare qualsiasi PNG, file o mappa non approvati.

| Contenuto | Requisito effettivo | Limite |
|---|---|---|
| PNG narrativo | riferimento valido al bundle narrativo; coppia ritratto/marker corrente risolta dal server, esattamente corrispondente ai media del bundle | non abilita automaticamente il combattimento |
| PNG Combat | narrativa e scheda meccanica approvate e correnti, media approvati, bundle canonico adottato e verifica nella bozza salvata | il percorso `npc_custom` creato da zero è collaudato in Human Native Staff; il raccordo Human ordinario pubblico resta limitato a `legacy` |
| Immagine di contesto | ticket attivo della specifica bozza/puntata/fase, upload registrato, SHA/MIME/dimensione coerenti con Storage | una URL o un’immagine generica non basta |
| Arena di combattimento | `template_key` e `template_version` esistenti, stato `ready`, impronta geometrica coerente e zero errori di template | l’immagine non crea geometria, ostacoli o regole spaziali |

La certificazione canonica usa i normali producer Builder `stage → validate → compile`, controlla la ricevuta e restituisce il nuovo riferimento. Non inventa una nuova versione narrativa, non sostituisce l’approvazione dei media e non assegna capacità dal client. Nuove meccaniche, tipi di azione o geometrie fuori dal contratto richiedono invece il rispettivo lavoro di prodotto.

## Preparare PNG e mappe

1. Nell’editor usare **Crea PNG libero**, compilare identità, conoscenze e fallback umani e salvare la nuova scheda Combat con statistiche e riferimenti consentiti. Caricare e registrare ritratto e sagoma; inviare la review congiunta e approvare la versione e la coppia media. L’approvazione conserva la versione meccanica precedente e ne crea una nuova approvata. Adottare il bundle con la certificazione Builder. Questo percorso da zero è verificato nella Staff; per Human ordinario pubblico usare ancora il raccordo `legacy` approvato.
2. Inserire i riferimenti dei PNG e le mappe nelle puntate/fasi della bozza Native. Un PNG che combatte deve avere il relativo riferimento Combat valido; mantenere anche le sue presenze narrative previste.
3. Per un’arena scegliere il template e la versione qualificati; per il contesto caricare l’immagine con il ticket della fase. Sono due riferimenti distinti.
4. Nel riquadro **Quest con Master**, premere **Leggi la bozza Native salvata**. Per i profili pertinenti usare **Certifica profilo Combat: …**. Dopo una nuova certificazione selezionare i riferimenti realmente restituiti nell’editor e salvare nuovamente la bozza Native. Non continuare usando il vecchio bundle.

Per il nuovo PNG certificato scegliere il bundle realmente restituito, associarlo alla fase di scontro con la relativa arena e salvare. Premere **Verifica PNG Combat nella bozza salvata**: solo la qualifica server rende il profilo selezionabile in quel contesto. Il bundle adottato da solo può riportare correttamente «non ancora idoneo agli scontri». Nel collaudo Iori, creato da zero, ha superato questo passaggio e giocato uno scambio Human completo. La creazione di un nuovo template arena non è stata collaudata: qui si è riutilizzata una mappa valida esistente. Nuovi contenuti compatibili non richiedono codice dedicato al nome del PNG; il supporto custom pubblico ordinario resta distinto dalla prova Staff.

## Creare e pubblicare la quest

1. Completare **Tono del racconto**, **Indicazioni riservate**, **Continuità fra le puntate** e selezionare **Partecipanti** (da uno a quattro).
2. Usare **Prepara importazione** oppure **Prepara nuova versione**. Questa preparazione conserva localmente richiesta e contenuto; non equivale al salvataggio server.
3. Verificare il riepilogo; **Dettagli Staff della richiesta preparata** conserva gli identificativi tecnici per l’audit. Eseguire **Conferma il salvataggio preparato** soltanto quando la disponibilità server è autorizzata.
4. Eseguire **Anteprima**. Correggere gli errori; solo un’anteprima convalidata offre **Pubblica la quest**.
5. Usare **Apri la quest in LAND**. Preparazione, iscrizione dei PG e avvio della scena restano operazioni distinte e confermate dal server; il collegamento non concede automaticamente il controllo della Regia.

## Avviare la puntata

1. Aprire la quest in LAND con l’account del Master assegnato e scegliere la puntata. Usare **Rileggi la puntata** per vedere lo stato autorevole.
2. Preparare l’episodio nel luogo e con il gruppo ammessi. La preparazione non equivale all’avvio e non iscrive automaticamente tutti i PG.
3. I partecipanti confermano dal proprio accesso le opzioni di ingresso offerte dalla pagina. Il Master attende che il gruppo sia pronto.
4. Quando disponibili, usare **Conferma Regia umana**, poi **Avvia con Master** e **Apri conduzione e Fato**. Se un comando manca o è disabilitato, leggere lo stato anziché forzare il passaggio.

## Condurre la scena

Usare la vista Quest/Regia inline di LAND, conservando chat e testo del Fato. Pubblicare il Fato iniziale e raccogliere le role dei PG. Eseguire soltanto le transizioni offerte dal server. Il Master intreccia i PNG nel medesimo Fato; non inventa decisioni o difese dei PG.

Se la fase offre Combat, aprire lo scontro dal comando disponibile e usare la Regia ordinaria per intenzioni, difese, valutazione e risoluzione. Il server determina i fatti meccanici; la pubblicazione del Fato rende giocabile il passaggio successivo. Il ritorno pacifico è disponibile soltanto quando il server lo consente. Alla fine preparare la conclusione, pubblicare il Fato conclusivo e attendere la conferma terminale. Per passare alla seconda puntata usare il successore mostrato dalla quest: si prepara e avvia il nuovo episodio dal contesto autorevole della prima conclusione, mantenendo continuità e roster verificati. La chiusura della prima non significa che la seconda sia già partita.

In presenza di richiesta incerta usare **Rileggi la stessa richiesta** e, quando previsto, **Ripeti la stessa richiesta**. Conservare testo e identificativo originali: non creare una nuova richiesta per aggirare un esito non confermato. Premi e risorse rimangono server-side; una simulazione Staff senza premi reali non prova l’erogazione ordinaria.

Prima di chiudere pacificamente uno scontro, risolvere il round e pubblicarne il Fato tramite **Round e Fato → Avanza round**. Lasciare vuoto il nuovo round, rileggere la conduzione e usare **combat.peaceful** quando offerto; il server chiude lo scontro e apre la fase narrativa. Raccogliere le role richieste, preparare il terminale e pubblicare la conclusione senza premi. Se un invio diventa obsoleto, conservare testo e richiesta, rileggere lo stato e seguire il recupero normale; non duplicare il turno. Nel caso Tamako la riapertura normale della vista ha conservato la role e permesso l’invio.

## Fonti e copertura

Fonti permanenti nel cantiere `management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/` (sorgenti effettivamente pubblicati/installati, non un nuovo PASS):

- `HUMAN_ORDINARY_RELEASE_SOURCE.sql:222–279`: certificazione Combat, Auth/Staff/ownership/CAS, meccanica legacy, media e normale Builder.
- `HUMAN_ORDINARY_RELEASE_SOURCE.sql:428–461`: contesto Storage e arena/versione/geometria.
- `HUMAN_ORDINARY_RELEASE_SOURCE.sql:474–501`: qualificazione bundle narrativi/Combat e corrispondenza media correnti.
- `HUMAN_ORDINARY_RELEASE_CONSUMER.mjs:74–83`: costruzione variante dalle puntate salvate, preparazione locale, certificazione per binding, bottoni di anteprima/pubblicazione.
- `HUMAN_ORDINARY_RELEASE_CONSUMER.mjs:21`: journal, recupero stessa richiesta e verifica fonte.
- `HUMAN_ORDINARY_RELEASE_CONSUMER.mjs:38–42`: widget episodio/Master/partecipante separati e contesto inline.
- `HUMAN_ORDINARY_ADMIN_CANDIDATE.html:4603–4605`: adozione componente nell’Admin con normale identità e bozza corrente.

Queste righe dimostrano contratti e consumer presenti nei sorgenti. Non costituiscono un nuovo PASS runtime, non abilitano l’ordinario e non dimostrano accesso pubblico ai producer di contenuti.

## Stato della consegna e casi da non confondere

| Percorso | Stato attestato |
|---|---|
| Staff precedente: Fato, Combat, conclusione prima puntata, seconda puntata e conclusione | PASS, entrambe le scene chiuse; 48 campi reali invariati e zero provider |
| UI inline e rimozione delle descrizioni Human richieste | Pubblicate; LAND/Admin/module nel commit `51f7bb88e08a5b8aae342ed11386640a907ab026`, Pages SUCCESS |
| Base ordinaria67 | Installata inizialmente inerte con `20261015124453`; integrata dal successivo delta OwnerAccepted11, apertura `20261015161741` verificata17/17 |
| Ammissione Human e identità di rilascio | Apertura verificata Root 15/10/2026 16:17:53 UTC/20261015161741/7a992b068c1611bdb9fea6a931814c1afa43277f552a539b54e230f988032feb; materialreview e448595fc995097134ab013cb84b0921f89b8a742922d710cd9ab2458c2e93be, S `5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366`; gate Human proprio, IA generica invariata |
| Collaudo e apertura utenti | Staff PASS accettato per LAND; apertura verificata tecnicamente. Ordinary runtime e premio reale NOT_RUN, nessun nuovo PASS giocato dichiarato |

La bozza Native CV7 e la richiesta locale1d427 preparata ma non inviata restano conservate. Prima di riusare quella bozza aggiornare i due riferimenti PNG legacy con i normali pulsanti di certificazione e salvataggio Native. Le coppie ritratto/marker sono già approvate: non ripetere upload/approvazione per correggere un riferimento obsoleto. Nuove quest devono usare profili PNG approvati/canonici compatibili e mappe valide/versionate; nessuna immagine arbitraria o meccanica non supportata viene accettata. La disponibilità Human ordinaria non dipende da un rinnovo della lease Staff; nessuna nuova QA giocata è richiesta dal mandato di accettazione.
