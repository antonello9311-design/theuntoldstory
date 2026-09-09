# 04 · LAVORI APERTI — cantieri, dipendenze e prossimi passi

> Allineamento documentale del 09/09/2026. Una pagina riscritta in posto; storia in `storico/04_LAVORI_APERTI_diario_fino_20260902.md`. Al massimo **tre cantieri in lavoro**; un nuovo cantiere richiede mandato PM e uno slot libero. «In uso» lo dichiara Antonello. Le finestre e i budget delle vecchie campagne non si riattivano leggendo questo tabellone.

## I tre cantieri documentali aperti
| Cantiere | Stato e dipendenza | Prossimo passo nel mandato esistente | Responsabili |
|---|---|---|---|
| `management/candidati/CLAN-L1_2026-09-01/` | Raccordo locale16/16SQL PASS e review0/0/0; Controllo OFF/ON live PASS, postflight integro. Uchiha candidato13file, qualifica aperta. | Preflight/recovery/gate raccordo, poi smoke Clone; completare collegamenti Uchiha. Flussi dopo mosse Sabaku presenti, non dopo tutti i clan. | PM, DB/COMBAT, LAND/RULES |
| `management/candidati/COMBAT-COMPOSITE_2026-09-01/` | in lavoro; pannelli e contratti condivisi con Clan e Narratore. LAND099 e recupero Edge23 attestati; certificazione generale configurata ancora rossa. | Alla futura assegnazione PM, allineare il consumer ai contratti correnti e trattare i finding nei rispettivi mandati. Non ripetere il rilascio096 o aprire una nuova scena per effetto di un vecchio handoff. | COMBAT-CORE, DB-CORE, LAND-UI |
| `management/candidati/NARRATORE-UNIFICATO_2026-09-02/` | cantiere condiviso aperto; task Narratore conclusa e archiviata. Esame e Combat hanno percorsi e prove distinti. Recupero singolo riuscito; successiva tranche ordinaria Passa+attacco attestata, con postflight protetto senza differenze. | Residui consegnati al PM, task Clan archiviata; per l'Esame consolidare gli ultimi riscontri sulle ripetizioni e sul dialogo PNG. Campagna20 conclusa, nessuna ripetizione o rigenerazione da questo tabellone. | NARRATIVE-AI, QA, COMBAT, PM |

**Task operative:** le8precedenti restano archiviate. Punto1 e punto2 completati;31contenuti del processo più registro e consegna caricati/verificati su GitHub il09/09, testa b97925f073e59699dbbadc2ac63d6f3255ef29aa. Nella stessa task PM prosegue Clan con owner e prenotazioni: raccordo locale0/0/0, ripristino operativo in preparazione, Uchiha ancora da integrare. Vecchi rossi terminali preservati. Monitor PAUSED; anti-stop distinto. Nessun quarto cantiere.

**Ordine Clan conservato:** Marionetta → Sabaku → Hyūga → Uchiha → Nara; si supera temporaneamente un ramo con un vero blocco prodotto. Preparazioni indipendenti possono procedere in parallelo, con un owner per file e contratti condivisi coordinati. Le sei scelte del 09/09 sono già ratificate; gli OPEN residui sono quelli della scheda CLAN, non quelli delle task precedenti. Aburame/Akimichi/Hoki/Inuzuka conservano il rinvio di rilascio a dopo Missioni; le preparazioni interne autorizzate non sono aperture generali.

**Staff corrente:** Riuji e testperfunzioni nei percorsi protetti, stessa scena mantenuta aperta su mandato. Test Room utenti070 differita per questa tranche, con residuo di allineamento conservato. Il budget di ciascun blocco e il postflight sono gestiti dal suo owner, non da un limite notturno scaduto. Nessuna tecnica Clan nell'Esame per effetto di questi lavori.

