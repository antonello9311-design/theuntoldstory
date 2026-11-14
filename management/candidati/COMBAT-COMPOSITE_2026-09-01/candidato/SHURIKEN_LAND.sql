DO $release$
DECLARE gate text := pg_get_functiondef('combat_panel_private.shuriken_public_enabled_v1()'::regprocedure);
BEGIN
  IF md5(gate)<>'8ebe77a262cf27af4ff34b5c511c5519'
     OR md5(pg_get_functiondef('combat_panel_private.shuriken_pool_v1(uuid)'::regprocedure))<>'747f94d28132cc93dcd3dc36356a7ecc' THEN
    RAISE EXCEPTION 'Shuriken release baseline drift';
  END IF;
  EXECUTE replace(gate,'SELECT false','SELECT true');
END
$release$;
