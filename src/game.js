import { cargos, rigs, mechanisms, upgrades } from './data.js';
import { loadGame, saveGame } from './save.js';
import { applyLift, triggerClickLift } from './systems/lift.js';
import { updateHeat } from './systems/heat.js';
import { updateDurability } from './systems/durability.js';
import { updateRewards, finishAttempt } from './systems/reward.js';
import { umod } from './systems/upgrades.js';

export class Game {
  constructor(){
    const save=loadGame();
    this.money=save?.money??0; this.reputation=save?.reputation??0;
    this.unlockedCargo=new Set(save?.unlockedCargo??['crate']);
    this.ownedRigs=new Set(save?.ownedRigs??['basic_rope']);
    this.ownedMechanisms=new Set(save?.ownedMechanisms??['beam']);
    this.selectedCargo=save?.selectedCargo??'crate'; this.selectedRig=save?.selectedRig??'basic_rope'; this.selectedMechanism=save?.selectedMechanism??'beam';
    this.upgradeLevels=save?.upgradeLevels??{}; this.bestHeights=save?.bestHeights??{};
    this.upgradeDefs=upgrades; this.state='idle'; this.message=''; this.messageTimer=0;
    this.resetAttempt(); this.liftHeld=false;
  }
  getCargo(){return cargos.find(c=>c.id===this.selectedCargo);} getRig(){return rigs.find(r=>r.id===this.selectedRig);} getMechanism(){return mechanisms.find(m=>m.id===this.selectedMechanism);}  
  mod(id){ return umod(this,id); }
  resetAttempt(){ const rig=this.getRig(); this.currentHeight=0; this.bestHeightAttempt=0; this.currentHeat=0; this.currentDurability=rig.durabilityMax*(1+this.mod('durability')); this.holdTime=0; this.attemptMoney=0; this.activeClickBoost=0; if(this.state!=='failed') this.state='idle'; }
  pushMessage(m){ this.message=m; this.messageTimer=2.5; }
  unlockByReputation(){ for(const c of cargos){ if(this.reputation>=c.unlockReputation&&!this.unlockedCargo.has(c.id)){ this.unlockedCargo.add(c.id); this.pushMessage('Cargo Unlocked: '+c.name);} } }
  buyRig(id){ const r=rigs.find(x=>x.id===id); if(this.ownedRigs.has(id)){ this.selectedRig=id; return;} if(this.money>=r.cost){this.money-=r.cost;this.ownedRigs.add(id);this.selectedRig=id;this.resetAttempt();} }
  buyMechanism(id){ const m=mechanisms.find(x=>x.id===id); if(this.ownedMechanisms.has(id)){ this.selectedMechanism=id; return;} if(this.money>=m.cost){this.money-=m.cost;this.ownedMechanisms.add(id);this.selectedMechanism=id;this.resetAttempt();} }
  selectCargo(id){ if(this.unlockedCargo.has(id)){ this.selectedCargo=id; this.resetAttempt(); } }
  liftClick(){ triggerClickLift(this); }
  finish(){ finishAttempt(this,this.state==='failed'); }
  tick(dt){
    if(this.messageTimer>0){ this.messageTimer-=dt; if(this.messageTimer<=0)this.message=''; }
    if(this.state==='failed') return;
    applyLift(this,dt); updateHeat(this,dt); updateDurability(this,dt); updateRewards(this,dt);
  }
  persist(){ saveGame({money:this.money,reputation:this.reputation,unlockedCargo:[...this.unlockedCargo],ownedRigs:[...this.ownedRigs],ownedMechanisms:[...this.ownedMechanisms],selectedCargo:this.selectedCargo,selectedRig:this.selectedRig,selectedMechanism:this.selectedMechanism,upgradeLevels:this.upgradeLevels,bestHeights:this.bestHeights}); }
}
