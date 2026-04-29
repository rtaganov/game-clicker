export function updateDurability(state,dt){
  const c=state.getCargo(),r=state.getRig(),m=state.getMechanism();
  let danger=0;
  if(state.currentHeat>m.overheatThreshold*0.9) danger++;
  if(c.weight/r.maxWeight>0.9) danger++;
  if(state.currentHeight>15&&state.holdTime>4) danger++;
  const safeCut=1-state.mod('safe_handling')*0.6;
  const loss=danger*(1.2/(r.wearResistance*(1+state.mod('durability'))))*safeCut;
  state.currentDurability-=loss*dt;
  if(state.currentDurability<=0){ state.currentDurability=0; state.state='failed'; state.currentHeight=0; state.holdTime=0; state.pushMessage('Attempt Failed'); }
}
