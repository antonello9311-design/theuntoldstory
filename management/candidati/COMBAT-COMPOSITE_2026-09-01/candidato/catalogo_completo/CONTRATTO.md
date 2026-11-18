# Contratto di integrazione del catalogo Combat — ricognizione 18/11/2026

Scope: fonte soltanto. Zero provider, scene, iscrizioni o mutazioni DB. Snapshot catalog.baseline.json e letture vive pertinenti dello stesso incarico. Il file combat_runtime_audit.json conserva 371 schede (362 clan_techniques + 9 jutsu), gate, hash delle funzioni, grafo chiamanti e aggregati storici. Non è una qualifica funzionale generale.

## Cosa significa oggi «integrata»

Il mapping pubblico Genin ha **45 righe** e il gate foundation storico staff_room_genin_spatial_smoke_v1 è OFF/RED_SIMULATION. Non è il catalogo esclusivo del motore; non usare assenza/presenza nel mapping come criterio di integrazione.

public.combat_v2_character_snapshot carica tutte le abilità attive acquisite e i jutsu acquisiti attivi. Costo/danno NULL diventano **0 nel solo snapshot**. Il pannello Master offre genericamente principale/rapida non difensiva, non di_scena, non diversivo, non passiva; applica poi i filtri dei domini. combat_v2_actor_ability usa lo snapshot e adapter dedicati. Quindi una tecnica non mappata può già comparire come attacco numerico: questo non esegue automaticamente guarigione, controllo, trasformazione, evocazione o altri effetti della descrizione.

Tre evidenze separate: (a) proiezione/attacco del core; (b) adapter/gate e lifecycle dell’effetto; (c) collaudo Staff pertinente della stessa versione. Una dichiarazione storica risolta non copre da sola durata, dispel, consumo, bersagli e modalità con/senza Master.

## Producer, consumer e invarianti

| Confine | Autorità/produttore | Consumer da comporre |
|---|---|---|
| Catalogo acquisibile | clan_techniques, jutsu, acquisizioni server | scheda/admin/catalogo, snapshot del personaggio |
| Offerta legale | snapshot, combat_v2_actor_ability, round_options_authoritative, adapter dei clan, profili spaziali | master_actor_offers e import_ordinary_offer; stesso pannello Land |
| Dichiarazione | offerta server con attore, round, bersagli, versione, idempotency key | combat_v2_action_declare / defense_declare, freeze dei domini |
| Risoluzione | combat_v2_round_resolve e adapter tipizzati | effetti, risorse simulate/reali appropriate, ledger, round report |
| Persistenza e fine | combat_effects_private lifecycle_before_report, settle_native_target; lifecycle del dominio | turni personali, scadenza, liberazione, congedo, morte, chiusura |
| Fato e ripresa | fatti/ricevuta server e barriera di pubblicazione | consumer ordinario, Master umano, Regia IA; mai numeri decisi dalla narrazione |

Preservare firme, ACL, search_path vuoto, controllore e attore, acquisizione, costo reale, geometria server, CAS, ricevuta e replay. Nuova capacità prima solo Staff protetta; nessuna modifica alle schede reali durante la prova. Nessun nuovo vincolo o allentamento proposto da questa ricognizione.

## Componenti già riusabili

- **27 passive di clan** in world_passive_catalog_v1; gate pubblico v2 ON. Non diventano pulsanti d’attacco: offrono permessi e capacità riconosciute dal dominio.
- **10 configurazioni mantenute attive/revisionate**: Byakugan I–IV, Sharingan I–IV, Sabbia I e Quattro Zampe. Usare activation/upkeep/config_versions e i rispettivi toggle/lifecycle, mai la conversione del costo NULL.
- Gate dedicati pubblici presenti per 5 Taijutsu Foglia; 6 Elementali other; 2 Suiton; Scudo di Terra; Rotazione Suprema; Aghi e Corpo Tossico Hōki. I 17 ID sono nel JSON. Altri rami dedicati vivi: Jūken/16 chiusure, Uchiha Palla, Aburame, Akimichi parziale, Nara Possesso, Inuzuka, Marionettisti/Fili e Sabaku clone/armatura/flusso.
- Stato dei gate non uniforme: tattiche Moltiplicazione v2 **solo Staff** (ordinary/master/generic false). Non riaprire quei rami spostando indiscriminatamente tecniche in una categoria generica.
- 31 ID distinti hanno almeno una dichiarazione V2 risolta in storico, compresa un’arma. Questo è indice di uso, non certificazione di ogni effetto.

## Famiglie da completare con contratti tipizzati

