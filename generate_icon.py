"""
Generates CalcPro app icon PNG files.
Creates a modern dark-themed calculator icon with gradient effect.
"""
from PIL import Image, ImageDraw, ImageFont
import math
import os

def create_gradient(width, height, color1, color2, angle=135):
    """Create a diagonal gradient background."""
    base = Image.new('RGBA', (width, height), color1)
    top = Image.new('RGBA', (width, height), color2)
    mask = Image.new('L', (width, height))
    draw = ImageDraw.Draw(mask)
    
    angle_rad = math.radians(angle)
    for y in range(height):
        for x in range(width):
            value = int(255 * (x * math.cos(angle_rad) + y * math.sin(angle_rad)) / 
                       (width * math.cos(angle_rad) + height * math.sin(angle_rad)))
            value = max(0, min(255, value))
            mask.putpixel((x, y), value)
    
    base.paste(top, mask=mask)
    return base

def draw_rounded_rect(draw, xy, radius, fill):
    """Draw a rounded rectangle."""
    x0, y0, x1, y1 = xy
    draw.rectangle([x0 + radius, y0, x1 - radius, y1], fill=fill)
    draw.rectangle([x0, y0 + radius, x1, y1 - radius], fill=fill)
    draw.ellipse([x0, y0, x0 + radius * 2, y0 + radius * 2], fill=fill)
    draw.ellipse([x1 - radius * 2, y0, x1, y0 + radius * 2], fill=fill)
    draw.ellipse([x0, y1 - radius * 2, x0 + radius * 2, y1], fill=fill)
    draw.ellipse([x1 - radius * 2, y1 - radius * 2, x1, y1], fill=fill)

def create_calculator_icon(size=1024):
    """Create a modern calculator app icon."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Background with rounded corners
    bg_gradient = create_gradient(size, size, 
                                   (26, 26, 46, 255),    # #1A1A2E dark navy
                                   (15, 52, 96, 255))    # #0F3460 deep blue
    
    # Apply rounded corners mask to background
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = int(size * 0.22)
    draw_rounded_rect(mask_draw, [0, 0, size, size], corner_radius, 255)
    
    img.paste(bg_gradient, (0, 0))
    img.putalpha(mask)
    
    draw = ImageDraw.Draw(img)
    
    # Draw the "C" symbol in bold
    # Calculator display area (top portion)
    display_margin = int(size * 0.1)
    display_height = int(size * 0.22)
    display_w = size - display_margin * 2
    display_x = display_margin
    display_y = int(size * 0.1)
    
    # Display background - soft glow rectangle
    display_color = (108, 99, 255, 60)  # Semi-transparent purple
    draw_rounded_rect(draw, 
                      [display_x, display_y, display_x + display_w, display_y + display_height],
                      int(display_height * 0.25), 
                      display_color)
    
    # Display number "42" in white
    num_x = display_x + display_w - int(size * 0.08)
    num_y = display_y + int(display_height * 0.2)
    num_size = int(display_height * 0.6)
    
    # Draw digits manually since we can't rely on fonts
    # "=" symbol as lines on the display
    line_color = (255, 255, 255, 200)
    line_h = int(num_size * 0.15)
    line_w = int(display_w * 0.35)
    line_x = display_x + display_w - line_w - int(size * 0.06)
    line_y1 = display_y + int(display_height * 0.35)
    line_y2 = display_y + int(display_height * 0.6)
    draw.rectangle([line_x, line_y1, line_x + line_w, line_y1 + line_h], fill=line_color)
    draw.rectangle([line_x, line_y2, line_x + line_w, line_y2 + line_h], fill=line_color)
    
    # Button grid (3 columns x 4 rows of buttons)
    btn_area_top = int(size * 0.37)
    btn_area_bottom = int(size * 0.93)
    btn_area_left = int(size * 0.08)
    btn_area_right = int(size * 0.92)
    
    cols = 4
    rows = 4
    gap = int(size * 0.03)
    btn_w = (btn_area_right - btn_area_left - gap * (cols - 1)) // cols
    btn_h = (btn_area_bottom - btn_area_top - gap * (rows - 1)) // rows
    btn_radius = int(btn_h * 0.28)
    
    # Button colors
    colors = {
        'num': (45, 45, 68, 230),        # Dark blue-grey
        'op': (255, 107, 53, 230),        # Orange
        'clear': (255, 71, 87, 230),      # Red
        'eq': (108, 99, 255, 255),        # Purple
        'zero': (45, 45, 68, 230),
    }
    
    layout = [
        ['clear', 'op',  'op',  'op'],
        ['num',   'num', 'num', 'op'],
        ['num',   'num', 'num', 'op'],
        ['num',   'num', 'num', 'eq'],
    ]
    
    for row in range(rows):
        for col in range(cols):
            bx = btn_area_left + col * (btn_w + gap)
            by = btn_area_top + row * (btn_h + gap)
            btype = layout[row][col]
            color = colors[btype]
            draw_rounded_rect(draw, [bx, by, bx + btn_w, by + btn_h], btn_radius, color)
    
    # Add subtle glow on equals button (bottom-right)
    last_col = cols - 1
    last_row = rows - 1
    glow_x = btn_area_left + last_col * (btn_w + gap) + btn_w // 2
    glow_y = btn_area_top + last_row * (btn_h + gap) + btn_h // 2
    glow_r = btn_w * 2
    
    # Glow effect via radial transparent circles
    for i in range(6, 0, -1):
        r = glow_r * i // 6
        alpha = int(30 * (7 - i) / 6)
        glow_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        gd = ImageDraw.Draw(glow_img)
        gd.ellipse([glow_x - r, glow_y - r, glow_x + r, glow_y + r], 
                   fill=(108, 99, 255, alpha))
        img = Image.alpha_composite(img, glow_img)
        draw = ImageDraw.Draw(img)
    
    return img

def create_foreground_icon(size=1024):
    """Create a foreground icon for Android adaptive icons."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    # Use a slightly smaller calculator on transparent background
    # for the adaptive icon foreground layer
    calc = create_calculator_icon(int(size * 0.6))
    offset = int(size * 0.2)
    img.paste(calc, (offset, offset), calc)
    return img

if __name__ == '__main__':
    os.makedirs('assets/icon', exist_ok=True)
    
    # Main app icon
    icon = create_calculator_icon(1024)
    icon.save('assets/icon/app_icon.png')
    print("Created assets/icon/app_icon.png")
    
    # Adaptive foreground icon  
    fg = create_foreground_icon(1024)
    fg.save('assets/icon/app_icon_fg.png')
    print("Created assets/icon/app_icon_fg.png")
    
    print("Icon generation complete!")
