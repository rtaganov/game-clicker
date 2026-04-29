export function updateHeat(state,dt){
  const m=state.getMechanism();
  const c=state.getCargo(),r=state.getRig();
  const activelyLifting=state.state==='lifting' && c.weight<=r.maxWeight;

  if(activelyLifting){
    const continuousHeat=m.heatGainPerClick*0.7*(1-state.mod('heat_gain'));
    state.currentHeat=Math.min(m.heatMax,state.currentHeat+continuousHeat*dt);
  }

  state.currentHeat=Math.max(0,state.currentHeat-m.heatCoolRate*(1+state.mod('cooling_rate'))*dt);

  if(state.currentHeat>=m.overheatThreshold&&state.state!=='overheating'){
    state.state='overheating';
    state.pushMessage('Overheated');
  }
  if(state.state==='overheating'&&state.currentHeat<=m.overheatThreshold*0.65){
    state.state='idle';
    state.pushMessage('Recovered from Overheat');
  }
}
