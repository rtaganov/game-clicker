export const uval=(state,id)=>state.upgradeLevels[id]||0;
export const umod=(state,id)=>state.upgradeDefs.find(u=>u.id===id).effect(uval(state,id));
export function upgradeCost(u,l){ return Math.floor(u.baseCost*Math.pow(1.45,l)); }
