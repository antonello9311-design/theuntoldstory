BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '15s';

-- Sospende i nuovi avvii. Le ricevute restano conservate e la Land può
-- completare i soli percorsi reali già maturati al prossimo ingresso.
UPDATE training_sheet_private.release_v1
  SET staff_enabled=false, public_enabled=false
  WHERE singleton;

COMMIT;
