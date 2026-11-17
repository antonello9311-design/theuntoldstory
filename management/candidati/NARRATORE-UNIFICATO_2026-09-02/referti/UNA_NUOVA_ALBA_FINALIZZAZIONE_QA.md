# Una nuova alba — chiusura definitiva Staff e pubblicabilità senza PNG

17/11/2026 · Esito PASS. Chiusure Staff qualificate e pubblicazione effettiva senza PNG verificata.

## Pubblicazione effettiva e bacheca — 17/11/2026, 20:49 UTC

Mandato MISSION-UNA-NUOVA-ALBA-PUBBLICAZIONE-20261117. Prima della pubblicazione il server restituiva SQL42702 «column reference kind is ambiguous». Tre tentativi del medesimo comando conservavano la stessa request_key e lasciavano la transazione annullata, zero pubblicazioni e bozza v3/hash invariati. L’ultimo tentativo strumentato ha identificato l’errore. Correzione minima in materialize_ai_v3, una singola SELECT qualificata con alias em3_step per kind/plan_version_id/step_key, senza modificare contratti, guardie o permessi.

Review indipendente0/0/0, installer/recovery completi pglast7statement/3blocchi PLpgSQL ciascuno PASS. Root d129 ricomposta senza perdita in fa7f5e2f14fad90a7bd306d022f8dd85b7f411042ad35083a7b28ba5b75a9f0c,504111byte, modifica dei soli7 percorsi previsti. Migrazione20261117204926 applicata e riletta, DDL MD5 f77a977b75b529748a32df66990d37b6, prosrc da7819f385462f30cdebc80705c4a0a9, qualifica true. Edge168 e client invariati. Unica funzione applicativa modificata, nessun CHECK/RLS/GRANT/formula/budget modificato. Recovery conserva inventario completo dei certificati, mutex e guardie senza sessioni; dopo nuove pubblicazioni richiede forward fix. Non eseguita.

Con la stessa richiesta conservata1358279e-7d51-4c89-a34a-4d7ec540bb86 il normale comando pubblica è riuscito al primo tentativo successivo alla correzione. UI «Missione pubblicata con Regia IA. Nessuna partita e stata avviata». Ricevuta committed/public, una sola pubblicazione.

Missione a3a8430f-6a3d-4d46-9a75-271d5458406d aperta, piano90d513ec-15e9-4a83-b9b9-c67052b77be9, configurazione1, quattro scene, actors0/encounters0. Bozza v3 published e MD5 cf825ecd8fe85c8f32d10e1a717623a3 invariato. Certificato content_admission e qualifica motore validi. Zero sessioni della nuova missione e zero Staff aperte.

In Land → Missioni → Bacheca è visibile «D Una nuova alba KONOHA», briefing esatto, squadra ancora nessuno(max2), ritrovo Konoha - Altri Luoghi. Selezione normale «Avvio missione» riuscita, pannello «Missione IA · Una nuova alba» e «Configurazione IA pubblicata». Riuji è di Suna e vede correttamente «Missione di un altro villaggio»; non è stata forzata l’iscrizione. Il percorso è disponibile ai PG idonei di Konoha secondo la configurazione approvata. Nessuna iscrizione o partita avviata, nessun provider aggiuntivo.

Le sezioni di qualifica Staff sotto descrivono la versione d129 prima della pubblicazione. Fonte Staff annullata e storico preservati. Screenshot della bacheca e selezione salvati negli artefatti della chat. I builder temporanei non sono depositati perché dipendono da snapshot locali; i tre nuovi sorgenti/piano congelati sono nel cantiere.

Ricevuta autorevole completa, senza testi delle role:

