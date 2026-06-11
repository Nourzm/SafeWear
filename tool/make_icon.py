"""Generates the SafeWear launcher icon (blue gradient + white shield)."""
from PIL import Image, ImageDraw

SIZE = 1024
img = Image.new("RGBA", (SIZE, SIZE))
draw = ImageDraw.Draw(img)

# Diagonal gradient #003D70 -> #005394 -> #1A6FAA
c1, c2, c3 = (0x00, 0x3D, 0x70), (0x00, 0x53, 0x94), (0x1A, 0x6F, 0xAA)
for y in range(SIZE):
    for_x_t = y / SIZE
    if for_x_t < 0.5:
        t = for_x_t * 2
        r = int(c1[0] + (c2[0] - c1[0]) * t)
        g = int(c1[1] + (c2[1] - c1[1]) * t)
        b = int(c1[2] + (c2[2] - c1[2]) * t)
    else:
        t = (for_x_t - 0.5) * 2
        r = int(c2[0] + (c3[0] - c2[0]) * t)
        g = int(c2[1] + (c3[1] - c2[1]) * t)
        b = int(c2[2] + (c3[2] - c2[2]) * t)
    draw.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

# Shield shape (white), centered
cx, cy = SIZE / 2, SIZE / 2
w, h = 480, 560
top = cy - h / 2
shield = [
    (cx, top),                       # top point
    (cx + w / 2, top + h * 0.16),    # right shoulder
    (cx + w / 2, top + h * 0.55),    # right side
    (cx, top + h),                   # bottom point
    (cx - w / 2, top + h * 0.55),    # left side
    (cx - w / 2, top + h * 0.16),    # left shoulder
]
draw.polygon(shield, fill=(255, 255, 255, 255))

# Inner shield (gradient blue again, slightly smaller) for a ring effect
w2, h2 = w - 96, h - 112
top2 = cy - h2 / 2
inner = [
    (cx, top2),
    (cx + w2 / 2, top2 + h2 * 0.16),
    (cx + w2 / 2, top2 + h2 * 0.55),
    (cx, top2 + h2),
    (cx - w2 / 2, top2 + h2 * 0.55),
    (cx - w2 / 2, top2 + h2 * 0.16),
]
draw.polygon(inner, fill=(0x00, 0x53, 0x94, 255))

# Check mark (white, thick) inside the shield
check = [(cx - 110, cy + 0), (cx - 30, cy + 85), (cx + 120, cy - 90)]
draw.line(check, fill=(255, 255, 255, 255), width=58, joint="curve")
# Round the check ends
for px, py in (check[0], check[2]):
    draw.ellipse([px - 29, py - 29, px + 29, py + 29], fill=(255, 255, 255, 255))

img.save(r"D:\Desktop\SafeWear\safewear\assets\icons\app_icon.png")

# Foreground for Android adaptive icon: shield on transparent, with safe margin
fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
fgd = ImageDraw.Draw(fg)
scale = 0.62
w3, h3 = w * scale, h * scale
top3 = cy - h3 / 2
outer3 = [
    (cx, top3),
    (cx + w3 / 2, top3 + h3 * 0.16),
    (cx + w3 / 2, top3 + h3 * 0.55),
    (cx, top3 + h3),
    (cx - w3 / 2, top3 + h3 * 0.55),
    (cx - w3 / 2, top3 + h3 * 0.16),
]
fgd.polygon(outer3, fill=(255, 255, 255, 255))
w4, h4 = (w - 96) * scale, (h - 112) * scale
top4 = cy - h4 / 2
inner4 = [
    (cx, top4),
    (cx + w4 / 2, top4 + h4 * 0.16),
    (cx + w4 / 2, top4 + h4 * 0.55),
    (cx, top4 + h4),
    (cx - w4 / 2, top4 + h4 * 0.55),
    (cx - w4 / 2, top4 + h4 * 0.16),
]
fgd.polygon(inner4, fill=(0x00, 0x53, 0x94, 255))
check4 = [
    (cx - 110 * scale, cy),
    (cx - 30 * scale, cy + 85 * scale),
    (cx + 120 * scale, cy - 90 * scale),
]
fgd.line(check4, fill=(255, 255, 255, 255), width=int(58 * scale), joint="curve")
for px, py in (check4[0], check4[2]):
    r = int(29 * scale)
    fgd.ellipse([px - r, py - r, px + r, py + r], fill=(255, 255, 255, 255))

fg.save(r"D:\Desktop\SafeWear\safewear\assets\icons\app_icon_foreground.png")
print("icons written")
