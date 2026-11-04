# -*- coding: utf-8 -*-
"""사이트 아이콘·공유 이미지 생성 (#823): 앱 아이콘 원본 1장 > mark·favicon·og
실행: python3 -I _src/build_icons.py <main 레포 루트>  (gh-pages 루트에서)
원본: main brand/app_icon_1024.png (#766)·brand-colors.json, 글꼴 app/assets/fonts/Pretendard-*, 캡처 shots/execute.webp
og 는 Chrome 헤드리스로 찍음 (글꼴·한글 조판을 브라우저에 맡김)
"""

import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

SITE_ROOT = Path(__file__).resolve().parents[1]
ICON_DIR = SITE_ROOT / "icon"
CHROME_PATH = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# 상단 바·마지막 구역 표시 크기(28·72px)의 레티나 여유
MARK_SIZE_PIXELS = 192
FAVICON_SIZES_PIXELS = (32, 180)
FAVICON_ICO_SIZES = [(16, 16), (32, 32), (48, 48)]
# SNS 공유 미리보기 표준
OG_SIZE_PIXELS = (1200, 630)

OG_TEMPLATE = """<!doctype html><html lang="ko"><head><meta charset="utf-8"><style>
@font-face {{ font-family: P; src: url("{font_dir}/Pretendard-Bold.ttf"); font-weight: 800; }}
@font-face {{ font-family: P; src: url("{font_dir}/Pretendard-SemiBold.ttf"); font-weight: 600; }}
html, body {{ margin: 0; width: 1200px; height: 630px; overflow: hidden; }}
body {{ font-family: P, sans-serif; background: linear-gradient(135deg, {gradient_top} 0%, {gradient_bottom} 100%); color: #0b0b12; position: relative; }}
.copy {{ position: absolute; left: 80px; top: 92px; width: 640px; }}
.brand {{ display: flex; align-items: center; gap: 20px; font-size: 40px; font-weight: 800; letter-spacing: -0.02em; }}
.brand img {{ width: 92px; height: 92px; border-radius: 22px; box-shadow: 0 12px 30px rgba(72, 70, 194, 0.28); }}
h1 {{ margin: 44px 0 0; font-size: 76px; line-height: 1.12; letter-spacing: -0.035em; font-weight: 800; }}
h1 span {{ color: {accent}; }}
p {{ margin: 30px 0 0; font-size: 28px; font-weight: 600; color: #545463; }}
.stores {{ margin-top: 26px; font-size: 24px; font-weight: 600; color: {accent}; }}
.phone {{ position: absolute; right: 70px; top: 70px; width: 300px; padding: 10px; border-radius: 52px; background: #101015;
  transform: rotate(8deg); box-shadow: 0 40px 80px -20px rgba(40, 36, 120, 0.5); }}
.phone img {{ display: block; width: 100%; border-radius: 42px; }}
</style></head><body>
<div class="copy">
  <div class="brand"><img src="{icon_uri}" alt="">passQL</div>
  <h1>SQLD,<br><span>앱 하나로</span> 끝내세요</h1>
  <p>최신 기출 경향 · SQL 직접 실행 · AI 해설</p>
  <div class="stores">App Store · Google Play · 웹</div>
</div>
<div class="phone"><img src="{shot_uri}" alt=""></div>
</body></html>"""


def write_resized_icons(brand_icon):
    """앱 아이콘 > mark·favicon png·ico"""
    brand_icon.resize((MARK_SIZE_PIXELS, MARK_SIZE_PIXELS), Image.LANCZOS).save(ICON_DIR / "mark.png", optimize=True)
    for size in FAVICON_SIZES_PIXELS:
        brand_icon.resize((size, size), Image.LANCZOS).save(ICON_DIR / f"favicon-{size}.png", optimize=True)
    brand_icon.save(SITE_ROOT / "favicon.ico", sizes=FAVICON_ICO_SIZES)


def write_open_graph_image(brand_icon_path, font_dir, brand_colors):
    """공유 이미지: 템플릿 채움(배경·강조색은 brand-colors.json) > Chrome 캡처 > 크기 검증"""
    page_html = OG_TEMPLATE.format(
        gradient_top=brand_colors["appIconGradient"]["top"],
        gradient_bottom=brand_colors["appIconGradient"]["bottom"],
        accent=brand_colors["accent"]["light"],
        font_dir=Path(font_dir).resolve().as_uri(),
        icon_uri=Path(brand_icon_path).resolve().as_uri(),
        shot_uri=(SITE_ROOT / "shots" / "execute.webp").as_uri(),
    )
    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False, encoding="utf-8") as page:
        page.write(page_html)
    out_path = ICON_DIR / "og.png"
    try:
        subprocess.run(
            [CHROME_PATH, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
             f"--window-size={OG_SIZE_PIXELS[0]},{OG_SIZE_PIXELS[1]}", "--virtual-time-budget=3000",
             "--allow-file-access-from-files", f"--screenshot={out_path}", Path(page.name).as_uri()],
            check=True, capture_output=True,
        )
    finally:
        os.unlink(page.name)
    with Image.open(out_path) as image:
        if image.size != OG_SIZE_PIXELS:
            raise SystemExit(f"[site icons] og size mismatch : {image.size}")
        image.convert("RGB").save(out_path, optimize=True)


def main():
    if len(sys.argv) != 2:
        raise SystemExit("usage: python3 -I _src/build_icons.py <main repo root>")
    main_root = Path(sys.argv[1])
    brand_icon_path = main_root / "brand" / "app_icon_1024.png"
    brand_icon = Image.open(brand_icon_path).convert("RGB")
    write_resized_icons(brand_icon)
    brand_colors = json.loads((main_root / "brand" / "brand-colors.json").read_text(encoding="utf-8"))
    write_open_graph_image(brand_icon_path, main_root / "app" / "assets" / "fonts", brand_colors)
    print("[site icons] wrote mark, favicon-32, favicon-180, favicon.ico, og")


if __name__ == "__main__":
    main()