```json
{
  "status": "committed",
  "draft_id": "a050c701-796a-4f6b-b129-42b2262e3303",
  "mission_id": "a3a8430f-6a3d-4d46-9a75-271d5458406d",
  "request_key": "1358279e-7d51-4c89-a34a-4d7ec540bb86",
  "draft_version": 3,
  "source_sha256": "ee5422664a7ec70c091339fe57e38539d49c637753148005194fbb80e78a440e",
  "ai_plan_sha256": "a0a5509a4e0e91794545b15e898cfd1ac50c5a09f7e623e7d6b538f7669afa53",
  "config_version": 1,
  "schema_version": "mission-factory-publication/3",
  "supported_modes": [
    "ai"
  ],
  "capability_sha256": "be00bd21916a0d8f190ea2b7a8ee58ad1090ab869fbf68f0a65157e337fa7603",
  "ai_plan_version_id": "90d513ec-15e9-4a83-b9b9-c67052b77be9",
  "availability_scope": "public",
  "engine_release_sha256": "fa7f5e2f14fad90a7bd306d022f8dd85b7f411042ad35083a7b28ba5b75a9f0c",
  "gathering_location_id": "6c737082-8fc7-4fd8-b246-30297a1ed1af",
  "content_admission_sha256": "e9a55faa85800cc58c84a8c6ac3a0444e69a8f0921b77567c964bf642118f362"
}
```



## Risultato e contenuto

Bozza `a050c701-796a-4f6b-b129-42b2262e3303`, versione3, documento MD5 `cf825ecd8fe85c8f32d10e1a717623a3` invariato. SHA del documento IA `a96ec585eb572a592cdf973e68a26e959011ad916da28555de2993fda9d337ab`. Due PG, zero PNG, quattro fasi, quattro transizioni, due finali. Indagine nel bosco e nelle rovine, tracce alternative, registri/lotti/ordini di carico e collegamenti economici verso Kurose, minaccia al convoglio all'alba. Il rientro anticipato produce un rapporto utile ma incompleto senza inventare l'identità del responsabile. Fonte Staff `7e06ff5b-5fc6-446d-ba10-1b2ca2322cf6`, piano `4bf290b6-41c6-4573-88c3-47c7c4c10c3c`, annullata e premi0.

Prima della pubblicazione era stata verificata l’anteprima nel pannello Missioni IA, messaggio «Anteprima pronta: la missione puo essere pubblicata», pulsante Pubblica attivo. A quel checkpoint lo stato era previewed e le pubblicazioni pubbliche0. Stato corrente published e pubblicazioni1, come ricevuta sopra. Nessun PNG aggiunto.

## Difetti corretti e versione integrata

Il publisher e i consumer imponevano success/conclusa anche per il finale parziale. Sette corpi DB e un helper privato derivano ora l'esito dal terminal step server; UI tre controlli e Edge HTTP un controllo accettano i due enum conservando schema, firma, hash e autorizzazioni. L'helper permette failure nella simulazione Staff o nel certificato narrativo diretto zero PNG già ammesso. Il controllo readonly dell'ammissione usa require_enabled=false solo per consentire la chiusura di attività già autorizzate anche a runtime disabilitato, senza concedere Start o spesa.

Preview, publish e content_admission hanno un ramo zero PNG limitato al contratto diretto narrativo a due PG senza mappe/arena/incontri. Il ramo esistente due PNG è preservato. Nessun allentamento generale dei validatori. Contratto zero PNG `ad6ede711c2ac7b72228a022e84591f58ffd9d94c4557f11b857daa22b16dd79`.

Migrazione Staff `20261117200747`, migrazione ammissione `20261117202826`. Root della qualifica Staff `d12982a577a72429b61f6d974646bb5d17e0c66b3da9eba21b69077e1468ada6`, 503092 byte, engine qualified true. Root intermedio Staff `a1832dc33e8abf5c76a2df79fc08db118738967dd22e45f3417eb2d0d36e23b0`, baseline `f9ad89a82dfc1912f042907a6ad7a6b7196370abbf288f1fdd3e52f31de664f1`. Compattazione JSON lossless entro il CHECK esistente, storico/certificati/qualifiche riproiettati senza cancellazioni.

