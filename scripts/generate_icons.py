"""
SpendWise premium icon generator — v2 refined
Produces:
  assets/icon/app_icon.png          (1024×1024, V1 main launcher)
  assets/icon/app_icon_fg.png       (1024×1024, adaptive foreground)
  assets/icon/spendwise_icon_v1.png (V1 wallet + donut chart)
  assets/icon/spendwise_icon_v1.svg
  assets/icon/spendwise_icon_v2.png (V2 minimal circle + donut)
  assets/icon/spendwise_icon_v2.svg
"""

import math
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
HALF = SIZE // 2
OUT  = os.path.join(os.path.dirname(__file__), "..", "assets", "icon")
os.makedirs(OUT, exist_ok=True)

# ── Palette ─────────────────────────────────────────────────────────────────
BG_TOP   = (74,  222, 128)   # #4ADE80  bright lime-green (top)
BG_BOT   = (22,  163,  74)   # #16A34A  rich green (bottom)
SEG_DARK  = (21,  128,  61)  # #15803D  darkest segment
SEG_LIGHT = (134, 239, 172)  # #86EFAC  lightest segment
WHITE     = (255, 255, 255)


# ── Gradient helpers ─────────────────────────────────────────────────────────
def vertical_gradient_img(size, top_rgb, bot_rgb):
    """Fast vertical gradient using numpy."""
    t = np.linspace(0, 1, size, dtype=np.float32)
    r = (top_rgb[0] + (bot_rgb[0] - top_rgb[0]) * t).astype(np.uint8)
    g = (top_rgb[1] + (bot_rgb[1] - top_rgb[1]) * t).astype(np.uint8)
    b = (top_rgb[2] + (bot_rgb[2] - top_rgb[2]) * t).astype(np.uint8)
    a = np.full(size, 255, dtype=np.uint8)
    row  = np.stack([r, g, b, a], axis=-1)          # (size, 4)
    grid = np.broadcast_to(row[:, np.newaxis, :], (size, size, 4)).copy()
    return Image.fromarray(grid, "RGBA")


def diagonal_gradient_img(size, tl_rgb, br_rgb):
    """Diagonal gradient: bright top-left → dark bottom-right."""
    x = np.linspace(0, 1, size, dtype=np.float32)
    xx, yy = np.meshgrid(x, x)
    t = (xx + yy) / 2                               # 0 at TL, 1 at BR
    r = np.clip(tl_rgb[0] + (br_rgb[0] - tl_rgb[0]) * t, 0, 255).astype(np.uint8)
    g = np.clip(tl_rgb[1] + (br_rgb[1] - tl_rgb[1]) * t, 0, 255).astype(np.uint8)
    b = np.clip(tl_rgb[2] + (br_rgb[2] - tl_rgb[2]) * t, 0, 255).astype(np.uint8)
    a = np.full((size, size), 255, dtype=np.uint8)
    return Image.fromarray(np.stack([r, g, b, a], axis=-1), "RGBA")


