-- PREPARATION ONLY: native objects, empty runtime, no historical migration rows or RNG keys.

-- Not a production migration. Gameplay blocked by documented non-portable release guard.

BEGIN;

SET LOCAL lock_timeout='5s'; SET LOCAL statement_timeout='120s';

SET LOCAL search_path=pg_catalog,public,extensions,auth;

SET LOCAL check_function_bodies=on;

DO $guard$ BEGIN

 IF current_database()<>'narrative_multiplication_wrapper_001' THEN RAISE EXCEPTION 'hyuga_bootstrap_wrong_database'; END IF;

 IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname=current_user AND rolsuper) THEN RAISE EXCEPTION 'hyuga_bootstrap_requires_local_superuser'; END IF;

 IF EXISTS(SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.relkind IN('r','p') AND n.nspname NOT IN('pg_catalog','information_schema')) THEN RAISE EXCEPTION 'hyuga_bootstrap_requires_empty_database'; END IF;

 IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname='anon') THEN RAISE EXCEPTION 'hyuga_bootstrap_missing_role: %','anon'; END IF;

 IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname='authenticated') THEN RAISE EXCEPTION 'hyuga_bootstrap_missing_role: %','authenticated'; END IF;

 IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname='dashboard_user') THEN RAISE EXCEPTION 'hyuga_bootstrap_missing_role: %','dashboard_user'; END IF;

 IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname='pg_database_owner') THEN RAISE EXCEPTION 'hyuga_bootstrap_missing_role: %','pg_database_owner'; END IF;

 IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname='postgres') THEN RAISE EXCEPTION 'hyuga_bootstrap_missing_role: %','postgres'; END IF;

 IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname='service_role') THEN RAISE EXCEPTION 'hyuga_bootstrap_missing_role: %','service_role'; END IF;

 IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname='supabase_admin') THEN RAISE EXCEPTION 'hyuga_bootstrap_missing_role: %','supabase_admin'; END IF;

 IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname='supabase_auth_admin') THEN RAISE EXCEPTION 'hyuga_bootstrap_missing_role: %','supabase_auth_admin'; END IF;

END $guard$;

CREATE SCHEMA IF NOT EXISTS "auth" AUTHORIZATION "supabase_admin";

ALTER SCHEMA "auth" OWNER TO "supabase_admin";

GRANT USAGE,CREATE ON SCHEMA "auth" TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "auth" TO "supabase_auth_admin";

CREATE SCHEMA IF NOT EXISTS "clan_innata_combat_private" AUTHORIZATION "postgres";

ALTER SCHEMA "clan_innata_combat_private" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "clan_innata_combat_private" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "clan_innata_private" AUTHORIZATION "postgres";

ALTER SCHEMA "clan_innata_private" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "clan_innata_private" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "clan_marionettisti_private" AUTHORIZATION "postgres";

ALTER SCHEMA "clan_marionettisti_private" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "clan_marionettisti_private" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "clan_sabaku_private" AUTHORIZATION "postgres";

ALTER SCHEMA "clan_sabaku_private" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "clan_sabaku_private" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "combat_consumer_private" AUTHORIZATION "postgres";

ALTER SCHEMA "combat_consumer_private" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "combat_consumer_private" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "combat_gate_private" AUTHORIZATION "postgres";

ALTER SCHEMA "combat_gate_private" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "combat_gate_private" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "combat_panel_private" AUTHORIZATION "postgres";

ALTER SCHEMA "combat_panel_private" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "combat_panel_private" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "combat_spatial" AUTHORIZATION "postgres";

ALTER SCHEMA "combat_spatial" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "combat_spatial" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "combat_v2_composite_internal" AUTHORIZATION "postgres";

ALTER SCHEMA "combat_v2_composite_internal" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "combat_v2_composite_internal" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "combat_v2_elemental_internal" AUTHORIZATION "postgres";

ALTER SCHEMA "combat_v2_elemental_internal" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "combat_v2_elemental_internal" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "combat_v2_multitarget_internal" AUTHORIZATION "postgres";

ALTER SCHEMA "combat_v2_multitarget_internal" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "combat_v2_multitarget_internal" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "combat_v2_private" AUTHORIZATION "postgres";

ALTER SCHEMA "combat_v2_private" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "combat_v2_private" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "extensions" AUTHORIZATION "postgres";

ALTER SCHEMA "extensions" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "extensions" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "hyuga_runtime_qa" AUTHORIZATION "postgres";

ALTER SCHEMA "hyuga_runtime_qa" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "hyuga_runtime_qa" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "mission_ai_board_owner" AUTHORIZATION "postgres";

ALTER SCHEMA "mission_ai_board_owner" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "mission_ai_board_owner" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "mission_ai_service_owner" AUTHORIZATION "postgres";

ALTER SCHEMA "mission_ai_service_owner" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "mission_ai_service_owner" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "mission_declaration_owner" AUTHORIZATION "postgres";

ALTER SCHEMA "mission_declaration_owner" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "mission_declaration_owner" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "mission_exam_private" AUTHORIZATION "postgres";

ALTER SCHEMA "mission_exam_private" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "mission_exam_private" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "mission_exchange_combat_owner" AUTHORIZATION "postgres";

ALTER SCHEMA "mission_exchange_combat_owner" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "mission_exchange_combat_owner" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "mission_internal" AUTHORIZATION "postgres";

ALTER SCHEMA "mission_internal" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "mission_internal" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "ninja_book_internal" AUTHORIZATION "postgres";

ALTER SCHEMA "ninja_book_internal" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "ninja_book_internal" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "png_builder_internal" AUTHORIZATION "postgres";

ALTER SCHEMA "png_builder_internal" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "png_builder_internal" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "public" AUTHORIZATION "pg_database_owner";

ALTER SCHEMA "public" OWNER TO "pg_database_owner";

GRANT USAGE,CREATE ON SCHEMA "public" TO "postgres";

CREATE SCHEMA IF NOT EXISTS "supabase_migrations" AUTHORIZATION "postgres";

ALTER SCHEMA "supabase_migrations" OWNER TO "postgres";

GRANT USAGE,CREATE ON SCHEMA "supabase_migrations" TO "postgres";

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;

CREATE TYPE "clan_innata_combat_private"."actor_context" AS (
 "session_id" "pg_catalog"."uuid",
 "location_id" "pg_catalog"."uuid",
 "exchange_id" "pg_catalog"."uuid",
 "turn_actor_id" "pg_catalog"."uuid",
 "phase" "pg_catalog"."text" COLLATE "pg_catalog"."default",
 "policy_id" "pg_catalog"."text" COLLATE "pg_catalog"."default",
 "context_version" "pg_catalog"."int8",
 "activity_kind" "pg_catalog"."text" COLLATE "pg_catalog"."default",
 "personal_turn_id" "pg_catalog"."uuid"
);

ALTER TYPE "clan_innata_combat_private"."actor_context" OWNER TO "postgres";

CREATE OR REPLACE FUNCTION mission_internal.nb029h_json_hash(p_value jsonb)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO ''
AS $function$
 select pg_catalog.encode(extensions.digest(pg_catalog.convert_to(p_value::text,'utf8'),'sha256'),'hex')
$function$;

ALTER FUNCTION mission_internal.nb029h_json_hash(jsonb) OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION mission_internal.nb029h_json_hash(jsonb) FROM PUBLIC,"anon","authenticated","postgres","service_role";

GRANT EXECUTE ON FUNCTION mission_internal.nb029h_json_hash(jsonb) TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION public.calc_chakra_max(p_nin integer, p_mente integer, p_rank text)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select (5 * round( ( 30 + (coalesce(p_nin,0)+coalesce(p_mente,0))*1.2 + case coalesce(p_rank,'Deshi')
      when 'Genin' then 15 when 'Chunin' then 30 when 'Jonin' then 50
      when 'Jonin Speciale' then 65 when 'Kage' then 85 when 'Sannin' then 85 else 0 end ) / 5.0 ))::int;
$function$;

ALTER FUNCTION public.calc_chakra_max(integer,integer,text) OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION public.calc_chakra_max(integer,integer,text) FROM PUBLIC,"anon","authenticated","postgres","service_role";

GRANT EXECUTE ON FUNCTION public.calc_chakra_max(integer,integer,text) TO "postgres";

GRANT EXECUTE ON FUNCTION public.calc_chakra_max(integer,integer,text) TO "service_role";

GRANT EXECUTE ON FUNCTION public.calc_chakra_max(integer,integer,text) TO "authenticated";

RESET ROLE;

CREATE OR REPLACE FUNCTION public.calc_vita_max(p_res integer, p_rank text)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select (5 * round( ( 50 + coalesce(p_res,0) + case coalesce(p_rank,'Deshi')
      when 'Genin' then 10 when 'Chunin' then 25 when 'Jonin' then 45
      when 'Jonin Speciale' then 60 when 'Kage' then 80 when 'Sannin' then 80 else 0 end ) / 5.0 ))::int;
$function$;

ALTER FUNCTION public.calc_vita_max(integer,text) OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION public.calc_vita_max(integer,text) FROM PUBLIC,"anon","authenticated","postgres","service_role";

GRANT EXECUTE ON FUNCTION public.calc_vita_max(integer,text) TO "postgres";

GRANT EXECUTE ON FUNCTION public.calc_vita_max(integer,text) TO "service_role";

GRANT EXECUTE ON FUNCTION public.calc_vita_max(integer,text) TO "authenticated";

RESET ROLE;



-- Native metadata bank only. No native functions below are invoked by this setup.

CREATE TABLE "auth"."users" (
 "instance_id" uuid,
 "id" uuid NOT NULL,
 "aud" character varying(255),
 "role" character varying(255),
 "email" character varying(255),
 "encrypted_password" character varying(255),
 "email_confirmed_at" timestamp with time zone,
 "invited_at" timestamp with time zone,
 "confirmation_token" character varying(255),
 "confirmation_sent_at" timestamp with time zone,
 "recovery_token" character varying(255),
 "recovery_sent_at" timestamp with time zone,
 "email_change_token_new" character varying(255),
 "email_change" character varying(255),
 "email_change_sent_at" timestamp with time zone,
 "last_sign_in_at" timestamp with time zone,
 "raw_app_meta_data" jsonb,
 "raw_user_meta_data" jsonb,
 "is_super_admin" boolean,
 "created_at" timestamp with time zone,
 "updated_at" timestamp with time zone,
 "phone" text,
 "phone_confirmed_at" timestamp with time zone,
 "phone_change" text,
 "phone_change_token" character varying(255),
 "phone_change_sent_at" timestamp with time zone,
 "confirmed_at" timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
 "email_change_token_current" character varying(255),
 "email_change_confirm_status" smallint,
 "banned_until" timestamp with time zone,
 "reauthentication_token" character varying(255),
 "reauthentication_sent_at" timestamp with time zone,
 "is_sso_user" boolean NOT NULL,
 "deleted_at" timestamp with time zone,
 "is_anonymous" boolean NOT NULL
);

ALTER TABLE "auth"."users" OWNER TO "supabase_auth_admin";

