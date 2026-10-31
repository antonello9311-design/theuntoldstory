# E70 — Adattamento minimo della preview Staff

Stato: candidata congelata, non installata. Baseline Edge134, Root56a9583b50838d9ac0f66de90cf5329b37046d730d8c92ca0f2d9191aade041b. Nuova campagna 2bd901b7-6ba6-5319-a55a-2d2e2cfcf03b, UUID5 URL di tus-c1266-editorial70-20261031.

## Producer e consumer

Il producer DB registra una nuova campagna e nuove fonti dichiarate, con le medesime tre situazioni e domande narrative E68. Il runtime accetta esplicitamente soltanto le due identità editoriali E68 ed E70 per lo stesso source/1; il consumer della coppia classifica entrambe come work/3. Non è introdotta un'ammissione generica di UUID. Le RPC autenticate e l'autorità Root della campagna attiva restano obbligatorie prima di ogni avvio o seguito: la whitelist Edge non abilita una campagna chiusa. E65/E66 non cambiano.

Le trasformazioni sono reversibili staticamente: rimossi i due delta d'identità, il runtime intero e il consumer della coppia tornano identici alla baseline. Director dialogico/2, response/9, memoriaScene/1, schema, limiti, normalizzatori e controlli E69 restano byteidentici. Nessuna modifica a stile, domande, memoria salvata o Fati.

## Client

Il modulo Staff aggiunge soltanto REVIEW_BUILD e REVIEW_CAMPAIGN. Il controller esistente è riutilizzato integralmente, con journal per build, utente autenticato, campagna e caso; salva la nonce prima del POST e non avvia richieste al mount. Nessun polling o retry automatico. Il modulo principale monta la nuova istanza «Verifica E69 · Staff» conservando l'istanza E68 e i suoi esiti; dispone entrambe e aggiorna i pin modulo/pagina. Nessun cambiamento a Combat o ai controlli della missione.

I tre file locali sono riconciliati con GitHub main4fa92315caac3fe5bfc2078d8e203687ad703be2, che conserva i tre asset pubblicati con38674. I due moduli sono stati acquisiti integralmente dal connector. Per land.html il connector omette il contenuto troppo grande: il blob GitHub52fc91752f983b9ba1ea9d4a81f370ed343b9da2 coincide con l'identità Git calcolata su tutti i2374142byte locali; SHA256963016bf899fbe69c69805396694c8e35afbc77599c7f25633fc9f620d9b66ad. Non è dichiarato un fullreadback remoto del contenuto che il connector non ha restituito.

## Controlli e limiti

Sintassi15moduli Edge e8blocchi/moduli client verificata con node --check; import relativi Edge risolti staticamente. Ricostruzione separata: package, static, manifestUI e tre asset byteidentici. Nessun gameplay, fixture, browser, DB mutante, provider o deploy da questo contributo. Review e installazione integrate spettano al PM; efficacia editoriale e percorso runtime E70 NOT_RUN. Il mandato successivo prevede tre nuove coppie, massimo12HTTP e0,264USD aggiuntivi entro4USD cumulativi, senza consumare chiamate durante questa preparazione.

## Identità

- Package: `04728348a57beb1c27d4b9204b268e0e37ce6eb2fd56511e72f792ae87ccde21`.
- Builder: `3952f350e260d331ac45af8310bf4cc4ef2da2fa9b387b8a1ee90cef17195dd4`.
- sito_live/mission-editorial-staff.mjs: 14975 byte, `c3168a3664c231f24be407104429788bdf5689cded30e44c357e1d901998ff76`.
- sito_live/mission-generic-ui.mjs: 355895 byte, `c29a5709ec6d271bca585e346df3cb88183df4471d87cb1a36708bb464bc91e2`.
- sito_live/land.html: 2374142 byte, `70f113f83e37e4d665a4e689cc590e5b8e85da7ed3cdcdd494ab6e74b6edbf06`.

## Diff esatti

### mission-generic-runtime.mjs

