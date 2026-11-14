BEGIN;

CREATE FUNCTION combat_panel_private.shuriken_qa_location_v1() RETURNS uuid
LANGUAGE sql IMMUTABLE SET search_path TO ''
AS $body$ SELECT '57cbcb2f-49c0-4b3a-bb52-28f9db04eccb'::uuid $body$;

CREATE FUNCTION combat_panel_private.shuriken_qa_can_read_v1(p_location uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO ''
AS $body$
  SELECT p_location IS DISTINCT FROM combat_panel_private.shuriken_qa_location_v1()
    OR EXISTS (
      SELECT 1 FROM public.characters c
      WHERE c.user_id=auth.uid() AND c.id IN (
        '2a877f02-4993-4e65-9172-7d29f08c5b86','6bceee99-974f-426b-8d92-38b43b4a4267'
      )
    )
$body$;

REVOKE ALL ON FUNCTION combat_panel_private.shuriken_qa_location_v1() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_qa_can_read_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.shuriken_qa_can_read_v1(uuid) TO authenticated,anon;

CREATE POLICY shuriken_qa_location_reserve ON public.locations AS RESTRICTIVE
  FOR SELECT TO authenticated,anon USING (combat_panel_private.shuriken_qa_can_read_v1(id));
CREATE POLICY shuriken_qa_messages_reserve ON public.messages AS RESTRICTIVE
  FOR SELECT TO authenticated,anon USING (combat_panel_private.shuriken_qa_can_read_v1(location_id));
CREATE POLICY shuriken_qa_archive_reserve ON public.messages_archive AS RESTRICTIVE
  FOR SELECT TO authenticated,anon USING (combat_panel_private.shuriken_qa_can_read_v1(location_id));
CREATE POLICY shuriken_qa_presence_reserve ON public.presence AS RESTRICTIVE
  FOR SELECT TO authenticated,anon USING (combat_panel_private.shuriken_qa_can_read_v1(location_id));
CREATE POLICY shuriken_qa_presence_events_reserve ON public.presence_events AS RESTRICTIVE
  FOR SELECT TO authenticated,anon USING (combat_panel_private.shuriken_qa_can_read_v1(location_id));

-- The room is never a source of recorded roles, legacy fights or Master/mission scenes.
CREATE FUNCTION combat_panel_private.shuriken_qa_reject_other_scene_v1() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $body$
BEGIN
  IF NEW.location_id=combat_panel_private.shuriken_qa_location_v1() THEN
    RAISE EXCEPTION 'shuriken_qa_ordinary_duel_only' USING ERRCODE='42501';
  END IF;
  RETURN NEW;
END
$body$;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_qa_reject_other_scene_v1() FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER shuriken_qa_no_recorded_role BEFORE INSERT OR UPDATE OF location_id ON public.role_sessions
  FOR EACH ROW EXECUTE FUNCTION combat_panel_private.shuriken_qa_reject_other_scene_v1();
CREATE TRIGGER shuriken_qa_no_master_scene BEFORE INSERT OR UPDATE OF location_id ON public.master_v2_sessions
  FOR EACH ROW EXECUTE FUNCTION combat_panel_private.shuriken_qa_reject_other_scene_v1();
CREATE TRIGGER shuriken_qa_no_legacy_scene BEFORE INSERT OR UPDATE OF location_id ON public.combat_sessions
  FOR EACH ROW EXECUTE FUNCTION combat_panel_private.shuriken_qa_reject_other_scene_v1();

-- Only this PG may debit its inventory, and only for the scoped Shuriken declaration.
-- The session gate also blocks non-panel routes to the native action/defense resolver.
CREATE FUNCTION combat_panel_private.shuriken_qa_declaration_scope_v1(
  p_session uuid, p_actor uuid, p_kind text, p_intent jsonb
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $body$
BEGIN
  IF EXISTS (SELECT 1 FROM public.combat_v2_sessions s WHERE s.id=p_session
    AND s.location_id=combat_panel_private.shuriken_qa_location_v1()) AND NOT EXISTS (
    SELECT 1 FROM public.combat_v2_sessions s
    JOIN public.combat_v2_actors a ON a.session_id=s.id AND a.id=p_actor
    JOIN public.characters c ON c.id=a.character_id AND c.user_id=auth.uid() AND c.is_test
    JOIN combat_consumer_private.activities act ON act.session_id=s.id
      AND act.location_id=s.location_id AND act.phase='action' AND act.turn_actor_id=a.id
    WHERE s.id=p_session AND s.source_kind='ordinary' AND s.lesiva IS FALSE
      AND (
        SELECT count(*) FROM public.combat_v2_actors roster
        WHERE roster.session_id=s.id AND roster.actor_kind='pg' AND roster.character_id IN (
          '2a877f02-4993-4e65-9172-7d29f08c5b86','6bceee99-974f-426b-8d92-38b43b4a4267'
        )
      )=2
      AND (SELECT count(*) FROM public.combat_v2_actors roster WHERE roster.session_id=s.id)=2
      AND a.character_id='2a877f02-4993-4e65-9172-7d29f08c5b86' 
      AND p_kind='attacco' AND p_intent->>'ability_source'='arma'
      AND p_intent->>'ability_id'=combat_panel_private.shuriken_profile_v1()->>'id'
  ) THEN
    RAISE EXCEPTION 'shuriken_qa_only_test_character_attack' USING ERRCODE='42501';
  END IF;
END
$body$;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_qa_declaration_scope_v1(uuid,uuid,text,jsonb) FROM PUBLIC,anon,authenticated,service_role;

CREATE FUNCTION combat_panel_private.shuriken_qa_declaration_guard_v1() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $body$
BEGIN
  PERFORM combat_panel_private.shuriken_qa_declaration_scope_v1(
    (SELECT r.session_id FROM public.combat_v2_rounds r WHERE r.id=NEW.round_id),
    NEW.actor_id,NEW.kind,NEW.sanitized_intent
  );
  RETURN NEW;
END
$body$;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_qa_declaration_guard_v1() FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER shuriken_qa_declaration_guard BEFORE INSERT ON public.combat_v2_declarations
  FOR EACH ROW EXECUTE FUNCTION combat_panel_private.shuriken_qa_declaration_guard_v1();

CREATE TABLE combat_panel_private.shuriken_qa_message_permits_v1 (
  message_id uuid PRIMARY KEY,
  transaction_id bigint NOT NULL
);
ALTER TABLE combat_panel_private.shuriken_qa_message_permits_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON combat_panel_private.shuriken_qa_message_permits_v1 FROM PUBLIC,anon,authenticated,service_role;

CREATE FUNCTION combat_panel_private.shuriken_qa_message_guard_v1() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $body$
BEGIN
  IF NEW.location_id=combat_panel_private.shuriken_qa_location_v1()
    AND NOT EXISTS (
      SELECT 1 FROM combat_panel_private.shuriken_qa_message_permits_v1 p
      WHERE p.message_id=NEW.id AND p.transaction_id=txid_current()
    ) THEN
    RAISE EXCEPTION 'shuriken_qa_messages_reserved' USING ERRCODE='42501';
  END IF;
  RETURN NEW;
END
$body$;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_qa_message_guard_v1() FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER shuriken_qa_message_guard BEFORE INSERT ON public.messages
  FOR EACH ROW EXECUTE FUNCTION combat_panel_private.shuriken_qa_message_guard_v1();

CREATE FUNCTION combat_panel_private.shuriken_qa_presence_guard_v1() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $body$
BEGIN
  IF NEW.location_id=combat_panel_private.shuriken_qa_location_v1()
     AND (NEW.user_id IS DISTINCT FROM auth.uid()
       OR NOT combat_panel_private.shuriken_qa_can_read_v1(NEW.location_id)) THEN
    RAISE EXCEPTION 'shuriken_qa_presence_reserved' USING ERRCODE='42501';
  END IF;
  RETURN NEW;
END
$body$;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_qa_presence_guard_v1() FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER shuriken_qa_presence_guard BEFORE INSERT OR UPDATE OF location_id ON public.presence
  FOR EACH ROW EXECUTE FUNCTION combat_panel_private.shuriken_qa_presence_guard_v1();

CREATE FUNCTION combat_panel_private.shuriken_qa_write_message_v1(p_declaration uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $body$
DECLARE
  v_id uuid:=gen_random_uuid();
  v_message uuid;
BEGIN
  INSERT INTO combat_panel_private.shuriken_qa_message_permits_v1(message_id,transaction_id)
  VALUES (v_id,txid_current());
  INSERT INTO public.messages(id,location_id,character_id,author_name,body,sender_user)
  SELECT v_id,s.location_id,c.id,c.name,d.declaration_text,c.user_id
  FROM public.combat_v2_declarations d
  JOIN public.combat_v2_rounds r ON r.id=d.round_id
  JOIN public.combat_v2_sessions s ON s.id=r.session_id
  JOIN public.combat_v2_actors a ON a.id=d.actor_id AND a.session_id=s.id
  JOIN public.characters c ON c.id=a.character_id AND c.user_id=auth.uid() AND c.is_test
  JOIN combat_panel_private.shuriken_spend_v1 q ON q.declaration_id=d.id
    AND q.actor_id=a.id AND q.session_id=s.id AND NOT q.simulated
  WHERE d.id=p_declaration AND s.location_id=combat_panel_private.shuriken_qa_location_v1()
    AND c.id='2a877f02-4993-4e65-9172-7d29f08c5b86'
  RETURNING id INTO v_message;
  IF v_message IS NULL THEN
    RAISE EXCEPTION 'shuriken_qa_missing_spend' USING ERRCODE='42501';
  END IF;
  PERFORM combat_consumer_private.record_message(p_declaration,v_message);
END
$body$;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_qa_write_message_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;

CREATE TABLE combat_panel_private.shuriken_qa_command_v1 (
  principal_user uuid NOT NULL,
  activity_id uuid PRIMARY KEY,
  command jsonb NOT NULL
);
ALTER TABLE combat_panel_private.shuriken_qa_command_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON combat_panel_private.shuriken_qa_command_v1 FROM PUBLIC,anon,authenticated,service_role;

CREATE FUNCTION public.shuriken_qa_prepare_stock_v1() RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $body$
DECLARE
  v_char constant uuid:='2a877f02-4993-4e65-9172-7d29f08c5b86';
  v_item constant uuid:='298df4d4-6b82-4b58-9ef5-c1d0421e4097';
  v_location uuid:=combat_panel_private.shuriken_qa_location_v1();
BEGIN
  IF NOT public.is_staff() OR NOT EXISTS (
    SELECT 1 FROM public.characters WHERE id=v_char AND is_test AND user_id=auth.uid()
  ) OR NOT EXISTS(SELECT 1 FROM public.locations WHERE id=v_location AND is_active) THEN
    RAISE EXCEPTION 'shuriken_qa_stock_not_allowed' USING ERRCODE='42501';
  END IF;
  PERFORM 1 FROM public.locations WHERE id=v_location FOR UPDATE;
  IF NOT EXISTS(SELECT 1 FROM public.locations WHERE id=v_location AND is_active) THEN
    RAISE EXCEPTION 'shuriken_qa_stock_not_allowed' USING ERRCODE='42501';
  END IF;
  PERFORM 1 FROM public.characters WHERE id=v_char AND is_test FOR UPDATE;
  PERFORM clan_akimichi_private.meal_inventory_lock(v_char,v_item);
  IF EXISTS(SELECT 1 FROM public.character_equipment WHERE character_id=v_char AND
    (item_id=v_item OR anchor IN ('mano_dx','mano_sx')))
    OR EXISTS(SELECT 1 FROM public.character_inventory WHERE character_id=v_char AND item_id=v_item AND quantity<>0)
    OR EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE location_id=v_location)
    OR EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_sessions s ON s.id=a.session_id
      WHERE a.character_id=v_char AND s.state NOT IN ('chiuso','annullato')) THEN
    RAISE EXCEPTION 'shuriken_qa_stock_already_prepared_or_in_use' USING ERRCODE='42501';
  END IF;
  PERFORM public.staff_adjust_item(v_char,v_item,2,'Collaudo isolato Shuriken Land');
  PERFORM public.equip_to_anchor(v_char,v_item,'mano_dx');
  PERFORM public.equip_to_anchor(v_char,v_item,'mano_sx');
  RETURN jsonb_build_object('inventory',2,'equipped',2);
END
$body$;
REVOKE ALL ON FUNCTION public.shuriken_qa_prepare_stock_v1() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.shuriken_qa_prepare_stock_v1() TO authenticated;

-- Exact replay via the normal panel RPC, authorized by the original principal and declaration.
CREATE FUNCTION public.shuriken_qa_replay_v1() RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $body$
DECLARE
  v_saved combat_panel_private.shuriken_qa_command_v1%ROWTYPE;
  v_receipt jsonb;
  v_answer jsonb;
  v_after bigint;
  v_equipped bigint;
  v_character constant uuid:='2a877f02-4993-4e65-9172-7d29f08c5b86';
  v_item constant uuid:='298df4d4-6b82-4b58-9ef5-c1d0421e4097';
BEGIN
  IF NOT EXISTS(SELECT 1 FROM public.characters c WHERE c.id=v_character AND c.is_test AND c.user_id=auth.uid())
     OR NOT EXISTS(SELECT 1 FROM public.locations l WHERE l.id=combat_panel_private.shuriken_qa_location_v1() AND l.is_active) THEN
    RAISE EXCEPTION 'shuriken_qa_replay_not_allowed' USING ERRCODE='42501';
  END IF;
  SELECT q.* INTO STRICT v_saved
  FROM combat_panel_private.shuriken_qa_command_v1 q
  JOIN combat_consumer_private.activities a ON a.session_id=q.activity_id
  WHERE q.principal_user=auth.uid() AND a.phase='defense' AND a.closed_at IS NULL
    AND a.location_id=combat_panel_private.shuriken_qa_location_v1();
  SELECT rr.viewer_envelope->'receipt' INTO STRICT v_receipt
  FROM combat_panel_private.request_receipts rr
  WHERE rr.principal_user=v_saved.principal_user AND rr.request_key=(v_saved.command->>'request_key')::uuid
    AND rr.viewer_envelope#>>'{receipt,activity_id}'=v_saved.activity_id::text
    AND EXISTS (
      SELECT 1 FROM combat_panel_private.shuriken_spend_v1 s
      WHERE s.session_id=v_saved.activity_id AND s.declaration_id=(rr.viewer_envelope#>>'{receipt,declaration_id}')::uuid
        AND NOT s.simulated
    );

  v_answer:=public.combat_panel_commit_v1(v_saved.command)->'receipt';
  IF (v_answer->>'replayed')::boolean IS DISTINCT FROM true
     OR (v_answer-'replayed') IS DISTINCT FROM (v_receipt-'replayed') THEN
    RAISE EXCEPTION 'shuriken_qa_receipt_mismatch';
  END IF;
  SELECT coalesce(sum(i.quantity),0) INTO v_after FROM public.character_inventory i
    WHERE i.character_id=v_character AND i.item_id=v_item;
  SELECT coalesce(sum(e.quantity),0) INTO v_equipped FROM public.character_equipment e
    WHERE e.character_id=v_character AND e.item_id=v_item;
  RETURN jsonb_build_object('receipt_id',v_answer->>'receipt_id','same_receipt',true,
    'inventory_after_replay',v_after,'equipped_after_replay',v_equipped);
END
$body$;
REVOKE ALL ON FUNCTION public.shuriken_qa_replay_v1() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.shuriken_qa_replay_v1() TO authenticated;

DO $patch$
DECLARE v record; definition text;
BEGIN
  FOR v IN SELECT * FROM (VALUES
    ('combat_consumer_private.runtime_allowed(uuid,uuid)','33979b409042cc27b22bf6cddc2bae24',
      'SELECT CASE WHEN user_testroom_common_private.bound_context(p_location) IS NOT NULL THEN',
      $runtime$SELECT CASE WHEN p_location=combat_panel_private.shuriken_qa_location_v1() AND (NOT EXISTS (SELECT 1 FROM public.characters c WHERE c.user_id=p_principal AND c.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86','6bceee99-974f-426b-8d92-38b43b4a4267')) OR NOT combat_panel_private.shuriken_qa_can_read_v1(p_location)) THEN false WHEN user_testroom_common_private.bound_context(p_location) IS NOT NULL THEN$runtime$),
    ('public.enter_location(uuid)','376a1b4322a414ea087c882283379bf5',
      '  if auth.uid() is null then return; end if;',
      $a$  if auth.uid() is null then return; end if;
  IF NOT combat_panel_private.shuriken_qa_can_read_v1(p_location) THEN
    RAISE EXCEPTION 'shuriken_qa_location_reserved' USING ERRCODE='42501';
  END IF;$a$),
    ('public.post_message(uuid,text,uuid,uuid,text)','11dfabc592a186e76bd16855feb25565',
      $b$  if auth.uid() is null then raise exception 'non autenticato'; end if;$b$,
      $b$  if auth.uid() is null then raise exception 'non autenticato'; end if;
  IF p_location=combat_panel_private.shuriken_qa_location_v1() THEN
    RAISE EXCEPTION 'shuriken_qa_use_combat_panel' USING ERRCODE='42501';
  END IF;$b$),
    ('public.online_roster(integer)','e74d184b61ffb9b5531a6c30aca70315',
      '  where p.last_seen > now() - make_interval',
      '  where combat_panel_private.shuriken_qa_can_read_v1(p.location_id) AND p.last_seen > now() - make_interval'),
    ('public.post_item_use(uuid,uuid)','6fe171f8f4695d8ffc59815c2daa6d63',
      $a$  if auth.uid() is null then raise exception 'non autenticato'; end if;$a$,
      $a$  if auth.uid() is null then raise exception 'non autenticato'; end if;
  IF p_location=combat_panel_private.shuriken_qa_location_v1() THEN
    RAISE EXCEPTION 'shuriken_qa_item_use_unavailable' USING ERRCODE='42501';
  END IF;$a$),
    ('public.role_scene(uuid)','cde825a5221b0d38d21be88ac02aa68e',
      '  if v_sess.id is null then return; end if;',
      '  if v_sess.id is null OR NOT combat_panel_private.shuriken_qa_can_read_v1(v_sess.location_id) then return; end if;'),
    ('public.combat_v2_ordinary_open(uuid,uuid,integer,uuid)','aee9ff56b8e3f06536d3407a21ccf6ed',
      $sess$values('ordinary',p_location,'in_corso',true) returning id into v_enc;$sess$,
      $sess$values('ordinary',p_location,'in_corso',
    p_location IS DISTINCT FROM combat_panel_private.shuriken_qa_location_v1()) returning id into v_enc;$sess$),
    ('public.trg_role_autojoin()','7c2e17c5286a9bc606da34c7e5be1d91',
      $role$ IF TG_OP='INSERT' AND mission_narrative_internal.scene_message_permitted_v1(NEW) THEN RETURN NEW;END IF;$role$,
      $role$ IF TG_OP='INSERT' AND NEW.location_id=combat_panel_private.shuriken_qa_location_v1() THEN RETURN NEW; END IF;
 IF TG_OP='INSERT' AND mission_narrative_internal.scene_message_permitted_v1(NEW) THEN RETURN NEW;END IF;$role$),
    ('combat_consumer_private.accept_invitation(uuid,uuid)','cc8646ef038359066d84443f170fa805',
      '    case when first_initiative>=second_initiative then opener.id else recipient.id end;',
      $turn$    case when inv.location_id=combat_panel_private.shuriken_qa_location_v1()
      then '2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
      when first_initiative>=second_initiative then opener.id else recipient.id end;$turn$),
    ('combat_consumer_private.prepare_command(jsonb)','7c314150118417fa60ba6cf78f64e82e',
      $prepare$  sid:=(p->>'activity_id')::uuid;xid:=(p->>'exchange_id')::uuid;$prepare$,
      $prepare$  sid:=(p->>'activity_id')::uuid;xid:=(p->>'exchange_id')::uuid;
  IF loc=combat_panel_private.shuriken_qa_location_v1()
     AND p->>'operation' NOT IN ('open','join','close','declare') THEN
    RAISE EXCEPTION 'shuriken_qa_command_scope' USING ERRCODE='42501';
  END IF;$prepare$),
    ('combat_panel_private.commit_ordinary(jsonb)','ed553ca3e6385b8210c52f0135c1022c',
      $d$ RETURN env;
END $d$,
      $d$ IF c.location_id=combat_panel_private.shuriken_qa_location_v1()
      AND o.kind='action' AND o.operation='declare' THEN
   INSERT INTO combat_panel_private.shuriken_qa_command_v1(principal_user,activity_id,command)
   VALUES(uid,c.activity_id,p);
 END IF;
 RETURN env;
END $d$),
    ('combat_consumer_private.commit_exchange(jsonb,jsonb)','afa2cc75f1effc68d40547843cd8b392',
      $c$  ELSE
    perform combat_consumer_private.record_message(declaration,
      public.post_message(ctx.location_id,p->>'narrative_text',null,null,null));
  END IF;$c$,
      $c$  ELSIF ctx.location_id=combat_panel_private.shuriken_qa_location_v1() THEN
    PERFORM combat_panel_private.shuriken_qa_write_message_v1(declaration);
  ELSE
    perform combat_consumer_private.record_message(declaration,
      public.post_message(ctx.location_id,p->>'narrative_text',null,null,null));
  END IF;$c$)
  ) AS patches(signature,pin,before_text,after_text)
  LOOP
    definition:=pg_get_functiondef(v.signature::regprocedure);
    IF md5(definition)<>v.pin OR
      (length(definition)-length(replace(definition,v.before_text,'')))<>length(v.before_text) THEN
      RAISE EXCEPTION 'shuriken_qa_baseline_drift %',v.signature;
    END IF;
    EXECUTE replace(definition,v.before_text,v.after_text);
  END LOOP;
END
$patch$;

-- Provision the reserved location inactively. Installing the contract never enables the scene.
INSERT INTO public.locations(id,name,kind,region,is_active,is_test,is_exam_room,map_x,map_y)
VALUES (combat_panel_private.shuriken_qa_location_v1(),'Collaudo riservato Shuriken','altro','konoha',false,false,false,50,50);
INSERT INTO combat_consumer_private.scene_profiles(
  location_id,template_key,template_version,producer_version,geometry_sha256,approval_reference,enabled,
  fighter_one_slot,fighter_two_slot
)
VALUES (combat_panel_private.shuriken_qa_location_v1(),'ordinary_neutral_v1',1,2,
  combat_consumer_private.scene_fingerprint('ordinary_neutral_v1',1),'COMBAT-SHURIKEN-PRIVATE-LAND-20261114',
  true,'PG-A','PG-B');

COMMIT;
