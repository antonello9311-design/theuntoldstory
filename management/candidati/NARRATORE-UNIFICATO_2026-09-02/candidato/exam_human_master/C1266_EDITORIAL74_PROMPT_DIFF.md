# E74 — adattamento tecnico della preview E73

Delta dalla Edge138 e dai tre asset UI riconciliati su Git main5cbc4fe. Cambiano soltanto due allowlist d’identità nella Edge: il runtime e il consumer della coppia ammettono la nuova campagnaE74 oltre alle precedenti E68/E70/E72. Tutti i testi E73, incluse le 45 regioni nei tre moduli runtime, Narrative Master ed editorial, restano byteidentici, così come schemi, bounds, normalizzatori, validator, quote, autorità e topologia. Nessun nuovo Director viene aggiunto alla narrazione ordinaria.

La UI aggiunge un’istanza del medesimo controller Staff per Verifica E73. Restano i pannelli e i journal precedenti; il nuovo journal ha namespace distinto per build/utente/campagna/caso. Nessun polling, autostart o generazione automatica. I tre asset cambiano solo per gli export d’identità, i link/pin, l’istanza, mount/dispose e la stringa di versione, della stessa lunghezza precedente. Il build generale LAND e tutte le classi e costanti estranee restano invariati.

Prove statiche:15MJS Edge,2MJS UI e gli script LAND eseguibili analizzati con node --check; import relativi risolti. Le sostituzioni inverse ripristinano l’intero runtime, il consumer della coppia e i tre asset UI byte per byte: la prova copre l’intera baseline, non solo tre prompt selezionati. Il rebuild riproduce pacchetto/static/UI/diff. Nessun gameplay, provider, deploy o SQL eseguito da questo contributo. La nuova campagna richiede comunque l’autorità server e l’installazione integrata qualificata; la presenza della UI non abilita la prova.

## Identità

- Package SHA256: `303be3a26b875479d8a45a3e3e128c74ca858a99b1bb09052514c99ea56e9654`.
- Builder SHA256: `8976d60333de79d41d48ee77f99f4a6580030c7532bcc9723cf20a57f0ba9c5f`.
- Runtime candidato: `c240b4c9fb3c48ea84d0257dde77dc25e099b43374ec2119e974ce7992d2f49b`.
- Pair candidato: `3cde8bf417a32a06c23143384eba864eb81cc17f3976b4a2441c099b9c77424e`.

## Diff Edge esatto

```diff
--- Edge138/mission-generic-runtime.mjs
+++ E74/mission-generic-runtime.mjs
@@ -4557,6 +4557,7 @@
 const EDITORIAL_DIALOGUE_CAMPAIGN='a8c3c6f9-949d-5b64-8a02-80667c7b4da8';
 const EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN='2bd901b7-6ba6-5319-a55a-2d2e2cfcf03b';
 const EDITORIAL_DIALOGUE_E71_CAMPAIGN='ff79949a-06cb-5749-a33f-3d632d78f3a5';
+const EDITORIAL_DIALOGUE_E73_CAMPAIGN='beabfc88-ae45-53b1-b081-d137cd8eac41';
 const EDITORIAL_DIALOGUE_DECISION_FIELDS=['schema_version','source_window_id','source_role_ids','source_evidence','opportunity_id','action_kind','entry_side','world_reaction_intent','npc_intents'];
 const EDITORIAL_DIALOGUE_WRITER_RULE="staff-editorial-dialogue-writer/3. editorial_questions e premesse sono fonti private Staff-authored, non role accettate, azioni o consensi dei PG. Il piano Director appartiene alla stessa coppia e autorizza soltanto le iniziative speak/gesture ammesse per i PNG presenti. Non autorizza scelte PG, consegne, attacchi, risultati meccanici o transizioni. next_step resta stay. Testo e memoria rimangono privati e non aggiornano la missione.";
 function editorialDialogueLimits(policy){
@@ -4567,7 +4568,7 @@
 async function editorialDialogueView(source){
  const bad=()=>{throw Error('MISSION_EDITORIAL_DIALOGUE_SOURCE_INVALID');};
  const fields=['schema_version','campaign_id','case_no','author_user_id','historical_anchor_work_id','case_source_id','plan_version_id','plan_sha256','npc_refs','phase_key','snapshot','scene_memory','last_fati','questions'];
- if(!exact(source,fields)||source.schema_version!=='staff-editorial-dialogue-source/1'||![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN,EDITORIAL_DIALOGUE_E71_CAMPAIGN].includes(source.campaign_id)
+ if(!exact(source,fields)||source.schema_version!=='staff-editorial-dialogue-source/1'||![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN,EDITORIAL_DIALOGUE_E71_CAMPAIGN,EDITORIAL_DIALOGUE_E73_CAMPAIGN].includes(source.campaign_id)
   ||!Number.isInteger(source.case_no)||source.case_no<1||source.case_no>3
   ||!['author_user_id','historical_anchor_work_id','case_source_id','plan_version_id'].every(k=>uuid(source[k]))||!sha(source.plan_sha256)||!text(source.phase_key))bad();
  const captured=source.snapshot;
--- Edge138/mission-staff-editorial-pair.mjs
+++ E74/mission-staff-editorial-pair.mjs
@@ -5,7 +5,8 @@
 const DIALOGUE_CAMPAIGN='a8c3c6f9-949d-5b64-8a02-80667c7b4da8';
 const DIALOGUE_REVIEW_CAMPAIGN='2bd901b7-6ba6-5319-a55a-2d2e2cfcf03b';
 const DIALOGUE_E71_CAMPAIGN='ff79949a-06cb-5749-a33f-3d632d78f3a5';
-const campaignSpec=id=>id===CAMPAIGN?{work:'staff-editorial-work/2',directorSource:'staff-editorial-source/1',writerSource:'staff-editorial-paired-writer-source/1',director:createStaffEditorialDirector,writer:createStaffPairedEditorialWriter}:(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN||id===DIALOGUE_E71_CAMPAIGN)?{work:'staff-editorial-work/3',directorSource:'staff-editorial-dialogue-source/1',writerSource:'staff-editorial-dialogue-writer-source/1',director:createStaffDialogueEditorialDirector,writer:createStaffDialogueEditorialWriter}:null;
+const DIALOGUE_E73_CAMPAIGN='beabfc88-ae45-53b1-b081-d137cd8eac41';
+const campaignSpec=id=>id===CAMPAIGN?{work:'staff-editorial-work/2',directorSource:'staff-editorial-source/1',writerSource:'staff-editorial-paired-writer-source/1',director:createStaffEditorialDirector,writer:createStaffPairedEditorialWriter}:(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN||id===DIALOGUE_E71_CAMPAIGN||id===DIALOGUE_E73_CAMPAIGN)?{work:'staff-editorial-work/3',directorSource:'staff-editorial-dialogue-source/1',writerSource:'staff-editorial-dialogue-writer-source/1',director:createStaffDialogueEditorialDirector,writer:createStaffDialogueEditorialWriter}:null;
 const factoryFor=(work,variant)=>{const spec=campaignSpec(work.campaign_id);if(!spec||work.source?.schema_version!==spec[variant==='director'?'directorSource':'writerSource'])throw Error('E68_SOURCE_BINDING');return spec[variant];};
 const UUID=/^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/i;
 const SHA=/^[a-f0-9]{64}$/;
```
