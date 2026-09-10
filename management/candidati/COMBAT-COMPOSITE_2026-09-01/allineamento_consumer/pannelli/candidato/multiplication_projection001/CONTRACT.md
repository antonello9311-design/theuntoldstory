# Proiezione Moltiplicazione · contratto di presentazione001

## Fonte e autorità
DIAGNOSIS.json di multiplication_assault_smoke011, metadata002: corpo autentico combat_panel_private.multiplication_formation_valid(jsonb,integer,integer,integer), MD5e0d2cf52e22a1c9cf020f27810fd5941. La funzione ammette figure coincidenti sulla griglia intera, verifica indici distinti e distanza L1≤5fra ogni coppia. Fonte congelata, nessuna nuova verifica DB o attribuzione dello stato live da questa costruzione. PLAN approvato dal PM prima del codice.

La UI non deve decidere la validità meccanica della formazione: il divieto di coordinate coincidenti era più restrittivo del server; il precedente controllo Euclideo descriveva una metrica diversa. Entrambi sono rimossi dal validatore di presentazione, senza sostituirli con un secondo controllo geometrico client. La regola L1 e la validazione delle coordinate intere restano al server, che emette e ricontrolla le offerte. Un envelope sintetico geometricamente impossibile ma strutturalmente sicuro può essere rappresentabile: ciò non gli conferisce autorità di gioco.

## Invarianti del DTO
combat-multiplication-view/1 invariato. Conservare shape esatta delle formazioni e dei punti, UUID, mode, versione intera positiva, array≥2, indici interi unici nel dominio1..numerofigure, coordinate finite e dentro bounds finiti positivi; nessuna nuova chiave privata o limite arbitrario alle copie. original_index può essere soltanto null o un indice presente. Se null, manteniamo il divieto di corpo reale duplicato nella mappa, distanza del proprietario e POV che rivelino implicitamente l’originale. Nessuna deduzione da coincidenza, ordine, colore, coordinate o distanza. Non correggere/snap/normalizzare i punti ricevuti.

## Resa e selezione
La mappa è di sola lettura. Ogni figura conserva un marker alle coordinate ricevute, un’etichetta accessibile e una voce distinta nella legenda. In posizioni coincidenti si raggruppa soltanto il testo sopra i marker in un’etichetta con gli indici, senza eliminare figure o separarle geometricamente. I marker sono raggiungibili da tastiera; nessun click sulla mappa invia comandi. La legenda offre riferimenti leggibili anche quando i marker si sovrappongono.

Le figure si selezionano dai gruppi/opzioni nativi del pannello, già distinti per option_id/indice pubblico; non dalle coordinate e non dal testo della legenda. Controller, view delle offerte e costruzione del comando rimangono immutati. Un eventuale originale visibile resta solo quello indicato esplicitamente da original_index nella proiezione autorizzata; quando null nessun marker lo nomina o evidenzia.

## Composizione e recupero
Due moduli soli multiplication.mjs/map.mjs innestati nella basefeedback001, unico marcatore nuovo. Delta inverso dei due blocchi e marcatore deve ricostruire byteesattamente la base; nessun nuovo JS globale, endpoint, listener di comando o permesso. I tre moduli feedback restano identici. La futura composizione privata003 mantiene il proprio controller/persistenza e closecapability/export oltre agli altri delta: questo pacchetto non la sostituisce e non la qualifica.

## Criteri futuri
QA_PLAN.md congela6gruppi prima di qualsiasi esecuzione. Questa tranche produce sorgenti e controlli di costruzione soltanto; zero run di matrice, API, browser o motore. L’accessibilità reale al puntatore/tastiera e la resa visiva saranno esplicitamente distinte dal DOM sintetico. Nessuna causa di011 o completamento delle tattiche viene dedotto dal verde futuro del validatore.
