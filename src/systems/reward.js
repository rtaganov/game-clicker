export function updateRewards(state,dt){
  const c=state.getCargo(),r=state.getRig(),m=state.getMechanism();
  if(state.currentHeight>1){
    state.holdTime+=dt;
    const mps=c.rewardBase*(1+state.currentHeight/10)*(1+r.holdBonus+state.mod('hold_bonus')+m.holdEfficiency*0.5)*(1+state.mod('hold_reward'));
    state.attemptMoney+=mps*dt;
  }
}
export function finishAttempt(state,failed=false){
  const c=state.getCargo();
  const previousBest=state.bestHeights[c.id]||0;
  const isRecord=state.bestHeightAttempt>previousBest;
  if(isRecord){ state.bestHeights[c.id]=state.bestHeightAttempt; state.pushMessage('New Record'); }
  const successMultiplier=failed?0.4:1;
  const rep=(c.reputationBase*successMultiplier+(isRecord?2:0))*(1+state.mod('rep_gain'));
  state.money+=failed?0:state.attemptMoney;
  state.reputation+=rep;
  state.unlockByReputation();
  state.resetAttempt();
}