```diff
--- Edge134/mission-generic-runtime.mjs
+++ E70/mission-generic-runtime.mjs
@@ -4555,6 +4555,7 @@
 
 // E68: private authored-source adapters. These issue no work/admission/lease or provider permission.
 const EDITORIAL_DIALOGUE_CAMPAIGN='a8c3c6f9-949d-5b64-8a02-80667c7b4da8';
+const EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN='2bd901b7-6ba6-5319-a55a-2d2e2cfcf03b';
 const EDITORIAL_DIALOGUE_DECISION_FIELDS=['schema_version','source_window_id','source_role_ids','source_evidence','opportunity_id','action_kind','entry_side','world_reaction_intent','npc_intents'];
 const EDITORIAL_DIALOGUE_WRITER_RULE="staff-editorial-dialogue-writer/2. La fonte è un caso editoriale privato: editorial_questions sono domande Staff-authored, non role PG accettate o nuovi fatti pubblicati. Il piano Director ricevuto è la nuova proposta narrativa validata della stessa coppia. Realizza soltanto le iniziative speak/gesture ammesse per i PNG presenti; contenuto, scopo e modo ricevuti orientano la prosa, non sono battute da copiare. Le premesse editoriali non provano consenso o azioni PG. Nessuna scelta PG, consegna, attacco, risultato meccanico o nuova transizione è autorizzata. next_step è soltanto stay: continua l'interazione nella stessa fase, senza impedirne gli sviluppi narrativi consentiti. Memoria e testo rimangono privati, senza pubblicazione o aggiornamento della missione.";
 function editorialDialogueLimits(policy){
@@ -4565,7 +4566,7 @@
 async function editorialDialogueView(source){
  const bad=()=>{throw Error('MISSION_EDITORIAL_DIALOGUE_SOURCE_INVALID');};
  const fields=['schema_version','campaign_id','case_no','author_user_id','historical_anchor_work_id','case_source_id','plan_version_id','plan_sha256','npc_refs','phase_key','snapshot','scene_memory','last_fati','questions'];
- if(!exact(source,fields)||source.schema_version!=='staff-editorial-dialogue-source/1'||source.campaign_id!==EDITORIAL_DIALOGUE_CAMPAIGN
+ if(!exact(source,fields)||source.schema_version!=='staff-editorial-dialogue-source/1'||![EDITORIAL_DIALOGUE_CAMPAIGN,EDITORIAL_DIALOGUE_REVIEW_CAMPAIGN].includes(source.campaign_id)
   ||!Number.isInteger(source.case_no)||source.case_no<1||source.case_no>3
   ||!['author_user_id','historical_anchor_work_id','case_source_id','plan_version_id'].every(k=>uuid(source[k]))||!sha(source.plan_sha256)||!text(source.phase_key))bad();
  const captured=source.snapshot;
```

### mission-staff-editorial-pair.mjs

```diff
--- Edge134/mission-staff-editorial-pair.mjs
+++ E70/mission-staff-editorial-pair.mjs
@@ -3,7 +3,8 @@
 
 const CAMPAIGN='23c83d81-3e37-5a7e-8056-45b009992a3f';
 const DIALOGUE_CAMPAIGN='a8c3c6f9-949d-5b64-8a02-80667c7b4da8';
-const campaignSpec=id=>id===CAMPAIGN?{work:'staff-editorial-work/2',directorSource:'staff-editorial-source/1',writerSource:'staff-editorial-paired-writer-source/1',director:createStaffEditorialDirector,writer:createStaffPairedEditorialWriter}:id===DIALOGUE_CAMPAIGN?{work:'staff-editorial-work/3',directorSource:'staff-editorial-dialogue-source/1',writerSource:'staff-editorial-dialogue-writer-source/1',director:createStaffDialogueEditorialDirector,writer:createStaffDialogueEditorialWriter}:null;
+const DIALOGUE_REVIEW_CAMPAIGN='2bd901b7-6ba6-5319-a55a-2d2e2cfcf03b';
+const campaignSpec=id=>id===CAMPAIGN?{work:'staff-editorial-work/2',directorSource:'staff-editorial-source/1',writerSource:'staff-editorial-paired-writer-source/1',director:createStaffEditorialDirector,writer:createStaffPairedEditorialWriter}:(id===DIALOGUE_CAMPAIGN||id===DIALOGUE_REVIEW_CAMPAIGN)?{work:'staff-editorial-work/3',directorSource:'staff-editorial-dialogue-source/1',writerSource:'staff-editorial-dialogue-writer-source/1',director:createStaffDialogueEditorialDirector,writer:createStaffDialogueEditorialWriter}:null;
 const factoryFor=(work,variant)=>{const spec=campaignSpec(work.campaign_id);if(!spec||work.source?.schema_version!==spec[variant==='director'?'directorSource':'writerSource'])throw Error('E68_SOURCE_BINDING');return spec[variant];};
 const UUID=/^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/i;
 const SHA=/^[a-f0-9]{64}$/;
```

