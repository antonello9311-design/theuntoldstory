import {seedMissionNativeModel} from './mf-mission-native-bridge-d6ee2eff5385f62b557185e85c897dff2bed13f070bb151008d75482807e288f.mjs';

// Composizione candidata: tutte le letture sono Staff; il salvataggio source è nel controller Factory.
export function createMissionNativeVariantAdapter({api,nativeUI}) {
  if (!api || typeof api.variantNpcProjection !== 'function' ||
      typeof api.nativeVariantOptions !== 'function' || typeof api.catalog !== 'function' ||
      typeof nativeUI?.mountDraftVariant !== 'function')
    throw Error('Bridge della variante nativa non disponibile.');
  return async function editVariant({mode,draft_id,expected_version,document,host}) {
    if (!['ai','human'].includes(mode) || document?.schema_version !== 'mission-factory-draft/1' ||
        !Number.isSafeInteger(expected_version) || expected_version < 1 || !host?.isConnected)
      throw Error('Bozza della variante non qualificata.');
    const [projection,native,factoryCatalog]=await Promise.all([
      api.variantNpcProjection({draft_id,expected_version}),api.nativeVariantOptions(),api.catalog()
    ]);
    if (factoryCatalog?.schema_version !== 'mission-factory-catalog/1' ||
        factoryCatalog.version !== document.catalog_version ||
        factoryCatalog.event_projection_version !== 'mission-factory-native-event/1')
      throw Error('Catalogo Factory cambiato: aggiorna la bozza prima di configurare la variante.');
    const model=seedMissionNativeModel(document,projection,{draftId:draft_id,expectedVersion:expected_version,
      mode,catalog:factoryCatalog});
    const prior=document.variants?.[mode];
    const existing=prior?.state==='complete' && prior.mode===mode ? prior.document : null;
    return nativeUI.mountDraftVariant(host,{draft_id,mode,model,existing,catalog:native.catalog,
      profiles:native.profiles,factorySource:document,factoryCatalog});
  };
}
