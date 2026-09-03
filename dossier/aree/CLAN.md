# AREA · Clan, innate e tecniche Genin — scheda viva
Riscritta il 03/09/2026 · da Codex (`PM-DOCUMENTALE-CANTIERI-DIPENDENZE-001`) · **stato dell'area: in lavoro** (exact21 aperto; fondazioni 450–453 LIVE inerti; gate Clan OFF)

## Fonti fondamentali — in quest'ordine, solo il blocco che serve
1. **`management/coordination/HANDOFFS/HANDOFF-CLAUDE-2026-09-02-CODEX.md`** — la consegna di Codex del 02/09: baseline LIVE455, cosa è concluso, le decisioni prodotto ratificate (Hyūga, Marionettisti, Hoki/Dokugan) e l'ordine dei lavori. Poi `TASK-PM-CLAN-TECHNIQUES-INHERITANCE-001.md` (le sei fasi) e, solo per cercare, `REFERTO-2026-09-01-CODEX.md` (225 KB).
2. `TASK-PM-MOTORE-CLAN-POWER-001.md`, `TASK-PM-CLAN-SPATIAL-ALIGN-001.md`, `TASK-TECH-CLANS-HYUGA-RATIFICA-003.md` — architettura, allineamento spaziale, ratifica Hyūga.
3. `sito_live/REGOLE.md` §3 (Innata/kekkei genkai), §8 (progressione e clan chiusi) e §5.1 (nature del chakra) per le elementali.
4. Tabelle `clan_techniques` (355 righe), `clans` (9), `clan_richieste`, e il registro Genin: `clan_genin_spatial_profile_registry_v1` (44), `clan_genin_live_inventory_pin_v1` (30), `clan_genin_catalog_function_map_v1` (45), `clan_genin_runtime_gate_v1` (1, OFF).
5. Bozze e comunicazione: `HANDOFF-CLAN-KONOHA-TARGET-001.md`, `BOZZA-PUBBLICAZIONE-CLAN-KONOHA-001.md`, `management/COMUNICAZIONE_CLAN_UTENZA.docx`; `claude/clan_konoha_5_adattati.md`, `claude/clan_suna_bozza.md`, `claude/jutsu_sviluppo_clan.md`.
6. Memoria di progetto: `clan_innate_contro_motore`, `catalogo_contro_motore`, `foglio_utenza_clan`.
7. Skill `gdr-contesto` §4 (i nove clan, soglie KG 30/50/70/80, clan chiusi) e §6 (vincoli CHECK di `clan_techniques`).

## Stato vivo — riconciliato il 03/09/2026 sulla baseline PM
- Baseline LIVE verificata il 03/09: **history461**, head `20260903111028 esame_narratore_unificato_005_bersaglio_dichiarato`. Catena Clan/Combat LIVE **inerte** invariata: 450 `clan_genin_innata_state_common_015_hosted_source_pin` (Innata Common R15), 451 `combat_v2_composite_movement_action_011_common_r15_consumer` (Composite R13), 452 `genin_elemental_eligibility_common_009` (Eligibility R9), 453 `clan_genin_innata_common_release_seal_eligibility_018` (release seal R18, review 0/0/0). Gate Clan, runtime, provider e attivazioni **OFF**. Ogni futuro gate usa una fotografia LIVE fresca: history461 non è un pin permanente.
- Registro Genin: 44 profili spaziali, 30 inventario, 45 mapping; `public_offer=false`, `progression_write=false`. Nove clan verdi target, rossi runtime.
- Editoriale: le **10 tecniche elementali Genin** sono approvate (`open_elemental=0`; pubblicazione/abilitazione distinte). Registro centrale Clan Genin: **13 voci consolidate** (Aburame 2, Akimichi 3, Hoki 2, Hyūga 2, Inuzuka 2, Marionettisti 2); Nara, Sabaku e Uchiha hanno ratifiche nelle schede owner **non ancora nel registro exact21**.
- Depositi: `management/candidati/CLAN-L1_2026-09-01/` (inventario · innata_state_common · editoriale/<clan> · elementali · runtime · spatial_target_completeness). Il subagente Hyūga è stato interrotto in `pending_init`: nessun WIP.
- Personaggi 73; `clan_richieste` 6.

