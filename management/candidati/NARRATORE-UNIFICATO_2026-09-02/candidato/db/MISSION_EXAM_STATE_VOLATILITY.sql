-- Il caricamento delle difese prepara capability server per Sostituzione.
-- PostgREST deve usare una transazione scrivibile per questa RPC POST.
ALTER FUNCTION public.esame_prova_stato(uuid) VOLATILE;
NOTIFY pgrst, 'reload schema';
