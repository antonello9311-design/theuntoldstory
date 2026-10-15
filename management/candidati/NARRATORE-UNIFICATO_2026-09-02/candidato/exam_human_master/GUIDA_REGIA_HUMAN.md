# Regia con Master, PNG e mappe

**Guida operativa · disponibilità ordinaria non ancora aperta al 15/10/2026.** Audit documentale dei sorgenti congelati Source67 e consumer; nessun nuovo collaudo, apply o rinnovo. Il precedente percorso Staff completato non certifica l’apertura ordinaria: Source67 è installata inerte, configurazione e qualifica ordinaria restano da eseguire.

## Cosa si può riutilizzare

Il Master umano scrive il Fato e conduce i PNG; il server controlla azioni, difese, costi, esiti e passaggi di fase. Questa modalità non richiede un narratore IA: nella campagna autorizzata chiamate e token ai provider restano zero.

La quest collega contenuti tramite identificativi e versioni: non contiene una lista rigida di nomi Nami/Tetsuna. Nuovi contenuti che rispettano i contratti già esistenti non richiedono una funzione o modifica del codice server specifica per ogni quest. Restano necessarie le normali registrazioni, approvazioni e certificazioni dei contenuti. Questo NON significa accettare qualsiasi PNG, file o mappa non approvati.

| Contenuto | Requisito effettivo | Limite |
|---|---|---|
| PNG narrativo | riferimento valido al bundle narrativo; coppia ritratto/marker corrente risolta dal server, esattamente corrispondente ai media del bundle | non abilita automaticamente il combattimento |
| PNG Combat | template/versione narrativa approvati e correnti, legame meccanico approvato, bundle canonico adottato, media approvati correnti | il raccordo `Certifica profilo Combat` qui esaminato ammette meccaniche esistenti di tipo `legacy`; non crea nuove statistiche o capacità |
| Immagine di contesto | ticket attivo della specifica bozza/puntata/fase, upload registrato, SHA/MIME/dimensione coerenti con Storage | una URL o un’immagine generica non basta |
| Arena di combattimento | `template_key` e `template_version` esistenti, stato `ready`, impronta geometrica coerente e zero errori di template | l’immagine non crea geometria, ostacoli o regole spaziali |

La certificazione canonica usa i normali producer Builder `stage → validate → compile`, controlla la ricevuta e restituisce il nuovo riferimento. Non inventa una nuova versione narrativa, non sostituisce l’approvazione dei media e non assegna capacità dal client. Nuove meccaniche, tipi di azione o geometrie fuori dal contratto richiedono invece il rispettivo lavoro di prodotto.

## Preparare PNG e mappe

1. Nell’editor normale preparare e approvare il profilo narrativo. Per un PNG da scontro selezionare un legame meccanico `legacy` già approvato e compatibile: il pulsante qui descritto non crea una nuova meccanica. Preparare ritratto e marker con il percorso media esistente e approvare la coppia.
2. Inserire i riferimenti dei PNG e le mappe nelle puntate/fasi della bozza Native. Un PNG che combatte deve avere il relativo riferimento Combat valido; mantenere anche le sue presenze narrative previste.
3. Per un’arena scegliere il template e la versione qualificati; per il contesto caricare l’immagine con il ticket della fase. Sono due riferimenti distinti.
4. Nel riquadro **Quest con Master**, premere **Leggi la bozza Native salvata**. Per i profili pertinenti usare **Certifica profilo Combat: …**. Dopo una nuova certificazione selezionare i riferimenti realmente restituiti nell’editor e salvare nuovamente la bozza Native. Non continuare usando il vecchio bundle.

Il bottone di certificazione non è un editor universale di PNG: adotta la fonte approvata esistente. L’audit qui svolto non certifica l’intero percorso di creazione da zero del Builder o l’autoring di un nuovo template arena; tali percorsi vanno documentati dalle rispettive superfici prima di prometterne la disponibilità agli utenti.

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
| Backend ordinario67 | Installato inerte, migrazione `20261015124453`; postflight18/18 |
| Configurazione Staff della nuova versione e identità Human | Config5 recensita 0/0/0, non applicata; readback13:05:23UTC: gate OFF e zero identità/qualifiche Human |
| Collaudo ordinario e apertura utenti | NOT_STARTED / NON APERTA; autorizzazione ricevuta, esecuzione ancora pendente |

Nella prova in lavorazione, la richiesta locale CV7 preparata è conservata e non inviata. Prima di prepararne una nuova vanno aggiornati i due riferimenti PNG alle coppie media attuali mediante i normali pulsanti di certificazione e salvataggio Native. Il Mac bloccato impedisce questi passaggi; non è richiesta un’altra autorizzazione procedurale.
