const KEY='rig_lift_save_v1';
export function saveGame(data){ localStorage.setItem(KEY, JSON.stringify(data)); }
export function loadGame(){ try{ return JSON.parse(localStorage.getItem(KEY)||'null'); }catch{return null;} }
