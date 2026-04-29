const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
export function applyLift(state,dt){
  const c=state.getCargo(),r=state.getRig(),m=state.getMechanism();
  const weightRatio=c.weight/r.maxWeight;
  const stabilityBonus=state.mod('stability');
  const weightPenalty=clamp(weightRatio*0.35,0,0.35)*(1-stabilityBonus*0.35);
  const heatRatio=state.currentHeat/m.overheatThreshold;
  const heatFactor=heatRatio<0.7?1:clamp(1-(heatRatio-0.7)*2.5,0.25,1);
  const liftSpeed=(m.liftSpeedBase*(1+state.mod('lift_speed'))+state.activeClickBoost)*(1-weightPenalty)*heatFactor;
  if(state.state!=='overheating'&&state.liftHeld){ state.currentHeight+=liftSpeed*dt; state.state='lifting'; }
  else { state.currentHeight-=Math.max(0.35, c.instability*0.6)*dt; if(state.state!=='overheating')state.state='idle'; }
  const holdDrop=Math.max(0.05,c.instability*0.9-(r.holdBonus+state.mod('hold_bonus'))-m.holdEfficiency*0.4);
  if(!state.liftHeld && state.currentHeight>0.2){ state.currentHeight-=holdDrop*dt; }
  state.currentHeight=clamp(state.currentHeight,0,30);
  state.activeClickBoost=Math.max(0,state.activeClickBoost-dt*0.9);
  if(state.currentHeight>state.bestHeightAttempt) state.bestHeightAttempt=state.currentHeight;
}
export function triggerClickLift(state){
  if(state.state==='overheating'||state.state==='failed') return;
  const c=state.getCargo(),r=state.getRig();
  if(c.weight>r.maxWeight){ state.pushMessage('Too Heavy for Current Rig'); return; }
  const m=state.getMechanism();
  state.activeClickBoost+=m.clickPower*(1+state.mod('click_power'));
  state.currentHeat=Math.min(m.heatMax,state.currentHeat+m.heatGainPerClick*(1-state.mod('heat_gain')));
}