## Lavori aperti — nell'ordine consegnato da Codex il 02/09, uno alla volta
1. **[P1] Consolidamento editoriale exact21** — portare Nara (Possesso dell'Ombra), Sabaku (decisioni owner) e Uchiha (Risonanza Katon, Palla di Fuoco Suprema, Fiori della Fenice) nel registro centrale; rieseguire indice, validatori e manifesto senza perdere le ratifiche. Solo documenti, niente DB. Chi: RULES-LORE + Antonello per le scelte residue.
2. **[P1] Runtime Marionettisti riscritto sul contratto ratificato** — marionetta = PNG-compagno già in scena (identità, posizione, condizioni; nessun turno autonomo); `Rilascio della Marionetta` rimosso dal TARGET; `Fili di Chakra` arte segreta passiva 10/20/30/40 m senza costo; con i fili attivi il marionettista agisce solo tramite la marionetta; fili recisi = un turno pieno senza controllo, poi riallaccio non-main a 5; `Marionetta da Combattimento` azione principale, costo 5, un bersaglio entro 3 m, pool KG+Ninjutsu. Il runtime legacy (evocazione/rilascio) va archiviato.
3. **[P1] Runtime Hyūga da ribasare sulla head LIVE verificata al gate** — il candidato storico pinzato a head453/455 non si modifica con search/replace: una nuova revisione lo sostituisce e la precedente resta in `_precedenti/`. Valori ratificati: Byakugan L1 vede flusso e rete del chakra, 0–10 m; Jūken aumenta il danno degli attacchi compatibili, non drena, non chiude tenketsu; 16 Chiusure bersaglio singolo a contatto (2 m), non cumula col Jūken, su pieno successo +5 al costo chakra delle tecniche del bersaglio per due suoi turni (rinnova, non accumula). Suite PG17 ×2 e review indipendente.
4. **[P2] Verticali Clan rimanenti, uno alla volta** (Sabaku → Nara → Aburame/Hoki → Akimichi → Inuzuka → Uchiha) con campi strutturati completi: distanza, area, cardinalità, bersagli, origine, LOS/LOE, movimento, risultato per target, profile/version; fixture e review 0/0/0.
5. **[P2] Dieci elementali Genin**: pubblicazione/abilitazione distinte dall'approvazione editoriale; verifica sul Combat comune una riga alla volta.
6. **[P3] Staff Room e bilanciamento**, poi **pubblicazione** coordinata (regole + pannelli + UI).

## Parcheggiato — non riaprire senza mandato
- Nessuna decisione «identitaria» generale sui nove clan resta aperta: gli OPEN sono locali (valori, testi, runtime). Non si riapre l'identità di un clan.
- Il foglio dell'utenza sui clan copre 7 clan su 9 e non è scrivibile da qui.

## Decisioni chiuse — non ridiscutere
- L'Innata L1 ha un controllo server-side Attiva/Spegni separato e **non consuma l'azione principale**; uno stato attivo già autorizzato viene ereditato senza nuova spesa.
- Byakugan: attivazione e upkeep 5, spegnimento gratuito, raggio percettivo 0–10 m, Jūken e 16 Chiusure separati (valori ratificati il 02/09, vedi lavoro #3), Palmo d'Aria escluso.
- Hoki/Dokugan (02/09): clan e cognome `Hoki`, Innata `Dokugan L1–L4`; `Occhio del Veleno` escluso dal TARGET corrente.
- Marionettisti (02/09): contratto prodotto chiuso come al lavoro #2; il vecchio runtime non è automaticamente valido.
- Sabaku: Innata separata da Scudo, Clone e Trasporto; nessuno Scudo o Armatura impliciti; costo e testo pubblico li ratifica Antonello.
- Innate e leggendarie non occupano slot; le 36 righe innate sono un modello unico. Hyūga, Uchiha e Sabaku sono chiusi e assegnati dallo staff.
- Non confondere «mapping» o «verde target» con «tecnica eseguibile»; nessun gate ON prima di resolver, review e smoke.

## Trappole — lezioni della memoria di progetto che valgono qui
[[clan_innate_contro_motore]] · [[catalogo_contro_motore]] · [[foglio_utenza_clan]] · [[costo_azione_non_solo_bonus]] · [[xp_scale_non_scritte]] · [[check_vivo_sostituzione_insieme]] · [[disattivare_riga_catalogo]]

## Prossimo passo
Il consolidamento exact21 (solo documenti): finché il registro centrale non contiene tutte le 21 tecniche, ogni verticale runtime lavora su una fonte incompleta.
