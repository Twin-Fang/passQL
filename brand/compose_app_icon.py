#!/usr/bin/env python3
"""
앱 아이콘 원본 2개 합성 (#766 시안 8): 가로 로고 > pass(남색) 위 · QL(18% 진하게) 아래 2줄
출력 2개: app_icon_1024.png (연보라 세로 그라데이션 배경), app_icon_adaptive_foreground.png (투명, Android 원형 안전 영역 안)
이후 generate_brand_assets_for_all_platforms.py 와 flutter_launcher_icons 가 플랫폼 사본을 만든다
"""
import json
from pathlib import Path

from PIL import Image, ImageEnhance

BRAND_DIR = Path(__file__).resolve().parent
LOGO_PATH = BRAND_DIR / "logo_horizontal.png"
ICON_PATH = BRAND_DIR / "app_icon_1024.png"
FOREGROUND_PATH = BRAND_DIR / "app_icon_adaptive_foreground.png"
COLORS_PATH = BRAND_DIR / "brand-colors.json"

ICON_SIZE_PIXELS = 1024

# 가로 로고 안 글자 경계 (열 번호): pass 는 0..PASS_END, QL 은 QL_START..끝 (채도 기준으로 측정)
LOGO_PASS_END_COLUMN = 788
LOGO_QL_START_COLUMN = 815

# QL 을 원본보다 진하게 (밝은 배경 대비, 시안 8: 18%)
QL_BRIGHTNESS_FACTOR = 0.82

# 아이콘 안 배치: 묶음 폭 비율, pass 폭 / QL 폭, 줄 간격 (아이콘 크기 대비)
ICON_GROUP_WIDTH_RATIO = 0.62
FOREGROUND_GROUP_WIDTH_RATIO = 0.50  # Android 적응형: 지름 66% 원 안에 들어가게
PASS_TO_QL_WIDTH_RATIO = 0.78
LINE_GAP_RATIO = 0.035


def load_logo_parts() -> tuple[Image.Image, Image.Image]:
    """가로 로고 > (pass, QL) 글자 이미지 (투명 여백 잘라냄, QL 은 진하게)"""
    logo = Image.open(LOGO_PATH).convert("RGBA")
    pass_part = logo.crop((0, 0, LOGO_PASS_END_COLUMN, logo.height))
    ql_part = logo.crop((LOGO_QL_START_COLUMN, 0, logo.width, logo.height))
    pass_part = pass_part.crop(pass_part.getbbox())
    ql_part = ql_part.crop(ql_part.getbbox())
    ql_rgb = ImageEnhance.Brightness(ql_part.convert("RGB")).enhance(QL_BRIGHTNESS_FACTOR)
    ql_rgb.putalpha(ql_part.getchannel("A"))
    return pass_part, ql_rgb


def scaled_to_width(image: Image.Image, width_pixels: int) -> Image.Image:
    """비율 유지 폭 맞춤"""
    height_pixels = round(image.height * width_pixels / image.width)
    return image.resize((width_pixels, height_pixels), Image.LANCZOS)


def compose_wordmark_group(group_width_pixels: int) -> Image.Image:
    """pass 위 · QL 아래, 가운데 정렬 묶음 (투명)"""
    pass_part, ql_part = load_logo_parts()
    ql_scaled = scaled_to_width(ql_part, group_width_pixels)
    pass_scaled = scaled_to_width(pass_part, round(group_width_pixels * PASS_TO_QL_WIDTH_RATIO))
    line_gap_pixels = round(ICON_SIZE_PIXELS * LINE_GAP_RATIO)
    group = Image.new("RGBA", (group_width_pixels, pass_scaled.height + line_gap_pixels + ql_scaled.height))
    group.alpha_composite(pass_scaled, ((group_width_pixels - pass_scaled.width) // 2, 0))
    group.alpha_composite(ql_scaled, (0, pass_scaled.height + line_gap_pixels))
    return group


def vertical_gradient(top_hex: str, bottom_hex: str) -> Image.Image:
    """위 > 아래 세로 그라데이션 배경"""
    top = tuple(int(top_hex[i:i + 2], 16) for i in (1, 3, 5))
    bottom = tuple(int(bottom_hex[i:i + 2], 16) for i in (1, 3, 5))
    background = Image.new("RGB", (ICON_SIZE_PIXELS, ICON_SIZE_PIXELS))
    for y in range(ICON_SIZE_PIXELS):
        ratio = y / (ICON_SIZE_PIXELS - 1)
        color = tuple(round(top[i] + (bottom[i] - top[i]) * ratio) for i in range(3))
        background.paste(color, (0, y, ICON_SIZE_PIXELS, y + 1))
    return background


def centered_on(canvas: Image.Image, group: Image.Image) -> Image.Image:
    """묶음을 캔버스 가운데에"""
    result = canvas.convert("RGBA")
    result.alpha_composite(group, ((canvas.width - group.width) // 2, (canvas.height - group.height) // 2))
    return result


def main() -> None:
    colors = json.loads(COLORS_PATH.read_text(encoding="utf-8"))
    gradient = colors["appIconGradient"]

    # iOS·웹 원본: 불투명 (App Store 아이콘은 알파 금지)
    icon = centered_on(vertical_gradient(gradient["top"], gradient["bottom"]),
                       compose_wordmark_group(round(ICON_SIZE_PIXELS * ICON_GROUP_WIDTH_RATIO)))
    icon.convert("RGB").save(ICON_PATH)

    # Android 적응형 전경: 투명, 배경색은 brand-colors.json appIconBackground
    foreground = centered_on(Image.new("RGBA", (ICON_SIZE_PIXELS, ICON_SIZE_PIXELS)),
                             compose_wordmark_group(round(ICON_SIZE_PIXELS * FOREGROUND_GROUP_WIDTH_RATIO)))
    foreground.save(FOREGROUND_PATH)
    print(f"wrote {ICON_PATH.name}, {FOREGROUND_PATH.name}")


if __name__ == "__main__":
    main()
