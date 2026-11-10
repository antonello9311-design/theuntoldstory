# S24 PNG — distribuzione bloccata, prova non avviata

TASK-ID: COMBAT-S24-PNG-WINDOW-20261110 · owner PM-COMBAT-S24.

## Scope toccato
Sola finestra policy Staff e relativo Root/pin Admin; tre casi mancanti T6/T7/T8, nessuna apertura pubblica.

## Contratti usati/modificati
Root ed742e942e3d421f0272239c51bb55bd820efc9de07c0cb7191bc927269fa917, parent a614eba9e2c8c43042cfcc24ddfe64d1205c84bc85a0315ff940b710dd7654fa; 90header, un DDL con quattro timestamp, altri89immutati. Generic160/16file invariati, Combat42 invariata. Migrazione combat_s24_png_window_20261110, readback90PASS; review0/0/0 SHA5899bfa1462f891f8bbcf63a33fcb7e30e4f6c487c23cfeb22c3f3e89cc87798, installer5fb3f11344921a6043bd2ef07542f41efa6957d5b6b0781f6a382856f75268e3. Admincommit7f6f425b8b8d8c46078ef55ac2b3a609f853e92c, SHA6d4ddde840a3ada33c3a8b683e6ab9b91f0386c8c01caeb1dcac6bd8e9eaa012.

## Decisioni / OPEN
Finestra08:48–10:18UTC del10nov, cutoff10:12; nessun rinnovo. Massimo12nuoviwork/24HTTP, input24000/output4096 perGen, source18Count18Gen36HTTP/0.0577523USD, uppercampagna0.0919462USD entro0.10. La scena non è stata avviata. Nessuna scelta PNG forzata, pesca di esiti, Restore o ripetizioneF1.

## Prove e risultato
S24 PNG nuova finestra · 10/11/2026 · BLOCCATA SU PAGES, QA NOT_RUN. Root ed742e94 installata/readback90header, Generic160 invariata; Admin7f6f425b (484602B, SHA6d4ddde8) e documenti96787fa0 pubblicati/riletti. Pages42786153551 e42788407741: buildSUCCESS, deployTIMEOUT durante syncing_files dopo600s; retry accettati ma in coda senza nuovi job osservati. Dominio ancora al Root parent a614. Finestra08:48–10:18UTC, cutoff10:12, invariata; massimo12work24HTTP, uppertotale0,0919462USD. Nessuno Start o provider nuovo. Postflight indipendente09:22UTC PASS: totale0,0385702USD,0riserve/hold/pending/Staffaperte, recovery e custodia esatte. T6/T7/T8 NOT_RUN, F1PASSnonripetuto, noRestore, pubblicoOFF.

## Rischi e regressioni
Nessuna qualifica runtime di T6/T7/T8 o Writer LifeCore. Due build riuscite e due deploy in timeout non costituiscono pubblicazione riuscita; i retry accettati restano pendenti lato GitHub. Backend attuale e Admin sul dominio disallineati: non avviare il collaudo finché il nuovo pin non è distribuito. Recovery precedente e storico invariati, nessuna scena da chiudere.

## Passaggio al PM
Prossimo passo: risolvere la distribuzione Pages e verificare Root corrente sul dominio prima dello Start della fonte originale. Se disponibili prima del cutoff10:12UTC, riprendere E1/N2/N3 entro i medesimi limiti; la finestra non si rinnova automaticamente. Non riaprire i tentativi annullati né ripetere F1 PASS. Costo cumulativo0,0385702USD incluso nel tetto0,10USD.

Deposito: piano/review/release/handoff al commit96787fa0, readback4/4 esatto; checkpoint corrente aggiornato localmente. SQL integrale, Root/proof/raw, template SQL QA e dossier cumulativi restano locali per evidenze private e WIP non riconciliati; nessun sito_live sovrascritto. Pubblicazione successiva dei soli referti pronti registrata separatamente.
