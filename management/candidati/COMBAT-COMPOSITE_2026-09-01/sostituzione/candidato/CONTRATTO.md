# P1-A · attestazione resolver comune Sostituzione e binding Esame

TASK-ID: `P1-A-COMBAT-EXAM-SUBSTITUTION-REBASE-001`  
Stato: `offline · attestazione pronta · gate integrato bloccato`  
Owner: `DB-CORE`  
Autorita spaziale: `generic_sostituzione_spatial_v1`

## Esito del rebase

Non viene creato un secondo resolver. La produzione possiede gia, inerte/offer-only:

- R9 `20260901065823 common_sostituzione_spatial_runtime_bridge_009_media_r4_rebase`;
- chiusura offer-only `20260901195205 combat_v2_substitution_spatial_offer_only`;
- `combat_spatial.anchor_is_legal` e `combat_spatial.substitution_commit`;
- porte Combat `combat_v2_substitution_options_v1`, `combat_v2_substitution_select_v1`, `combat_v2_substitution_resolve_internal_v1`;
- wrapper Esame `exam_substitution_options_v1` e `exam_substitution_commit_v1`, service-only.

Il solo delta P1-A e contrattuale: l'adapter Esame deve consumare queste porte, non il ramo legacy che sceglie l'ancora dopo l'esito e addebita localmente costo/cooldown. `MIGRATION_CANDIDATE_NON_APPLICARE.sql` e una attestazione read-only fail-closed, non una migrazione.

## Contratto comune congelato

- tecnica catalogo `31b15861-fb78-4f8a-ac1c-ebf2d957c32e`;
- anchor certificata exact `portable_single_use`, transizione `available -> consumed_non_substitutable`;
- portata inclusiva dal Ninjutsu snapshot: `<25=3m`, `25-49=5m`, `50-74=10m`, `>=75=15m`;
- cooldown al commit: uso R1, assente R2/R3, ritorno R4;
- economia atomica: `reaction1 + chakra5`;
- destinazione con full-footprint clearance, bounds e occupancy fail-closed;
- commit unico di reazione, chakra, anchor, posizione, cooldown, evento e receipt;
- stale precommit costo0; postcommit storico, senza refund, nearest, push, overlap, reroute, retarget o auto-switch;
- replay operation-scoped: stessa request key e stesso fingerprint restituiscono la receipt storica; payload diverso confligge.

Il profilo Missione puo certificare la scena, ma non e autorita meccanica e non concede fallback.

## Input dell'adapter Esame

Il client sceglie soltanto un `opaque_substitution_option_id` gia offerto. L'adapter server lega:

- `prova_id`, `source_application_id`, exact attacker/defender semantic key;
- exact parent defense window e request key operation-scoped;
- current server snapshot di attore, corpo, Ninjutsu, chakra, round e scena;
- option/capability, anchor/versione e certificate/geometry version gia materializzati dal common resolver.

Coordinate, range, anchor raw, collisione, costi, cooldown e outcome non arrivano dal client, dall'IA o dalla prosa.

## Output audit verso P1-B/P1-C

Identita condivisa obbligatoria e ordinata:

`combat_exam_exchange_identity_v1 = (exchange_id, exchange_version, root_application_id, attack_application_id, defense_application_id, substitution_event_id nullable, resolution_revision)`.

Il resolver comune fornisce l'exact `substitution_event_id` tramite l'evento committato e la receipt autoritativa. L'adapter lega quell'evento alla shared identity; non rigenera l'evento e non usa l'id della request come event id.

Per outcome `substituted`, l'audit bundle deve contenere immutabilmente:

- `before`, `impact`, `anchor_before`, `anchor_after_proxy`, `after`;
- `distance_to_attacker_after_m` e exact `range_band/range_profile_version`;
- typed source, anatomy e target evidence;
- spatial event id/version, source/body/anchor/map/profile versions.

La proiezione Narratore e distinta: usa handle opachi e regioni semantiche, mai UUID o coordinate raw.

## Output/errori delle porte comuni

`exam_substitution_options_v1(prova, source_application_id)` restituisce capability opache oppure lista vuota/non disponibile senza leakage.

`exam_substitution_commit_v1(prova, option_id, request_key)` restituisce la resolution receipt comune con `event_id`, esito canonico `negato_sostituzione`, danno0, chakra committato5 e payload Narratore server-derived.

Errori pubblici minimi e non rivelanti:

- `substitution_no_legal_anchor`;
- `exam_substitution_option_stale`;
- `exam_substitution_resource_unavailable`;
- request fingerprint conflict della porta operation-scoped;
- indisponibilita generica quando instance, window, profile o source non sono pronti.

I dettagli su range, occupancy, bounds, blocker, version drift e anchor restano audit-only.

## Gate

P1-A non richiede SQL mutativo ne rollback. Il gate integrato resta STOP finche il branch Supabase QA non e healthy e allineato alla head produzione e finche P1-B/P1-C non usano la stessa identity su una sola revisione. La prova Esame aperta non viene letta nel dettaglio ne mutata.
