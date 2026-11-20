WITH target AS (
 SELECT to_jsonb(t) AS original,j.plus FROM public.clan_techniques t CROSS JOIN (SELECT $verme_effect$Combat V2: in prova nella Staff Test Room. Il profilo in prova usa l’azione principale, costa 10 chakra per lancio e impegna 5 unità di Colonia per un colpo a contatto entro 2 metri. Il colpo ha danno base 10. Un successo pieno con danno effettivo inietta una tossina se il bersaglio è ancora operativo. La tossina ha danno base 5, ridotto dalla Resistenza, all’inizio di ciascuno dei due turni personali successivi del bersaglio. Le iniezioni successive possono rinnovarne la durata senza sommare gli effetti. Gli insetti superstiti rientrano nella Colonia dopo la risoluzione.$verme_effect$::text AS plus) j WHERE t.id='2f06b6f8-341f-472b-be04-ad48fcf2c412'::uuid
), model AS (
 SELECT original,jsonb_set(original,'{danno_effetto}',to_jsonb(plus),false) AS projected FROM target
) SELECT jsonb_build_object(
 'row_before',public.combat_v2_sha256(m.original),'row_after',public.combat_v2_sha256(m.projected),
 'mechanics_fingerprint',public.combat_v2_sha256(m.original-'danno_effetto'),
 'only_effect_changed',(m.original-'danno_effetto')=(m.projected-'danno_effetto'),
 'inverse_exact',jsonb_set(m.projected,'{danno_effetto}','null'::jsonb,false)=m.original,
 'before_effect',m.original->'danno_effetto','after_effect',m.projected->'danno_effetto',
 'other_rows_sha256',(SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(t) ORDER BY t.id)) FROM public.clan_techniques t WHERE t.id<>'2f06b6f8-341f-472b-be04-ad48fcf2c412'::uuid),
 'noninternal_triggers',(SELECT count(*) FROM pg_trigger g WHERE g.tgrelid='public.clan_techniques'::regclass AND NOT g.tgisinternal),
 'root',(SELECT r.revision_sha256 FROM mission_factory_owner.editor_release_readiness r WHERE r.singleton),
 'e52',clan_innata_private.catalogo_eligibility_release_v1(),
 'verme_release',clan_aburame_private.verme_release_v1(),
 'verme_manifest',clan_aburame_private.verme_manifest_v1(),
 'verme_gate',(SELECT to_jsonb(g) FROM clan_aburame_private.verme_gate_v1 g WHERE singleton)
) AS evidence FROM model m;
