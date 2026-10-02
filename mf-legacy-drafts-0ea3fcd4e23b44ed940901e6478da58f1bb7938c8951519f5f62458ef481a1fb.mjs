// Mission Factory · recupero conservativo Rapid/1. Solo bozze già esistenti.
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const node=(tag,text='')=>{const el=document.createElement(tag);el.textContent=text;return el;};
const errorText=e=>e?.message||'Lettura delle bozze precedenti non riuscita.';

export function mountLegacyDrafts({host,client,existingOnly,mountRapidExisting,notice=()=>{}}={}) {
  if (!(host instanceof Element)||!client?.rpc||existingOnly!==true) throw Error('Recupero legacy disponibile solo per bozze esistenti.');
  let alive=true, busy=false, cursor=null, generation=0, editor=null;
  const shell=node('section');shell.className='mission-factory-legacy-drafts';
  const title=node('h3','Bozze precedenti');
  const help=node('p','Qui ritrovi le bozze Rapid originali. ID, contenuti e versioni restano nel loro archivio.');
  const status=node('p');status.setAttribute('role','status');status.setAttribute('aria-live','polite');
  const list=node('div'), detail=node('div');
  const more=node('button','Carica altre bozze');more.type='button';more.hidden=true;
  const refresh=node('button','Aggiorna elenco');refresh.type='button';
  shell.append(title,help,refresh,status,list,more,detail);host.replaceChildren(shell);
  async function rpc(name,args){const out=await client.rpc(name,args);if(out?.error)throw out.error;return out?.data??out;}
  function setStatus(message){if(alive)status.textContent=message;}
  function itemLabel(item){return `${item.title||'Bozza senza titolo'} · ${item.state} · ${item.updated_at||'data non disponibile'}`;}
  async function open(id){
    if(!UUID.test(id)||!alive)return;
    const stamp=++generation;editor?.dispose?.();editor=null;detail.replaceChildren();setStatus('Lettura della bozza…');
    try{
      const snap=await rpc('mission_rapid_legacy_read_v1',{p_draft:id});
      if(!alive||stamp!==generation)return;
      if(snap?.schema_version!=='mission-rapid-legacy-read/1'||snap.draft_id!==id||!['queued','claimed','draft','failed','published'].includes(snap.state)||!Number.isSafeInteger(snap.control_version))throw Error('Risposta legacy non compatibile.');
      detail.append(node('h4',snap.title||'Bozza Rapid'),node('p',`ID bozza: ${snap.draft_id} · versione ${snap.control_version} · stato ${snap.state}`));
      if(snap.state==='published')detail.append(node('p',`Missione già pubblicata: ${snap.mission_id||'ID non disponibile'}. La ricevuta originale resta nel percorso Rapid.`));
      else if(snap.state==='draft'){
        if(typeof mountRapidExisting!=='function'){detail.append(node('p','L’editor di recupero non è ancora collegato. La bozza originale resta intatta.'));}
        else{
          const slot=node('div');detail.append(slot);
          editor=await mountRapidExisting({host:slot,snapshot:snap,existingOnly:true});
          if(!alive||stamp!==generation){editor?.dispose?.();return;}
        }
      }else detail.append(node('p','La compilazione non è una bozza modificabile. Usa la richiesta originale nel percorso Rapid autorizzato.'));
      setStatus('Bozza originale letta senza conversione.');
    }catch(e){if(alive&&stamp===generation)setStatus(errorText(e));}
  }
  async function load({reset=false}={}){
    if(!alive||busy)return;busy=true;refresh.disabled=more.disabled=true;
    if(reset){cursor=null;list.replaceChildren();}
    setStatus('Caricamento bozze precedenti…');
    try{
      const data=await rpc('mission_rapid_legacy_list_v1',{p_cursor:cursor,p_limit:25});
      if(!alive)return;
      if(data?.schema_version!=='mission-rapid-legacy-list/1'||!Array.isArray(data.items))throw Error('Elenco legacy non compatibile.');
      for(const item of data.items){
        if(!UUID.test(item.draft_id||'')||!['queued','claimed','draft','failed','published'].includes(item.state))throw Error('Identità di bozza legacy non valida.');
        const row=node('div');row.className='mission-factory-legacy-row';
        const button=node('button','Apri');button.type='button';button.addEventListener('click',()=>{void open(item.draft_id);});
        row.append(node('span',itemLabel(item)),button);list.append(row);
      }
      cursor=data.next_cursor||null;more.hidden=!cursor;
      setStatus(data.items.length?`${data.items.length} bozze caricate.`:'Nessuna bozza precedente in questa pagina.');
    }catch(e){setStatus(errorText(e));notice(errorText(e));}
    finally{busy=false;if(alive){refresh.disabled=more.disabled=false;}}
  }
  refresh.addEventListener('click',()=>{void load({reset:true});});
  more.addEventListener('click',()=>{void load();});
  void load({reset:true});
  return {open,refresh:()=>load({reset:true}),dispose:()=>{alive=false;generation++;editor?.dispose?.();host.replaceChildren();}};
}
