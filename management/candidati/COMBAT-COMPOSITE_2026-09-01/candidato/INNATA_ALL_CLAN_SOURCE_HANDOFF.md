# Backend Source · raccordo36 · consegna congelata

TASK-ID · INNATA-ALL-CLAN-BACKEND-SOURCE-20261104 · owner DB-INNATA-ALL-SOURCE. SOURCE FROZEN, review integrata ancora richiesta; non installabile direttamente e nessuna qualifica runtime.

Scope toccato · Soli INNATA_ALL_CLAN_SOURCE.sql, INNATA_ALL_CLAN_SOURCE_PLAN.json e questo HANDOFF nel candidato Combat. Nessun DB apply, browser, provider, gameplay, World enable, sorgente sito o QA/common document modificato. Delta33funzioni vive+11nuove, due CHECK sostituiti, nessuna nuova colonna/tabella/trigger; massimo9righe di configurazione append-only per i3tierSharingan nuovi. Fonte SQL 175275byte SHA256 `f5563e65ded4ecaf752a3768d90af9d1c4450b0c8e7dd844374781229be59dda`.

Contratti usati/modificati · INNATA_ALL_CLAN_CONTRACT.md SHA5ab71c326bb0b150ed466bb2e6b76b8e9a83e6bdfe68198777d22ce7b47413b5, catalogo36 congelato, DTO2 esatti13/15campi e wrapper1/6profili con replay storici conservati. Sottocontratti privati innata-permission-fact/1 e innata-permission-role-link/1 consumati da DTO2, snapshot e ricevuta materialization. combat-narrative-facts/1, post_message/role-command wire, GenericUI e consegna Narratore non modificati.

Decisioni prese / OPEN · 27permission passive e9mantenute. Passive: costoNULL, nessun ON/upkeep/stato fittizio/statbonus, diritto di fascia distinto dalla capacità. Native risorse esistenti restano indipendenti; nessun motore Hoki/Akimichi/Nara nuovo né preparazione nascosta di colonia/chassis. Sharingan2–4 usa quote10/15/20, scopeStaff provato, native ledger/upkeep/OFF e famiglia singola; WorldL1 invariato e nuoviUUID non ammessi da state_set_core canonico invariato. Nessuna decisione prodotto riaperta. La review può individuare finding reali da correggere come aggregata, non micro-patch durante review.

Prove eseguite e risultato · Tre gruppi statici PASS:74statement SQL,6corpiSQL e40blocchiPL/pgSQL (solo tipi dichiarati/ritorno aliasati per libpg_query), matrice36/27+9 e separazioneDTO/passive, ABI33/legacyreplay/roleports/continuità/Worldguard. Nessun gameplay o DB eseguito dai parser, nessun PASS di installazione. Readonly finale 2026-11-04T14:17:22.84115+00:00:33/33targetcorpi/DDL esatti, zero drift target; Root esterno ora `8adc08d3d0a5ed3b2d6d54f87b94243770480fc97e0a8fb3537373497d782ed6` anziché contrattoeb81. Il composer deve preservare questa provenienza nuova. LAND/GenericUI sono cambiati esternamente: usare rebaseUI owner, non attribuire live0633/c1d.

Rischi o regressioni da verificare · Eseguibilità e security pertinenti nella review Root del materiale completo; conservare tutti gli header non target e i cambi esterni, nuove ACL esplicite soli authenticated sulle2RPC e postgres sugli helper. Verificare le due CHECK ampliate, righe quote sigillate e trigger Sedici su nuovi costi. I permessi non certificano capacità superiori, risorse complete, modalità non giocate o Narratore. Le role coperte sono ordinary post_message e i due rami Master/role2 reali che chiamano lo stesso post_message; link nella stessa transazione dopo INSERT, niente trigger globale. L'ensure_context vivo resta byte-identico ed eredita il nuovo saldo solo dal closed actor autorevole; materialize replay non riscrive l'attore e conserva postpassSP06. La port restore del PM resta tranche separata; nessun refill o credito provato da questa source.

