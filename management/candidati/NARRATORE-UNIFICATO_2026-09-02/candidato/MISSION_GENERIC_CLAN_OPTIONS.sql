-- MISSION-GENERIC-CLAN-OPTIONS/1 — A1 MG-SRC-R1-01; no gate/technique enable.

begin;

do $patch$ declare body text;ddl text;o text;n text;begin
 select prosrc,pg_get_functiondef(oid) into strict body,ddl from pg_proc where oid='clan_hyuga_private.master_control_offers(uuid,bigint)'::regprocedure
 and prosecdef and pg_get_userbyid(proowner)='postgres' and proconfig=ARRAY['search_path=""']
 and proacl::text='{postgres=X/postgres}';
 if md5(body)<>'7f9bdd705b4bd629401c7315f2ec2bc7' then raise exception 'MG_CLAN_OPTIONS_BASELINE_DRIFT';end if;
 o:=$old$ SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND controller_user=auth.uid();$old$;
 n:=$new$ SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND CASE WHEN auth.uid() IS NOT NULL THEN controller_user=auth.uid()
    ELSE actor_kind='png' AND controller_user IS NULL
     AND mission_generic_owner.current_principal()=mission_generic_owner.actor_principal(id) END;$new$;
 if (length(ddl)-length(replace(ddl,o,'')))/length(o)<>1 then raise exception 'MG_CLAN_OPTIONS_ANCHOR_DRIFT';end if;
 execute replace(ddl,o,n);
end $patch$;

do $patch$ declare body text;ddl text;o text;n text;begin
 select prosrc,pg_get_functiondef(oid) into strict body,ddl from pg_proc where oid='clan_innata_private.sharingan_master_control_offers(uuid,bigint)'::regprocedure
 and prosecdef and pg_get_userbyid(proowner)='postgres' and proconfig=ARRAY['search_path=""']
 and proacl::text='{postgres=X/postgres}';
 if md5(body)<>'110e2293ac42e3817ae977ccc92e9fe5' then raise exception 'MG_CLAN_OPTIONS_BASELINE_DRIFT';end if;
 o:=$old$ SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND controller_user=auth.uid();$old$;
 n:=$new$ SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND CASE WHEN auth.uid() IS NOT NULL THEN controller_user=auth.uid()
    ELSE actor_kind='png' AND controller_user IS NULL
     AND mission_generic_owner.current_principal()=mission_generic_owner.actor_principal(id) END;$new$;
 if (length(ddl)-length(replace(ddl,o,'')))/length(o)<>1 then raise exception 'MG_CLAN_OPTIONS_ANCHOR_DRIFT';end if;
 execute replace(ddl,o,n);
end $patch$;

-- CREATE OR REPLACE conserva le ACL private dei due helper; nessun nuovo GRANT pubblico.

commit;