## Altri lavori e decisioni da preservare
| Area | Stato | Seguito |
|---|---|---|
| REC Esame | `EXAM-REC-OPEN_2026-09-04`: proposto, non applicato | Approvazione del piano ancora necessaria prima dello sviluppo; QA-ESAME-REC-REAL resta parcheggiato. Nuovo lavoro tecnico soltanto con slot/mandato. |
| Missioni / PNG | Fondazioni e materiali presenti, uso automatico completo non attestato | Riconciliare il percorso della prossima missione con gli owner. PACK004 già ratificato per canary; guida generale già scritta ma da ratificare nel suo insieme. Mandato missioni miste con base Konoha e PNG via Builder conservato; nessuna data, spesa o nuovo run implicito. |
| Narrativa / scene libere | Fonte comune e progetti di memoria già esistenti | Collegare contesto, azioni/difese e risultati server a una narrazione continua; verificare distribuzione per profilo. Scontro è un caso della Regia; IA senza autorità su valori, scelte o pensieri dei PG. Discovery scene libere123 da riconciliare, non da riscrivere da zero. |
| Pagine | Rilasci attestati nel registro; background scheda chiuso il07/09 | Preservare i rilasci. Requisiti recuperati: editor ridimensionabile con bozza mantenuta, motivi delle limitazioni al movimento; proposta per rendere comprensibili le tecniche non disponibili. Priorità pannelli già assegnata. |
| Training / Accademia | Checkpoint datati nelle aree | Riconciliare prove recenti e difetti concreti; non dedurre abbandoni da pochi eventi storici. Ratifica narrativa del singolo allenamento conservata senza effetti DB impliciti. |
| Piattaforma | QA permanente ritirato; snapshot DB09/09,11:32UTC:495 migrazioni/head20260909112705 | Docker ordinario e Test Room protette. Branch temporaneo solo per rischio non coperto e costo autorizzato. Nessun repair del branch eliminato; igiene preesistente separata. |
| Documenti / processo | Punti1e2 completati e depositati;33blob esatti, inclusi registro e consegna | Processo operativo nella cartella; copie delle impostazioni esterne Claude/Cowork da verificare separatamente. |
| Nuova utenza | Analisi da completare | Adulti italofoni, anche nuovi al play-by-chat, interessati a GDR/anime/manga/Naruto. Budget da definire dopo l'analisi; nessuna campagna o spesa avviata. |

## Parcheggi e rinvii da rispettare
`QA-ESAME-REC-REAL-001` fino al fix REC e alla seconda REC genuina · `TEST-ROOM-TESTER-AVANZATO` senza nuovo mandato · Ninja Book G11-* e127D nei rispettivi gate canary, da riconciliare con le consegne successive · voce narrativa066/067 e proposte P2–P8 storiche da confrontare con il consolidamento corrente · TACTIC-015/016 e integrazione040+042 superate · UI-005/UI-003 Esame da verificare sul vivo prima di riuso · Sensei IA Training secondo il gate dell'area · `TASK-AI-ITALIANO-COMUNE-001` storico, distinto dal successivo mandato della fonte editoriale comune.

Restano proposte di sviluppo: Tester avanzato, iniziativa manuale Master, azioni non offensive, PNG del Book nella Regia umana, refactor delle pagine, guida del motore e ritiro degli avvii legacy preservando le sessioni esistenti. Non sono nuove task avviate da questo allineamento. Non si spostano o archiviano cantieri di altri owner automaticamente.

## Consegne
Ogni owner aggiorna SCHEDA, HANDOFF, STORICO e la propria area; il PM mantiene questo riepilogo. Stato dei caricamenti e inventario esatto in `aree/PUBBLICAZIONE.md`. Richieste immagini e decisioni prodotto si verificano nell'area prima di riproporle: vecchi conteggi non sono un fabbisogno corrente certificato. L'indice delle task conserva provenienza, decisioni valide e limiti del recupero; non occorre rileggere tutti gli archivi per iniziare un lavoro ordinario.
