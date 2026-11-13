BEGIN;
SET LOCAL lock_timeout = '4s';

DO $check$
BEGIN
  IF (SELECT md5(pg_get_viewdef('public.chat_messages_live'::regclass, true)))
      IS DISTINCT FROM '4edc9e81183db6da8042bc1bd4ab64a3' THEN
    RAISE EXCEPTION 'STAFF_ARCHIVE_CHAT_VIEW_DRIFT';
  END IF;
END
$check$;

CREATE TABLE combat_panel_private.staff_archived_messages (
  message_id uuid PRIMARY KEY,
  archived_at timestamptz NOT NULL DEFAULT statement_timestamp()
);
ALTER TABLE combat_panel_private.staff_archived_messages ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON combat_panel_private.staff_archived_messages FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION public.staff_chat_message_archived(p_location uuid, p_message uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $function$
  SELECT CASE WHEN p_location = '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN
    CASE WHEN auth.role() = 'service_role'
      OR (auth.uid() IS NULL AND session_user = 'postgres')
      OR public.is_staff() THEN
      EXISTS (SELECT 1 FROM combat_panel_private.staff_archived_messages a WHERE a.message_id = p_message)
    ELSE false END
  ELSE false END;
$function$;
REVOKE ALL ON FUNCTION public.staff_chat_message_archived(uuid, uuid) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.staff_chat_message_archived(uuid, uuid) TO authenticated, service_role;

CREATE OR REPLACE VIEW public.chat_messages_live WITH (security_invoker = true) AS
SELECT id, location_id, character_id, author_name, body, created_at, kind, sender_user,
       recipient_user, recipient_name, dice_sides, dice_result, companion_id, companion_body
FROM public.messages
WHERE created_at >= (now() - interval '12 hours')
  AND NOT public.staff_chat_message_archived(location_id, id);

COMMIT;
