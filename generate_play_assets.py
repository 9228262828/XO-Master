"""
Google Play Console Asset Generator for CalcPro
Produces all required images at exact Google Play sizes.
"""

from PIL import Image, ImageDraw
import math, os

OUT = "google_play_assets"

# Palette – plain (R,G,B,A) tuples
C_BG1     = (26,  26,  46,  255)
C_BG2     = (15,  52,  96,  255)
C_SURF    = (45,  45,  68,  255)
C_SURF2   = (52,  52,  84,  255)
C_PRIMARY = (108, 99,  255, 255)
C_SECOND  = (59,  130, 246, 255)
C_ORANGE  = (255, 107, 53,  255)
C_RED     = (255, 71,  87,  255)
C_WHITE   = (255, 255, 255, 255)
C_W70     = (255, 255, 255, 178)
C_W50     = (255, 255, 255, 127)
C_W30     = (255, 255, 255,  76)
C_W12     = (255, 255, 255,  30)
C_W08     = (255, 255, 255,  20)


def rgba(c, a=None):
    """Return a 4-tuple colour. Pass a=int to override alpha."""
    if a is not None:
        return (c[0], c[1], c[2], a)
    return c[:4] if len(c) == 4 else c + (255,)


# ── Low-level draw helpers ────────────────────────────────────────────────────

def make_grad(w, h, c1, c2, angle=135):
    img = Image.new("RGBA", (w, h), c1)
    top = Image.new("RGBA", (w, h), c2)
    msk = Image.new("L",    (w, h))
    ar  = math.radians(angle)
    denom = w * math.cos(ar) + h * math.sin(ar)
    for y in range(h):
        for x in range(w):
            v = int(255 * (x * math.cos(ar) + y * math.sin(ar)) / denom)
            msk.putpixel((x, y), max(0, min(255, v)))
    img.paste(top, mask=msk)
    return img