Edge mission_generic_ai168, EZBR `9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76`, 16/16 file identici al readback, verify_jwt=false invariato. UI commit `5240891862e5e548dee57266725a1532474bb001`, SHA256 `1953f6d08e8c0be9bb210e1b3178c6ef677cd3488f22ed393dc57fef178881a6`. Land commit `e591df5b397e3a1870b54600310cea2f59659b3e`, SHA256 `47ecad08c9a2912d0e223792c171b7df897d3875635647e82497e7cf8e9ffe47`, build LAND-ALBA-FINALE-20261117. Admin invariato ADMIN-ALBA-STAFF-20261117. Nuovo helper ownerpostgres, SECURITY DEFINER STABLE, search_path vuoto, ACL `{postgres=X/postgres}`, REVOKE PUBLIC/anon/authenticated/service_role espliciti. Firme/ACL delle funzioni esistenti mantenute. Nessun CHECK, RLS, formula, budget server o account modificato.

## Review e preflight

Review indipendente source DB/helper/UI/Edge/Land0/0/0. Pacchetto Staff corretto dopo findingP2 sulle sessioni preparazione, entrambe le recovery/installazioni usano closed_at IS NULL. Controverifica0/0/0. Pacchetto ammissione corretto dopo findingP2 sulla recovery di nuove pubblicazioni due PNG, inventario completo certificati controllato e serializzato con mutex; controverifica0/0/0. Nessuna patch durante i casi, nessun retry esplorativo. Sintassi completa SQL/PLpgSQL e parsing moduli/script verificati senza gameplay o DB locali. Baseline viva, pin, ACL, Root e recovery verificati prima degli apply, zero Staff/pubbliche AI attive all'installazione.

## Casi giocati

Staff `0b85f354-9cdb-47e1-baf9-3d266bb7e06b`, accessi normali Riuji e testperfunzioni. Quattro Fati per caso, ogni work completato al primo tentativo con Count e Generation. Progressione inizio → conclusione → fase_1/fase_2 → complete.

### Rapporto completo — PASS

Sessione `0907afd0-a16b-4c1a-bb8f-50bc74c6e726`, fase `fase_1`, run `conclusa`, esito `success`, Master `chiusa`, motivo `completata`, chiusa `2026-11-17T20:15:17.569142+00:00`. Comando normale «Concludi la prova», capability terminal/normal.

Ricevuta `8cb9b06a61267ce54daf27758a989b72a9c273c8f708a7c1404a436bab1781b2`, richiesta `fde642bf-473b-ca14-7740-9863f1e123d2`, pubblicazione `7ca8526c-ff6a-43db-9f66-8c77022fd7fc`, source revision `a89e1cba1c958aef5c4fd4e9f65df5c025670910c88a9c54ff76c48db17ba69f`, replayed=false.

Sei passaggi completati — encounter_resolved, final_report_published, mission_run_terminalized, mission_finalized, role_segment_finalized, master_session_closed.

### Rientro con prove parziali — PASS

Sessione `e1eeb337-8f4f-49bc-88d6-039a5c3bb9cd`, fase `fase_2`, run `fallita`, esito `failure`, Master `chiusa`, motivo `completata`, chiusa `2026-11-17T20:22:09.962577+00:00`. Comando normale «Concludi la prova», capability terminal/normal.

Ricevuta `f302c3568d2c315fa1c926141aaf796d53558e6f81317566075c4601c6935e62`, richiesta `9bf286ee-72f9-9e6f-f191-b24c07ef32e9`, pubblicazione `3e47c952-2d18-46ca-b9a1-e020a30c4479`, source revision `fe6e1b58e966b151369177fd2efb3ed114b7e1fbf3a5ed2b74e8a9ae31d51b26`, replayed=false.

Sei passaggi completati — encounter_resolved, final_report_published, mission_run_terminalized, mission_finalized, role_segment_finalized, master_session_closed.

Nel rapporto completo i PG seguono aria/tracce fino alle scale, collegano registri, date, lotti e pagamenti e consegnano elementi su Kurose e sul prossimo convoglio. Nel rapporto parziale tornano con marchi sulle casse, posizione e orario del convoglio, senza attribuzione nominativa. Il Fato chiude la scena mantenendo questa incertezza e uno sviluppo successivo possibile. Nessuna azione unica obbligatoria o scontro imposto.

