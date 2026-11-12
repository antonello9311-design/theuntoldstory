(function () {
  'use strict';

  // Display values for the two Dokugan techniques in Combat V2.
  // The original catalog row still serves acquisition and other consumers.
  const details = new Map([
    ['127f3854-4183-4354-a654-f59320d8807e', {
      danno_base: 10,
      potenza: 20,
      gittata: '15 m',
      tipo_azione: 'azione principale',
      riserva_veleno: '2 unità per lancio',
      chakra_cost: 5,
      consumption_type: 'ad_utilizzo'
    }],
    ['c8d32b00-3917-41a6-8906-388e7b9efcc7', {
      danno_base: 0,
      potenza: null,
      gittata: 'contatto a mani nude',
      tipo_azione: 'attivazione dal pannello nel proprio turno',
      durata: 'fino a 3 turni personali',
      riserva_veleno: '5 unità impegnate',
      chakra_cost: 5,
      consumption_type: 'per_turno'
    }]
  ]);

  window.TUSHokiCatalog = function (technique) {
    const display = details.get(technique.technique_id || technique.id);
    return display ? { ...technique, uso: null, portata: null, ...display } : technique;
  };
})();
