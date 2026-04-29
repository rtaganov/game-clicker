export const cargos = [
  { id:'crate', name:'Wooden Crate', weight:8, rewardBase:1.2, reputationBase:3, instability:0.05, unlockReputation:0 },
  { id:'sandbag', name:'Sandbag', weight:14, rewardBase:1.9, reputationBase:5, instability:0.12, unlockReputation:35 },
  { id:'washer', name:'Washing Machine', weight:26, rewardBase:3.2, reputationBase:9, instability:0.2, unlockReputation:110 },
  { id:'piano', name:'Piano', weight:42, rewardBase:5.5, reputationBase:16, instability:0.33, unlockReputation:260 },
];
export const rigs = [
  { id:'basic_rope', name:'Basic Rope', maxWeight:14, stability:0.55, durabilityMax:100, wearResistance:0.75, holdBonus:0, cost:0 },
  { id:'thick_rope', name:'Thick Rope / Cable', maxWeight:22, stability:0.68, durabilityMax:125, wearResistance:0.9, holdBonus:0.08, cost:120 },
  { id:'reinforced_sling', name:'Reinforced Sling', maxWeight:38, stability:0.82, durabilityMax:165, wearResistance:1.1, holdBonus:0.18, cost:420 },
  { id:'steel_cable', name:'Steel Cable', maxWeight:60, stability:0.92, durabilityMax:220, wearResistance:1.35, holdBonus:0.3, cost:1200 },
];
export const mechanisms = [
  { id:'beam', name:'Rope Over Beam', liftSpeedBase:0.8, clickPower:0.55, heatMax:100, heatGainPerClick:13, heatCoolRate:11, overheatThreshold:80, holdEfficiency:0.25, cost:0 },
  { id:'pulley', name:'Simple Pulley', liftSpeedBase:1.05, clickPower:0.65, heatMax:105, heatGainPerClick:11, heatCoolRate:12, overheatThreshold:82, holdEfficiency:0.4, cost:180 },
  { id:'tackle', name:'Tackle', liftSpeedBase:1.2, clickPower:0.7, heatMax:115, heatGainPerClick:9, heatCoolRate:14, overheatThreshold:85, holdEfficiency:0.6, cost:550 },
  { id:'winch', name:'Hand Winch', liftSpeedBase:1.55, clickPower:0.95, heatMax:110, heatGainPerClick:14, heatCoolRate:13, overheatThreshold:78, holdEfficiency:0.78, cost:1500 },
];
export const upgrades = [
  {id:'lift_speed',name:'+Lift Speed',baseCost:60,maxLevel:8,effect:l=>0.08*l},
  {id:'click_power',name:'+Click Power',baseCost:50,maxLevel:8,effect:l=>0.06*l},
  {id:'heat_gain',name:'-Heat Gain',baseCost:70,maxLevel:8,effect:l=>0.04*l},
  {id:'cooling_rate',name:'+Cooling Rate',baseCost:75,maxLevel:8,effect:l=>0.07*l},
  {id:'durability',name:'+Durability',baseCost:85,maxLevel:8,effect:l=>0.1*l},
  {id:'stability',name:'+Stability',baseCost:80,maxLevel:8,effect:l=>0.06*l},
  {id:'hold_reward',name:'+Hold Reward',baseCost:90,maxLevel:8,effect:l=>0.08*l},
  {id:'rep_gain',name:'+Reputation Gain',baseCost:95,maxLevel:8,effect:l=>0.08*l},
  {id:'safe_handling',name:'+Safe Handling',baseCost:105,maxLevel:8,effect:l=>0.07*l},
  {id:'hold_bonus',name:'+Hold Bonus',baseCost:100,maxLevel:8,effect:l=>0.06*l},
];
