SELECT jsonb_build_object(
 'target',t.id,'row_sha256',public.combat_v2_sha256(to_jsonb(t)),
 'after_matches',public.combat_v2_sha256(to_jsonb(t))='757a5232e4a72e009fb1b5e8e8964660beccdda062013f28fcaba68f3941c77b',
 'before_matches',public.combat_v2_sha256(to_jsonb(t))='36880dbfcce77d76af0412aac7f927a92efcb657578e2ab87d194477ee3a9ddf',
 'numeric_and_catalog_invariants',public.combat_v2_sha256(to_jsonb(t)-'danno_effetto')='90c9c9be44e812fdadedf3c44d6bd876449f6dc1fc936854374eea54297a1050',
 'effect_matches',t.danno_effetto IS NOT DISTINCT FROM $verme_effect$Combat V2: in prova nella Staff Test Room. Il profilo in prova usa l’azione principale, costa 10 chakra per lancio e impegna 5 unità di Colonia per un colpo a contatto entro 2 metri. Il colpo ha danno base 10. Un successo pieno con danno effettivo inietta una tossina se il bersaglio è ancora operativo. La tossina ha danno base 5, ridotto dalla Resistenza, all’inizio di ciascuno dei due turni personali successivi del bersaglio. Le iniezioni successive possono rinnovarne la durata senza sommare gli effetti. Gli insetti superstiti rientrano nella Colonia dopo la risoluzione.$verme_effect$,
 'root',(SELECT revision_sha256 FROM mission_factory_owner.editor_release_readiness WHERE singleton),
 'e52',clan_innata_private.catalogo_eligibility_release_v1(),
 'verme_release',clan_aburame_private.verme_release_v1(),
 'verme_manifest',clan_aburame_private.verme_manifest_v1(),
 'verme_gate',(SELECT to_jsonb(g) FROM clan_aburame_private.verme_gate_v1 g WHERE singleton)
) AS evidence FROM public.clan_techniques t WHERE t.id='2f06b6f8-341f-472b-be04-ad48fcf2c412'::uuid;
