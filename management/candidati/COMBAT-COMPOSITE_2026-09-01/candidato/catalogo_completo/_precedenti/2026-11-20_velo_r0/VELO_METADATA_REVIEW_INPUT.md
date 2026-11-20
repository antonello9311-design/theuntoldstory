# Velo del Cercoterio — allineamento del catalogo

COMBAT-CATALOGO-DAY-VELO-METADATA-SOURCE-20261120 · consegna per revisione indipendente · nessuna installazione.

La riga `c9b261da-c9cd-40bb-8189-7b65ab5a1605` riporta `uso=principale`. Il regolamento pubblico §8.9 assegna l'azione rapida all'attivazione e il costo di 5 chakra a turno al Velo. La specifica Cercoteri §4.2 nomina esplicitamente Velo e Manto. Il cambiamento riguarda la sola colonna `uso`. Requisiti, consumo per turno, costo, descrizione e dati di tutte le altre tecniche sono preservati. Byakugan, Sharingan e Quattro Zampe impiegano già `rapida` e `per_turno`. Il CHECK `clan_techniques_uso_check` ammette esplicitamente `rapida`. [Regole pubblicate §8.9](https://github.com/antonello9311-design/theuntoldstory/blob/0563dcf9daa16d58b9eaea342f57159c5e203071/REGOLE.md#L869-L899)

| Immagine | SHA256 calcolato dal database sul JSONB della riga |
|---|---|
| Riga attuale | `6901226f7517ec24417ae07bd795e1b83221c82f2dd570355065af10a5159710` |
| Riga attesa con `uso=rapida` | `a79a36d47fe260c0db0d965703cef3b41d98c39530605382d6a8c68109d78229` |

La lettura del 20/11/2026 ha contato zero Forze Portanti, zero apprendimenti del Velo e zero combattenti con il Velo fotografato in sessioni aperte. I guard bloccano entrambe le direzioni in caso di apprendimento o scena aperta con la tecnica. Il lock della riga è incompatibile con il lock della chiave esterna di una nuova acquisizione. Il confronto prima/dopo protegge anche ogni altra riga del catalogo durante la breve prenotazione transazionale della tabella. Rileggere l'assenza di drift e consumatori al preflight. Lo script è ancorato alla riga del Velo, dato che nessun campo della Root, funzione o versione client cambia.

Riscontro dei percorsi vivi. `combat_v2_character_snapshot` raccoglie solo le abilità attive acquisite. `combat_panel_private.master_actor_offers` e `combat_v2_action_declare` accettano entrambe le classi nel medesimo predicato. Anche `test_room_user_techniques` e `test_room_user_action` accettano entrambe le classi e richiedono un apprendimento attivo. La modifica non crea una nuova possibilità di selezione in quei percorsi. L'attacco legacy rifiuta `rapida` come tecnica di attacco principale. Non sussiste già un producer del potenziamento Velo. Se in futuro compare una Forza Portante con Velo attivo, verificare anche l'esclusione dalle offerte d'attacco generiche prima della disponibilità runtime del potenziamento.

Apertura runtime ancora da preparare. L'entrata Staff attuale offre le famiglie di clan ammesse dal CHECK `contexts_v1_staff_ability_profile_check` e nessuna Forza Portante simulata. Serve un profilo protetto autorizzato per provare il Velo attraverso il lifecycle nativo. L'ingresso futuro deve verificare possibilità e costi server, +5 Forza e Velocità solo durante l'effetto, nessuna coda o conseguenza del Manto e idempotenza. I limiti del prodotto non si risolvono creando una Forza Portante reale in scheda.

Tre verifiche statiche positive. La grammatica completa SQL e PL/pgSQL è valida per entrambe le transazioni. Ciascuna contiene un solo UPDATE su `public.clan_techniques`. Le immagini e il campo modificato sono reciproci. Parser PostgreSQL locale senza database, compilazione semantica e collaudo Staff non eseguiti. Operazioni a database solo in lettura, zero provider e zero gameplay.

- `VELO_METADATA_SOURCE.sql` · 2644 byte · SHA256 `3adb2a72cc782d76593e6e7b929a555998e4f177d3bb136de5f40c9b3b1f120a`
- `VELO_METADATA_RECOVERY.sql` · 2648 byte · SHA256 `574b471243013a1f144308ff40abc7c96b8be39edef077e08c519d25c9fe3c66`

Al PM. Revisione indipendente pertinente e preflight vivo prima di un eventuale apply del solo dato. Rileggere riga, altra collezione, numero apprendimenti e stato Root dopo il deposito. Registrare l'eventuale cambiamento come allineamento catalogo. Il percorso del Velo sul sito resta da implementare e il referto notturno mantiene le proprie verifiche e limiti.
