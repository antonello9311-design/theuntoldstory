import {createPanelController} from './controller.mjs';
import {mountPanelView} from './view.mjs';
import {insist} from './validate.mjs';

// Host unico per le due superfici. Nessuna chiamata alla costruzione e nessun
// fallback verso invii legacy: il testo viaggia soltanto nel commit atomico.
export function mountPanelSurface({root,client,contextKey,locationId,onConfirmed=()=>{},onDraft=()=>{},renderers={}}){
  insist(root?.ownerDocument&&typeof client?.rpc==='function'&&typeof contextKey==='function','mount_configuration');
  let disposed=false,view;
  const controller=createPanelController({
    locationId,contextKey:()=>disposed?null:contextKey(),
    rpc:async(name,args)=>{const response=await client.rpc(name,args);if(response.error)throw Error('transport_unconfirmed');return response.data;},
    onChange:model=>{if(!disposed){view?.render(model);onDraft(model);}}
  });
  const invoke=fn=>async(...args)=>{if(disposed)return null;try{return await fn(...args);}catch(e){if(!disposed)controller.reportInteractionError(e);return null;}};
  async function read(){if(!await controller.readState())return false;const m=controller.snapshot();if(m.envelope?.viewer.can_command&&!m.pending)return controller.readOptions();return true;}
  async function send(retry=false){
    const key=contextKey(),before=controller.snapshot(),receipt=await(retry?controller.retry():controller.submit());
    if(receipt&&!disposed&&contextKey()===key)await onConfirmed(receipt,before.narrativeText);
    return receipt;
  }
  view=mountPanelView(root,{
    readState:invoke(read),readOptions:invoke(()=>controller.readOptions()),
    selectActor:invoke(async actor=>{if(await controller.selectActor(actor))return controller.readOptions();return false;}),
    selectOffer:invoke(id=>controller.selectOffer(id)),selectOption:invoke((group,id,on)=>controller.selectOption(group,id,on)),
    setInput:invoke((id,value)=>controller.setInput(id,value)),setNarrative:invoke(value=>controller.setNarrative(value)),
    prepare:invoke(()=>send(false)),retry:invoke(()=>send(true))
  },renderers);
  view.render(controller.snapshot());
  return {
    open:invoke(read),
    refresh:invoke(()=>controller.readState()),
    setNarrative:invoke(value=>controller.setNarrative(value)),
    submit:invoke(()=>send(false)),
    invalidate:()=>{if(!disposed)controller.invalidate();},
    dispose:()=>{disposed=true;controller.clear();view.clear();},
    snapshot:()=>controller.snapshot()
  };
}
