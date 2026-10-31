# E72 — adattamento tecnico della preview E71

Delta dalla Edge136 e dai tre asset UI riconciliati su Git main67e5. Cambiano soltanto due allowlist d’identità nella Edge: il runtime e il consumer della coppia ammettono la nuova campagnaE72 oltre alle precedentiE68/E70. I prompt E71 Director dialogico/3, Writer response/10 e memoriaScene/2 restano byteidentici, così come schemi, bounds, normalizzatori, validator, quote, autorità e topologia. Nessun nuovo Director viene aggiunto alla narrazione ordinaria.

La UI aggiunge un’istanza del medesimo controller Staff per Verifica E71. Restano i pannelli e i journal precedenti; il nuovo journal ha namespace distinto per build/utente/campagna/caso. Nessun polling, autostart o generazione automatica. I tre asset cambiano solo per gli export d’identità, i link/pin, l’istanza, mount/dispose e la stringa di versione, della stessa lunghezza precedente. Il build generale LAND e tutte le classi e costanti estranee restano invariati.

Prove statiche:15MJS Edge,2MJS UI e gli script LAND eseguibili analizzati con node --check; import relativi risolti. Le sostituzioni inverse ripristinano l’intero runtime, il consumer della coppia e i tre asset UI byte per byte: la prova copre l’intera baseline, non solo tre prompt selezionati. Il rebuild riproduce pacchetto/static/UI/diff. Nessun gameplay, provider, deploy o SQL eseguito da questo contributo. La nuova campagna richiede comunque l’autorità server e l’installazione integrata qualificata; la presenza della UI non abilita la prova.

## Identità

- Package SHA256: `2f0b74fc680d6dd54c285992f0bfb8b89049b8602efa5f6c8d40eb7146f3faef`.
- Builder SHA256: `d2b1eebc50165f82aa561949a49d1c459d7288646d23e68bc7404dacf2d20660`.
- Runtime candidato: `46b0078ef29501183c9fffc691dc5fcb476e7f5d6f806dc8b4a5c5304787b5af`.
- Pair candidato: `3029e4691cdd486819a90f2c42a978efc82cdac327e13e670503ca57430fb2c6`.

## Diff Edge esatto

```diff
--- Edge136/mission-generic-runtime.mjs
+++ E72/mission-generic-runtime.mjs
@@ -4556,6 +4556,7 @@
 // E68: private authored-source adapters. These issue no work/admission/lease or provider permission.
 const EDITORIAL_DIALOGUE_CAMPAIGN='a8c3c6f9-949d-5b64-8a02-80667c7b4da8';
 const EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN='2bd901b7-6ba6-5319-a55a-2d2e2cfcf03b';
+const EDITORIAL_DIALOGUE_E71_CAMPAIGN='ff79949a-06cb-5749-a33f-3d632d78f3a5';
 const EDITORIAL_DIALOGUE_DECISION_FIELDS=['schema_version','source_window_id','source_role_ids','source_evidence','opportunity_id','action_kind','entry_side','world_reaction_intent','npc_intents'];
 const EDITORIAL_DIALOGUE_WRITER_RULE="staff-editorial-dialogue-writer/2. La fonte è un caso editoriale privato: editorial_questions sono domande Staff-authored, non role PG accettate o nuovi fatti pubblicati. Il piano Director ricevuto è la nuova proposta narrativa validata della stessa coppia. Realizza soltanto le iniziative speak/gesture ammesse per i PNG presenti; contenuto, scopo e modo ricevuti orientano la prosa, non sono battute da copiare. Le premesse editoriali non provano consenso o azioni PG. Nessuna scelta PG, consegna, attacco, risultato meccanico o nuova transizione è autorizzata. next_step è soltanto stay: continua l'interazione nella stessa fase, senza impedirne gli sviluppi narrativi consentiti. Memoria e testo rimangono privati, senza pubblicazione o aggiornamento della missione.";
 function editorialDialogueLimits(policy){
@@ -4566,7 +4567,7 @@
 async function editorialDialogueView(source){
  const bad=()=>{throw Error('MISSION_EDITORIAL_DIALOGUE_SOURCE_INVALID');};
  const fields=['schema_version','campaign_id','case_no','author_user_id','historical_anchor_work_id','case_source_id','plan_version_id','plan_sha256','npc_refs','phase_key','snapshot','scene_memory','last_fati','questions'];
- if(!exact(source,fields)||source.schema_version!=='staff-editorial-dialogue-source/1'||![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN].includes(source.campaign_id)
+ if(!exact(source,fields)||source.schema_version!=='staff-editorial-dialogue-source/1'||![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN,EDITORIAL_DIALOGUE_E71_CAMPAIGN].includes(source.campaign_id)
   ||!Number.isInteger(source.case_no)||source.case_no<1||source.case_no>3
   ||!['author_user_id','historical_anchor_work_id','case_source_id','plan_version_id'].every(k=>uuid(source[k]))||!sha(source.plan_sha256)||!text(source.phase_key))bad();
  const captured=source.snapshot;
--- Edge136/mission-staff-editorial-pair.mjs
+++ E72/mission-staff-editorial-pair.mjs
@@ -4,7 +4,8 @@
 const CAMPAIGN='23c83d81-3e37-5a7e-8056-45b009992a3f';
 const DIALOGUE_CAMPAIGN='a8c3c6f9-949d-5b64-8a02-80667c7b4da8';
 const DIALOGUE_REVIEW_CAMPAIGN='2bd901b7-6ba6-5319-a55a-2d2e2cfcf03b';
-const campaignSpec=id=>id===CAMPAIGN?{work:'staff-editorial-work/2',directorSource:'staff-editorial-source/1',writerSource:'staff-editorial-paired-writer-source/1',director:createStaffEditorialDirector,writer:createStaffPairedEditorialWriter}:(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN)?{work:'staff-editorial-work/3',directorSource:'staff-editorial-dialogue-source/1',writerSource:'staff-editorial-dialogue-writer-source/1',director:createStaffDialogueEditorialDirector,writer:createStaffDialogueEditorialWriter}:null;
+const DIALOGUE_E71_CAMPAIGN='ff79949a-06cb-5749-a33f-3d632d78f3a5';
+const campaignSpec=id=>id===CAMPAIGN?{work:'staff-editorial-work/2',directorSource:'staff-editorial-source/1',writerSource:'staff-editorial-paired-writer-source/1',director:createStaffEditorialDirector,writer:createStaffPairedEditorialWriter}:(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN||id===DIALOGUE_E71_CAMPAIGN)?{work:'staff-editorial-work/3',directorSource:'staff-editorial-dialogue-source/1',writerSource:'staff-editorial-dialogue-writer-source/1',director:createStaffDialogueEditorialDirector,writer:createStaffDialogueEditorialWriter}:null;
 const factoryFor=(work,variant)=>{const spec=campaignSpec(work.campaign_id);if(!spec||work.source?.schema_version!==spec[variant==='director'?'directorSource':'writerSource'])throw Error('E68_SOURCE_BINDING');return spec[variant];};
 const UUID=/^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/i;
 const SHA=/^[a-f0-9]{64}$/;
```