### mission-editorial-staff.mjs

```diff
--- Published/mission-editorial-staff.mjs
+++ E70/mission-editorial-staff.mjs
@@ -54,6 +54,8 @@
 export const PAIR_CAMPAIGN='23c83d81-3e37-5a7e-8056-45b009992a3f';
 export const DIALOGUE_BUILD='staff-editorial-dialogue-ui/1';
 export const DIALOGUE_CAMPAIGN='a8c3c6f9-949d-5b64-8a02-80667c7b4da8';
+export const REVIEW_BUILD='staff-editorial-review69-ui/1';
+export const REVIEW_CAMPAIGN='2bd901b7-6ba6-5319-a55a-2d2e2cfcf03b';
 const PAIR_SHA=/^[0-9a-f]{64}$/;
 const pairExact=(v,keys)=>v!==null&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===keys.length&&keys.every(k=>Object.hasOwn(v,k));
 const pairId=v=>v===null||UUID.test(v||'');
```

### mission-generic-ui.mjs

```diff
--- Published/mission-generic-ui.mjs
+++ E70/mission-generic-ui.mjs
@@ -1,7 +1,7 @@
 import {createStaffAbortController,guardStaffAbortClient,staffAbortJournalSessions,staffAbortBlocked} from './staff-simulation-abort-ui.mjs?v=abort-availability-d092961883b6fe3e';
 import {createStaffFatoRegen} from './mission-staff-fato-regen.v1.mjs?v=fato-display-8cdf2250a8562d83';
-import {createStaffEditorial,createStaffEditorialPair,DIALOGUE_CAMPAIGN,DIALOGUE_BUILD} from './mission-editorial-staff.mjs?v=editorial68-003770c9b5d6fcf3';
-export const VERSION='mission-combat64-ui/5-editorial68-dialogue';
+import {createStaffEditorial,createStaffEditorialPair,DIALOGUE_CAMPAIGN,DIALOGUE_BUILD,REVIEW_CAMPAIGN,REVIEW_BUILD} from './mission-editorial-staff.mjs?v=editorial70-c3168a3664c231f2';
+export const VERSION='mission-combat64-ui/5-editorial70-review69';
 const STAFF_TEST_ROOM='0b85f354-9cdb-47e1-baf9-3d266bb7e06b';
 const id=()=>crypto.randomUUID();
 const clone=x=>structuredClone(x);
@@ -39,6 +39,7 @@
  const editorial=createStaffEditorial({client,identity,isStaff,currentLocation,staffRoom:STAFF_TEST_ROOM});
  const editorialPair=createStaffEditorialPair({client,identity,isStaff,currentLocation,staffRoom:STAFF_TEST_ROOM});
  const editorialDialogue=createStaffEditorialPair({client,identity,isStaff,currentLocation,staffRoom:STAFF_TEST_ROOM,campaign:DIALOGUE_CAMPAIGN,build:DIALOGUE_BUILD,title:'Nuove domande ai PNG · Staff',description:'Tre situazioni editoriali con domande diverse: nuova proposta Director e nuovo Fato privato, senza inviare role o modificare la missione.',caseLabels:['Fatti e aggiunte personali','Motivazioni e dissenso','Rettifica nel mercato']});
+ const editorialReview=createStaffEditorialPair({client,identity,isStaff,currentLocation,staffRoom:STAFF_TEST_ROOM,campaign:REVIEW_CAMPAIGN,build:REVIEW_BUILD,title:'Verifica E69 · Staff',description:'Tre nuove prove private sulle stesse situazioni e domande del confronto precedente, con le istruzioni aggiornate. Gli esiti della missione restano invariati.',caseLabels:['Fatti e aggiunte personali','Motivazioni e dissenso','Rettifica nel mercato']});
  const valid=(user)=>!!user&&identity()===user;
  async function rpc(name,args,user=identity(),diagnosticCode=false){
   if(!valid(user))throw Error('Accedi nuovamente per continuare.');
@@ -3427,6 +3428,7 @@
   editorial.mount(host);
   editorialPair.mount(host);
   editorialDialogue.mount(host);
+  editorialReview.mount(host);
   if(roomReadFlight){if(options.hintRead===true)roomDirtyHint=true;return roomReadFlight;}
   const task=readRoomOnce(host,options),user=identity(),location=currentLocation()?.id,epoch=roomEpoch;
   const flight=Promise.resolve(task).finally(()=>{if(roomReadFlight!==flight)return;roomReadFlight=null;
@@ -3580,5 +3582,5 @@
   if(roomHost)void updateRoom(roomHost,{manual:true});
   return {handled:true,receipt};
  }
- return {editor,board,decorateBoard,updateRoom,submitRole,chatPublication,isNarrativeRoom,automaticCombatReadAllowed,legacyScenePollingAllowed,sessionId:()=>roomState?.session_id,dispose(){editorialDialogue.dispose();editorialPair.dispose();editorial.dispose();eventRecoveryFeedback.clear();roomReadReady=null;roomReadFlight=null;roomDirtyHint=false;for(const c of aborts.values())c.dispose();aborts.clear();abortActor=null;regen.dispose();roomEpoch++;roomRead=null;roomScope=null;roomHost=null;roomState=null;roomSignature='';roomError='';entryState=null;entryPending=null;entryError='';if(currentDialog)currentDialog.close();},version:VERSION};
+ return {editor,board,decorateBoard,updateRoom,submitRole,chatPublication,isNarrativeRoom,automaticCombatReadAllowed,legacyScenePollingAllowed,sessionId:()=>roomState?.session_id,dispose(){editorialReview.dispose();editorialDialogue.dispose();editorialPair.dispose();editorial.dispose();eventRecoveryFeedback.clear();roomReadReady=null;roomReadFlight=null;roomDirtyHint=false;for(const c of aborts.values())c.dispose();aborts.clear();abortActor=null;regen.dispose();roomEpoch++;roomRead=null;roomScope=null;roomHost=null;roomState=null;roomSignature='';roomError='';entryState=null;entryPending=null;entryError='';if(currentDialog)currentDialog.close();},version:VERSION};
 }
```