## Budget e postflight

Prima del primo Start il budget è stato fissato a due casi,8 Gen+8 Count=16 HTTP provider, USD0.20,45 minuti. I tetti token sono stati raffinati prima di Start e di qualsiasi chiamata, dai massimi già attivi24000 input/richiesta e20000 output/Gen, a384000 input e160000 output. Nessun limite automatico o contatore server aumentato/reset.

Start20:09:22UTC, ultima chiusura20:22:09.962577UTC,12m47.96s. Gen8 settled, input31069/output12835, USD0.0095244. Count8 unknown_billable con token null e riserva USD0.0992. Totale prudenziale USD0.1087244 entro0.20. Nessuna ulteriore chiamata provider dopo l'ottavo Fato. Le RPC di chiusura non sono chiamate provider.

Zero Staff aperte, otto work completed. Fonte annullata, XP/Ryo0, nessun premio reale. PV/chakra/XP/pool/grado identici prima/dopo — testperfunzioni105/105,155/155,9950,120,Genin; Riuji80/80,105/105,100,90,Genin. Nessun ripristino delle schede, abort o cancellazione per queste due scene. Presenza e normali metadati possono cambiare. Inventario/portafoglio completi non confrontati per hash, isolamento del ramo simulazione verificato staticamente.

La precedente campagna da sei Fati terminava con Annulla prova e aveva output12868 su12000, eccedenza868. Resta immutata in UNA_NUOVA_ALBA_STAFF_QA.md. Questa nuova campagna parte con propri limiti espliciti e non azzera costi o audit. Cumulativo delle due campagne14Gen+14Count, USD0.1917521 prudenziali, Gen input53006/output25703.

## Copertura e recovery

Runtime qualificato per la conclusione esplicita Staff legacy/3 dei due finali. Auto/4 e avvio pubblico non eseguiti; caller e consumer verificati staticamente. Anteprima e disponibilità Pubblica provati dal pannello normale, pubblicazione effettiva verificata successivamente nella sezione iniziale di questo referto. Nessuna attestazione globale di altre missioni o del backlog. Il vecchio ingresso legacy Factory ha un pin già arretrato prima di questa task, non è stato ripinnato per aggirarne le guardie; Missioni IA moderno funziona.

Recovery Staff utilizzabile solo prima di nuovi Start, altrimenti forward fix. Recovery ammissione utilizzabile solo senza nuovi certificati rispetto all'inventario clonato dal parent e senza sessioni attive. Mantengono storico, dati e dipendenze. Nessuna recovery eseguita. La precedente UNA_NUOVA_ALBA_RECOVERY_SOURCE.sql non appartiene a questa versione.

## Artefatti congelati

- `UNA_NUOVA_ALBA_FINALIZZAZIONE_SOURCE.sql`, 647358 byte, SHA256 `a5f61ce8034bc925b292ccfc5d441da82f8072d579b19ef47a290c29e1137421`.
- `UNA_NUOVA_ALBA_FINALIZZAZIONE_RECOVERY.sql`, 643320 byte, SHA256 `92b44f8f44f26f49617f543678178bf9c4daee074da46a90906c44d58f2a87a3`.
- `UNA_NUOVA_ALBA_AMMISSIONE_SOURCE.sql`, 565334 byte, SHA256 `0d3c79b38a0a613c5c73a0807fadea0fef7f6a985e73c14a47ab0137b1dcce5f`.
- `UNA_NUOVA_ALBA_AMMISSIONE_RECOVERY.sql`, 550722 byte, SHA256 `11af62572f64bedf01e8fb27131371cac9c5b1ecd22b473d5f948db6b08574be`.

Il pacchetto runtime contiene le16 sorgenti Edge della versione168. Piano aggiornato con budget/esiti reali. Builder preparatorio dipendente da snapshot temporanei e copie duplicate UI/Land restano locali; i consumer effettivi sono già pubblicati nella root del repository ai due commit sopra. Nessun segreto o testo integrale delle role depositato. Screenshot anteprima e ricevute di chiusura conservati negli artefatti della chat.
