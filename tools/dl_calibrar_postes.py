#!/usr/bin/env python3
"""Calibra e confere os postes laterais do Desvio Logico SEM abrir o Godot (V0.16.9.5/6).

Uso (na raiz do projeto; precisa de Pillow e numpy):
  python tools/dl_calibrar_postes.py medir              mede o CENTRO DA CALCADA (faixa cinza/roxa) nos 6 fundos e sugere os markers
  python tools/dl_calibrar_postes.py auditar            diz a que distancia (px) cada marker atual esta do centro da calcada
  (acrescente "gramado" em medir/auditar para medir a faixa verde em vez da calcada)
  python tools/dl_calibrar_postes.py preview [saida]    desenha os postes (como o jogo desenha) sobre os 6 fundos -> PNG

Os markers sao lidos de scenes/minigames/desviologico/DesvioLogico.tscn e as constantes/paletas de DLConfig.gd e
modules/DLSideProps.gd; assim o preview sempre reflete o que esta no projeto (nada e copiado a mao).
Quando trocar a arte dos fundos: rode `medir`, cole os valores nos markers PostLeft*/PostRight* no editor do Godot e rode `auditar`.
"""
import math
import re
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
DL = ROOT / "scenes/minigames/desviologico"
BGS = ["amanhecer", "manha", "tarde", "entardecer", "anoitecer", "noite"]
BG_DIR = ROOT / "assets/background/minegames/desviologico"
STAGE = (1280, 720)
SS = 3  # supersampling do preview


# ----------------------------------------------------------------------------- leitura do projeto
def read_markers():
    txt = (DL / "DesvioLogico.tscn").read_text(encoding="utf-8")
    out = {}
    for m in re.finditer(r'\[node name="(Post(?:Left|Right)(?:Start|Mid|End))" type="Marker2D"[^\n]*\]\n(?:[^\n\[]*\n)*?position = Vector2\(([-\d.]+), ([-\d.]+)\)', txt):
        out[m.group(1)] = (float(m.group(2)), float(m.group(3)))
    return out


def read_config():
    txt = (DL / "DLConfig.gd").read_text(encoding="utf-8")
    cfg = {}
    for key in ("POST_VANISH_Y", "POST_REF_Y", "POST_REF_HEIGHT", "POST_FADE_IN_T"):
        cfg[key] = float(re.search(r"const %s := ([-\d.]+)" % key, txt).group(1))
    for key in ("POST_LIGHT_BY_ROUND", "POST_DEPTH_SLOTS_LEFT", "POST_DEPTH_SLOTS_RIGHT"):
        arr = re.search(r"const %s := \[([^\]]*)\]" % key, txt).group(1)
        cfg[key] = [float(v) for v in arr.split(",") if v.strip()]
    return cfg


def read_palettes():
    txt = (DL / "modules/DLSideProps.gd").read_text(encoding="utf-8")
    body = txt.split("func _build_post_palette", 1)[1].split("func _with_alpha", 1)[0]
    pals, current = {}, None
    for line in body.splitlines():
        m = re.match(r"\s*(\d):\s*$", line)
        if m:
            current = int(m.group(1))
            continue
        if "return {" in line:
            idx = current if current is not None else 1  # o return depois do match e a Manha (1)
            pal = {}
            for k, a, b, c in re.findall(r'"(\w+)": Color\(([\d.]+), ([\d.]+), ([\d.]+)\)', line):
                pal[k] = (float(a), float(b), float(c))
            pals[idx] = pal
            current = None
    return pals


# ----------------------------------------------------------------------------- trilha (mesma logica de DLSideProps)
def path_x(markers, side, y):
    pre = "PostLeft" if side < 0 else "PostRight"
    s, m, e = markers[pre + "Start"], markers[pre + "Mid"], markers[pre + "End"]
    lerp = lambda a, b, t: a + (b - a) * t
    clamp01 = lambda v: min(max(v, 0.0), 1.0)
    if m[1] > s[1] + 1 and e[1] > m[1] + 1:
        if y <= m[1]:
            return lerp(s[0], m[0], clamp01((y - s[1]) / (m[1] - s[1])))
        return lerp(m[0], e[0], clamp01((y - m[1]) / (e[1] - m[1])))
    return lerp(s[0], e[0], clamp01((y - s[1]) / (e[1] - s[1])))