Passaggio richiesto al PM · Review indipendente del freeze e composizione DB/RPC+UI2 ribasata+config/recovery su Root vivo, poi preflight readonly/installazione Staff nel mandato distinto. Conservare costi/journal/ricevute/Scorta/schede e contatori QA2; nuove prove soltanto con campagna finita e fattibilità risorse. Source sentinel INNATA_ALL_CLAN_ROOT_COMPOSITION_REQUIRED impedisce l'esecuzione autonoma. Recovery non deve ripristinare la vecchia whitelist6 sopra dati nuovi, cancellare audit o reinstallare corpi arretrati.

## Firme cambiate

- `public.clan_innata_staff_profile_state_v1(uuid,uuid)` · prosrc MD5 `ea90aad4a4124ab3182ad25d4a5606fe`
- `public.clan_innata_staff_profile_set_v1(uuid,uuid,text,uuid,bigint)` · prosrc MD5 `249d61cd47032235f4922526c6cd95c1`
- `clan_innata_narrative_private.staff_profile_for_character_v1(uuid,uuid,uuid)` · prosrc MD5 `0c8875db2d17c457c5da62853cf8703d`
- `clan_innata_narrative_private.command_admitted_v1(uuid,uuid,uuid)` · prosrc MD5 `19e4aa17ef54e8116df872c337836f0a`
- `clan_innata_narrative_private.activate_v1(uuid,uuid,uuid,uuid,uuid)` · prosrc MD5 `229acf0737d362be51998b0ac1f417fa`
- `clan_innata_narrative_private.quote_v1(uuid,boolean)` · prosrc MD5 `96b916c84948bda3d377f1b535aa06b3`
- `clan_innata_private.sharingan_combat_scope_core(uuid,boolean)` · prosrc MD5 `bf602a8e8c9da169dce8dbbec32346e0`
- `clan_innata_private.sharingan_staff_bind_ready(uuid)` · prosrc MD5 `e8ec7615c648aebb436ee815141ef6e0`
- `clan_innata_private.combat_scope(uuid,uuid)` · prosrc MD5 `cb8eb1074e14c03b23423657d95ff2e2`
- `clan_innata_private.combat_activation_window(uuid,uuid)` · prosrc MD5 `5385f7e1bdc32ee7d59133e95815e21b`
- `clan_innata_private.combat_begin_turn(uuid,uuid)` · prosrc MD5 `c3c44d1d11f1b160282cee61d6d63a66`
- `clan_innata_private.combat_terminal(uuid,uuid,text)` · prosrc MD5 `f6b3bc2a10d4745c45e25c242daa017a`
- `clan_innata_private.combat_transition(uuid,uuid,text,uuid,bigint)` · prosrc MD5 `0d2ff8675b0c8a56301093ade149a880`
- `clan_innata_private.sharingan_consumer_options(jsonb)` · prosrc MD5 `5f91694e7d1e28a42e77110af6ebc70e`
- `clan_innata_private.sharingan_master_control_offers(uuid,bigint)` · prosrc MD5 `7901ee2d824e294d16964eb9ca6db5cf`
- `clan_innata_private.sharingan_commit_control(jsonb,jsonb)` · prosrc MD5 `a0a870b9a08a285910784a5f4b099a92`
- `clan_innata_private.sharingan_commit_master_control(jsonb)` · prosrc MD5 `3a16b4c47de10a22a0ea7cd11fb430a3`
- `clan_innata_private.sharingan_off_offer_valid(uuid,uuid)` · prosrc MD5 `423c2cd5cf1bf94dce209a4f12a1dc9e`
- `clan_hyuga_private.sedici_common_cost_guard()` · prosrc MD5 `0d219bce5b8660641bf40b28e6731257`
- `clan_innata_narrative_private.byakugan_family_guard_v1()` · prosrc MD5 `f9301a4a197a462e6c98579a8ef5f9a1`
- `clan_innata_narrative_private.staff_profile_actor_v1(uuid)` · prosrc MD5 `e66a41c06cd56ebc7d5109eb8cfaf932`
- `clan_innata_narrative_private.staff_profile_bind_v1(uuid,uuid)` · prosrc MD5 `32f5410369549e9d61a32084cdc4a0c4`
- `public.post_message(uuid,text,uuid,uuid,text)` · prosrc MD5 `9fc568f0683efee969668516ba551c74`
- `clan_innata_narrative_private.materialize_v1(uuid)` · prosrc MD5 `39fbb826c4fb95c5c6ea4dfadef49aad`
- `clan_aburame_private.staff_scope(uuid)` · prosrc MD5 `6aa304ceaba25a513a9e85d00e31d9e2`
- `clan_aburame_private.actor_allowed(uuid)` · prosrc MD5 `54a56857e80991453025ea267b8f5faf`
- `clan_aburame_private.actor_has_technique(uuid,uuid)` · prosrc MD5 `21940017614bae1fbebc039f0c6a57db`
- `clan_aburame_private.ensure_scope(uuid)` · prosrc MD5 `ba938fd10940e419b124b814d925fb32`
- `clan_inuzuka_private.owner_scope(uuid,boolean)` · prosrc MD5 `df0f8a00082bbff3d12ca49b24cf3b97`
- `clan_inuzuka_private.staff_profile_needed(uuid)` · prosrc MD5 `536847d68028efd6b5331b262eb25896`
- `clan_inuzuka_private.staff_profile_apply(uuid)` · prosrc MD5 `42aec12a1442524a561407405fcd4007`
- `clan_marionettisti_private.consumer_options(jsonb)` · prosrc MD5 `06163b97f72459e400a976faf7fdf695`
- `clan_marionettisti_private.staff_profile_bind(uuid,jsonb)` · prosrc MD5 `0b4e2cf0a58b097229cf4b90efecea07`