def rounded_mask(size, radius):
    m = Image.new("L", (size, size), 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return m


def circle_mask(size, padding=48):
    m = Image.new("L", (size, size), 0)
    ImageDraw.Draw(m).ellipse([padding, padding, size - padding, size - padding], fill=255)
    return m


# ── Drawing helpers ──────────────────────────────────────────────────────────
def pie_slice(draw, cx, cy, r, a0, a1, color):
    draw.pieslice([cx - r, cy - r, cx + r, cy + r], start=a0, end=a1, fill=color)


def divider_line(draw, cx, cy, r, deg, width=7):
    rad = math.radians(deg)
    x2  = cx + r * math.cos(rad)
    y2  = cy + r * math.sin(rad)
    draw.line([(cx, cy), (x2, y2)], fill=(*WHITE, 255), width=width)


def soft_shadow(canvas, rect, radius, blur=30, color=(10, 70, 20, 110), offset=(0, 14)):
    shd = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    sd  = ImageDraw.Draw(shd)
    x0, y0, x1, y1 = rect
    sd.rounded_rectangle(
        [x0 + offset[0], y0 + offset[1], x1 + offset[0], y1 + offset[1]],
        radius=radius, fill=color,
    )
    shd = shd.filter(ImageFilter.GaussianBlur(blur))
    canvas.alpha_composite(shd)


def top_glow(canvas, cx=HALF, max_alpha=16, steps=28):
    """Very subtle white radial highlight at top-centre — 'lit from above'."""
    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gd   = ImageDraw.Draw(glow)
    for i in range(steps):
        a  = max(0, int(max_alpha * (1 - i / steps)))
        hw = 200 + i * 18
        hh = 120 + i * 12
        gd.ellipse([cx - hw, -hh // 2, cx + hw, hh + 20], fill=(255, 255, 255, a))
    glow = glow.filter(ImageFilter.GaussianBlur(24))
    canvas.alpha_composite(glow)


# ════════════════════════════════════════════════════════════════════════════
#  V1 — Wallet + Donut Chart  (main launcher icon)
# ════════════════════════════════════════════════════════════════════════════
def make_v1():
    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

    # 1 ▸ Background
    bg = diagonal_gradient_img(SIZE, BG_TOP, BG_BOT)
    canvas.paste(bg, mask=rounded_mask(SIZE, 220))

    # 2 ▸ Top glow
    top_glow(canvas, max_alpha=14)

    # 3 ▸ Wallet card shadow
    CARD = [180, 312, 844, 712]
    soft_shadow(canvas, CARD, radius=68, blur=32,
                color=(8, 60, 20, 115), offset=(0, 16))

    # 4 ▸ Wallet card body  (clean — no decorations)
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rounded_rectangle(CARD, radius=64, fill=(*WHITE, 246))

    # ── Optional: a barely-there top-edge inner highlight ──
    # One thin white arc at the top of the card gives a "glass" feel
    inner_h = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ih = ImageDraw.Draw(inner_h)
    ih.rounded_rectangle(
        [CARD[0] + 2, CARD[1] + 2, CARD[2] - 2, CARD[1] + 60],
        radius=62, fill=(255, 255, 255, 70),
    )
    inner_h = inner_h.filter(ImageFilter.GaussianBlur(6))
    canvas.alpha_composite(inner_h)

    draw = ImageDraw.Draw(canvas, "RGBA")

    # 5 ▸ Donut chart
    cx  = HALF
    cy  = (CARD[1] + CARD[3]) // 2          # vertically centred in card
    R   = 150                                # outer radius
    ri  = 62                                 # inner (donut hole) radius

    # Segments  — start from top (-90°), clockwise
    # 45 % = 162°  dark green
    pie_slice(draw, cx, cy, R, -90, -90 + 162, (*SEG_DARK,  255))
    # 35 % = 126°  white
    pie_slice(draw, cx, cy, R, -90 + 162, -90 + 288, (*WHITE,    255))
    # 20 % =  72°  light green
    pie_slice(draw, cx, cy, R, -90 + 288,       270,  (*SEG_LIGHT, 255))

    # Crisp white dividers
    for deg in (-90, -90 + 162, -90 + 288):
        divider_line(draw, cx, cy, R, deg, width=7)

    # Donut hole
    draw.ellipse([cx - ri, cy - ri, cx + ri, cy + ri], fill=(*WHITE, 255))

    # Tiny centre accent — anchors the eye
    dot = 13
    draw.ellipse([cx - dot, cy - dot, cx + dot, cy + dot], fill=(*SEG_DARK, 200))

    return canvas


# ════════════════════════════════════════════════════════════════════════════
#  V2 — Minimal Circle  (notification icon / alternate)
# ════════════════════════════════════════════════════════════════════════════
def make_v2():
    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

    # 1 ▸ Circular gradient background
    bg = diagonal_gradient_img(SIZE, BG_TOP, BG_BOT)
    canvas.paste(bg, mask=circle_mask(SIZE, padding=48))

    # 2 ▸ Outer ring highlight (very subtle)
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.ellipse([48, 48, SIZE - 48, SIZE - 48],
                 outline=(*WHITE, 28), width=14)

    # 3 ▸ Top glow
    top_glow(canvas, max_alpha=12)

    draw = ImageDraw.Draw(canvas, "RGBA")

    # 4 ▸ Donut chart
    cx, cy = HALF, HALF
    R  = 336
    ri = 142

    pie_slice(draw, cx, cy, R, -90,        -90 + 162, (*SEG_DARK,  255))
    pie_slice(draw, cx, cy, R, -90 + 162,  -90 + 288, (*WHITE,     255))
    pie_slice(draw, cx, cy, R, -90 + 288,       270,  (*SEG_LIGHT, 255))

    for deg in (-90, -90 + 162, -90 + 288):
        divider_line(draw, cx, cy, R, deg, width=10)

    # Donut hole — dark green inner circle, lighter inner ring, white dot
    draw.ellipse([cx - ri, cy - ri, cx + ri, cy + ri], fill=(*BG_BOT, 255))
    draw.ellipse([cx - ri + 14, cy - ri + 14, cx + ri - 14, cy + ri - 14],
                 fill=(*SEG_DARK, 255))

    # Up-arrow (trend) in centre
    ax, ay = cx, cy
    shaft_w, shaft_h = 16, 46
    head_w,  head_h  = 46, 34
    # shaft
    draw.rectangle(
        [ax - shaft_w // 2, ay - shaft_h // 2 + 14,
         ax + shaft_w // 2, ay + shaft_h // 2 + 14],
        fill=(*WHITE, 230),
    )
    # arrowhead
    draw.polygon(
        [(ax,              ay - shaft_h // 2 - head_h + 14),
         (ax - head_w // 2, ay - shaft_h // 2 + 14),
         (ax + head_w // 2, ay - shaft_h // 2 + 14)],
        fill=(*WHITE, 255),
    )

    return canvas


# ════════════════════════════════════════════════════════════════════════════
#  SVG generators
# ════════════════════════════════════════════════════════════════════════════
def _svg_pie_path(cx, cy, r, a0_deg, a1_deg):
    a0, a1 = math.radians(a0_deg), math.radians(a1_deg)
    x1, y1 = cx + r * math.cos(a0), cy + r * math.sin(a0)
    x2, y2 = cx + r * math.cos(a1), cy + r * math.sin(a1)
    large  = 1 if (a1_deg - a0_deg) > 180 else 0
    return (f"M {cx:.1f},{cy:.1f} "
            f"L {x1:.2f},{y1:.2f} "
            f"A {r},{r} 0 {large},1 {x2:.2f},{y2:.2f} Z")


def make_v1_svg():
    W = H = 1024
    cx = cy = 512

    defs = """
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#4ADE80"/>
      <stop offset="100%" stop-color="#16A34A"/>
    </linearGradient>
    <filter id="cardShadow" x="-8%" y="-8%" width="116%" height="130%">
      <feDropShadow dx="0" dy="16" stdDeviation="20"
                    flood-color="#0a3c14" flood-opacity="0.40"/>
    </filter>
  </defs>"""

    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">',
        defs,
        # background
        '  <rect width="1024" height="1024" rx="220" ry="220" fill="url(#bg)"/>',
        # top glow
        '  <radialGradient id="topGlow" cx="50%" cy="0%" r="60%" gradientUnits="userSpaceOnUse">',
        '    <stop offset="0%" stop-color="white" stop-opacity="0.14"/>',
        '    <stop offset="100%" stop-color="white" stop-opacity="0"/>',
        '  </radialGradient>',
        '  <rect width="1024" height="1024" rx="220" ry="220" fill="url(#topGlow)"/>',
        # wallet card
        '  <rect x="180" y="312" width="664" height="400" rx="64" ry="64"',
        '        fill="white" fill-opacity="0.96" filter="url(#cardShadow)"/>',
        # inner top highlight on card
        '  <rect x="182" y="314" width="660" height="58" rx="62" ry="62"',
        '        fill="white" fill-opacity="0.28"/>',
    ]

    # Pie slices
    segs = [(-90, -90+162, "#15803D"), (-90+162, -90+288, "#FFFFFF"), (-90+288, 270, "#86EFAC")]
    for a0, a1, col in segs:
        parts.append(f'  <path d="{_svg_pie_path(cx, 512, 150, a0, a1)}" fill="{col}"/>')

    # Dividers
    for deg in (-90, -90+162, -90+288):
        rad = math.radians(deg)
        x2  = cx + 150 * math.cos(rad)
        y2  = 512 + 150 * math.sin(rad)
        parts.append(f'  <line x1="{cx}" y1="512" x2="{x2:.2f}" y2="{y2:.2f}"'
                     f' stroke="white" stroke-width="7" stroke-linecap="round"/>')

    # Donut hole + dot
    parts += [
        f'  <circle cx="{cx}" cy="512" r="62" fill="white"/>',
        f'  <circle cx="{cx}" cy="512" r="13" fill="#15803D" fill-opacity="0.80"/>',
        '</svg>',
    ]
    return "\n".join(parts)


def make_v2_svg():
    W = H = 1024
    cx = cy = 512

    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">',
        '  <defs>',
        '    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">',
        '      <stop offset="0%" stop-color="#4ADE80"/>',
        '      <stop offset="100%" stop-color="#16A34A"/>',
        '    </linearGradient>',
        '    <clipPath id="circ"><circle cx="512" cy="512" r="464"/></clipPath>',
        '  </defs>',
        '  <circle cx="512" cy="512" r="464" fill="url(#bg)"/>',
        '  <circle cx="512" cy="512" r="464" fill="none" stroke="white"',
        '          stroke-opacity="0.11" stroke-width="14"/>',
    ]

    segs = [(-90, -90+162, "#15803D"), (-90+162, -90+288, "#FFFFFF"), (-90+288, 270, "#86EFAC")]
    for a0, a1, col in segs:
        parts.append(f'  <path d="{_svg_pie_path(cx, cy, 336, a0, a1)}" fill="{col}"/>')

    for deg in (-90, -90+162, -90+288):
        rad = math.radians(deg)
        x2  = cx + 336 * math.cos(rad)
        y2  = cy + 336 * math.sin(rad)
        parts.append(f'  <line x1="{cx}" y1="{cy}" x2="{x2:.2f}" y2="{y2:.2f}"'
                     f' stroke="white" stroke-width="10" stroke-linecap="round"/>')

    # Donut hole + arrow
    parts += [
        f'  <circle cx="{cx}" cy="{cy}" r="142" fill="#16A34A"/>',
        f'  <circle cx="{cx}" cy="{cy}" r="128" fill="#15803D"/>',
        # shaft
        f'  <rect x="504" y="506" width="16" height="46" rx="4" fill="white" fill-opacity="0.90"/>',
        # arrowhead
        f'  <polygon points="512,464 489,500 535,500" fill="white"/>',
        '</svg>',
    ]
    return "\n".join(parts)


# ════════════════════════════════════════════════════════════════════════════
#  MAIN
# ════════════════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    print("Generating V1 (Wallet + Donut Chart) …")
    v1 = make_v1()
    p1 = os.path.join(OUT, "spendwise_icon_v1.png")
    v1.save(p1, "PNG")
    print(f"  ✓ {p1}")

    print("Generating V2 (Minimal Circle + Donut) …")
    v2 = make_v2()
    p2 = os.path.join(OUT, "spendwise_icon_v2.png")
    v2.save(p2, "PNG")
    print(f"  ✓ {p2}")

    # SVGs
    for path, content in [
        (os.path.join(OUT, "spendwise_icon_v1.svg"), make_v1_svg()),
        (os.path.join(OUT, "spendwise_icon_v2.svg"), make_v2_svg()),
    ]:
        with open(path, "w") as f:
            f.write(content)
        print(f"  ✓ {path}")

    # Main app icon (V1)
    main_path = os.path.join(OUT, "app_icon.png")
    v1.save(main_path, "PNG")
    print(f"  ✓ {main_path}  ← main launcher icon")

    # Adaptive foreground — V1 scaled to 66% centred on transparent canvas
    fg       = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    scale    = 0.66
    small_sz = int(SIZE * scale)
    offset   = (SIZE - small_sz) // 2
    v1_small = v1.resize((small_sz, small_sz), Image.LANCZOS)
    fg.paste(v1_small, (offset, offset), v1_small)
    fg_path  = os.path.join(OUT, "app_icon_fg.png")
    fg.save(fg_path, "PNG")
    print(f"  ✓ {fg_path}  ← adaptive foreground")

    print("\nAll icons generated successfully!")
