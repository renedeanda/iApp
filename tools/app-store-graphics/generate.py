#!/usr/bin/env python3
"""
App Store Graphics Generator  —  Kindling portfolio tool
====================================================

Single source of truth for every app in your portfolio's App Store
screenshot generator. One rendering ENGINE (CSS + JS) + a compact per-app CONFIG
(palette, font, feature screens) emits a self-contained HTML file per
repo that opens straight in a browser — no build step, no dependencies.

Each generated page lets you:
  * drop your own screenshots into every slot,
  * flip "First image" (Bold hero / Plain caption) and
    "Screenshots" (Soft panel / Device frame) live,
  * pick a locale + download every graphic at the exact App Store size:
        iPhone 6.9"  1320 x 2868   (one shelf auto-scales to every iPhone)
        iPad   13"   2064 x 2752
        Mac          2880 x 1800   (universal apps only)
  * download a whole locale, or every locale × device, as one organized .zip.

Exports are flattened opaque (no alpha) PNG or JPEG, RGB — App Store ready.
Android is intentionally omitted — this tool targets iOS/macOS.

Usage:
    python3 generate.py            # write every app file + the mega reference
    python3 generate.py --list     # list apps and their output paths

The same ENGINE powers tools/app-store-graphics/index.html
(the mega reference: an app switcher across every config), which the
/new-app flow reuses — see README.md.
"""

import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.environ.get("APP_STORE_GRAPHICS_ROOT", HERE)
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from i18n_data import SAMPLE_I18N
from theme_data import (SAMPLE_THEMES, SAMPLE_DEFAULTS, DOT_THEMES, DOT_DEFAULTS,
                        PLANNER_THEMES, PLANNER_DEFAULTS)


def _luminance(hexc):
    h = hexc.lstrip("#"); ch = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    f = lambda c: (c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4)
    return 0.2126 * f(ch[0]) + 0.7152 * f(ch[1]) + 0.0722 * f(ch[2])

def _contrast(a, b):
    L = sorted([_luminance(a), _luminance(b)]); return (L[1] + 0.05) / (L[0] + 0.05)

