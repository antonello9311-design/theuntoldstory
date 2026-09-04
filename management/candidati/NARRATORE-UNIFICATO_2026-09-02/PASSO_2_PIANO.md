# Passo 2 — Ricevuta arricchita, aula per villaggio, perimetro 10 m · PIANO TECNICO (da approvare)

> Scritto il 02/09/2026 sera dalla lettura dei corpi vivi (sola lettura). **Niente è stato applicato.** Tutte le impronte sono quelle del 02/09 sera; la migrazione le riverifica prima di toccare.

## 0. Il vincolo che decide la forma: la Edge v106 resta viva fino al passo 4
Letta la v106 per intero (27 file). Tre fatti che il piano rispetta alla lettera:
1. **`exam_narrative_context_materialize_v5` legge `_esame_luogo_prova()` per uguaglianza di stringhe.** `luce` deve valere esattamente «naturale dalle finestre» (o «lampade interne»), altrimenti `AUTHORITATIVE_LIGHT_UNKNOWN` → la Edge risponde 500 **senza ripiego**; `dove` = «l'aula interna della prova» dà `exam_room`; la riga «piccoli supporti di legno da esercitazione sono disposti ai margini del tatami» dentro `dettagli` dà `training_edges`; e l'oggetto `sostituzione` deve essere **identico** a `{oggetto: 'un piccolo supporto di legno da esercitazione', provenienza: 'margine del tatami'}`, altrimenti `anchor_ids=[]` e ogni «supporto di legno» nella prosa diventa `ANCHOR_SOSTITUZIONE_INVENTATO`. Il catalogo V5 è chiuso (`_exam_context_validate_v5`: un solo `anchor_id`, quattro `environment_ids`). ⇒ **`_esame_luogo_prova` cambia solo per aggiunta**: le quattro chiavi di oggi restano byte-uguali, le nuove chiavi si affiancano. Le 8 ancore entrano nel catalogo V5 al passo 4, insieme alla Edge (DB e Edge cambiano in coppia).
2. **Nessuna cifra nel referto e nessun numero nella scena.** `verificaPayloadV4` rifiuta `esito_precedente` se la sua serializzazione contiene una cifra qualunque; `numeriNelPayload` rifiuta ogni valore numerico fuori da `scena.spazio.*_m`. `_esame_referto_modello` già spoglia i numeri dal referto, ma le stringhe nuove devono essere **solo parole** (niente «A1», niente «5 m»). ⇒ gli id delle ancore sono slug senza cifre; le posizioni al modello sono parole («a sinistra, verso il fondo»); la tabella numerica resta nel server.
3. **Il payload di una ricevuta deve essere stabile** (`source_digest` in `exam_narrative_gate_snapshots`; se cambia fra due chiamate → `AUTHORITATIVE_SNAPSHOT_CONFLICT`, 500 senza ripiego). ⇒ le chiavi nuove derivano da `esame_scambi` e da tabelle statiche, mai da `now()`; e **la migrazione si applica solo con zero prove `aperta`** (guardia nel DO block).

Le chiavi aggiunte al payload **non vengono rifiutate** dalla v106 (nessun controllo di chiavi sconosciute: `scena: Record<string, unknown>`, cast finale) e arrivano al modello tali e quali (`JSON.stringify(payload)` nel prompt). Il validatore v106 non le legge. Quindi il passo 2 è **retro-compatibile**: la v106 continua a funzionare, con più fatti a disposizione del modello.

## 1. Perimetro 10 m (decisione 02/09)
**Regola:** ogni posizione dell'Esame sta in `[0, 10]`; `_esame_muove` e `_diversivo_posizione` non si toccano (condivise col combat legacy). Il blocco va **dove si scrive o si offre** una posizione — censimento fatto, 6 funzioni, 14 siti:

| Funzione | Siti | Cosa cambia |
|---|---|---|
| `_esame_prova_opzioni` | 2 `_esame_muove` (avvicinamento/ritirata) + 1 `_diversivo_posizione` | il risultato passa da `_esame_bordo(pos)`; `v_avv_ok/v_rit_ok` e `distanza_dopo` si calcolano sul valore bloccato, così «ritirata» sparisce da sola sul bordo |
| `_esame_png_intenzioni` | 3 `_esame_muove` | idem: `v_pos := _esame_bordo(...)`; `if v_pos = v.pos_png then continue` fa già il resto |
| `_esame_prova_azione_esegui` | 2 `_esame_muove` → `pos_candidato` | `v_pos_new := _esame_bordo(...)`; il rifiuto «non cambierebbe la posizione» resta valido |
| `_esame_png_gioca` | 1 `_esame_muove` → `pos_png` | idem |
| `_esame_moltiplicazione_candidato` (4 arg) | 1 `_diversivo_posizione` → `pos_candidato` | idem |
| `_esame_moltiplicazione_candidato` (5 arg) | 3 `_esame_muove` → `pos_candidato` | idem; il controllo `mod(...,5)` resta sui metri **dichiarati**, il bordo può accorciare l'esecuzione (il tatami finisce lì: fatto dichiarato nel referto come «fermato dal bordo») |
| `_esame_diversivo` | 1 `_diversivo_posizione` → `pos_png`/`pos_candidato` | idem (settima funzione: il censimento l'ha trovata fuori dall'elenco iniziale delle sei) |