# ----------------------------------------------------------------------------- medicao do gramado
def _hsv(a):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    mx, mn = a.max(-1), a.min(-1)
    d = mx - mn + 1e-6
    h = np.where(mx == r, ((g - b) / d) % 6, np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4)) * 60
    return h, d / (mx + 1e-6), mx


TARGET = "calcada"


def measure(rows=range(260, 610, 10)):
    """Mediana (entre os 6 fundos) do centro da calcada (ou do gramado) por linha. Retorna {'L': {y: x}, 'R': {y: x}}."""
    acc = {"L": {y: [] for y in rows}, "R": {y: [] for y in rows}}
    for name in BGS:
        im = Image.open(BG_DIR / f"background_dl_{name}.png").convert("RGB").resize(STAGE, Image.LANCZOS)
        a = np.asarray(im).astype(float) / 255
        if TARGET == "gramado":
            h, s, v = _hsv(a)
            mask = (h > 65) & (h < 160) & (s > 0.30) & (v > 0.18)
        else:  # tampa clara da calcada: arroxeada (b > r > g)
            r, g, b = (a[..., 0] * 255, a[..., 1] * 255, a[..., 2] * 255)
            mask = (b > g + 18) & (b > r + 12) & (r > g) & (b > 115) & (b < 210) & (r > 85)
        for y in rows:
            xs = np.where(mask[y])[0]
            for key, sel in (("L", xs[xs < STAGE[0] // 2]), ("R", xs[xs >= STAGE[0] // 2])):
                if len(sel) >= 5:
                    clusters = np.split(sel, np.where(np.diff(sel) > 3)[0] + 1)
                    c = max(clusters, key=len)
                    if len(c) >= 4:
                        acc[key][y].append((c.min() + c.max()) / 2)
    # so linhas com amostra em pelo menos 3 dos 6 fundos (descarta ruido isolado)
    return {k: {y: float(np.median(v)) for y, v in d.items() if len(v) >= 3} for k, d in acc.items()}


def fit_lines(med):
    fits = {}
    for k, d in med.items():
        ys = np.array(list(d.keys()))
        xs = np.array(list(d.values()))
        a, b = np.polyfit(ys, xs, 1)
        fits[k] = (float(a), float(b), float(np.abs(xs - (a * ys + b)).max()))
    return fits


def cmd_medir():
    fits = fit_lines(measure())
    (la, lb, lr), (ra, rb, rr) = fits["L"], fits["R"]
    print(f"Centro da {TARGET} (mediana dos 6 fundos):  esquerda x = {la:.4f}*y + {lb:.1f}   (erro max {lr:.1f}px)")
    print(f"                                         direita  x = {ra:.4f}*y + {rb:.1f}   (erro max {rr:.1f}px)")
    vp = (rb - lb) / (la - ra)
    print(f"Ponto de fuga (onde as duas linhas se cruzam): y = {vp:.1f}  -> DLConfig.POST_VANISH_Y")
    cur = read_markers()
    print("\nMarkers sugeridos (mantendo os y atuais):")
    for pre, (a, b) in (("PostLeft", (la, lb)), ("PostRight", (ra, rb))):
        for part in ("Start", "Mid", "End"):
            y = cur[pre + part][1]
            print(f"  {pre}{part:<5} Vector2({round(a * y + b)}, {round(y)})    (atual: {cur[pre + part][0]:.0f}, {y:.0f})")


def cmd_auditar():
    markers = read_markers()
    fits = fit_lines(measure())
    worst = 0.0
    print(f"Distancia (px) de cada marker ate o centro medido da {TARGET}:")
    for pre, key in (("PostLeft", "L"), ("PostRight", "R")):
        a, b, _ = fits[key]
        for part in ("Start", "Mid", "End"):
            x, y = markers[pre + part]
            d = x - (a * y + b)
            worst = max(worst, abs(d))
            print(f"  {pre}{part:<5} ({x:.0f}, {y:.0f})  desvio {d:+.1f}px  {'OK' if abs(d) <= 12 else 'FORA DO CENTRO'}")
    print("\nResultado:", "OK (todos a <= 12 px do centro)" if worst <= 12 else f"AJUSTAR: pior desvio {worst:.0f}px")
    return 0 if worst <= 12 else 1


# ----------------------------------------------------------------------------- preview (espelha DLSideProps._draw_script_post)
def lerp(a, b, t):
    return a + (b - a) * t


def radial(size, cx, cy, rx, ry, col, alpha):
    w, h = size
    yy, xx = np.mgrid[0:h, 0:w]
    d = np.sqrt(((xx - cx) / max(rx, 0.01)) ** 2 + ((yy - cy) / max(ry, 0.01)) ** 2)
    # mesma curva do Gradient do jogo: 1.0 em 0, 0.30 em 0.45, 0.0 em 1
    a = np.interp(np.clip(d, 0, 1), [0.0, 0.45, 1.0], [1.0, 0.30, 0.0]) * alpha
    arr = np.zeros((h, w, 4), np.uint8)
    arr[..., 0], arr[..., 1], arr[..., 2] = [int(c * 255) for c in col]
    arr[..., 3] = (a * 255).astype(np.uint8)
    return Image.fromarray(arr, "RGBA")


def draw_post(img, markers, cfg, pals, side, y, rnd, t, tm=0.0):
    bx, by = path_x(markers, side, y), y
    k = min(max((y - cfg["POST_VANISH_Y"]) / (cfg["POST_REF_Y"] - cfg["POST_VANISH_Y"]), 0.08), 1.25)
    h = cfg["POST_REF_HEIGHT"] * k
    d = 1.0 if side < 0 else -1.0
    sx = img.size[0]
    if (side < 0 and bx + h * 0.30 < -12) or (side > 0 and bx - h * 0.30 > sx + 12):
        return
    x = min(max(t / cfg["POST_FADE_IN_T"], 0.0), 1.0)
    alpha = lerp(0.82, 1.0, min(max(t, 0), 1)) * (x * x * (3 - 2 * x))
    if alpha <= 0.01:
        return
    pal = pals[min(max(rnd, 0), 5)]
    table = cfg["POST_LIGHT_BY_ROUND"]
    inten = table[min(max(rnd, 0), len(table) - 1)]
    inten *= 0.95 + 0.05 * math.sin(tm * 3.1 + side * 1.7) if inten > 0 else 1
    lit = inten > 0.02
    S = img.size
    C = lambda c, a=1.0: tuple(int(v * 255) for v in c) + (int(255 * a * alpha),)
    top_y = by - h * 0.90
    ax, ay = bx + d * h * 0.22, top_y - h * 0.060
    hw, th = h * 0.052, h * 0.024
    img.alpha_composite(radial(S, bx, by + 1, h * 0.09, h * 0.016, (0, 0, 0), 0.34 * alpha))
    if lit:
        img.alpha_composite(radial(S, ax, by, h * 0.20, h * 0.030, pal["light"], 0.34 * inten * alpha))
        cone = Image.new("RGBA", S, (0, 0, 0, 0))
        cd = ImageDraw.Draw(cone)
        n = 14
        for i in range(n):
            t0, t1 = i / n, (i + 1) / n
            y0, y1 = lerp(ay + th, by, t0), lerp(ay + th, by, t1)
            w0, w1 = lerp(hw * 0.6, h * 0.17, t0), lerp(hw * 0.6, h * 0.17, t1)
            a = lerp(0.20, 0.02, (t0 + t1) / 2) * inten * alpha
            cd.polygon([(ax - w0, y0), (ax + w0, y0), (ax + w1, y1), (ax - w1, y1)], fill=tuple(int(v * 255) for v in pal["light"]) + (int(a * 255),))
        img.alpha_composite(cone)
    big = Image.new("RGBA", (S[0] * SS, S[1] * SS), (0, 0, 0, 0))
    g = ImageDraw.Draw(big)
    P = lambda px, py: (px * SS, py * SS)
    g.rectangle([P(bx - h * 0.034, by - h * 0.035), P(bx + h * 0.034, by)], fill=C(pal["plinth"]))
    wb, wt = max(1.8, h * 0.026), max(1.2, h * 0.016)
    g.polygon([P(bx - wb, by - h * 0.03), P(bx + wb, by - h * 0.03), P(bx + wt, top_y), P(bx - wt, top_y)], fill=C(pal["pole"]))
    g.line([P(bx - wt * 0.35, by - h * 0.05), P(bx - wt * 0.35, top_y)], fill=C(pal["hl"]), width=max(1, int(max(1.0, wt * 0.7) * SS)))
    p0, p1, p2 = (bx, top_y + h * 0.02), (bx, top_y - h * 0.085), (ax, ay)
    pts = []
    for i in range(7):
        u = i / 6
        pts.append(P(*[(1 - u) ** 2 * p0[j] + 2 * (1 - u) * u * p1[j] + u * u * p2[j] for j in (0, 1)]))
    g.line(pts, fill=C(pal["pole"]), width=int(max(1.6, h * 0.020) * SS), joint="curve")
    g.polygon([P(ax - hw, ay), P(ax + hw, ay), P(ax + hw * 0.78, ay + th), P(ax - hw * 0.78, ay + th)], fill=C(pal["head"]))
    lens = pal["lens"] if lit else tuple(v * 0.8 for v in pal["lens"])
    g.rectangle([P(ax - hw * 0.66, ay + th * 0.62), P(ax + hw * 0.66, ay + th * 0.62 + max(1.2, th * 0.38))], fill=C(lens))
    img.alpha_composite(big.resize(S, Image.LANCZOS))
    if lit:
        r = max(h * 0.30, 6.0)
        img.alpha_composite(radial(S, ax, ay + th * 0.6, r, r, pal["light"], 0.60 * inten * alpha))


def cmd_preview(out="preview_postes_desvio_logico.png"):
    markers, cfg, pals = read_markers(), read_config(), read_palettes()
    tiles = []
    for rnd, name in enumerate(BGS):
        bg = Image.open(BG_DIR / f"background_dl_{name}.png").convert("RGBA").resize(STAGE, Image.LANCZOS)
        for side, slots in ((-1, cfg["POST_DEPTH_SLOTS_LEFT"]), (1, cfg["POST_DEPTH_SLOTS_RIGHT"])):
            pre = "PostLeft" if side < 0 else "PostRight"
            y0, y1 = markers[pre + "Start"][1], markers[pre + "End"][1]
            for slot in slots:
                draw_post(bg, markers, cfg, pals, side, lerp(y0, y1, slot), rnd, slot)
        ImageDraw.Draw(bg).text((12, 10), f"{rnd} - {name}", fill=(255, 255, 255, 255))
        tiles.append(bg.resize((640, 360), Image.LANCZOS))
    sheet = Image.new("RGB", (1280, 1080))
    for i, t in enumerate(tiles):
        sheet.paste(t.convert("RGB"), ((i % 2) * 640, (i // 2) * 360))
    sheet.save(out)
    print("Preview salvo em", out)


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if "gramado" in sys.argv[2:]:
        TARGET = "gramado"
    if cmd == "medir":
        cmd_medir()
    elif cmd == "auditar":
        sys.exit(cmd_auditar())
    elif cmd == "preview":
        cmd_preview(*[a for a in sys.argv[2:3] if a != "gramado"])
    else:
        print(__doc__)