### land.html

```diff
--- Published/land.html
+++ E70/land.html
@@ -15128,7 +15128,7 @@
       }
       function missionGenericUI(){
         if(MISSION_GENERIC_UI)return Promise.resolve(MISSION_GENERIC_UI);
-    if(!MISSION_GENERIC_LOAD)MISSION_GENERIC_LOAD=import('./mission-generic-ui.mjs?v=editorial68-74000407048f109b').then(function(mod){
+    if(!MISSION_GENERIC_LOAD)MISSION_GENERIC_LOAD=import('./mission-generic-ui.mjs?v=editorial70-c29a5709ec6d271b').then(function(mod){
           MISSION_GENERIC_UI=mod.createMissionUI({client:sb,isEventReadMode:landPureReadMode,creationEditor:function(mission,title,revision){return missionCreationUI().then(function(ui){return ui.editor(mission,title,revision);});},creationBoard:function(mission,title){return missionCreationUI().then(function(ui){return ui.routeBoard(mission,title);});},identity:function(){return !ordinarySigningOut&&loggedIn&&ordinaryAuthId===myId?myId:null;},
             isStaff:function(){return !!iAmStaff;},currentLocation:function(){return cur;},notice:toast,
             createRecoveryFeedback:function(){var revision=toastRevision;return function(message){if(revision!==toastRevision)return;toast(message);revision=toastRevision;};},
```
