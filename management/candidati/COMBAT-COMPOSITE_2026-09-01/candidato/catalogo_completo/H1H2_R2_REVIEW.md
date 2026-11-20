# Revisione indipendente H1/H2 R2

**Esito sorgente 0 P0, 0 P1, 0 P2.** Bundle `a9487d1b3df0dc85ad619d797e2fe17a8a6b28ddcec7f9b88a412e1799d24203`. L’apply R1 resta registrato come annullato con rollback.

Il controllo di R1 richiedeva 34 funzioni condivise, ma la SELECT aveva assegnato a quel manifest le sole due funzioni modificate. Altri quattro manifest erano senza acquisizione e il conteggio degli header richiedeva sia tre sia due. Entrambi i template R2 acquisiscono i sei array e verificano cardinalità e digest con `IS DISTINCT FROM` prima di usare i dati per alias o descriptor.

| Acquisizione | Firme distinte | Proiezione rispetto al vivo |
|---|---:|---|
| Shared | 34 | Array invariato |
| Private | 66 | Array invariato |
| Native | 3 | Array invariato |
| Peer | 6 | Solo i due digest di E52 |
| Header modificati | 2 | Solo i digest di Akimichi ed E52 |
| Compatibilità | 2 | Solo i due digest di E52 |

La verifica ha estratto le SELECT dai template, conservato i campi e l’ordinamento e letto tutti gli array in una transazione PostgreSQL `READ ONLY`. Le chiavi e i digest completi coincidono con la ricostruzione indipendente del candidato. Cinque SELECT corrispondono alla precedente versione installata. La sesta seleziona i due soli DDL della correzione. I digest proiettati sostituiscono unicamente quelli del corpo e della definizione per le firme interessate. I due footer sono identici e il confronto byte circoscrive il delta alle acquisizioni e relative guardie. Root, missioni, gate e corpi SQL mantengono i contratti di R1. Il controllo sintattico ha verificato 7 statement nel source e 5 nella recovery.

Alle 08:52:04 UTC la Root `4987b6ec…` e la riga `c2b73ffb…` confermavano due ammissioni Missioni qualificate e zero scene o inviti Staff pendenti. GitHub conferma blob `ebbe0d60…` e Pages `44704697096` completato con successo. La precedente ricevuta di dominio del medesimo commit, con build 2, è quella vincolata al bundle. Il limite stimato della Root resta 523832 byte su 524288.

L’Entry effettiva richiede la ricevuta di questa review, il calcolo di P confermato da SELECT, l’inversa esatta dei due innesti e una verifica dedicata. La recovery richiede anche la Root successiva all’installazione e la chiusura delle prove. Entry, apply R2, gameplay Staff e apertura pubblica restano `NOT_RUN` in questo referto. Zero chiamate provider.
