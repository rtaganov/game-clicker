export function updateHeat(state,dt){
  const m=state.getMechanism();
  state.currentHeat=Math.max(0,state.currentHeat-m.heatCoolRate*(1+state.mod('cooling_rate'))*dt);
  if(state.currentHeat>=m.overheatThreshold&&state.state!=='overheating'){ state.state='overheating'; state.pushMessage('Overheated'); }
  if(state.state==='overheating'&&state.currentHeat<=m.overheatThreshold*0.65){ state.state='idle'; }
}