| Famiglia | Riuso possibile | Parte che il semplice danno del core non implementa |
|---|---|---|
| Cure, chakra, stamina, antidoti, rianimazione | ledger/turno/bersaglio/effetti comuni; porta Palmo Curativo esistente | quantità/limiti, frequenza, destinatari alleati, consumi, isolamento e ricevuta Combat |
| Genjutsu, paralisi, controllo e sigilli | Dispersione, immobilizzazione, Nara e lifecycle effetti | applicazione/resistenza, durata, azioni negate, liberazione e immunità specifiche |
| Evocazioni e poteri di compagni | attori-compagni, autorità del controllore, geometria e pannello | ingresso PG, slot/congedo/durata, pool, abilità per famiglia e combo |
| Trasformazioni e modi superiori | config mantenuta, Akimichi/Inuzuka, snapshot/freeze | modificatori e nuova geometria/azioni/lifecycle specifici; non solo un bonus narrato |
| Danno nel tempo/veleni/assorbimento | combat_effects_private e Hōki tipizzati | fonte/target/turno escluso, tick/cap/stack, interruzione, recupero e riflessi sulle risorse |
| Barriere, gabbie, aree e multibersaglio | targeting/geometry, Scudo, Flussi, arena capabilities | entità/persistenza, bordo/coperture, ingressi/uscite, numero destinatari e condizioni specifiche |
| Sensori, furtività, teletrasporto e spazio-tempo | vista/permessi passivi e movement capabilities server | conoscenza limitata, destinazioni legali, costo e condizioni; non fabbricare coordinate client |
| Poteri clan superiori/Cercoteri/leggendari | stesso protocollo di offerta/freeze/risoluzione | profilo meccanico proprio per ciascuna capacità speciale (es. Susanoo, Kamui, rianimazioni), prerequisiti e lifecycle |

Questa è una partizione del lavoro, non l’affermazione che ogni riga di queste famiglie sia assente. I 227 record classificati CORE_PROJECTION_NOT_FULL_EFFECT_CERTIFICATION richiedono confronto descrizione→effetti per separare veri attacchi semplici da poteri parzialmente rappresentati. Le 40 voci fuori scontro non richiedono un attacco Combat; le 22 passive non già coperte dal catalogo delle 27 richiedono prova del relativo dominio, non un pulsante indiscriminato. Le 28 inattive complessive (25 clan_techniques + 3 jutsu) restano intatte.

## Fonte canonica dei numeri e anomalie

Ordine operativo: contratto/regola vigente ratificata e configurazione tipizzata approvata → dato catalogo vivo non nullo coerente → descrizione numerica esplicita coerente col contratto → OPEN se manca una regola. Il fallback COALESCE(NULL,0) non autorizza a riempire il catalogo con zero. Non derivare costi/danni dalla sola categoria, rango, potenza o somiglianza con un’altra tecnica.

**Hōki, conflitto concreto:** needle_ability (prosrc MD5 bf7f1a8b18eb0e1e555c1351dbe609f5) emette costo 5, danno 10 e portata 15m; il catalogo attuale riporta danno_base 15. Corpo Tossico è escluso dall’attacco generico nel percorso Hōki e applica veleno da contatto corporeo valido tramite body_contact/apply_poison; il suo danno_base 15 non è un danno diretto del potere. Riconciliare i campi col contratto già ratificato e i referti, preservando gli effetti veleno; non classificarli come riempimenti neutri di NULL.

## Prima aggregata concreta proponibile

1. Catalogo editoriale: applicare soltanto campi esplicitamente ricavabili senza cambiare bilanciamento, preservando inattivi e dati completi; segnalare separatamente conflitti come Hōki.
2. Matrice per ogni ID: capacità richieste dalla descrizione, profilo core/dominio esistente, scostamenti e OPEN numerici; nessuna etichetta di integrazione generale derivata dal mapping.
3. Runtime: riusare un contratto di profilo tipizzato per famiglia (versione, prerequisiti server, bersagli/geometria, azione, costi, effetti con parametri ammessi, durata/rimozione, idempotenza, fatti pubblici/privati). Il client sceglie soltanto offerte firmate dal server; non invia parametri di gioco liberi.
4. Prima famiglia nuova soltanto quando il suo profilo è completo e i numeri hanno fonte: offerte→dichiarazione/freeze→resolver→lifecycle→ledger/report→Fato/ripresa. Integrare un solo delta end-to-end e recovery conservativa, review indipendente pertinente, poi Staff e regressioni dei componenti effettivamente toccati. Non creare un fallback che dichiara un effetto descritto ma non lo esegue.

La ricognizione consegna il contratto e le fonti per continuare; non afferma completate tutte le tecniche né richiede ricertificare componenti condivisi invariati.

