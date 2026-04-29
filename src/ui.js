import { cargos, rigs, mechanisms, upgrades } from './data.js';
import { upgradeCost } from './systems/upgrades.js';

export function initUI(game){
  const $=id=>document.getElementById(id);
  const nodes={money:$('money'),reputation:$('reputation'),state:$('state'),messages:$('messages'),heatBar:$('heatBar'),durabilityBar:$('durabilityBar'),heatText:$('heatText'),durabilityText:$('durabilityText'),height:$('height'),bestHeight:$('bestHeight'),holdTime:$('holdTime'),currentCargo:$('currentCargo'),currentRig:$('currentRig'),currentMech:$('currentMech'),debug:$('debugPanel')};
  const liftBtn=$('liftBtn'),finishBtn=$('finishBtn');
  const cargoList=$('cargoList'),rigList=$('rigList'),mechList=$('mechList'),upgradeList=$('upgradeList');

  liftBtn.addEventListener('mousedown',()=>{game.liftHeld=true;game.liftClick();});
  window.addEventListener('mouseup',()=>game.liftHeld=false);
  liftBtn.addEventListener('mouseleave',()=>game.liftHeld=false);
  liftBtn.addEventListener('touchstart',(e)=>{e.preventDefault();game.liftHeld=true;game.liftClick();},{passive:false});
  window.addEventListener('touchend',()=>game.liftHeld=false);
  window.addEventListener('keydown',(e)=>{ if(e.code==='Space'){ e.preventDefault(); game.liftHeld=true; game.liftClick(); }});
  window.addEventListener('keyup',(e)=>{ if(e.code==='Space') game.liftHeld=false; });
  finishBtn.addEventListener('click',()=>game.finish());

  const cargoButtons=new Map(), rigButtons=new Map(), mechButtons=new Map(), upgradeButtons=new Map();

  for(const c of cargos){ const b=document.createElement('button'); b.onclick=()=>game.selectCargo(c.id); cargoButtons.set(c.id,b); cargoList.appendChild(b); }
  for(const r of rigs){ const b=document.createElement('button'); b.onclick=()=>game.buyRig(r.id); rigButtons.set(r.id,b); rigList.appendChild(b); }
  for(const m of mechanisms){ const b=document.createElement('button'); b.onclick=()=>game.buyMechanism(m.id); mechButtons.set(m.id,b); mechList.appendChild(b); }
  for(const u of upgrades){ const b=document.createElement('button'); b.onclick=()=>{
      const lvl=game.upgradeLevels[u.id]||0; const cost=upgradeCost(u,lvl);
      if(lvl>=u.maxLevel||game.money<cost) return;
      game.money-=cost; game.upgradeLevels[u.id]=lvl+1;
      if(u.id==='durability') game.currentDurability=game.getRig().durabilityMax*(1+game.mod('durability'));
    }; upgradeButtons.set(u.id,b); upgradeList.appendChild(b);
  }

  function updateLists(){
    for(const c of cargos){ const b=cargoButtons.get(c.id); const unlocked=game.unlockedCargo.has(c.id); b.textContent=unlocked?`${c.name} (W:${c.weight})`:`${c.name} (Unlock Rep ${c.unlockReputation})`; b.disabled=!unlocked; b.classList.toggle('selected',game.selectedCargo===c.id); }
    for(const r of rigs){ const b=rigButtons.get(r.id); const owned=game.ownedRigs.has(r.id); b.textContent=owned?`${r.name} (Cap ${r.maxWeight})`:`Buy ${r.name} - $${r.cost}`; b.disabled=!owned && game.money<r.cost; b.classList.toggle('selected',game.selectedRig===r.id); }
    for(const m of mechanisms){ const b=mechButtons.get(m.id); const owned=game.ownedMechanisms.has(m.id); b.textContent=owned?`${m.name}`:`Buy ${m.name} - $${m.cost}`; b.disabled=!owned && game.money<m.cost; b.classList.toggle('selected',game.selectedMechanism===m.id); }
    for(const u of upgrades){ const lvl=game.upgradeLevels[u.id]||0; const cost=upgradeCost(u,lvl); const b=upgradeButtons.get(u.id); b.textContent=`${u.name} Lv ${lvl}/${u.maxLevel} - $${cost}`; b.disabled=lvl>=u.maxLevel||game.money<cost; }
  }

  return { render(){
    updateLists();
    const c=game.getCargo(),r=game.getRig(),m=game.getMechanism();
    const best=game.bestHeights[c.id]||0;
    nodes.money.textContent=game.money.toFixed(2); nodes.reputation.textContent=game.reputation.toFixed(1); nodes.state.textContent=game.state;
    nodes.messages.textContent=game.message;
    nodes.height.textContent=game.currentHeight.toFixed(2); nodes.bestHeight.textContent=best.toFixed(2); nodes.holdTime.textContent=game.holdTime.toFixed(2);
    nodes.currentCargo.textContent=c.name; nodes.currentRig.textContent=r.name; nodes.currentMech.textContent=m.name;
    nodes.heatText.textContent=`${game.currentHeat.toFixed(1)} / ${m.heatMax}`; nodes.durabilityText.textContent=`${game.currentDurability.toFixed(1)} / ${(r.durabilityMax*(1+game.mod('durability'))).toFixed(1)}`;
    const hp=Math.min(100,game.currentHeat/m.heatMax*100); nodes.heatBar.style.width=`${hp}%`; nodes.heatBar.style.background=hp<60?'#22c55e':hp<85?'#f59e0b':'#ef4444';
    const dp=Math.max(0,Math.min(100,game.currentDurability/(r.durabilityMax*(1+game.mod('durability')))*100)); nodes.durabilityBar.style.width=`${dp}%`; nodes.durabilityBar.style.background=dp>50?'#5aa7ff':dp>25?'#f59e0b':'#ef4444';
    nodes.debug.textContent=`liftHeld=${game.liftHeld} | clickBoost=${game.activeClickBoost.toFixed(2)} | h=${game.currentHeight.toFixed(2)} | heat=${game.currentHeat.toFixed(2)} | dura=${game.currentDurability.toFixed(2)} | state=${game.state} | load=${c.weight}/${r.maxWeight}`;
  }};
}
