export function drawScene(ctx,state){
  const w=ctx.canvas.width,h=ctx.canvas.height;
  ctx.clearRect(0,0,w,h);
  ctx.fillStyle='#101826';ctx.fillRect(0,0,w,h);
  ctx.fillStyle='#3a4c33';ctx.fillRect(0,h-50,w,50);
  ctx.strokeStyle='#8ba2bf';ctx.lineWidth=2;ctx.beginPath();ctx.moveTo(70,30);ctx.lineTo(70,h-50);ctx.stroke();
  for(let i=0;i<=30;i+=5){ const y=h-50-(i/30)*(h-100); ctx.fillStyle='#9ab'; ctx.fillText(i+'m',20,y+4); ctx.strokeStyle='#334'; ctx.beginPath(); ctx.moveTo(62,y); ctx.lineTo(80,y); ctx.stroke(); }
  ctx.strokeStyle='#ccc';ctx.lineWidth=5;ctx.beginPath();ctx.moveTo(230,20);ctx.lineTo(230,h-50);ctx.stroke();
  ctx.fillStyle='#667';ctx.fillRect(160,15,150,12);
  const cy=h-50-(state.currentHeight/30)*(h-110);
  ctx.strokeStyle='#e8dfc6';ctx.lineWidth=2;ctx.beginPath();ctx.moveTo(230,27);ctx.lineTo(230,cy);ctx.stroke();
  ctx.fillStyle=state.state==='failed'?'#9a2930':'#bb8f3b';ctx.fillRect(195,cy,70,45);
  ctx.fillStyle='#111';ctx.fillText(state.getCargo().name,198,cy+25);
}
