import { Game } from './game.js';
import { initUI } from './ui.js';
import { drawScene } from './render.js';

const game=new Game();
const ui=initUI(game);
const ctx=document.getElementById('gameCanvas').getContext('2d');
let last=performance.now(), saveAccumulator=0;
function frame(now){
  const dt=Math.min(0.05,(now-last)/1000); last=now;
  game.tick(dt); ui.render(); drawScene(ctx,game);
  saveAccumulator+=dt; if(saveAccumulator>2){ game.persist(); saveAccumulator=0; }
  requestAnimationFrame(frame);
}
requestAnimationFrame(frame);
window.addEventListener('beforeunload',()=>game.persist());