## Firme nuove

- `clan_innata_narrative_private.catalog_v2()` · prosrc MD5 `54fdbeb352e3022ec8d9ead4aa3e3138`
- `clan_innata_narrative_private.profile_definition_v2(text)` · prosrc MD5 `c9ca1bdcea4c4866e3547c1c98c4c332`
- `clan_innata_narrative_private.profile_definition_by_id_v2(uuid)` · prosrc MD5 `3ae234fe238982c87cc3b92bcbf638fd`
- `clan_innata_narrative_private.permission_fact_v2(uuid)` · prosrc MD5 `d62b510bc362f4173f6fb76f8d92035a`
- `clan_innata_narrative_private.profile_busy_reason_v2(uuid)` · prosrc MD5 `5844011aca9eb65ebb763e8d6ee9c8f5`
- `clan_innata_narrative_private.profile_state_core_v2(uuid,uuid)` · prosrc MD5 `3d5b6a2f11f1c54fc701c4dba098321d`
- `public.clan_innata_staff_profile_state_v2(uuid,uuid)` · prosrc MD5 `1c6e5b50c609a8239c916accf29fc5cb`
- `public.clan_innata_staff_profile_set_v2(uuid,uuid,text,uuid,bigint)` · prosrc MD5 `00c3a603061b5c1ba13183bae48a0cfb`
- `clan_innata_narrative_private.sharingan_selected_v2(uuid)` · prosrc MD5 `c32a2e8e4635731e9aedced3b8ada358`
- `clan_innata_narrative_private.sharingan_quote_for_actor_v2(uuid)` · prosrc MD5 `bf6fa585bba77c0b7fd2c946186db0c8`
- `clan_innata_narrative_private.permission_role_link_v2(uuid,uuid,uuid)` · prosrc MD5 `4c42e24c581a9b656f009c34fe7a91c2`
