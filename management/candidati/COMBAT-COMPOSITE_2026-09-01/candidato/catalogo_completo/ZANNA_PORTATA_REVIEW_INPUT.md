# Zanna Perforante · allineamento della portata descrittiva

Propongo di cambiare soltanto `portata` da **Corto** a **Contatto (carica separata)** per l’UUID `b076a976-c75b-4b5a-8813-b0e8e2c3af03`. Il testo ha 26 caratteri rispetto al limite 30 del controllo Admin. Il §6.3.2 imposta un singolo bersaglio a contatto. La traiettoria di avvicinamento è risolta separatamente dal movimento nativo e può mancare quando il PG è già a contatto.

## Autorità di Combat

- `clan_inuzuka_private.staff_profile_apply` scrive `range='contatto'` nel profilo Staff. `zanna_contact_valid` usa `melee_eligible` nell’ordinario. Con Master usa distanza finale 2 o `zanna_master_endpoint_v1`, che verifica una capacità di movimento rilasciata e la stessa distanza finale. `master_actor_offers` applica l’eccezione 2 m per l’UUID Zanna anche se lo snapshot di partenza riporta una fascia generica. `zanna_freeze` attesta un singolo bersaglio, contatto, costo 5 e danno base 10.
- La `gittata` presente nella riga è `corta`. È metadata macchina in `combat_v2_character_snapshot`, `ninja_book_internal.ronda_ability_refs_resolve_v1` e nella coppia legacy `combat_opzioni`/`combat_dichiara_attacco`. Gli ultimi due usano `_fascia_metri`, che oggi traduce corta in 10 m e contatto in 2 m. La Test Room usa la precedenza `gittata → portata → media`; la prima è già valorizzata per Zanna. I lettori di visualizzazione `my_abilities`, `tecniche_suggerite`, catalogo Land, Scheda e Admin espongono fascia o testo corrente. I consumer legati a tecniche diverse, come `my_defenses` e i resolver sigillati di altri clan, non ammettono l’UUID Zanna per questo ramo.
- Cambiare `gittata` richiederebbe una review di contratto per snapshot, fallback e percorsi legacy. L’eccezione nativa Zanna già applica il contatto. La proposta usa esclusivamente `portata` e la Test Room conserva la stessa fascia. Nei punti UI che mostrano entrambi i dati, il testo distingue il colpo finale dalla tratta di carica.

## Proiezioni narrative

I fatti nativi derivano dal profilo congelato e dalla risoluzione effettiva. `combat_consumer_private.narrative_context` ricava la distanza dalla geometria e il movimento dai relativi eventi. `narrative_catalog_fields_v1` legge `portata` per un elenco chiuso di altre tecniche. Zanna non compare tra gli UUID ammessi. `narrative_tech_sources_v1` non proietta il campo. La proposta cambia il testo visibile della tecnica e conserva il materiale del Fato, l’offerta, l’autorità di movimento, i danni e i costi.

## Impronte, installazione e limiti

La sola lettura server su Root4987 ha verificato il confronto JSONB completo, il medesimo valore effettivo della fascia Test Room, zero trigger applicativi abilitati e zero regole di riscrittura sulla tabella. L’impronta attuale è `a637815c68abe10648b9d6d0b076ae0c4523ff02141bbf83eb3fc1f5bb675c60`. Quella prevista con il testo proposto è `158c6a3051c267eeb123dfc537560c5b1ae34962e4d556b7d55ef7b5ce6b6e90`. La recovery ritorna all’impronta iniziale.

Il sorgente e la recovery acquisiscono un lock, verificano l’impronta completa prima del cambio e ricontrollano contenuto e impronta dopo la scrittura. L’unico UPDATE possibile riguarda `portata` nella riga attiva identificata. Entrambi gli script hanno superato il parser SQL/PLpgSQL. Il preflight live, la review indipendente e l’eventuale apply restano al responsabile dell’integrazione. Nessuna esecuzione del delta durante la preparazione.

Sono emerse due difformità distinte. Il requisito testuale dice Kekkei Genkai ≥40, mentre il dato strutturato e il §6.3.2 indicano 30. Il catalogo ha danno base 20, mentre il profilo e il freezer nativi attivi usano 10. Entrambe restano fuori dalla modifica di portata e richiedono il perimetro appropriato prima di intervenire.