CREATE TABLE "clan_marionettisti_private"."master_scene_claims" (
 "claim_id" uuid NOT NULL,
 "master_session_id" uuid NOT NULL,
 "encounter_id" uuid NOT NULL,
 "template_key" text NOT NULL,
 "template_version" integer NOT NULL,
 "geometry_version" bigint NOT NULL,
 "claim_version" bigint NOT NULL,
 "authority_version" text NOT NULL,
 "authority_principal_id" uuid NOT NULL,
 "authority_control_version" bigint NOT NULL,
 "geometry_fingerprint" text NOT NULL,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "clan_marionettisti_private"."master_scene_claims" OWNER TO "postgres";

CREATE TABLE "clan_marionettisti_private"."sources" (
 "id" uuid NOT NULL,
 "source_kind" text NOT NULL,
 "real_companion_id" uuid,
 "session_id" uuid,
 "owner_actor_id" uuid,
 "owner_character_id" uuid NOT NULL,
 "profile_version" text NOT NULL,
 "is_active" boolean NOT NULL,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "clan_marionettisti_private"."sources" OWNER TO "postgres";

CREATE TABLE "combat_consumer_private"."activities" (
 "session_id" uuid NOT NULL,
 "location_id" uuid NOT NULL,
 "scene_profile_id" uuid NOT NULL,
 "opener_character_id" uuid NOT NULL,
 "context_version" bigint NOT NULL,
 "round_no" integer NOT NULL,
 "exchange_id" uuid,
 "turn_actor_id" uuid,
 "phase" text NOT NULL,
 "policy_id" text NOT NULL,
 "created_at" timestamp with time zone NOT NULL,
 "last_action_at" timestamp with time zone NOT NULL,
 "closed_at" timestamp with time zone
);

ALTER TABLE "combat_consumer_private"."activities" OWNER TO "postgres";

CREATE TABLE "combat_consumer_private"."narrative_claims" (
 "id" uuid NOT NULL,
 "session_id" uuid NOT NULL,
 "round_id" uuid NOT NULL,
 "report_id" uuid NOT NULL,
 "report_sha256" text NOT NULL,
 "context_version" bigint NOT NULL,
 "control_version" bigint NOT NULL,
 "context_payload" jsonb NOT NULL,
 "context_sha256" text NOT NULL,
 "request_key" uuid NOT NULL,
 "state" text NOT NULL,
 "claimed_at" timestamp with time zone NOT NULL,
 "expires_at" timestamp with time zone NOT NULL,
 "completion_sha256" text,
 "completion_result" jsonb,
 "provider_response_id" text,
 "provider_request_sha256" text,
 "raw_output_sha256" text,
 "failure_code" text
);

ALTER TABLE "combat_consumer_private"."narrative_claims" OWNER TO "postgres";

CREATE TABLE "combat_consumer_private"."scene_attempts_v2" (
 "claim_id" uuid NOT NULL,
 "request_key" uuid NOT NULL,
 "round_id" uuid NOT NULL,
 "session_id" uuid NOT NULL,
 "scene_payload" jsonb NOT NULL,
 "scene_sha256" text NOT NULL,
 "state" text NOT NULL,
 "permit_at" timestamp with time zone,
 "result_bytes" text,
 "result_payload" jsonb,
 "result_sha256" text,
 "provider_response_id" text,
 "failure_code" text,
 "completion" jsonb,
 "created_at" timestamp with time zone NOT NULL,
 "result_at" timestamp with time zone,
 "redelivery_at" timestamp with time zone,
 "redelivery_state" text,
 "redelivery_request_id" bigint
);

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" OWNER TO "postgres";

CREATE TABLE "combat_consumer_private"."scene_claims" (
 "id" uuid NOT NULL,
 "session_id" uuid NOT NULL,
 "scene_profile_id" uuid NOT NULL,
 "template_key" text NOT NULL,
 "template_version" integer NOT NULL,
 "producer_version" integer NOT NULL,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "combat_consumer_private"."scene_claims" OWNER TO "postgres";

CREATE TABLE "combat_consumer_private"."scene_profiles" (
 "id" uuid NOT NULL,
 "location_id" uuid NOT NULL,
 "template_key" text NOT NULL,
 "template_version" integer NOT NULL,
 "producer_version" integer NOT NULL,
 "geometry_sha256" text NOT NULL,
 "approval_reference" text NOT NULL,
 "enabled" boolean NOT NULL,
 "fighter_one_slot" text NOT NULL,
 "fighter_two_slot" text NOT NULL
);

ALTER TABLE "combat_consumer_private"."scene_profiles" OWNER TO "postgres";

CREATE TABLE "combat_panel_private"."master_scene_claims" (
 "id" uuid NOT NULL,
 "profile_id" uuid NOT NULL,
 "profile_version" bigint NOT NULL,
 "master_session_id" uuid NOT NULL,
 "encounter_id" uuid NOT NULL,
 "template_key" text NOT NULL,
 "template_version" integer NOT NULL,
 "authority_principal_id" uuid NOT NULL,
 "authority_control_version" bigint NOT NULL,
 "geometry_fingerprint" text NOT NULL,
 "roster_fingerprint" text NOT NULL,
 "policy_id" text NOT NULL,
 "visibility_mode" text NOT NULL,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "combat_panel_private"."master_scene_claims" OWNER TO "postgres";

CREATE TABLE "combat_panel_private"."master_scene_profiles" (
 "id" uuid NOT NULL,
 "location_id" uuid NOT NULL,
 "label" text NOT NULL,
 "template_key" text NOT NULL,
 "template_version" integer NOT NULL,
 "profile_version" bigint NOT NULL,
 "geometry_fingerprint" text NOT NULL,
 "policy_id" text NOT NULL,
 "visibility_mode" text NOT NULL,
 "enabled" boolean NOT NULL
);

ALTER TABLE "combat_panel_private"."master_scene_profiles" OWNER TO "postgres";

CREATE TABLE "combat_panel_private"."multiplication_formations" (
 "id" uuid NOT NULL,
 "session_id" uuid NOT NULL,
 "round_id" uuid NOT NULL,
 "actor_id" uuid NOT NULL,
 "declaration_id" uuid NOT NULL,
 "instance_id" uuid NOT NULL,
 "source_body_version" bigint NOT NULL,
 "mode" text NOT NULL,
 "copy_count" integer NOT NULL,
 "copy_cap" integer NOT NULL,
 "figures" jsonb NOT NULL,
 "original_index" integer NOT NULL,
 "state" text NOT NULL,
 "state_version" bigint NOT NULL,
 "terminal_reason" text,
 "created_at" timestamp with time zone NOT NULL,
 "ended_at" timestamp with time zone
);

ALTER TABLE "combat_panel_private"."multiplication_formations" OWNER TO "postgres";

CREATE TABLE "combat_panel_private"."multiplication_resolutions" (
 "formation_id" uuid NOT NULL,
 "attack_target_id" uuid NOT NULL,
 "chooser_actor_id" uuid NOT NULL,
 "selected_index" integer NOT NULL,
 "choice_kind" text NOT NULL,
 "outcome" text NOT NULL,
 "rng_seed" bytea,
 "facts" jsonb NOT NULL,
 "receipt_sha256" text NOT NULL,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "combat_panel_private"."multiplication_resolutions" OWNER TO "postgres";

CREATE TABLE "combat_spatial"."arena_instances" (
 "instance_id" uuid NOT NULL,
 "master_session_id" uuid,
 "encounter_id" uuid NOT NULL,
 "binding_id" uuid,
 "template_key" text NOT NULL,
 "template_version" integer NOT NULL,
 "map_version" integer NOT NULL,
 "state" text NOT NULL,
 "created_at" timestamp with time zone NOT NULL,
 "context_source" text NOT NULL,
 "ordinary_claim_id" uuid,
 "master_claim_id" uuid,
 "panel_claim_id" uuid
);

ALTER TABLE "combat_spatial"."arena_instances" OWNER TO "postgres";

CREATE TABLE "combat_spatial"."arena_slots" (
 "template_key" text NOT NULL,
 "template_version" integer NOT NULL,
 "slot_key" text NOT NULL,
 "actor_kind" text NOT NULL,
 "x_m" numeric(8,2) NOT NULL,
 "y_m" numeric(8,2) NOT NULL
);

ALTER TABLE "combat_spatial"."arena_slots" OWNER TO "postgres";

CREATE TABLE "combat_spatial"."arena_templates" (
 "template_key" text NOT NULL,
 "template_version" integer NOT NULL,
 "contract_version" text NOT NULL,
 "width_m" numeric(8,2) NOT NULL,
 "height_m" numeric(8,2) NOT NULL,
 "actor_radius_m" numeric(8,2) NOT NULL,
 "geometry_contract_id" text NOT NULL,
 "geometry_contract_version" integer NOT NULL,
 "geometry_hash" text NOT NULL,
 "required_shape_keys" text[] NOT NULL,
 "status" text NOT NULL,
 "source_asset_sha256" text NOT NULL
);

ALTER TABLE "combat_spatial"."arena_templates" OWNER TO "postgres";

CREATE TABLE "combat_spatial"."mission_bindings" (
 "binding_id" uuid NOT NULL,
 "binding_key" text NOT NULL,
 "binding_version" integer NOT NULL,
 "location_id" uuid NOT NULL,
 "template_key" text NOT NULL,
 "template_version" integer NOT NULL,
 "roster_contract_id" text NOT NULL,
 "roster_contract_version" integer NOT NULL,
 "roster_seal_sha256" text NOT NULL,
 "roster_profile_id" uuid NOT NULL,
 "roster_profile_key" text NOT NULL,
 "roster_profile_sha256" text NOT NULL,
 "guard_migration_version" text NOT NULL,
 "guard_migration_name" text NOT NULL,
 "guard_function_md5" jsonb NOT NULL,
 "enabled" boolean NOT NULL
);

ALTER TABLE "combat_spatial"."mission_bindings" OWNER TO "postgres";

CREATE TABLE "mission_ai_board_owner"."activations" (
 "id" uuid NOT NULL,
 "mission_id" uuid NOT NULL,
 "package_id" uuid NOT NULL,
 "location_id" uuid NOT NULL,
 "mission_seal_sha256" text NOT NULL,
 "state" text NOT NULL,
 "control_version" bigint NOT NULL,
 "roster_sha256" text,
 "all_ready" boolean NOT NULL,
 "current_session_id" uuid,
 "opened_at" timestamp with time zone NOT NULL,
 "frozen_at" timestamp with time zone,
 "started_at" timestamp with time zone
);

ALTER TABLE "mission_ai_board_owner"."activations" OWNER TO "postgres";

CREATE TABLE "mission_ai_service_owner"."capabilities" (
 "id" uuid NOT NULL,
 "start_request_key" uuid NOT NULL,
 "master_session_id" uuid,
 "authority_receipt_sha256" text NOT NULL,
 "expected_control_version" bigint NOT NULL,
 "state" text NOT NULL,
 "terminal_request_key" uuid,
 "terminal_mode" text,
 "created_at" timestamp with time zone NOT NULL,
 "terminal_at" timestamp with time zone,
 "roster_profile_id" uuid,
 "board_activation_id" uuid,
 "ronda_binding_id" uuid
);

ALTER TABLE "mission_ai_service_owner"."capabilities" OWNER TO "postgres";

CREATE TABLE "mission_ai_service_owner"."roster_profiles" (
 "id" uuid NOT NULL,
 "profile_key" text NOT NULL,
 "package_key" text NOT NULL,
 "owner_kind" text NOT NULL,
 "operational_location_id" uuid NOT NULL,
 "team_exact" smallint NOT NULL,
 "active" boolean NOT NULL,
 "control_version" bigint NOT NULL,
 "profile_sha256" text NOT NULL,
 "created_at" timestamp with time zone NOT NULL,
 "activated_at" timestamp with time zone
);

ALTER TABLE "mission_ai_service_owner"."roster_profiles" OWNER TO "postgres";

CREATE TABLE "mission_internal"."nb_mission_source_attestations" (
 "manifest_sha256" text NOT NULL,
 "source_task_id" text NOT NULL,
 "manifest_entries" integer NOT NULL,
 "manifest_path" text NOT NULL,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "mission_internal"."nb_mission_source_attestations" OWNER TO "postgres";

CREATE TABLE "mission_internal"."ronda_runtime_bindings_v1" (
 "id" uuid NOT NULL,
 "binding_key" text NOT NULL,
 "schema_version" text NOT NULL,
 "mission_id" uuid NOT NULL,
 "pg_character_ids" uuid[] NOT NULL,
 "narrative_template_ids" uuid[] NOT NULL,
 "narrative_version_ids" uuid[] NOT NULL,
 "mechanical_template_ids" uuid[] NOT NULL,
 "mechanical_version_ids" uuid[] NOT NULL,
 "import_history_version" text NOT NULL,
 "import_statement_sha256" text NOT NULL,
 "lifecycle_state" text NOT NULL,
 "enabled" boolean NOT NULL,
 "control_version" bigint NOT NULL,
 "binding_sha256" text NOT NULL,
 "created_at" timestamp with time zone NOT NULL,
 "updated_at" timestamp with time zone NOT NULL
);

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" OWNER TO "postgres";

CREATE TABLE "public"."character_companions" (
 "id" uuid NOT NULL,
 "character_id" uuid NOT NULL,
 "kind" text NOT NULL,
 "grado" text NOT NULL,
 "name" text NOT NULL,
 "avatar_url" text,
 "descr" text,
 "is_active" boolean NOT NULL,
 "created_at" timestamp with time zone NOT NULL,
 "famiglia" text
);

ALTER TABLE "public"."character_companions" OWNER TO "postgres";

CREATE TABLE "public"."characters" (
 "id" uuid NOT NULL,
 "user_id" uuid NOT NULL,
 "name" text NOT NULL,
 "village" text,
 "rank" text NOT NULL,
 "clan" text,
 "corporation" text,
 "element" text,
 "money" integer NOT NULL,
 "exp" integer NOT NULL,
 "chakra" integer NOT NULL,
 "chakra_max" integer NOT NULL,
 "vita" integer NOT NULL,
 "vita_max" integer NOT NULL,
 "taijutsu" integer NOT NULL,
 "ninjutsu" integer NOT NULL,
 "genjutsu" integer NOT NULL,
 "forza" integer NOT NULL,
 "velocita" integer NOT NULL,
 "mente" integer NOT NULL,
 "background" text,
 "avatar_url" text,
 "banner_url" text,
 "music_url" text,
 "created_at" timestamp with time zone NOT NULL,
 "updated_at" timestamp with time zone NOT NULL,
 "age" integer,
 "sex" text,
 "unspent_points" integer NOT NULL,
 "epithet" text,
 "off_notes" text,
 "clan_role" text,
 "resistenza" integer NOT NULL,
 "fuuinjutsu" integer NOT NULL,
 "kekkei_genkai" integer NOT NULL,
 "face_claim" text,
 "last_regen_at" timestamp with time zone NOT NULL,
 "xp_lifetime" integer NOT NULL,
 "last_daily_xp" date,
 "lealta" integer NOT NULL,
 "via" integer NOT NULL,
 "fama" integer NOT NULL,
 "slot_extra" integer NOT NULL,
 "corp_spec" text,
 "corp_role" text,
 "corp_since" timestamp with time zone,
 "corp_anon" boolean,
 "cercoterio" text,
 "sigillo" text,
 "element2" text,
 "pool_concesso" integer NOT NULL,
 "is_test" boolean NOT NULL,
 "cognome" text
);

ALTER TABLE "public"."characters" OWNER TO "postgres";

CREATE TABLE "public"."combat_v2_actors" (
 "id" uuid NOT NULL,
 "session_id" uuid NOT NULL,
 "actor_kind" text NOT NULL,
 "character_id" uuid,
 "png_instance_id" uuid,
 "controller_user" uuid,
 "team_key" text NOT NULL,
 "state" text NOT NULL,
 "position_m" integer NOT NULL,
 "initiative_snapshot" integer NOT NULL,
 "mechanics_snapshot" jsonb NOT NULL,
 "controller_version" bigint NOT NULL,
 "created_at" timestamp with time zone NOT NULL,
 "provider_instance_v1_id" uuid,
 "companion_id" uuid
);

ALTER TABLE "public"."combat_v2_actors" OWNER TO "postgres";

CREATE TABLE "public"."combat_v2_attack_targets" (
 "id" uuid NOT NULL,
 "round_id" uuid NOT NULL,
 "attack_declaration_id" uuid NOT NULL,
 "ordinal" smallint NOT NULL,
 "target_actor_id" uuid NOT NULL,
 "target_controller_version" bigint NOT NULL,
 "target_position_m" integer NOT NULL,
 "state" text NOT NULL,
 "outcome" jsonb,
 "rng_receipt_sha256" text,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "public"."combat_v2_attack_targets" OWNER TO "postgres";

CREATE TABLE "public"."combat_v2_declarations" (
 "id" uuid NOT NULL,
 "round_id" uuid NOT NULL,
 "actor_id" uuid NOT NULL,
 "kind" text NOT NULL,
 "parent_attack_id" uuid,
 "target_actor_id" uuid,
 "sanitized_intent" jsonb NOT NULL,
 "declaration_text" text NOT NULL,
 "controller_user_snapshot" uuid NOT NULL,
 "controller_version_snapshot" bigint NOT NULL,
 "request_key" uuid NOT NULL,
 "state" text NOT NULL,
 "outcome" jsonb,
 "order_no" integer,
 "tie_break" bigint,
 "cost_snapshot" jsonb NOT NULL,
 "created_at" timestamp with time zone NOT NULL,
 "frozen_at" timestamp with time zone
);

ALTER TABLE "public"."combat_v2_declarations" OWNER TO "postgres";

CREATE TABLE "public"."combat_v2_events" (
 "id" uuid NOT NULL,
 "scope_id" uuid NOT NULL,
 "request_key" uuid NOT NULL,
 "operation_kind" text NOT NULL,
 "request_fingerprint" text NOT NULL,
 "caller" uuid,
 "control_version" bigint,
 "status" text NOT NULL,
 "result" jsonb,
 "error_sanitized" jsonb,
 "created_at" timestamp with time zone NOT NULL,
 "completed_at" timestamp with time zone,
 "caller_kind" text NOT NULL,
 "caller_service_capability" uuid
);

ALTER TABLE "public"."combat_v2_events" OWNER TO "postgres";

CREATE TABLE "public"."combat_v2_png_instances" (
 "id" uuid NOT NULL,
 "session_id" uuid NOT NULL,
 "template_id" uuid NOT NULL,
 "client_ref" uuid NOT NULL,
 "nome" text NOT NULL,
 "snapshot" jsonb NOT NULL,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "public"."combat_v2_png_instances" OWNER TO "postgres";

CREATE TABLE "public"."combat_v2_provider_instances_v1" (
 "id" uuid NOT NULL,
 "schema_version" text NOT NULL,
 "session_id" uuid NOT NULL,
 "client_ref" uuid NOT NULL,
 "provider" text NOT NULL,
 "offer_ref" uuid NOT NULL,
 "narrative_template_ref" uuid NOT NULL,
 "narrative_version_ref" uuid NOT NULL,
 "mechanical_template_ref" uuid NOT NULL,
 "mechanical_version_ref" uuid NOT NULL,
 "source_sha256" text NOT NULL,
 "snapshot_sha256" text NOT NULL,
 "nome" text NOT NULL,
 "snapshot" jsonb NOT NULL,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "public"."combat_v2_provider_instances_v1" OWNER TO "postgres";

CREATE TABLE "public"."combat_v2_round_reports" (
 "id" uuid NOT NULL,
 "round_id" uuid NOT NULL,
 "mechanics" jsonb NOT NULL,
 "mechanics_sha256" text NOT NULL,
 "values_written" boolean NOT NULL,
 "engine_version" text NOT NULL,
 "resolver_version" text NOT NULL,
 "order_version" text NOT NULL,
 "quality_version" text NOT NULL,
 "narration_state" text NOT NULL,
 "narrator_kind" text,
 "message_id" uuid,
 "created_at" timestamp with time zone NOT NULL,
 "narrated_at" timestamp with time zone
);

ALTER TABLE "public"."combat_v2_round_reports" OWNER TO "postgres";

CREATE TABLE "public"."combat_v2_rounds" (
 "id" uuid NOT NULL,
 "session_id" uuid NOT NULL,
 "round_no" integer NOT NULL,
 "phase" text NOT NULL,
 "state" text NOT NULL,
 "engine_version" text NOT NULL,
 "resolver_version" text NOT NULL,
 "order_version" text NOT NULL,
 "quality_version" text NOT NULL,
 "evaluation_mode" text NOT NULL,
 "rng_order_commitment" text,
 "freeze_at" timestamp with time zone,
 "resolved_at" timestamp with time zone,
 "narrated_at" timestamp with time zone,
 "report_id" uuid,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "public"."combat_v2_rounds" OWNER TO "postgres";

CREATE TABLE "public"."combat_v2_sessions" (
 "id" uuid NOT NULL,
 "source_kind" text NOT NULL,
 "master_session_id" uuid,
 "location_id" uuid NOT NULL,
 "state" text NOT NULL,
 "state_before_suspend" text,
 "engine_version" text NOT NULL,
 "resolver_version" text NOT NULL,
 "lesiva" boolean NOT NULL,
 "created_at" timestamp with time zone NOT NULL,
 "closed_at" timestamp with time zone
);

ALTER TABLE "public"."combat_v2_sessions" OWNER TO "postgres";

CREATE TABLE "public"."locations" (
 "id" uuid NOT NULL,
 "name" text NOT NULL,
 "description" text,
 "kind" text,
 "map_x" numeric,
 "map_y" numeric,
 "sort" integer,
 "is_active" boolean,
 "created_at" timestamp with time zone,
 "image_url" text,
 "event_note" text,
 "region" text,
 "is_academy" boolean NOT NULL,
 "overflow_of" uuid,
 "is_test" boolean NOT NULL,
 "is_exam_room" boolean NOT NULL
);

ALTER TABLE "public"."locations" OWNER TO "postgres";

CREATE TABLE "public"."master_v2_nb_actor_offers_v1" (
 "offer_ref" uuid NOT NULL,
 "schema_version" text NOT NULL,
 "master_session_id" uuid NOT NULL,
 "mission_id" uuid NOT NULL,
 "recipient_user" uuid,
 "narrative_template_id" uuid NOT NULL,
 "narrative_version_id" uuid NOT NULL,
 "mechanical_template_id" uuid NOT NULL,
 "mechanical_version_id" uuid NOT NULL,
 "expected_master_control_version" bigint NOT NULL,
 "expected_narrative_template_control_version" bigint NOT NULL,
 "expected_narrative_version_control_version" bigint NOT NULL,
 "expected_binding_control_version" bigint NOT NULL,
 "expected_mechanical_template_control_version" bigint NOT NULL,
 "expected_mechanical_version_control_version" bigint NOT NULL,
 "expected_narrative_sha256" text NOT NULL,
 "expected_mechanical_sha256" text NOT NULL,
 "lifecycle_state" text NOT NULL,
 "control_version" bigint NOT NULL,
 "expires_at" timestamp with time zone NOT NULL,
 "consumed_event_id" uuid,
 "consumed_at" timestamp with time zone,
 "created_by" uuid,
 "created_at" timestamp with time zone NOT NULL,
 "updated_at" timestamp with time zone NOT NULL,
 "recipient_kind" text NOT NULL,
 "recipient_service_capability" uuid,
 "created_by_service_capability" uuid
);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" OWNER TO "postgres";

CREATE TABLE "public"."master_v2_sessions" (
 "id" uuid NOT NULL,
 "location_id" uuid NOT NULL,
 "tipo" text NOT NULL,
 "stato" text NOT NULL,
 "master_user" uuid,
 "control_version" bigint NOT NULL,
 "mission_id" uuid,
 "titolo" text NOT NULL,
 "stato_pre_sospensione" text,
 "created_at" timestamp with time zone NOT NULL,
 "suspended_at" timestamp with time zone,
 "closed_at" timestamp with time zone,
 "close_reason" text,
 "quest_kind" text,
 "owner_kind" text NOT NULL
);

ALTER TABLE "public"."master_v2_sessions" OWNER TO "postgres";

CREATE TABLE "public"."messages" (
 "id" uuid NOT NULL,
 "location_id" uuid NOT NULL,
 "character_id" uuid,
 "author_name" text NOT NULL,
 "body" text NOT NULL,
 "created_at" timestamp with time zone,
 "kind" text NOT NULL,
 "sender_user" uuid,
 "recipient_user" uuid,
 "recipient_name" text,
 "dice_sides" integer,
 "dice_result" integer,
 "companion_id" uuid,
 "companion_body" text
);

ALTER TABLE "public"."messages" OWNER TO "postgres";

CREATE TABLE "public"."mission_plan_versions" (
 "id" uuid NOT NULL,
 "plan_id" uuid NOT NULL,
 "versione" bigint NOT NULL,
 "stato" text NOT NULL,
 "initial_step_key" text NOT NULL,
 "plan_sha256" text,
 "approved_at" timestamp with time zone,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "public"."mission_plan_versions" OWNER TO "postgres";

CREATE TABLE "public"."mission_plans" (
 "id" uuid NOT NULL,
 "mission_id" uuid NOT NULL,
 "stato" text NOT NULL,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "public"."mission_plans" OWNER TO "postgres";

CREATE TABLE "public"."missions" (
 "id" uuid NOT NULL,
 "title" text NOT NULL,
 "village" text,
 "grado" text NOT NULL,
 "briefing" text NOT NULL,
 "tag_trama" text,
 "xp_reward" integer NOT NULL,
 "ryo_reward" integer NOT NULL,
 "team_min" integer NOT NULL,
 "team_max" integer NOT NULL,
 "location_hint" text,
 "status" text NOT NULL,
 "data_missione" date,
 "master_id" uuid,
 "esito_nota" text,
 "created_by" uuid,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "public"."missions" OWNER TO "postgres";

CREATE TABLE "public"."nb_mechanical_templates" (
 "id" uuid NOT NULL,
 "template_key" text NOT NULL,
 "archetype" text NOT NULL,
 "lifecycle_state" text NOT NULL,
 "active" boolean NOT NULL,
 "current_version_id" uuid,
 "control_version" bigint NOT NULL,
 "created_at" timestamp with time zone NOT NULL,
 "updated_at" timestamp with time zone NOT NULL
);

ALTER TABLE "public"."nb_mechanical_templates" OWNER TO "postgres";

CREATE TABLE "public"."nb_mechanical_versions" (
 "id" uuid NOT NULL,
 "template_id" uuid NOT NULL,
 "version_no" integer NOT NULL,
 "schema_version" text NOT NULL,
 "supersedes_version_id" uuid,
 "rank" text NOT NULL,
 "archetype" text NOT NULL,
 "base_per_stat" integer NOT NULL,
 "allocated_points" integer NOT NULL,
 "innata" integer NOT NULL,
 "stats" jsonb NOT NULL,
 "vita_max" integer NOT NULL,
 "chakra_max" integer NOT NULL,
 "abilities" jsonb NOT NULL,
 "generation" jsonb NOT NULL,
 "content_sha256" text NOT NULL,
 "review_state" text NOT NULL,
 "control_version" bigint NOT NULL,
 "created_at" timestamp with time zone NOT NULL
);

ALTER TABLE "public"."nb_mechanical_versions" OWNER TO "postgres";

CREATE TABLE "public"."nb_mission_packages" (
 "id" uuid NOT NULL,
 "package_key" text NOT NULL,
 "schema_version" text NOT NULL,
 "lifecycle_state" text NOT NULL,
 "active" boolean NOT NULL,
 "test_only" boolean NOT NULL,
 "team_exact" integer NOT NULL,
 "xp_reward" integer NOT NULL,
 "ryo_reward" integer NOT NULL,
 "persistent_effects" boolean NOT NULL,
 "payload" jsonb NOT NULL,
 "payload_sha256" text GENERATED ALWAYS AS (mission_internal.nb029h_json_hash(payload)) STORED,
 "expected_segment_manifest" jsonb NOT NULL,
 "expected_segment_manifest_sha256" text GENERATED ALWAYS AS (mission_internal.nb029h_json_hash(expected_segment_manifest)) STORED,
 "source_manifest_sha256" text NOT NULL,
 "miyo_template_id" uuid NOT NULL,
 "miyo_template_version_id" uuid NOT NULL,
 "miyo_template_control_version" bigint NOT NULL,
 "miyo_version_control_version" bigint NOT NULL,
 "miyo_content_sha256" text NOT NULL,
 "segment_set_sha256" text,
 "seal_sha256" text,
 "seal_request_key" uuid,
 "mission_id" uuid,
 "plan_id" uuid,
 "plan_version_id" uuid,
 "control_version" bigint NOT NULL,
 "created_by_kind" text NOT NULL,
 "created_at" timestamp with time zone NOT NULL,
 "sealed_at" timestamp with time zone,
 "reviewed_at" timestamp with time zone,
 "approved_at" timestamp with time zone
);

ALTER TABLE "public"."nb_mission_packages" OWNER TO "postgres";

CREATE TABLE "public"."nb_template_versions" (
 "id" uuid NOT NULL,
 "template_id" uuid NOT NULL,
 "version_no" integer NOT NULL,
 "schema_version" text NOT NULL,
 "supersedes_version_id" uuid,
 "mechanical_template_id" uuid,
 "skeleton" jsonb NOT NULL,
 "knowledge_boundary" jsonb NOT NULL,
 "fallback_profile" jsonb NOT NULL,
 "content_sha256" text NOT NULL,
 "review_state" text NOT NULL,
 "reviewed_by" uuid,
 "reviewed_at" timestamp with time zone,
 "approved_by" uuid,
 "approved_at" timestamp with time zone,
 "created_by" uuid NOT NULL,
 "created_at" timestamp with time zone NOT NULL,
 "control_version" bigint NOT NULL,
 "updated_at" timestamp with time zone NOT NULL
);

ALTER TABLE "public"."nb_template_versions" OWNER TO "postgres";

CREATE TABLE "public"."nb_templates" (
 "id" uuid NOT NULL,
 "request_key" uuid NOT NULL,
 "template_key" text NOT NULL,
 "display_name" text NOT NULL,
 "village_scope" text,
 "lifecycle_state" text NOT NULL,
 "current_version_id" uuid,
 "control_version" bigint NOT NULL,
 "created_by" uuid NOT NULL,
 "created_at" timestamp with time zone NOT NULL,
 "updated_at" timestamp with time zone NOT NULL,
 "deactivated_at" timestamp with time zone
);

ALTER TABLE "public"."nb_templates" OWNER TO "postgres";

CREATE TABLE "public"."png_templates" (
 "id" uuid NOT NULL,
 "nome" text NOT NULL,
 "epiteto" text,
 "avatar_url" text,
 "grado" text NOT NULL,
 "taijutsu" integer NOT NULL,
 "ninjutsu" integer NOT NULL,
 "genjutsu" integer NOT NULL,
 "forza" integer NOT NULL,
 "velocita" integer NOT NULL,
 "mente" integer NOT NULL,
 "resistenza" integer NOT NULL,
 "fuuinjutsu" integer NOT NULL,
 "kekkei_genkai" integer NOT NULL,
 "vita_max" integer,
 "chakra_max" integer,
 "abilita" jsonb NOT NULL,
 "note" text,
 "is_active" boolean NOT NULL,
 "created_by" uuid,
 "created_at" timestamp with time zone NOT NULL,
 "prestavolto" text
);

ALTER TABLE "public"."png_templates" OWNER TO "postgres";

CREATE TABLE "public"."profiles" (
 "id" uuid NOT NULL,
 "username" text NOT NULL,
 "is_adult" boolean NOT NULL,
 "role" text NOT NULL,
 "created_at" timestamp with time zone NOT NULL,
 "adult_confirmed_at" timestamp with time zone,
 "terms_accepted_at" timestamp with time zone,
 "consent_version" text,
 "welcomed_at" timestamp with time zone
);

ALTER TABLE "public"."profiles" OWNER TO "postgres";

SET LOCAL check_function_bodies=off;

CREATE OR REPLACE FUNCTION combat_consumer_private.narrative_tech_sources_v1(p_claim uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE claim combat_consumer_private.narrative_claims%ROWTYPE;
  unit public.combat_v2_rounds%ROWTYPE; ref record; event record; content jsonb;
  sources jsonb:='[]'; endings jsonb:='[]'; native_id uuid; source_kind text;
BEGIN
 SELECT * INTO STRICT claim FROM combat_consumer_private.narrative_claims WHERE id=p_claim;
 SELECT * INTO STRICT unit FROM public.combat_v2_rounds WHERE id=claim.round_id;
 IF unit.session_id IS DISTINCT FROM claim.session_id OR claim.context_payload->>'ordinary' IS DISTINCT FROM 'true'
   OR claim.context_payload->>'genere' IS DISTINCT FROM 'azione_risolta' THEN
   RAISE EXCEPTION 'narrative_tech_scope_invalid' USING ERRCODE='22023';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.activities staff_activity
      JOIN public.combat_v2_sessions staff_session ON staff_session.id=staff_activity.session_id
      JOIN public.locations staff_location ON staff_location.id=staff_activity.location_id
      WHERE staff_activity.session_id=claim.session_id AND staff_activity.exchange_id=claim.round_id
        AND staff_activity.phase='resolved' AND staff_activity.policy_id='staff_test_no_persistent_resources_v1'
        AND staff_session.source_kind='ordinary' AND staff_session.location_id=staff_activity.location_id
        AND staff_location.is_test AND NOT public.combat_v2_values_written(staff_session.id)
        AND combat_consumer_private.staff_test_allowed(staff_location.id,
          (SELECT array_agg(actor.controller_user ORDER BY actor.id)
           FROM combat_consumer_private.members member JOIN public.combat_v2_actors actor
             ON actor.id=member.actor_id AND actor.session_id=member.session_id
             AND actor.character_id=member.character_id
           WHERE member.session_id=claim.session_id),false)) THEN
   RAISE EXCEPTION 'narrative_tech_staff_scope_required' USING ERRCODE='42501';
 END IF;
 -- Native rows certify use: no role-text/name lookup, no inventory scan.
 FOR ref IN
  SELECT DISTINCT x.catalog,x.actor_id FROM (
   SELECT 'clan_techniques'::text catalog,d.actor_id
    FROM public.combat_v2_declarations d
    WHERE d.round_id=claim.round_id AND d.state='risolta'
      AND d.outcome->'sabaku_clone'->>'schema_version'='sabaku-clone/1'
      AND d.kind='utilita'
   UNION
   SELECT 'clan_techniques',c.actor_id FROM clan_sabaku_private.clone_captures cc
    JOIN clan_sabaku_private.clones c ON c.id=cc.clone_id
    WHERE cc.round_id=claim.round_id AND c.session_id=claim.session_id
   UNION
   SELECT 'jutsu',f.actor_id FROM combat_panel_private.multiplication_formations f
    JOIN public.combat_v2_declarations d ON d.id=f.declaration_id
    WHERE f.session_id=claim.session_id AND d.round_id=claim.round_id AND d.state='risolta'
   UNION
   SELECT 'jutsu',f.actor_id FROM combat_panel_private.multiplication_resolutions mr
    JOIN combat_panel_private.multiplication_formations f ON f.id=mr.formation_id
    JOIN public.combat_v2_attack_targets t ON t.id=mr.attack_target_id
    JOIN public.combat_v2_declarations d ON d.id=t.attack_declaration_id
    WHERE f.session_id=claim.session_id AND d.round_id=claim.round_id AND d.state='risolta'
      AND t.state IN('risolta','superflua')
   UNION
   SELECT 'jutsu',f.actor_id FROM clan_sabaku_private.clone_captures cc
    JOIN combat_panel_private.multiplication_formations f ON f.id=cc.formation_id
    WHERE cc.round_id=claim.round_id AND f.session_id=claim.session_id
  ) x ORDER BY x.catalog,x.actor_id
 LOOP
  IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.members m
    WHERE m.session_id=claim.session_id AND m.actor_id=ref.actor_id) THEN
   RAISE EXCEPTION 'narrative_tech_actor_not_in_scene' USING ERRCODE='22023';
  END IF;
  IF ref.catalog='clan_techniques' THEN
   native_id:='617484d6-af7b-41c3-a37f-615b22818421';
   SELECT jsonb_build_object('id',id,'name',name,'description',description,'danno_effetto',danno_effetto)
     INTO STRICT content FROM public.clan_techniques WHERE id=native_id;
  ELSE
   native_id:='c6e31b7b-38fe-4b4f-b3c7-05f3e922d193';
   SELECT jsonb_build_object('id',id,'name_it',name_it,'effect',effect,'limits',limits)
     INTO STRICT content FROM public.jutsu WHERE id=native_id;
  END IF;
  sources:=sources||jsonb_build_array(jsonb_build_object('catalog',ref.catalog,'technique_id',native_id,
    'actor_id',ref.actor_id,'mapping_version','ordinary-tech/1','source_sha256',
    encode(extensions.digest(convert_to(content::text,'UTF8'),'sha256'),'hex'),'content',content));
 END LOOP;
 -- Terminal event only when the native capture and native terminal state agree.
 -- No original index, figures, coordinates, dice, private stats, or inference from damage.
 FOR event IN
  SELECT cc.id,cc.copy_hit,cc.result,c.actor_id,c.state,c.end_reason,c.ended_at,cc.created_at
  FROM clan_sabaku_private.clone_captures cc JOIN clan_sabaku_private.clones c ON c.id=cc.clone_id
  WHERE cc.round_id=claim.round_id AND c.session_id=claim.session_id
  ORDER BY cc.created_at,cc.id
 LOOP
  IF event.result->>'schema_version' IS DISTINCT FROM 'sabaku-clone-capture/1'
    OR event.result->'copy_hit' IS DISTINCT FROM to_jsonb(event.copy_hit)
    OR jsonb_typeof(event.result->'success') IS DISTINCT FROM 'boolean' THEN
   RAISE EXCEPTION 'narrative_tech_capture_invalid' USING ERRCODE='22023';
  END IF;
  IF event.result->'success'='false'::jsonb THEN
   IF event.state IS DISTINCT FROM 'ended' OR event.ended_at IS NULL
    OR event.ended_at<event.created_at
    OR event.end_reason IS DISTINCT FROM (CASE WHEN event.copy_hit THEN 'copy_triggered' ELSE 'capture_failed' END) THEN
    RAISE EXCEPTION 'narrative_tech_terminal_event_missing' USING ERRCODE='22023';
   END IF;
   endings:=endings||jsonb_build_array(jsonb_build_object('tecnica','Clone di Sabbia','actor_id',event.actor_id,
      'stato','terminato','causa',event.end_reason));
  END IF;
 END LOOP;
 RETURN jsonb_build_object('fonti_tecniche',sources,'conclusioni_effetti_server',endings);
END $function$;

ALTER FUNCTION combat_consumer_private.narrative_tech_sources_v1(uuid) OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_consumer_private.narrative_tech_sources_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_consumer_private.narrative_tech_sources_v1(uuid) TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_consumer_private.scene_snapshot_v2(p_claim uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_consumer_private.narrative_claims%ROWTYPE;
  activity combat_consumer_private.activities%ROWTYPE; row record; snap jsonb; candidate jsonb;
  actors jsonb; actions jsonb:='[]'; sources jsonb:='[]'; role_count integer:=0;
  prior_count integer:=0; included integer:=0; current_round integer; place public.locations%ROWTYPE;
  body_sha text; facts jsonb;
BEGIN
  SELECT * INTO STRICT c FROM combat_consumer_private.narrative_claims WHERE id=p_claim;
  SELECT * INTO STRICT activity FROM combat_consumer_private.activities WHERE session_id=c.session_id;
  SELECT round_no INTO STRICT current_round FROM public.combat_v2_rounds WHERE id=c.round_id;
  SELECT * INTO STRICT place FROM public.locations WHERE id=activity.location_id;
  IF c.context_payload->>'genere' NOT IN('confronto','rinuncia','azione_risolta') THEN RAISE EXCEPTION 'scene_kind_unsupported'; END IF;
  SELECT jsonb_agg(jsonb_build_object('id',m.actor_id,'name',ch.name,'kind','PG','persona',null,'may_speak',false) ORDER BY m.actor_id)
    INTO actors FROM combat_consumer_private.members m JOIN public.characters ch ON ch.id=m.character_id
    WHERE m.session_id=c.session_id;
  IF jsonb_array_length(actors) IS DISTINCT FROM 2 THEN RAISE EXCEPTION 'scene_current_consumer_roster_unsupported'; END IF;
  -- La descrizione del luogo è ambientazione pubblica. Event_note esclusa: nessuna nuova policy implicita.
  IF nullif(btrim(place.description),'') IS NOT NULL THEN
    sources:=sources||jsonb_build_array(jsonb_build_object('id','location:'||place.id,'session_id',c.session_id,
      'round_id',c.round_id,'kind','setting','actor_id',null,'sequence',current_round,'body',place.description,
      'sha256',encode(extensions.digest(convert_to(place.description,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
  END IF;
  FOR row IN
    SELECT d.id,d.actor_id,d.kind,m.id message_id,m.body,m.location_id,m.character_id,l.message_sha256,mem.character_id expected_character
    FROM public.combat_v2_declarations d
    JOIN combat_consumer_private.members mem ON mem.actor_id=d.actor_id AND mem.session_id=c.session_id
    LEFT JOIN combat_consumer_private.declaration_messages l ON l.declaration_id=d.id
    LEFT JOIN public.messages m ON m.id=l.message_id
    WHERE d.round_id=c.round_id AND d.kind IN('attacco','utilita','passa','movimento','difesa','nessuna')
    ORDER BY CASE WHEN d.kind IN('difesa','nessuna') THEN 1 ELSE 0 END,d.id
  LOOP
    IF row.message_id IS NULL OR row.location_id IS DISTINCT FROM activity.location_id
      OR row.character_id IS DISTINCT FROM row.expected_character OR nullif(btrim(row.body),'') IS NULL
      OR public._combat_narrative_sha(row.message_id) IS DISTINCT FROM row.message_sha256 THEN RAISE EXCEPTION 'scene_current_source_invalid'; END IF;
    role_count:=role_count+1;
    actions:=actions||jsonb_build_array(jsonb_build_object('actor_id',row.actor_id,
      'role',CASE WHEN row.kind IN('difesa','nessuna') THEN 'difesa' ELSE 'azione' END,'source_id',row.message_id));
    body_sha:=encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex');
    sources:=sources||jsonb_build_array(jsonb_build_object('id',row.message_id,'session_id',c.session_id,'round_id',c.round_id,
      'kind','role','actor_id',row.actor_id,'sequence',current_round,'body',row.body,'sha256',body_sha,'visibility','public','complete',true));
  END LOOP;
  IF role_count<>(CASE WHEN c.context_payload->>'genere'='confronto' OR c.context_payload->>'reazione' IS NOT NULL THEN 2 ELSE 1 END) THEN
    RAISE EXCEPTION 'scene_current_actions_incomplete'; END IF;
  -- Proiezione narrativa già prodotta dal server: nessuna lettura di mechanics_snapshot o ricalcolo.
  facts:=c.context_payload-ARRAY['player_reports','gia_visto','ordinary','model'];
  IF c.context_payload->>'ordinary'='true' AND c.context_payload->>'genere'='azione_risolta'
    AND EXISTS(SELECT 1 FROM combat_consumer_private.activities staff_activity
      JOIN public.combat_v2_sessions staff_session ON staff_session.id=staff_activity.session_id
      JOIN public.locations staff_location ON staff_location.id=staff_activity.location_id
      WHERE staff_activity.session_id=c.session_id AND staff_activity.exchange_id=c.round_id
        AND staff_activity.phase='resolved' AND staff_activity.policy_id='staff_test_no_persistent_resources_v1'
        AND staff_session.source_kind='ordinary' AND staff_session.location_id=staff_activity.location_id
        AND staff_location.is_test AND NOT public.combat_v2_values_written(staff_session.id)
        AND combat_consumer_private.staff_test_allowed(staff_location.id,
          (SELECT array_agg(actor.controller_user ORDER BY actor.id)
           FROM combat_consumer_private.members member JOIN public.combat_v2_actors actor
             ON actor.id=member.actor_id AND actor.session_id=member.session_id
             AND actor.character_id=member.character_id
           WHERE member.session_id=c.session_id),false)) THEN
    facts:=facts||combat_consumer_private.narrative_tech_sources_v1(c.id);
  END IF;
  SELECT count(*) INTO prior_count FROM public.combat_v2_narratives n JOIN public.combat_v2_rounds r ON r.id=n.round_id
    WHERE r.session_id=c.session_id AND r.round_no<current_round AND r.state='narrato';
  snap:=jsonb_build_object('schema_version','combat-scene/1','session_id',c.session_id,'round_id',c.round_id,
    'report_sha256',c.report_sha256,'control_version',c.control_version,'location',place.name,
    'actors',actors,'actions',actions,'resolved_facts',facts::text,'sources',sources,
    'selection',jsonb_build_object('max_input_bytes',49152,'previous_available',prior_count,'previous_included',0));
  IF octet_length(snap::text)>49152 THEN RAISE EXCEPTION 'scene_required_context_overflow'; END IF;
  FOR row IN SELECT n.id,n.round_id,n.body,r.round_no FROM public.combat_v2_narratives n
    JOIN public.combat_v2_rounds r ON r.id=n.round_id WHERE r.session_id=c.session_id AND r.round_no<current_round
    AND r.state='narrato' ORDER BY r.round_no DESC,n.id
  LOOP
    candidate:=jsonb_set(snap,'{sources}',(snap->'sources')||jsonb_build_array(jsonb_build_object('id',row.id,
      'session_id',c.session_id,'round_id',row.round_id,'kind','fato','actor_id',null,'sequence',row.round_no,'body',row.body,
      'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true)));
    candidate:=jsonb_set(candidate,'{selection,previous_included}',to_jsonb(included+1));
    EXIT WHEN octet_length(candidate::text)>49152;
    included:=included+1; snap:=candidate;
  END LOOP;
  RETURN snap;
END $function$;

ALTER FUNCTION combat_consumer_private.scene_snapshot_v2(uuid) OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_consumer_private.scene_snapshot_v2(uuid) FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_consumer_private.scene_snapshot_v2(uuid) TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_attack_finish(p_target uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE f record;
BEGIN
 FOR f IN SELECT r.formation_id,m.mode,m.actor_id,m.declaration_id,t.target_actor_id,d.id AS attack_id,d.actor_id AS attacker_id FROM combat_panel_private.multiplication_resolutions r
   JOIN combat_panel_private.multiplication_formations m ON m.id=r.formation_id
   JOIN public.combat_v2_attack_targets t ON t.id=r.attack_target_id
   JOIN public.combat_v2_declarations d ON d.id=t.attack_declaration_id
   WHERE r.attack_target_id=p_target ORDER BY r.formation_id LOOP
   PERFORM combat_panel_private.multiplication_finish(f.formation_id,
     CASE WHEN f.mode='assalto' AND f.declaration_id=f.attack_id AND f.actor_id=f.attacker_id
       THEN 'assault_resolved' ELSE 'first_attack' END);
 END LOOP;
END $function$;

ALTER FUNCTION combat_panel_private.multiplication_attack_finish(uuid) OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_panel_private.multiplication_attack_finish(uuid) FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_panel_private.multiplication_attack_finish(uuid) TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_finish(p_formation uuid, p_reason text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE f combat_panel_private.multiplication_formations%ROWTYPE;
BEGIN
 IF p_reason IS NULL OR p_reason NOT IN ('first_attack','assault_resolved','owner_next_action','owner_inoperative','combat_end','formation_invalid') THEN
   RAISE EXCEPTION 'panel_multiplication_finish_reason_invalid' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT f FROM combat_panel_private.multiplication_formations WHERE id=p_formation FOR UPDATE;
 IF f.state<>'active' THEN RETURN false; END IF;
 IF p_reason='assault_resolved' AND f.mode<>'assalto' THEN
   RAISE EXCEPTION 'panel_multiplication_mode_mismatch' USING ERRCODE='22023'; END IF;
 UPDATE combat_panel_private.multiplication_formations SET
   state=CASE WHEN p_reason IN ('first_attack','assault_resolved') THEN 'consumed' ELSE 'expired' END,
   state_version=state_version+1,terminal_reason=p_reason,ended_at=clock_timestamp() WHERE id=f.id;
 RETURN true;
END $function$;

ALTER FUNCTION combat_panel_private.multiplication_finish(uuid,text) OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_panel_private.multiplication_finish(uuid,text) FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_panel_private.multiplication_finish(uuid,text) TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_resolve_choice(p_formation uuid, p_target uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE f combat_panel_private.multiplication_formations%ROWTYPE; t public.combat_v2_attack_targets%ROWTYPE;
 d public.combat_v2_declarations%ROWTYPE; chosen combat_panel_private.multiplication_choices%ROWTYPE;
 previous combat_panel_private.multiplication_resolutions%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 source jsonb; aoe boolean; eye boolean; idx integer; how text; result text; seed bytea; facts jsonb; draw combat_panel_private.multiplication_attack_aims%ROWTYPE;
BEGIN
 SELECT * INTO STRICT t FROM public.combat_v2_attack_targets WHERE id=p_target;
 PERFORM public.combat_v2_lock_round(t.round_id);
 SELECT * INTO STRICT f FROM combat_panel_private.multiplication_formations WHERE id=p_formation FOR UPDATE;
 SELECT * INTO previous FROM combat_panel_private.multiplication_resolutions WHERE formation_id=f.id AND attack_target_id=t.id;
 IF FOUND THEN RETURN previous.facts; END IF;
 IF f.state<>'active' THEN RETURN NULL; END IF;
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=t.attack_declaration_id AND round_id=t.round_id;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=combat_panel_private.multiplication_chooser(f.id,t.id) AND session_id=f.session_id;
 SELECT * INTO chosen FROM combat_panel_private.multiplication_choices WHERE formation_id=f.id AND attack_target_id=t.id;
 IF chosen.id IS NOT NULL AND (chosen.chooser_actor_id<>a.id
   OR NOT combat_panel_private.controller_version_valid(a.id,chosen.controller_version,NULL)) THEN
   RAISE EXCEPTION 'panel_multiplication_chooser_changed' USING ERRCODE='40001'; END IF;
 IF f.mode='assalto' AND f.declaration_id=d.id AND f.actor_id=d.actor_id THEN
   SELECT defense.sanitized_intent INTO source FROM public.combat_v2_defense_coverages c
     JOIN public.combat_v2_declarations defense ON defense.id=c.defense_declaration_id
     WHERE c.attack_target_id=t.id AND defense.actor_id=a.id;
 ELSE source:=d.sanitized_intent; END IF;
 aoe:=coalesce(public._formazione_catalogo_colpisce(nullif(source->>'ability_id','')::uuid,source->>'ability_source'),false);
 eye:=combat_panel_private.multiplication_actor_recognizes(a.id);
 -- Le autorita prevalgono anche su una scelta esplicita errata.
 IF aoe THEN idx:=f.original_index; how:='formation_coverage';
 ELSIF eye THEN idx:=f.original_index; how:='active_dojutsu';
 ELSIF chosen.selected_index IS NOT NULL THEN
   SELECT * INTO draw FROM combat_panel_private.multiplication_attack_aims
    WHERE attack_target_id=t.id AND choice_id=chosen.id AND formation_id=f.id AND random_seed IS NOT NULL;
   IF draw.request_key IS NOT NULL THEN
    idx:=draw.random_indices[combat_panel_private.multiplication_random_figure(cardinality(draw.random_indices),draw.random_seed)];
    IF idx IS DISTINCT FROM chosen.selected_index OR idx IS DISTINCT FROM draw.selected_index
     OR draw.actor_id<>a.id OR draw.round_id<>t.round_id THEN
     RAISE EXCEPTION 'panel_multiplication_draw_receipt_invalid' USING ERRCODE='40001'; END IF;
    seed:=draw.random_seed;how:='server_random';
   ELSE idx:=chosen.selected_index;how:='explicit'; END IF;
 ELSE
   seed:=extensions.gen_random_bytes(32);
   idx:=combat_panel_private.multiplication_random_figure(f.copy_count+1,seed); how:='server_random';
 END IF;
 result:=CASE WHEN idx=f.original_index THEN 'original_found' ELSE 'copy_hit' END;
 facts:=jsonb_build_object('schema_version','combat-multiplication-resolution/1',
   'formation_id',f.id,'attack_target_id',t.id,'mode',f.mode,'selected_index',idx,'choice_kind',how,'outcome',result,
   'rng_commitment',CASE WHEN seed IS NULL THEN NULL ELSE encode(extensions.digest(seed,'sha256'),'hex') END);
 INSERT INTO combat_panel_private.multiplication_resolutions(formation_id,attack_target_id,chooser_actor_id,selected_index,choice_kind,outcome,rng_seed,facts,receipt_sha256)
   VALUES(f.id,t.id,a.id,idx,how,result,seed,facts,public.combat_v2_sha256(facts));
 -- Il resolver applica questi fatti e termina la formazione nella stessa
 -- transazione. Qui non si alterano difese, danni o dichiarazioni gia inviate.
 RETURN facts;
END $function$;

ALTER FUNCTION combat_panel_private.multiplication_resolve_choice(uuid,uuid) OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_panel_private.multiplication_resolve_choice(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_panel_private.multiplication_resolve_choice(uuid,uuid) TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_selection_immutable()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
BEGIN
 RAISE EXCEPTION 'panel_multiplication_selection_immutable' USING ERRCODE='22023';
END $function$;

ALTER FUNCTION combat_panel_private.multiplication_selection_immutable() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_panel_private.multiplication_selection_immutable() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_panel_private.multiplication_selection_immutable() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_state_guard()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE original jsonb;
BEGIN
 IF TG_OP='UPDATE' THEN
   IF (to_jsonb(NEW)-ARRAY['state','state_version','terminal_reason','ended_at'])
     IS DISTINCT FROM (to_jsonb(OLD)-ARRAY['state','state_version','terminal_reason','ended_at']) THEN
     RAISE EXCEPTION 'panel_multiplication_identity_immutable' USING ERRCODE='22023'; END IF;
   IF OLD.state<>'active' OR NEW.state='active' OR NEW.state_version<>OLD.state_version+1 THEN
     RAISE EXCEPTION 'panel_multiplication_terminal_invalid' USING ERRCODE='40001'; END IF;
   RETURN NEW;
 END IF;
 IF NEW.state<>'active' OR NEW.state_version<>1 OR NOT EXISTS(
   SELECT 1 FROM public.combat_v2_declarations d
   JOIN public.combat_v2_rounds r ON r.id=d.round_id
   JOIN public.combat_v2_actors a ON a.id=d.actor_id AND a.session_id=r.session_id
   JOIN combat_spatial.arena_instances i ON i.instance_id=NEW.instance_id AND i.encounter_id=r.session_id AND i.state='open'
   WHERE d.id=NEW.declaration_id AND d.round_id=NEW.round_id AND d.actor_id=NEW.actor_id
    AND r.session_id=NEW.session_id AND a.state='attivo' AND a.companion_id IS NULL
    AND a.actor_kind IN ('pg','png')
    AND d.kind=CASE WHEN NEW.mode='assalto' THEN 'attacco' ELSE 'utilita' END) THEN
   RAISE EXCEPTION 'panel_multiplication_declaration_scope_invalid' USING ERRCODE='22023'; END IF;
 SELECT f INTO STRICT original FROM jsonb_array_elements(NEW.figures) f
   WHERE (f->>'figure_index')::integer=NEW.original_index;
 -- Il corpo reale deve occupare proprio la figura sigillata, dopo il movimento
 -- autorizzato del commit; nessun originale virtuale scollegato dalla mappa.
 IF NOT EXISTS(SELECT 1 FROM combat_spatial.actor_states a
   WHERE a.instance_id=NEW.instance_id AND a.actor_id=NEW.actor_id AND a.state='active'
    AND a.body_version=NEW.source_body_version
    AND a.x_m=(original->>'x_m')::numeric AND a.y_m=(original->>'y_m')::numeric) THEN
   RAISE EXCEPTION 'panel_multiplication_original_position_invalid' USING ERRCODE='40001'; END IF;
 RETURN NEW;
END $function$;

ALTER FUNCTION combat_panel_private.multiplication_state_guard() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_panel_private.multiplication_state_guard() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_panel_private.multiplication_state_guard() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION public.combat_v2_sha256(p_value jsonb)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO ''
AS $function$
  select encode(extensions.digest(convert_to(coalesce(p_value,'null'::jsonb)::text,'UTF8'),'sha256'),'hex')
$function$;

ALTER FUNCTION combat_v2_sha256(jsonb) OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_v2_sha256(jsonb) FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_v2_sha256(jsonb) TO "postgres";

GRANT EXECUTE ON FUNCTION combat_v2_sha256(jsonb) TO "service_role";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_assault_end()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE fid uuid;
BEGIN
 IF NEW.state IN ('risolta','superflua') AND OLD.state IS DISTINCT FROM NEW.state THEN
   FOR fid IN SELECT id FROM combat_panel_private.multiplication_formations
     WHERE declaration_id=NEW.id AND mode='assalto' AND state='active' ORDER BY id LOOP
     PERFORM combat_panel_private.multiplication_finish(fid,'assault_resolved');
   END LOOP;
 END IF;
 RETURN NEW;
END $function$;

ALTER FUNCTION combat_panel_private.multiplication_assault_end() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_panel_private.multiplication_assault_end() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_panel_private.multiplication_assault_end() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_v2_multitarget_internal.resolve_parent(p_session uuid, p_round uuid, p_attack uuid, p_values boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare multiplication_facts jsonb; multiplication_effect jsonb; d public.combat_v2_declarations%rowtype;att public.combat_v2_actors%rowtype;tar public.combat_v2_actors%rowtype;defender public.combat_v2_actors%rowtype;
 t public.combat_v2_attack_targets%rowtype;c public.combat_v2_defense_coverages%rowtype;def public.combat_v2_declarations%rowtype;
 meta jsonb;calc jsonb;rng jsonb;parent_entropy bytea;entropy bytea;ctx text;reaction text;kind text;base int;
 a1 int;a2 int;d1 int;d2 int;vote_a int;vote_d int;corr int;raw int;final int;full_damage int;damage int;hp int;
 any_success boolean:=false;children jsonb:='[]';child_outcome jsonb;receipt text;old_slancio int;
begin
 select*into strict d from public.combat_v2_declarations where id=p_attack and round_id=p_round for update;
 select*into strict att from public.combat_v2_actors where id=d.actor_id for update;
 if d.sanitized_intent->>'ability_source'='clan' and d.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
  if (select count(*) from public.combat_v2_attack_targets where attack_declaration_id=d.id)<>1 then raise exception 'marionetta_single_target_required' using errcode='22023';end if;
  calc:=public.combat_v2_clan_genin_marionettisti_resolve_v1(jsonb_build_object('contract_version','marionetta-round-hook/1','declaration_id',d.id,'request_key',d.id));
  att.mechanics_snapshot:=att.mechanics_snapshot||jsonb_build_object('marionetta_profile',calc->'profile');
 end if;
 meta:=d.sanitized_intent->'server_ability';base:=coalesce((d.cost_snapshot->>'damage_base')::int,0);
 select coalesce((select value from public.combat_v2_ratings where declaration_id=d.id and is_active order by created_at desc limit 1),0)into vote_a;
 old_slancio:=coalesce((att.mechanics_snapshot->>'slancio')::int,0);
 parent_entropy:=extensions.gen_random_bytes(32);
 for t in select*from public.combat_v2_attack_targets where attack_declaration_id=d.id order by ordinal for update loop
  select*into strict c from public.combat_v2_defense_coverages where attack_target_id=t.id for update;
  select*into strict def from public.combat_v2_declarations where id=c.defense_declaration_id for update;
  select*into strict defender from public.combat_v2_actors where id=def.actor_id for update;
  select*into strict tar from public.combat_v2_actors where id=t.target_actor_id for update;
  if (case when combat_panel_private.has_master_geometry(p_session)
    then not combat_panel_private.controller_version_valid(tar.id,t.target_controller_version)
    else tar.controller_version is distinct from t.target_controller_version end) then raise exception 'targeting_geometry_stale';end if;
  if (case when combat_panel_private.has_master_geometry(p_session)
    then not combat_panel_private.controller_version_valid(defender.id,c.defender_controller_version,def.controller_user_snapshot)
    else defender.controller_version is distinct from c.defender_controller_version end) then raise exception 'defender_controller_stale';end if;
  if c.mode<>'self'and(case when combat_panel_private.has_master_geometry(p_session)
     then not combat_panel_private.coverage_geometry_valid(c.id,defender.id)
     else abs(defender.position_m-tar.position_m)>2
       or tar.position_m is distinct from c.protected_position_m end)then raise exception 'targeting_geometry_stale';end if;
  if tar.state<>'attivo'then
   child_outcome:=jsonb_build_object('success',false,'damage_applied',0,'reason','bersaglio_gia_fuori','child_ordinal',t.ordinal);
   update public.combat_v2_attack_targets set state='superflua',outcome=child_outcome where id=t.id;
  else
   reaction:=coalesce(def.sanitized_intent->>'reaction','nessuna');
   multiplication_facts:=combat_panel_private.multiplication_attack_facts(t.id);
   multiplication_effect:=combat_panel_private.multiplication_effect(multiplication_facts,reaction);
   reaction:=multiplication_effect->>'effective_reaction';kind:=lower(coalesce(meta->>'kind','fisico'));if kind not in('fisico','ninjutsu','genjutsu')then kind:='fisico';end if;
   ctx:='combat-v2/r3/multi-child:'||p_session::text||':'||p_round::text||':'||d.id::text||':'||t.id::text;
   -- Un solo seal parent nel ledger RNG esistente; l'entropia child e' derivata
   -- su un dominio distinto target/ordinale, quindi ogni child ha dadi indipendenti.
   entropy:=extensions.hmac(convert_to(ctx,'UTF8'),parent_entropy,'sha256');
   a1:=public.combat_v2_derive_d10(entropy,ctx,1);a2:=public.combat_v2_derive_d10(entropy,ctx,2);d1:=public.combat_v2_derive_d10(entropy,ctx,3);d2:=public.combat_v2_derive_d10(entropy,ctx,4);
   calc:=public._combat_calcola(kind,att.mechanics_snapshot,case when tar.companion_id is not null then clan_marionettisti_private.defense_snapshot(defender.id,tar.id,reaction) else defender.mechanics_snapshot end,reaction,
    coalesce(def.sanitized_intent->'server_ability'->>'kind','taijutsu'),base,meta->>'element',a1+a2,d1+d2,0,0,false);
   rng:=jsonb_build_object('scheme','combat-v2-child-derive/1.0','child_id',t.id,
    'commitment',encode(extensions.digest(entropy,'sha256'),'hex'),
    'dice_attack',jsonb_build_array(a1,a2),'dice_defense',jsonb_build_array(d1,d2));
   select coalesce((select value from public.combat_v2_ratings where declaration_id=def.id and is_active order by created_at desc limit 1),0)into vote_d;
   corr:=greatest(-3,least(3,vote_a-CASE WHEN (multiplication_effect->>'defense_spent_on_copy')::boolean THEN 0 ELSE vote_d END));raw:=(calc->>'margine')::int;final:=raw+corr;
   if (multiplication_effect->>'copy_intercepted')::boolean or kind='genjutsu'and final<0 then damage:=0;
   elsif final<0 then damage:=greatest(1,greatest(1,base+((calc->>'off')::int/4)-(calc->>'riduzione')::int)/4);
   else full_damage:=greatest(1,base+((calc->>'off')::int/4)+coalesce((calc->>'bonus_margine')::int,0)-(calc->>'riduzione')::int);damage:=least(65,full_damage);end if;
   hp:=greatest(0,coalesce((tar.mechanics_snapshot->>'vita')::int,0)-damage);
   update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{vita}',to_jsonb(hp),false),state=case when hp=0 then'fuori'else state end where id=tar.id;
   if p_values and tar.actor_kind='pg'and damage>0 then perform set_config('app.allow_vita_delta','1',true);update public.characters set vita=hp where id=tar.character_id;perform set_config('app.allow_vita_delta','0',true);end if;
   any_success:=any_success or (final>=0 AND NOT (multiplication_effect->>'copy_intercepted')::boolean);
   child_outcome:=jsonb_build_object('child_id',t.id,'child_ordinal',t.ordinal,'target_actor_id',tar.id,'raw',calc,'rng_audit',rng,
    'rating_attack',vote_a,'rating_defense',vote_d,'quality_correction',corr,'threshold_margin',final,'success',final>=0 AND NOT (multiplication_effect->>'copy_intercepted')::boolean,
    'damage_policy','full_each','damage_applied',damage,'target_hp_after',hp,'ko',hp=0);
   IF jsonb_array_length(multiplication_facts)>0 THEN
     child_outcome:=child_outcome||jsonb_build_object('multiplication',multiplication_facts,'multiplication_effect',multiplication_effect);
    END IF;
    receipt:=combat_v2_multitarget_internal.sha(child_outcome);
   update public.combat_v2_attack_targets set state='risolta',outcome=child_outcome,rng_receipt_sha256=receipt where id=t.id;
  end if;
  PERFORM combat_panel_private.multiplication_attack_finish(t.id);
   update public.combat_v2_defense_coverages set state='risolta'where id=c.id;
  children:=children||jsonb_build_array(child_outcome);
 end loop;
 update public.combat_v2_declarations dd set state='risolta',outcome=jsonb_build_object(
   'linked_attacks',(select coalesce(jsonb_agg(distinct mt.attack_declaration_id order by mt.attack_declaration_id),'[]'::jsonb)
      from public.combat_v2_defense_coverages cv join public.combat_v2_attack_targets mt on mt.id=cv.attack_target_id where cv.defense_declaration_id=dd.id),
   'coverage',(select coalesce(jsonb_agg(jsonb_build_object('attack_target_id',cv2.attack_target_id,'protected_actor_id',cv2.protected_actor_id,'mode',cv2.mode,'state',cv2.state) order by cv2.attack_target_id),'[]'::jsonb)
      from public.combat_v2_defense_coverages cv2 where cv2.defense_declaration_id=dd.id),
   'coverage_count',(select count(*) from public.combat_v2_defense_coverages cv3 where cv3.defense_declaration_id=dd.id))
 where dd.id in(select distinct cv.defense_declaration_id from public.combat_v2_defense_coverages cv join public.combat_v2_attack_targets mt on mt.id=cv.attack_target_id where mt.attack_declaration_id=d.id);
 perform combat_v2_private.rng_seal(p_session,p_round,d.id,'attack',
  'combat-v2/r3/multi-parent:'||p_session::text||':'||p_round::text||':'||d.id::text,
  parent_entropy,jsonb_build_object('scheme','combat-v2-child-derive/1.0','children',children));
 update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{slancio}',to_jsonb(case when any_success then 0 else least(9,old_slancio+3)end),true)where id=att.id;
 update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('targeting_mode',case when jsonb_array_length(children)>1 then'multi'else'single'end,
  'damage_policy','full_each','child_count',jsonb_array_length(children),'any_success',any_success,'slancio_before',old_slancio,
  'slancio_after',case when any_success then 0 else least(9,old_slancio+3)end,'children',children)where id=d.id;
 return jsonb_build_object('any_success',any_success,'children',children);
end$function$;

ALTER FUNCTION combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean) OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean) FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean) TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION public.combat_v2_round_resolve(p_round uuid, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare multiplication_facts jsonb; multiplication_effect jsonb; multiplication_target uuid; v_uid uuid:=auth.uid(); v_r public.combat_v2_rounds%rowtype; v_s public.combat_v2_sessions%rowtype; v_m public.master_v2_sessions%rowtype;
  v_event jsonb; v_event_id uuid; v_values boolean; v_entropy bytea; v_order_entropy bytea; v_before jsonb; v_after jsonb;
  v_d public.combat_v2_declarations%rowtype; v_def public.combat_v2_declarations%rowtype; v_att public.combat_v2_actors%rowtype; v_tar public.combat_v2_actors%rowtype;
  v_meta jsonb; v_calc jsonb; v_rng jsonb; v_kind text; v_reaction text; v_base int; v_dice_a int; v_dice_d int;
  v_a1 int; v_a2 int; v_d1 int; v_d2 int; v_rng_context text; v_order_context text; v_order_rng jsonb;
  v_vote_a int; v_vote_d int; v_corr int; v_raw int; v_final int; v_damage int; v_full int; v_new_hp int;
  v_report jsonb; v_report_id uuid; v_sha text; v_result jsonb; v_chakra int; v_need int; v_order int:=0;
begin
  if v_uid is null and not public.combat_v2_is_service() then perform public.combat_v2_fail('autenticazione_richiesta','Autenticazione richiesta.',401,p_request_key,'{}'); end if;
  perform public.combat_v2_lock_round(p_round);
  select * into v_r from public.combat_v2_rounds where id=p_round for update;
  if v_r.id is null then perform public.combat_v2_fail('sessione_inesistente','Round inesistente.',404,p_request_key,'{}'); end if;
  select * into v_s from public.combat_v2_sessions where id=v_r.session_id for update;
  if v_s.master_session_id is not null then select * into v_m from public.master_v2_sessions where id=v_s.master_session_id for update; end if;
  if v_s.source_kind='master' and v_m.master_user<>v_uid and not public.combat_v2_is_service() then perform public.combat_v2_fail('master_non_proprietario','Solo il Master corrente può risolvere.',403,p_request_key,'{}'); end if;
  if combat_consumer_private.owns_round(p_round) then perform combat_consumer_private.assert_dispatch(p_round,p_request_key,'resolve'); else if v_s.source_kind='ordinary' and not public.combat_v2_is_service() then perform public.combat_v2_fail('controllo_revocato','Risoluzione ordinary solo server.',403,p_request_key,'{}'); end if; end if;
  perform public.combat_v2_assert_operational(p_round,p_request_key,false);
  -- [MISSION-GUARD-005] Precheck globale prima di evento, freeze e costi.
  if exists(select 1 from public.combat_v2_declarations d
     where d.round_id=p_round and d.kind in ('difesa','nessuna')
       and(coalesce(d.sanitized_intent->>'reaction','nessuna')='copie'
        or(coalesce(d.sanitized_intent->>'reaction','nessuna')='tecnica'
          and coalesce(d.sanitized_intent#>>'{server_ability,targeting,mode}','')not in('intercept','multi_protect')))
  ) then
    perform public.combat_v2_fail('profilo_runtime_non_disponibile','La difesa speciale non ha un resolver V2 attivo.',409,p_request_key,'{}');
  end if;
  v_event:=public.combat_v2_event_begin(p_round,p_request_key,'combat_v2_round_resolve',jsonb_build_object('round',p_round),v_m.control_version);
  if (v_event->>'replay')::boolean then return v_event->'result'; end if; v_event_id:=(v_event->>'event_id')::uuid;
  if v_r.state in ('risolto','narrazione','narrato') then
    select public.combat_v2_envelope(p_request_key,jsonb_build_object('report_id',x.id,'report_sha256',x.mechanics_sha256,'replay',true)) into v_result from public.combat_v2_round_reports x where x.round_id=p_round;
    return public.combat_v2_event_complete(v_event_id,v_result);
  end if;
  if (select count(*) from public.combat_v2_declarations where round_id=p_round and kind in ('attacco','movimento','utilita','passa')) <>
     combat_consumer_private.expected_main_count(p_round) then
    perform public.combat_v2_fail('dichiarazioni_mancanti','Mancano dichiarazioni principali.',409,p_request_key,'{}'); end if;
  if not combat_v2_multitarget_internal.round_complete(p_round) then
    perform public.combat_v2_fail('difese_mancanti','Mancano difese.',409,p_request_key,'{}'); end if;
  if v_r.evaluation_mode='neutra' then
    insert into public.combat_v2_ratings(declaration_id,session_id,round_id,pg_character_id,rating_kind,value,source,request_key)
    select d.id,v_s.id,p_round,a.character_id,d.kind,0,'neutralita_sistema',gen_random_uuid()
      from public.combat_v2_declarations d join public.combat_v2_actors a on a.id=d.actor_id
     where d.round_id=p_round and d.kind in ('attacco','difesa') and a.actor_kind='pg'
       and not exists(select 1 from public.combat_v2_ratings x where x.declaration_id=d.id and x.is_active);
  elsif exists(select 1 from public.combat_v2_declarations d join public.combat_v2_actors a on a.id=d.actor_id
    where d.round_id=p_round and d.kind in ('attacco','difesa') and a.actor_kind='pg'
      and not exists(select 1 from public.combat_v2_ratings x where x.declaration_id=d.id and x.is_active)) then
    perform public.combat_v2_fail('voto_richiesto','Mancano voti del Master.',409,p_request_key,'{}');
  end if;
  -- Ordine globale: sessione e round sono già bloccati; ora attori e risorse per UUID.
  perform 1 from public.combat_v2_actors a where a.session_id=v_s.id order by a.id for update;
  perform 1 from public.characters c where c.id in (select a.character_id from public.combat_v2_actors a where a.session_id=v_s.id and a.character_id is not null) order by c.id for update;
  v_before:=(select jsonb_agg(jsonb_build_object('actor',a.id,'state',a.state,'position_m',a.position_m,'mechanics',a.mechanics_snapshot) order by a.id) from public.combat_v2_actors a where a.session_id=v_s.id);
  -- Rivalidazione cumulativa dei costi prima di qualunque consumo.
  for v_att in select * from public.combat_v2_actors a where a.session_id=v_s.id order by a.id loop
    select coalesce(sum(coalesce((d.cost_snapshot->>'chakra')::int,0)),0) into v_need from public.combat_v2_declarations d where d.round_id=p_round and d.actor_id=v_att.id;
    v_chakra:=coalesce((v_att.mechanics_snapshot->>'chakra')::int,0);
    if v_need>v_chakra then perform public.combat_v2_fail('risorsa_insufficiente','Chakra insufficiente al freeze.',409,p_request_key,jsonb_build_object('actor',v_att.id)); end if;
  end loop;
  v_order_entropy:=extensions.gen_random_bytes(32);
  v_order_context:='combat-v2/r3/order:'||v_s.id::text||':'||p_round::text;
  update public.combat_v2_rounds set phase='congelato',state='congelato',
    rng_order_commitment=encode(extensions.digest(v_order_entropy,'sha256'),'hex'),freeze_at=clock_timestamp()
   where id=p_round;
  with ord as (
    select d.id,row_number() over(order by a.initiative_snapshot desc,
      (('x'||substr(encode(extensions.digest(v_order_entropy||convert_to(a.id::text,'UTF8'),'sha256'),'hex'),1,16))::bit(64)::bigint),a.id) n,
      (('x'||substr(encode(extensions.digest(v_order_entropy||convert_to(a.id::text,'UTF8'),'sha256'),'hex'),1,16))::bit(64)::bigint) tie
    from public.combat_v2_declarations d join public.combat_v2_actors a on a.id=d.actor_id
    where d.round_id=p_round and d.kind in ('attacco','movimento','utilita','passa'))
  update public.combat_v2_declarations d set order_no=ord.n,tie_break=ord.tie,state='congelata',frozen_at=clock_timestamp() from ord where d.id=ord.id;
  v_order_rng:=combat_v2_private.rng_seal(v_s.id,p_round,null,'order',v_order_context,v_order_entropy,
    jsonb_build_object('order_ties',coalesce((select jsonb_object_agg(d.id::text,d.tie_break order by d.id)
      from public.combat_v2_declarations d where d.round_id=p_round and d.kind in ('attacco','movimento','utilita','passa')),'{}'::jsonb)));
  update public.combat_v2_declarations set state='congelata',frozen_at=clock_timestamp() where round_id=p_round and kind in ('difesa','nessuna');
  for v_def in select * from public.combat_v2_declarations where round_id=p_round and kind='difesa' and sanitized_intent->>'reaction'='sostituzione' order by id loop
    perform combat_spatial.substitution_rebase_selected_internal_v1(v_def.id);
    perform public.combat_v2_substitution_resolve_internal_v1(v_def.id,md5(p_request_key::text||'|substitution|'||v_def.id::text)::uuid);
  end loop;
  update public.combat_v2_ratings set frozen_at=clock_timestamp() where round_id=p_round and frozen_at is null;
  v_values:=public.combat_v2_values_written(v_s.id);
  -- Impegno costi di tutte le dichiarazioni; nessun rimborso successivo.
  for v_d in select * from public.combat_v2_declarations where round_id=p_round and not(kind='difesa' and sanitized_intent->>'reaction'='sostituzione') order by actor_id,id loop
    select * into v_att from public.combat_v2_actors where id=v_d.actor_id for update;
    v_need:=coalesce((v_d.cost_snapshot->>'chakra')::int,0); v_chakra:=coalesce((v_att.mechanics_snapshot->>'chakra')::int,0);
    insert into public.combat_v2_resource_ledger(session_id,round_id,declaration_id,actor_id,resource_kind,expected_amount,committed_amount,applied_amount,is_simulated,balance_before,balance_after,idempotency_key)
    values(v_s.id,p_round,v_d.id,v_att.id,'chakra',v_need,v_need,case when v_values then v_need else 0 end,not v_values,v_chakra,case when v_values or combat_panel_private.uses_simulated_pools(v_s.id) then v_chakra-v_need else v_chakra end,gen_random_uuid());
    insert into public.combat_v2_resource_ledger(session_id,round_id,declaration_id,actor_id,resource_kind,expected_amount,committed_amount,applied_amount,is_simulated,idempotency_key)
    values(v_s.id,p_round,v_d.id,v_att.id,case when v_d.kind in ('difesa','nessuna') then 'reazione' else 'azione_principale' end,1,1,case when v_values then 1 else 0 end,not v_values,gen_random_uuid());
    if (v_values or combat_panel_private.uses_simulated_pools(v_s.id)) and v_need>0 then
      update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{chakra}',to_jsonb(v_chakra-v_need),false) where id=v_att.id;
      if v_values and v_att.actor_kind='pg' then
        perform set_config('app.allow_chakra_delta','1',true); update public.characters set chakra=chakra-v_need where id=v_att.character_id; perform set_config('app.allow_chakra_delta','0',true);
      end if;
    end if;
  end loop;
  update public.combat_v2_rounds set phase='risoluzione',state='risoluzione' where id=p_round;
  for v_d in select * from public.combat_v2_declarations where round_id=p_round and kind in ('attacco','movimento','utilita','passa') and state<>'risolta' order by order_no loop
    select * into v_att from public.combat_v2_actors where id=v_d.actor_id for update;
    if v_d.kind='movimento' then
      if combat_panel_private.has_master_geometry(v_s.id) then
        v_calc:=combat_panel_private.resolve_master_movement(v_d.id,p_request_key);
        update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;
      else
        update public.combat_v2_actors set position_m=greatest(0,least(1000,position_m+(v_d.sanitized_intent->>'move_m')::int)) where id=v_att.id;
        update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('movement_m',(v_d.sanitized_intent->>'move_m')::int) where id=v_d.id;
      end if;
    elsif v_d.kind='attacco' then
        if v_d.sanitized_intent->>'ability_source'='clan' and v_d.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
          begin
            v_calc:=public.combat_v2_clan_genin_marionettisti_resolve_v1(jsonb_build_object('contract_version','marionetta-round-hook/1','declaration_id',v_d.id,'request_key',p_request_key));
            v_att.mechanics_snapshot:=v_att.mechanics_snapshot||jsonb_build_object('marionetta_profile',v_calc->'profile');
          exception when sqlstate '22023' or no_data_found then
            update public.combat_v2_declarations set state='superflua',outcome=jsonb_build_object('reason','marionetta_source_unavailable','refund',false) where id=v_d.id;
            continue;
          end;
        end if;

      if (select count(*) from public.combat_v2_attack_targets where attack_declaration_id=v_d.id)=1
          and not exists(select 1 from public.combat_v2_defense_coverages c join public.combat_v2_attack_targets t on t.id=c.attack_target_id where t.attack_declaration_id=v_d.id and c.mode<>'self') then
      select * into v_tar from public.combat_v2_actors where id=v_d.target_actor_id for update;
      if v_tar.state<>'attivo' then
        update public.combat_v2_declarations set state='superflua',outcome=jsonb_build_object('reason','bersaglio_gia_fuori','refund',false) where id=v_d.id;
      else
        select * into v_def from public.combat_v2_declarations where parent_attack_id=v_d.id;
        v_reaction:=coalesce(v_def.sanitized_intent->>'reaction','nessuna'); v_meta:=v_d.sanitized_intent->'server_ability';
        SELECT id INTO STRICT multiplication_target FROM public.combat_v2_attack_targets WHERE attack_declaration_id=v_d.id;
        multiplication_facts:=combat_panel_private.multiplication_attack_facts(multiplication_target);
        multiplication_effect:=combat_panel_private.multiplication_effect(multiplication_facts,v_reaction);
        v_reaction:=multiplication_effect->>'effective_reaction';
        -- [MISSION-GUARD-006] Guard locale dopo la lettura concorrente.
        if v_reaction in ('copie','tecnica') then
          perform public.combat_v2_fail('profilo_runtime_non_disponibile','La difesa speciale non ha un resolver V2 attivo.',409,p_request_key,'{}');
        end if;
        v_kind:=lower(coalesce(v_meta->>'kind','fisico')); if v_kind not in ('fisico','ninjutsu','genjutsu') then v_kind:='fisico'; end if;
        v_base:=coalesce((v_d.cost_snapshot->>'damage_base')::int,0);
        v_rng_context:='combat-v2/r3/attack:'||v_s.id::text||':'||p_round::text||':'||v_d.id::text;
        v_entropy:=extensions.gen_random_bytes(32);
        v_a1:=public.combat_v2_derive_d10(v_entropy,v_rng_context,1); v_a2:=public.combat_v2_derive_d10(v_entropy,v_rng_context,2);
        v_d1:=public.combat_v2_derive_d10(v_entropy,v_rng_context,3); v_d2:=public.combat_v2_derive_d10(v_entropy,v_rng_context,4);
        v_dice_a:=v_a1+v_a2; v_dice_d:=v_d1+v_d2;
        v_calc:=public._combat_calcola(v_kind,v_att.mechanics_snapshot,clan_marionettisti_private.defense_snapshot(v_def.actor_id,v_tar.id,v_reaction),v_reaction,
          coalesce(v_def.sanitized_intent->'server_ability'->>'kind','taijutsu'),v_base,v_meta->>'element',v_dice_a,v_dice_d,0,0,false);
        v_rng:=combat_v2_private.rng_seal(v_s.id,p_round,v_d.id,'attack',v_rng_context,v_entropy,
          jsonb_build_object(
            'dice_attack',jsonb_build_array(v_a1,v_a2),
            'dice_defense',jsonb_build_array(v_d1,v_d2),
            'pools',jsonb_build_object('attack',v_calc->'pool_att','defense',v_calc->'pool_dif'),
            'modifiers',jsonb_build_object(
              'mira',v_calc->'mod_mira','guardia',v_calc->'mod_guardia','colto',v_calc->'mod_colto',
              'slancio',v_calc->'mod_slancio','element_attack',v_calc->'mod_elem_att','element_defense',v_calc->'mod_elem_dif'),
            'totals',jsonb_build_object('attack',v_calc->'atk_tot','defense',v_calc->'def_tot','margin',v_calc->'margine')
          ));
        select coalesce((select value from public.combat_v2_ratings where declaration_id=v_d.id and is_active order by created_at desc limit 1),0) into v_vote_a;
        select coalesce((select value from public.combat_v2_ratings where declaration_id=v_def.id and is_active order by created_at desc limit 1),0) into v_vote_d;
        v_corr:=greatest(-3,least(3,v_vote_a-CASE WHEN (multiplication_effect->>'defense_spent_on_copy')::boolean THEN 0 ELSE v_vote_d END)); v_raw:=(v_calc->>'margine')::int;
        if v_reaction='sostituzione' then v_corr:=0; end if;
        v_final:=v_raw+v_corr;
        if (multiplication_effect->>'copy_intercepted')::boolean or v_reaction='sostituzione' or v_kind='genjutsu' and v_final<0 or v_reaction='copie' and v_final<0 then v_damage:=0;
        elsif v_final<0 then v_damage:=greatest(1,greatest(1,v_base+((v_calc->>'off')::int/4)-(v_calc->>'riduzione')::int)/4);
        else
          v_full:=greatest(1,v_base+((v_calc->>'off')::int/4)+coalesce((v_calc->>'bonus_margine')::int,0)-(v_calc->>'riduzione')::int);
          v_damage:=least(65,v_full);
        end if;
        v_new_hp:=greatest(0,coalesce((v_tar.mechanics_snapshot->>'vita')::int,0)-v_damage);
        update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{vita}',to_jsonb(v_new_hp),false),state=case when v_new_hp=0 then 'fuori' else state end where id=v_tar.id;
        if v_values and v_tar.actor_kind='pg' and v_damage>0 then
          perform set_config('app.allow_vita_delta','1',true); update public.characters set vita=v_new_hp where id=v_tar.character_id; perform set_config('app.allow_vita_delta','0',true);
        end if;
        update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{slancio}',to_jsonb(case when v_final>=0 AND NOT (multiplication_effect->>'copy_intercepted')::boolean then 0 else least(9,coalesce((mechanics_snapshot->>'slancio')::int,0)+3) end),true) where id=v_att.id;
        update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('raw',v_calc,'rng_audit',v_rng,'rating_attack',v_vote_a,'rating_defense',v_vote_d,
          'quality_correction',v_corr,'quality_applicable',v_reaction<>'sostituzione','threshold_margin',v_final,'success',v_final>=0 and v_reaction<>'sostituzione' AND NOT (multiplication_effect->>'copy_intercepted')::boolean,
          'damage_applied',v_damage,'target_hp_after',v_new_hp,'ko',v_new_hp=0,'copies_outcome',case when v_reaction='copie' and v_final<0 then 'copia_colpita' when v_reaction='copie' then 'originale_individuato' end)||CASE WHEN jsonb_array_length(multiplication_facts)>0 THEN jsonb_build_object(
            'multiplication',multiplication_facts,'multiplication_effect',multiplication_effect) ELSE '{}'::jsonb END where id=v_d.id;
        PERFORM combat_panel_private.multiplication_attack_finish(multiplication_target);
        update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('linked_attack',v_d.id) where id=v_def.id;
      end if;
      else
        v_calc:=combat_v2_multitarget_internal.resolve_parent(v_s.id,p_round,v_d.id,v_values);
      end if;

    elsif v_d.kind='utilita' AND EXISTS(SELECT 1 FROM clan_sabaku_private.clone_plans WHERE declaration_id=v_d.id) THEN
      v_calc:=clan_sabaku_private.clone_resolve_creation(v_d.id);
      update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;
    elsif v_d.kind='utilita' AND EXISTS(SELECT 1 FROM combat_panel_private.immobilization_escape_plans WHERE declaration_id=v_d.id) THEN
      v_calc:=combat_panel_private.immobilization_resolve_escape(v_d.id);
      update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;
    else update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('kind',v_d.kind) where id=v_d.id;
    end if;
  end loop;
  -- SINGLE_SURFACE_SYNC_R6
  update public.combat_v2_attack_targets t set
    state=case when d.state='superflua'then'superflua'else'risolta'end,
    outcome=d.outcome
  from public.combat_v2_declarations d
  where d.id=t.attack_declaration_id and t.round_id=p_round
    and d.state in('risolta','superflua')
    and (select count(*)from public.combat_v2_attack_targets x where x.attack_declaration_id=d.id)=1
    and not exists(select 1 from public.combat_v2_defense_coverages c join public.combat_v2_attack_targets x on x.id=c.attack_target_id where x.attack_declaration_id=d.id and c.mode<>'self');
  update public.combat_v2_defense_coverages c set state='risolta'
  from public.combat_v2_attack_targets t,public.combat_v2_declarations d,public.combat_v2_declarations a
  where c.attack_target_id=t.id and c.defense_declaration_id=d.id and t.attack_declaration_id=a.id
    and c.round_id=p_round and d.state='risolta'and a.state in('risolta','superflua')
    and (select count(*)from public.combat_v2_attack_targets x where x.attack_declaration_id=a.id)=1
    and not exists(select 1 from public.combat_v2_defense_coverages z join public.combat_v2_attack_targets x on x.id=z.attack_target_id where x.attack_declaration_id=a.id and z.mode<>'self');
  v_after:=(select jsonb_agg(jsonb_build_object('actor',a.id,'state',a.state,'position_m',a.position_m,'mechanics',a.mechanics_snapshot) order by a.id) from public.combat_v2_actors a where a.session_id=v_s.id);
  v_report:=jsonb_build_object('initial_actors',v_before,'final_actors',v_after,
    'declarations',(select jsonb_agg(jsonb_build_object('id',d.id,'actor',d.actor_id,'kind',d.kind,'target',d.target_actor_id,'parent',d.parent_attack_id,'order',d.order_no,'state',d.state,'cost',d.cost_snapshot,'outcome',d.outcome) order by d.order_no nulls last,d.id) from public.combat_v2_declarations d where d.round_id=p_round),
    'attack_targets',(select jsonb_agg(to_jsonb(t) order by t.attack_declaration_id,t.ordinal)from public.combat_v2_attack_targets t where t.round_id=p_round),'defense_coverages',(select jsonb_agg(to_jsonb(c)order by c.defense_declaration_id,c.id)from public.combat_v2_defense_coverages c where c.round_id=p_round),'ledger',(select jsonb_agg(clan_marionettisti_private.ledger_wire(l) order by l.created_at,l.id) from public.combat_v2_resource_ledger l where l.round_id=p_round),
    'rng_order',v_order_rng,'rng_scheme','hmac-sha256-jsonb-pg17/1',
    'substitution_receipts',coalesce((select jsonb_agg(jsonb_build_object('event_id',e.event_id,'event_kind',e.event_kind,'source_application_id',e.root_id,'round_id',l.activity_round_id,'instance_id',e.instance_id,'actor_id',e.actor_id,'narrator_payload',e.narrator_payload) order by e.created_at,e.event_id) from combat_spatial.spatial_events e join combat_spatial.substitution_activity_links l on l.activity_kind='combat_v2' and l.activity_round_id=p_round and l.attack_declaration_id=e.root_id and l.instance_id=e.instance_id and l.defender_actor_id=e.actor_id and l.state='committed' where e.event_kind='substitution_committed'),'[]'::jsonb),'values_written',v_values,'engine_version',v_r.engine_version,'resolver_version',v_r.resolver_version,'order_version',v_r.order_version,'quality_version',v_r.quality_version);
  v_sha:=public.combat_v2_sha256(v_report);
  insert into public.combat_v2_round_reports(round_id,mechanics,mechanics_sha256,values_written,engine_version,resolver_version,order_version,quality_version)
  values(p_round,v_report,v_sha,v_values,v_r.engine_version,v_r.resolver_version,v_r.order_version,v_r.quality_version) returning id into v_report_id;
  update public.combat_v2_rounds set phase='risolto',state='risolto',resolved_at=clock_timestamp(),report_id=v_report_id where id=p_round;
  if clan_marionettisti_private.is_dedicated_scene(v_s.id) then perform clan_marionettisti_private.settle_round_damage(v_report_id);end if;
  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('report_id',v_report_id,'report_sha256',v_sha,'mechanics',v_report));
  return public.combat_v2_event_complete(v_event_id,v_result);
end $function$;

ALTER FUNCTION public.combat_v2_round_resolve(uuid,uuid) OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION public.combat_v2_round_resolve(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION public.combat_v2_round_resolve(uuid,uuid) TO "postgres";

GRANT EXECUTE ON FUNCTION public.combat_v2_round_resolve(uuid,uuid) TO "service_role";

GRANT EXECUTE ON FUNCTION public.combat_v2_round_resolve(uuid,uuid) TO "authenticated";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_v2_multitarget_internal.sync_declaration()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare multiplication_aim_valid boolean; ids uuid[]:='{}';j jsonb;t uuid;n int:=0;a public.combat_v2_actors%rowtype;
        target public.combat_v2_actors%rowtype;meta jsonb;mode text;at_id uuid;attack_id uuid;attack public.combat_v2_declarations%rowtype;
begin
 if new.kind='attacco' then
  select*into strict a from public.combat_v2_actors where id=new.actor_id;
  meta:=new.sanitized_intent->'server_ability';
  if new.sanitized_intent?'target_actor_ids' then
   if jsonb_typeof(new.sanitized_intent->'target_actor_ids')<>'array' then raise exception 'targeting_cardinality_invalid';end if;
   for j in select value from jsonb_array_elements(new.sanitized_intent->'target_actor_ids') loop
    begin t:=(j#>>'{}')::uuid;exception when others then raise exception 'targeting_target_not_eligible';end;
    ids:=array_append(ids,t);
   end loop;
  else ids:=array[new.target_actor_id];end if;
  if cardinality(ids)not between 1 and 3 then raise exception 'targeting_cardinality_invalid';end if;
  if cardinality(ids)<>(select count(distinct z)from unnest(ids)z)then raise exception 'targeting_duplicate_target';end if;
  if new.target_actor_id is distinct from ids[1]then raise exception 'targeting_primary_not_ordinal_1';end if;
  if not combat_v2_multitarget_internal.attack_profile_ok(meta,cardinality(ids))then raise exception 'targeting_profile_missing';end if;
  foreach t in array ids loop
   select*into target from public.combat_v2_actors where id=t and session_id=a.session_id and state='attivo' for key share;
   if target.id is null or target.team_key=a.team_key then raise exception 'targeting_target_not_eligible';end if;
   multiplication_aim_valid:=combat_panel_private.multiplication_attack_aim_valid(new.round_id,a.id,t,new.request_key,
     case when new.sanitized_intent->>'ability_source'='clan' and new.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then 3 when coalesce(new.sanitized_intent->>'ability_source','mano')='mano' then 2 else public._fascia_metri(meta->>'range') end);
   if multiplication_aim_valid is not null then
    if new.sanitized_intent->>'ability_source'='clan'
      and new.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
      if cardinality(ids)<>1 then raise exception 'marionetta_single_target_required' using errcode='22023';end if;
       perform combat_panel_private.multiplication_companion_attack_source(new.round_id,a.id,t,new.request_key,null);end if;
    if not multiplication_aim_valid then raise exception 'fuori_portata';end if;
   elsif combat_panel_private.has_master_geometry(a.session_id)
    and new.sanitized_intent->>'ability_source'='clan'
    and new.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
    if cardinality(ids)<>1 or not clan_marionettisti_private.target_geometry_valid(new.round_id,a.id,t,new.sanitized_intent) then
      raise exception 'fuori_portata';end if;
   elsif combat_panel_private.has_master_geometry(a.session_id) then
    if not combat_panel_private.target_geometry_valid(a.id,t,case when coalesce(new.sanitized_intent->>'ability_source','mano')='mano' then 2 else public._fascia_metri(meta->>'range') end) then raise exception 'fuori_portata';end if;
   elsif clan_marionettisti_private.is_dedicated_scene(a.session_id) then
    if not clan_marionettisti_private.target_geometry_valid(new.round_id,a.id,t,new.sanitized_intent) then raise exception 'fuori_portata';end if;
   elsif abs(a.position_m-target.position_m)>coalesce(public._fascia_metri(meta->>'range'),-1)then raise exception 'fuori_portata';end if;
   n:=n+1;
   insert into public.combat_v2_attack_targets(round_id,attack_declaration_id,ordinal,target_actor_id,target_controller_version,target_position_m)
   values(new.round_id,new.id,n,t,target.controller_version,target.position_m);
  end loop;
 elsif new.kind in('difesa','nessuna')then
  select*into strict a from public.combat_v2_actors where id=new.actor_id;
  select*into strict attack from public.combat_v2_declarations where id=new.parent_attack_id and round_id=new.round_id and kind='attacco';
  meta:=new.sanitized_intent->'server_ability';
  if new.sanitized_intent?'attack_target_ids'then
   if jsonb_typeof(new.sanitized_intent->'attack_target_ids')<>'array'then raise exception 'targeting_cardinality_invalid';end if;
   for j in select value from jsonb_array_elements(new.sanitized_intent->'attack_target_ids')loop
    begin at_id:=(j#>>'{}')::uuid;exception when others then raise exception 'defense_targeting_not_eligible';end;
    ids:=array_append(ids,at_id);
   end loop;
  else
   select array_agg(x.id order by x.ordinal)into ids from public.combat_v2_attack_targets x
    where x.attack_declaration_id=new.parent_attack_id and x.target_actor_id=new.target_actor_id;
  end if;
  if ids is null or cardinality(ids)=0 or cardinality(ids)<>(select count(distinct z)from unnest(ids)z)then raise exception 'defense_targeting_not_eligible';end if;
  mode:=case
    when new.kind='nessuna'
      or coalesce(new.sanitized_intent->>'reaction','nessuna')in('schivata','parata','nessuna')
      then 'self'
    when coalesce(new.sanitized_intent->>'reaction','')='tecnica'
      and nullif(meta#>>'{targeting,mode}','') is null
      then 'self'
    else meta#>>'{targeting,mode}'
  end;
  if mode is null or mode not in('self','intercept','multi_protect')then raise exception 'defense_targeting_not_eligible';end if;
  if mode='self'and cardinality(ids)<>1 then raise exception 'defense_targeting_not_eligible';end if;
  if mode<>'self'and not combat_v2_multitarget_internal.defense_profile_ok(meta,mode,cardinality(ids))then raise exception 'defense_targeting_not_eligible';end if;
  foreach at_id in array ids loop
   select x.target_actor_id,d.id into t,attack_id from public.combat_v2_attack_targets x join public.combat_v2_declarations d on d.id=x.attack_declaration_id
    where x.id=at_id and x.round_id=new.round_id and x.state='attesa_difesa' for update of x;
   if t is null then raise exception 'targeting_child_already_covered';end if;
   if mode in('self','intercept')and attack_id is distinct from new.parent_attack_id then raise exception 'defense_targeting_cross_parent';end if;
   select*into target from public.combat_v2_actors where id=t for key share;
   if mode='self'and t<>new.actor_id and not clan_marionettisti_private.defends_body(new.actor_id,t,coalesce(new.sanitized_intent->>'reaction','nessuna')) then raise exception 'defense_targeting_not_eligible';end if;
   if mode<>'self'and(target.team_key<>a.team_key or
     case when combat_panel_private.has_master_geometry(a.session_id)
       then combat_panel_private.actor_distance(a.id,target.id)>2
       else abs(a.position_m-target.position_m)>2 end)then raise exception 'defense_targeting_not_eligible';end if;
   insert into public.combat_v2_defense_coverages(round_id,defense_declaration_id,attack_target_id,protected_actor_id,mode,defender_controller_version,protected_position_m)
   values(new.round_id,new.id,at_id,t,mode,a.controller_version,target.position_m);
   perform combat_panel_private.capture_coverage_geometry(new.id,at_id);
   update public.combat_v2_attack_targets set state='coperta'where id=at_id;
  end loop;
 end if;
 return new;
end
$function$;

ALTER FUNCTION combat_v2_multitarget_internal.sync_declaration() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_v2_multitarget_internal.sync_declaration() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_v2_multitarget_internal.sync_declaration() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.round_window_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
 if new.phase='raccolta_azioni' then
  if tg_op='INSERT' then perform clan_marionettisti_private.start_command_window(new.id);
  elsif old.phase is distinct from new.phase then perform clan_marionettisti_private.start_command_window(new.id);end if;
 end if;
 return new;
end;
$function$;

ALTER FUNCTION clan_marionettisti_private.round_window_trigger() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION clan_marionettisti_private.round_window_trigger() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION clan_marionettisti_private.round_window_trigger() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.declaration_terminal_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare start_event clan_marionettisti_private.control_events%rowtype;
 r public.combat_v2_rounds%rowtype;target public.combat_v2_actors%rowtype;
 link clan_marionettisti_private.links%rowtype;cut_no bigint;
begin
 if new.state not in('risolta','superflua') or old.state in('risolta','superflua') then return new;end if;
 select * into strict r from public.combat_v2_rounds where id=new.round_id;
 if r.phase<>'risoluzione' or not clan_marionettisti_private.is_dedicated_scene(r.session_id) then return new;end if;
 if new.kind in('attacco','movimento','utilita','passa') and exists(select 1 from public.combat_v2_actors where id=new.actor_id and state='attivo') then
  select * into start_event from clan_marionettisti_private.control_events
   where round_id=r.id and owner_actor_id=new.actor_id and kind='turn_started';
  if found then
   insert into clan_marionettisti_private.control_events(session_id,round_id,owner_actor_id,kind,source_declaration_id,request_key,fingerprint,payload)
    values(r.session_id,r.id,new.actor_id,'turn_completed',new.id,r.id,public.combat_v2_sha256(new.outcome),
     jsonb_build_object('authority','common-terminal/1','started_event_no',start_event.event_no,'terminal_state',new.state,'kind',new.kind))
    on conflict(owner_actor_id,kind,request_key) do nothing;
  end if;
 end if;
 -- Recisione solo da proprieta meccaniche gia presenti nello snapshot server
 -- della fonte e da successo Common,mai dal testo o da una lama ordinaria.
 if new.kind='attacco' and new.state='risolta' and new.outcome->>'success'='true'
  and new.sanitized_intent#>>'{server_ability,link_control_traits,perceives_chakra_links}'='true'
  and new.sanitized_intent#>>'{server_ability,link_control_traits,severs_chakra_links}'='true' then
  select * into target from public.combat_v2_actors where id=new.target_actor_id and session_id=r.session_id;
  if target.companion_id is not null then
   select * into link from clan_marionettisti_private.links where companion_actor_id=target.id for update;
   if found and link.state='connected' then
    insert into clan_marionettisti_private.control_events(session_id,round_id,owner_actor_id,kind,source_declaration_id,request_key,fingerprint,payload)
     values(r.session_id,r.id,link.owner_actor_id,'link_severed',new.id,new.id,public.combat_v2_sha256(new.outcome),
      jsonb_build_object('authority','common-source-traits/1','companion_actor_id',target.id,'prior_link_version',link.link_version))
     returning event_no into cut_no;
    update clan_marionettisti_private.links set state='severed',link_version=link_version+1,cut_event_no=cut_no where owner_actor_id=link.owner_actor_id;
   end if;
  end if;
 end if;
 return new;
end;
$function$;

ALTER FUNCTION clan_marionettisti_private.declaration_terminal_trigger() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION clan_marionettisti_private.declaration_terminal_trigger() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION clan_marionettisti_private.declaration_terminal_trigger() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_panel_private.master_entry_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE s public.combat_v2_sessions%ROWTYPE; m public.master_v2_sessions%ROWTYPE;
 enrolled combat_panel_private.master_panel_sessions%ROWTYPE; uid uuid; sid uuid;
BEGIN
 IF TG_TABLE_SCHEMA='public' AND TG_TABLE_NAME='master_v2_sessions' THEN
   PERFORM combat_panel_private.enroll_master(NEW.id);
 ELSIF TG_TABLE_SCHEMA='public' AND TG_TABLE_NAME='combat_v2_sessions' THEN
   IF NEW.source_kind='master' AND NEW.master_session_id IS NOT NULL THEN
     PERFORM combat_panel_private.enroll_master(NEW.master_session_id);
     SELECT * INTO enrolled FROM combat_panel_private.master_panel_sessions WHERE master_session_id=NEW.master_session_id;
     IF enrolled.master_session_id IS NOT NULL AND (enrolled.location_id<>NEW.location_id
       OR (enrolled.policy_id='staff_test_no_persistent_resources_v1' AND NEW.lesiva)) THEN
       RAISE EXCEPTION 'panel_master_encounter_scope_invalid' USING ERRCODE='42501'; END IF;
   END IF;
 ELSIF TG_TABLE_SCHEMA='public' AND TG_TABLE_NAME='combat_v2_actors' THEN
   SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=NEW.session_id;
   SELECT * INTO enrolled FROM combat_panel_private.master_panel_sessions WHERE master_session_id=s.master_session_id;
   IF enrolled.policy_id='staff_test_no_persistent_resources_v1' THEN
     SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=s.master_session_id;
     IF NOT combat_consumer_private.staff_test_allowed(enrolled.location_id,ARRAY[NEW.controller_user],false) THEN
       RAISE EXCEPTION 'panel_staff_actor_not_allowed' USING ERRCODE='42501'; END IF;
     IF NEW.actor_kind='pg' THEN
       SELECT user_id INTO STRICT uid FROM public.characters WHERE id=NEW.character_id;
       IF uid IS DISTINCT FROM NEW.controller_user THEN
         RAISE EXCEPTION 'panel_staff_actor_controller_invalid' USING ERRCODE='42501'; END IF;
     ELSIF NEW.companion_id IS NULL AND NEW.controller_user IS DISTINCT FROM m.master_user THEN
       RAISE EXCEPTION 'panel_staff_png_controller_invalid' USING ERRCODE='42501';
     END IF;
   END IF;
 ELSIF TG_TABLE_SCHEMA='public' AND TG_TABLE_NAME='mission_run_state' THEN
   IF EXISTS(SELECT 1 FROM combat_panel_private.master_panel_sessions WHERE master_session_id=NEW.master_session_id
     AND policy_id='staff_test_no_persistent_resources_v1') THEN
     RAISE EXCEPTION 'panel_staff_mission_binding_forbidden' USING ERRCODE='42501'; END IF;
 ELSIF TG_TABLE_SCHEMA='public' AND TG_TABLE_NAME='combat_v2_declarations' THEN
   SELECT session_id INTO STRICT sid FROM public.combat_v2_rounds WHERE id=NEW.round_id;
   PERFORM combat_panel_private.assert_master_ready(sid);
 ELSIF TG_TABLE_SCHEMA='combat_spatial' AND TG_TABLE_NAME='arena_instances' THEN
   IF NEW.context_source='panel_master' THEN
     PERFORM combat_panel_private.enroll_master(NEW.master_session_id);
     IF NOT EXISTS(SELECT 1 FROM combat_panel_private.master_panel_sessions WHERE master_session_id=NEW.master_session_id) THEN
       RAISE EXCEPTION 'panel_master_entry_not_enabled' USING ERRCODE='42501'; END IF;
   END IF;
 ELSE RAISE EXCEPTION 'panel_entry_trigger_scope_invalid' USING ERRCODE='22023';
 END IF;
 RETURN NEW;
END $function$;

ALTER FUNCTION combat_panel_private.master_entry_trigger() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_panel_private.master_entry_trigger() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_panel_private.master_entry_trigger() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_panel_private.actor_turn_lifecycle()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE aid uuid; rid uuid; tid uuid;
BEGIN
 IF TG_TABLE_NAME='combat_v2_rounds' THEN
   IF NEW.phase='raccolta_azioni' THEN
     FOR aid IN SELECT id FROM public.combat_v2_actors WHERE session_id=NEW.session_id
       AND state='attivo' AND companion_id IS NULL ORDER BY id LOOP
       PERFORM combat_panel_private.ensure_actor_turn(NEW.id,aid);
     END LOOP;
   ELSIF NEW.phase='risolto' THEN
     UPDATE combat_panel_private.actor_turns SET state='ended',end_reason='round_end',ended_at=clock_timestamp()
       WHERE round_id=NEW.id AND state<>'ended';
   END IF;
 ELSIF TG_TABLE_NAME='combat_v2_actors' THEN
   IF NEW.state<>'attivo' THEN
     UPDATE combat_panel_private.actor_turns SET state='ended',end_reason='actor_inoperative',ended_at=clock_timestamp()
       WHERE actor_id=NEW.id AND state<>'ended';
   ELSIF TG_OP='INSERT' THEN
     FOR rid IN SELECT id FROM public.combat_v2_rounds WHERE session_id=NEW.session_id
       AND phase='raccolta_azioni' ORDER BY round_no LOOP
       PERFORM combat_panel_private.ensure_actor_turn(rid,NEW.id);
     END LOOP;
   END IF;
 ELSIF TG_TABLE_NAME='combat_v2_declarations' THEN
   IF NEW.kind NOT IN ('attacco','movimento','utilita','passa') THEN RETURN NEW; END IF;
   tid:=combat_panel_private.ensure_actor_turn(NEW.round_id,NEW.actor_id);
   IF tid IS NULL THEN RETURN NEW; END IF;
   IF EXISTS(SELECT 1 FROM combat_panel_private.actor_turns WHERE id=tid
     AND main_declaration_id IS NOT NULL AND main_declaration_id<>NEW.id) THEN
     RAISE EXCEPTION 'panel_actor_turn_main_conflict' USING ERRCODE='40001'; END IF;
   IF NEW.state IN ('risolta','superflua') THEN
     UPDATE combat_panel_private.actor_turns SET main_declaration_id=NEW.id,state='ended',
       end_reason='action_settled',ended_at=clock_timestamp() WHERE id=tid AND state<>'ended';
   ELSE
     UPDATE combat_panel_private.actor_turns SET main_declaration_id=NEW.id,state='declared'
       WHERE id=tid AND state='ready';
   END IF;
 ELSIF TG_TABLE_NAME='master_v2_sessions' AND NEW.stato IN ('chiusa','annullata') THEN
   UPDATE combat_panel_private.actor_turns t SET state='ended',end_reason='combat_end',ended_at=clock_timestamp()
     FROM public.combat_v2_rounds r JOIN public.combat_v2_sessions s ON s.id=r.session_id
     WHERE t.round_id=r.id AND s.master_session_id=NEW.id AND t.state<>'ended';
 END IF;
 RETURN NEW;
END $function$;

ALTER FUNCTION combat_panel_private.actor_turn_lifecycle() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_panel_private.actor_turn_lifecycle() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_panel_private.actor_turn_lifecycle() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION clan_sabaku_private.master_turn_lifecycle()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE use_id uuid; reason text; hp integer;
BEGIN
 IF TG_TABLE_NAME='combat_v2_declarations' THEN
   IF NEW.kind IN ('attacco','movimento','utilita','passa') AND EXISTS(
     SELECT 1 FROM public.combat_v2_rounds r JOIN public.combat_v2_sessions s ON s.id=r.session_id
     JOIN combat_panel_private.master_panel_sessions p ON p.master_session_id=s.master_session_id
     WHERE r.id=NEW.round_id) THEN
     -- Anche un comando dalla porta normale deve passare dallo stesso upkeep,
     -- prima che la dichiarazione consumi la finestra di inizio turno.
     PERFORM clan_innata_private.combat_begin_turn(NEW.actor_id);
   END IF;
   RETURN NEW;
 END IF;
 IF TG_OP='INSERT' AND NEW.state='ready' THEN
   PERFORM clan_innata_private.combat_begin_turn(NEW.actor_id);
 ELSIF TG_OP='UPDATE' AND NEW.state='ended' AND OLD.state<>'ended' THEN
   reason:=CASE NEW.end_reason WHEN 'combat_end' THEN 'combat_end'
     WHEN 'actor_inoperative' THEN 'owner_inoperative' ELSE 'turn_end' END;
   IF reason='owner_inoperative' THEN
     SELECT coalesce((mechanics_snapshot->>'vita')::integer,0) INTO hp FROM public.combat_v2_actors WHERE id=NEW.actor_id;
     IF hp<=0 THEN reason:='owner_ko'; END IF;
   END IF;
   FOR use_id IN SELECT id FROM clan_sabaku_private.transport_uses
     WHERE actor_id=NEW.actor_id AND round_id=NEW.round_id AND state='active' ORDER BY id LOOP
     PERFORM clan_sabaku_private.transport_release(use_id,reason);
   END LOOP;
   IF reason IN ('combat_end','owner_ko','owner_inoperative') THEN
     PERFORM clan_innata_private.combat_terminal(NEW.actor_id,reason);
   END IF;
 END IF;
 RETURN NEW;
END $function$;

ALTER FUNCTION clan_sabaku_private.master_turn_lifecycle() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION clan_sabaku_private.master_turn_lifecycle() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION clan_sabaku_private.master_turn_lifecycle() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_next_action()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE fid uuid;
BEGIN
 IF NEW.kind NOT IN ('attacco','movimento','utilita','passa') THEN RETURN NEW; END IF;
 FOR fid IN SELECT id FROM combat_panel_private.multiplication_formations
   WHERE actor_id=NEW.actor_id AND state='active' AND declaration_id<>NEW.id ORDER BY id LOOP
   PERFORM combat_panel_private.multiplication_finish(fid,'owner_next_action');
 END LOOP;
 RETURN NEW;
END $function$;

ALTER FUNCTION combat_panel_private.multiplication_next_action() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_panel_private.multiplication_next_action() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_panel_private.multiplication_next_action() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_panel_private.immobilization_attack_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
 IF NEW.state='risolta' THEN PERFORM combat_panel_private.immobilization_apply_from_attack(NEW.id); END IF;
 RETURN NEW;
END $function$;

ALTER FUNCTION combat_panel_private.immobilization_attack_trigger() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_panel_private.immobilization_attack_trigger() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_panel_private.immobilization_attack_trigger() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION clan_sabaku_private.clone_lifecycle_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE row_data jsonb; entry record; table_name text:=TG_TABLE_SCHEMA||'.'||TG_TABLE_NAME;
BEGIN
 row_data:=CASE WHEN TG_OP='DELETE' THEN to_jsonb(OLD) ELSE to_jsonb(NEW) END;
 IF table_name='public.presence' THEN
   FOR entry IN SELECT DISTINCT c.session_id FROM clan_sabaku_private.clones c JOIN public.combat_v2_actors a ON a.id=c.actor_id
     WHERE c.state<>'ended' AND a.controller_user IN ((to_jsonb(OLD)->>'user_id')::uuid,(row_data->>'user_id')::uuid) LOOP
     PERFORM clan_sabaku_private.clone_reconcile(entry.session_id);
   END LOOP;
 ELSIF table_name IN ('combat_spatial.actor_states','combat_spatial.arena_instances') THEN
   FOR entry IN SELECT DISTINCT session_id FROM clan_sabaku_private.clones
     WHERE state<>'ended' AND instance_id=(row_data->>'instance_id')::uuid LOOP
     PERFORM clan_sabaku_private.clone_reconcile(entry.session_id);
   END LOOP;
 ELSIF table_name IN ('combat_consumer_private.activities','public.combat_v2_actors','public.combat_v2_rounds','clan_innata_combat_private.combat_state','combat_panel_private.immobilizations') THEN
   PERFORM clan_sabaku_private.clone_reconcile((row_data->>'session_id')::uuid);
 ELSIF table_name='public.combat_v2_sessions' THEN
   PERFORM clan_sabaku_private.clone_reconcile((row_data->>'id')::uuid);
 ELSE RAISE EXCEPTION 'sabaku_clone_lifecycle_source_invalid' USING ERRCODE='22023'; END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF;
 RETURN NEW;
END $function$;

ALTER FUNCTION clan_sabaku_private.clone_lifecycle_trigger() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION clan_sabaku_private.clone_lifecycle_trigger() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION clan_sabaku_private.clone_lifecycle_trigger() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION clan_sabaku_private.clone_formation_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE clone_id uuid;
BEGIN
 IF NEW.state<>'active' THEN RETURN NEW; END IF;
 FOR clone_id IN SELECT id FROM clan_sabaku_private.clones WHERE instance_id=NEW.instance_id AND state='armed' ORDER BY created_at,id LOOP
   PERFORM clan_sabaku_private.clone_trigger_nearby(clone_id,NEW.round_id,'formation_created',NEW.actor_id,NULL,NEW.declaration_id);
 END LOOP;
 RETURN NEW;
END $function$;

ALTER FUNCTION clan_sabaku_private.clone_formation_trigger() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION clan_sabaku_private.clone_formation_trigger() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION clan_sabaku_private.clone_formation_trigger() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_consumer_private.recovery_preserve_parent_v1()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
 IF EXISTS(SELECT 1 FROM combat_consumer_private.recovery_claims_v1 WHERE parent_claim_id=OLD.id) THEN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'recovery_parent_immutable'; END IF;
  RETURN OLD;
 END IF;
 RETURN NEW;
END $function$;

ALTER FUNCTION combat_consumer_private.recovery_preserve_parent_v1() OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_consumer_private.recovery_preserve_parent_v1() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_consumer_private.recovery_preserve_parent_v1() TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_formation_valid(p_figures jsonb, p_copy_count integer, p_copy_cap integer, p_original_index integer)
 RETURNS boolean
 LANGUAGE plpgsql
 IMMUTABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE f jsonb; seen integer[]:='{}'; idx integer; x numeric; y numeric;
 points jsonb:='[]'; other jsonb;
BEGIN
 IF p_copy_count IS NULL OR p_copy_cap IS NULL OR p_copy_count<1
   OR p_copy_count>p_copy_cap OR p_original_index IS NULL
   OR p_original_index<1 OR p_original_index>p_copy_count+1
   OR jsonb_typeof(p_figures) IS DISTINCT FROM 'array' THEN RETURN false; END IF;
 IF jsonb_array_length(p_figures)<>p_copy_count+1 THEN RETURN false; END IF;
 FOR f IN SELECT value FROM jsonb_array_elements(p_figures) LOOP
   IF jsonb_typeof(f) IS DISTINCT FROM 'object' THEN RETURN false; END IF;
   -- DTO pubblico minimale: nessun indice originale, actor/source id o flag.
   IF NOT f ?& ARRAY['figure_index','x_m','y_m']
     OR EXISTS(SELECT 1 FROM jsonb_object_keys(f) k
       WHERE k NOT IN ('figure_index','x_m','y_m'))
     OR jsonb_typeof(f->'figure_index') IS DISTINCT FROM 'number'
     OR jsonb_typeof(f->'x_m') IS DISTINCT FROM 'number'
     OR jsonb_typeof(f->'y_m') IS DISTINCT FROM 'number' THEN RETURN false; END IF;
   IF (f->>'figure_index')::numeric<>trunc((f->>'figure_index')::numeric)
     OR (f->>'figure_index')::numeric NOT BETWEEN 1 AND p_copy_count+1 THEN RETURN false; END IF;
   idx:=(f->>'figure_index')::integer; x:=(f->>'x_m')::numeric; y:=(f->>'y_m')::numeric;
   IF idx=ANY(seen) OR x IN ('NaN'::numeric,'Infinity'::numeric,'-Infinity'::numeric)
     OR y IN ('NaN'::numeric,'Infinity'::numeric,'-Infinity'::numeric)
     OR x<>round(x,0) OR y<>round(y,0) THEN RETURN false; END IF;
   FOR other IN SELECT value FROM jsonb_array_elements(points) LOOP
     -- Le copie possono coincidere sulla griglia intera; resta il limite L1 di 5m.
     IF abs(x-(other->>'x_m')::numeric)+abs(y-(other->>'y_m')::numeric)>5 THEN RETURN false; END IF;
   END LOOP;
   seen:=array_append(seen,idx); points:=points||jsonb_build_array(f);
 END LOOP;
 RETURN true;
END $function$;

ALTER FUNCTION combat_panel_private.multiplication_formation_valid(jsonb,integer,integer,integer) OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION combat_panel_private.multiplication_formation_valid(jsonb,integer,integer,integer) FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION combat_panel_private.multiplication_formation_valid(jsonb,integer,integer,integer) TO "postgres";

RESET ROLE;

CREATE OR REPLACE FUNCTION auth.uid()
 RETURNS uuid
 LANGUAGE sql
 STABLE
AS $function$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$function$;

ALTER FUNCTION auth.uid() OWNER TO "supabase_auth_admin";

SET LOCAL ROLE "supabase_auth_admin";

REVOKE ALL ON FUNCTION auth.uid() FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION auth.uid() TO PUBLIC;

GRANT EXECUTE ON FUNCTION auth.uid() TO "supabase_auth_admin";

GRANT EXECUTE ON FUNCTION auth.uid() TO "dashboard_user";

RESET ROLE;

CREATE OR REPLACE FUNCTION mission_internal.nb029h_json_hash(p_value jsonb)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO ''
AS $function$
 select pg_catalog.encode(extensions.digest(pg_catalog.convert_to(p_value::text,'utf8'),'sha256'),'hex')
$function$;

ALTER FUNCTION mission_internal.nb029h_json_hash(jsonb) OWNER TO "postgres";

SET LOCAL ROLE "postgres";

REVOKE ALL ON FUNCTION mission_internal.nb029h_json_hash(jsonb) FROM PUBLIC,anon,authenticated,service_role;

GRANT EXECUTE ON FUNCTION mission_internal.nb029h_json_hash(jsonb) TO "postgres";

RESET ROLE;

SET LOCAL check_function_bodies=on;

ALTER TABLE "auth"."users" ALTER COLUMN "phone" SET DEFAULT NULL::character varying;

ALTER TABLE "auth"."users" ALTER COLUMN "phone_change" SET DEFAULT ''::character varying;

ALTER TABLE "auth"."users" ALTER COLUMN "phone_change_token" SET DEFAULT ''::character varying;

ALTER TABLE "auth"."users" ALTER COLUMN "email_change_token_current" SET DEFAULT ''::character varying;

ALTER TABLE "auth"."users" ALTER COLUMN "email_change_confirm_status" SET DEFAULT 0;

ALTER TABLE "auth"."users" ALTER COLUMN "reauthentication_token" SET DEFAULT ''::character varying;

ALTER TABLE "auth"."users" ALTER COLUMN "is_sso_user" SET DEFAULT false;

ALTER TABLE "auth"."users" ALTER COLUMN "is_anonymous" SET DEFAULT false;

ALTER TABLE "clan_marionettisti_private"."master_scene_claims" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "clan_marionettisti_private"."sources" ALTER COLUMN "is_active" SET DEFAULT true;

ALTER TABLE "clan_marionettisti_private"."sources" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "combat_consumer_private"."activities" ALTER COLUMN "context_version" SET DEFAULT 1;

ALTER TABLE "combat_consumer_private"."activities" ALTER COLUMN "round_no" SET DEFAULT 1;

ALTER TABLE "combat_consumer_private"."activities" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "combat_consumer_private"."activities" ALTER COLUMN "last_action_at" SET DEFAULT clock_timestamp();

ALTER TABLE "combat_consumer_private"."narrative_claims" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "combat_consumer_private"."narrative_claims" ALTER COLUMN "claimed_at" SET DEFAULT clock_timestamp();

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "combat_consumer_private"."scene_claims" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "combat_consumer_private"."scene_claims" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "combat_consumer_private"."scene_profiles" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "combat_consumer_private"."scene_profiles" ALTER COLUMN "enabled" SET DEFAULT false;

ALTER TABLE "combat_panel_private"."master_scene_claims" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "combat_panel_private"."master_scene_profiles" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "combat_panel_private"."master_scene_profiles" ALTER COLUMN "profile_version" SET DEFAULT 1;

ALTER TABLE "combat_panel_private"."master_scene_profiles" ALTER COLUMN "enabled" SET DEFAULT false;

ALTER TABLE "combat_panel_private"."multiplication_formations" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "combat_panel_private"."multiplication_formations" ALTER COLUMN "state" SET DEFAULT 'active'::text;

ALTER TABLE "combat_panel_private"."multiplication_formations" ALTER COLUMN "state_version" SET DEFAULT 1;

ALTER TABLE "combat_panel_private"."multiplication_formations" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "combat_panel_private"."multiplication_resolutions" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "combat_spatial"."arena_instances" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "combat_spatial"."arena_instances" ALTER COLUMN "context_source" SET DEFAULT 'mission'::text;

ALTER TABLE "combat_spatial"."mission_bindings" ALTER COLUMN "enabled" SET DEFAULT false;

ALTER TABLE "mission_ai_board_owner"."activations" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "mission_ai_board_owner"."activations" ALTER COLUMN "control_version" SET DEFAULT 1;

ALTER TABLE "mission_ai_board_owner"."activations" ALTER COLUMN "all_ready" SET DEFAULT false;

ALTER TABLE "mission_ai_board_owner"."activations" ALTER COLUMN "opened_at" SET DEFAULT clock_timestamp();

ALTER TABLE "mission_ai_service_owner"."capabilities" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "mission_ai_service_owner"."capabilities" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "mission_ai_service_owner"."roster_profiles" ALTER COLUMN "active" SET DEFAULT false;

ALTER TABLE "mission_ai_service_owner"."roster_profiles" ALTER COLUMN "control_version" SET DEFAULT 1;

ALTER TABLE "mission_ai_service_owner"."roster_profiles" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "mission_internal"."nb_mission_source_attestations" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ALTER COLUMN "lifecycle_state" SET DEFAULT 'staged'::text;

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ALTER COLUMN "enabled" SET DEFAULT false;

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ALTER COLUMN "control_version" SET DEFAULT 1;

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ALTER COLUMN "updated_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."character_companions" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."character_companions" ALTER COLUMN "grado" SET DEFAULT 'baby'::text;

ALTER TABLE "public"."character_companions" ALTER COLUMN "is_active" SET DEFAULT true;

ALTER TABLE "public"."character_companions" ALTER COLUMN "created_at" SET DEFAULT now();

ALTER TABLE "public"."characters" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."characters" ALTER COLUMN "rank" SET DEFAULT 'Deshi'::text;

ALTER TABLE "public"."characters" ALTER COLUMN "money" SET DEFAULT 0;

ALTER TABLE "public"."characters" ALTER COLUMN "exp" SET DEFAULT 0;

ALTER TABLE "public"."characters" ALTER COLUMN "chakra" SET DEFAULT 0;

ALTER TABLE "public"."characters" ALTER COLUMN "chakra_max" SET DEFAULT 0;

ALTER TABLE "public"."characters" ALTER COLUMN "vita" SET DEFAULT 0;

ALTER TABLE "public"."characters" ALTER COLUMN "vita_max" SET DEFAULT 0;

ALTER TABLE "public"."characters" ALTER COLUMN "taijutsu" SET DEFAULT 10;

ALTER TABLE "public"."characters" ALTER COLUMN "ninjutsu" SET DEFAULT 10;

ALTER TABLE "public"."characters" ALTER COLUMN "genjutsu" SET DEFAULT 10;

ALTER TABLE "public"."characters" ALTER COLUMN "forza" SET DEFAULT 10;

ALTER TABLE "public"."characters" ALTER COLUMN "velocita" SET DEFAULT 10;

ALTER TABLE "public"."characters" ALTER COLUMN "mente" SET DEFAULT 10;

ALTER TABLE "public"."characters" ALTER COLUMN "created_at" SET DEFAULT now();

ALTER TABLE "public"."characters" ALTER COLUMN "updated_at" SET DEFAULT now();

ALTER TABLE "public"."characters" ALTER COLUMN "unspent_points" SET DEFAULT 0;

ALTER TABLE "public"."characters" ALTER COLUMN "resistenza" SET DEFAULT 10;

ALTER TABLE "public"."characters" ALTER COLUMN "fuuinjutsu" SET DEFAULT 10;

ALTER TABLE "public"."characters" ALTER COLUMN "kekkei_genkai" SET DEFAULT 10;

ALTER TABLE "public"."characters" ALTER COLUMN "last_regen_at" SET DEFAULT now();

ALTER TABLE "public"."characters" ALTER COLUMN "xp_lifetime" SET DEFAULT 0;

ALTER TABLE "public"."characters" ALTER COLUMN "lealta" SET DEFAULT 50;

ALTER TABLE "public"."characters" ALTER COLUMN "via" SET DEFAULT 50;

ALTER TABLE "public"."characters" ALTER COLUMN "fama" SET DEFAULT 50;

ALTER TABLE "public"."characters" ALTER COLUMN "slot_extra" SET DEFAULT 0;

ALTER TABLE "public"."characters" ALTER COLUMN "corp_anon" SET DEFAULT false;

ALTER TABLE "public"."characters" ALTER COLUMN "pool_concesso" SET DEFAULT 60;

ALTER TABLE "public"."characters" ALTER COLUMN "is_test" SET DEFAULT false;

ALTER TABLE "public"."combat_v2_actors" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."combat_v2_actors" ALTER COLUMN "state" SET DEFAULT 'attivo'::text;

ALTER TABLE "public"."combat_v2_actors" ALTER COLUMN "position_m" SET DEFAULT 0;

ALTER TABLE "public"."combat_v2_actors" ALTER COLUMN "controller_version" SET DEFAULT 1;

ALTER TABLE "public"."combat_v2_actors" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."combat_v2_attack_targets" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."combat_v2_attack_targets" ALTER COLUMN "state" SET DEFAULT 'attesa_difesa'::text;

ALTER TABLE "public"."combat_v2_attack_targets" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."combat_v2_declarations" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."combat_v2_declarations" ALTER COLUMN "declaration_text" SET DEFAULT ''::text;

ALTER TABLE "public"."combat_v2_declarations" ALTER COLUMN "state" SET DEFAULT 'inviata'::text;

ALTER TABLE "public"."combat_v2_declarations" ALTER COLUMN "cost_snapshot" SET DEFAULT '{}'::jsonb;

ALTER TABLE "public"."combat_v2_declarations" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."combat_v2_events" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."combat_v2_events" ALTER COLUMN "status" SET DEFAULT 'in_corso'::text;

ALTER TABLE "public"."combat_v2_events" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."combat_v2_events" ALTER COLUMN "caller_kind" SET DEFAULT 'human'::text;

ALTER TABLE "public"."combat_v2_png_instances" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."combat_v2_png_instances" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."combat_v2_provider_instances_v1" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."combat_v2_provider_instances_v1" ALTER COLUMN "schema_version" SET DEFAULT 'combat-v2-provider-instance/1.0'::text;

ALTER TABLE "public"."combat_v2_provider_instances_v1" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."combat_v2_round_reports" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."combat_v2_round_reports" ALTER COLUMN "narration_state" SET DEFAULT 'attesa'::text;

ALTER TABLE "public"."combat_v2_round_reports" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."combat_v2_rounds" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."combat_v2_rounds" ALTER COLUMN "phase" SET DEFAULT 'raccolta_azioni'::text;

ALTER TABLE "public"."combat_v2_rounds" ALTER COLUMN "state" SET DEFAULT 'raccolta_azioni'::text;

ALTER TABLE "public"."combat_v2_rounds" ALTER COLUMN "engine_version" SET DEFAULT 'combat-v2/2.0.0'::text;

ALTER TABLE "public"."combat_v2_rounds" ALTER COLUMN "resolver_version" SET DEFAULT 'v11-parity/1'::text;

ALTER TABLE "public"."combat_v2_rounds" ALTER COLUMN "order_version" SET DEFAULT 'initiative-desc/1'::text;

ALTER TABLE "public"."combat_v2_rounds" ALTER COLUMN "quality_version" SET DEFAULT 'quality-delta/1.0.0'::text;

ALTER TABLE "public"."combat_v2_rounds" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."combat_v2_sessions" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."combat_v2_sessions" ALTER COLUMN "state" SET DEFAULT 'preparazione'::text;

ALTER TABLE "public"."combat_v2_sessions" ALTER COLUMN "engine_version" SET DEFAULT 'combat-v2/2.0.0'::text;

ALTER TABLE "public"."combat_v2_sessions" ALTER COLUMN "resolver_version" SET DEFAULT 'v11-parity/1'::text;

ALTER TABLE "public"."combat_v2_sessions" ALTER COLUMN "lesiva" SET DEFAULT false;

ALTER TABLE "public"."combat_v2_sessions" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."locations" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."locations" ALTER COLUMN "description" SET DEFAULT ''::text;

ALTER TABLE "public"."locations" ALTER COLUMN "kind" SET DEFAULT 'area'::text;

ALTER TABLE "public"."locations" ALTER COLUMN "sort" SET DEFAULT 0;

ALTER TABLE "public"."locations" ALTER COLUMN "is_active" SET DEFAULT true;

ALTER TABLE "public"."locations" ALTER COLUMN "created_at" SET DEFAULT now();

ALTER TABLE "public"."locations" ALTER COLUMN "is_academy" SET DEFAULT false;

ALTER TABLE "public"."locations" ALTER COLUMN "is_test" SET DEFAULT false;

ALTER TABLE "public"."locations" ALTER COLUMN "is_exam_room" SET DEFAULT false;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ALTER COLUMN "offer_ref" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ALTER COLUMN "schema_version" SET DEFAULT 'master-v2-nb-offer/1.0'::text;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ALTER COLUMN "lifecycle_state" SET DEFAULT 'offerta'::text;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ALTER COLUMN "control_version" SET DEFAULT 1;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ALTER COLUMN "updated_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ALTER COLUMN "recipient_kind" SET DEFAULT 'human'::text;

ALTER TABLE "public"."master_v2_sessions" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."master_v2_sessions" ALTER COLUMN "stato" SET DEFAULT 'preparazione'::text;

ALTER TABLE "public"."master_v2_sessions" ALTER COLUMN "control_version" SET DEFAULT 1;

ALTER TABLE "public"."master_v2_sessions" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."master_v2_sessions" ALTER COLUMN "owner_kind" SET DEFAULT 'human'::text;

ALTER TABLE "public"."messages" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."messages" ALTER COLUMN "author_name" SET DEFAULT ''::text;

ALTER TABLE "public"."messages" ALTER COLUMN "created_at" SET DEFAULT now();

ALTER TABLE "public"."messages" ALTER COLUMN "kind" SET DEFAULT 'say'::text;

ALTER TABLE "public"."mission_plan_versions" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."mission_plan_versions" ALTER COLUMN "stato" SET DEFAULT 'bozza'::text;

ALTER TABLE "public"."mission_plan_versions" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."mission_plans" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."mission_plans" ALTER COLUMN "stato" SET DEFAULT 'bozza'::text;

ALTER TABLE "public"."mission_plans" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."missions" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."missions" ALTER COLUMN "team_min" SET DEFAULT 1;

ALTER TABLE "public"."missions" ALTER COLUMN "team_max" SET DEFAULT 4;

ALTER TABLE "public"."missions" ALTER COLUMN "status" SET DEFAULT 'aperta'::text;

ALTER TABLE "public"."missions" ALTER COLUMN "created_by" SET DEFAULT auth.uid();

ALTER TABLE "public"."missions" ALTER COLUMN "created_at" SET DEFAULT now();

ALTER TABLE "public"."nb_mechanical_templates" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."nb_mechanical_templates" ALTER COLUMN "active" SET DEFAULT false;

ALTER TABLE "public"."nb_mechanical_templates" ALTER COLUMN "control_version" SET DEFAULT 1;

ALTER TABLE "public"."nb_mechanical_templates" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."nb_mechanical_templates" ALTER COLUMN "updated_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."nb_mechanical_versions" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."nb_mechanical_versions" ALTER COLUMN "schema_version" SET DEFAULT 'ninja-book-mechanics/1.0'::text;

ALTER TABLE "public"."nb_mechanical_versions" ALTER COLUMN "control_version" SET DEFAULT 1;

ALTER TABLE "public"."nb_mechanical_versions" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."nb_mission_packages" ALTER COLUMN "lifecycle_state" SET DEFAULT 'draft'::text;

ALTER TABLE "public"."nb_mission_packages" ALTER COLUMN "active" SET DEFAULT false;

ALTER TABLE "public"."nb_mission_packages" ALTER COLUMN "control_version" SET DEFAULT 1;

ALTER TABLE "public"."nb_mission_packages" ALTER COLUMN "created_by_kind" SET DEFAULT 'service_role'::text;

ALTER TABLE "public"."nb_mission_packages" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."nb_template_versions" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."nb_template_versions" ALTER COLUMN "schema_version" SET DEFAULT 'ninja-book/1.0'::text;

ALTER TABLE "public"."nb_template_versions" ALTER COLUMN "review_state" SET DEFAULT 'draft'::text;

ALTER TABLE "public"."nb_template_versions" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."nb_template_versions" ALTER COLUMN "control_version" SET DEFAULT 1;

ALTER TABLE "public"."nb_template_versions" ALTER COLUMN "updated_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."nb_templates" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."nb_templates" ALTER COLUMN "lifecycle_state" SET DEFAULT 'draft'::text;

ALTER TABLE "public"."nb_templates" ALTER COLUMN "control_version" SET DEFAULT 1;

ALTER TABLE "public"."nb_templates" ALTER COLUMN "created_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."nb_templates" ALTER COLUMN "updated_at" SET DEFAULT clock_timestamp();

ALTER TABLE "public"."png_templates" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();

ALTER TABLE "public"."png_templates" ALTER COLUMN "grado" SET DEFAULT 'D'::text;

ALTER TABLE "public"."png_templates" ALTER COLUMN "taijutsu" SET DEFAULT 10;

ALTER TABLE "public"."png_templates" ALTER COLUMN "ninjutsu" SET DEFAULT 10;

ALTER TABLE "public"."png_templates" ALTER COLUMN "genjutsu" SET DEFAULT 10;

ALTER TABLE "public"."png_templates" ALTER COLUMN "forza" SET DEFAULT 10;

ALTER TABLE "public"."png_templates" ALTER COLUMN "velocita" SET DEFAULT 10;

ALTER TABLE "public"."png_templates" ALTER COLUMN "mente" SET DEFAULT 10;

ALTER TABLE "public"."png_templates" ALTER COLUMN "resistenza" SET DEFAULT 10;

ALTER TABLE "public"."png_templates" ALTER COLUMN "fuuinjutsu" SET DEFAULT 10;

ALTER TABLE "public"."png_templates" ALTER COLUMN "kekkei_genkai" SET DEFAULT 0;

ALTER TABLE "public"."png_templates" ALTER COLUMN "abilita" SET DEFAULT '[]'::jsonb;

ALTER TABLE "public"."png_templates" ALTER COLUMN "is_active" SET DEFAULT true;

ALTER TABLE "public"."png_templates" ALTER COLUMN "created_by" SET DEFAULT auth.uid();

ALTER TABLE "public"."png_templates" ALTER COLUMN "created_at" SET DEFAULT now();

ALTER TABLE "public"."profiles" ALTER COLUMN "is_adult" SET DEFAULT false;

ALTER TABLE "public"."profiles" ALTER COLUMN "role" SET DEFAULT 'player'::text;

ALTER TABLE "public"."profiles" ALTER COLUMN "created_at" SET DEFAULT now();

ALTER TABLE "auth"."users" ADD CONSTRAINT "users_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."profiles" ADD CONSTRAINT "profiles_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."characters" ADD CONSTRAINT "characters_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."png_templates" ADD CONSTRAINT "png_templates_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."locations" ADD CONSTRAINT "locations_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."messages" ADD CONSTRAINT "messages_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_pkey" PRIMARY KEY (offer_ref);

ALTER TABLE "public"."missions" ADD CONSTRAINT "missions_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."character_companions" ADD CONSTRAINT "character_companions_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."combat_v2_provider_instances_v1" ADD CONSTRAINT "combat_v2_provider_instances_v1_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."combat_v2_sessions" ADD CONSTRAINT "combat_v2_sessions_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."combat_v2_png_instances" ADD CONSTRAINT "combat_v2_png_instances_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."combat_v2_rounds" ADD CONSTRAINT "combat_v2_rounds_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."combat_v2_declarations" ADD CONSTRAINT "combat_v2_declarations_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."combat_v2_round_reports" ADD CONSTRAINT "combat_v2_round_reports_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."combat_v2_events" ADD CONSTRAINT "combat_v2_events_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."nb_templates" ADD CONSTRAINT "nb_templates_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."mission_plans" ADD CONSTRAINT "mission_plans_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."mission_plan_versions" ADD CONSTRAINT "mission_plan_versions_pkey" PRIMARY KEY (id);

ALTER TABLE "mission_internal"."nb_mission_source_attestations" ADD CONSTRAINT "nb_mission_source_attestations_pkey" PRIMARY KEY (manifest_sha256);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."nb_mechanical_templates" ADD CONSTRAINT "nb_mechanical_templates_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_pkey" PRIMARY KEY (id);

ALTER TABLE "combat_consumer_private"."scene_profiles" ADD CONSTRAINT "scene_profiles_pkey" PRIMARY KEY (id);

ALTER TABLE "combat_consumer_private"."activities" ADD CONSTRAINT "activities_pkey" PRIMARY KEY (session_id);

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_pkey" PRIMARY KEY (id);

ALTER TABLE "combat_consumer_private"."scene_claims" ADD CONSTRAINT "scene_claims_pkey" PRIMARY KEY (id);

ALTER TABLE "mission_ai_service_owner"."roster_profiles" ADD CONSTRAINT "roster_profiles_pkey" PRIMARY KEY (id);

ALTER TABLE "combat_spatial"."arena_templates" ADD CONSTRAINT "arena_templates_pkey" PRIMARY KEY (template_key, template_version);

ALTER TABLE "combat_spatial"."arena_slots" ADD CONSTRAINT "arena_slots_pkey" PRIMARY KEY (template_key, template_version, slot_key);

ALTER TABLE "combat_spatial"."mission_bindings" ADD CONSTRAINT "mission_bindings_pkey" PRIMARY KEY (binding_id);

ALTER TABLE "combat_spatial"."arena_instances" ADD CONSTRAINT "arena_instances_pkey" PRIMARY KEY (instance_id);

ALTER TABLE "combat_consumer_private"."narrative_claims" ADD CONSTRAINT "narrative_claims_pkey" PRIMARY KEY (id);

ALTER TABLE "clan_marionettisti_private"."sources" ADD CONSTRAINT "sources_pkey" PRIMARY KEY (id);

ALTER TABLE "public"."combat_v2_attack_targets" ADD CONSTRAINT "combat_v2_attack_targets_pkey" PRIMARY KEY (id);

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ADD CONSTRAINT "ronda_runtime_bindings_v1_pkey" PRIMARY KEY (id);

ALTER TABLE "clan_marionettisti_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_pkey" PRIMARY KEY (claim_id);

ALTER TABLE "mission_ai_board_owner"."activations" ADD CONSTRAINT "activations_pkey" PRIMARY KEY (id);

ALTER TABLE "combat_panel_private"."master_scene_profiles" ADD CONSTRAINT "master_scene_profiles_pkey" PRIMARY KEY (id);

ALTER TABLE "combat_panel_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_pkey" PRIMARY KEY (id);

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_pkey" PRIMARY KEY (id);

ALTER TABLE "combat_panel_private"."multiplication_resolutions" ADD CONSTRAINT "multiplication_resolutions_pkey" PRIMARY KEY (formation_id, attack_target_id);

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_pkey" PRIMARY KEY (claim_id);

ALTER TABLE "auth"."users" ADD CONSTRAINT "users_phone_key" UNIQUE (phone);

ALTER TABLE "public"."characters" ADD CONSTRAINT "characters_user_unique" UNIQUE (user_id);

ALTER TABLE "public"."combat_v2_provider_instances_v1" ADD CONSTRAINT "combat_v2_provider_instances_v1_offer_ref_key" UNIQUE (offer_ref);

ALTER TABLE "public"."combat_v2_provider_instances_v1" ADD CONSTRAINT "combat_v2_provider_instances_v1_session_id_client_ref_key" UNIQUE (session_id, client_ref);

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_session_provider_v1_key" UNIQUE (session_id, provider_instance_v1_id);

ALTER TABLE "public"."combat_v2_png_instances" ADD CONSTRAINT "combat_v2_png_instances_session_id_client_ref_key" UNIQUE (session_id, client_ref);

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_session_id_id_key" UNIQUE (session_id, id);

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_session_id_character_id_key" UNIQUE (session_id, character_id);

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_session_id_png_instance_id_key" UNIQUE (session_id, png_instance_id);

ALTER TABLE "public"."combat_v2_rounds" ADD CONSTRAINT "combat_v2_rounds_session_id_round_no_key" UNIQUE (session_id, round_no);

ALTER TABLE "public"."combat_v2_declarations" ADD CONSTRAINT "combat_v2_declarations_round_id_request_key_key" UNIQUE (round_id, request_key);

ALTER TABLE "public"."combat_v2_round_reports" ADD CONSTRAINT "combat_v2_round_reports_round_id_key" UNIQUE (round_id);

ALTER TABLE "public"."combat_v2_round_reports" ADD CONSTRAINT "combat_v2_round_reports_message_id_key" UNIQUE (message_id);

ALTER TABLE "public"."combat_v2_events" ADD CONSTRAINT "combat_v2_events_scope_id_request_key_key" UNIQUE (scope_id, request_key);

ALTER TABLE "public"."nb_templates" ADD CONSTRAINT "nb_templates_request_key_key" UNIQUE (request_key);

ALTER TABLE "public"."nb_templates" ADD CONSTRAINT "nb_templates_template_key_key" UNIQUE (template_key);

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_template_id_version_no_key" UNIQUE (template_id, version_no);

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_id_template_id_key" UNIQUE (id, template_id);

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_template_id_content_sha256_key" UNIQUE (template_id, content_sha256);

ALTER TABLE "public"."mission_plans" ADD CONSTRAINT "mission_plans_id_mission_id_key" UNIQUE (id, mission_id);

ALTER TABLE "public"."mission_plan_versions" ADD CONSTRAINT "mission_plan_versions_plan_id_versione_key" UNIQUE (plan_id, versione);

ALTER TABLE "public"."mission_plan_versions" ADD CONSTRAINT "mission_plan_versions_id_plan_id_key" UNIQUE (id, plan_id);

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_id_mission_id_key" UNIQUE (id, mission_id);

ALTER TABLE "mission_internal"."nb_mission_source_attestations" ADD CONSTRAINT "nb_mission_source_attestations_source_task_id_key" UNIQUE (source_task_id);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_package_key_key" UNIQUE (package_key);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_seal_sha256_key" UNIQUE (seal_sha256);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_seal_request_key_key" UNIQUE (seal_request_key);

ALTER TABLE "public"."nb_mechanical_templates" ADD CONSTRAINT "nb_mechanical_templates_template_key_key" UNIQUE (template_key);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_template_id_version_no_key" UNIQUE (template_id, version_no);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_id_template_id_key" UNIQUE (id, template_id);

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_round_id_key" UNIQUE (round_id);

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_provider_response_id_key" UNIQUE (provider_response_id);

ALTER TABLE "combat_consumer_private"."scene_profiles" ADD CONSTRAINT "scene_profiles_id_location_id_key" UNIQUE (id, location_id);

ALTER TABLE "combat_consumer_private"."activities" ADD CONSTRAINT "activities_session_id_location_id_key" UNIQUE (session_id, location_id);

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_start_request_key_key" UNIQUE (start_request_key);

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_master_session_id_key" UNIQUE (master_session_id);

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_authority_receipt_sha256_key" UNIQUE (authority_receipt_sha256);

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_terminal_request_key_key" UNIQUE (terminal_request_key);

ALTER TABLE "combat_consumer_private"."scene_claims" ADD CONSTRAINT "scene_claims_session_id_key" UNIQUE (session_id);

ALTER TABLE "combat_consumer_private"."scene_claims" ADD CONSTRAINT "scene_claims_id_session_id_template_key_template_version_key" UNIQUE (id, session_id, template_key, template_version);

ALTER TABLE "mission_ai_service_owner"."roster_profiles" ADD CONSTRAINT "roster_profiles_profile_key_key" UNIQUE (profile_key);

ALTER TABLE "combat_spatial"."mission_bindings" ADD CONSTRAINT "mission_bindings_binding_key_key" UNIQUE (binding_key);

ALTER TABLE "combat_spatial"."arena_instances" ADD CONSTRAINT "arena_instances_master_session_id_key" UNIQUE (master_session_id);

ALTER TABLE "combat_spatial"."arena_instances" ADD CONSTRAINT "arena_instances_encounter_id_key" UNIQUE (encounter_id);

ALTER TABLE "combat_consumer_private"."narrative_claims" ADD CONSTRAINT "narrative_claims_round_id_key" UNIQUE (round_id);

ALTER TABLE "combat_consumer_private"."narrative_claims" ADD CONSTRAINT "narrative_claims_report_id_key" UNIQUE (report_id);

ALTER TABLE "combat_consumer_private"."narrative_claims" ADD CONSTRAINT "narrative_claims_request_key_key" UNIQUE (request_key);

ALTER TABLE "clan_marionettisti_private"."sources" ADD CONSTRAINT "sources_real_companion_id_key" UNIQUE (real_companion_id);

ALTER TABLE "clan_marionettisti_private"."sources" ADD CONSTRAINT "sources_session_id_owner_actor_id_key" UNIQUE (session_id, owner_actor_id);

ALTER TABLE "public"."combat_v2_attack_targets" ADD CONSTRAINT "combat_v2_attack_targets_attack_declaration_id_ordinal_key" UNIQUE (attack_declaration_id, ordinal);

ALTER TABLE "public"."combat_v2_attack_targets" ADD CONSTRAINT "combat_v2_attack_targets_attack_declaration_id_target_actor_key" UNIQUE (attack_declaration_id, target_actor_id);

ALTER TABLE "public"."combat_v2_attack_targets" ADD CONSTRAINT "combat_v2_attack_targets_id_attack_declaration_id_key" UNIQUE (id, attack_declaration_id);

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ADD CONSTRAINT "ronda_runtime_bindings_v1_binding_key_key" UNIQUE (binding_key);

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ADD CONSTRAINT "ronda_runtime_bindings_v1_mission_key" UNIQUE (mission_id);

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_session_companion_key" UNIQUE (session_id, companion_id);

ALTER TABLE "clan_marionettisti_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_claim_id_master_session_id_encounter_id_key" UNIQUE (claim_id, master_session_id, encounter_id, template_key, template_version);

ALTER TABLE "mission_ai_board_owner"."activations" ADD CONSTRAINT "activations_mission_id_key" UNIQUE (mission_id);

ALTER TABLE "combat_panel_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_id_master_session_id_encounter_id_templ_key" UNIQUE (id, master_session_id, encounter_id, template_key, template_version);

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_declaration_id_key" UNIQUE (declaration_id);

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_request_key_key" UNIQUE (request_key);

ALTER TABLE "auth"."users" ADD CONSTRAINT "users_email_change_confirm_status_check" CHECK (email_change_confirm_status >= 0 AND email_change_confirm_status <= 2);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_schema_version_check" CHECK (schema_version = 'master-v2-nb-offer/1.0'::text);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_expected_master_control_vers_check" CHECK (expected_master_control_version > 0);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_expected_narrative_template__check" CHECK (expected_narrative_template_control_version > 0);

ALTER TABLE "public"."profiles" ADD CONSTRAINT "profiles_role_check" CHECK (role = ANY (ARRAY['player'::text, 'master'::text, 'admin'::text]));

ALTER TABLE "public"."characters" ADD CONSTRAINT "characters_name_len" CHECK (char_length(name) >= 2 AND char_length(name) <= 40);

ALTER TABLE "public"."characters" ADD CONSTRAINT "characters_stats_range" CHECK (taijutsu >= 1 AND taijutsu <= 100 AND ninjutsu >= 1 AND ninjutsu <= 100 AND genjutsu >= 1 AND genjutsu <= 100 AND forza >= 1 AND forza <= 100 AND velocita >= 1 AND velocita <= 100 AND mente >= 1 AND mente <= 100);

ALTER TABLE "public"."profiles" ADD CONSTRAINT "profiles_username_check" CHECK (char_length(username) >= 2 AND char_length(username) <= 40 AND username = btrim(username) AND username !~ '[[:cntrl:]]'::text);

ALTER TABLE "public"."characters" ADD CONSTRAINT "characters_epithet_len" CHECK (epithet IS NULL OR char_length(epithet) <= 40);

ALTER TABLE "public"."characters" ADD CONSTRAINT "characters_offnotes_len" CHECK (off_notes IS NULL OR char_length(off_notes) <= 280);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_expected_narrative_version_c_check" CHECK (expected_narrative_version_control_version > 0);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_expected_binding_control_ver_check" CHECK (expected_binding_control_version > 0);

ALTER TABLE "public"."png_templates" ADD CONSTRAINT "png_templates_kekkei_genkai_check" CHECK ((kekkei_genkai % 5) = 0);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_expected_mechanical_template_check" CHECK (expected_mechanical_template_control_version > 0);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_expected_mechanical_version__check" CHECK (expected_mechanical_version_control_version > 0);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_expected_narrative_sha256_check" CHECK (expected_narrative_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_expected_mechanical_sha256_check" CHECK (expected_mechanical_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_lifecycle_state_check" CHECK (lifecycle_state = ANY (ARRAY['offerta'::text, 'consumata'::text, 'inattiva'::text, 'scaduta'::text]));

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_control_version_check" CHECK (control_version > 0);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_check" CHECK ((lifecycle_state = 'consumata'::text) = (consumed_event_id IS NOT NULL AND consumed_at IS NOT NULL));

ALTER TABLE "public"."characters" ADD CONSTRAINT "characters_clan_role_check" CHECK (clan_role IS NULL OR (clan_role = ANY (ARRAY['Capo clan'::text, 'Anziano'::text, 'Membro esperto'::text, 'Novizio'::text])));

ALTER TABLE "public"."combat_v2_provider_instances_v1" ADD CONSTRAINT "combat_v2_provider_instances_v1_schema_version_check" CHECK (schema_version = 'combat-v2-provider-instance/1.0'::text);

ALTER TABLE "public"."combat_v2_provider_instances_v1" ADD CONSTRAINT "combat_v2_provider_instances_v1_provider_check" CHECK (provider = 'ninja_book'::text);

ALTER TABLE "public"."combat_v2_declarations" ADD CONSTRAINT "combat_v2_declarations_declaration_text_check" CHECK (char_length(declaration_text) <= 5000);

ALTER TABLE "public"."combat_v2_provider_instances_v1" ADD CONSTRAINT "combat_v2_provider_instances_v1_source_sha256_check" CHECK (source_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "public"."missions" ADD CONSTRAINT "missions_village_check" CHECK (village = ANY (ARRAY['Konoha'::text, 'Suna'::text]));

ALTER TABLE "public"."missions" ADD CONSTRAINT "missions_grado_check" CHECK (grado = ANY (ARRAY['D'::text, 'C'::text, 'B'::text, 'A'::text, 'S'::text]));

ALTER TABLE "public"."missions" ADD CONSTRAINT "missions_team_min_check" CHECK (team_min >= 1 AND team_min <= 4);

ALTER TABLE "public"."missions" ADD CONSTRAINT "missions_team_max_check" CHECK (team_max >= 1 AND team_max <= 4);

ALTER TABLE "public"."missions" ADD CONSTRAINT "missions_status_check" CHECK (status = ANY (ARRAY['aperta'::text, 'programmata'::text, 'completata'::text, 'fallita'::text, 'annullata'::text]));

ALTER TABLE "public"."missions" ADD CONSTRAINT "missions_check" CHECK (team_min <= team_max);

ALTER TABLE "public"."png_templates" ADD CONSTRAINT "png_templates_grado_check" CHECK (grado = ANY (ARRAY['D'::text, 'C'::text, 'B'::text, 'A'::text, 'S'::text]));

ALTER TABLE "public"."png_templates" ADD CONSTRAINT "png_templates_taijutsu_check" CHECK ((taijutsu % 5) = 0);

ALTER TABLE "public"."png_templates" ADD CONSTRAINT "png_templates_ninjutsu_check" CHECK ((ninjutsu % 5) = 0);

ALTER TABLE "public"."png_templates" ADD CONSTRAINT "png_templates_genjutsu_check" CHECK ((genjutsu % 5) = 0);

ALTER TABLE "public"."png_templates" ADD CONSTRAINT "png_templates_forza_check" CHECK ((forza % 5) = 0);

ALTER TABLE "public"."png_templates" ADD CONSTRAINT "png_templates_velocita_check" CHECK ((velocita % 5) = 0);

ALTER TABLE "public"."png_templates" ADD CONSTRAINT "png_templates_mente_check" CHECK ((mente % 5) = 0);

ALTER TABLE "public"."png_templates" ADD CONSTRAINT "png_templates_resistenza_check" CHECK ((resistenza % 5) = 0);

ALTER TABLE "public"."png_templates" ADD CONSTRAINT "png_templates_fuuinjutsu_check" CHECK ((fuuinjutsu % 5) = 0);

ALTER TABLE "public"."character_companions" ADD CONSTRAINT "character_companions_kind_check" CHECK (kind = ANY (ARRAY['marionetta'::text, 'cane_ninja'::text, 'evocazione'::text]));

ALTER TABLE "public"."character_companions" ADD CONSTRAINT "character_companions_name_check" CHECK (length(TRIM(BOTH FROM name)) >= 2 AND length(TRIM(BOTH FROM name)) <= 40);

ALTER TABLE "public"."character_companions" ADD CONSTRAINT "character_companions_descr_check" CHECK (descr IS NULL OR length(descr) <= 300);

ALTER TABLE "public"."character_companions" ADD CONSTRAINT "character_companions_grado_check" CHECK (grado = ANY (ARRAY['baby'::text, 'piccola'::text, 'media'::text, 'grande'::text, 'leggendaria'::text]));

ALTER TABLE "public"."character_companions" ADD CONSTRAINT "character_companions_famiglia_check" CHECK (
CASE
    WHEN kind = 'evocazione'::text THEN famiglia IS NULL OR (famiglia = ANY (ARRAY['rospi'::text, 'serpenti'::text, 'rapaci'::text, 'rettili'::text, 'lumache'::text, 'scimmie'::text]))
    ELSE famiglia IS NULL
END);

ALTER TABLE "public"."characters" ADD CONSTRAINT "characters_cercoterio_check" CHECK (cercoterio IS NULL OR (cercoterio = ANY (ARRAY['Shukaku'::text, 'Matatabi'::text, 'Isobu'::text, 'Son Gokū'::text, 'Kokuō'::text, 'Saiken'::text, 'Chōmei'::text, 'Gyūki'::text, 'Kurama'::text])));

ALTER TABLE "public"."characters" ADD CONSTRAINT "characters_sigillo_check" CHECK (
CASE
    WHEN cercoterio IS NULL THEN sigillo IS NULL
    ELSE sigillo IS NULL OR (sigillo = ANY (ARRAY['Solido'::text, 'Ordinario'::text, 'Difettoso'::text]))
END);

ALTER TABLE "public"."characters" ADD CONSTRAINT "characters_clan_o_cercoterio" CHECK (COALESCE(NULLIF(btrim(clan), ''::text), 'Nessuno'::text) = 'Nessuno'::text OR cercoterio IS NULL);

ALTER TABLE "public"."characters" ADD CONSTRAINT "characters_element2_check" CHECK (element2 IS NULL OR (element2 = ANY (ARRAY['Fuoco'::text, 'Vento'::text, 'Fulmine'::text, 'Terra'::text, 'Acqua'::text])) AND element2 IS DISTINCT FROM element);

ALTER TABLE "public"."combat_v2_provider_instances_v1" ADD CONSTRAINT "combat_v2_provider_instances_v1_snapshot_sha256_check" CHECK (snapshot_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_authority_scope_chk" CHECK ((state <> ALL (ARRAY['offered'::text, 'active'::text])) OR ((roster_profile_id IS NOT NULL)::integer + (board_activation_id IS NOT NULL)::integer + (ronda_binding_id IS NOT NULL)::integer) = 1);

ALTER TABLE "public"."combat_v2_provider_instances_v1" ADD CONSTRAINT "combat_v2_provider_instances_v1_nome_check" CHECK (char_length(btrim(nome)) >= 2 AND char_length(btrim(nome)) <= 120);

ALTER TABLE "public"."combat_v2_provider_instances_v1" ADD CONSTRAINT "combat_v2_provider_instances_v1_snapshot_check" CHECK (jsonb_typeof(snapshot) = 'object'::text);

ALTER TABLE "public"."messages" ADD CONSTRAINT "messages_kind_chk" CHECK (kind = ANY (ARRAY['say'::text, 'roll'::text, 'whisper'::text, 'item'::text, 'combat'::text, 'sensei'::text, 'cura'::text, 'sistema'::text, 'motore'::text, 'png'::text, 'fato'::text]));

ALTER TABLE "public"."characters" ADD CONSTRAINT "characters_cognome_len" CHECK (cognome IS NULL OR char_length(cognome) >= 2 AND char_length(cognome) <= 15);

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_tipo_check" CHECK (tipo = ANY (ARRAY['duello'::text, 'quest'::text]));

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_stato_check" CHECK (stato = ANY (ARRAY['preparazione'::text, 'in_corso'::text, 'sospesa'::text, 'chiusura'::text, 'chiusa'::text, 'annullata'::text]));

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_control_version_check" CHECK (control_version >= 1);

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_titolo_check" CHECK (char_length(btrim(titolo)) >= 2 AND char_length(btrim(titolo)) <= 120);

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_terminale_chk" CHECK ((stato = ANY (ARRAY['chiusa'::text, 'annullata'::text])) = (closed_at IS NOT NULL));

ALTER TABLE "public"."combat_v2_sessions" ADD CONSTRAINT "combat_v2_sessions_source_chk" CHECK ((source_kind = 'master'::text) = (master_session_id IS NOT NULL));

ALTER TABLE "public"."combat_v2_sessions" ADD CONSTRAINT "combat_v2_sessions_source_kind_check" CHECK (source_kind = ANY (ARRAY['ordinary'::text, 'master'::text]));

ALTER TABLE "public"."combat_v2_sessions" ADD CONSTRAINT "combat_v2_sessions_state_check" CHECK (state = ANY (ARRAY['preparazione'::text, 'in_corso'::text, 'sospeso'::text, 'risolto'::text, 'chiuso'::text, 'annullato'::text]));

ALTER TABLE "public"."combat_v2_events" ADD CONSTRAINT "combat_v2_events_request_fingerprint_check" CHECK (request_fingerprint ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "public"."combat_v2_sessions" ADD CONSTRAINT "combat_v2_sessions_terminale_chk" CHECK ((state <> ALL (ARRAY['chiuso'::text, 'annullato'::text])) OR closed_at IS NOT NULL);

ALTER TABLE "public"."combat_v2_png_instances" ADD CONSTRAINT "combat_v2_png_instances_nome_check" CHECK (char_length(btrim(nome)) >= 2 AND char_length(btrim(nome)) <= 60);

ALTER TABLE "public"."combat_v2_png_instances" ADD CONSTRAINT "combat_v2_png_instances_snapshot_check" CHECK (jsonb_typeof(snapshot) = 'object'::text);

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_actor_kind_check" CHECK (actor_kind = ANY (ARRAY['pg'::text, 'png'::text]));

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_team_key_check" CHECK (char_length(btrim(team_key)) >= 1 AND char_length(btrim(team_key)) <= 40);

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_state_check" CHECK (state = ANY (ARRAY['attivo'::text, 'fuori'::text, 'ritirato'::text]));

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_position_m_check" CHECK (position_m >= 0 AND position_m <= 1000);

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_mechanics_snapshot_check" CHECK (jsonb_typeof(mechanics_snapshot) = 'object'::text);

ALTER TABLE "public"."combat_v2_round_reports" ADD CONSTRAINT "combat_v2_round_reports_narration_state_check" CHECK (narration_state = ANY (ARRAY['attesa'::text, 'pubblicata'::text, 'ritirata'::text]));

ALTER TABLE "public"."combat_v2_rounds" ADD CONSTRAINT "combat_v2_rounds_round_no_check" CHECK (round_no >= 1);

ALTER TABLE "public"."combat_v2_declarations" ADD CONSTRAINT "combat_v2_declarations_sanitized_intent_check" CHECK (jsonb_typeof(sanitized_intent) = 'object'::text);

ALTER TABLE "public"."nb_templates" ADD CONSTRAINT "nb_templates_template_key_check" CHECK (template_key ~ '^[a-z][a-z0-9_]{2,63}$'::text);

ALTER TABLE "public"."combat_v2_rounds" ADD CONSTRAINT "combat_v2_rounds_phase_check" CHECK (phase = ANY (ARRAY['raccolta_azioni'::text, 'raccolta_difese'::text, 'congelato'::text, 'valutazione'::text, 'risoluzione'::text, 'risolto'::text, 'narrazione'::text, 'narrato'::text]));

ALTER TABLE "public"."combat_v2_rounds" ADD CONSTRAINT "combat_v2_rounds_state_check" CHECK (state = ANY (ARRAY['raccolta_azioni'::text, 'raccolta_difese'::text, 'congelato'::text, 'valutazione'::text, 'risoluzione'::text, 'risolto'::text, 'narrazione'::text, 'narrato'::text]));

ALTER TABLE "public"."combat_v2_rounds" ADD CONSTRAINT "combat_v2_rounds_evaluation_mode_check" CHECK (evaluation_mode = ANY (ARRAY['umana'::text, 'neutra'::text]));

ALTER TABLE "public"."combat_v2_rounds" ADD CONSTRAINT "combat_v2_rounds_rng_order_commitment_check" CHECK (rng_order_commitment IS NULL OR rng_order_commitment ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "public"."combat_v2_declarations" ADD CONSTRAINT "combat_v2_declarations_kind_check" CHECK (kind = ANY (ARRAY['attacco'::text, 'difesa'::text, 'movimento'::text, 'utilita'::text, 'passa'::text, 'nessuna'::text]));

ALTER TABLE "public"."combat_v2_declarations" ADD CONSTRAINT "combat_v2_declarations_state_check" CHECK (state = ANY (ARRAY['bozza_server'::text, 'inviata'::text, 'congelata'::text, 'risolta'::text, 'superflua'::text]));

ALTER TABLE "public"."combat_v2_declarations" ADD CONSTRAINT "combat_v2_declarations_cost_snapshot_check" CHECK (jsonb_typeof(cost_snapshot) = 'object'::text);

ALTER TABLE "public"."combat_v2_declarations" ADD CONSTRAINT "combat_v2_declarations_parent_chk" CHECK ((kind = ANY (ARRAY['difesa'::text, 'nessuna'::text])) = (parent_attack_id IS NOT NULL));

ALTER TABLE "public"."combat_v2_declarations" ADD CONSTRAINT "combat_v2_declarations_target_chk" CHECK (kind <> 'attacco'::text OR target_actor_id IS NOT NULL);

ALTER TABLE "public"."combat_v2_round_reports" ADD CONSTRAINT "combat_v2_round_reports_mechanics_check" CHECK (jsonb_typeof(mechanics) = 'object'::text);

ALTER TABLE "public"."combat_v2_round_reports" ADD CONSTRAINT "combat_v2_round_reports_mechanics_sha256_check" CHECK (mechanics_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "public"."combat_v2_round_reports" ADD CONSTRAINT "combat_v2_round_reports_narrator_kind_check" CHECK (narrator_kind = ANY (ARRAY['umano'::text, 'ia'::text]));

ALTER TABLE "public"."combat_v2_events" ADD CONSTRAINT "combat_v2_events_status_check" CHECK (status = ANY (ARRAY['in_corso'::text, 'completata'::text, 'fallita'::text]));

ALTER TABLE "public"."nb_templates" ADD CONSTRAINT "nb_templates_display_name_check" CHECK (btrim(display_name) <> ''::text);

ALTER TABLE "public"."nb_templates" ADD CONSTRAINT "nb_templates_lifecycle_state_check" CHECK (lifecycle_state = ANY (ARRAY['draft'::text, 'review'::text, 'approved'::text, 'inactive'::text]));

ALTER TABLE "public"."nb_templates" ADD CONSTRAINT "nb_templates_control_version_check" CHECK (control_version > 0);

ALTER TABLE "public"."nb_templates" ADD CONSTRAINT "nb_templates_check" CHECK ((lifecycle_state = 'inactive'::text) = (deactivated_at IS NOT NULL));

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_version_no_check" CHECK (version_no > 0);

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_schema_version_check" CHECK (schema_version = 'ninja-book/1.0'::text);

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_skeleton_check" CHECK (jsonb_typeof(skeleton) = 'object'::text);

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_knowledge_boundary_check" CHECK (jsonb_typeof(knowledge_boundary) = 'object'::text);

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_fallback_profile_check" CHECK (jsonb_typeof(fallback_profile) = 'object'::text);

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_content_sha256_check" CHECK (content_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_review_state_check" CHECK (review_state = ANY (ARRAY['draft'::text, 'review'::text, 'approved'::text, 'rejected'::text, 'inactive'::text]));

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_check" CHECK ((review_state = ANY (ARRAY['approved'::text, 'inactive'::text])) AND approved_by IS NOT NULL AND approved_at IS NOT NULL OR (review_state = ANY (ARRAY['draft'::text, 'review'::text, 'rejected'::text])) AND approved_by IS NULL AND approved_at IS NULL);

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_check1" CHECK (supersedes_version_id IS NULL OR supersedes_version_id <> id);

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_check2" CHECK (approved_at IS NULL OR skeleton ?& ARRAY['identity'::text, 'voice'::text, 'gestures'::text, 'motivations'::text, 'goals'::text, 'fears'::text, 'fragility'::text, 'resilience'::text, 'character_errors'::text, 'recovery'::text, 'knowledge_limits'::text, 'relationships'::text, 'conduct'::text, 'continuity'::text, 'forbidden'::text, 'fallback'::text] AND jsonb_typeof(skeleton -> 'character_errors'::text) = 'array'::text AND jsonb_array_length(skeleton -> 'character_errors'::text) >= 2 AND jsonb_typeof(skeleton -> 'recovery'::text) = 'array'::text AND jsonb_array_length(skeleton -> 'recovery'::text) >= 1 AND jsonb_typeof(skeleton #> '{knowledge_limits,absent}'::text[]) = 'array'::text AND jsonb_array_length(skeleton #> '{knowledge_limits,absent}'::text[]) >= 1 AND jsonb_typeof(skeleton #> '{continuity,emotional_endings}'::text[]) = 'array'::text AND jsonb_array_length(skeleton #> '{continuity,emotional_endings}'::text[]) >= 2);

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_control_version_check" CHECK (control_version > 0);

ALTER TABLE "public"."mission_plans" ADD CONSTRAINT "mission_plans_stato_check" CHECK (stato = ANY (ARRAY['bozza'::text, 'attivo'::text, 'ritirato'::text]));

ALTER TABLE "public"."mission_plan_versions" ADD CONSTRAINT "mission_plan_versions_versione_check" CHECK (versione > 0);

ALTER TABLE "public"."mission_plan_versions" ADD CONSTRAINT "mission_plan_versions_stato_check" CHECK (stato = ANY (ARRAY['bozza'::text, 'approvata'::text, 'ritirata'::text]));

ALTER TABLE "public"."mission_plan_versions" ADD CONSTRAINT "mission_plan_versions_initial_step_key_check" CHECK (initial_step_key ~ '^[a-z][a-z0-9_]{0,63}$'::text);

ALTER TABLE "public"."mission_plan_versions" ADD CONSTRAINT "mission_plan_versions_approval_chk" CHECK ((stato = 'approvata'::text) = (plan_sha256 ~ '^[0-9a-f]{64}$'::text AND approved_at IS NOT NULL));

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_miyo_version_control_version_check" CHECK (miyo_version_control_version > 0);

ALTER TABLE "mission_internal"."nb_mission_source_attestations" ADD CONSTRAINT "nb_mission_source_attestations_manifest_sha256_check" CHECK (manifest_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "mission_internal"."nb_mission_source_attestations" ADD CONSTRAINT "nb_mission_source_attestations_source_task_id_check" CHECK (source_task_id = 'NINJA-BOOK-MISSION-NODO-AZZURRO-029G-OFFLINE'::text);

ALTER TABLE "mission_internal"."nb_mission_source_attestations" ADD CONSTRAINT "nb_mission_source_attestations_manifest_entries_check" CHECK (manifest_entries = 20);

ALTER TABLE "mission_internal"."nb_mission_source_attestations" ADD CONSTRAINT "nb_mission_source_attestations_manifest_path_check" CHECK (manifest_path = 'management/candidati/ninja_book_mission_nodo_azzurro_029g_offline/MANIFEST.sha256'::text);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_package_key_check" CHECK (package_key ~ '^[a-z][a-z0-9_]{2,63}$'::text);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_schema_version_check" CHECK (schema_version = 'mission-content-package/1.0'::text);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_lifecycle_state_check" CHECK (lifecycle_state = ANY (ARRAY['draft'::text, 'sealed'::text, 'review'::text, 'approved'::text, 'inactive'::text]));

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_xp_reward_check" CHECK (xp_reward = 0);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_ryo_reward_check" CHECK (ryo_reward = 0);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_persistent_effects_check" CHECK (NOT persistent_effects);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_payload_check" CHECK (jsonb_typeof(payload) = 'object'::text);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_expected_segment_manifest_check" CHECK (jsonb_typeof(expected_segment_manifest) = 'array'::text AND jsonb_array_length(expected_segment_manifest) = 11);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_miyo_template_control_version_check" CHECK (miyo_template_control_version > 0);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_miyo_content_sha256_check" CHECK (miyo_content_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_segment_set_sha256_check" CHECK (segment_set_sha256 IS NULL OR segment_set_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_seal_sha256_check" CHECK (seal_sha256 IS NULL OR seal_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_control_version_check" CHECK (control_version > 0);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_created_by_kind_check" CHECK (created_by_kind = 'service_role'::text);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_state_chk" CHECK (lifecycle_state = 'draft'::text AND seal_sha256 IS NULL AND segment_set_sha256 IS NULL AND seal_request_key IS NULL AND sealed_at IS NULL AND reviewed_at IS NULL AND approved_at IS NULL OR lifecycle_state = 'sealed'::text AND seal_sha256 IS NOT NULL AND segment_set_sha256 IS NOT NULL AND seal_request_key IS NOT NULL AND sealed_at IS NOT NULL AND reviewed_at IS NULL AND approved_at IS NULL OR lifecycle_state = 'review'::text AND seal_sha256 IS NOT NULL AND segment_set_sha256 IS NOT NULL AND sealed_at IS NOT NULL AND reviewed_at IS NOT NULL AND approved_at IS NULL OR lifecycle_state = 'approved'::text AND seal_sha256 IS NOT NULL AND segment_set_sha256 IS NOT NULL AND sealed_at IS NOT NULL AND reviewed_at IS NOT NULL AND approved_at IS NOT NULL OR lifecycle_state = 'inactive'::text);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_unbound_chk" CHECK (mission_id IS NULL AND plan_id IS NULL AND plan_version_id IS NULL OR mission_id IS NOT NULL AND plan_id IS NOT NULL AND plan_version_id IS NOT NULL AND lifecycle_state = 'approved'::text);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_content_sha256_check" CHECK (content_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "public"."nb_mechanical_templates" ADD CONSTRAINT "nb_mechanical_templates_template_key_check" CHECK (template_key ~ '^nbm_[a-z0-9_]{3,60}$'::text);

ALTER TABLE "public"."nb_mechanical_templates" ADD CONSTRAINT "nb_mechanical_templates_archetype_check" CHECK (archetype = 'bandit_simple'::text);

ALTER TABLE "public"."nb_mechanical_templates" ADD CONSTRAINT "nb_mechanical_templates_lifecycle_state_check" CHECK (lifecycle_state = ANY (ARRAY['draft'::text, 'review'::text, 'approved'::text, 'inactive'::text]));

ALTER TABLE "public"."nb_mechanical_templates" ADD CONSTRAINT "nb_mechanical_templates_control_version_check" CHECK (control_version > 0);

ALTER TABLE "public"."nb_mechanical_templates" ADD CONSTRAINT "nb_mechanical_templates_check" CHECK (lifecycle_state = 'approved'::text AND (active = ANY (ARRAY[true, false])) OR lifecycle_state <> 'approved'::text AND NOT active);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_version_no_check" CHECK (version_no > 0);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_schema_version_check" CHECK (schema_version = 'ninja-book-mechanics/1.0'::text);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_rank_check" CHECK (rank = 'Genin'::text);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_archetype_check" CHECK (archetype = 'bandit_simple'::text);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_base_per_stat_check" CHECK (base_per_stat = 10);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_allocated_points_check" CHECK (allocated_points = 90);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_innata_check" CHECK (innata = 0);

ALTER TABLE "combat_spatial"."arena_instances" ADD CONSTRAINT "arena_instances_source_identity_chk" CHECK (context_source = 'mission'::text AND master_session_id IS NOT NULL AND binding_id IS NOT NULL AND ordinary_claim_id IS NULL AND master_claim_id IS NULL AND panel_claim_id IS NULL OR context_source = 'ordinary'::text AND master_session_id IS NULL AND binding_id IS NULL AND ordinary_claim_id IS NOT NULL AND master_claim_id IS NULL AND panel_claim_id IS NULL OR context_source = 'marionetta_master'::text AND master_session_id IS NOT NULL AND binding_id IS NULL AND ordinary_claim_id IS NULL AND master_claim_id IS NOT NULL AND panel_claim_id IS NULL OR context_source = 'panel_master'::text AND master_session_id IS NOT NULL AND binding_id IS NULL AND ordinary_claim_id IS NULL AND master_claim_id IS NULL AND panel_claim_id IS NOT NULL);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_generation_check" CHECK (jsonb_typeof(generation) = 'object'::text);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_review_state_check" CHECK (review_state = ANY (ARRAY['draft'::text, 'review'::text, 'approved'::text, 'inactive'::text]));

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_control_version_check" CHECK (control_version > 0);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_check" CHECK (supersedes_version_id IS NULL OR supersedes_version_id <> id);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_stats_check" CHECK (jsonb_typeof(stats) = 'object'::text AND stats ?& ARRAY['taijutsu'::text, 'ninjutsu'::text, 'genjutsu'::text, 'forza'::text, 'velocita'::text, 'mente'::text, 'resistenza'::text, 'fuuinjutsu'::text] AND (stats - ARRAY['taijutsu'::text, 'ninjutsu'::text, 'genjutsu'::text, 'forza'::text, 'velocita'::text, 'mente'::text, 'resistenza'::text, 'fuuinjutsu'::text]) = '{}'::jsonb);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_stats_check1" CHECK (((stats ->> 'taijutsu'::text)::integer) >= 10 AND ((stats ->> 'taijutsu'::text)::integer) <= 45 AND (((stats ->> 'taijutsu'::text)::integer) % 5) = 0 AND ((stats ->> 'ninjutsu'::text)::integer) >= 10 AND ((stats ->> 'ninjutsu'::text)::integer) <= 45 AND (((stats ->> 'ninjutsu'::text)::integer) % 5) = 0 AND ((stats ->> 'genjutsu'::text)::integer) >= 10 AND ((stats ->> 'genjutsu'::text)::integer) <= 45 AND (((stats ->> 'genjutsu'::text)::integer) % 5) = 0 AND ((stats ->> 'forza'::text)::integer) >= 10 AND ((stats ->> 'forza'::text)::integer) <= 45 AND (((stats ->> 'forza'::text)::integer) % 5) = 0 AND ((stats ->> 'velocita'::text)::integer) >= 10 AND ((stats ->> 'velocita'::text)::integer) <= 45 AND (((stats ->> 'velocita'::text)::integer) % 5) = 0 AND ((stats ->> 'mente'::text)::integer) >= 10 AND ((stats ->> 'mente'::text)::integer) <= 45 AND (((stats ->> 'mente'::text)::integer) % 5) = 0 AND ((stats ->> 'resistenza'::text)::integer) >= 10 AND ((stats ->> 'resistenza'::text)::integer) <= 45 AND (((stats ->> 'resistenza'::text)::integer) % 5) = 0 AND ((stats ->> 'fuuinjutsu'::text)::integer) >= 10 AND ((stats ->> 'fuuinjutsu'::text)::integer) <= 45 AND (((stats ->> 'fuuinjutsu'::text)::integer) % 5) = 0);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_stats_check2" CHECK ((((stats ->> 'taijutsu'::text)::integer) + ((stats ->> 'ninjutsu'::text)::integer) + ((stats ->> 'genjutsu'::text)::integer) + ((stats ->> 'forza'::text)::integer) + ((stats ->> 'velocita'::text)::integer) + ((stats ->> 'mente'::text)::integer) + ((stats ->> 'resistenza'::text)::integer) + ((stats ->> 'fuuinjutsu'::text)::integer)) = 170);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_check1" CHECK (vita_max = (5::numeric * round((50 + ((stats ->> 'resistenza'::text)::integer) + 10)::numeric / 5.0))::integer);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_check2" CHECK (chakra_max = (5::numeric * round((30::numeric + (((stats ->> 'ninjutsu'::text)::integer) + ((stats ->> 'mente'::text)::integer))::numeric * 1.2 + 15::numeric) / 5.0))::integer);

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_quest_kind_chk" CHECK (quest_kind IS NULL OR (quest_kind = ANY (ARRAY['one_shot'::text, 'trama'::text])));

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_missione_chk" CHECK (tipo = 'duello'::text AND mission_id IS NULL AND quest_kind IS NULL OR tipo = 'quest'::text AND (mission_id IS NOT NULL AND quest_kind IS NULL OR mission_id IS NULL AND quest_kind IS NOT NULL));

ALTER TABLE "combat_consumer_private"."scene_profiles" ADD CONSTRAINT "scene_profiles_producer_version_check" CHECK (producer_version > 0);

ALTER TABLE "combat_consumer_private"."scene_profiles" ADD CONSTRAINT "scene_profiles_geometry_sha256_check" CHECK (geometry_sha256 ~ '^[a-f0-9]{64}$'::text);

ALTER TABLE "combat_consumer_private"."scene_profiles" ADD CONSTRAINT "scene_profiles_approval_reference_check" CHECK (length(btrim(approval_reference)) > 0);

ALTER TABLE "combat_consumer_private"."activities" ADD CONSTRAINT "activities_context_version_check" CHECK (context_version > 0);

ALTER TABLE "combat_consumer_private"."activities" ADD CONSTRAINT "activities_round_no_check" CHECK (round_no > 0);

ALTER TABLE "combat_consumer_private"."activities" ADD CONSTRAINT "activities_phase_check" CHECK (phase = ANY (ARRAY['waiting_join'::text, 'action'::text, 'defense'::text, 'resolved'::text, 'closed'::text]));

ALTER TABLE "combat_consumer_private"."activities" ADD CONSTRAINT "activities_policy_id_check" CHECK (policy_id = ANY (ARRAY['free_duel_nonlethal_real_resources_v1'::text, 'staff_test_no_persistent_resources_v1'::text]));

ALTER TABLE "combat_consumer_private"."activities" ADD CONSTRAINT "activities_check" CHECK ((phase = 'closed'::text) = (closed_at IS NOT NULL));

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_owner_kind_chk" CHECK (owner_kind = ANY (ARRAY['human'::text, 'ai_service'::text]));

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_master_chk" CHECK (owner_kind = 'human'::text AND master_user IS NOT NULL OR owner_kind = 'ai_service'::text AND master_user IS NULL);

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_authority_receipt_sha256_check" CHECK (authority_receipt_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_expected_control_version_check" CHECK (expected_control_version >= 1);

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_state_check" CHECK (state = ANY (ARRAY['offered'::text, 'active'::text, 'terminal'::text, 'recovered'::text]));

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_terminal_mode_check" CHECK (terminal_mode = ANY (ARRAY['normal'::text, 'abort'::text, 'recovery'::text]));

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_check" CHECK ((state = ANY (ARRAY['offered'::text, 'active'::text])) AND terminal_request_key IS NULL AND terminal_at IS NULL OR (state = ANY (ARRAY['terminal'::text, 'recovered'::text])) AND terminal_request_key IS NOT NULL AND terminal_at IS NOT NULL);

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_authority_chk" CHECK (recipient_kind = 'human'::text AND recipient_user IS NOT NULL AND created_by IS NOT NULL AND recipient_service_capability IS NULL AND created_by_service_capability IS NULL OR recipient_kind = 'ai_service'::text AND recipient_user IS NULL AND created_by IS NULL AND recipient_service_capability IS NOT NULL AND created_by_service_capability = recipient_service_capability);

ALTER TABLE "public"."combat_v2_events" ADD CONSTRAINT "combat_v2_events_caller_kind_check" CHECK (caller_kind = ANY (ARRAY['human'::text, 'ai_service'::text]));

ALTER TABLE "public"."combat_v2_events" ADD CONSTRAINT "combat_v2_events_service_authority_chk" CHECK (caller_kind = 'human'::text AND caller_service_capability IS NULL OR caller_kind = 'ai_service'::text AND caller IS NULL AND caller_service_capability IS NOT NULL);

ALTER TABLE "combat_consumer_private"."scene_claims" ADD CONSTRAINT "scene_claims_producer_version_check" CHECK (producer_version > 0);

ALTER TABLE "mission_ai_service_owner"."roster_profiles" ADD CONSTRAINT "roster_profiles_owner_kind_check" CHECK (owner_kind = 'ai_service'::text);

ALTER TABLE "mission_ai_service_owner"."roster_profiles" ADD CONSTRAINT "roster_profiles_team_exact_check" CHECK (team_exact = 2);

ALTER TABLE "mission_ai_service_owner"."roster_profiles" ADD CONSTRAINT "roster_profiles_control_version_check" CHECK (control_version > 0);

ALTER TABLE "mission_ai_service_owner"."roster_profiles" ADD CONSTRAINT "roster_profiles_profile_sha256_check" CHECK (profile_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "mission_ai_service_owner"."roster_profiles" ADD CONSTRAINT "roster_profiles_check" CHECK (active AND activated_at IS NOT NULL OR NOT active AND activated_at IS NULL);

ALTER TABLE "combat_consumer_private"."scene_profiles" ADD CONSTRAINT "ordinary_distinct_slots" CHECK (fighter_one_slot <> fighter_two_slot);

ALTER TABLE "combat_spatial"."arena_templates" ADD CONSTRAINT "arena_templates_template_version_check" CHECK (template_version > 0);

ALTER TABLE "combat_spatial"."arena_templates" ADD CONSTRAINT "arena_templates_width_m_check" CHECK (width_m > 0::numeric);

ALTER TABLE "combat_spatial"."arena_templates" ADD CONSTRAINT "arena_templates_height_m_check" CHECK (height_m > 0::numeric);

ALTER TABLE "combat_spatial"."arena_templates" ADD CONSTRAINT "arena_templates_actor_radius_m_check" CHECK (actor_radius_m > 0::numeric);

ALTER TABLE "combat_spatial"."arena_templates" ADD CONSTRAINT "arena_templates_geometry_contract_version_check" CHECK (geometry_contract_version > 0);

ALTER TABLE "combat_spatial"."arena_templates" ADD CONSTRAINT "arena_templates_status_check" CHECK (status = ANY (ARRAY['draft'::text, 'ready'::text, 'retired'::text]));

ALTER TABLE "combat_spatial"."arena_slots" ADD CONSTRAINT "arena_slots_actor_kind_check" CHECK (actor_kind = ANY (ARRAY['PG'::text, 'PNG'::text]));

ALTER TABLE "combat_spatial"."mission_bindings" ADD CONSTRAINT "mission_bindings_binding_version_check" CHECK (binding_version > 0);

ALTER TABLE "combat_spatial"."mission_bindings" ADD CONSTRAINT "mission_bindings_roster_seal_sha256_check" CHECK (length(roster_seal_sha256) = 64);

ALTER TABLE "combat_spatial"."mission_bindings" ADD CONSTRAINT "mission_bindings_roster_profile_sha256_check" CHECK (length(roster_profile_sha256) = 64);

ALTER TABLE "combat_spatial"."mission_bindings" ADD CONSTRAINT "mission_bindings_guard_function_md5_check" CHECK (jsonb_typeof(guard_function_md5) = 'object'::text);

ALTER TABLE "combat_spatial"."arena_instances" ADD CONSTRAINT "arena_instances_map_version_check" CHECK (map_version > 0);

ALTER TABLE "combat_spatial"."arena_instances" ADD CONSTRAINT "arena_instances_state_check" CHECK (state = ANY (ARRAY['open'::text, 'closed'::text]));

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_controller_chk" CHECK (actor_kind = 'png'::text OR controller_user IS NOT NULL);

ALTER TABLE "combat_consumer_private"."narrative_claims" ADD CONSTRAINT "narrative_claims_report_sha256_check" CHECK (report_sha256 ~ '^[a-f0-9]{64}$'::text);

ALTER TABLE "combat_consumer_private"."narrative_claims" ADD CONSTRAINT "narrative_claims_context_sha256_check" CHECK (context_sha256 ~ '^[a-f0-9]{64}$'::text);

ALTER TABLE "combat_consumer_private"."narrative_claims" ADD CONSTRAINT "narrative_claims_state_check" CHECK (state = ANY (ARRAY['claimed'::text, 'completed'::text, 'failed'::text, 'expired'::text]));

ALTER TABLE "combat_consumer_private"."narrative_claims" ADD CONSTRAINT "narrative_claims_check" CHECK (state <> 'completed'::text OR provider_response_id IS NOT NULL);

ALTER TABLE "combat_consumer_private"."narrative_claims" ADD CONSTRAINT "narrative_claims_completion_sha256_check" CHECK (completion_sha256 IS NULL OR completion_sha256 ~ '^[a-f0-9]{64}$'::text);

ALTER TABLE "clan_marionettisti_private"."sources" ADD CONSTRAINT "sources_source_kind_check" CHECK (source_kind = ANY (ARRAY['real'::text, 'staff'::text]));

ALTER TABLE "clan_marionettisti_private"."sources" ADD CONSTRAINT "sources_profile_version_check" CHECK (profile_version = 'marionetta-l1/1'::text);

ALTER TABLE "clan_marionettisti_private"."sources" ADD CONSTRAINT "sources_check" CHECK (source_kind = 'real'::text AND real_companion_id IS NOT NULL AND real_companion_id = id AND session_id IS NULL AND owner_actor_id IS NULL OR source_kind = 'staff'::text AND real_companion_id IS NULL AND session_id IS NOT NULL AND owner_actor_id IS NOT NULL);

ALTER TABLE "public"."combat_v2_attack_targets" ADD CONSTRAINT "combat_v2_attack_targets_ordinal_check" CHECK (ordinal >= 1 AND ordinal <= 3);

ALTER TABLE "public"."combat_v2_attack_targets" ADD CONSTRAINT "combat_v2_attack_targets_state_check" CHECK (state = ANY (ARRAY['attesa_difesa'::text, 'coperta'::text, 'risolta'::text, 'superflua'::text]));

ALTER TABLE "public"."combat_v2_attack_targets" ADD CONSTRAINT "combat_v2_attack_targets_rng_receipt_sha256_check" CHECK (rng_receipt_sha256 IS NULL OR rng_receipt_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "public"."combat_v2_attack_targets" ADD CONSTRAINT "combat_v2_attack_targets_outcome_check" CHECK (outcome IS NULL OR jsonb_typeof(outcome) = 'object'::text);

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_abilities_check" CHECK (jsonb_typeof(abilities) = 'array'::text AND jsonb_array_length(abilities) <= 20);

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ADD CONSTRAINT "ronda_runtime_bindings_v1_schema_chk" CHECK (schema_version = 'mission-ronda-runtime-binding/1.1'::text);

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ADD CONSTRAINT "ronda_runtime_bindings_v1_exact2_chk" CHECK (cardinality(pg_character_ids) = 2 AND cardinality(narrative_template_ids) = 2 AND cardinality(narrative_version_ids) = 2 AND cardinality(mechanical_template_ids) = 2 AND cardinality(mechanical_version_ids) = 2);

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ADD CONSTRAINT "ronda_runtime_bindings_v1_lifecycle_chk" CHECK (lifecycle_state = ANY (ARRAY['staged'::text, 'active'::text, 'closed'::text]));

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ADD CONSTRAINT "ronda_runtime_bindings_v1_enabled_chk" CHECK (enabled AND lifecycle_state = 'active'::text OR NOT enabled AND (lifecycle_state = ANY (ARRAY['staged'::text, 'closed'::text])));

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ADD CONSTRAINT "ronda_runtime_bindings_v1_sha_chk" CHECK (binding_sha256 ~ '^[0-9a-f]{64}$'::text AND import_statement_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_identity_chk" CHECK (actor_kind = 'pg'::text AND character_id IS NOT NULL AND png_instance_id IS NULL AND provider_instance_v1_id IS NULL AND companion_id IS NULL OR actor_kind = 'png'::text AND character_id IS NULL AND num_nonnulls(png_instance_id, provider_instance_v1_id, companion_id) = 1);

ALTER TABLE "clan_marionettisti_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_geometry_version_check" CHECK (geometry_version > 0);

ALTER TABLE "clan_marionettisti_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_claim_version_check" CHECK (claim_version > 0);

ALTER TABLE "clan_marionettisti_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_authority_version_check" CHECK (authority_version = 'marionetta-master-scene/1'::text);

ALTER TABLE "clan_marionettisti_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_authority_control_version_check" CHECK (authority_control_version > 0);

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_copy_count_check" CHECK (copy_count > 0);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_active_check" CHECK (NOT active OR lifecycle_state = 'approved'::text AND NOT test_only);

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_test_only_check" CHECK (test_only = ANY (ARRAY[true, false]));

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_team_exact_check" CHECK (team_exact >= 1 AND team_exact <= 4);

ALTER TABLE "mission_ai_board_owner"."activations" ADD CONSTRAINT "activations_mission_seal_sha256_check" CHECK (mission_seal_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "mission_ai_board_owner"."activations" ADD CONSTRAINT "activations_state_check" CHECK (state = ANY (ARRAY['enrollment_open'::text, 'start_reserved'::text, 'preview_ready'::text, 'started'::text, 'disarmed'::text]));

ALTER TABLE "mission_ai_board_owner"."activations" ADD CONSTRAINT "activations_control_version_check" CHECK (control_version > 0);

ALTER TABLE "mission_ai_board_owner"."activations" ADD CONSTRAINT "activations_roster_sha256_check" CHECK (roster_sha256 IS NULL OR roster_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "mission_ai_board_owner"."activations" ADD CONSTRAINT "activations_check" CHECK ((state = 'enrollment_open'::text) = (roster_sha256 IS NULL));

ALTER TABLE "mission_ai_board_owner"."activations" ADD CONSTRAINT "activations_check1" CHECK ((state = ANY (ARRAY['enrollment_open'::text, 'disarmed'::text])) OR current_session_id IS NOT NULL);

ALTER TABLE "combat_panel_private"."master_scene_profiles" ADD CONSTRAINT "master_scene_profiles_geometry_fingerprint_check" CHECK (geometry_fingerprint ~ '^[0-9a-f]{32}$'::text);

ALTER TABLE "combat_panel_private"."master_scene_profiles" ADD CONSTRAINT "master_scene_profiles_label_check" CHECK (length(btrim(label)) >= 1 AND length(btrim(label)) <= 120);

ALTER TABLE "combat_panel_private"."master_scene_profiles" ADD CONSTRAINT "master_scene_profiles_profile_version_check" CHECK (profile_version >= 1 AND profile_version <= '9007199254740991'::bigint);

ALTER TABLE "combat_panel_private"."master_scene_profiles" ADD CONSTRAINT "master_scene_profiles_policy_id_check" CHECK (policy_id = ANY (ARRAY['staff_test_no_persistent_resources_v1'::text, 'master_game_resources_v1'::text]));

ALTER TABLE "combat_panel_private"."master_scene_profiles" ADD CONSTRAINT "master_scene_profiles_visibility_mode_check" CHECK (visibility_mode = ANY (ARRAY['master_only'::text, 'participants'::text]));

ALTER TABLE "combat_panel_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_profile_version_check" CHECK (profile_version >= 1 AND profile_version <= '9007199254740991'::bigint);

ALTER TABLE "combat_panel_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_authority_control_version_check" CHECK (authority_control_version >= 1 AND authority_control_version <= '9007199254740991'::bigint);

ALTER TABLE "combat_panel_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_geometry_fingerprint_check" CHECK (geometry_fingerprint ~ '^[0-9a-f]{32}$'::text);

ALTER TABLE "combat_panel_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_roster_fingerprint_check" CHECK (roster_fingerprint ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "combat_panel_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_policy_id_check" CHECK (policy_id = ANY (ARRAY['staff_test_no_persistent_resources_v1'::text, 'master_game_resources_v1'::text]));

ALTER TABLE "combat_panel_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_visibility_mode_check" CHECK (visibility_mode = ANY (ARRAY['master_only'::text, 'participants'::text]));

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_check" CHECK (copy_cap >= copy_count);

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_source_body_version_check" CHECK (source_body_version > 0);

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_mode_check" CHECK (mode = ANY (ARRAY['diversivo'::text, 'copertura'::text, 'assalto'::text]));

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_state_check" CHECK (state = ANY (ARRAY['active'::text, 'consumed'::text, 'expired'::text]));

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_state_version_check" CHECK (state_version > 0);

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_terminal_reason_check" CHECK (terminal_reason = ANY (ARRAY['first_attack'::text, 'assault_resolved'::text, 'owner_next_action'::text, 'owner_inoperative'::text, 'combat_end'::text, 'formation_invalid'::text]));

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_check1" CHECK (combat_panel_private.multiplication_formation_valid(figures, copy_count, copy_cap, original_index));

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_check2" CHECK ((state = 'active'::text) = (ended_at IS NULL));

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_check3" CHECK ((state = 'active'::text) = (terminal_reason IS NULL));

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_check4" CHECK (state <> 'consumed'::text OR (terminal_reason = ANY (ARRAY['first_attack'::text, 'assault_resolved'::text])));

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_check5" CHECK (state <> 'expired'::text OR (terminal_reason <> ALL (ARRAY['first_attack'::text, 'assault_resolved'::text])));

ALTER TABLE "combat_panel_private"."multiplication_resolutions" ADD CONSTRAINT "multiplication_resolutions_selected_index_check" CHECK (selected_index > 0);

ALTER TABLE "combat_panel_private"."multiplication_resolutions" ADD CONSTRAINT "multiplication_resolutions_choice_kind_check" CHECK (choice_kind = ANY (ARRAY['explicit'::text, 'server_random'::text, 'formation_coverage'::text, 'active_dojutsu'::text]));

ALTER TABLE "combat_panel_private"."multiplication_resolutions" ADD CONSTRAINT "multiplication_resolutions_outcome_check" CHECK (outcome = ANY (ARRAY['copy_hit'::text, 'original_found'::text]));

ALTER TABLE "combat_panel_private"."multiplication_resolutions" ADD CONSTRAINT "multiplication_resolutions_facts_check" CHECK (jsonb_typeof(facts) = 'object'::text);

ALTER TABLE "combat_panel_private"."multiplication_resolutions" ADD CONSTRAINT "multiplication_resolutions_receipt_sha256_check" CHECK (receipt_sha256 ~ '^[0-9a-f]{64}$'::text);

ALTER TABLE "combat_panel_private"."multiplication_resolutions" ADD CONSTRAINT "multiplication_resolutions_check" CHECK ((choice_kind = 'server_random'::text) = (rng_seed IS NOT NULL));

ALTER TABLE "combat_panel_private"."multiplication_resolutions" ADD CONSTRAINT "multiplication_resolutions_rng_seed_check" CHECK (rng_seed IS NULL OR octet_length(rng_seed) = 32);

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_scene_sha256_check" CHECK (scene_sha256 ~ '^[a-f0-9]{64}$'::text);

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_state_check" CHECK (state = ANY (ARRAY['claimed'::text, 'provider_reserved'::text, 'generated'::text, 'published'::text, 'failed'::text]));

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_result_sha256_check" CHECK (result_sha256 ~ '^[a-f0-9]{64}$'::text);

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_redelivery_state_check" CHECK (redelivery_state = ANY (ARRAY['reserved'::text, 'queued'::text, 'failed'::text]));

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_check" CHECK ((result_payload IS NULL) = (result_bytes IS NULL));

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_check1" CHECK ((result_payload IS NULL) = (result_sha256 IS NULL));

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_check2" CHECK ((state <> ALL (ARRAY['generated'::text, 'published'::text])) OR result_payload IS NOT NULL AND permit_at IS NOT NULL);

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_check3" CHECK (state <> 'provider_reserved'::text OR permit_at IS NOT NULL);

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_check4" CHECK (state <> 'published'::text OR completion IS NOT NULL);

ALTER TABLE "public"."profiles" ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE "public"."characters" ADD CONSTRAINT "characters_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE "public"."messages" ADD CONSTRAINT "messages_location_id_fkey" FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE;

ALTER TABLE "public"."messages" ADD CONSTRAINT "messages_character_id_fkey" FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE SET NULL;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_recipient_user_fkey" FOREIGN KEY (recipient_user) REFERENCES profiles(id) ON DELETE RESTRICT;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_consumed_event_id_fkey" FOREIGN KEY (consumed_event_id) REFERENCES combat_v2_events(id) ON DELETE RESTRICT;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE RESTRICT;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_master_session_id_mission_id_fkey" FOREIGN KEY (master_session_id, mission_id) REFERENCES master_v2_sessions(id, mission_id) ON DELETE RESTRICT;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_narrative_version_id_narrativ_fkey" FOREIGN KEY (narrative_version_id, narrative_template_id) REFERENCES nb_template_versions(id, template_id) ON DELETE RESTRICT;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_mechanical_version_id_mechani_fkey" FOREIGN KEY (mechanical_version_id, mechanical_template_id) REFERENCES nb_mechanical_versions(id, template_id) ON DELETE RESTRICT;

ALTER TABLE "public"."character_companions" ADD CONSTRAINT "character_companions_character_id_fkey" FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE;

ALTER TABLE "public"."messages" ADD CONSTRAINT "messages_companion_id_fkey" FOREIGN KEY (companion_id) REFERENCES character_companions(id) ON DELETE SET NULL;

ALTER TABLE "public"."locations" ADD CONSTRAINT "locations_overflow_of_fkey" FOREIGN KEY (overflow_of) REFERENCES locations(id) ON DELETE SET NULL;

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_ronda_binding_id_fkey" FOREIGN KEY (ronda_binding_id) REFERENCES mission_internal.ronda_runtime_bindings_v1(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_provider_instances_v1" ADD CONSTRAINT "combat_v2_provider_instances_v1_session_id_fkey" FOREIGN KEY (session_id) REFERENCES combat_v2_sessions(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_provider_instances_v1" ADD CONSTRAINT "combat_v2_provider_instances_v1_offer_ref_fkey" FOREIGN KEY (offer_ref) REFERENCES master_v2_nb_actor_offers_v1(offer_ref) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_provider_instances_v1" ADD CONSTRAINT "combat_v2_provider_instances__narrative_version_ref_narrat_fkey" FOREIGN KEY (narrative_version_ref, narrative_template_ref) REFERENCES nb_template_versions(id, template_id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_provider_instances_v1" ADD CONSTRAINT "combat_v2_provider_instances__mechanical_version_ref_mecha_fkey" FOREIGN KEY (mechanical_version_ref, mechanical_template_ref) REFERENCES nb_mechanical_versions(id, template_id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_provider_instance_v1_fkey" FOREIGN KEY (provider_instance_v1_id) REFERENCES combat_v2_provider_instances_v1(id) ON DELETE RESTRICT;

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_location_id_fkey" FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE RESTRICT;

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_master_user_fkey" FOREIGN KEY (master_user) REFERENCES profiles(id) ON DELETE RESTRICT;

ALTER TABLE "public"."master_v2_sessions" ADD CONSTRAINT "master_v2_sessions_mission_id_fkey" FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_sessions" ADD CONSTRAINT "combat_v2_sessions_master_session_id_fkey" FOREIGN KEY (master_session_id) REFERENCES master_v2_sessions(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_sessions" ADD CONSTRAINT "combat_v2_sessions_location_id_fkey" FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_png_instances" ADD CONSTRAINT "combat_v2_png_instances_session_id_fkey" FOREIGN KEY (session_id) REFERENCES combat_v2_sessions(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_png_instances" ADD CONSTRAINT "combat_v2_png_instances_template_id_fkey" FOREIGN KEY (template_id) REFERENCES png_templates(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_round_reports" ADD CONSTRAINT "combat_v2_round_reports_message_id_fkey" FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_session_id_fkey" FOREIGN KEY (session_id) REFERENCES combat_v2_sessions(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_character_id_fkey" FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_png_instance_id_fkey" FOREIGN KEY (png_instance_id) REFERENCES combat_v2_png_instances(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_rounds" ADD CONSTRAINT "combat_v2_rounds_session_id_fkey" FOREIGN KEY (session_id) REFERENCES combat_v2_sessions(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_declarations" ADD CONSTRAINT "combat_v2_declarations_round_id_fkey" FOREIGN KEY (round_id) REFERENCES combat_v2_rounds(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_declarations" ADD CONSTRAINT "combat_v2_declarations_actor_id_fkey" FOREIGN KEY (actor_id) REFERENCES combat_v2_actors(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_declarations" ADD CONSTRAINT "combat_v2_declarations_parent_attack_id_fkey" FOREIGN KEY (parent_attack_id) REFERENCES combat_v2_declarations(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_declarations" ADD CONSTRAINT "combat_v2_declarations_target_actor_id_fkey" FOREIGN KEY (target_actor_id) REFERENCES combat_v2_actors(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_round_reports" ADD CONSTRAINT "combat_v2_round_reports_round_id_fkey" FOREIGN KEY (round_id) REFERENCES combat_v2_rounds(id) ON DELETE RESTRICT;

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_template_id_fkey" FOREIGN KEY (template_id) REFERENCES nb_templates(id) ON DELETE RESTRICT;

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_supersedes_version_id_fkey" FOREIGN KEY (supersedes_version_id) REFERENCES nb_template_versions(id) ON DELETE RESTRICT;

ALTER TABLE "public"."nb_template_versions" ADD CONSTRAINT "nb_template_versions_supersedes_version_id_template_id_fkey" FOREIGN KEY (supersedes_version_id, template_id) REFERENCES nb_template_versions(id, template_id) ON DELETE RESTRICT;

ALTER TABLE "public"."nb_templates" ADD CONSTRAINT "nb_templates_current_version_fk" FOREIGN KEY (current_version_id, id) REFERENCES nb_template_versions(id, template_id) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_miyo_template_version_id_miyo_template_fkey" FOREIGN KEY (miyo_template_version_id, miyo_template_id) REFERENCES nb_template_versions(id, template_id) ON DELETE RESTRICT;

ALTER TABLE "mission_ai_board_owner"."activations" ADD CONSTRAINT "activations_current_session_id_fkey" FOREIGN KEY (current_session_id) REFERENCES master_v2_sessions(id) ON DELETE RESTRICT;

ALTER TABLE "public"."mission_plans" ADD CONSTRAINT "mission_plans_mission_id_fkey" FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE RESTRICT;

ALTER TABLE "public"."mission_plan_versions" ADD CONSTRAINT "mission_plan_versions_plan_id_fkey" FOREIGN KEY (plan_id) REFERENCES mission_plans(id) ON DELETE RESTRICT;

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_miyo_template_id_fkey" FOREIGN KEY (miyo_template_id) REFERENCES nb_templates(id) ON DELETE RESTRICT;

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_source_manifest_sha256_fkey" FOREIGN KEY (source_manifest_sha256) REFERENCES mission_internal.nb_mission_source_attestations(manifest_sha256) ON DELETE RESTRICT;

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_mission_id_fkey" FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE RESTRICT;

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_plan_id_fkey" FOREIGN KEY (plan_id) REFERENCES mission_plans(id) ON DELETE RESTRICT;

ALTER TABLE "public"."nb_mission_packages" ADD CONSTRAINT "nb_mission_packages_plan_version_id_fkey" FOREIGN KEY (plan_version_id) REFERENCES mission_plan_versions(id) ON DELETE RESTRICT;

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_template_id_fkey" FOREIGN KEY (template_id) REFERENCES nb_mechanical_templates(id) ON DELETE RESTRICT;

ALTER TABLE "public"."nb_mechanical_versions" ADD CONSTRAINT "nb_mechanical_versions_supersedes_version_id_template_id_fkey" FOREIGN KEY (supersedes_version_id, template_id) REFERENCES nb_mechanical_versions(id, template_id) ON DELETE RESTRICT;

ALTER TABLE "public"."nb_mechanical_templates" ADD CONSTRAINT "nb_mechanical_templates_current_version_fk" FOREIGN KEY (current_version_id, id) REFERENCES nb_mechanical_versions(id, template_id) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_claim_id_fkey" FOREIGN KEY (claim_id) REFERENCES combat_consumer_private.narrative_claims(id);

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_round_id_fkey" FOREIGN KEY (round_id) REFERENCES combat_v2_rounds(id);

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ADD CONSTRAINT "scene_attempts_v2_session_id_fkey" FOREIGN KEY (session_id) REFERENCES combat_consumer_private.activities(session_id);

ALTER TABLE "combat_consumer_private"."scene_profiles" ADD CONSTRAINT "scene_profiles_location_id_fkey" FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE RESTRICT;

ALTER TABLE "combat_consumer_private"."scene_profiles" ADD CONSTRAINT "scene_profiles_template_key_template_version_fkey" FOREIGN KEY (template_key, template_version) REFERENCES combat_spatial.arena_templates(template_key, template_version) ON DELETE RESTRICT;

ALTER TABLE "combat_consumer_private"."activities" ADD CONSTRAINT "activities_session_id_fkey" FOREIGN KEY (session_id) REFERENCES combat_v2_sessions(id) ON DELETE RESTRICT;

ALTER TABLE "combat_consumer_private"."activities" ADD CONSTRAINT "activities_location_id_fkey" FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE RESTRICT;

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_master_session_id_fkey" FOREIGN KEY (master_session_id) REFERENCES master_v2_sessions(id) ON DELETE RESTRICT;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_recipient_service_capability_fkey" FOREIGN KEY (recipient_service_capability) REFERENCES mission_ai_service_owner.capabilities(id) ON DELETE RESTRICT;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ADD CONSTRAINT "master_v2_nb_actor_offers_v1_created_by_service_capability_fkey" FOREIGN KEY (created_by_service_capability) REFERENCES mission_ai_service_owner.capabilities(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_events" ADD CONSTRAINT "combat_v2_events_caller_service_capability_fkey" FOREIGN KEY (caller_service_capability) REFERENCES mission_ai_service_owner.capabilities(id) ON DELETE RESTRICT;

ALTER TABLE "combat_consumer_private"."activities" ADD CONSTRAINT "activities_opener_character_id_fkey" FOREIGN KEY (opener_character_id) REFERENCES characters(id) ON DELETE RESTRICT;

ALTER TABLE "combat_consumer_private"."activities" ADD CONSTRAINT "activities_exchange_id_fkey" FOREIGN KEY (exchange_id) REFERENCES combat_v2_rounds(id) ON DELETE RESTRICT;

ALTER TABLE "combat_consumer_private"."activities" ADD CONSTRAINT "activities_turn_actor_id_fkey" FOREIGN KEY (turn_actor_id) REFERENCES combat_v2_actors(id) ON DELETE RESTRICT;

ALTER TABLE "combat_consumer_private"."activities" ADD CONSTRAINT "activities_scene_profile_id_location_id_fkey" FOREIGN KEY (scene_profile_id, location_id) REFERENCES combat_consumer_private.scene_profiles(id, location_id) ON DELETE RESTRICT;

ALTER TABLE "combat_consumer_private"."scene_claims" ADD CONSTRAINT "scene_claims_session_id_fkey" FOREIGN KEY (session_id) REFERENCES combat_consumer_private.activities(session_id) ON DELETE RESTRICT;

ALTER TABLE "combat_consumer_private"."scene_claims" ADD CONSTRAINT "scene_claims_scene_profile_id_fkey" FOREIGN KEY (scene_profile_id) REFERENCES combat_consumer_private.scene_profiles(id) ON DELETE RESTRICT;

ALTER TABLE "combat_consumer_private"."scene_claims" ADD CONSTRAINT "scene_claims_template_key_template_version_fkey" FOREIGN KEY (template_key, template_version) REFERENCES combat_spatial.arena_templates(template_key, template_version) ON DELETE RESTRICT;

ALTER TABLE "combat_spatial"."arena_instances" ADD CONSTRAINT "arena_instances_ordinary_claim_fk" FOREIGN KEY (ordinary_claim_id, encounter_id, template_key, template_version) REFERENCES combat_consumer_private.scene_claims(id, session_id, template_key, template_version) ON DELETE RESTRICT;

ALTER TABLE "mission_ai_service_owner"."roster_profiles" ADD CONSTRAINT "roster_profiles_operational_location_id_fkey" FOREIGN KEY (operational_location_id) REFERENCES locations(id) ON DELETE RESTRICT;

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_roster_profile_id_fkey" FOREIGN KEY (roster_profile_id) REFERENCES mission_ai_service_owner.roster_profiles(id) ON DELETE RESTRICT;

ALTER TABLE "combat_consumer_private"."scene_profiles" ADD CONSTRAINT "ordinary_slot_one_fk" FOREIGN KEY (template_key, template_version, fighter_one_slot) REFERENCES combat_spatial.arena_slots(template_key, template_version, slot_key);

ALTER TABLE "combat_consumer_private"."scene_profiles" ADD CONSTRAINT "ordinary_slot_two_fk" FOREIGN KEY (template_key, template_version, fighter_two_slot) REFERENCES combat_spatial.arena_slots(template_key, template_version, slot_key);

ALTER TABLE "combat_spatial"."arena_slots" ADD CONSTRAINT "arena_slots_template_key_template_version_fkey" FOREIGN KEY (template_key, template_version) REFERENCES combat_spatial.arena_templates(template_key, template_version);

ALTER TABLE "combat_spatial"."mission_bindings" ADD CONSTRAINT "mission_bindings_template_key_template_version_fkey" FOREIGN KEY (template_key, template_version) REFERENCES combat_spatial.arena_templates(template_key, template_version);

ALTER TABLE "combat_spatial"."arena_instances" ADD CONSTRAINT "arena_instances_binding_id_fkey" FOREIGN KEY (binding_id) REFERENCES combat_spatial.mission_bindings(binding_id);

ALTER TABLE "combat_spatial"."arena_instances" ADD CONSTRAINT "arena_instances_template_key_template_version_fkey" FOREIGN KEY (template_key, template_version) REFERENCES combat_spatial.arena_templates(template_key, template_version);

ALTER TABLE "combat_consumer_private"."narrative_claims" ADD CONSTRAINT "narrative_claims_session_id_fkey" FOREIGN KEY (session_id) REFERENCES combat_consumer_private.activities(session_id);

ALTER TABLE "combat_consumer_private"."narrative_claims" ADD CONSTRAINT "narrative_claims_round_id_fkey" FOREIGN KEY (round_id) REFERENCES combat_v2_rounds(id);

ALTER TABLE "combat_consumer_private"."narrative_claims" ADD CONSTRAINT "narrative_claims_report_id_fkey" FOREIGN KEY (report_id) REFERENCES combat_v2_round_reports(id);

ALTER TABLE "clan_marionettisti_private"."sources" ADD CONSTRAINT "sources_real_companion_id_fkey" FOREIGN KEY (real_companion_id) REFERENCES character_companions(id) ON DELETE RESTRICT;

ALTER TABLE "clan_marionettisti_private"."sources" ADD CONSTRAINT "sources_session_id_fkey" FOREIGN KEY (session_id) REFERENCES combat_v2_sessions(id) ON DELETE RESTRICT;

ALTER TABLE "clan_marionettisti_private"."sources" ADD CONSTRAINT "sources_owner_actor_id_fkey" FOREIGN KEY (owner_actor_id) REFERENCES combat_v2_actors(id) ON DELETE RESTRICT;

ALTER TABLE "clan_marionettisti_private"."sources" ADD CONSTRAINT "sources_owner_character_id_fkey" FOREIGN KEY (owner_character_id) REFERENCES characters(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_attack_targets" ADD CONSTRAINT "combat_v2_attack_targets_round_id_fkey" FOREIGN KEY (round_id) REFERENCES combat_v2_rounds(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_attack_targets" ADD CONSTRAINT "combat_v2_attack_targets_attack_declaration_id_fkey" FOREIGN KEY (attack_declaration_id) REFERENCES combat_v2_declarations(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_attack_targets" ADD CONSTRAINT "combat_v2_attack_targets_target_actor_id_fkey" FOREIGN KEY (target_actor_id) REFERENCES combat_v2_actors(id) ON DELETE RESTRICT;

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ADD CONSTRAINT "ronda_runtime_bindings_v1_mission_id_fkey" FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE RESTRICT;

ALTER TABLE "public"."combat_v2_actors" ADD CONSTRAINT "combat_v2_actors_companion_id_fkey" FOREIGN KEY (companion_id) REFERENCES clan_marionettisti_private.sources(id) ON DELETE RESTRICT;

ALTER TABLE "clan_marionettisti_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_master_session_id_fkey" FOREIGN KEY (master_session_id) REFERENCES master_v2_sessions(id) ON DELETE RESTRICT;

ALTER TABLE "clan_marionettisti_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_encounter_id_fkey" FOREIGN KEY (encounter_id) REFERENCES combat_v2_sessions(id) ON DELETE RESTRICT;

ALTER TABLE "clan_marionettisti_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_template_key_template_version_fkey" FOREIGN KEY (template_key, template_version) REFERENCES combat_spatial.arena_templates(template_key, template_version) ON DELETE RESTRICT;

ALTER TABLE "combat_spatial"."arena_instances" ADD CONSTRAINT "arena_instances_master_claim_binding_fkey" FOREIGN KEY (master_claim_id, master_session_id, encounter_id, template_key, template_version) REFERENCES clan_marionettisti_private.master_scene_claims(claim_id, master_session_id, encounter_id, template_key, template_version) ON DELETE RESTRICT;

ALTER TABLE "mission_ai_board_owner"."activations" ADD CONSTRAINT "activations_location_id_fkey" FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE RESTRICT;

ALTER TABLE "mission_ai_board_owner"."activations" ADD CONSTRAINT "activations_mission_id_fkey" FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE RESTRICT;

ALTER TABLE "mission_ai_board_owner"."activations" ADD CONSTRAINT "activations_package_id_fkey" FOREIGN KEY (package_id) REFERENCES nb_mission_packages(id) ON DELETE RESTRICT;

ALTER TABLE "mission_ai_service_owner"."capabilities" ADD CONSTRAINT "capabilities_board_activation_id_fkey" FOREIGN KEY (board_activation_id) REFERENCES mission_ai_board_owner.activations(id) ON DELETE RESTRICT;

ALTER TABLE "combat_panel_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES combat_panel_private.master_scene_profiles(id);

ALTER TABLE "combat_panel_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_master_session_id_fkey" FOREIGN KEY (master_session_id) REFERENCES master_v2_sessions(id);

ALTER TABLE "combat_panel_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_encounter_id_fkey" FOREIGN KEY (encounter_id) REFERENCES combat_v2_sessions(id);

ALTER TABLE "combat_panel_private"."master_scene_claims" ADD CONSTRAINT "master_scene_claims_template_key_template_version_fkey" FOREIGN KEY (template_key, template_version) REFERENCES combat_spatial.arena_templates(template_key, template_version);

ALTER TABLE "combat_panel_private"."master_scene_profiles" ADD CONSTRAINT "master_scene_profiles_location_id_fkey" FOREIGN KEY (location_id) REFERENCES locations(id);

ALTER TABLE "combat_panel_private"."master_scene_profiles" ADD CONSTRAINT "master_scene_profiles_template_key_template_version_fkey" FOREIGN KEY (template_key, template_version) REFERENCES combat_spatial.arena_templates(template_key, template_version);

ALTER TABLE "combat_spatial"."arena_instances" ADD CONSTRAINT "arena_instances_panel_claim_fkey" FOREIGN KEY (panel_claim_id, master_session_id, encounter_id, template_key, template_version) REFERENCES combat_panel_private.master_scene_claims(id, master_session_id, encounter_id, template_key, template_version);

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_session_id_fkey" FOREIGN KEY (session_id) REFERENCES combat_v2_sessions(id);

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_round_id_fkey" FOREIGN KEY (round_id) REFERENCES combat_v2_rounds(id);

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_actor_id_fkey" FOREIGN KEY (actor_id) REFERENCES combat_v2_actors(id);

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_declaration_id_fkey" FOREIGN KEY (declaration_id) REFERENCES combat_v2_declarations(id);

ALTER TABLE "combat_panel_private"."multiplication_formations" ADD CONSTRAINT "multiplication_formations_instance_id_fkey" FOREIGN KEY (instance_id) REFERENCES combat_spatial.arena_instances(instance_id);

ALTER TABLE "combat_panel_private"."multiplication_resolutions" ADD CONSTRAINT "multiplication_resolutions_formation_id_fkey" FOREIGN KEY (formation_id) REFERENCES combat_panel_private.multiplication_formations(id);

ALTER TABLE "combat_panel_private"."multiplication_resolutions" ADD CONSTRAINT "multiplication_resolutions_attack_target_id_fkey" FOREIGN KEY (attack_target_id) REFERENCES combat_v2_attack_targets(id);

ALTER TABLE "combat_panel_private"."multiplication_resolutions" ADD CONSTRAINT "multiplication_resolutions_chooser_actor_id_fkey" FOREIGN KEY (chooser_actor_id) REFERENCES combat_v2_actors(id);

ALTER TABLE "auth"."users" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "clan_marionettisti_private"."master_scene_claims" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "clan_marionettisti_private"."sources" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_consumer_private"."activities" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_consumer_private"."activities" FORCE ROW LEVEL SECURITY;

ALTER TABLE "combat_consumer_private"."narrative_claims" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_consumer_private"."narrative_claims" FORCE ROW LEVEL SECURITY;

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_consumer_private"."scene_attempts_v2" FORCE ROW LEVEL SECURITY;

ALTER TABLE "combat_consumer_private"."scene_claims" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_consumer_private"."scene_claims" FORCE ROW LEVEL SECURITY;

ALTER TABLE "combat_consumer_private"."scene_profiles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_consumer_private"."scene_profiles" FORCE ROW LEVEL SECURITY;

ALTER TABLE "combat_panel_private"."master_scene_claims" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_panel_private"."master_scene_profiles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_panel_private"."multiplication_formations" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_panel_private"."multiplication_formations" FORCE ROW LEVEL SECURITY;

ALTER TABLE "combat_panel_private"."multiplication_resolutions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_panel_private"."multiplication_resolutions" FORCE ROW LEVEL SECURITY;

ALTER TABLE "combat_spatial"."arena_instances" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_spatial"."arena_instances" FORCE ROW LEVEL SECURITY;

ALTER TABLE "combat_spatial"."arena_slots" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_spatial"."arena_slots" FORCE ROW LEVEL SECURITY;

ALTER TABLE "combat_spatial"."arena_templates" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_spatial"."arena_templates" FORCE ROW LEVEL SECURITY;

ALTER TABLE "combat_spatial"."mission_bindings" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "combat_spatial"."mission_bindings" FORCE ROW LEVEL SECURITY;

ALTER TABLE "mission_ai_board_owner"."activations" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "mission_ai_board_owner"."activations" FORCE ROW LEVEL SECURITY;

ALTER TABLE "mission_ai_service_owner"."capabilities" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "mission_ai_service_owner"."capabilities" FORCE ROW LEVEL SECURITY;

ALTER TABLE "mission_ai_service_owner"."roster_profiles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "mission_ai_service_owner"."roster_profiles" FORCE ROW LEVEL SECURITY;

ALTER TABLE "mission_internal"."nb_mission_source_attestations" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "mission_internal"."nb_mission_source_attestations" FORCE ROW LEVEL SECURITY;

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "mission_internal"."ronda_runtime_bindings_v1" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."character_companions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."characters" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_actors" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_actors" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_attack_targets" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_attack_targets" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_declarations" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_declarations" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_events" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_events" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_png_instances" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_png_instances" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_provider_instances_v1" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_provider_instances_v1" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_round_reports" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_round_reports" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_rounds" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_rounds" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_sessions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."combat_v2_sessions" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."locations" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."master_v2_nb_actor_offers_v1" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."master_v2_sessions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."master_v2_sessions" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."mission_plan_versions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."mission_plan_versions" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."mission_plans" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."mission_plans" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."missions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."nb_mechanical_templates" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."nb_mechanical_templates" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."nb_mechanical_versions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."nb_mechanical_versions" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."nb_mission_packages" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."nb_mission_packages" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."nb_template_versions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."nb_template_versions" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."nb_templates" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."nb_templates" FORCE ROW LEVEL SECURITY;

ALTER TABLE "public"."png_templates" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);

CREATE INDEX idx_users_email ON auth.users USING btree (email);

CREATE INDEX idx_users_created_at_desc ON auth.users USING btree (created_at DESC);

CREATE INDEX idx_users_last_sign_in_at_desc ON auth.users USING btree (last_sign_in_at DESC);

CREATE INDEX idx_users_name ON auth.users USING btree (((raw_user_meta_data ->> 'name'::text))) WHERE ((raw_user_meta_data ->> 'name'::text) IS NOT NULL);

CREATE UNIQUE INDEX profiles_username_lower_key ON public.profiles USING btree (lower(username));

CREATE INDEX messages_loc_time ON public.messages USING btree (location_id, created_at);

CREATE UNIQUE INDEX chars_faceclaim_uq ON public.characters USING btree (lower(btrim(face_claim))) WHERE ((face_claim IS NOT NULL) AND (btrim(face_claim) <> ''::text));

CREATE INDEX missions_status_idx ON public.missions USING btree (status, created_at DESC);

CREATE INDEX character_companions_char ON public.character_companions USING btree (character_id);

CREATE UNIQUE INDEX characters_cercoterio_unico ON public.characters USING btree (cercoterio) WHERE (cercoterio IS NOT NULL);

CREATE UNIQUE INDEX master_v2_sessions_unica_luogo_idx ON public.master_v2_sessions USING btree (location_id) WHERE (stato <> ALL (ARRAY['chiusa'::text, 'annullata'::text]));

CREATE INDEX master_v2_sessions_master_stato_idx ON public.master_v2_sessions USING btree (master_user, stato);

CREATE INDEX master_v2_sessions_missione_idx ON public.master_v2_sessions USING btree (mission_id) WHERE (mission_id IS NOT NULL);

CREATE UNIQUE INDEX combat_v2_sessions_unica_luogo_idx ON public.combat_v2_sessions USING btree (location_id) WHERE (state <> ALL (ARRAY['chiuso'::text, 'annullato'::text]));

CREATE INDEX combat_v2_sessions_master_idx ON public.combat_v2_sessions USING btree (master_session_id);

CREATE INDEX combat_v2_png_instances_template_idx ON public.combat_v2_png_instances USING btree (template_id);

CREATE INDEX combat_v2_actors_controller_idx ON public.combat_v2_actors USING btree (session_id, controller_user);

CREATE INDEX combat_v2_actors_character_idx ON public.combat_v2_actors USING btree (character_id);

CREATE INDEX combat_v2_actors_png_instance_idx ON public.combat_v2_actors USING btree (png_instance_id);

CREATE UNIQUE INDEX combat_v2_rounds_unico_attivo_idx ON public.combat_v2_rounds USING btree (session_id) WHERE (state <> 'narrato'::text);

CREATE UNIQUE INDEX combat_v2_declarations_principale_idx ON public.combat_v2_declarations USING btree (round_id, actor_id) WHERE (kind = ANY (ARRAY['attacco'::text, 'movimento'::text, 'utilita'::text, 'passa'::text]));

CREATE UNIQUE INDEX combat_v2_declarations_difesa_idx ON public.combat_v2_declarations USING btree (parent_attack_id) WHERE (kind = ANY (ARRAY['difesa'::text, 'nessuna'::text]));

CREATE INDEX combat_v2_declarations_round_order_idx ON public.combat_v2_declarations USING btree (round_id, order_no);

CREATE INDEX combat_v2_declarations_target_idx ON public.combat_v2_declarations USING btree (target_actor_id);

CREATE INDEX combat_v2_declarations_actor_idx ON public.combat_v2_declarations USING btree (actor_id);

CREATE INDEX training_messages_character_location_time_idx ON public.messages USING btree (character_id, location_id, created_at) WHERE ((character_id IS NOT NULL) AND (recipient_user IS NULL));

CREATE INDEX mission_plans_mission_stato_idx ON public.mission_plans USING btree (mission_id, stato);

CREATE INDEX mission_plan_versions_plan_stato_idx ON public.mission_plan_versions USING btree (plan_id, stato, versione DESC);

CREATE INDEX nb_mission_packages_mission_id_idx ON public.nb_mission_packages USING btree (mission_id) WHERE (mission_id IS NOT NULL);

CREATE INDEX nb_mission_packages_plan_id_idx ON public.nb_mission_packages USING btree (plan_id) WHERE (plan_id IS NOT NULL);

CREATE INDEX nb_mission_packages_plan_version_id_idx ON public.nb_mission_packages USING btree (plan_version_id) WHERE (plan_version_id IS NOT NULL);

CREATE INDEX nb_mission_packages_miyo_template_id_idx ON public.nb_mission_packages USING btree (miyo_template_id);

CREATE INDEX nb_mission_packages_miyo_version_id_idx ON public.nb_mission_packages USING btree (miyo_template_version_id);

CREATE INDEX nb_mechanical_versions_template_idx ON public.nb_mechanical_versions USING btree (template_id);

CREATE INDEX master_v2_nb_actor_offers_v1_session_idx ON public.master_v2_nb_actor_offers_v1 USING btree (master_session_id, offer_ref);

CREATE INDEX master_v2_nb_actor_offers_v1_session_mission_idx ON public.master_v2_nb_actor_offers_v1 USING btree (master_session_id, mission_id);

CREATE INDEX master_v2_nb_actor_offers_v1_recipient_idx ON public.master_v2_nb_actor_offers_v1 USING btree (recipient_user);

CREATE INDEX master_v2_nb_actor_offers_v1_creator_idx ON public.master_v2_nb_actor_offers_v1 USING btree (created_by);

CREATE INDEX master_v2_nb_actor_offers_v1_consumed_event_idx ON public.master_v2_nb_actor_offers_v1 USING btree (consumed_event_id) WHERE (consumed_event_id IS NOT NULL);

CREATE INDEX master_v2_nb_actor_offers_v1_narrative_idx ON public.master_v2_nb_actor_offers_v1 USING btree (narrative_version_id, narrative_template_id);

CREATE INDEX master_v2_nb_actor_offers_v1_mechanical_idx ON public.master_v2_nb_actor_offers_v1 USING btree (mechanical_version_id, mechanical_template_id);

CREATE INDEX combat_v2_provider_instances_v1_session_idx ON public.combat_v2_provider_instances_v1 USING btree (session_id);

CREATE INDEX combat_v2_provider_instances_v1_narrative_idx ON public.combat_v2_provider_instances_v1 USING btree (narrative_version_ref, narrative_template_ref);

CREATE INDEX combat_v2_provider_instances_v1_mechanical_idx ON public.combat_v2_provider_instances_v1 USING btree (mechanical_version_ref, mechanical_template_ref);

CREATE INDEX combat_v2_actors_provider_instance_v1_idx ON public.combat_v2_actors USING btree (provider_instance_v1_id);

CREATE INDEX a18g0c_capability_state ON mission_ai_service_owner.capabilities USING btree (state, master_session_id);

CREATE UNIQUE INDEX roster_profiles_one_active ON mission_ai_service_owner.roster_profiles USING btree ((1)) WHERE active;

CREATE INDEX combat_v2_attack_targets_round_idx ON public.combat_v2_attack_targets USING btree (round_id, attack_declaration_id);

CREATE INDEX combat_v2_attack_targets_target_idx ON public.combat_v2_attack_targets USING btree (target_actor_id);

CREATE UNIQUE INDEX scene_profiles_one_enabled_location ON combat_consumer_private.scene_profiles USING btree (location_id) WHERE enabled;

CREATE UNIQUE INDEX activities_one_open_location ON combat_consumer_private.activities USING btree (location_id) WHERE (phase <> 'closed'::text);

CREATE UNIQUE INDEX narrative_response_once ON combat_consumer_private.narrative_claims USING btree (provider_response_id) WHERE (provider_response_id IS NOT NULL);

CREATE UNIQUE INDEX panel_one_active_multiplication ON combat_panel_private.multiplication_formations USING btree (actor_id) WHERE (state = 'active'::text);

SET LOCAL ROLE "supabase_auth_admin";

REVOKE ALL ON TABLE "auth"."users" FROM PUBLIC,"anon","authenticated","dashboard_user","postgres","service_role","supabase_auth_admin";

RESET ROLE;

SET LOCAL ROLE "supabase_auth_admin";

GRANT INSERT ON TABLE "auth"."users" TO "supabase_auth_admin";

GRANT SELECT ON TABLE "auth"."users" TO "supabase_auth_admin";

GRANT UPDATE ON TABLE "auth"."users" TO "supabase_auth_admin";

GRANT DELETE ON TABLE "auth"."users" TO "supabase_auth_admin";

GRANT TRUNCATE ON TABLE "auth"."users" TO "supabase_auth_admin";

GRANT REFERENCES ON TABLE "auth"."users" TO "supabase_auth_admin";

GRANT TRIGGER ON TABLE "auth"."users" TO "supabase_auth_admin";

GRANT MAINTAIN ON TABLE "auth"."users" TO "supabase_auth_admin";

RESET ROLE;

SET LOCAL ROLE "supabase_auth_admin";

GRANT INSERT ON TABLE "auth"."users" TO "dashboard_user";

GRANT SELECT ON TABLE "auth"."users" TO "dashboard_user";

GRANT UPDATE ON TABLE "auth"."users" TO "dashboard_user";

GRANT DELETE ON TABLE "auth"."users" TO "dashboard_user";

GRANT TRUNCATE ON TABLE "auth"."users" TO "dashboard_user";

GRANT REFERENCES ON TABLE "auth"."users" TO "dashboard_user";

GRANT TRIGGER ON TABLE "auth"."users" TO "dashboard_user";

GRANT MAINTAIN ON TABLE "auth"."users" TO "dashboard_user";

RESET ROLE;

SET LOCAL ROLE "supabase_auth_admin";

GRANT INSERT ON TABLE "auth"."users" TO "postgres";

GRANT SELECT ON TABLE "auth"."users" TO "postgres" WITH GRANT OPTION;

GRANT UPDATE ON TABLE "auth"."users" TO "postgres";

GRANT DELETE ON TABLE "auth"."users" TO "postgres";

GRANT TRUNCATE ON TABLE "auth"."users" TO "postgres";

GRANT REFERENCES ON TABLE "auth"."users" TO "postgres";

GRANT TRIGGER ON TABLE "auth"."users" TO "postgres";

GRANT MAINTAIN ON TABLE "auth"."users" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "clan_marionettisti_private"."master_scene_claims" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "clan_marionettisti_private"."master_scene_claims" TO "postgres";

GRANT SELECT ON TABLE "clan_marionettisti_private"."master_scene_claims" TO "postgres";

GRANT UPDATE ON TABLE "clan_marionettisti_private"."master_scene_claims" TO "postgres";

GRANT DELETE ON TABLE "clan_marionettisti_private"."master_scene_claims" TO "postgres";

GRANT TRUNCATE ON TABLE "clan_marionettisti_private"."master_scene_claims" TO "postgres";

GRANT REFERENCES ON TABLE "clan_marionettisti_private"."master_scene_claims" TO "postgres";

GRANT TRIGGER ON TABLE "clan_marionettisti_private"."master_scene_claims" TO "postgres";

GRANT MAINTAIN ON TABLE "clan_marionettisti_private"."master_scene_claims" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "clan_marionettisti_private"."sources" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "clan_marionettisti_private"."sources" TO "postgres";

GRANT SELECT ON TABLE "clan_marionettisti_private"."sources" TO "postgres";

GRANT UPDATE ON TABLE "clan_marionettisti_private"."sources" TO "postgres";

GRANT DELETE ON TABLE "clan_marionettisti_private"."sources" TO "postgres";

GRANT TRUNCATE ON TABLE "clan_marionettisti_private"."sources" TO "postgres";

GRANT REFERENCES ON TABLE "clan_marionettisti_private"."sources" TO "postgres";

GRANT TRIGGER ON TABLE "clan_marionettisti_private"."sources" TO "postgres";

GRANT MAINTAIN ON TABLE "clan_marionettisti_private"."sources" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "combat_consumer_private"."activities" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "combat_consumer_private"."activities" TO "postgres";

GRANT SELECT ON TABLE "combat_consumer_private"."activities" TO "postgres";

GRANT UPDATE ON TABLE "combat_consumer_private"."activities" TO "postgres";

GRANT DELETE ON TABLE "combat_consumer_private"."activities" TO "postgres";

GRANT TRUNCATE ON TABLE "combat_consumer_private"."activities" TO "postgres";

GRANT REFERENCES ON TABLE "combat_consumer_private"."activities" TO "postgres";

GRANT TRIGGER ON TABLE "combat_consumer_private"."activities" TO "postgres";

GRANT MAINTAIN ON TABLE "combat_consumer_private"."activities" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "combat_consumer_private"."narrative_claims" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "combat_consumer_private"."narrative_claims" TO "postgres";

GRANT SELECT ON TABLE "combat_consumer_private"."narrative_claims" TO "postgres";

GRANT UPDATE ON TABLE "combat_consumer_private"."narrative_claims" TO "postgres";

GRANT DELETE ON TABLE "combat_consumer_private"."narrative_claims" TO "postgres";

GRANT TRUNCATE ON TABLE "combat_consumer_private"."narrative_claims" TO "postgres";

GRANT REFERENCES ON TABLE "combat_consumer_private"."narrative_claims" TO "postgres";

GRANT TRIGGER ON TABLE "combat_consumer_private"."narrative_claims" TO "postgres";

GRANT MAINTAIN ON TABLE "combat_consumer_private"."narrative_claims" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "combat_consumer_private"."scene_attempts_v2" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "combat_consumer_private"."scene_attempts_v2" TO "postgres";

GRANT SELECT ON TABLE "combat_consumer_private"."scene_attempts_v2" TO "postgres";

GRANT UPDATE ON TABLE "combat_consumer_private"."scene_attempts_v2" TO "postgres";

GRANT DELETE ON TABLE "combat_consumer_private"."scene_attempts_v2" TO "postgres";

GRANT TRUNCATE ON TABLE "combat_consumer_private"."scene_attempts_v2" TO "postgres";

GRANT REFERENCES ON TABLE "combat_consumer_private"."scene_attempts_v2" TO "postgres";

GRANT TRIGGER ON TABLE "combat_consumer_private"."scene_attempts_v2" TO "postgres";

GRANT MAINTAIN ON TABLE "combat_consumer_private"."scene_attempts_v2" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "combat_consumer_private"."scene_claims" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "combat_consumer_private"."scene_claims" TO "postgres";

GRANT SELECT ON TABLE "combat_consumer_private"."scene_claims" TO "postgres";

GRANT UPDATE ON TABLE "combat_consumer_private"."scene_claims" TO "postgres";

GRANT DELETE ON TABLE "combat_consumer_private"."scene_claims" TO "postgres";

GRANT TRUNCATE ON TABLE "combat_consumer_private"."scene_claims" TO "postgres";

GRANT REFERENCES ON TABLE "combat_consumer_private"."scene_claims" TO "postgres";

GRANT TRIGGER ON TABLE "combat_consumer_private"."scene_claims" TO "postgres";

GRANT MAINTAIN ON TABLE "combat_consumer_private"."scene_claims" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "combat_consumer_private"."scene_profiles" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "combat_consumer_private"."scene_profiles" TO "postgres";

GRANT SELECT ON TABLE "combat_consumer_private"."scene_profiles" TO "postgres";

GRANT UPDATE ON TABLE "combat_consumer_private"."scene_profiles" TO "postgres";

GRANT DELETE ON TABLE "combat_consumer_private"."scene_profiles" TO "postgres";

GRANT TRUNCATE ON TABLE "combat_consumer_private"."scene_profiles" TO "postgres";

GRANT REFERENCES ON TABLE "combat_consumer_private"."scene_profiles" TO "postgres";

GRANT TRIGGER ON TABLE "combat_consumer_private"."scene_profiles" TO "postgres";

GRANT MAINTAIN ON TABLE "combat_consumer_private"."scene_profiles" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "combat_panel_private"."master_scene_claims" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "combat_panel_private"."master_scene_claims" TO "postgres";

GRANT SELECT ON TABLE "combat_panel_private"."master_scene_claims" TO "postgres";

GRANT UPDATE ON TABLE "combat_panel_private"."master_scene_claims" TO "postgres";

GRANT DELETE ON TABLE "combat_panel_private"."master_scene_claims" TO "postgres";

GRANT TRUNCATE ON TABLE "combat_panel_private"."master_scene_claims" TO "postgres";

GRANT REFERENCES ON TABLE "combat_panel_private"."master_scene_claims" TO "postgres";

GRANT TRIGGER ON TABLE "combat_panel_private"."master_scene_claims" TO "postgres";

GRANT MAINTAIN ON TABLE "combat_panel_private"."master_scene_claims" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "combat_panel_private"."master_scene_profiles" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "combat_panel_private"."master_scene_profiles" TO "postgres";

GRANT SELECT ON TABLE "combat_panel_private"."master_scene_profiles" TO "postgres";

GRANT UPDATE ON TABLE "combat_panel_private"."master_scene_profiles" TO "postgres";

GRANT DELETE ON TABLE "combat_panel_private"."master_scene_profiles" TO "postgres";

GRANT TRUNCATE ON TABLE "combat_panel_private"."master_scene_profiles" TO "postgres";

GRANT REFERENCES ON TABLE "combat_panel_private"."master_scene_profiles" TO "postgres";

GRANT TRIGGER ON TABLE "combat_panel_private"."master_scene_profiles" TO "postgres";

GRANT MAINTAIN ON TABLE "combat_panel_private"."master_scene_profiles" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "combat_panel_private"."multiplication_formations" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "combat_panel_private"."multiplication_formations" TO "postgres";

GRANT SELECT ON TABLE "combat_panel_private"."multiplication_formations" TO "postgres";

GRANT UPDATE ON TABLE "combat_panel_private"."multiplication_formations" TO "postgres";

GRANT DELETE ON TABLE "combat_panel_private"."multiplication_formations" TO "postgres";

GRANT TRUNCATE ON TABLE "combat_panel_private"."multiplication_formations" TO "postgres";

GRANT REFERENCES ON TABLE "combat_panel_private"."multiplication_formations" TO "postgres";

GRANT TRIGGER ON TABLE "combat_panel_private"."multiplication_formations" TO "postgres";

GRANT MAINTAIN ON TABLE "combat_panel_private"."multiplication_formations" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "combat_panel_private"."multiplication_resolutions" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "combat_panel_private"."multiplication_resolutions" TO "postgres";

GRANT SELECT ON TABLE "combat_panel_private"."multiplication_resolutions" TO "postgres";

GRANT UPDATE ON TABLE "combat_panel_private"."multiplication_resolutions" TO "postgres";

GRANT DELETE ON TABLE "combat_panel_private"."multiplication_resolutions" TO "postgres";

GRANT TRUNCATE ON TABLE "combat_panel_private"."multiplication_resolutions" TO "postgres";

GRANT REFERENCES ON TABLE "combat_panel_private"."multiplication_resolutions" TO "postgres";

GRANT TRIGGER ON TABLE "combat_panel_private"."multiplication_resolutions" TO "postgres";

GRANT MAINTAIN ON TABLE "combat_panel_private"."multiplication_resolutions" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "combat_spatial"."arena_instances" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "combat_spatial"."arena_instances" TO "postgres";

GRANT SELECT ON TABLE "combat_spatial"."arena_instances" TO "postgres";

GRANT UPDATE ON TABLE "combat_spatial"."arena_instances" TO "postgres";

GRANT DELETE ON TABLE "combat_spatial"."arena_instances" TO "postgres";

GRANT TRUNCATE ON TABLE "combat_spatial"."arena_instances" TO "postgres";

GRANT REFERENCES ON TABLE "combat_spatial"."arena_instances" TO "postgres";

GRANT TRIGGER ON TABLE "combat_spatial"."arena_instances" TO "postgres";

GRANT MAINTAIN ON TABLE "combat_spatial"."arena_instances" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "combat_spatial"."arena_slots" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "combat_spatial"."arena_slots" TO "postgres";

GRANT SELECT ON TABLE "combat_spatial"."arena_slots" TO "postgres";

GRANT UPDATE ON TABLE "combat_spatial"."arena_slots" TO "postgres";

GRANT DELETE ON TABLE "combat_spatial"."arena_slots" TO "postgres";

GRANT TRUNCATE ON TABLE "combat_spatial"."arena_slots" TO "postgres";

GRANT REFERENCES ON TABLE "combat_spatial"."arena_slots" TO "postgres";

GRANT TRIGGER ON TABLE "combat_spatial"."arena_slots" TO "postgres";

GRANT MAINTAIN ON TABLE "combat_spatial"."arena_slots" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "combat_spatial"."arena_templates" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "combat_spatial"."arena_templates" TO "postgres";

GRANT SELECT ON TABLE "combat_spatial"."arena_templates" TO "postgres";

GRANT UPDATE ON TABLE "combat_spatial"."arena_templates" TO "postgres";

GRANT DELETE ON TABLE "combat_spatial"."arena_templates" TO "postgres";

GRANT TRUNCATE ON TABLE "combat_spatial"."arena_templates" TO "postgres";

GRANT REFERENCES ON TABLE "combat_spatial"."arena_templates" TO "postgres";

GRANT TRIGGER ON TABLE "combat_spatial"."arena_templates" TO "postgres";

GRANT MAINTAIN ON TABLE "combat_spatial"."arena_templates" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "combat_spatial"."mission_bindings" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "combat_spatial"."mission_bindings" TO "postgres";

GRANT SELECT ON TABLE "combat_spatial"."mission_bindings" TO "postgres";

GRANT UPDATE ON TABLE "combat_spatial"."mission_bindings" TO "postgres";

GRANT DELETE ON TABLE "combat_spatial"."mission_bindings" TO "postgres";

GRANT TRUNCATE ON TABLE "combat_spatial"."mission_bindings" TO "postgres";

GRANT REFERENCES ON TABLE "combat_spatial"."mission_bindings" TO "postgres";

GRANT TRIGGER ON TABLE "combat_spatial"."mission_bindings" TO "postgres";

GRANT MAINTAIN ON TABLE "combat_spatial"."mission_bindings" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "mission_ai_board_owner"."activations" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "mission_ai_board_owner"."activations" TO "postgres";

GRANT SELECT ON TABLE "mission_ai_board_owner"."activations" TO "postgres";

GRANT UPDATE ON TABLE "mission_ai_board_owner"."activations" TO "postgres";

GRANT DELETE ON TABLE "mission_ai_board_owner"."activations" TO "postgres";

GRANT TRUNCATE ON TABLE "mission_ai_board_owner"."activations" TO "postgres";

GRANT REFERENCES ON TABLE "mission_ai_board_owner"."activations" TO "postgres";

GRANT TRIGGER ON TABLE "mission_ai_board_owner"."activations" TO "postgres";

GRANT MAINTAIN ON TABLE "mission_ai_board_owner"."activations" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "mission_ai_service_owner"."capabilities" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "mission_ai_service_owner"."capabilities" TO "postgres";

GRANT SELECT ON TABLE "mission_ai_service_owner"."capabilities" TO "postgres";

GRANT UPDATE ON TABLE "mission_ai_service_owner"."capabilities" TO "postgres";

GRANT DELETE ON TABLE "mission_ai_service_owner"."capabilities" TO "postgres";

GRANT TRUNCATE ON TABLE "mission_ai_service_owner"."capabilities" TO "postgres";

GRANT REFERENCES ON TABLE "mission_ai_service_owner"."capabilities" TO "postgres";

GRANT TRIGGER ON TABLE "mission_ai_service_owner"."capabilities" TO "postgres";

GRANT MAINTAIN ON TABLE "mission_ai_service_owner"."capabilities" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT SELECT ON TABLE "mission_ai_service_owner"."capabilities" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "mission_ai_service_owner"."roster_profiles" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "mission_ai_service_owner"."roster_profiles" TO "postgres";

GRANT SELECT ON TABLE "mission_ai_service_owner"."roster_profiles" TO "postgres";

GRANT UPDATE ON TABLE "mission_ai_service_owner"."roster_profiles" TO "postgres";

GRANT DELETE ON TABLE "mission_ai_service_owner"."roster_profiles" TO "postgres";

GRANT TRUNCATE ON TABLE "mission_ai_service_owner"."roster_profiles" TO "postgres";

GRANT REFERENCES ON TABLE "mission_ai_service_owner"."roster_profiles" TO "postgres";

GRANT TRIGGER ON TABLE "mission_ai_service_owner"."roster_profiles" TO "postgres";

GRANT MAINTAIN ON TABLE "mission_ai_service_owner"."roster_profiles" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT SELECT ON TABLE "mission_ai_service_owner"."roster_profiles" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "mission_internal"."nb_mission_source_attestations" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "mission_internal"."nb_mission_source_attestations" TO "postgres";

GRANT SELECT ON TABLE "mission_internal"."nb_mission_source_attestations" TO "postgres";

GRANT UPDATE ON TABLE "mission_internal"."nb_mission_source_attestations" TO "postgres";

GRANT DELETE ON TABLE "mission_internal"."nb_mission_source_attestations" TO "postgres";

GRANT TRUNCATE ON TABLE "mission_internal"."nb_mission_source_attestations" TO "postgres";

GRANT REFERENCES ON TABLE "mission_internal"."nb_mission_source_attestations" TO "postgres";

GRANT TRIGGER ON TABLE "mission_internal"."nb_mission_source_attestations" TO "postgres";

GRANT MAINTAIN ON TABLE "mission_internal"."nb_mission_source_attestations" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "mission_internal"."ronda_runtime_bindings_v1" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "mission_internal"."ronda_runtime_bindings_v1" TO "postgres";

GRANT SELECT ON TABLE "mission_internal"."ronda_runtime_bindings_v1" TO "postgres";

GRANT UPDATE ON TABLE "mission_internal"."ronda_runtime_bindings_v1" TO "postgres";

GRANT DELETE ON TABLE "mission_internal"."ronda_runtime_bindings_v1" TO "postgres";

GRANT TRUNCATE ON TABLE "mission_internal"."ronda_runtime_bindings_v1" TO "postgres";

GRANT REFERENCES ON TABLE "mission_internal"."ronda_runtime_bindings_v1" TO "postgres";

GRANT TRIGGER ON TABLE "mission_internal"."ronda_runtime_bindings_v1" TO "postgres";

GRANT MAINTAIN ON TABLE "mission_internal"."ronda_runtime_bindings_v1" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."character_companions" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."character_companions" TO "postgres";

GRANT SELECT ON TABLE "public"."character_companions" TO "postgres";

GRANT UPDATE ON TABLE "public"."character_companions" TO "postgres";

GRANT DELETE ON TABLE "public"."character_companions" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."character_companions" TO "postgres";

GRANT REFERENCES ON TABLE "public"."character_companions" TO "postgres";

GRANT TRIGGER ON TABLE "public"."character_companions" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."character_companions" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."character_companions" TO "anon";

GRANT SELECT ON TABLE "public"."character_companions" TO "anon";

GRANT UPDATE ON TABLE "public"."character_companions" TO "anon";

GRANT DELETE ON TABLE "public"."character_companions" TO "anon";

GRANT TRUNCATE ON TABLE "public"."character_companions" TO "anon";

GRANT REFERENCES ON TABLE "public"."character_companions" TO "anon";

GRANT TRIGGER ON TABLE "public"."character_companions" TO "anon";

GRANT MAINTAIN ON TABLE "public"."character_companions" TO "anon";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."character_companions" TO "authenticated";

GRANT SELECT ON TABLE "public"."character_companions" TO "authenticated";

GRANT UPDATE ON TABLE "public"."character_companions" TO "authenticated";

GRANT DELETE ON TABLE "public"."character_companions" TO "authenticated";

GRANT TRUNCATE ON TABLE "public"."character_companions" TO "authenticated";

GRANT REFERENCES ON TABLE "public"."character_companions" TO "authenticated";

GRANT TRIGGER ON TABLE "public"."character_companions" TO "authenticated";

GRANT MAINTAIN ON TABLE "public"."character_companions" TO "authenticated";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."character_companions" TO "service_role";

GRANT SELECT ON TABLE "public"."character_companions" TO "service_role";

GRANT UPDATE ON TABLE "public"."character_companions" TO "service_role";

GRANT DELETE ON TABLE "public"."character_companions" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."character_companions" TO "service_role";

GRANT REFERENCES ON TABLE "public"."character_companions" TO "service_role";

GRANT TRIGGER ON TABLE "public"."character_companions" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."character_companions" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."characters" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."characters" TO "postgres";

GRANT SELECT ON TABLE "public"."characters" TO "postgres";

GRANT UPDATE ON TABLE "public"."characters" TO "postgres";

GRANT DELETE ON TABLE "public"."characters" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."characters" TO "postgres";

GRANT REFERENCES ON TABLE "public"."characters" TO "postgres";

GRANT TRIGGER ON TABLE "public"."characters" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."characters" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."characters" TO "anon";

GRANT SELECT ON TABLE "public"."characters" TO "anon";

GRANT UPDATE ON TABLE "public"."characters" TO "anon";

GRANT DELETE ON TABLE "public"."characters" TO "anon";

GRANT TRUNCATE ON TABLE "public"."characters" TO "anon";

GRANT REFERENCES ON TABLE "public"."characters" TO "anon";

GRANT TRIGGER ON TABLE "public"."characters" TO "anon";

GRANT MAINTAIN ON TABLE "public"."characters" TO "anon";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."characters" TO "authenticated";

GRANT SELECT ON TABLE "public"."characters" TO "authenticated";

GRANT UPDATE ON TABLE "public"."characters" TO "authenticated";

GRANT DELETE ON TABLE "public"."characters" TO "authenticated";

GRANT TRUNCATE ON TABLE "public"."characters" TO "authenticated";

GRANT REFERENCES ON TABLE "public"."characters" TO "authenticated";

GRANT TRIGGER ON TABLE "public"."characters" TO "authenticated";

GRANT MAINTAIN ON TABLE "public"."characters" TO "authenticated";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."characters" TO "service_role";

GRANT SELECT ON TABLE "public"."characters" TO "service_role";

GRANT UPDATE ON TABLE "public"."characters" TO "service_role";

GRANT DELETE ON TABLE "public"."characters" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."characters" TO "service_role";

GRANT REFERENCES ON TABLE "public"."characters" TO "service_role";

GRANT TRIGGER ON TABLE "public"."characters" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."characters" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."combat_v2_actors" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_actors" TO "postgres";

GRANT SELECT ON TABLE "public"."combat_v2_actors" TO "postgres";

GRANT UPDATE ON TABLE "public"."combat_v2_actors" TO "postgres";

GRANT DELETE ON TABLE "public"."combat_v2_actors" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."combat_v2_actors" TO "postgres";

GRANT REFERENCES ON TABLE "public"."combat_v2_actors" TO "postgres";

GRANT TRIGGER ON TABLE "public"."combat_v2_actors" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."combat_v2_actors" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_actors" TO "service_role";

GRANT SELECT ON TABLE "public"."combat_v2_actors" TO "service_role";

GRANT UPDATE ON TABLE "public"."combat_v2_actors" TO "service_role";

GRANT DELETE ON TABLE "public"."combat_v2_actors" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."combat_v2_actors" TO "service_role";

GRANT REFERENCES ON TABLE "public"."combat_v2_actors" TO "service_role";

GRANT TRIGGER ON TABLE "public"."combat_v2_actors" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."combat_v2_actors" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."combat_v2_attack_targets" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_attack_targets" TO "postgres";

GRANT SELECT ON TABLE "public"."combat_v2_attack_targets" TO "postgres";

GRANT UPDATE ON TABLE "public"."combat_v2_attack_targets" TO "postgres";

GRANT DELETE ON TABLE "public"."combat_v2_attack_targets" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."combat_v2_attack_targets" TO "postgres";

GRANT REFERENCES ON TABLE "public"."combat_v2_attack_targets" TO "postgres";

GRANT TRIGGER ON TABLE "public"."combat_v2_attack_targets" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."combat_v2_attack_targets" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_attack_targets" TO "service_role";

GRANT SELECT ON TABLE "public"."combat_v2_attack_targets" TO "service_role";

GRANT UPDATE ON TABLE "public"."combat_v2_attack_targets" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."combat_v2_declarations" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_declarations" TO "postgres";

GRANT SELECT ON TABLE "public"."combat_v2_declarations" TO "postgres";

GRANT UPDATE ON TABLE "public"."combat_v2_declarations" TO "postgres";

GRANT DELETE ON TABLE "public"."combat_v2_declarations" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."combat_v2_declarations" TO "postgres";

GRANT REFERENCES ON TABLE "public"."combat_v2_declarations" TO "postgres";

GRANT TRIGGER ON TABLE "public"."combat_v2_declarations" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."combat_v2_declarations" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_declarations" TO "service_role";

GRANT SELECT ON TABLE "public"."combat_v2_declarations" TO "service_role";

GRANT UPDATE ON TABLE "public"."combat_v2_declarations" TO "service_role";

GRANT DELETE ON TABLE "public"."combat_v2_declarations" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."combat_v2_declarations" TO "service_role";

GRANT REFERENCES ON TABLE "public"."combat_v2_declarations" TO "service_role";

GRANT TRIGGER ON TABLE "public"."combat_v2_declarations" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."combat_v2_declarations" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."combat_v2_events" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_events" TO "postgres";

GRANT SELECT ON TABLE "public"."combat_v2_events" TO "postgres";

GRANT UPDATE ON TABLE "public"."combat_v2_events" TO "postgres";

GRANT DELETE ON TABLE "public"."combat_v2_events" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."combat_v2_events" TO "postgres";

GRANT REFERENCES ON TABLE "public"."combat_v2_events" TO "postgres";

GRANT TRIGGER ON TABLE "public"."combat_v2_events" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."combat_v2_events" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_events" TO "service_role";

GRANT SELECT ON TABLE "public"."combat_v2_events" TO "service_role";

GRANT UPDATE ON TABLE "public"."combat_v2_events" TO "service_role";

GRANT DELETE ON TABLE "public"."combat_v2_events" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."combat_v2_events" TO "service_role";

GRANT REFERENCES ON TABLE "public"."combat_v2_events" TO "service_role";

GRANT TRIGGER ON TABLE "public"."combat_v2_events" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."combat_v2_events" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."combat_v2_png_instances" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_png_instances" TO "postgres";

GRANT SELECT ON TABLE "public"."combat_v2_png_instances" TO "postgres";

GRANT UPDATE ON TABLE "public"."combat_v2_png_instances" TO "postgres";

GRANT DELETE ON TABLE "public"."combat_v2_png_instances" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."combat_v2_png_instances" TO "postgres";

GRANT REFERENCES ON TABLE "public"."combat_v2_png_instances" TO "postgres";

GRANT TRIGGER ON TABLE "public"."combat_v2_png_instances" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."combat_v2_png_instances" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_png_instances" TO "service_role";

GRANT SELECT ON TABLE "public"."combat_v2_png_instances" TO "service_role";

GRANT UPDATE ON TABLE "public"."combat_v2_png_instances" TO "service_role";

GRANT DELETE ON TABLE "public"."combat_v2_png_instances" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."combat_v2_png_instances" TO "service_role";

GRANT REFERENCES ON TABLE "public"."combat_v2_png_instances" TO "service_role";

GRANT TRIGGER ON TABLE "public"."combat_v2_png_instances" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."combat_v2_png_instances" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."combat_v2_provider_instances_v1" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_provider_instances_v1" TO "postgres";

GRANT SELECT ON TABLE "public"."combat_v2_provider_instances_v1" TO "postgres";

GRANT UPDATE ON TABLE "public"."combat_v2_provider_instances_v1" TO "postgres";

GRANT DELETE ON TABLE "public"."combat_v2_provider_instances_v1" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."combat_v2_provider_instances_v1" TO "postgres";

GRANT REFERENCES ON TABLE "public"."combat_v2_provider_instances_v1" TO "postgres";

GRANT TRIGGER ON TABLE "public"."combat_v2_provider_instances_v1" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."combat_v2_provider_instances_v1" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."combat_v2_round_reports" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_round_reports" TO "postgres";

GRANT SELECT ON TABLE "public"."combat_v2_round_reports" TO "postgres";

GRANT UPDATE ON TABLE "public"."combat_v2_round_reports" TO "postgres";

GRANT DELETE ON TABLE "public"."combat_v2_round_reports" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."combat_v2_round_reports" TO "postgres";

GRANT REFERENCES ON TABLE "public"."combat_v2_round_reports" TO "postgres";

GRANT TRIGGER ON TABLE "public"."combat_v2_round_reports" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."combat_v2_round_reports" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_round_reports" TO "service_role";

GRANT SELECT ON TABLE "public"."combat_v2_round_reports" TO "service_role";

GRANT UPDATE ON TABLE "public"."combat_v2_round_reports" TO "service_role";

GRANT DELETE ON TABLE "public"."combat_v2_round_reports" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."combat_v2_round_reports" TO "service_role";

GRANT REFERENCES ON TABLE "public"."combat_v2_round_reports" TO "service_role";

GRANT TRIGGER ON TABLE "public"."combat_v2_round_reports" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."combat_v2_round_reports" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."combat_v2_rounds" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_rounds" TO "postgres";

GRANT SELECT ON TABLE "public"."combat_v2_rounds" TO "postgres";

GRANT UPDATE ON TABLE "public"."combat_v2_rounds" TO "postgres";

GRANT DELETE ON TABLE "public"."combat_v2_rounds" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."combat_v2_rounds" TO "postgres";

GRANT REFERENCES ON TABLE "public"."combat_v2_rounds" TO "postgres";

GRANT TRIGGER ON TABLE "public"."combat_v2_rounds" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."combat_v2_rounds" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_rounds" TO "service_role";

GRANT SELECT ON TABLE "public"."combat_v2_rounds" TO "service_role";

GRANT UPDATE ON TABLE "public"."combat_v2_rounds" TO "service_role";

GRANT DELETE ON TABLE "public"."combat_v2_rounds" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."combat_v2_rounds" TO "service_role";

GRANT REFERENCES ON TABLE "public"."combat_v2_rounds" TO "service_role";

GRANT TRIGGER ON TABLE "public"."combat_v2_rounds" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."combat_v2_rounds" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."combat_v2_sessions" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_sessions" TO "postgres";

GRANT SELECT ON TABLE "public"."combat_v2_sessions" TO "postgres";

GRANT UPDATE ON TABLE "public"."combat_v2_sessions" TO "postgres";

GRANT DELETE ON TABLE "public"."combat_v2_sessions" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."combat_v2_sessions" TO "postgres";

GRANT REFERENCES ON TABLE "public"."combat_v2_sessions" TO "postgres";

GRANT TRIGGER ON TABLE "public"."combat_v2_sessions" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."combat_v2_sessions" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."combat_v2_sessions" TO "service_role";

GRANT SELECT ON TABLE "public"."combat_v2_sessions" TO "service_role";

GRANT UPDATE ON TABLE "public"."combat_v2_sessions" TO "service_role";

GRANT DELETE ON TABLE "public"."combat_v2_sessions" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."combat_v2_sessions" TO "service_role";

GRANT REFERENCES ON TABLE "public"."combat_v2_sessions" TO "service_role";

GRANT TRIGGER ON TABLE "public"."combat_v2_sessions" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."combat_v2_sessions" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."locations" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."locations" TO "postgres";

GRANT SELECT ON TABLE "public"."locations" TO "postgres";

GRANT UPDATE ON TABLE "public"."locations" TO "postgres";

GRANT DELETE ON TABLE "public"."locations" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."locations" TO "postgres";

GRANT REFERENCES ON TABLE "public"."locations" TO "postgres";

GRANT TRIGGER ON TABLE "public"."locations" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."locations" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."locations" TO "anon";

GRANT SELECT ON TABLE "public"."locations" TO "anon";

GRANT UPDATE ON TABLE "public"."locations" TO "anon";

GRANT DELETE ON TABLE "public"."locations" TO "anon";

GRANT TRUNCATE ON TABLE "public"."locations" TO "anon";

GRANT REFERENCES ON TABLE "public"."locations" TO "anon";

GRANT TRIGGER ON TABLE "public"."locations" TO "anon";

GRANT MAINTAIN ON TABLE "public"."locations" TO "anon";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."locations" TO "authenticated";

GRANT SELECT ON TABLE "public"."locations" TO "authenticated";

GRANT UPDATE ON TABLE "public"."locations" TO "authenticated";

GRANT DELETE ON TABLE "public"."locations" TO "authenticated";

GRANT TRUNCATE ON TABLE "public"."locations" TO "authenticated";

GRANT REFERENCES ON TABLE "public"."locations" TO "authenticated";

GRANT TRIGGER ON TABLE "public"."locations" TO "authenticated";

GRANT MAINTAIN ON TABLE "public"."locations" TO "authenticated";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."locations" TO "service_role";

GRANT SELECT ON TABLE "public"."locations" TO "service_role";

GRANT UPDATE ON TABLE "public"."locations" TO "service_role";

GRANT DELETE ON TABLE "public"."locations" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."locations" TO "service_role";

GRANT REFERENCES ON TABLE "public"."locations" TO "service_role";

GRANT TRIGGER ON TABLE "public"."locations" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."locations" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."master_v2_nb_actor_offers_v1" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."master_v2_nb_actor_offers_v1" TO "postgres";

GRANT SELECT ON TABLE "public"."master_v2_nb_actor_offers_v1" TO "postgres";

GRANT UPDATE ON TABLE "public"."master_v2_nb_actor_offers_v1" TO "postgres";

GRANT DELETE ON TABLE "public"."master_v2_nb_actor_offers_v1" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."master_v2_nb_actor_offers_v1" TO "postgres";

GRANT REFERENCES ON TABLE "public"."master_v2_nb_actor_offers_v1" TO "postgres";

GRANT TRIGGER ON TABLE "public"."master_v2_nb_actor_offers_v1" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."master_v2_nb_actor_offers_v1" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."master_v2_sessions" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."master_v2_sessions" TO "postgres";

GRANT SELECT ON TABLE "public"."master_v2_sessions" TO "postgres";

GRANT UPDATE ON TABLE "public"."master_v2_sessions" TO "postgres";

GRANT DELETE ON TABLE "public"."master_v2_sessions" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."master_v2_sessions" TO "postgres";

GRANT REFERENCES ON TABLE "public"."master_v2_sessions" TO "postgres";

GRANT TRIGGER ON TABLE "public"."master_v2_sessions" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."master_v2_sessions" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."master_v2_sessions" TO "service_role";

GRANT SELECT ON TABLE "public"."master_v2_sessions" TO "service_role";

GRANT UPDATE ON TABLE "public"."master_v2_sessions" TO "service_role";

GRANT DELETE ON TABLE "public"."master_v2_sessions" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."master_v2_sessions" TO "service_role";

GRANT REFERENCES ON TABLE "public"."master_v2_sessions" TO "service_role";

GRANT TRIGGER ON TABLE "public"."master_v2_sessions" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."master_v2_sessions" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."messages" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."messages" TO "postgres";

GRANT SELECT ON TABLE "public"."messages" TO "postgres";

GRANT UPDATE ON TABLE "public"."messages" TO "postgres";

GRANT DELETE ON TABLE "public"."messages" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."messages" TO "postgres";

GRANT REFERENCES ON TABLE "public"."messages" TO "postgres";

GRANT TRIGGER ON TABLE "public"."messages" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."messages" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."messages" TO "anon";

GRANT SELECT ON TABLE "public"."messages" TO "anon";

GRANT UPDATE ON TABLE "public"."messages" TO "anon";

GRANT DELETE ON TABLE "public"."messages" TO "anon";

GRANT TRUNCATE ON TABLE "public"."messages" TO "anon";

GRANT REFERENCES ON TABLE "public"."messages" TO "anon";

GRANT TRIGGER ON TABLE "public"."messages" TO "anon";

GRANT MAINTAIN ON TABLE "public"."messages" TO "anon";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."messages" TO "authenticated";

GRANT SELECT ON TABLE "public"."messages" TO "authenticated";

GRANT UPDATE ON TABLE "public"."messages" TO "authenticated";

GRANT DELETE ON TABLE "public"."messages" TO "authenticated";

GRANT TRUNCATE ON TABLE "public"."messages" TO "authenticated";

GRANT REFERENCES ON TABLE "public"."messages" TO "authenticated";

GRANT TRIGGER ON TABLE "public"."messages" TO "authenticated";

GRANT MAINTAIN ON TABLE "public"."messages" TO "authenticated";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."messages" TO "service_role";

GRANT SELECT ON TABLE "public"."messages" TO "service_role";

GRANT UPDATE ON TABLE "public"."messages" TO "service_role";

GRANT DELETE ON TABLE "public"."messages" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."messages" TO "service_role";

GRANT REFERENCES ON TABLE "public"."messages" TO "service_role";

GRANT TRIGGER ON TABLE "public"."messages" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."messages" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."mission_plan_versions" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."mission_plan_versions" TO "postgres";

GRANT SELECT ON TABLE "public"."mission_plan_versions" TO "postgres";

GRANT UPDATE ON TABLE "public"."mission_plan_versions" TO "postgres";

GRANT DELETE ON TABLE "public"."mission_plan_versions" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."mission_plan_versions" TO "postgres";

GRANT REFERENCES ON TABLE "public"."mission_plan_versions" TO "postgres";

GRANT TRIGGER ON TABLE "public"."mission_plan_versions" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."mission_plan_versions" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."mission_plans" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."mission_plans" TO "postgres";

GRANT SELECT ON TABLE "public"."mission_plans" TO "postgres";

GRANT UPDATE ON TABLE "public"."mission_plans" TO "postgres";

GRANT DELETE ON TABLE "public"."mission_plans" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."mission_plans" TO "postgres";

GRANT REFERENCES ON TABLE "public"."mission_plans" TO "postgres";

GRANT TRIGGER ON TABLE "public"."mission_plans" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."mission_plans" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."missions" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."missions" TO "postgres";

GRANT SELECT ON TABLE "public"."missions" TO "postgres";

GRANT UPDATE ON TABLE "public"."missions" TO "postgres";

GRANT DELETE ON TABLE "public"."missions" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."missions" TO "postgres";

GRANT REFERENCES ON TABLE "public"."missions" TO "postgres";

GRANT TRIGGER ON TABLE "public"."missions" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."missions" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."missions" TO "anon";

GRANT SELECT ON TABLE "public"."missions" TO "anon";

GRANT UPDATE ON TABLE "public"."missions" TO "anon";

GRANT DELETE ON TABLE "public"."missions" TO "anon";

GRANT TRUNCATE ON TABLE "public"."missions" TO "anon";

GRANT REFERENCES ON TABLE "public"."missions" TO "anon";

GRANT TRIGGER ON TABLE "public"."missions" TO "anon";

GRANT MAINTAIN ON TABLE "public"."missions" TO "anon";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."missions" TO "authenticated";

GRANT SELECT ON TABLE "public"."missions" TO "authenticated";

GRANT UPDATE ON TABLE "public"."missions" TO "authenticated";

GRANT DELETE ON TABLE "public"."missions" TO "authenticated";

GRANT TRUNCATE ON TABLE "public"."missions" TO "authenticated";

GRANT REFERENCES ON TABLE "public"."missions" TO "authenticated";

GRANT TRIGGER ON TABLE "public"."missions" TO "authenticated";

GRANT MAINTAIN ON TABLE "public"."missions" TO "authenticated";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."missions" TO "service_role";

GRANT SELECT ON TABLE "public"."missions" TO "service_role";

GRANT UPDATE ON TABLE "public"."missions" TO "service_role";

GRANT DELETE ON TABLE "public"."missions" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."missions" TO "service_role";

GRANT REFERENCES ON TABLE "public"."missions" TO "service_role";

GRANT TRIGGER ON TABLE "public"."missions" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."missions" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."nb_mechanical_templates" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."nb_mechanical_templates" TO "postgres";

GRANT SELECT ON TABLE "public"."nb_mechanical_templates" TO "postgres";

GRANT UPDATE ON TABLE "public"."nb_mechanical_templates" TO "postgres";

GRANT DELETE ON TABLE "public"."nb_mechanical_templates" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."nb_mechanical_templates" TO "postgres";

GRANT REFERENCES ON TABLE "public"."nb_mechanical_templates" TO "postgres";

GRANT TRIGGER ON TABLE "public"."nb_mechanical_templates" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."nb_mechanical_templates" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."nb_mechanical_versions" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."nb_mechanical_versions" TO "postgres";

GRANT SELECT ON TABLE "public"."nb_mechanical_versions" TO "postgres";

GRANT UPDATE ON TABLE "public"."nb_mechanical_versions" TO "postgres";

GRANT DELETE ON TABLE "public"."nb_mechanical_versions" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."nb_mechanical_versions" TO "postgres";

GRANT REFERENCES ON TABLE "public"."nb_mechanical_versions" TO "postgres";

GRANT TRIGGER ON TABLE "public"."nb_mechanical_versions" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."nb_mechanical_versions" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."nb_mission_packages" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."nb_mission_packages" TO "postgres";

GRANT SELECT ON TABLE "public"."nb_mission_packages" TO "postgres";

GRANT UPDATE ON TABLE "public"."nb_mission_packages" TO "postgres";

GRANT DELETE ON TABLE "public"."nb_mission_packages" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."nb_mission_packages" TO "postgres";

GRANT REFERENCES ON TABLE "public"."nb_mission_packages" TO "postgres";

GRANT TRIGGER ON TABLE "public"."nb_mission_packages" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."nb_mission_packages" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."nb_template_versions" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."nb_template_versions" TO "postgres";

GRANT SELECT ON TABLE "public"."nb_template_versions" TO "postgres";

GRANT UPDATE ON TABLE "public"."nb_template_versions" TO "postgres";

GRANT DELETE ON TABLE "public"."nb_template_versions" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."nb_template_versions" TO "postgres";

GRANT REFERENCES ON TABLE "public"."nb_template_versions" TO "postgres";

GRANT TRIGGER ON TABLE "public"."nb_template_versions" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."nb_template_versions" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."nb_templates" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."nb_templates" TO "postgres";

GRANT SELECT ON TABLE "public"."nb_templates" TO "postgres";

GRANT UPDATE ON TABLE "public"."nb_templates" TO "postgres";

GRANT DELETE ON TABLE "public"."nb_templates" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."nb_templates" TO "postgres";

GRANT REFERENCES ON TABLE "public"."nb_templates" TO "postgres";

GRANT TRIGGER ON TABLE "public"."nb_templates" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."nb_templates" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."png_templates" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."png_templates" TO "postgres";

GRANT SELECT ON TABLE "public"."png_templates" TO "postgres";

GRANT UPDATE ON TABLE "public"."png_templates" TO "postgres";

GRANT DELETE ON TABLE "public"."png_templates" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."png_templates" TO "postgres";

GRANT REFERENCES ON TABLE "public"."png_templates" TO "postgres";

GRANT TRIGGER ON TABLE "public"."png_templates" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."png_templates" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."png_templates" TO "anon";

GRANT SELECT ON TABLE "public"."png_templates" TO "anon";

GRANT UPDATE ON TABLE "public"."png_templates" TO "anon";

GRANT DELETE ON TABLE "public"."png_templates" TO "anon";

GRANT TRUNCATE ON TABLE "public"."png_templates" TO "anon";

GRANT REFERENCES ON TABLE "public"."png_templates" TO "anon";

GRANT TRIGGER ON TABLE "public"."png_templates" TO "anon";

GRANT MAINTAIN ON TABLE "public"."png_templates" TO "anon";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."png_templates" TO "authenticated";

GRANT SELECT ON TABLE "public"."png_templates" TO "authenticated";

GRANT UPDATE ON TABLE "public"."png_templates" TO "authenticated";

GRANT DELETE ON TABLE "public"."png_templates" TO "authenticated";

GRANT TRUNCATE ON TABLE "public"."png_templates" TO "authenticated";

GRANT REFERENCES ON TABLE "public"."png_templates" TO "authenticated";

GRANT TRIGGER ON TABLE "public"."png_templates" TO "authenticated";

GRANT MAINTAIN ON TABLE "public"."png_templates" TO "authenticated";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."png_templates" TO "service_role";

GRANT SELECT ON TABLE "public"."png_templates" TO "service_role";

GRANT UPDATE ON TABLE "public"."png_templates" TO "service_role";

GRANT DELETE ON TABLE "public"."png_templates" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."png_templates" TO "service_role";

GRANT REFERENCES ON TABLE "public"."png_templates" TO "service_role";

GRANT TRIGGER ON TABLE "public"."png_templates" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."png_templates" TO "service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

REVOKE ALL ON TABLE "public"."profiles" FROM PUBLIC,"anon","authenticated","postgres","service_role";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."profiles" TO "postgres";

GRANT SELECT ON TABLE "public"."profiles" TO "postgres";

GRANT UPDATE ON TABLE "public"."profiles" TO "postgres";

GRANT DELETE ON TABLE "public"."profiles" TO "postgres";

GRANT TRUNCATE ON TABLE "public"."profiles" TO "postgres";

GRANT REFERENCES ON TABLE "public"."profiles" TO "postgres";

GRANT TRIGGER ON TABLE "public"."profiles" TO "postgres";

GRANT MAINTAIN ON TABLE "public"."profiles" TO "postgres";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."profiles" TO "anon";

GRANT SELECT ON TABLE "public"."profiles" TO "anon";

GRANT UPDATE ON TABLE "public"."profiles" TO "anon";

GRANT DELETE ON TABLE "public"."profiles" TO "anon";

GRANT TRUNCATE ON TABLE "public"."profiles" TO "anon";

GRANT REFERENCES ON TABLE "public"."profiles" TO "anon";

GRANT TRIGGER ON TABLE "public"."profiles" TO "anon";

GRANT MAINTAIN ON TABLE "public"."profiles" TO "anon";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."profiles" TO "authenticated";

GRANT SELECT ON TABLE "public"."profiles" TO "authenticated";

GRANT UPDATE ON TABLE "public"."profiles" TO "authenticated";

GRANT DELETE ON TABLE "public"."profiles" TO "authenticated";

GRANT TRUNCATE ON TABLE "public"."profiles" TO "authenticated";

GRANT REFERENCES ON TABLE "public"."profiles" TO "authenticated";

GRANT TRIGGER ON TABLE "public"."profiles" TO "authenticated";

GRANT MAINTAIN ON TABLE "public"."profiles" TO "authenticated";

RESET ROLE;

SET LOCAL ROLE "postgres";

GRANT INSERT ON TABLE "public"."profiles" TO "service_role";

GRANT SELECT ON TABLE "public"."profiles" TO "service_role";

GRANT UPDATE ON TABLE "public"."profiles" TO "service_role";

GRANT DELETE ON TABLE "public"."profiles" TO "service_role";

GRANT TRUNCATE ON TABLE "public"."profiles" TO "service_role";

GRANT REFERENCES ON TABLE "public"."profiles" TO "service_role";

GRANT TRIGGER ON TABLE "public"."profiles" TO "service_role";

GRANT MAINTAIN ON TABLE "public"."profiles" TO "service_role";

RESET ROLE;

CREATE TRIGGER combat_v2_declarations_multitarget_sync AFTER INSERT ON combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_v2_multitarget_internal.sync_declaration();

CREATE TRIGGER marionetta_command_window AFTER INSERT OR UPDATE OF phase ON combat_v2_rounds FOR EACH ROW EXECUTE FUNCTION clan_marionettisti_private.round_window_trigger();

CREATE TRIGGER marionetta_terminal_event AFTER UPDATE OF state ON combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_marionettisti_private.declaration_terminal_trigger();

CREATE TRIGGER panel_declaration_ready BEFORE INSERT OR UPDATE OF round_id, actor_id, kind ON combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_entry_trigger();

CREATE TRIGGER panel_actor_turn_round AFTER INSERT OR UPDATE OF phase ON combat_v2_rounds FOR EACH ROW EXECUTE FUNCTION combat_panel_private.actor_turn_lifecycle();

CREATE TRIGGER panel_actor_turn_declaration AFTER INSERT OR UPDATE OF state ON combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.actor_turn_lifecycle();

CREATE TRIGGER sabaku_master_main BEFORE INSERT ON combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.master_turn_lifecycle();

CREATE TRIGGER panel_multiplication_identity BEFORE INSERT OR UPDATE ON combat_panel_private.multiplication_formations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_state_guard();

CREATE TRIGGER panel_multiplication_next_action BEFORE INSERT ON combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_next_action();

CREATE TRIGGER panel_multiplication_assault_end AFTER UPDATE OF state ON combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_assault_end();

CREATE TRIGGER panel_multiplication_resolution_immutable BEFORE DELETE OR UPDATE ON combat_panel_private.multiplication_resolutions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_selection_immutable();

CREATE TRIGGER panel_immobilization_attack AFTER INSERT OR UPDATE OF state, outcome ON combat_v2_attack_targets FOR EACH ROW EXECUTE FUNCTION combat_panel_private.immobilization_attack_trigger();

CREATE TRIGGER sabaku_clone_round_end AFTER UPDATE OF phase ON combat_v2_rounds FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.clone_lifecycle_trigger();

CREATE TRIGGER sabaku_clone_formation_created AFTER INSERT ON combat_panel_private.multiplication_formations FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.clone_formation_trigger();

CREATE TRIGGER recovery_parent_immutable BEFORE DELETE OR UPDATE ON combat_consumer_private.narrative_claims FOR EACH ROW EXECUTE FUNCTION combat_consumer_private.recovery_preserve_parent_v1();

COMMIT;