def rrect(draw, x0, y0, x1, y1, r, color):
    x0, y0, x1, y1 = int(x0), int(y0), int(x1), int(y1)
    if x1 <= x0 or y1 <= y0:
        return
    r = max(0, min(r, (x1-x0)//2, (y1-y0)//2))
    draw.rectangle([x0+r, y0,   x1-r, y1  ], fill=color)
    draw.rectangle([x0,   y0+r, x1,   y1-r], fill=color)
    if r > 0:
        draw.ellipse([x0,     y0,     x0+2*r, y0+2*r], fill=color)
        draw.ellipse([x1-2*r, y0,     x1,     y0+2*r], fill=color)
        draw.ellipse([x0,     y1-2*r, x0+2*r, y1    ], fill=color)
        draw.ellipse([x1-2*r, y1-2*r, x1,     y1    ], fill=color)


def overlay_circle(img, cx, cy, r, color):
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.ellipse([cx-r, cy-r, cx+r, cy+r], fill=color)
    return Image.alpha_composite(img, layer)


def overlay_rrect(img, x0, y0, x1, y1, r, color):
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    rrect(d, x0, y0, x1, y1, r, color)
    return Image.alpha_composite(img, layer)


def get_font(size, bold=False):
    from PIL import ImageFont
    paths = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/dejavu/DejaVuSans.ttf",
    ]
    preferred = paths[0] if bold else paths[1]
    for p in ([preferred] + paths):
        try:
            return ImageFont.truetype(p, size)
        except Exception:
            pass
    return ImageFont.load_default()


def draw_text(draw, text, x, y, size, color, bold=False):
    f = get_font(size, bold)
    draw.text((x, y), text, font=f, fill=color)
    bb = draw.textbbox((x, y), text, font=f)
    return bb[2] - bb[0]   # return width


def center_text(img_w, draw, text, y, size, color, bold=False):
    f = get_font(size, bold)
    bb = draw.textbbox((0, 0), text, font=f)
    tw = bb[2] - bb[0]
    draw.text(((img_w - tw) // 2, y), text, font=f, fill=color)


# ── CalcPro logo box ──────────────────────────────────────────────────────────

def draw_logo_box(img, cx, cy, size):
    """Draw the gradient logo square centred at (cx, cy)."""
    half = size // 2
    r    = size // 5

    # Soft glow
    for i in range(6, 0, -1):
        gr = half + i * (size // 12)
        ga = int(35 * i / 6)
        img = overlay_circle(img, cx, cy, gr, rgba(C_PRIMARY, ga))

    # Base purple square
    img = overlay_rrect(img, cx-half, cy-half, cx+half, cy+half,
                        r, C_PRIMARY)
    # Blue highlight triangle (right half)
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d     = ImageDraw.Draw(layer)
    rrect(d, cx, cy-half, cx+half, cy+half, r, C_SECOND)
    img = Image.alpha_composite(img, layer)

    draw = ImageDraw.Draw(img)

    # --- Calculator icon inside ---
    sw   = int(size * 0.52)
    sh   = int(size * 0.60)
    sx   = cx - sw // 2
    sy   = cy - sh // 2

    # Screen rectangle
    scr_h = int(sh * 0.28)
    rrect(draw, sx, sy, sx+sw, sy+scr_h, max(2, size//20), rgba(C_WHITE, 45))

    # Number stub on screen
    f_s = get_font(max(8, size//10))
    draw.text((sx + sw - size//6, sy + scr_h//4), "42", font=f_s,
              fill=rgba(C_WHITE, 200))

    # Button grid (3 × 3)
    bgap = max(2, int(size * 0.035))
    bcols, brows = 3, 3
    bstart_y = sy + scr_h + bgap
    bw2 = (sw - bgap*(bcols+1)) // bcols
    bh2 = max(4, int(bw2 * 0.65))
    br2 = max(2, size // 22)

    for row in range(brows):
        for col in range(bcols):
            bx2 = sx + bgap + col*(bw2+bgap)
            by2 = bstart_y + row*(bh2+bgap)
            c   = C_ORANGE if (row == brows-1 and col == bcols-1) \
                  else rgba(C_WHITE, 180)
            rrect(draw, bx2, by2, bx2+bw2, by2+bh2, br2, c)

    return img


# ── 1.  HIGH-RES ICON  512×512 ────────────────────────────────────────────────

def make_icon():
    W = H = 512
    bg   = make_grad(W, H, C_BG1, C_BG2)

    # Rounded-corner mask
    mask = Image.new("L", (W, H), 0)
    rrect(ImageDraw.Draw(mask), 0, 0, W, H, 110, 255)

    result = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    result.paste(bg, mask=mask)

    result = draw_logo_box(result, W//2, H//2, 310)
    result.putalpha(mask)

    result.convert("RGBA").save(f"{OUT}/icon_512x512.png")
    print("  icon_512x512.png")


# ── 2.  FEATURE GRAPHIC  1024×500 ─────────────────────────────────────────────

def make_feature():
    W, H = 1024, 500
    img  = make_grad(W, H, C_BG1, C_BG2, 150)

    # Decorative circles
    img = overlay_circle(img, 860,  50, 210, rgba(C_PRIMARY, 18))
    img = overlay_circle(img, 970, 430, 170, rgba(C_SECOND,  14))
    img = overlay_circle(img,  80, 460, 140, rgba(C_PRIMARY, 11))

    # Logo
    img = draw_logo_box(img, 150, 210, 170)

    draw = ImageDraw.Draw(img)

    # Title + subtitle
    center_text(520, draw, "CalcPro", 90, 80, C_WHITE, bold=True)
    center_text(520, draw, "Smart Calculator", 190, 32, C_W70)

    # Feature pills
    tags    = ["Secure Login", "Full Arithmetic", "Modern Dark UI", "100% Offline"]
    pill_x  = 320
    pill_y  = 270
    for tag in tags:
        f   = get_font(24)
        bb  = draw.textbbox((0,0), tag, font=f)
        tw  = bb[2]-bb[0]
        pw  = tw + 36
        ph  = 48
        img = overlay_rrect(img, pill_x, pill_y, pill_x+pw, pill_y+ph,
                            ph//2, rgba(C_PRIMARY, 70))
        draw = ImageDraw.Draw(img)
        draw.text((pill_x+18, pill_y+11), tag, font=f, fill=C_WHITE)
        pill_x += pw + 20
        if pill_x > W - 60:
            pill_x  = 320
            pill_y += 60

    # Mini calculator card on right
    mx, my = 700, 55
    mw, mh = 285, 390
    mr = 22
    img = overlay_rrect(img, mx, my, mx+mw, my+mh, mr, rgba(C_SURF, 210))
    draw = ImageDraw.Draw(img)

    # Display
    rrect(draw, mx+14, my+14, mx+mw-14, my+88, 10, rgba(C_WHITE, 12))
    draw_text(draw, "1,234.5", mx+mw-140, my+38, 34, C_WHITE, bold=True)

    # Buttons
    bpad2 = 9
    bc, br = 4, 4
    bw3 = (mw - bpad2*(bc+1)) // bc
    bh3 = 48
    bsy2 = my + 100
    grid = [
        [("C",C_RED),   ("CE",C_RED),   ("%",C_SURF2), ("/",C_ORANGE)],
        [("7",C_SURF),  ("8",C_SURF),   ("9",C_SURF),  ("x",C_ORANGE)],
        [("4",C_SURF),  ("5",C_SURF),   ("6",C_SURF),  ("-",C_ORANGE)],
        [("1",C_SURF),  ("2",C_SURF),   ("3",C_SURF),  ("=",C_PRIMARY)],
    ]
    for row, rdata in enumerate(grid):
        for col, (lbl, col_c) in enumerate(rdata):
            bx3 = mx + bpad2 + col*(bw3+bpad2)
            by3 = bsy2 + row*(bh3+bpad2//2)
            rrect(draw, bx3, by3, bx3+bw3, by3+bh3, 8, col_c)
            f3 = get_font(16, bold=True)
            bb3 = draw.textbbox((0,0), lbl, font=f3)
            lw3 = bb3[2]-bb3[0]
            draw.text((bx3+(bw3-lw3)//2, by3+14), lbl, font=f3, fill=C_WHITE)

    img.save(f"{OUT}/feature_graphic_1024x500.png")
    print("  feature_graphic_1024x500.png")


# ── 3.  SCREENSHOTS  1080×1920 ────────────────────────────────────────────────

def base_screen():
    W, H = 1080, 1920
    img  = make_grad(W, H, C_BG1, C_BG2)
    draw = ImageDraw.Draw(img)
    # status bar
    draw_text(draw, "9:41", 60, 44, 36, C_W50)
    draw_text(draw, "WiFi  Bat", W-220, 44, 30, C_W50)
    return img, W, H


def field_row(img, draw, x, y, w, h, hint):
    img = overlay_rrect(img, x, y, x+w, y+h, 18, rgba(C_WHITE, 20))
    draw = ImageDraw.Draw(img)
    draw_text(draw, hint, x+24, y + h//2 - 16, 30, C_W30)
    return img, draw


def scr_splash():
    img, W, H = base_screen()
    img = overlay_circle(img, -60,  -60, 280, rgba(C_PRIMARY, 16))
    img = overlay_circle(img, W+60, H//2,320, rgba(C_SECOND,  12))
    img = overlay_circle(img,  80,  H-80, 220, rgba(C_PRIMARY,  9))

    img = draw_logo_box(img, W//2, H//2 - 130, 250)
    draw = ImageDraw.Draw(img)
    center_text(W, draw, "CalcPro",      H//2 + 80,  92, C_WHITE,  bold=True)
    center_text(W, draw, "Smart Calculator", H//2+200, 42, C_W70)
    center_text(W, draw, "v1.0.0",           H - 80,   28, C_W30)

    # Animated dots
    for i, a in enumerate([255, 160, 80]):
        dx = W//2 - 36 + i*36
        dy = H//2 + 310
        img = overlay_circle(img, dx, dy, 12, rgba(C_PRIMARY, a))

    img.save(f"{OUT}/screenshots/01_splash.png")
    print("  screenshots/01_splash.png")


def scr_login():
    img, W, H = base_screen()
    img = overlay_circle(img, W+50, -50, 260, rgba(C_PRIMARY, 14))
    img = overlay_circle(img, -70, H-180, 220, rgba(C_SECOND, 10))

    img = draw_logo_box(img, W//2, 270, 148)
    draw = ImageDraw.Draw(img)
    center_text(W, draw, "CalcPro", 370, 52, C_WHITE, bold=True)

    draw_text(draw, "Welcome back",         80, 490, 60, C_WHITE, bold=True)
    draw_text(draw, "Sign in to continue", 80, 576, 36, C_W50)

    fw = W - 160

    # Email field (focused — purple border)
    img = overlay_rrect(img, 80, 680, 80+fw, 780, 18, rgba(C_WHITE, 20))
    draw = ImageDraw.Draw(img)
    for i in range(3):
        for seg in [
            [80+i, 680+i, 80+fw-i, 680+i],
            [80+i, 780-i, 80+fw-i, 780-i],
            [80+i, 680+i, 80+i,    780-i],
            [80+fw-i, 680+i, 80+fw-i, 780-i],
        ]:
            draw.line(seg, fill=rgba(C_PRIMARY, 200 - i*60), width=1)
    draw_text(draw, "Username or Email", 80, 646, 28, C_W70)
    draw_text(draw, "ahmed@example.com", 110, 714, 34, C_WHITE)

    # Password field
    img, draw = field_row(img, draw, 80, 840, fw, 100, "Password")
    draw_text(draw, "Password", 80, 806, 28, C_W70)
    draw_text(draw, "* * * * * * * *", 110, 872, 34, C_W70)

    # Sign In button
    btn_y = 1010
    img = overlay_rrect(img, 80, btn_y, 80+fw, btn_y+104, 20, C_PRIMARY)
    draw = ImageDraw.Draw(img)
    center_text(W, draw, "Sign In", btn_y+28, 48, C_WHITE, bold=True)

    draw.line([(80, 1168), (80+fw, 1168)], fill=rgba(C_WHITE, 25), width=1)
    center_text(W, draw, "Don't have an account?", 1196, 34, C_W50)
    center_text(W, draw, "Register",               1248, 38, C_PRIMARY, bold=True)

    img.save(f"{OUT}/screenshots/02_login.png")
    print("  screenshots/02_login.png")


def scr_register():
    img, W, H = base_screen()
    img = overlay_circle(img, W+40, -40, 240, rgba(C_SECOND,  14))
    img = overlay_circle(img, -60,  H//2, 200, rgba(C_PRIMARY, 9))

    draw = ImageDraw.Draw(img)

    # Back button
    img = overlay_rrect(img, 60, 120, 170, 216, 20, rgba(C_WHITE, 18))
    draw = ImageDraw.Draw(img)
    center_text(110, draw, "<", 138, 48, C_WHITE)

    draw_text(draw, "Create Account",           80, 256, 62, C_WHITE, bold=True)
    draw_text(draw, "Sign up to use CalcPro",   80, 342, 34, C_W50)

    fw = W - 160
    fields = [
        ("Username",         "ahmed_shefo",       540),
        ("Email",            "ahmed@example.com", 700),
        ("Password",         "* * * * * * * *",  860),
        ("Confirm Password", "* * * * * * * *",  1020),
    ]
    for label, hint, fy in fields:
        draw_text(draw, label, 80, fy - 36, 28, C_W70)
        img = overlay_rrect(img, 80, fy, 80+fw, fy+100, 18, rgba(C_WHITE, 20))
        draw = ImageDraw.Draw(img)
        draw_text(draw, hint, 110, fy+30, 34, C_W70)

    btn_y = 1196
    img = overlay_rrect(img, 80, btn_y, 80+fw, btn_y+104, 20, C_PRIMARY)
    draw = ImageDraw.Draw(img)
    center_text(W, draw, "Create Account", btn_y+28, 48, C_WHITE, bold=True)

    center_text(W, draw, "Already have an account?  Sign In", 1368, 34, C_W50)

    img.save(f"{OUT}/screenshots/03_register.png")
    print("  screenshots/03_register.png")


def scr_calculator():
    img, W, H = base_screen()
    draw = ImageDraw.Draw(img)

    # AppBar background
    img = overlay_rrect(img, 0, 0, W, 148, 0, rgba(C_BG1, 255))
    img = draw_logo_box(img, 72, 94, 70)
    draw = ImageDraw.Draw(img)
    draw_text(draw, "CalcPro",      122, 62, 40, C_WHITE, bold=True)
    draw_text(draw, "Hi, ahmed",    W-280, 66, 28, C_W50)

    # Expression
    draw_text(draw, "1,234 x 56 =", 80, 200, 36, C_W50)

    # Big result
    f_big = get_font(130)
    result_str = "69,104"
    bb = draw.textbbox((0, 0), result_str, font=f_big)
    rw = bb[2]-bb[0]
    draw.text((W - rw - 80, 250), result_str, font=f_big, fill=C_WHITE)

    # Divider
    draw.line([(60, 430), (W-60, 430)], fill=rgba(C_WHITE, 22), width=2)

    # Button grid
    pad   = 18
    cols  = 4
    rows  = 5
    bw    = (W - pad*(cols+1)) // cols
    bh    = (H - 480 - pad*(rows-1) - 50) // rows
    br    = 24
    top_y = 460

    layout = [
        [("C", C_RED),    ("CE", C_RED),    ("%", C_SURF2),  ("/", C_ORANGE)],
        [("7", C_SURF),   ("8",  C_SURF),   ("9", C_SURF),   ("x", C_ORANGE)],
        [("4", C_SURF),   ("5",  C_SURF),   ("6", C_SURF),   ("-", C_ORANGE)],
        [("1", C_SURF),   ("2",  C_SURF),   ("3", C_SURF),   ("+", C_ORANGE)],
        [("+/-",C_SURF2), ("0",  C_SURF),   (".", C_SURF),   ("=", C_PRIMARY)],
    ]

    for row, rdata in enumerate(layout):
        for col, (lbl, col_c) in enumerate(rdata):
            bx = pad + col*(bw+pad)
            by = top_y + row*(bh+pad)

            # shadow
            img = overlay_rrect(img, bx+4, by+6, bx+bw+4, by+bh+6, br,
                                rgba(C_BG1, 60))
            img = overlay_rrect(img, bx, by, bx+bw, by+bh, br, col_c)
            draw = ImageDraw.Draw(img)

            fsz = 30 if len(lbl) > 1 else 42
            f   = get_font(fsz, bold=True)
            bb  = draw.textbbox((0,0), lbl, font=f)
            lw  = bb[2]-bb[0]
            lh  = bb[3]-bb[1]
            draw.text((bx+(bw-lw)//2, by+(bh-lh)//2 - 2),
                      lbl, font=f, fill=C_WHITE)

    img.save(f"{OUT}/screenshots/04_calculator.png")
    print("  screenshots/04_calculator.png")


# ── Entry point ───────────────────────────────────────────────────────────────
if __name__ == "__main__":
    os.makedirs(f"{OUT}/screenshots", exist_ok=True)
    print("Generating Google Play assets...")
    make_icon()
    make_feature()
    scr_splash()
    scr_login()
    scr_register()
    scr_calculator()
    print(f"\nDone. All files saved to ./{OUT}/")