def _deepen(accent, bg, target=3.2):
    # richer shade of the SAME accent until it clears the AA-large bar on bg
    r, g, b = [int(accent.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
    light = _luminance(bg) > 0.5
    for _ in range(160):
        if _contrast("#%02X%02X%02X" % (r, g, b), bg) >= target:
            break
        if light:
            r, g, b = int(r * 0.95), int(g * 0.95), int(b * 0.95)
        else:
            r, g, b = min(255, int(r + (255 - r) * 0.07)), min(255, int(g + (255 - g) * 0.07)), min(255, int(b + (255 - b) * 0.07))
    return "#%02X%02X%02X" % (r, g, b)

# Derive a legible HEADLINE colour per theme: the exact accent where it already meets the
# AA-large 3:1 bar (most themes), otherwise a deeper shade of the SAME accent. Keeps the
# colourful accent headline while guaranteeing legibility on every theme. The brighter
# accent still appears on the flame / dots.
for _reg in (SAMPLE_THEMES, DOT_THEMES, PLANNER_THEMES):
    for _t in _reg.values():
        _t["head"] = _t["accent"] if _contrast(_t["accent"], _t["bg"]) >= 3.2 else _deepen(_t["accent"], _t["bg"])

# ---------------------------------------------------------------------------
#  ENGINE — shared CSS
# ---------------------------------------------------------------------------
CSS = r"""
:root { color-scheme: light dark; }
* { box-sizing: border-box; }
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  margin: 0; padding: 0 24px 80px;
  background: #11131a; color: #e8e9ee;
}
.wrap { max-width: 1380px; margin: 0 auto; }
header.page { padding: 34px 0 10px; }
header.page h1 { margin: 0 0 4px; font-size: 26px; letter-spacing: -0.02em; }
header.page p { margin: 0; color: #9aa0ad; font-size: 14px; line-height: 1.5; }
.controls {
  position: sticky; top: 0; z-index: 50;
  display: flex; flex-wrap: wrap; gap: 22px; align-items: center;
  margin: 18px 0 8px; padding: 14px 18px;
  background: rgba(24,27,36,0.92); backdrop-filter: blur(12px);
  border: 1px solid #2a2e3a; border-radius: 14px;
}
.controls .grp { display: flex; align-items: center; gap: 8px; }
.controls .lbl { font-size: 12px; text-transform: uppercase; letter-spacing: 0.08em; color: #8b91a0; margin-right: 2px; }
.seg { display: inline-flex; background: #20242f; border: 1px solid #2f3442; border-radius: 10px; padding: 3px; }
.seg button {
  border: 0; background: transparent; color: #b9bfca; cursor: pointer;
  font-size: 13px; font-weight: 600; padding: 7px 13px; border-radius: 7px; transition: all .15s;
}
.seg button.on { background: #e8e9ee; color: #14161d; }
select.appsel {
  background: #20242f; color: #e8e9ee; border: 1px solid #2f3442;
  border-radius: 10px; padding: 9px 12px; font-size: 14px; font-weight: 600; min-width: 190px;
}
.note { color: #8b91a0; font-size: 12.5px; line-height: 1.5; margin: 6px 2px 0; }
h2.sec { font-size: 20px; margin: 40px 0 4px; letter-spacing: -0.01em; }
h2.sec span { color: #8b91a0; font-weight: 500; font-size: 15px; margin-left: 8px; }
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(290px, 1fr)); gap: 26px; margin-top: 18px; }
.grid.mac { grid-template-columns: repeat(auto-fill, minmax(440px, 1fr)); }
.card { background: #181b24; border: 1px solid #262a36; border-radius: 16px; padding: 16px; }
.card .prev { width: 100%; border-radius: 10px; overflow: hidden; margin-bottom: 12px; box-shadow: 0 4px 18px rgba(0,0,0,0.35); }
.card .prev svg { display: block; width: 100%; height: auto; }
.card .cap { font-size: 12.5px; color: #9aa0ad; margin: 0 2px 10px; font-weight: 600; }
.row { display: flex; gap: 8px; }
.row input[type=file] { flex: 1; min-width: 0; font-size: 12px; color: #9aa0ad; }
.row input[type=file]::file-selector-button {
  background: #2a2e3a; color: #d7dbe3; border: 0; border-radius: 8px;
  padding: 7px 11px; margin-right: 9px; font-weight: 600; cursor: pointer;
}
button.dl {
  border: 0; border-radius: 9px; padding: 9px 14px; cursor: pointer;
  font-weight: 700; font-size: 12.5px; white-space: nowrap;
  background: #4f7cff; color: #fff; transition: background .15s;
}
button.dl:hover { background: #3d6af0; }
button.dlall {
  border: 0; border-radius: 10px; padding: 9px 15px; cursor: pointer;
  font-weight: 700; font-size: 13px; background: #2a2e3a; color: #e8e9ee;
}
button.dlall:hover { background: #343a48; }
"""

# ---------------------------------------------------------------------------
#  ENGINE — shared JS  (operates on a global `APP`)
# ---------------------------------------------------------------------------
JS = r"""
const SIZES = {
  iphone: { w: 1242, h: 2688, ow: 1320, oh: 2868, label: 'iPhone 6.9″', sc: '6.9',
            alts: [{ ow: 1242, oh: 2688, label: 'iPhone 6.5″', sc: '6.5' }] },
  ipad:   { w: 2048, h: 2732, ow: 2064, oh: 2752, label: 'iPad 13″',    sc: '13',
            alts: [{ ow: 2048, oh: 2732, label: 'iPad 12.9″',  sc: '12.9' }] },
  mac:    { w: 2880, h: 1800, ow: 2880, oh: 1800, label: 'Mac',          sc: 'mac' }
};
// Each iPhone/iPad device exports at BOTH Apple-approved sizes from ONE layout: the
// current 6.9″/13″ (1320×2868 / 2064×2752) AND the long-proven 6.5″/12.9″
// (1242×2688 / 2048×2732) that the original hand-tested graphics shipped — Apple
// accepts both, so we emit both and you upload whichever the listing wants. The
// design space (w/h) is authored once; each size is just a different export viewBox.
function sizesFor(dev){ const z=SIZES[dev]; const base={ ow:z.ow, oh:z.oh, label:z.label, sc:z.sc }; return z.alts ? [base].concat(z.alts) : [base]; }
// w/h = design space the cards + GEO are authored in; ow/oh = the exact App
// Store px the PNG exports at (the SVG viewBox stretches design→export; the
// aspect deltas are <0.5%, invisible). Apple 2026 required sizes: one 6.9″
// iPhone shelf (1320×2868) auto-scales to every smaller iPhone; 13″ iPad is
// 2064×2752; Mac 2880×1800. Exports are flattened opaque (no transparent px).
const state = { first: 'hero', shot: 'panel', locale: 'en', fmt: 'png', wordmark: 'off', hsize: 'md', mark: 'glyph', shots: {} };
function HS(){ return state.hsize==='sm'?0.86:(state.hsize==='lg'?1.16:1); }   /* headline size scale */

/* ---- color helpers ---- */
function hx(h){ h=h.replace('#',''); if(h.length===3) h=h.split('').map(c=>c+c).join(''); return {r:parseInt(h.slice(0,2),16),g:parseInt(h.slice(2,4),16),b:parseInt(h.slice(4,6),16)}; }
function th(r,g,b){ const f=x=>('0'+Math.max(0,Math.min(255,Math.round(x))).toString(16)).slice(-2); return '#'+f(r)+f(g)+f(b); }
function darken(h,a){ const c=hx(h); return th(c.r*(1-a),c.g*(1-a),c.b*(1-a)); }
function lighten(h,a){ const c=hx(h); return th(c.r+(255-c.r)*a,c.g+(255-c.g)*a,c.b+(255-c.b)*a); }
function lum(h){ const c=hx(h); const f=v=>{v/=255; return v<=0.03928? v/12.92 : Math.pow((v+0.055)/1.055,2.4);}; return 0.2126*f(c.r)+0.7152*f(c.g)+0.0722*f(c.b); }
function ink(h){ return lum(h)>0.5 ? '#16181D' : '#FFFFFF'; }
function esc(s){ return (''+s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

/* ---- font / weights ---- */
// font-family for SVG text. The app's Latin family first, then named system CJK +
// Arabic faces before the generic — so PNG export (SVG-in-<img> rasterize) renders
// ja/ko/zh/ar glyphs the Latin webfont lacks, instead of tofu. Present on macOS.
function fam(){ return APP.font.replace(/,\s*(sans-serif|serif)\s*$/, ", 'PingFang SC','Hiragino Sans','Hiragino Kaku Gothic ProN','Apple SD Gothic Neo','Microsoft YaHei','Noto Sans CJK SC','Noto Sans CJK JP','Noto Sans CJK KR','Geeza Pro','Noto Naskh Arabic', $1"); }
function hw(){ return APP.hw || 800; }
function sw(){ return APP.sw || 500; }
function headColor(s){ return APP.headlineUseAccent === false ? APP.text : s.accent; }

/* ---- multi-line text ---- */
function tlines(arr,x,y,lh,attr){
  return '<text '+attr+' x="'+x+'" y="'+y+'">'+
    arr.map((t,i)=>'<tspan x="'+x+'"'+(i?' dy="'+lh+'"':'')+'>'+esc(t)+'</tspan>').join('')+'</text>';
}

/* ---- screenshot region renderers ---------------------------------------
   reg = { x, w, top, bleed, encY, encH, r }
   panel: rounded-top, bleeds off the bottom edge (the reference look)
   frame: fully-enclosed device with bezel + dynamic-island pill
------------------------------------------------------------------------- */
function regPanel(reg,dev,i,tint,tintOp,strokeOp){
  const {x,w,top,bleed,r}=reg, x2=x+w, yb=bleed, cid='cp-'+dev+'-'+i;
  const d='M '+x+','+yb+' L '+x+','+(top+r)+' A '+r+','+r+' 0 0,1 '+(x+r)+','+top+
          ' L '+(x2-r)+','+top+' A '+r+','+r+' 0 0,1 '+x2+','+(top+r)+' L '+x2+','+yb+' Z';
  return '<defs><clipPath id="'+cid+'"><path d="'+d+'"/></clipPath></defs>'+
    '<path d="'+d+'" fill="'+tint+'" fill-opacity="'+tintOp+'" stroke="'+tint+'" stroke-width="3" stroke-opacity="'+strokeOp+'"/>'+
    '<image id="shot-'+dev+'-'+i+'" x="'+x+'" y="'+top+'" width="'+w+'" preserveAspectRatio="xMinYMin slice" clip-path="url(#'+cid+')" opacity="0"/>';
}
function regFrame(reg,dev,i,tint,tintOp){
  const {x,w,encY,encH,r}=reg, cid='cf-'+dev+'-'+i, bz=Math.round(w*0.022);
  const bx=x-bz, by=encY-bz, bw=w+bz*2, bh=encH+bz*2, br=r+bz;
  const iw=w*0.34, ih=Math.round(w*0.045), ix=x+(w-iw)/2, iy=encY+Math.round(w*0.028), ir=ih/2;
  return '<defs><clipPath id="'+cid+'"><rect x="'+x+'" y="'+encY+'" width="'+w+'" height="'+encH+'" rx="'+r+'" ry="'+r+'"/></clipPath></defs>'+
    '<rect x="'+bx+'" y="'+by+'" width="'+bw+'" height="'+bh+'" rx="'+br+'" ry="'+br+'" fill="#0C0D11" stroke="rgba(255,255,255,0.16)" stroke-width="2"/>'+
    '<rect x="'+x+'" y="'+encY+'" width="'+w+'" height="'+encH+'" rx="'+r+'" ry="'+r+'" fill="'+tint+'" fill-opacity="'+tintOp+'"/>'+
    '<image id="shot-'+dev+'-'+i+'" x="'+x+'" y="'+encY+'" width="'+w+'" height="'+encH+'" preserveAspectRatio="xMidYMin slice" clip-path="url(#'+cid+')" opacity="0"/>'+
    '<rect x="'+ix+'" y="'+iy+'" width="'+iw+'" height="'+ih+'" rx="'+ir+'" ry="'+ir+'" fill="#0C0D11"/>';
}
function regPlaceholder(reg,dev,i,color){
  const cx=reg.x+reg.w/2, cy = state.shot==='frame' ? reg.encY+reg.encH/2 : (reg.top+reg.bleed)/2;
  const sz = dev==='ipad'?48:(dev==='mac'?40:36);
  return '<text id="ph-'+dev+'-'+i+'" x="'+cx+'" y="'+cy+'" font-size="'+sz+'" font-weight="600" text-anchor="middle" fill="'+color+'" font-family="-apple-system,system-ui,sans-serif">Drop '+SIZES[dev].label+' screenshot</text>';
}
function shotMarkup(reg,dev,i,tint,tintOp,strokeOp,phColor){
  const body = state.shot==='frame' ? regFrame(reg,dev,i,tint,tintOp) : regPanel(reg,dev,i,tint,tintOp,strokeOp);
  return body + regPlaceholder(reg,dev,i,phColor);
}

/* ---- geometry per device ---- */
const GEO = {
  iphone: {
    cap:  { ex:621, ey:300, esz:180, h1:480, hlh:110, hsz:88, suby:710, susz:42, sublh:55,
            reg:{x:121,w:1000,top:850,bleed:2688,encY:905,encH:1650,r:92} },
    hero: { gx:621, gcy:370, gsz:330, ex:621, ey:300, esz:96, namey:600, namesz:44, h1:720, hlh:110, hsz:100,
            subgap:56, susz:46, sublh:58,
            reg:{x:151,w:940,top:1430,bleed:2688,encY:1450,encH:1120,r:92} }
  },
  ipad: {
    cap:  { ex:1024, ey:450, esz:220, h1:680, hlh:140, hsz:110, suby:970, susz:52, sublh:65,
            reg:{x:200,w:1648,top:1140,bleed:2732,encY:1190,encH:1430,r:74} },
    hero: { gx:1024, gcy:480, gsz:460, ex:1024, ey:470, esz:140, namey:780, namesz:60, h1:920, hlh:150, hsz:132,
            subgap:70, susz:60, sublh:78,
            reg:{x:300,w:1448,top:1900,bleed:2732,encY:1920,encH:720,r:80} }
  }
};

/* ---- signature glyphs — replace the emoji with per-app art ---- */
function gdot(x,y,r,fill,op){ return '<circle cx="'+x+'" cy="'+y+'" r="'+r+'" fill="'+fill+'"'+(op!=null?' fill-opacity="'+op+'"':'')+'/>'; }
function glyph(motif,cx,cy,sz,col,o){
  o=o||{}; const de=o.de||'rgba(0,0,0,0.12)', dark=!!o.dark, z=o.zones||['#34D399','#F59E0B','#FB7185'];
  let s='';
  if(motif==='dotgrid'){                         // dot-grid — the year in dots (denser on the hero)
    const cols=o.hero?11:7, rows=o.hero?7:5, gap=sz/cols, r=gap*0.30, x0=cx-(cols-1)*gap/2, y0=cy-(rows-1)*gap/2, n=cols*rows, fill=Math.round(n*0.62);
    const pal=['#5BD6E8','#FF6FA8','#8B7BFF','#4ED38A','#FFB23D','#FF8A3D','#E0C24D','#D46FE0'];
    for(let i=0;i<n;i++){ const c=i%cols, rw=(i/cols)|0; s+=gdot(x0+c*gap, y0+rw*gap, r, i<fill?(o.multi?pal[i%pal.length]:col):de, null); }
    return s;
  }
  if(motif==='rings'){                            // concentric rings — breathing orb
    s+='<circle cx="'+cx+'" cy="'+cy+'" r="'+(sz*0.50)+'" fill="none" stroke="'+col+'" stroke-width="'+(sz*0.028)+'" stroke-opacity="0.30"/>';
    s+='<circle cx="'+cx+'" cy="'+cy+'" r="'+(sz*0.34)+'" fill="none" stroke="'+col+'" stroke-width="'+(sz*0.034)+'" stroke-opacity="0.55"/>';
    s+='<circle cx="'+cx+'" cy="'+cy+'" r="'+(sz*0.19)+'" fill="'+col+'" fill-opacity="0.16"/>';
    return s+gdot(cx,cy,sz*0.07,col,null);
  }
  if(motif==='orbits'){                           // orbits — items on orbits, by zone
    const r1=sz*0.50, r2=sz*0.32;
    s+='<ellipse cx="'+cx+'" cy="'+cy+'" rx="'+r1+'" ry="'+(r1*0.64)+'" fill="none" stroke="'+col+'" stroke-width="'+(sz*0.02)+'" stroke-opacity="0.40"/>';
    s+='<ellipse cx="'+cx+'" cy="'+cy+'" rx="'+r2+'" ry="'+(r2*0.64)+'" fill="none" stroke="'+col+'" stroke-width="'+(sz*0.02)+'" stroke-opacity="0.60"/>';
    s+=gdot(cx,cy,sz*0.075,col,null);
    s+=gdot(cx+r2,cy,sz*0.05,z[0],null);
    s+=gdot(cx-r1*0.72,cy+r1*0.64*0.55,sz*0.05,z[1],null);
    return s+gdot(cx+r1*0.55,cy-r1*0.64*0.7,sz*0.05,z[2],null);
  }
  if(motif==='heatmap'){                          // heatmap — contribution grid
    const cols=7, rows=4, gap=sz/cols, cell=gap*0.72, rx=cell*0.3, x0=cx-(cols-1)*gap/2-cell/2, y0=cy-(rows-1)*gap/2-cell/2;
    const op=[0.18,0.5,0.9,0.3,0.7,1,0.22,0.6,0.85,0.4,1,0.28,0.55,0.8,0.95,0.35,0.7,0.2,0.9,0.5,0.62,0.32,0.8,1,0.45,0.66,0.24,0.92];
    for(let i=0;i<cols*rows;i++){ const c=i%cols, rw=(i/cols)|0; s+='<rect x="'+(x0+c*gap)+'" y="'+(y0+rw*gap)+'" width="'+cell+'" height="'+cell+'" rx="'+rx+'" ry="'+rx+'" fill="'+col+'" fill-opacity="'+op[i%op.length]+'"/>'; }
    return s;
  }
  if(motif==='kanban'){                           // kanban — three columns, a card in Done
    const cw=sz*0.27, gap=sz*0.075, h=sz*0.84, x0=cx-(cw*3+gap*2)/2, y=cy-h/2, colbg=dark?'rgba(255,255,255,0.10)':'rgba(0,0,0,0.05)';
    for(let k=0;k<3;k++){ const x=x0+k*(cw+gap);
      s+='<rect x="'+x+'" y="'+y+'" width="'+cw+'" height="'+h+'" rx="'+(sz*0.04)+'" fill="'+colbg+'"/>';
      s+='<rect x="'+(x+cw*0.13)+'" y="'+(y+sz*0.08)+'" width="'+(cw*0.74)+'" height="'+(sz*0.13)+'" rx="'+(sz*0.025)+'" fill="'+col+'" fill-opacity="'+(k===2?1:0.32)+'"/>';
      if(k<2) s+='<rect x="'+(x+cw*0.13)+'" y="'+(y+sz*0.26)+'" width="'+(cw*0.74)+'" height="'+(sz*0.13)+'" rx="'+(sz*0.025)+'" fill="'+col+'" fill-opacity="0.20"/>';
    }
    return s;
  }
  if(motif==='note'){                             // note — a note with a folded corner
    const w=sz*0.74, h=sz*0.86, x=cx-w/2, y=cy-h/2, fold=sz*0.20;
    s+='<path d="M '+x+' '+y+' L '+(x+w-fold)+' '+y+' L '+(x+w)+' '+(y+fold)+' L '+(x+w)+' '+(y+h)+' L '+x+' '+(y+h)+' Z" fill="'+col+'" fill-opacity="0.12" stroke="'+col+'" stroke-width="'+(sz*0.02)+'" stroke-opacity="0.55"/>';
    s+='<path d="M '+(x+w-fold)+' '+y+' L '+(x+w-fold)+' '+(y+fold)+' L '+(x+w)+' '+(y+fold)+'" fill="'+col+'" fill-opacity="0.30"/>';
    for(let i=0;i<3;i++) s+='<rect x="'+(x+sz*0.12)+'" y="'+(y+sz*0.32+i*sz*0.14)+'" width="'+(w-sz*0.24-(i===2?sz*0.2:0))+'" height="'+(sz*0.045)+'" rx="'+(sz*0.022)+'" fill="'+col+'" fill-opacity="0.45"/>';
    return s;
  }
  if(motif==='trail'){                            // trail — a trail of logged points
    const x=cx, y0=cy-sz*0.5, y1=cy+sz*0.5, ys=[y0+sz*0.06, cy-sz*0.06, cy+sz*0.18, y1-sz*0.04];
    s+='<line x1="'+x+'" y1="'+y0+'" x2="'+x+'" y2="'+y1+'" stroke="'+col+'" stroke-width="'+(sz*0.02)+'" stroke-opacity="0.4"/>';
    ys.forEach((yy,i)=>{ s+=(i===2)?'<circle cx="'+x+'" cy="'+yy+'" r="'+(sz*0.07)+'" fill="none" stroke="'+col+'" stroke-width="'+(sz*0.02)+'"/>':gdot(x,yy,sz*0.07,col,null);
      s+='<line x1="'+(x+sz*0.12)+'" y1="'+yy+'" x2="'+(x+sz*0.36)+'" y2="'+yy+'" stroke="'+col+'" stroke-width="'+(sz*0.018)+'" stroke-opacity="0.5"/>'; });
    return s;
  }
  if(motif==='route'){                            // route — a route between stops
    const x0=cx-sz*0.42, y0=cy+sz*0.36, x1=cx+sz*0.30, y1=cy-sz*0.28;
    s+='<path d="M '+x0+' '+y0+' C '+(cx-sz*0.1)+' '+(cy+sz*0.42)+', '+(cx-sz*0.22)+' '+(cy-sz*0.06)+', '+x1+' '+y1+'" fill="none" stroke="'+col+'" stroke-width="'+(sz*0.035)+'" stroke-linecap="round" stroke-dasharray="'+(sz*0.015)+' '+(sz*0.06)+'" stroke-opacity="0.8"/>';
    s+=gdot(x0,y0,sz*0.055,col,null);
    s+='<path d="M '+x1+' '+(y1-sz*0.20)+' C '+(x1-sz*0.13)+' '+(y1-sz*0.20)+', '+(x1-sz*0.13)+' '+(y1+sz*0.02)+', '+x1+' '+(y1+sz*0.08)+' C '+(x1+sz*0.13)+' '+(y1+sz*0.02)+', '+(x1+sz*0.13)+' '+(y1-sz*0.20)+', '+x1+' '+(y1-sz*0.20)+' Z" fill="'+col+'"/>';
    return s+gdot(x1,y1-sz*0.09,sz*0.035,dark?'#11131a':'#ffffff',0.95);
  }
  if(motif==='fold'){                             // fold — a dog-eared document page
    const w=sz*0.66, h=sz*0.84, x=cx-w/2, y=cy-h/2, f=sz*0.22;
    s+='<path d="M '+x+' '+y+' L '+(x+w-f)+' '+y+' L '+(x+w)+' '+(y+f)+' L '+(x+w)+' '+(y+h)+' L '+x+' '+(y+h)+' Z" fill="'+col+'" fill-opacity="0.08" stroke="'+col+'" stroke-width="'+(sz*0.022)+'" stroke-opacity="0.65"/>';
    s+='<path d="M '+(x+w-f)+' '+y+' L '+(x+w-f)+' '+(y+f)+' L '+(x+w)+' '+(y+f)+'" fill="none" stroke="'+col+'" stroke-width="'+(sz*0.022)+'" stroke-opacity="0.65"/>';
    for(let i=0;i<3;i++) s+='<rect x="'+(x+sz*0.12)+'" y="'+(y+sz*0.36+i*sz*0.13)+'" width="'+(w-sz*0.24-(i===2?sz*0.16:0))+'" height="'+(sz*0.04)+'" rx="'+(sz*0.02)+'" fill="'+col+'" fill-opacity="0.4"/>';
    return s;
  }
  if(motif==='bloom'){                            // bloom — a celebration burst
    const rays=o.hero?12:8, R=sz*0.5;
    for(let i=0;i<rays;i++){ const a=(i/rays)*Math.PI*2-Math.PI/2,
      x1=cx+Math.cos(a)*sz*0.19, y1=cy+Math.sin(a)*sz*0.19, x2=cx+Math.cos(a)*R, y2=cy+Math.sin(a)*R;
      s+='<line x1="'+x1+'" y1="'+y1+'" x2="'+x2+'" y2="'+y2+'" stroke="'+col+'" stroke-width="'+(sz*0.04)+'" stroke-linecap="round" stroke-opacity="0.85"/>';
      s+=gdot(x2,y2,sz*0.042,col,null); }
    return s+gdot(cx,cy,sz*0.14,col,null);
  }
  /* ---- alternates offered in the glyph picker ---- */
  if(motif==='heart'){                            // heart — gratitude
    const w=sz*0.82,h=sz*0.74;
    return '<path d="M '+cx+' '+(cy+h*0.44)+' C '+(cx-w*0.5)+' '+(cy-h*0.06)+', '+(cx-w*0.5)+' '+(cy-h*0.5)+', '+cx+' '+(cy-h*0.16)+' C '+(cx+w*0.5)+' '+(cy-h*0.5)+', '+(cx+w*0.5)+' '+(cy-h*0.06)+', '+cx+' '+(cy+h*0.44)+' Z" fill="'+col+'" fill-opacity="0.16" stroke="'+col+'" stroke-width="'+(sz*0.05)+'" stroke-linejoin="round"/>';
  }
  if(motif==='sun'){                              // sun — a bright day
    const r=sz*0.21;
    for(let i=0;i<8;i++){ const a=i/8*Math.PI*2; s+='<line x1="'+(cx+Math.cos(a)*r*1.55)+'" y1="'+(cy+Math.sin(a)*r*1.55)+'" x2="'+(cx+Math.cos(a)*r*2.25)+'" y2="'+(cy+Math.sin(a)*r*2.25)+'" stroke="'+col+'" stroke-width="'+(sz*0.04)+'" stroke-linecap="round"/>'; }
    return s+'<circle cx="'+cx+'" cy="'+cy+'" r="'+r+'" fill="'+col+'" fill-opacity="0.22" stroke="'+col+'" stroke-width="'+(sz*0.045)+'"/>';
  }
  if(motif==='spark3'){                           // spark3 — three good things
    const star=(x,y,r)=>'<path d="M '+x+' '+(y-r)+' L '+(x+r*0.22)+' '+(y-r*0.22)+' L '+(x+r)+' '+y+' L '+(x+r*0.22)+' '+(y+r*0.22)+' L '+x+' '+(y+r)+' L '+(x-r*0.22)+' '+(y+r*0.22)+' L '+(x-r)+' '+y+' L '+(x-r*0.22)+' '+(y-r*0.22)+' Z" fill="'+col+'"/>';
    return star(cx-sz*0.27,cy+sz*0.22,sz*0.14)+star(cx+sz*0.02,cy-sz*0.02,sz*0.24)+star(cx+sz*0.30,cy-sz*0.26,sz*0.12);
  }
  if(motif==='foldsheet'){                        // foldsheet — a sheet with a folded-up corner
    const w=sz*0.66,h=sz*0.8,x=cx-w/2,y=cy-h/2,f=sz*0.32;
    s+='<path d="M '+x+' '+y+' L '+(x+w)+' '+y+' L '+(x+w)+' '+(y+h-f)+' L '+(x+w-f)+' '+(y+h)+' L '+x+' '+(y+h)+' Z" fill="'+col+'" fill-opacity="0.12" stroke="'+col+'" stroke-width="'+(sz*0.024)+'" stroke-linejoin="round"/>';
    return s+'<path d="M '+(x+w)+' '+(y+h-f)+' L '+(x+w-f)+' '+(y+h-f)+' L '+(x+w-f)+' '+(y+h)+' Z" fill="'+col+'" fill-opacity="0.34"/>';
  }
  if(motif==='pdfstack'){                         // pdfstack — overlapping pages
    const w=sz*0.54,h=sz*0.7;
    s+='<rect x="'+(cx-w/2+sz*0.09)+'" y="'+(cy-h/2-sz*0.07)+'" width="'+w+'" height="'+h+'" rx="'+(sz*0.04)+'" fill="'+col+'" fill-opacity="0.14"/>';
    const fx=cx-w/2-sz*0.05,fy=cy-h/2+sz*0.07,f=sz*0.18;
    s+='<path d="M '+fx+' '+fy+' L '+(fx+w-f)+' '+fy+' L '+(fx+w)+' '+(fy+f)+' L '+(fx+w)+' '+(fy+h)+' L '+fx+' '+(fy+h)+' Z" fill="'+col+'" fill-opacity="0.18" stroke="'+col+'" stroke-width="'+(sz*0.022)+'" stroke-linejoin="round"/>';
    return s+'<path d="M '+(fx+w-f)+' '+fy+' L '+(fx+w-f)+' '+(fy+f)+' L '+(fx+w)+' '+(fy+f)+'" fill="none" stroke="'+col+'" stroke-width="'+(sz*0.022)+'"/>';
  }
  if(motif==='crumbs'){                           // crumbs — a trail of points + flag
    const pts=[[cx-sz*0.22,cy+sz*0.42],[cx+sz*0.04,cy+sz*0.2],[cx-sz*0.06,cy-sz*0.04],[cx+sz*0.16,cy-sz*0.28]];
    for(let i=0;i<pts.length-1;i++) s+='<line x1="'+pts[i][0]+'" y1="'+pts[i][1]+'" x2="'+pts[i+1][0]+'" y2="'+pts[i+1][1]+'" stroke="'+col+'" stroke-width="'+(sz*0.02)+'" stroke-opacity="0.4" stroke-linecap="round"/>';
    for(let i=0;i<pts.length;i++) s+=gdot(pts[i][0],pts[i][1], i===pts.length-1?sz*0.062:sz*0.046, col, null);
    const fx=pts[3][0],fy=pts[3][1];
    s+='<line x1="'+fx+'" y1="'+fy+'" x2="'+fx+'" y2="'+(fy-sz*0.28)+'" stroke="'+col+'" stroke-width="'+(sz*0.02)+'"/>';
    return s+'<path d="M '+fx+' '+(fy-sz*0.28)+' L '+(fx+sz*0.2)+' '+(fy-sz*0.21)+' L '+fx+' '+(fy-sz*0.14)+' Z" fill="'+col+'"/>';
  }
  if(motif==='signpost'){                         // signpost — a wayfinding signpost
    s+='<line x1="'+cx+'" y1="'+(cy-sz*0.42)+'" x2="'+cx+'" y2="'+(cy+sz*0.46)+'" stroke="'+col+'" stroke-width="'+(sz*0.038)+'" stroke-linecap="round"/>';
    const w=sz*0.46,t=sz*0.11,yr=cy-sz*0.2,yl=cy+sz*0.08;
    s+='<path d="M '+(cx-sz*0.04)+' '+(yr-sz*0.085)+' L '+(cx+w-t)+' '+(yr-sz*0.085)+' L '+(cx+w)+' '+yr+' L '+(cx+w-t)+' '+(yr+sz*0.085)+' L '+(cx-sz*0.04)+' '+(yr+sz*0.085)+' Z" fill="'+col+'"/>';
    return s+'<path d="M '+(cx+sz*0.04)+' '+(yl-sz*0.085)+' L '+(cx-w+t)+' '+(yl-sz*0.085)+' L '+(cx-w)+' '+yl+' L '+(cx-w+t)+' '+(yl+sz*0.085)+' L '+(cx+sz*0.04)+' '+(yl+sz*0.085)+' Z" fill="'+col+'" fill-opacity="0.55"/>';
  }
  if(motif==='calendar'||motif==='calcheck'||motif==='calclock'){   // calendar — day-planner marks
    const w=sz*0.74,h=sz*0.72,x=cx-w/2,y=cy-h/2,r=sz*0.05;
    s+='<rect x="'+x+'" y="'+y+'" width="'+w+'" height="'+h+'" rx="'+r+'" fill="'+col+'" fill-opacity="0.12" stroke="'+col+'" stroke-width="'+(sz*0.024)+'"/>';
    s+='<path d="M '+x+' '+(y+sz*0.16)+' L '+x+' '+(y+r)+' Q '+x+' '+y+' '+(x+r)+' '+y+' L '+(x+w-r)+' '+y+' Q '+(x+w)+' '+y+' '+(x+w)+' '+(y+r)+' L '+(x+w)+' '+(y+sz*0.16)+' Z" fill="'+col+'"/>';
    s+='<line x1="'+(x+w*0.3)+'" y1="'+(y-sz*0.05)+'" x2="'+(x+w*0.3)+'" y2="'+(y+sz*0.03)+'" stroke="'+col+'" stroke-width="'+(sz*0.028)+'" stroke-linecap="round"/>';
    s+='<line x1="'+(x+w*0.7)+'" y1="'+(y-sz*0.05)+'" x2="'+(x+w*0.7)+'" y2="'+(y+sz*0.03)+'" stroke="'+col+'" stroke-width="'+(sz*0.028)+'" stroke-linecap="round"/>';
    if(motif==='calendar'){
      const gx0=x+w*0.22,gy0=y+sz*0.34,gw=w*0.28,gh=sz*0.17;
      for(let rr=0;rr<2;rr++)for(let c=0;c<3;c++){ const hi=(rr===0&&c===2); s+='<rect x="'+(gx0+c*gw-sz*0.038)+'" y="'+(gy0+rr*gh-sz*0.038)+'" width="'+(sz*0.076)+'" height="'+(sz*0.076)+'" rx="'+(sz*0.018)+'" fill="'+col+'" fill-opacity="'+(hi?1:0.32)+'"/>'; }
    } else if(motif==='calcheck'){
      s+='<path d="M '+(cx-sz*0.16)+' '+(cy+sz*0.08)+' L '+(cx-sz*0.02)+' '+(cy+sz*0.22)+' L '+(cx+sz*0.2)+' '+(cy-sz*0.14)+'" fill="none" stroke="'+col+'" stroke-width="'+(sz*0.055)+'" stroke-linecap="round" stroke-linejoin="round"/>';
    } else {
      const ccy=cy+sz*0.13,cr=sz*0.16;
      s+='<circle cx="'+cx+'" cy="'+ccy+'" r="'+cr+'" fill="none" stroke="'+col+'" stroke-width="'+(sz*0.035)+'"/>';
      s+='<line x1="'+cx+'" y1="'+ccy+'" x2="'+cx+'" y2="'+(ccy-cr*0.62)+'" stroke="'+col+'" stroke-width="'+(sz*0.03)+'" stroke-linecap="round"/>';
      s+='<line x1="'+cx+'" y1="'+ccy+'" x2="'+(cx+cr*0.5)+'" y2="'+ccy+'" stroke="'+col+'" stroke-width="'+(sz*0.03)+'" stroke-linecap="round"/>';
    }
    return s;
  }
  return '';
}
function iconAt(cx,ey,esz,s,col,o){
  if(!APP.motif) return '<text x="'+cx+'" y="'+ey+'" font-size="'+esz+'" text-anchor="middle">'+s.emoji+'</text>';
  return glyph(APP.motif, cx, ey-esz*0.36, esz, col, o);
}

/* ---- per-screen theme (a themed app rides its real registry; a dot app its dot colors) ---- */
function themeOf(s){
  const dk=(s.dk!==undefined)?s.dk:APP.dark;
  return { bg:s.bg||APP.surface, fg:s.fg||APP.text, mut:s.mut||APP.subText, ph:s.ph||APP.placeholder,
           dk:dk, de:s.de||APP.dotEmpty||(dk?'rgba(255,255,255,0.16)':'rgba(0,0,0,0.10)'),
           hc:(APP.headlineUseAccent===false)?(s.fg||APP.text):s.accent };
}

/* ---- localized copy (locale dimension) ---- */
function L(){ return state.locale || 'en'; }
function scopy(s,i){
  const loc=L(), t=(loc!=='en' && APP.i18n && APP.i18n[loc] && APP.i18n[loc].screens) ? APP.i18n[loc].screens[i] : null;
  return { h:(t&&t.h)||s.h, sub:(t&&t.sub)||s.sub };
}
function heroCopy(s){
  const loc=L(), t=(loc!=='en' && APP.i18n) ? APP.i18n[loc] : null;
  return { h:(t&&t.heroH)||APP.heroH||s.h, sub:(t&&t.heroSub)||APP.heroSub||s.sub };
}
function emojiText(x,y,sz,e){ return '<text x="'+x+'" y="'+y+'" font-size="'+sz+'" text-anchor="middle">'+e+'</text>'; }

/* ---- card builders ----
   Feature cards: per-feature emoji + per-app theme. Hero card: the big
   signature glyph (the app's identity) + value-prop. ---- */
function captionCard(dev,s,i){
  const z=SIZES[dev], g=GEO[dev].cap, ff=fam(), t=themeOf(s), c=scopy(s,i), hs=HS();
  let svg='<rect width="'+z.w+'" height="'+z.h+'" fill="'+t.bg+'"/>';
  svg+=emojiText(g.ex,g.ey,g.esz,s.emoji);
  svg+=tlines(c.h,g.ex,g.h1,Math.round(g.hlh*hs),'font-size="'+Math.round(g.hsz*hs)+'" font-weight="'+hw()+'" text-anchor="middle" fill="'+t.hc+'" font-family="'+ff+'"');
  svg+=tlines(c.sub,g.ex,g.suby,g.sublh,'font-size="'+g.susz+'" font-weight="'+sw()+'" text-anchor="middle" fill="'+t.mut+'" font-family="'+ff+'"');
  svg+=shotMarkup(g.reg,dev,i,s.accent, t.dk?0.14:0.06, t.dk?0.35:0.2, t.ph);
  return svg;
}

function heroCard(dev,s,i){
  const z=SIZES[dev], g=GEO[dev].hero, ff=fam(), gid='hg-'+dev+'-'+i, c=heroCopy(s), hs=HS(), showName=state.wordmark==='on';
  let top,bot,ht,glyphCol,de,nameCol;
  if(APP.dark){ top=lighten(APP.surface,0.06); bot=APP.surface; ht=ink(bot); glyphCol=s.accent; de='rgba(255,255,255,0.18)'; nameCol=s.accent; }
  else { top=darken(s.accent,0.46); bot=darken(s.accent,0.06); ht=ink(top); glyphCol=ht; de='rgba(255,255,255,0.30)'; nameCol=ht; }
  let svg='<defs><linearGradient id="'+gid+'" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="'+top+'"/><stop offset="1" stop-color="'+bot+'"/></linearGradient></defs>';
  svg+='<rect width="'+z.w+'" height="'+z.h+'" fill="url(#'+gid+')"/>';
  svg+= (APP.motif && state.mark!=='emoji') ? glyph(APP.motif,g.gx,g.gcy,g.gsz,glyphCol,{dark:true,de:de,zones:APP.zones,multi:s.multi,hero:true})
                  : emojiText(g.gx, g.gcy+Math.round(g.gsz*0.2), Math.round(g.gsz*0.6), s.emoji);
  if(showName) svg+='<text x="'+g.gx+'" y="'+g.namey+'" font-size="'+g.namesz+'" font-weight="'+hw()+'" letter-spacing="6" text-anchor="middle" fill="'+nameCol+'" fill-opacity="0.95" font-family="'+ff+'">'+esc(APP.name.toUpperCase())+'</text>';
  const headY = showName ? g.h1 : g.namey+24, hlh=Math.round(g.hlh*hs);
  svg+=tlines(c.h,g.gx,headY,hlh,'font-size="'+Math.round(g.hsz*hs)+'" font-weight="'+hw()+'" text-anchor="middle" fill="'+ht+'" font-family="'+ff+'"');
  const subY=headY+c.h.length*hlh+g.subgap;
  svg+=tlines(c.sub,g.gx,subY,g.sublh,'font-size="'+g.susz+'" font-weight="'+sw()+'" text-anchor="middle" fill="'+ht+'" fill-opacity="0.9" font-family="'+ff+'"');
  svg+=shotMarkup(g.reg,dev,i,'#FFFFFF',0.12,0.5,'rgba(255,255,255,0.65)');
  return svg;
}

/* ---- Mac: desktop backdrop + a windowed screenshot with traffic-light chrome.
   The left column carries the value-prop (hero adds the big glyph + wordmark). ---- */
function macWindow(x,y,w,h,tint,tintOp,i,chrome,phc){
  const tb=64, r=20, cid='cm-'+i, light=(chrome!=='dark');
  const win=light?'#F3F3F5':'#1B1D23', bar=light?'#E4E5E9':'#262932', edge=light?'rgba(0,0,0,0.12)':'rgba(255,255,255,0.10)';
  let s='<rect x="'+(x+12)+'" y="'+(y+18)+'" width="'+w+'" height="'+h+'" rx="'+r+'" fill="#000000" fill-opacity="0.18"/>';
  s+='<rect x="'+x+'" y="'+y+'" width="'+w+'" height="'+h+'" rx="'+r+'" ry="'+r+'" fill="'+win+'" stroke="'+edge+'" stroke-width="2"/>';
  s+='<path d="M '+x+' '+(y+tb)+' L '+x+' '+(y+r)+' A '+r+' '+r+' 0 0 1 '+(x+r)+' '+y+' L '+(x+w-r)+' '+y+' A '+r+' '+r+' 0 0 1 '+(x+w)+' '+(y+r)+' L '+(x+w)+' '+(y+tb)+' Z" fill="'+bar+'"/>';
  s+=gdot(x+34,y+tb/2,11,'#FF5F57',null)+gdot(x+70,y+tb/2,11,'#FEBC2E',null)+gdot(x+106,y+tb/2,11,'#28C840',null);
  const sy=y+tb, sh=h-tb;
  s+='<defs><clipPath id="'+cid+'"><rect x="'+x+'" y="'+sy+'" width="'+w+'" height="'+sh+'"/></clipPath></defs>';
  s+='<rect x="'+x+'" y="'+sy+'" width="'+w+'" height="'+sh+'" fill="'+tint+'" fill-opacity="'+tintOp+'" clip-path="url(#'+cid+')"/>';
  s+='<image id="shot-mac-'+i+'" x="'+x+'" y="'+sy+'" width="'+w+'" height="'+sh+'" preserveAspectRatio="xMidYMid slice" clip-path="url(#'+cid+')" opacity="0"/>';
  s+='<text id="ph-mac-'+i+'" x="'+(x+w/2)+'" y="'+(sy+sh/2)+'" font-size="40" font-weight="600" text-anchor="middle" fill="'+phc+'" font-family="-apple-system,system-ui,sans-serif">Drop Mac screenshot (16:10)</text>';
  return s;
}
function macCard(s,i){
  const z=SIZES.mac, ff=fam(), t=themeOf(s), c=scopy(s,i);
  const isHero=(i===0 && state.first==='hero'), lx=600, showName=state.wordmark==='on';
  let svg, ht;
  if(isHero){
    const hc=heroCopy(s);
    let top,bot,gcol;
    if(APP.dark){ top=lighten(APP.surface,0.06); bot=APP.surface; ht=ink(bot); gcol=s.accent; }
    else { top=darken(s.accent,0.46); bot=darken(s.accent,0.06); ht=ink(top); gcol=ht; }
    svg='<defs><linearGradient id="mg-'+i+'" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="'+top+'"/><stop offset="1" stop-color="'+bot+'"/></linearGradient></defs><rect width="'+z.w+'" height="'+z.h+'" fill="url(#mg-'+i+')"/>';
    svg+= (APP.motif && state.mark!=='emoji') ? glyph(APP.motif,lx,520,300,gcol,{dark:true,de:'rgba(255,255,255,0.30)',zones:APP.zones,hero:true}) : emojiText(lx,600,210,s.emoji);
    if(showName) svg+='<text x="'+lx+'" y="800" font-size="46" font-weight="'+hw()+'" letter-spacing="7" text-anchor="middle" fill="'+ht+'" fill-opacity="0.95" font-family="'+ff+'">'+esc(APP.name.toUpperCase())+'</text>';
    const hs=HS(), mhlh=Math.round(108*hs), headY=showName?950:870;
    svg+=tlines(hc.h,lx,headY,mhlh,'font-size="'+Math.round(94*hs)+'" font-weight="'+hw()+'" text-anchor="middle" fill="'+ht+'" font-family="'+ff+'"');
    svg+=tlines(hc.sub,lx,headY+hc.h.length*mhlh+54,52,'font-size="42" font-weight="'+sw()+'" text-anchor="middle" fill="'+ht+'" fill-opacity="0.9" font-family="'+ff+'"');
    svg+=macWindow(1150,360,1600,1080,'#FFFFFF',0.12,i,'dark','rgba(255,255,255,0.5)');
  } else {
    svg='<rect width="'+z.w+'" height="'+z.h+'" fill="'+t.bg+'"/>';
    svg+=emojiText(lx,520,150,s.emoji);
    svg+=tlines(c.h,lx,770,104,'font-size="88" font-weight="'+hw()+'" text-anchor="middle" fill="'+t.hc+'" font-family="'+ff+'"');
    svg+=tlines(c.sub,lx,770+c.h.length*104+44,50,'font-size="40" font-weight="'+sw()+'" text-anchor="middle" fill="'+t.mut+'" font-family="'+ff+'"');
    svg+=macWindow(1150,360,1600,1080, s.accent, t.dk?0.16:0.06, i, t.dk?'dark':'light', t.ph);
  }
  return svg;
}

function buildCardSVG(dev,s,i){
  let inner;
  if(dev==='mac') inner = macCard(s,i);
  else if(i===0 && state.first==='hero') inner = heroCard(dev,s,i);
  else inner = captionCard(dev,s,i);
  const z=SIZES[dev];
  const fn = APP.slug+'-'+dev+'-'+(i+1)+'-'+s.file+(L()!=='en'?'-'+L():'');
  return '<svg id="svg-'+dev+'-'+i+'" data-fn="'+fn+'" viewBox="0 0 '+z.w+' '+z.h+'" xmlns="http://www.w3.org/2000/svg">'+inner+'</svg>';
}

/* ---- render ---- */
function render(){
  const root = document.getElementById('sections');
  let html = '';
  APP.devices.forEach(dev=>{
    const z=SIZES[dev], sizes=sizesFor(dev), multi=sizes.length>1;
    const sizeLabel=sizes.map(x=>x.ow+'×'+x.oh).join(' + ');
    html += '<h2 class="sec">'+z.label+' <span>'+sizeLabel+' px</span> '+
            '<button class="dlall" onclick="dlZip(\''+dev+'\',this)">↓ ZIP · '+L()+' ('+APP.screens.length+(multi?'×'+sizes.length:'')+')</button></h2>';
    html += '<div class="grid'+(dev==='mac'?' mac':'')+'">';
    APP.screens.forEach((s,i)=>{
      const dlBtns=sizes.map((x,si)=>'<button class="dl" onclick="dl(\''+dev+'\','+i+','+si+')">'+(multi?x.sc+'″':x.ow+'×'+x.oh)+'</button>').join('');
      html += '<div class="card">'+
        '<div class="prev">'+buildCardSVG(dev,s,i)+'</div>'+
        '<div class="cap">'+(i+1)+'. '+esc(scopy(s,i).h.join(' '))+'</div>'+
        '<div class="row">'+
          '<input type="file" accept="image/*" onchange="onPick(\''+dev+'\','+i+',this)">'+
          dlBtns+
        '</div></div>';
    });
    html += '</div>';
  });
  root.innerHTML = html;
  applyShots();
}
function applyShots(){
  Object.keys(state.shots).forEach(k=>{
    const el=document.getElementById('shot-'+k);
    if(el){ el.setAttribute('href',state.shots[k]); el.setAttribute('opacity','1');
            const ph=document.getElementById('ph-'+k); if(ph) ph.setAttribute('opacity','0'); }
  });
}
function onPick(dev,i,input){
  const f=input.files[0]; if(!f) return;
  const rd=new FileReader();
  rd.onload=e=>{ state.shots[dev+'-'+i]=e.target.result; applyShots(); };
  rd.readAsDataURL(f);
}

/* ---- download (SVG -> canvas -> PNG) ---- */
/* ---- download (SVG -> canvas -> PNG) ----
   Web fonts referenced only via <link> do NOT render inside the SVG-in-<img>
   rasterization context, so we inline the font as base64 @font-face into the
   SVG before drawing. Fetched once per font, cached. Offline (or if the fetch
   is blocked) → graceful fallback to the system font in the same family. */
const _fontCSS = {};
async function inlineFontCSS(){
  const href = APP.fontHref; if(!href) return '';
  if(_fontCSS[href] !== undefined) return _fontCSS[href];
  _fontCSS[href] = (async () => {
    try {
      const css = await (await fetch(href)).text();
      const urls = [...new Set([...css.matchAll(/url\((https:\/\/[^)]+\.woff2)\)/g)].map(m=>m[1]))];
      const map = {};
      await Promise.all(urls.map(async u => {
        const buf = new Uint8Array(await (await fetch(u)).arrayBuffer());
        let bin=''; for(let i=0;i<buf.length;i++) bin+=String.fromCharCode(buf[i]);
        map[u] = 'data:font/woff2;base64,'+btoa(bin);
      }));
      return css.replace(/url\((https:\/\/[^)]+\.woff2)\)/g, (m,u)=> 'url('+(map[u]||u)+')');
    } catch(e){ return ''; }
  })();
  return _fontCSS[href];
}
function ext(){ return state.fmt==='jpeg'?'jpg':'png'; }
function mime(){ return state.fmt==='jpeg'?'image/jpeg':'image/png'; }
async function rasterize(svgEl, size){
  const z=size||SIZES[svgEl.id.split('-')[1]];
  const clone=svgEl.cloneNode(true);
  clone.setAttribute('width',z.ow); clone.setAttribute('height',z.oh);
  clone.setAttribute('preserveAspectRatio','none');     // design viewBox -> exact export px
  try { await document.fonts.ready; } catch(e){}
  const css = await inlineFontCSS();
  if(css){ const st=document.createElementNS('http://www.w3.org/2000/svg','style'); st.textContent=css; clone.insertBefore(st, clone.firstChild); }
  const data=new XMLSerializer().serializeToString(clone);
  return await new Promise((res,rej)=>{
    const img=new Image();
    img.onload=()=>{ const c=document.createElement('canvas'); c.width=z.ow; c.height=z.oh;
      const ctx=c.getContext('2d'); ctx.fillStyle='#ffffff'; ctx.fillRect(0,0,z.ow,z.oh);   // flatten → no transparent pixels (App Store rejects alpha)
      ctx.drawImage(img,0,0,z.ow,z.oh); c.toBlob(b=>res(b), mime(), state.fmt==='jpeg'?0.95:undefined); };
    img.onerror=rej;
    img.src='data:image/svg+xml;base64,'+btoa(unescape(encodeURIComponent(data)));
  });
}
function saveBlob(blob,fn){
  const u=URL.createObjectURL(blob), a=document.createElement('a');
  a.href=u; a.download=fn; document.body.appendChild(a); a.click(); document.body.removeChild(a);
  setTimeout(()=>URL.revokeObjectURL(u),1000);
}
async function dl(dev,i,si){
  const svg=document.getElementById('svg-'+dev+'-'+i), size=sizesFor(dev)[si||0];
  saveBlob(await rasterize(svg,size), svg.getAttribute('data-fn')+'-'+size.sc+'.'+ext());
}

/* ---- dependency-free STORE-method .zip so a whole locale (or every locale)
        downloads as one organized archive, ready to drag into App Store Connect. */
function crc32(b){ let c=~0; for(let i=0;i<b.length;i++){ c^=b[i]; for(let k=0;k<8;k++) c=(c>>>1)^(0xEDB88320 & -(c&1)); } return ~c>>>0; }
function zipBlob(files){            // files: [{name, data:Uint8Array}]
  const enc=new TextEncoder(), parts=[], cen=[]; let off=0, n=0;
  const u16=v=>[v&255,(v>>8)&255], u32=v=>[v&255,(v>>8)&255,(v>>16)&255,(v>>24)&255];
  for(const f of files){
    const nm=enc.encode(f.name), crc=crc32(f.data), sz=f.data.length;
    const lh=new Uint8Array([80,75,3,4,...u16(20),...u16(0),...u16(0),...u16(0),...u16(0),...u32(crc),...u32(sz),...u32(sz),...u16(nm.length),...u16(0)]);
    parts.push(lh,nm,f.data);
    cen.push(new Uint8Array([80,75,1,2,...u16(20),...u16(20),...u16(0),...u16(0),...u16(0),...u16(0),...u32(crc),...u32(sz),...u32(sz),...u16(nm.length),...u16(0),...u16(0),...u16(0),...u16(0),...u32(0),...u32(off)]),nm);
    off+=lh.length+nm.length+sz; n++;
  }
  let cdSize=0; for(const c of cen) cdSize+=c.length;
  const end=new Uint8Array([80,75,5,6,...u16(0),...u16(0),...u16(n),...u16(n),...u32(cdSize),...u32(off),...u16(0)]);
  return new Blob([...parts,...cen,end],{type:'application/zip'});
}
async function bytes(blob){ return new Uint8Array(await blob.arrayBuffer()); }
async function shoot(dev,folder,files,size){      // every screen of one device+size, current locale
  const sz=size||sizesFor(dev)[0];
  for(let i=0;i<APP.screens.length;i++){
    const svg=document.getElementById('svg-'+dev+'-'+i);
    files.push({name:folder+svg.getAttribute('data-fn')+'.'+ext(), data:await bytes(await rasterize(svg,sz))});
  }
}
async function dlZip(dev,btn){                     // one device (all its sizes), current locale → zip
  const old=btn&&btn.textContent; if(btn) btn.textContent='Zipping…';
  const files=[], sizes=sizesFor(dev);
  for(const size of sizes) await shoot(dev, sizes.length>1?(size.sc+'/'):'', files, size);   // subfolder per size when >1
  saveBlob(zipBlob(files), APP.slug+'-'+dev+'-'+L()+'.zip');
  if(btn) btn.textContent=old;
}
async function dlEverything(){                     // every locale × device × size → one organized zip
  const btn=document.getElementById('dlEvery'), old=btn&&btn.textContent;
  const locs=locales(), keep=state.locale, files=[];
  let done=0, total=0; for(const dev of APP.devices) total+=sizesFor(dev).length; total*=locs.length;
  for(const loc of locs){
    state.locale=loc; render(); await new Promise(r=>setTimeout(r,30));
    for(const dev of APP.devices){
      for(const size of sizesFor(dev)){
        if(btn) btn.textContent='Building '+(++done)+'/'+total+'…';
        await shoot(dev, loc+'/'+size.sc+'/', files, size);     // folder per locale/size, ready to drag into App Store Connect
      }
    }
  }
  state.locale=keep; bootLocales(); render();
  saveBlob(zipBlob(files), APP.slug+'-appstore-screenshots.zip');
  if(btn) btn.textContent=old;
}

/* ---- controls ---- */
function setFirst(v){ state.first=v; syncSeg('first',v); render(); }
function setShot(v){ state.shot=v; syncSeg('shot',v); render(); }
function setWordmark(v){ state.wordmark=v; syncSeg('wordmark',v); render(); }
function setHsize(v){ state.hsize=v; syncSeg('hsize',v); render(); }
function setMark(v){ state.mark=v; syncSeg('mark',v); render(); }
function setFmt(v){ state.fmt=v; syncSeg('fmt',v); }       /* export-only; no re-render */
function syncSeg(name,v){ document.querySelectorAll('[data-seg="'+name+'"] button').forEach(b=>b.classList.toggle('on', b.dataset.val===v)); }

const LOCNAMES={en:'English',es:'Español',de:'Deutsch',fr:'Français',pt:'Português','zh-Hans':'简体中文',zh:'中文',ja:'日本語',ko:'한국어',it:'Italiano',nl:'Nederlands'};
function locales(){ return ['en'].concat(APP.i18n?Object.keys(APP.i18n):[]); }
function setLocale(v){ state.locale=v; render(); }
function bootLocales(){
  const grp=document.getElementById('localeGrp'), sel=document.getElementById('localeSel'); if(!grp||!sel) return;
  const ls=locales();
  if(ls.length<=1){ grp.style.display='none'; state.locale='en'; return; }
  grp.style.display='';
  sel.innerHTML=ls.map(l=>'<option value="'+l+'">'+(LOCNAMES[l]||l)+'</option>').join('');
  if(ls.indexOf(state.locale)<0) state.locale='en';
  sel.value=state.locale;
}

function bootFonts(){
  if(!APP.fontHref) return;
  if(document.querySelector('link[data-app-font]')) document.querySelector('link[data-app-font]').href=APP.fontHref;
  else { const l=document.createElement('link'); l.rel='stylesheet'; l.href=APP.fontHref; l.setAttribute('data-app-font','1'); document.head.appendChild(l); }
}
"""

# Per-page boot (single-app files)
BOOT_SINGLE = r"""
bootFonts(); bootLocales();
if(APP){ if(APP.first) state.first=APP.first; if(APP.mark) state.mark=APP.mark; }
syncSeg('first',state.first); syncSeg('shot',state.shot); syncSeg('fmt',state.fmt); syncSeg('wordmark',state.wordmark); syncSeg('hsize',state.hsize); syncSeg('mark',state.mark);
render();
"""

# ---------------------------------------------------------------------------
#  PAGE TEMPLATES
# ---------------------------------------------------------------------------
CONTROLS_HTML = """
  <div class="controls">
    __APPSEL__
    <div class="grp" id="localeGrp" style="display:none"><span class="lbl">Locale</span>
      <select class="appsel" id="localeSel" style="min-width:120px" onchange="setLocale(this.value)"></select></div>
    <div class="grp"><span class="lbl">First image</span>
      <div class="seg" data-seg="first">
        <button data-val="hero" onclick="setFirst('hero')">Bold hero</button>
        <button data-val="plain" onclick="setFirst('plain')">Plain caption</button>
      </div></div>
    <div class="grp"><span class="lbl">Wordmark</span>
      <div class="seg" data-seg="wordmark">
        <button data-val="off" onclick="setWordmark('off')">Off</button>
        <button data-val="on" onclick="setWordmark('on')">On</button>
      </div></div>
    <div class="grp"><span class="lbl">Headline</span>
      <div class="seg" data-seg="hsize">
        <button data-val="sm" onclick="setHsize('sm')">S</button>
        <button data-val="md" onclick="setHsize('md')">M</button>
        <button data-val="lg" onclick="setHsize('lg')">L</button>
      </div></div>
    <div class="grp"><span class="lbl">Mark</span>
      <div class="seg" data-seg="mark">
        <button data-val="glyph" onclick="setMark('glyph')">Glyph</button>
        <button data-val="emoji" onclick="setMark('emoji')">Emoji</button>
      </div></div>
    <div class="grp"><span class="lbl">Screenshots</span>
      <div class="seg" data-seg="shot">
        <button data-val="panel" onclick="setShot('panel')">Soft panel</button>
        <button data-val="frame" onclick="setShot('frame')">Device frame</button>
      </div></div>
    <div class="grp"><span class="lbl">Format</span>
      <div class="seg" data-seg="fmt">
        <button data-val="png" onclick="setFmt('png')">PNG</button>
        <button data-val="jpeg" onclick="setFmt('jpeg')">JPEG</button>
      </div></div>
    <div class="grp"><button class="dlall" id="dlEvery" onclick="dlEverything()" style="background:#4f7cff;color:#fff">⬇︎ Everything · all locales (zip)</button></div>
  </div>
  <p class="note">Drop a screenshot into any slot (or leave it blank). Toggles restyle every card live; card&nbsp;1 is your App Store hero. <b>Per language:</b> pick a <b>Locale</b>, then <b>↓ ZIP</b> on a device for that locale — or <b>⬇︎ Everything</b> to get every locale × device in one archive organized <code>locale/size/…</code>, ready to upload. Exports are exact App Store px at <b>both Apple-approved sizes</b> — iPhone 6.9″ + 6.5″, iPad 13″ + 12.9″ — so you can upload whichever your listing uses (each auto-scales to every smaller device). Use Chrome; PNG is crispest — switch to JPEG only if a reviewer ever flags an alpha channel.</p>
"""

PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>__TITLE__ — App Store Graphics</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
__FONTLINK__
<style>__CSS__</style>
</head>
<body>
<div class="wrap">
  <header class="page">
    <h1>__TITLE__ — App Store Graphics</h1>
    <p>__SUBTITLE__ · iPhone 1320×2868 (6.9″) · iPad 2064×2752 (13″)__MACNOTE__ · iOS/macOS only (no Android)</p>
  </header>
__CONTROLS__
  <div id="sections"></div>
</div>
<script>const APP = __APPJSON__;</script>
<script>__JS__</script>
<script>__BOOT__</script>
</body>
</html>
"""

# ---------------------------------------------------------------------------
#  FONTS
# ---------------------------------------------------------------------------
def gfont(spec):
    return f'<link href="https://fonts.googleapis.com/css2?family={spec}&display=swap" rel="stylesheet">'

FONTS = {
    "Poppins":       ("'Poppins', -apple-system, system-ui, sans-serif",            "Poppins:wght@500;600;700;800;900"),
    "Space Grotesk": ("'Space Grotesk', -apple-system, system-ui, sans-serif",      "Space+Grotesk:wght@500;600;700"),
    "Nunito":        ("'Nunito', -apple-system, system-ui, sans-serif",            "Nunito:wght@500;600;700;800;900"),
    "Fraunces":      ("'Fraunces', Georgia, 'Times New Roman', serif",             "Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700"),
    "Quicksand":     ("'Quicksand', -apple-system, system-ui, sans-serif",         "Quicksand:wght@500;600;700"),
    "Fredoka":       ("'Fredoka', -apple-system, system-ui, sans-serif",           "Fredoka:wght@400;500;600;700"),
    "Sora":          ("'Sora', -apple-system, system-ui, sans-serif",             "Sora:wght@500;600;700;800"),
    "Newsreader":    ("'Newsreader', Georgia, 'Times New Roman', serif",          "Newsreader:opsz,wght@6..72,500;6..72,600;6..72,700"),
    "Manrope":       ("'Manrope', -apple-system, system-ui, sans-serif",          "Manrope:wght@500;600;700;800"),
}

# ---------------------------------------------------------------------------
#  APP CONFIGS
# ---------------------------------------------------------------------------
# Accent palettes reused across apps
def S(accent, emoji, h, sub, file, **extra):
    # extra: per-screen theme overrides (bg, fg, mut, ph, dk, de) + flags (multi)
    d = {"accent": accent, "emoji": emoji, "h": h, "sub": sub, "file": file}
    d.update(extra)
    return d

APPS = {}

# ---- Sample Notes ----------------------------------------------------------
# A worked example of a themed, multi-device config: rides a real multi-theme
# registry so the graphics ARE the theme system. Glyph: a note w/ folded
# corner. Replace every field with your app's values (or copy BLANK below).
APPS["samplenotes"] = {
    "name": "Sample Notes", "slug": "samplenotes", "font_key": "Poppins", "hw": 800, "sw": 500,
    "out": "out/sample-notes/app-store-graphics.html",
    "subtitle": "A warm notes app that respects your time",
    "surface": "#FAF6F0", "text": "#2C2520", "subText": "#756A5E", "placeholder": "#B8AFA4",
    "dark": False, "headlineUseAccent": True, "motif": "note", "simpleStyle": "flame",
    "themes": SAMPLE_THEMES, "themeDefaults": SAMPLE_DEFAULTS,
    "devices": ["iphone", "ipad", "mac"],
    "heroH": ["Notes that feel", "like home"],
    "heroSub": ["Write beautifully, organize simply,", "and keep your words yours"],
    "i18n": SAMPLE_I18N,
    "screens": [
        S("#D4956A","\U0001F4DD",["Beautiful","Notes"],["A calm, focused editor","for everything you write"],"notes",
          bg="#FAF6F0", fg="#2C2520", mut="#756A5E", ph="#B8AFA4"),                                  # Light
        S("#5A9E7B","✍️",["Markdown","Editor"],["Rich formatting, checklists","& live preview"],"markdown-editor",
          bg="#F0F5F2", fg="#1E2D25", mut="#5A7568", ph="#9BB3A5"),                                  # Sage
        S("#4A90BF","☁️",["iCloud Sync","Everywhere"],["Your notes on every device,","synced automatically & securely"],"icloud-sync",
          bg="#F0F4F8", fg="#1A2533", mut="#536C85", ph="#94ABBD"),                                  # Ocean
        S("#7B9FD4","\U0001F4C2",["Folders &","Tags"],["Organize your way with","folders, tags & search"],"folders-tags",
          bg="#111318", fg="#E3E5EB", mut="#A0A6B6", ph="#5A6178", dk=True),                          # Midnight
        S("#E8A97A","\U0001F512",["Private by","Design"],["Export anytime — your data","always stays yours"],"privacy",
          bg="#1C1A17", fg="#F0EBE3", mut="#C4BCB2", ph="#7A746E", dk=True),                          # Dark
    ],
}

# ---- Sample Dots -----------------------------------------------------------
# A worked example of the dark, dot-grid style: vivid per-screen accents rotate
# to showcase a big theme registry. Rendered dark to match a minimal-dark UI.
APPS["sampledots"] = {
    "name": "Sample Dots", "slug": "sampledots", "font_key": "Space Grotesk", "hw": 700, "sw": 500,
    "out": "out/sample-dots/app-store-graphics.html",
    "subtitle": "Your year, visualized",
    "surface": "#0A0A0A", "text": "#FFFFFF", "subText": "#7C7C7C", "placeholder": "#4A4A4A",
    "dark": True, "headlineUseAccent": True, "motif": "dotgrid", "dotEmpty": "#262626", "simpleStyle": "dotgrid",
    "themes": DOT_THEMES, "themeDefaults": DOT_DEFAULTS,
    "devices": ["iphone", "ipad"],
    "heroH": ["365 dots.","One for each day."],
    "heroSub": ["See your year at a glance and the","moments you're counting down to"],
    "screens": [
        S("#F2F3F7","⚡",["Your Year,","Visualized"],["365 dots, one per day —","see time like never before"],"year-visualized", de="#2A2A2A"),
        S("#FF6FA8","⏳",["Event","Countdowns"],["Count down to the moments","that matter most"],"event-countdowns"),
        S("#8B7BFF","\U0001F4F2",["Home Screen","Widgets"],["Your next event on the Home","& Lock Screen — always in view"],"widgets"),
        S("#FF8A3D","\U0001F3A8",["Themes,","Your Way"],["Solid & gradient themes, dot","shapes & custom colors"],"themes", multi=True),
    ],
}

# Order shown in the mega reference. Add your own apps' keys as you configure them.
ORDER = ["samplenotes", "sampledots"]

# A neutral "blank" preset for the /new-app flow
BLANK = {
    "name": "New App", "slug": "newapp", "font_key": "Poppins", "hw": 800, "sw": 500,
    "subtitle": "Starter preset for /new-app — edit the config",
    "surface": "#F5F3EF", "text": "#1F1B16", "subText": "#7A7268", "placeholder": "#BDB6AC",
    "dark": False, "headlineUseAccent": True, "motif": "note",
    "devices": ["iphone", "ipad"],
    "heroH": ["Your one-line","promise here"],
    "heroSub": ["The benefit a new user feels in","the first ten seconds"],
    "screens": [
        S("#C97B4A","✨",["Headline","Feature"],["One clear benefit per card —","two short lines"],"feature-1"),
        S("#5E8A6B","\U0001F331",["Second","Feature"],["Show, don't tell — pair copy","with a real screenshot"],"feature-2"),
        S("#3A8BC2","☁️",["Sync","Everywhere"],["Your data on every device,","synced automatically"],"feature-3"),
        S("#8A7AC4","\U0001F3A8",["Make It","Yours"],["Themes, options & the","details that delight"],"feature-4"),
        S("#B06A9A","\U0001F512",["Private","by Design"],["On-device & yours —","no accounts, no tracking"],"feature-5"),
    ],
}

# ---------------------------------------------------------------------------
#  BUILD
# ---------------------------------------------------------------------------
def app_json(cfg):
    fam, _ = FONTS[cfg["font_key"]]
    spec = FONTS[cfg["font_key"]][1]
    out = {
        "name": cfg["name"], "slug": cfg["slug"], "subtitle": cfg["subtitle"],
        "font": fam, "fontHref": f"https://fonts.googleapis.com/css2?family={spec}&display=swap",
        "hw": cfg["hw"], "sw": cfg["sw"],
        "surface": cfg["surface"], "text": cfg["text"], "subText": cfg["subText"],
        "placeholder": cfg["placeholder"], "dark": cfg["dark"],
        "headlineUseAccent": cfg["headlineUseAccent"],
        "devices": cfg["devices"], "screens": cfg["screens"],
        "heroH": cfg["heroH"], "heroSub": cfg["heroSub"],
        "motif": cfg.get("motif"),
    }
    if cfg.get("first"):    out["first"] = cfg["first"]   # default first-image mode (hero|caption)
    if cfg.get("mark"):     out["mark"]  = cfg["mark"]    # default hero mark (glyph|emoji)
    if cfg.get("zones"):    out["zones"] = cfg["zones"]
    if cfg.get("dotEmpty"): out["dotEmpty"] = cfg["dotEmpty"]
    if cfg.get("i18n"):     out["i18n"] = cfg["i18n"]
    return out

def build_single(cfg):
    fam, spec = FONTS[cfg["font_key"]]
    fontlink = gfont(spec)
    macnote = " · Mac 2880×1800" if "mac" in cfg["devices"] else ""
    controls = CONTROLS_HTML.replace("__APPSEL__", "")
    html = (PAGE
        .replace("__TITLE__", cfg["name"])
        .replace("__SUBTITLE__", cfg["subtitle"])
        .replace("__MACNOTE__", macnote)
        .replace("__FONTLINK__", fontlink)
        .replace("__CSS__", CSS)
        .replace("__CONTROLS__", controls)
        .replace("__APPJSON__", json.dumps(app_json(cfg), ensure_ascii=False))
        .replace("__JS__", JS)
        .replace("__BOOT__", BOOT_SINGLE))
    return html

def build_mega():
    # all fonts up front so switching apps is instant
    specs = []
    seen = set()
    for key in ORDER + ["__blank__"]:
        cfg = BLANK if key == "__blank__" else APPS[key]
        fk = cfg["font_key"]
        if fk not in seen:
            seen.add(fk); specs.append(FONTS[fk][1])
    fontlinks = "\n".join(gfont(s) for s in specs)

    allcfg = {k: app_json(APPS[k]) for k in ORDER}
    allcfg["__blank__"] = app_json(BLANK)
    options = "".join(
        f'<option value="{k}">{APPS[k]["name"]} — {APPS[k]["subtitle"]}</option>' for k in ORDER
    ) + '<option value="__blank__">＋ New App (blank starter for /new-app)</option>'

    appsel = f'<div class="grp"><span class="lbl">App</span><select class="appsel" id="appsel" onchange="switchApp(this.value)">{options}</select></div>'
    controls = CONTROLS_HTML.replace("__APPSEL__", appsel)

    boot = """
const APPS = __ALL__;
let APP = APPS['samplenotes'];
function applyAppDefaults(){ state.first=(APP&&APP.first)||'hero'; state.mark=(APP&&APP.mark)||'glyph'; }
function switchApp(k){ APP = APPS[k]; applyAppDefaults(); bootFonts(); bootLocales(); syncSeg('first',state.first); syncSeg('mark',state.mark); render(); }
bootFonts(); bootLocales(); applyAppDefaults();
syncSeg('first',state.first); syncSeg('shot',state.shot); syncSeg('fmt',state.fmt); syncSeg('wordmark',state.wordmark); syncSeg('hsize',state.hsize); syncSeg('mark',state.mark);
render();
""".replace("__ALL__", json.dumps(allcfg, ensure_ascii=False))

    html = (PAGE
        .replace("__TITLE__", "Kindling")
        .replace("__SUBTITLE__", "Portfolio App Store graphics — every app, one engine")
        .replace("__MACNOTE__", " · Mac 2880×1800")
        .replace("__FONTLINK__", fontlinks)
        .replace("__CSS__", CSS)
        .replace("__CONTROLS__", controls)
        .replace("__APPJSON__", "null")
        .replace("__JS__", JS)
        .replace("__BOOT__", boot))
    # mega title tweak
    html = html.replace("<title>Kindling — App Store Graphics</title>",
                        "<title>Kindling — Portfolio App Store Graphics</title>")
    return html

# ---------------------------------------------------------------------------
#  SIMPLE / CLASSIC per-app generator
#  A second, deliberately-minimal output alongside the studio: one static page,
#  fixed caption layout, drop-a-screenshot + download-PNG — modelled exactly on
#  proven hand-crafted originals from shipped apps. No toggles, no
#  locale switch (English), no dependencies. It's the "use what works" fallback;
#  the studio (app-store-graphics.html) is the powerful path. Same per-app data,
#  so the two never drift. Geometry below is lifted verbatim from the bespoke SVG.
# ---------------------------------------------------------------------------
SIMPLE_GEOM = {
    "iphone": {"vw":1242,"vh":2688,"gx":100,"gy":200,"ex":521,"emy":100,"emsz":180,
               "t1":280,"t2":390,"tsz":88,"suby":510,"susz":42,"subdy":55,
               "clip":"M 121,2688 L 121,910 A 60,60 0 0,1 181,850 L 1061,850 A 60,60 0 0,1 1121,910 L 1121,2688 Z",
               "imx":121,"imy":850,"imw":1000,"phx":621,"phy":1750,"phsz":36,
               "label":"iPhone","sizes":[(1242,2688,"6.5″"),(1320,2868,"6.9″")]},
    "ipad":   {"vw":2048,"vh":2732,"gx":0,"gy":300,"ex":1024,"emy":150,"emsz":220,
               "t1":380,"t2":520,"tsz":110,"suby":670,"susz":52,"subdy":65,
               "clip":"M 200,2732 L 200,1200 A 60,60 0 0,1 260,1140 L 1788,1140 A 60,60 0 0,1 1848,1200 L 1848,2732 Z",
               "imx":200,"imy":1140,"imw":1648,"phx":1024,"phy":2000,"phsz":48,
               "label":"iPad","sizes":[(2048,2732,"12.9″"),(2064,2752,"13″")]},
}

def _sx(t):  # SVG/HTML-escape
    return str(t).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")

def simple_out(cfg):
    return cfg["out"][:-5] + "-simple.html" if cfg["out"].endswith(".html") else cfg["out"] + "-simple.html"

# The dot-grid Simple style rides only its two anchor themes — Classic (dark) + Snow (light) —
# alternating per screen. Monochrome + minimal by design: no theme chips, no busy grids,
# no faked "value" — the dropped screenshot carries the value, the caption complements it.
def _theme_select(sid, themes, tid):
    # per-card LIVE theme picker (reusable: any app with a `themes` registry gets one)
    opts = "".join('<option value="%s"%s>%s</option>' % (k, " selected" if k == tid else "", _sx(themes[k]["name"])) for k in themes)
    return '<label class="locsel">Theme&nbsp;<select onchange="setCardTheme(\'%s\',this.value)">%s</select></label>' % (sid, opts)

def _btns(cfg, dev, g, s, i, sid):
    base_fn = "%s-%s-%d-%s" % (cfg["slug"], dev, i + 1, s["file"])
    btns = '<input type="file" accept="image/*" onchange="loadImg(\'%s-shot\',\'%s-ph\',this)">' % (sid, sid)
    for (w, h, lbl) in g["sizes"]:
        btns += '<button onclick="dl(\'%s\',%d,%d,\'%s\')">%s · %d×%d</button>' % (sid, w, h, base_fn, lbl, w, h)
    return btns

def _card_div(sid, svg, s, i, btns, extra=""):
    return '<div class="card"><div class="prev">%s</div><div class="cap" id="cap-%s">%d. %s</div>%s<div class="row">%s</div></div>' % (svg, sid, i + 1, _sx(" ".join(s["h"])), extra, btns)

def _title(sid, lines, x, y0, dy, size, weight, fill, font, anchor="middle"):
    o = ""
    for k, line in enumerate(lines):
        o += ('<text id="t-%s-%d" x="%d" y="%d" font-size="%d" font-weight="%s" text-anchor="%s" fill="%s" font-family="%s">%s</text>'
              % (sid, k, x, y0 + k * dy, size, weight, anchor, fill, font, _sx(line)))
    return o

def _subt(sid, lines, x, y0, dy, size, fill, font, anchor="middle", weight="500", italic=False, tid=None):
    st = ' font-style="italic"' if italic else ""
    idattr = (' id="%s"' % tid) if tid else ""
    o = '<text%s x="%d" y="%d" font-size="%d" font-weight="%s" text-anchor="%s" fill="%s" font-family="%s"%s>' % (idattr, x, y0, size, weight, anchor, fill, font, st)
    for k, line in enumerate(lines):
        o += '<tspan id="s-%s-%d" x="%d"%s>%s</tspan>' % (sid, k, x, (' dy="%d"' % dy) if k else "", _sx(line))
    return o + "</text>"

def _shot(g, sid, fill, stroke, sw, ph_fill, pid=None):
    # screenshot drop well (clip + faint fill + image + placeholder) — shared by all per-identity styles
    idattr = (' id="%s"' % pid) if pid else ""
    return ('<defs><clipPath id="%s-clip"><path d="%s"/></clipPath></defs>' % (sid, g["clip"])
        + '<path%s d="%s" fill="%s" stroke="%s" stroke-width="%d"/>' % (idattr, g["clip"], fill, stroke, sw)
        + '<image id="%s-shot" x="%d" y="%d" width="%d" preserveAspectRatio="xMinYMin slice" clip-path="url(#%s-clip)" opacity="0"/>' % (sid, g["imx"], g["imy"], g["imw"], sid)
        + '<text id="%s-ph" x="%d" y="%d" font-size="%d" font-weight="600" text-anchor="middle" fill="%s" font-family="-apple-system,system-ui">Place %s screenshot</text>' % (sid, g["phx"], g["phy"], g["phsz"], ph_fill, g["label"]))

def _dot_row(g, sid, cx, y, on, off, n=12, filled=9):
    # one delicate row of dots — the dot-grid signature, kept minimal (12 = a year of months).
    # Filled dots tag .acc-<sid>, empty dots .ac2-<sid> so the live theme picker recolours them.
    span = int(g["vw"] * 0.34); gap = span // (n - 1); r = int(gap * 0.34)
    sx = cx - span // 2; o = ""
    for c in range(n):
        cls = "acc-" + sid if c < filled else "ac2-" + sid
        o += '<circle class="%s" cx="%d" cy="%d" r="%d" fill="%s"/>' % (cls, sx + c * gap, y, r, on if c < filled else off)
    return o

def _shot_round(g, sid, fill, stroke, sw, ph_fill, bottom, r):
    # fully rounded screenshot well (all four corners) — matches an iOS screenshot's shape
    x = g["imx"]; y = g["imy"]; w = g["imw"]; h = g["vh"] - y - bottom
    o = ('<defs><clipPath id="%s-clip"><rect x="%d" y="%d" width="%d" height="%d" rx="%d"/></clipPath></defs>' % (sid, x, y, w, h, r)
        + '<rect x="%d" y="%d" width="%d" height="%d" rx="%d" fill="%s"/>' % (x, y, w, h, r, fill)
        + '<image id="%s-shot" x="%d" y="%d" width="%d" preserveAspectRatio="xMinYMin slice" clip-path="url(#%s-clip)" opacity="0"/>' % (sid, x, y, w, sid)
        + '<text id="%s-ph" x="%d" y="%d" font-size="%d" font-weight="600" text-anchor="middle" fill="%s" font-family="-apple-system,system-ui">Place %s screenshot</text>' % (sid, g["phx"], g["phy"], g["phsz"], ph_fill, g["label"]))
    if sw:
        o += '<rect x="%d" y="%d" width="%d" height="%d" rx="%d" fill="none" stroke="%s" stroke-width="%d"/>' % (x, y, w, h, r, stroke, sw)
    return o

def _card_default(cfg, dev, g, s, i):
    font = FONTS[cfg["font_key"]][0]
    sid = dev + str(i + 1)
    accent = s["accent"]
    titles = ""
    for k, line in enumerate(s["h"]):
        y = g["t1"] + k * (g["t2"] - g["t1"])
        titles += ('<text id="t-%s-%d" x="%d" y="%d" font-size="%d" font-weight="800" text-anchor="middle" fill="%s" font-family="%s">%s</text>'
                   % (sid, k, g["ex"], y, g["tsz"], accent, font, _sx(line)))
    sub = '<text x="%d" y="%d" font-size="%d" font-weight="500" text-anchor="middle" fill="%s" font-family="%s">' % (g["ex"], g["suby"], g["susz"], cfg["subText"], font)
    for k, line in enumerate(s["sub"]):
        sub += '<tspan id="s-%s-%d" x="%d"%s>%s</tspan>' % (sid, k, g["ex"], (' dy="%d"' % g["subdy"]) if k else "", _sx(line))
    sub += "</text>"
    svg = ('<svg id="%s" viewBox="0 0 %d %d" xmlns="http://www.w3.org/2000/svg">' % (sid, g["vw"], g["vh"])
           + '<rect width="%d" height="%d" fill="%s"/>' % (g["vw"], g["vh"], cfg["surface"])
           + '<g transform="translate(%d,%d)">' % (g["gx"], g["gy"])
           + '<text x="%d" y="%d" font-size="%d" text-anchor="middle">%s</text>' % (g["ex"], g["emy"], g["emsz"], s["emoji"])
           + titles + sub + "</g>"
           + '<defs><clipPath id="%s-clip"><path d="%s"/></clipPath></defs>' % (sid, g["clip"])
           + '<path d="%s" fill="%s" fill-opacity="0.06" stroke="%s" stroke-width="3" stroke-opacity="0.2"/>' % (g["clip"], accent, accent)
           + '<image id="%s-shot" x="%d" y="%d" width="%d" preserveAspectRatio="xMinYMin slice" clip-path="url(#%s-clip)" opacity="0"/>' % (sid, g["imx"], g["imy"], g["imw"], sid)
           + '<text id="%s-ph" x="%d" y="%d" font-size="%d" font-weight="600" text-anchor="middle" fill="%s" font-family="-apple-system,system-ui">Place %s screenshot</text>' % (sid, g["phx"], g["phy"], g["phsz"], cfg["placeholder"], g["label"])
           + "</svg>")
    return _card_div(sid, svg, s, i, _btns(cfg, dev, g, s, i, sid))

def _card_dotgrid(cfg, dev, g, s, i):
    # dot-grid: minimal & monochrome by default — Classic (dark) / Snow (light) alternating,
    # one delicate dot row. Each card has a LIVE picker across all 25 real in-app themes.
    sid = dev + str(i + 1); font = FONTS[cfg["font_key"]][0]
    themes = cfg["themes"]; defs = cfg["themeDefaults"]
    tid = defs[i % len(defs)]; t = themes[tid]
    bg, on, off, sub, head = t["bg"], t["accent"], t["accent2"], t["sub"], t["head"]
    cx = g["vw"] // 2; wt = g["imy"]; T = int(g["tsz"] * 0.96); U = g["susz"]
    svg = '<svg id="%s" viewBox="0 0 %d %d" xmlns="http://www.w3.org/2000/svg">' % (sid, g["vw"], g["vh"])
    svg += '<rect id="bg-%s" width="%d" height="%d" fill="%s"/>' % (sid, g["vw"], g["vh"], bg)
    svg += _dot_row(g, sid, cx, int(wt * 0.24), on, off)
    svg += _title(sid, s["h"], cx, int(wt * 0.48), int(T * 1.16), T, "700", head, font)
    svg += _subt(sid, s["sub"], cx, int(wt * 0.72), g["subdy"], U, sub, font, tid="sub-" + sid)
    svg += _shot(g, sid, bg, off, 4, sub, pid="well-" + sid)
    return _card_div(sid, svg + "</svg>", s, i, _btns(cfg, dev, g, s, i, sid), extra=_theme_select(sid, themes, tid))

def _card_brutalist(cfg, dev, g, s, i):
    # brutalist: concrete neutrals + one loud accent, hard frames, heavy left-aligned type, raw rules.
    sid = dev + str(i + 1); font = FONTS[cfg["font_key"]][0]
    cement = "#D7D1C6"; ink = "#1A1714"; gold = "#E8A33D"
    wt = g["imy"]; T = int(g["tsz"] * 0.94); U = g["susz"]; M = g["vw"] // 11
    svg = '<svg id="%s" viewBox="0 0 %d %d" xmlns="http://www.w3.org/2000/svg">' % (sid, g["vw"], g["vh"])
    svg += '<rect width="%d" height="%d" fill="%s"/>' % (g["vw"], g["vh"], cement)
    svg += '<rect x="22" y="22" width="%d" height="%d" fill="none" stroke="%s" stroke-width="14"/>' % (g["vw"] - 44, g["vh"] - 44, ink)
    nb = int(wt * 0.17); ny = int(wt * 0.09)
    svg += '<rect x="%d" y="%d" width="%d" height="%d" fill="%s"/>' % (M, ny, nb, nb, gold)
    svg += '<text x="%d" y="%d" font-size="%d" font-weight="800" text-anchor="middle" fill="%s" font-family="%s">%02d</text>' % (M + nb // 2, ny + int(nb * 0.72), int(nb * 0.58), ink, font, i + 1)
    ty = int(wt * 0.48); TL = int(T * 1.12)
    svg += _title(sid, s["h"], M, ty, TL, T, "800", ink, font, anchor="start")
    uy = ty + (len(s["h"]) - 1) * TL + int(T * 0.4)
    svg += '<rect x="%d" y="%d" width="%d" height="20" fill="%s"/>' % (M, uy, int(g["vw"] * 0.44), gold)
    svg += _subt(sid, s["sub"], M, int(wt * 0.76), g["subdy"], U, ink, font, anchor="start", weight="600")
    # screenshot well: rounded corners (iOS-shaped) inside a thick brutalist black border
    svg += _shot_round(g, sid, "#FFFFFF", ink, 12, "#9A9488", 60, 54)
    return _card_div(sid, svg + "</svg>", s, i, _btns(cfg, dev, g, s, i, sid))

def _card_ink(cfg, dev, g, s, i):
    # ink: ink-on-paper monochrome. Hairlines + whitespace, no chromatic accent.
    sid = dev + str(i + 1); font = FONTS[cfg["font_key"]][0]
    paper = cfg["surface"]; ink = cfg["text"]; sec = cfg["subText"]
    cx = g["vw"] // 2; wt = g["imy"]; T = int(g["tsz"] * 0.92); U = g["susz"]
    svg = '<svg id="%s" viewBox="0 0 %d %d" xmlns="http://www.w3.org/2000/svg">' % (sid, g["vw"], g["vh"])
    svg += '<rect width="%d" height="%d" fill="%s"/>' % (g["vw"], g["vh"], paper)
    svg += '<text x="%d" y="%d" font-size="%d" font-weight="700" letter-spacing="9" text-anchor="middle" fill="%s" font-family="%s">FOLD · %02d</text>' % (cx, int(wt * 0.17), int(U * 0.78), sec, font, i + 1)
    ty = int(wt * 0.42); TL = int(T * 1.14)
    svg += _title(sid, s["h"], cx, ty, TL, T, "700", ink, font)
    ry = ty + (len(s["h"]) - 1) * TL + int(T * 0.55)
    svg += '<rect x="%d" y="%d" width="180" height="4" fill="%s" fill-opacity="0.3"/>' % (cx - 90, ry, ink)
    svg += _subt(sid, s["sub"], cx, int(wt * 0.72), g["subdy"], U, sec, font)
    svg += _shot(g, sid, "#F0EFEC", "#C7C7C3", 3, cfg["placeholder"])
    return _card_div(sid, svg + "</svg>", s, i, _btns(cfg, dev, g, s, i, sid))

def _card_serif(cfg, dev, g, s, i):
    # serif: editorial serif (Fraunces), rust-on-cream, left margin rule + folio.
    sid = dev + str(i + 1); font = FONTS[cfg["font_key"]][0]
    cream = cfg["surface"]; ink = cfg["text"]; sub = cfg["subText"]; rust = s["accent"]
    wt = g["imy"]; T = g["tsz"]; U = int(g["susz"] * 1.05); ML = g["vw"] // 10; x = ML + int(g["vw"] * 0.05)
    svg = '<svg id="%s" viewBox="0 0 %d %d" xmlns="http://www.w3.org/2000/svg">' % (sid, g["vw"], g["vh"])
    svg += '<rect width="%d" height="%d" fill="%s"/>' % (g["vw"], g["vh"], cream)
    svg += '<rect x="%d" y="%d" width="5" height="%d" fill="%s"/>' % (ML, int(wt * 0.10), int(wt * 0.80), rust)
    svg += '<text x="%d" y="%d" font-size="%d" font-style="italic" fill="%s" font-family="%s">No. %02d</text>' % (x, int(wt * 0.17), int(U * 0.9), rust, font, i + 1)
    svg += _title(sid, s["h"], x, int(wt * 0.42), int(T * 1.12), T, "600", ink, font, anchor="start")
    svg += _subt(sid, s["sub"], x, int(wt * 0.72), g["subdy"], U, sub, font, anchor="start", italic=True)
    svg += _shot(g, sid, "#FFFFFF", rust, 4, cfg["placeholder"])
    return _card_div(sid, svg + "</svg>", s, i, _btns(cfg, dev, g, s, i, sid))

# The flame style's hero mark — a simple flame glyph (swap in your own app's mark
# icon_master.svg, viewBox 1024). Filled in the screen's theme accent; the eyes + smile
# are cut in the surface colour so the little character reads on every theme.
def _flame_mark(sid, cx, ycenter, h, accent, face):
    sc = h / 684.0; tx = cx - 508 * sc; ty = ycenter - 526 * sc
    return ('<g transform="translate(%.2f,%.2f) scale(%.4f) rotate(11,512,512)">' % (tx, ty, sc)
        + '<path id="fl-%s" class="acc-%s" d="M 488 184 C 416 352, 248 500, 264 652 C 280 780, 380 868, 516 868 C 664 868, 768 764, 752 644 C 732 500, 572 364, 488 184Z" fill="%s"/>' % (sid, sid, accent)
        + '<g id="face-%s">' % sid
        + '<line x1="440" y1="564" x2="440" y2="636" stroke="%s" stroke-width="32" stroke-linecap="round"/>' % face
        + '<line x1="580" y1="564" x2="580" y2="636" stroke="%s" stroke-width="32" stroke-linecap="round"/>' % face
        + '<path d="M476 740 Q516 764,556 740" fill="none" stroke="%s" stroke-width="26" stroke-linecap="round"/>' % face
        + '</g></g>')

def _card_flame(cfg, dev, g, s, i):
    # flame: warm-minimal. Each card defaults to one of the sample registry's
    # themes and the user can switch it LIVE per card (all 41 themes, picker below the
    # card). Brand flame from the app icon, recoloured with the chosen theme's accent.
    sid = dev + str(i + 1); font = FONTS[cfg["font_key"]][0]
    themes = cfg["themes"]; defs = cfg["themeDefaults"]
    tid = defs[i % len(defs)]; t = themes[tid]
    bg, sub, ph, accent, head = t["bg"], t["sub"], t["ph"], t["accent"], t["head"]
    cx = g["vw"] // 2; wt = g["imy"]; T = int(g["tsz"] * 0.96); U = g["susz"]
    svg = '<svg id="%s" viewBox="0 0 %d %d" xmlns="http://www.w3.org/2000/svg">' % (sid, g["vw"], g["vh"])
    svg += '<rect id="bg-%s" width="%d" height="%d" fill="%s"/>' % (sid, g["vw"], g["vh"], bg)
    svg += _flame_mark(sid, cx, int(wt * 0.18), int(g["emsz"] * 0.92), accent, bg)
    svg += _title(sid, s["h"], cx, int(wt * 0.50), int(T * 1.16), T, "800", head, font)
    svg += _subt(sid, s["sub"], cx, int(wt * 0.72), g["subdy"], U, sub, font, tid="sub-" + sid)
    svg += _shot(g, sid, bg, accent, 4, ph, pid="well-" + sid)
    return _card_div(sid, svg + "</svg>", s, i, _btns(cfg, dev, g, s, i, sid), extra=_theme_select(sid, themes, tid))


def _card_blueprint(cfg, dev, g, s, i):
    # blueprint: blueprint-grid planning surface. Uses the planner theme tokens and
    # keeps screenshots bleeding off the bottom, matching the app's planner feel.
    sid = dev + str(i + 1); font = FONTS[cfg["font_key"]][0]
    themes = cfg["themes"]; defs = cfg["themeDefaults"]
    tid = defs[i % len(defs)]; t = themes[tid]
    bg, text, sub, ph = t["bg"], t["text"], t["sub"], t["ph"]
    accent, accent2, head = t["accent"], t["accent2"], t["head"]
    cx = g["vw"] // 2; wt = g["imy"]; T = int(g["tsz"] * 0.92); U = g["susz"]
    minor = 72 if dev == "iphone" else 96
    major = minor * 4
    svg = '<svg id="%s" viewBox="0 0 %d %d" xmlns="http://www.w3.org/2000/svg">' % (sid, g["vw"], g["vh"])
    svg += '<rect id="bg-%s" width="%d" height="%d" fill="%s"/>' % (sid, g["vw"], g["vh"], bg)
    for x in range(0, g["vw"] + minor, minor):
        op = "0.26" if x % major == 0 else "0.13"
        sw = 2 if x % major == 0 else 1
        svg += '<line class="ac2s-%s" x1="%d" y1="0" x2="%d" y2="%d" stroke="%s" stroke-width="%d" stroke-opacity="%s"/>' % (sid, x, x, g["vh"], accent2, sw, op)
    for y in range(0, g["vh"] + minor, minor):
        op = "0.26" if y % major == 0 else "0.13"
        sw = 2 if y % major == 0 else 1
        svg += '<line class="ac2s-%s" x1="0" y1="%d" x2="%d" y2="%d" stroke="%s" stroke-width="%d" stroke-opacity="%s"/>' % (sid, y, g["vw"], y, accent2, sw, op)
    route_y = int(wt * 0.22)
    svg += '<path class="accs-%s" d="M %d %d C %d %d, %d %d, %d %d S %d %d, %d %d" fill="none" stroke="%s" stroke-width="6" stroke-linecap="round" stroke-opacity="0.28"/>' % (
        sid, int(g["vw"] * 0.12), route_y, int(g["vw"] * 0.26), int(route_y * 0.62), int(g["vw"] * 0.36), int(route_y * 1.28), int(g["vw"] * 0.5), route_y, int(g["vw"] * 0.66), int(route_y * 0.72), int(g["vw"] * 0.88), int(route_y * 1.12), accent)
    for px, py in ((0.12, 1.0), (0.5, 1.0), (0.88, 1.12)):
        svg += '<circle class="acc-%s" cx="%d" cy="%d" r="%d" fill="%s" fill-opacity="0.82"/>' % (sid, int(g["vw"] * px), int(route_y * py), 10 if dev == "iphone" else 14, accent)
    svg += '<text x="%d" y="%d" font-size="%d" font-weight="700" text-anchor="middle" fill="%s" fill-opacity="0.72" font-family="%s">%02d</text>' % (cx, int(wt * 0.17), int(U * 0.72), sub, font, i + 1)
    ty = int(wt * 0.40); TL = int(T * 1.10)
    svg += _title(sid, s["h"], cx, ty, TL, T, "700", head, font)
    svg += '<rect class="acc-%s" x="%d" y="%d" width="%d" height="6" rx="3" fill="%s" fill-opacity="0.8"/>' % (sid, cx - int(g["vw"] * 0.12), ty + len(s["h"]) * TL - int(T * 0.36), int(g["vw"] * 0.24), accent)
    svg += _subt(sid, s["sub"], cx, int(wt * 0.72), g["subdy"], U, sub, font, tid="sub-" + sid)
    svg += _shot(g, sid, bg, accent2, 4, ph, pid="well-" + sid)
    return _card_div(sid, svg + "</svg>", s, i, _btns(cfg, dev, g, s, i, sid), extra=_theme_select(sid, themes, tid))

def _simple_card(cfg, dev, g, s, i):
    return {
        "flame": _card_flame, "dotgrid": _card_dotgrid, "brutalist": _card_brutalist,
        "ink": _card_ink, "serif": _card_serif, "blueprint": _card_blueprint,
    }.get(cfg.get("simpleStyle"), _card_default)(cfg, dev, g, s, i)

def build_simple(cfg):
    spec = FONTS[cfg["font_key"]][1]
    # Localize the Simple page with the SAME set as this app's Studio: en base + i18n.
    # Text is swapped live in JS (positions are fixed; every line is exactly 2 lines).
    i18n = {"en": {"screens": [{"h": s["h"], "sub": s["sub"]} for s in cfg["screens"]]}}
    for loc, v in (cfg.get("i18n") or {}).items():
        i18n[loc] = {"screens": v["screens"]}
    locsel = ""
    if len(i18n) > 1:
        opts = "".join('<option value="%s">%s</option>' % (l, l) for l in i18n)
        locsel = '<label class="locsel">Locale&nbsp;<select id="loc" onchange="setLoc(this.value)">%s</select></label>' % opts
    sections = ""
    for dev in cfg["devices"]:
        if dev == "mac":            # simple page is iPhone/iPad only (matches the bespoke)
            continue
        g = SIMPLE_GEOM[dev]
        cards = "".join(_simple_card(cfg, dev, g, s, i) for i, s in enumerate(cfg["screens"]))
        szs = " · ".join("%d×%d" % (w, h) for (w, h, _) in g["sizes"])
        sections += '<h2>%s graphics <span>%s px</span></h2><div class="grid">%s</div>' % (g["label"], szs, cards)
    # Reusable per-card LIVE theme switcher: any app whose config carries a `themes`
    # registry embeds the themes + one generic restyle fn keyed
    # off standard element ids/classes. Empty for apps without themes — so their Simple
    # pages stay byte-identical.
    themes = cfg.get("themes")
    extrajs = ""
    if themes:
        extrajs = ("const THEMES=%s;\n" % json.dumps(themes, ensure_ascii=False)
            + "function setCardTheme(sid,id){var t=THEMES[id];if(!t)return;"
            + "var b=document.getElementById('bg-'+sid);if(b)b.setAttribute('fill',t.bg);"
            + "document.querySelectorAll('.acc-'+sid).forEach(function(e){e.setAttribute('fill',t.accent);});"
            + "document.querySelectorAll('.ac2-'+sid).forEach(function(e){e.setAttribute('fill',t.accent2);});"
            + "document.querySelectorAll('.accs-'+sid).forEach(function(e){e.setAttribute('stroke',t.accent);});"
            + "document.querySelectorAll('.ac2s-'+sid).forEach(function(e){e.setAttribute('stroke',t.accent2);});"
            + "['0','1','2'].forEach(function(k){var el=document.getElementById('t-'+sid+'-'+k);if(el)el.setAttribute('fill',t.head);});"
            + "var s=document.getElementById('sub-'+sid);if(s)s.setAttribute('fill',t.sub);"
            + "var fc=document.getElementById('face-'+sid);if(fc)fc.querySelectorAll('*').forEach(function(e){e.setAttribute('stroke',t.bg);});"
            + "var w=document.getElementById('well-'+sid);if(w){w.setAttribute('fill',t.bg);w.setAttribute('stroke',t.accent2);}"
            + "var p=document.getElementById(sid+'-ph');if(p)p.setAttribute('fill',t.ph);}")
    return (SIMPLE_PAGE
            .replace("__TITLE__", _sx(cfg["name"]))
            .replace("__SURFACE__", cfg["surface"]).replace("__TEXT__", cfg["text"])
            .replace("__ACCENT__", cfg["screens"][0]["accent"])
            .replace("__FONTLINK__", gfont(spec))
            .replace("__FONTHREF__", "https://fonts.googleapis.com/css2?family=%s&display=swap" % spec)
            .replace("__LOCSEL__", locsel)
            .replace("__I18N__", json.dumps(i18n, ensure_ascii=False))
            .replace("__EXTRAJS__", extrajs)
            .replace("__SECTIONS__", sections))

SIMPLE_PAGE = """<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>__TITLE__ — App Store Graphics (simple)</title>
__FONTLINK__
<style>
 *{box-sizing:border-box}
 body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',system-ui,sans-serif;background:__SURFACE__;color:__TEXT__;margin:0;padding:40px 24px}
 .container{max-width:1400px;margin:0 auto}
 h1{font-size:28px;margin:0 0 8px}
 h2{font-size:22px;margin:48px 0 10px}
 h2 span{font-size:14px;font-weight:400;opacity:.55;margin-left:8px}
 p.note{opacity:.7;font-size:14px;line-height:1.5;margin:0 0 8px}
 code{background:rgba(0,0,0,.06);padding:1px 6px;border-radius:5px;font-size:13px}
 .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:24px}
 .card{background:#fff;border-radius:16px;padding:16px;box-shadow:0 2px 12px rgba(0,0,0,.06)}
 .prev svg{width:100%;height:auto;border-radius:10px;display:block;background:__SURFACE__}
 .cap{font-size:13px;font-weight:600;margin:10px 0 8px;opacity:.8}
 .row{display:flex;flex-wrap:wrap;gap:8px;align-items:center}
 input[type=file]{font-size:12px;flex:1 1 100%}
 button{background:__ACCENT__;color:#fff;border:0;border-radius:8px;padding:8px 12px;font-size:13px;font-weight:600;cursor:pointer}
 button:hover{filter:brightness(.92)}
 .locsel{display:inline-block;font-size:14px;font-weight:600;margin:0 0 14px}
 .locsel select{font-size:14px;padding:4px 8px;border-radius:8px;margin-left:4px}
</style></head><body><div class="container">
<h1>__TITLE__ — App Store Graphics</h1>
<p class="note">Simple static generator. Drop a screenshot into each slot, pick a locale, then download at the exact App Store size. For device frames, the bold-hero first image, and bulk per-locale ZIP export, use the full studio in <code>app-store-graphics.html</code>.</p>
__LOCSEL__
__SECTIONS__
</div>
<script>
const FONT_HREF="__FONTHREF__"; let _fc;
async function inlineFont(){ if(_fc!==undefined) return _fc;
  try{ const css=await (await fetch(FONT_HREF)).text();
    const urls=[...new Set([...css.matchAll(/url\\((https:[^)]+\\.woff2)\\)/g)].map(m=>m[1]))]; const map={};
    await Promise.all(urls.map(async u=>{const b=new Uint8Array(await (await fetch(u)).arrayBuffer());let s='';for(let i=0;i<b.length;i++)s+=String.fromCharCode(b[i]);map[u]='data:font/woff2;base64,'+btoa(s);}));
    _fc=css.replace(/url\\((https:[^)]+\\.woff2)\\)/g,(m,u)=>'url('+(map[u]||u)+')');
  }catch(e){_fc='';} return _fc; }
function loadImg(imgId,phId,inp){const f=inp.files[0];if(!f)return;const r=new FileReader();r.onload=e=>{const im=document.getElementById(imgId);im.setAttribute('href',e.target.result);im.setAttribute('opacity','1');const ph=document.getElementById(phId);if(ph)ph.setAttribute('opacity','0');};r.readAsDataURL(f);}
async function dlGraphic(svgId,filename,w,h){const svg=document.getElementById(svgId).cloneNode(true);
  svg.setAttribute('width',w);svg.setAttribute('height',h);svg.setAttribute('preserveAspectRatio','none');
  const css=await inlineFont(); if(css){const st=document.createElementNS('http://www.w3.org/2000/svg','style');st.textContent=css;svg.insertBefore(st,svg.firstChild);}
  const data=new XMLSerializer().serializeToString(svg); const img=new Image();
  img.onload=()=>{const c=document.createElement('canvas');c.width=w;c.height=h;const x=c.getContext('2d');x.fillStyle='#ffffff';x.fillRect(0,0,w,h);x.drawImage(img,0,0,w,h);c.toBlob(b=>{const u=URL.createObjectURL(b),a=document.createElement('a');a.href=u;a.download=filename;a.click();setTimeout(()=>URL.revokeObjectURL(u),1000);},'image/png');};
  img.onerror=()=>alert('Render failed — open in Chrome.');
  img.src='data:image/svg+xml;base64,'+btoa(unescape(encodeURIComponent(data)));}
const I18N=__I18N__; let curLoc='en';
function setLoc(loc){ curLoc=loc; const d=I18N[loc]||I18N['en'];
  d.screens.forEach((sc,i)=>{ ['iphone','ipad'].forEach(dev=>{ const sid=dev+(i+1);
    sc.h.forEach((t,k)=>{const el=document.getElementById('t-'+sid+'-'+k); if(el) el.textContent=t;});
    sc.sub.forEach((t,k)=>{const el=document.getElementById('s-'+sid+'-'+k); if(el) el.textContent=t;});
    const cap=document.getElementById('cap-'+sid); if(cap) cap.textContent=(i+1)+'. '+sc.h.join(' ');
  }); });
}
function dl(svgId,w,h,base){ dlGraphic(svgId, base+'-'+curLoc+'-'+w+'x'+h+'.png', w, h); }
__EXTRAJS__</script></body></html>"""

def check_theme_contrast():
    # Guard: every themed app's headline (head) + subtext (sub) must clear AA-large 3:1 on
    # its bg, on every theme. Surfaces a regression the moment a new theme is added.
    bad = []
    for k in ORDER:
        for tid, t in (APPS[k].get("themes") or {}).items():
            for role in ("head", "sub"):
                c = _contrast(t[role], t["bg"])
                if c < 3.0:
                    bad.append("  ⚠ %s/%s %s vs bg = %.2f:1 (< 3.0)" % (k, tid, role, c))
    return bad

def main():
    if "--list" in sys.argv:
        for k in ORDER:
            print(f'{APPS[k]["name"]:8} -> {APPS[k]["out"]}')
        print(f'{"mega":8} -> tools/app-store-graphics/index.html')
        return
    bad = check_theme_contrast()
    if bad:
        print("THEME CONTRAST WARNINGS (headline/subtext below AA-large):")
        print("\n".join(bad))
    written = []
    for k in ORDER:
        cfg = APPS[k]
        path = os.path.join(ROOT, cfg["out"])
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            f.write(build_single(cfg))
        written.append(cfg["out"])
        spath = os.path.join(ROOT, simple_out(cfg))     # the proven "use what works" fallback
        with open(spath, "w", encoding="utf-8") as f:
            f.write(build_simple(cfg))
        written.append(simple_out(cfg))
    mega = os.path.join(HERE, "index.html")
    with open(mega, "w", encoding="utf-8") as f:
        f.write(build_mega())
    written.append("tools/app-store-graphics/index.html")
    for w in written:
        print("wrote", w)

if __name__ == "__main__":
    main()