`_esame_bordo(p integer) → integer` = `least(10, greatest(0, p))`, nuova, IMMUTABLE, senza GRANT pubblico (ACL come le sorelle: postgres + service_role).

**Posizioni iniziali:** oggi 0 e 5 (`esame_prova_apri`, INSERT + DEFAULT di colonna). Con il bordo a 0 il candidato **non potrebbe mai arretrare**. Proposta: **candidato 2, sfidante 7** (stessa distanza di ingaggio di cinque metri — l'incipit non cambia — e terreno alle spalle per entrambi: due passi al candidato, tre allo sfidante). Cambia l'INSERT di `esame_prova_apri` e i due DEFAULT. La land riceve solo `io.pos`, `avversario.pos`, `distanza`: nessun bordo cablato lato client (il 60 in `esSpostamentoScelto` è un'anteprima; i metri disponibili li decide il server). ✋ **Da confermare: 2 e 7.**

**Fasce:** con separazione massima 10 esistono solo «a contatto» (≤2) e «corta» (≤10). I `case` con «media/lunga» (`_esame_prova_opzioni`, `_esame_stato_json`, `_esame_png_scena`, `_esame_risolvi`) restano com'erano (rami irraggiungibili, nessun rischio); si riscrivono al passo 4 con la Edge. Aggiunto un CHECK? **No**: un CHECK su `pos_*` fermerebbe una prova aperta mal migrata invece di correggerla; la guardia sta nelle funzioni, e il banco lo prova nei due sensi.

## 2. L'aula per villaggio
- **`_esame_aula_villaggio(p_prova) → text`**: `Suna` se `locations.region` della sessione è Suna, altrimenti `Konoha` (oggi la Test Room non ha regione → Konoha, come nella prova di Riuji).
- **`_esame_aula_ancore(p_villaggio) → jsonb`**: la tabella **numerica** delle 8 ancore per villaggio (id senza cifre, oggetto, x, y, taglia, note), fedele a `AULA_ESAME_KONOHA.md` / `AULA_ESAME_SUNA.md`. Solo server: non entra mai nel payload.
- **`_esame_luogo_prova(p_prova)`**: le quattro chiavi di oggi **identiche**; si aggiungono `villaggio`, `aula` (tre-quattro righe in parole dalla scheda: pietra/legno, luce a riquadri/lame, clessidra/stendardo, brocche/rastrelliere — **senza la parola «pietra» né «pali da allenamento»**: sono nelle liste rosse del validatore v106, si usa «roccia» e «palo di legno»), e `ancore` = le 8 ancore in **parole** (`{id, oggetto, dove: 'a sinistra, verso il fondo', taglia: 'alto quanto un uomo'}`), niente numeri.
- La linea dell'Esame (posizioni 0–10) corre **al centro del tatami**, da sinistra (lato rotoli/rastrelliere, candidato) a destra (lato finestre, sfidante); ogni ancora ha una distanza dalla linea calcolata dalla tabella. È la convenzione che lega l'1D di oggi al 2D delle tavole senza cambiare il motore.

## 3. La ricevuta arricchita (P1) — che cosa scrive `_esame_risolvi`
Tre colonne nuove, nullable, su `esame_scambi`: `bersaglio text`, `conseguenza text`, `ancora text` (le righe vecchie restano null = «non specificato»). Nessuna colonna su `esame_prove`.

Nel referto (`esame_narrazione_cicli.referto`, chiavi **nuove**, solo parole):
- `bersaglio` — la zona **decisa dal server** con il dado della prova (`_esame_dado(seme, _esame_indice(scambio, meta, chi, 'zona'))`, quindi deterministico e riproducibile), pesata per genere: colpo/tecnica fisica → spalla, braccio, torace, fianco, ventre, gamba, viso; genjutsu → «nessuna: la tecnica lavora sulla mente»; Assalto su copia → la zona è della copia. **Vale anche quando il colpo non arriva** («dove mirava»): il racconto di una parata sa che cosa è stato parato.
- `conseguenza` — la **classe** fisica, mai una frase (R3: niente formule): da (danno, bersaglio): `nessuno` → «nessuna»; `lieve` → «segno» (rossore, graffio, stoffa segnata); `serio` → «livido che sale» su spalla/braccio/fianco/gamba, «fiato mozzato» **solo** su torace/ventre, «taglio superficiale» su viso; `grave` → «ferita che segna» + «appoggio incerto» (sangue ammesso: decisione 02/09); `fuori combattimento` → «a terra». Il Narratore la traduce in prosa; il validatore del passo 4 la controlla per classe.
- `postura_difensore` — «in guardia» / «arretra di un passo» / «a terra un istante» / «a terra», da danno.
- `movimento` — dai `pos_*_prima` vs `pos_*` già in `esame_scambi`: «nessuno», «il candidato ha guadagnato terreno», «lo sfidante ha ceduto terreno», «fermato dal bordo del tatami».
- `iniziativa` — «passa al candidato» / «passa allo sfidante» / «la prova si chiude»; `scambio_prossimo` in parole.
- `ancora` — per una Sostituzione riuscita: **l'ancora più vicina alla posizione del difensore** sulla linea, dalla tabella del villaggio, in parole (`{oggetto, dove}`); la stessa ancora non si ripete nella prova finché ce ne sono altre libere (segnata in `esame_scambi.ancora`). La gittata resta quella meccanica di oggi: l'ancora è scenografia autoritativa, non un movimento.
- `segni` — la **memoria dei colpi**: i colpi già andati a segno in questa prova (`chi`, `bersaglio`, `conseguenza`, «poco fa/prima/all'inizio»), dalle colonne nuove. È il rimedio al «fianco colpito» inventato: la continuità delle ferite viene dal server, non dalla prosa precedente. La stessa lista entra anche in `scena` (`_esame_png_scena.segni`), così i cicli `png_attacca` la vedono senza referto.

`storia_narrativa` resta nel payload com'è (la v106 la usa per continuità e anti-ripetizione); il declassamento «stile, non fatti» è un'istruzione del prompt: passo 4.

## 4. Metodo, guardie, rollback
- Una migrazione `2026090xxxxxxx_esame_passo2_ricevuta_aula_perimetro_001.sql`, un DO block: (1) `raise` se esiste una prova `aperta`; (2) verifica delle impronte dei 9 corpi toccati (le sei del censimento + `_esame_diversivo`, `_esame_risolvi`, `_esame_luogo_prova`, `_esame_png_scena`, `esame_prova_apri`); (3) sostituzioni esatte contate una volta ciascuna (come la 002); (4) `create function` delle quattro nuove (`_esame_bordo`, `_esame_aula_villaggio`, `_esame_aula_ancore`, `_esame_referto_zona` per il calcolo di bersaglio/conseguenza), ACL come le sorelle, `search_path=public`; (5) `alter table esame_scambi add column … ` ×3; (6) verifica finale: ogni funzione ricompila, `_esame_bordo(-5)=0`, `_esame_bordo(15)=10`, `_esame_aula_ancore('Suna')` ha 8 righe, `_esame_luogo_prova` di una prova di prova conserva le quattro stringhe legacy byte-uguali.
- **Dry-run in rollback** sulla prova di Riuji del 02/09 (`5c8dda6b…`) con `set local role`: si ricostruisce il payload e si verifica che (a) non contenga cifre in `esito_precedente`, (b) non contenga numeri fuori da `spazio`, (c) `exam_narrative_context_materialize_v5` produca ancora `anchor_ids=['training_support_wood']` e `environment_ids` a quattro voci.
- Rollback depositato: inverte le sostituzioni guardate sulle impronte nuove, `drop function` delle quattro, le colonne restano (nullable, innocue) — rollback asimmetrico dichiarato, come lezione a memoria.
- Registro migrazioni: 457. GRANT: nessuna funzione nuova è pubblica; le firme pubbliche non cambiano. Vincoli allentati: nessuno. Vincoli aggiunti: il bordo [0,10] e le posizioni iniziali 2/7 — dichiarati.
- Collaudo: prova in Test Room (deroga 002 + i due flag) con Riuji: ritirata dal bordo negata, Sostituzione con ancora nominata, referto con bersaglio/conseguenza/segni, prosa v106 ancora viva (10/12 o meglio).

## 5. Decisioni chieste ad Antonello
1. Posizioni iniziali **2 e 7** (in luogo di 0 e 5). 
2. La tabella (danno × zona → conseguenza) del §3 così com'è, o con modifiche.
3. Le tre colonne nuove su `esame_scambi` (bersaglio, conseguenza, ancora).
4. Le parole «pietra» e «pali da allenamento» fuori dall'aula finché vive la v106 (si usano «roccia» e «palo di legno»).
