# Checklist conclusiva · Taijutsu generici

Stato: **CHIUSA · 19/09/2026**. Le cinque tecniche ratificate hanno completato implementazione, review, collaudo protetto, revisione editoriale e apertura pubblica.

| Tecnica | Verifica live conclusa | Esito |
|---|---|---|
| Colpo concatenato del leone | una sola azione, un confronto e un pacchetto di danno; nessun danno aggiuntivo da caduta o movimento | PASS |
| Spazzata della Foglia | colpo pieno con −2 m al turno personale successivo; minimo zero, nessun cumulo o rinnovo | PASS |
| Turbine della Foglia | +1 soltanto contro Parata nel confronto corrente; margine di danno invariato | PASS |
| Calcio ascendente della Foglia | apertura −1 conservata oltre un round senza difesa compatibile, applicata e consumata sulla prima Parata/Schivata successiva | PASS |
| Entrata dinamica | rincorsa atomica 6 m, arrivo a 2 m, attacco e danno simulato; un’unica scena offensiva | PASS |

## Chiusura

- `LIVE_RESULT.json`: cinque tecniche `pass_staff`; scene ordinary e Master chiuse dal sito, storico preservato.
- `OPENING_LIFECYCLE_LIVE_RESULT.json`: ciclo completo dell’apertura di Calcio ascendente verificato, inclusi retain, reserve e consume; 4/4 chiamate provider nel budget.
- Review finale del batch `0/0/0`; gate e cataloghi 5/5 pubblici e attivi.
- Sette tecniche Taijutsu precedenti conservate inattive; zero assegnazioni e addestramenti da migrare.
- Riuji e testperfunzioni invariati; nessuna scrittura sul ledger reale.
- Testi ed Effetti allineati al regolamento: le sequenze composte valgono come un’unica azione; bonus e malus non aumentano automaticamente il danno.

Non restano casi aperti nel perimetro delle cinque tecniche. Nuove interazioni future richiederanno una regressione mirata sul solo ramo modificato.
