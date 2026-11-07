# T3 · causa del fallimento atomico della proiezione Root

Diagnosi soltanto statica. Nessuna nuova query DB, DDL, prova gameplay, provider o browser dopo l'incidente. Il PM riferisce una sola apply della variante esatta `382d8492ba5aa95bc409fbd9c5b442518afdece0d132cf1690e31cf438d39b75`, fallita con `P0001 TACTICS_INTEGRATED_PROJECTED_ROOT` nel DO adoption, linea4. Il PM ha verificato rollback e preflight completo12/12 ancora positivo. Non e avvenuta una seconda apply; Root36f e CHECKvecchio restano la baseline.

## Causa sufficiente accertata

Il preflight confronta il CHECK storico[2,3], il cui `conbin` contiene due conversioni numeriche implicite: `FUNCEXPR :funcformat 2`. Il builder ha clonato quel nodo e aggiunto il valore10, mantenendo tre `funcformat 2` come uguaglianza integrale attesa nel guard postDDL.

Il SOURCE invece aggiunge `CHECK(range_m = ANY(ARRAY[2::numeric,3::numeric,10::numeric]))`. I tre `::numeric` sono cast espliciti. PostgreSQL17 `transformTypeCast` passa `COERCE_EXPLICIT_CAST`, il cui enum vale1, alla coercizione. `cookConstraint` conserva l'espressione trasformata e `StoreRelCheck` la serializza con nodeToString. Pertanto il nuovo CHECK non puo essere uguale al `conbin` atteso a cast impliciti2: almeno `funcformat` differisce in tutti e tre i nodi.

La catena nel SQL congelato e deterministica: uguaglianza `constraint_live.j - oid = expected_after` falsa → `object_guard.ok=false` → nessuna riga in `witness` → nessuna riga nella proiezione/pg_temp.tactics_projected → guardia iniziale adoption `count(*)=1` falsa → `TACTICS_INTEGRATED_PROJECTED_ROOT`. Hashsource, cap524117 e confronto outside_db_core non correggono questa assenza di riga. La causa spiega il punto d'errore ed e sufficiente a produrlo; non si dichiara di aver letto il CHECK temporaneo dopoDDL, ormai annullato.

Il12/12 precedente provava soltanto la baseline vecchia, non la nuova serializzazione. Review0/0/0SOURCE_ONLY e tentativo fallito restano entrambi nello storico: non diventano un PASSruntime o un'installazione riuscita.

## Fonti primarie e metodo

- [PostgreSQL17 parse_expr.c, transformTypeCast](https://raw.githubusercontent.com/postgres/postgres/REL_17_STABLE/src/backend/parser/parse_expr.c): righe2604–2608, cast esplicito passato alla coercizione.
- [PostgreSQL17 primnodes.h, CoercionForm](https://raw.githubusercontent.com/postgres/postgres/REL_17_STABLE/src/include/nodes/primnodes.h): righe699–705, enum con EXPLICIT_CAST=1 e IMPLICIT_CAST=2.
- [PostgreSQL17 heap.c](https://raw.githubusercontent.com/postgres/postgres/REL_17_STABLE/src/backend/catalog/heap.c): cookConstraint2750–2779 e StoreRelCheck2015–2027, trasformazione e memorizzazione dell'albero.

Nessuna esecuzione di DDL simulata o banco DB. Il confronto usa il conbin storico realmente catturato, l'AST del SOURCE e codice ufficiale del parser.

## Aggregata1 autorizzata per il futuro

Decisione PM: sostituire nel SOURCE soltanto l'ADD CHECK con `CHECK(range_m IN(2,3,10))`, ottenendo i cast impliciti canonici coerenti con il conbin atteso a funcformat2, mantenendo enum[2,3,10], writerStaffguard, costi,9corpi precedenti, cap e tutte le guardie. Non cambiare l'atteso a castespliciti1 e non rimuovere il confronto conbin. Rigenerare tutto Source/metadata/Root/manifest/Admin/recovery e ottenere una nuova review aggregata prima di una futura apply. Conservare il freeze precedente, review e unica apply fallita negli _precedenti interni. Nessun nuovo apply o QA nella finestra scaduta22:17:48, nessun rinnovo implicito.
