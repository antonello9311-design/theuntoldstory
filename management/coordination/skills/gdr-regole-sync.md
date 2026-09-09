---
name: gdr-regole-sync
description: Usa questa skill ogni volta che si cambia una regola, una formula, un costo, una soglia o un sistema del GDR «The Untold Story». Impone la procedura che tiene allineati REGOLE.md e regole.html, il backup preventivo, la riga di changelog (numerata solo nel markdown), la verifica del bilanciamento dei tag e la pubblicazione verificata secondo AGENTS. Attivala prima di scrivere la modifica, non dopo.
---

# gdr-regole-sync — cambiare una regola senza spaccare il regolamento

**Metodo vigente di progetto:** dalla cartella The Untold Story seguire `AGENTS.md` e `management/coordination/AVVIO_LAVORO.md` per mandato, owner, prenotazioni, budget e consegna. Questa skill conserva i dettagli tecnici del proprio dominio; non assegna file né riapre task o autorizzazioni. Preparare gli output in copia e integrarli con il guard del progetto; i gate di produzione restano distinti.


**La regola d'oro:** a ogni cambiamento di regole o di sistema si allineano **sempre insieme** `REGOLE.md` **e** `regole.html`. Mai uno solo dei due. Un regolamento disallineato è peggio di un regolamento incompleto, perché il giocatore legge l'HTML e lo staff legge il markdown.

---

## La procedura, in ordine

### 1 · Prima di toccare qualsiasi cosa: il backup

```bash
cp regole.html /tmp/regole.html.bak
cp REGOLE.md  /tmp/REGOLE.md.bak
```

Serve per il confronto finale delle dimensioni e per tornare indietro senza drammi.

### 2 · Individuare **tutti** i punti toccati

Una modifica quasi mai vive in un paragrafo solo. Prima di scrivere, cercare il concetto in entrambi i file e fare la lista completa dei punti da aggiornare. Le sezioni che si tirano dietro a vicenda più spesso:

- §3 creazione ↔ §8.4 tetti per grado (se cambia un tetto, cambia anche l'esempio di creazione)
- §5.2 doppia chiave ↔ tabelle dei costi XP ↔ `clan_techniques.req_stat_value` a database
- §4.2 turno ↔ §4.5/4.6 distanze (azioni e portate si citano a vicenda)
- §8.5/8.6 promozioni ↔ scala XP giornaliera degressiva
- Qualunque prezzo dei premi ↔ la tabella dei premi ↔ il modulo di richiesta in `scheda.html`

### 3 · Modificare `REGOLE.md`

È la fonte di verità del regolamento. Si scrive qui per primo.

### 4 · Rispecchiare in `regole.html`

Stessi contenuti, resa HTML. Due cautele:

- Le entità vanno scritte come **UTF-8 letterale** (`—`, `·`, `è`, `§`), **non** come entità nominate.
- Sulle righe HTML lunghe e concatenate lo strumento `Edit` fallisce: in quei casi si usa Python con `assert s.count(old) == 1` prima di sostituire (vedi `gdr-pagine`).

### 5 · La riga di changelog — **solo in `REGOLE.md`**

Il changelog numerato **esiste soltanto in `REGOLE.md`**, in fondo. `regole.html` **non ha** la tabella del changelog: non aggiungerla.

> **Ultima riga scritta: 28. La prossima libera è la 29.**
> Dopo averla usata, aggiornare questo numero qui e in `dossier/05_CONVENZIONI.md` §2.

Una riga per cambiamento, non una per file toccato.

### 6 · Verificare il bilanciamento dei tag

Un tag scompensato rompe il rendering **in silenzio**: la pagina si carica, ma metà del regolamento sparisce.

```bash
for t in p ul li div table section; do
  echo "$t: $(grep -o "<$t[ >]" regole.html | wc -l) aperti / $(grep -o "</$t>" regole.html | wc -l) chiusi"
done
```

Confrontare anche le dimensioni prima/dopo rispetto al backup in `/tmp/`: una variazione inattesa di decine di KB è un segnale.

### 7 · Se la regola ha un riflesso a database

Se il cambiamento tocca valori che vivono anche nelle tabelle (`req_stat_value`, `xp_cost`, `chakra_cost`, `danno_base`, `trainings_required`, prezzi dei premi), **il regolamento da solo non basta**: passare a `gdr-sql`, mostrare il piano ad Antonello e aspettare l'approvazione prima di eseguire.

### 8 · Pubblicazione verificata

Applicare AGENTS e gdr-chiusura: caricare autonomamente i soli file approvati e verificati, con riconciliazione remota, commit e controllo del dominio. Registrare la coppia in PUBBLICAZIONE e distinguere i file caricati da quelli bloccati. Le firme client/server richiedono un rilascio coordinato; deposito sorgenti, apply DB e deploy Edge non si sostituiscono.

---

## Controlli finali, prima di dire «fatto»

- I due file dicono la **stessa cosa**? (non «cose compatibili»: la stessa cosa)
- Tutti i valori nuovi sono **multipli di 5**?
- La riga di changelog c'è, ha il numero giusto, ed è **solo** nel markdown?
- I tag sono bilanciati?
- Se ho aggiunto di mia iniziativa un vincolo che mancava, **l'ho segnalato esplicitamente** ad Antonello perché lo controlli?
- Ho registrato i file caricati e quelli rimasti locali con motivo?
