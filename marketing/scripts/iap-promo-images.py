"""
Generate 1024×1024 PNG promotional images for the three Weft Premium IAP tiers.
Renders on a 4096×4096 canvas with full antialiasing primitives, then downsamples
with LANCZOS — yields cleaner edges than PIL's native non-antialiased drawing on
the final size, especially for curved strokes.

App Store Connect requires: 1024×1024 PNG, sRGB, NO alpha, no rounded corners
(Apple rounds them on display).

Concept per tier (intentionally minimal, each one a single load-bearing symbol
that reads at the 84×84 thumbnail size App Store uses):
  • Lifetime — lemniscate (∞) drawn as a continuous sage stroke
  • Yearly   — twelve sage dots arranged in a circle (one per month)
  • Monthly  — one solid sage dot, centered

Run from anywhere:
  python3 marketing/scripts/iap-promo-images.py
Outputs:
  marketing/iap-images/iap-lifetime.png
  marketing/iap-images/iap-yearly.png
  marketing/iap-images/iap-monthly.png
"""

import math
from pathlib import Path
from PIL import Image, ImageDraw

OUT_DIR = Path(__file__).resolve().parent.parent / "iap-images"
OUT_DIR.mkdir(parents=True, exist_ok=True)

# Design tokens (matched to Weft/Resources/Assets.xcassets).
BG = (248, 245, 239)   # #F8F5EF cream
SAGE = (92, 122, 102)  # #5C7A66
SAGE_WASH = (210, 222, 213)  # very faint sage tint for inner texture

FINAL = 1024
SUPER = 4 * FINAL  # 4096 — gives smooth curves after LANCZOS downsample
CENTER = SUPER // 2


def new_canvas() -> Image.Image:
    """4096×4096 cream canvas, RGB (no alpha — App Store Connect requires this)."""
    return Image.new("RGB", (SUPER, SUPER), BG)


def downsample(img: Image.Image) -> Image.Image:
    return img.resize((FINAL, FINAL), Image.LANCZOS)


def draw_lifetime() -> Image.Image:
    """
    Lemniscate of Bernoulli: x = a·cos(t)/(1+sin²t), y = a·cos(t)·sin(t)/(1+sin²t).
    Sample densely and stamp overlapping sage discs at each point — gives a
    perfectly smooth stroke without the spike artifacts PIL's thick polyline
    introduces at curved-segment joins.
    """
    img = new_canvas()
    draw = ImageDraw.Draw(img)
    a = int(SUPER * 0.32)          # half-width of the loop
    radius = int(SUPER * 0.013)    # disc radius; final stroke ≈ 2*radius
    steps = 2400                   # dense enough that adjacent discs overlap
    for i in range(steps + 1):
        t = -math.pi / 2 + (2 * math.pi) * i / steps
        denom = 1 + math.sin(t) ** 2
        x = a * math.cos(t) / denom
        y = a * math.cos(t) * math.sin(t) / denom
        cx, cy = CENTER + x, CENTER + y
        draw.ellipse((cx - radius, cy - radius, cx + radius, cy + radius), fill=SAGE)
    return downsample(img)


def draw_yearly() -> Image.Image:
    """
    Twelve sage dots evenly spaced on a circle, starting at 12 o'clock.
    Reads as a calendar / annual cycle without spelling it out.
    """
    img = new_canvas()
    draw = ImageDraw.Draw(img)
    ring_radius = int(SUPER * 0.30)
    dot_radius = int(SUPER * 0.035)
    for i in range(12):
        angle = -math.pi / 2 + (2 * math.pi) * i / 12  # start at top
        cx = CENTER + ring_radius * math.cos(angle)
        cy = CENTER + ring_radius * math.sin(angle)
        draw.ellipse(
            (cx - dot_radius, cy - dot_radius, cx + dot_radius, cy + dot_radius),
            fill=SAGE,
        )
    return downsample(img)


def draw_monthly() -> Image.Image:
    """One solid sage disc, centered. Minimal — represents a single cycle."""
    img = new_canvas()
    draw = ImageDraw.Draw(img)
    r = int(SUPER * 0.20)
    draw.ellipse((CENTER - r, CENTER - r, CENTER + r, CENTER + r), fill=SAGE)
    return downsample(img)


def main() -> None:
    targets = [
        ("iap-lifetime.png", draw_lifetime),
        ("iap-yearly.png", draw_yearly),
        ("iap-monthly.png", draw_monthly),
    ]
    for name, fn in targets:
        out = OUT_DIR / name
        img = fn()
        # Strip any alpha just in case and save as PNG with no extra metadata.
        img.convert("RGB").save(out, format="PNG", optimize=True)
        print(f"wrote {out}  size={img.size}  mode=RGB")


if __name__ == "__main__":
    main()
