import {seedMissionNativeModel} from './mf-mission-native-bridge-2d2425cd4006f98ee4afa2bc61fbdb2fe4b8d34bd64b60d7c23e3ce8c549d978.mjs';

// Composizione candidata: tutte le letture sono Staff; il salvataggio source è nel controller Factory.
export function createMissionNativeVariantAdapter({api,nativeUI}) {
  if (!api || typeof api.variantNpcProjection !== 'function' ||
      typeof api.nativeVariantOptions !== 'function' || typeof api.catalog !== 'function' ||
      typeof nativeUI?.mountDraftVariant !== 'function')
    throw Error('Bridge della variante nativa non disponibile.');
  return async function editVariant({mode,draft_id,expected_version,document,host,isCurrent=()=>true}) {
    if (!['ai','human'].includes(mode) || document?.schema_version !== 'mission-factory-draft/1' ||
        !Number.isSafeInteger(expected_version) || expected_version < 1 || !host?.isConnected)
      throw Error('Bozza della variante non qualificata.');
    const lifecycle=typeof api.lifecycleEpoch==='function'?api.lifecycleEpoch():null;const source=JSON.stringify(document);const current=()=>host.isConnected&&isCurrent()&&JSON.stringify(document)===source&&(lifecycle===null||api.lifecycleEpoch()===lifecycle);
    const [projection,native,factoryCatalog]=await Promise.all([
      api.variantNpcProjection({draft_id,expected_version}),api.nativeVariantOptions(),api.catalog()
    ]);
    if (factoryCatalog?.schema_version !== 'mission-factory-catalog/1' ||
        factoryCatalog.version !== document.catalog_version ||
        factoryCatalog.event_projection_version !== 'mission-factory-native-event/1')
      throw Error('Catalogo Factory cambiato: aggiorna la bozza prima di configurare la variante.');
    const d100Phases=document.phases.filter(x=>x.kind==='d100');
    if(d100Phases.length&&typeof api.d100Projection!=='function')throw Error('Proiezione Native D100 non disponibile.');
    const d100Projections=await Promise.all(d100Phases.map(phase=>api.d100Projection({phase:structuredClone(phase),mode})));
    if(!current())throw Error('Contesto della variante cambiato: riapri la configurazione.');
    const model=seedMissionNativeModel(document,projection,{draftId:draft_id,expectedVersion:expected_version,
      mode,catalog:factoryCatalog,d100Projections});
    const prior=document.variants?.[mode];
    const existing=prior?.state==='complete' && prior.mode===mode ? prior.document : null;
    return nativeUI.mountDraftVariant(host,{draft_id,mode,model,existing,catalog:native.catalog,
      profiles:native.profiles,factorySource:document,factoryCatalog,factoryD100Projections:d100Projections});
  };
}
