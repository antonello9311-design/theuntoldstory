# Palmo Curativo: collaudo Human notturno

TASK-ID: COMBAT-CATALOGO-NIGHT-PALMO-HUMAN-QA-20261119. Esito: PASS nei quattro casi assegnati; percorso ordinario senza Master ancora NOT_RUN. Apertura pubblica OFF.

Versione installata: Root `b3e9fcf8927cf169969f53dc642fe9d4b37fac38450e51c816f51bf4e59a926f`, SourceB `085482ab9fe948763eaf77e9bdd3f8580e2b86f95be108b3198c765828139278`. Nessun apply o deploy durante questa campagna.

| Caso | Risultato reale in Staff |
|---|---|
| PNG Passa per ultimo, senza attacchi | PASS, round2 risolto automaticamente; publisher accetta il Passa roleless completato, nessun blocco. |
| Bersaglio allontanato dopo dichiarazione | PASS, cura attesa30 ma applicata0, PV52→52, chakra curatore120→100; reason `target_no_longer_eligible_or_in_contact`. |
| Curatore sotto attacco | PASS, offerte Schivata/Parata presenti e Sostituzione assente; Parata realmente dichiarata e risolta. Danno36→12, cura16 fino28, chakra65→45. |
| Destinatario a terra | PASS, round7 PV0/stato fuori; round8 Palmo alleato0→30, revived=true/stato attivo, chakra100→80, nessun turno aggiuntivo nello stesso round. |

Scena propria Master `d3f6d8d3-51cd-4399-8ee4-98e62c6ff705`, Combat `507c9d41-86cd-43b5-985a-8b978d45feda`. Otto round risolti, otto Fato pubblicati, tutti gli hash meccanici validi. Otto è il limite autorizzato: il round9 aperto dal normale avanzamento non è stato giocato. Report completi e ledger sanitizzati nel JSON omonimo; nessuna role integrale conservata nel referto.

Budget fissato: 45min, cutoff nuovi casi23:12:11UTC, deadline23:27:11UTC, una scena/otto round/450UI/zero provider. Effettivo: 302UI come limite superiore,22 invii role compresi gli otto Fato, zero provider/token/USD. Chiusura Combat23:10:00.788UTC/Master23:10:00.995UTC; teardown browser entro23:10:30UTC.

Postflight: quattro digest reali identici prima/dopo (schede, inventario, abilità, jutsu); tutte le scritture risorse simulate e applied_amount0, tutte le cure applied_real_gain0, values_written=false. Solo la scena propria è stata annullata nativamente; storico, dichiarazioni, report e messaggi conservati. Scheda Chrome esistente lasciata alla mappa in modalità PG; sola IAB2 creata da questa campagna chiusa.

Osservazioni: nel round3 il Sasso(3,5) impediva l'attacco diretto Rina(2,5)→Riuji(4,5). La diagnosi indipendente readonly ha confermato first_block_t0.124999; normale riposizionamento nel round4, nessun bypass o patch. Nel round6 i controlli Master sono rimasti disabilitati dopo il cambio attore: ricaricamento normale, ingresso dalla mappa nella Staff e ripresa della stessa scena hanno recuperato il pannello senza ripetere dichiarazioni. Causa del pannello non dimostrata, difetto UI da isolare se ricorrente.

Passi successivi: collaudo ordinario senza Master entro una nuova campagna finita, poi Paralisi. I PASS storici di formula/cap/costo/autocura e cura alleata restano conservati; nessuna qualifica per casi non eseguiti. Questa consegna non completa l'intero catalogo notturno.
