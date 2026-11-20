Source preparata · COMBAT-CATALOGO-PALMO-ORDINARY-CONTACT-SOURCE-INPUTFIX-20261120

Corregge la sola autocura di un PG nella modalità ordinary della Staff. Source B `680f9d1d43250a7a62ad29537a6d0b2ac13abfdc06f510372c669794b15a403d`. Nessun apply, deploy, chiamata IA o collaudo eseguito da questo incarico.

Problema e comportamento

Nella scena propria ordinary la mappa nativa autorizza il PG tramite membership, controllo del personaggio, corpo attivo e arena valida con due membri. La tabella viewer_grants è vuota. Il contatto Palmo richiedeva comunque un grant Master anche per self, restituiva NULL e l’offerta scompariva. Il profilo Staff e i PV102/105 erano corretti. frozen_turn_valid=false prima della dichiarazione è normale, non un difetto.

Il delta usa l’autorità ordinary già esistente esclusivamente per PG self nella Staff protetta: stesso attore/personaggio/sessione, controllo e body controller coerenti, sessione ordinary viva senza Master, policy Staff, pool simulati senza scritture reali, arena open, template consentito/valido ed esattamente due membri. Non crea grant. Il percorso Master e quello verso alleati mantengono il grant e la geometria originali. Restano identici costi, PV, recupero da KO, obbligo di turno intero e protezioni.

Composizione consegnata

Due corpi derivati dal vivo: cure_contact_v1 e catalogo_eligibility_release_v1. Il secondo aggiorna il pin del contatto e identifica il nuovo amendment/private66; non elimina guardie né ricopia funzioni storiche. Audit contiene gli hunk P esatti, le DDL prima/dopo, inverse esatte, manifest66/peer6 e il template amendment. Source e Recovery hanno uno slot owner PM: senza sigillo globale coerente e review nuova la transazione fallisce. Il cap524288 resta invariato.

Il PM mantiene ownership di Root, mirror/config, metadata/alias, review composta e recovery finale. Al drift si rigenera il delta minimo dal vivo; non basta cambiare pin. Il contratto è sempre palmo-curativo/1; nessun nuovo consumer o schema/GRANT/vincolo.

Recovery

Conserva i due corpi corretti e ogni dato/ricevuta. In quiescenza disattiva soltanto i gate Cure e richiede un avanzamento Root a inert_recovery composto dal PM. Non reintroduce il contatto difettoso o una Root precedente.

Prove e seguito

Tre casi statici in Audit, senza gameplay o DB locali. Review indipendente, apply e caso ordinary self sono NOT_RUN. Il caso necessario, dopo installazione coerente nella Staff, è autocurare il PG ferito dal pannello ordinario e verificare recupero/costo/turno intero e chiusura protetta. I casi Master già positivi rimangono conservati, senza ricertificazione completa.

Registro

La task originaria è sospesa esclusivamente per correggere il suo input INSTALL assegnato al QA Paralisi; INPUTFIX conserva candidata, prove e limite totale60min/3casi/0provider. L’input canonico è NIGHT_PALMO_ORDINARY_QA.json; baseline e corpi vengono dal database vivo, diagnosi TEMP immutabile citata nell’Audit. Nessun nuovo cantiere o reset.
