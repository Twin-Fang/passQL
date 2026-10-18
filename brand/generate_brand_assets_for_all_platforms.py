#!/usr/bin/env python3
"""
브랜드 원본(brand/) > 플랫폼 사본 생성 (앱·iOS·Android·웹·관리자)
--check: 생성 결과 <-> 현재 파일 비교, 다르면 목록 출력 후 exit 1 (#459)
"""

import argparse
import functools
import io
import json
import shutil
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Optional

from PIL import Image, ImageChops

from brand_color_consistency import find_brand_color_mismatches, load_brand_colors

BRAND_DIRECTORY = Path(__file__).resolve().parent
REPOSITORY_ROOT = BRAND_DIRECTORY.parent

# 이미지 원본 3개: 가로 로고(투명), 앱 아이콘, 적응형 아이콘 전경 (색 원본 brand-colors.json 은 brand_color_consistency.py 에서 읽음)
SOURCE_LOGO_HORIZONTAL = BRAND_DIRECTORY / "logo_horizontal.png"
SOURCE_APP_ICON = BRAND_DIRECTORY / "app_icon_1024.png"
SOURCE_APP_ICON_ADAPTIVE_FOREGROUND = BRAND_DIRECTORY / "app_icon_adaptive_foreground.png"

# 다크 로고 변환 기준 (#453): 어두운 무채색 글자만 흰색, 그라데이션 QL 은 유지
DARK_LOGO_MAXIMUM_BRIGHTNESS = 120
DARK_LOGO_MAXIMUM_SATURATION_SPREAD = 70

# 시작 화면 로고 폭 (iOS pt = Android dp, 화면 가운데 고정 크기)
LAUNCH_LOGO_WIDTH_POINTS = 168
IOS_LAUNCH_IMAGE_DIRECTORY = "app/ios/Runner/Assets.xcassets/LaunchImage.imageset"
IOS_SCALE_SUFFIXES = {1: "", 2: "@2x", 3: "@3x"}
# Android 밀도 폴더 > 배율 (mdpi 기준 1)
ANDROID_DENSITY_SCALES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
ANDROID_RESOURCE_DIRECTORY = "app/android/app/src/main/res"
ANDROID_LAUNCH_LOGO_FILE_NAME = "launch_logo.png"

# OG 이미지 (SNS 공유 미리보기 표준 1200x630), 로고 폭은 캔버스의 60%
OPEN_GRAPH_SIZE_PIXELS = (1200, 630)
OPEN_GRAPH_LOGO_WIDTH_RATIO = 0.6

WEB_FAVICON_SIZE_PIXELS = 64
# 웹 앱 아이콘 (앱 다운로드 배너): 표시 48px(w-12) x 3배 (#531)
WEB_APP_ICON_SIZE_PIXELS = 144

# 웹 로고 높이: 최대 표시 높이 40px(h-10) x 3배(고밀도 화면), 원본 1336px 폭 그대로 내려보내지 않음 (#497)
WEB_LOGO_HEIGHT_PIXELS = 120
SERVER_FAVICON_SIZES_PIXELS = [(16, 16), (32, 32), (48, 48)]

# 픽셀 비교 허용 오차 (Pillow 버전 간 리샘플링 반올림 차이)
PIXEL_TOLERANCE_PER_CHANNEL = 2


@dataclass
class BrandAssetCopy:
    """플랫폼 사본 1개: 레포 기준 경로 + 만드는 방법 (원본 그대로 복사 또는 이미지·텍스트 생성)"""

    relative_path: str
    copied_from: Optional[Path] = None
    build_image: Optional[Callable[[], Image.Image]] = None
    image_format: str = "PNG"
    build_text: Optional[Callable[[], str]] = None


# ---------- 이미지 생성 ----------

def load_logo_horizontal() -> Image.Image:
    return Image.open(SOURCE_LOGO_HORIZONTAL).convert("RGBA")


def build_dark_logo() -> Image.Image:
    return build_dark_logo_once().copy()


@functools.lru_cache(maxsize=1)
def build_dark_logo_once() -> Image.Image:
    """라이트 로고 > 다크 로고 (어두운 무채색 불투명 픽셀 > 흰색, 알파 유지)"""
    dark_logo = load_logo_horizontal()
    pixels = dark_logo.load()
    width, height = dark_logo.size
    for y in range(height):
        for x in range(width):
            red, green, blue, alpha = pixels[x, y]
            if alpha == 0:
                continue
            brightest_channel = max(red, green, blue)
            saturation_spread = brightest_channel - min(red, green, blue)
            if (brightest_channel < DARK_LOGO_MAXIMUM_BRIGHTNESS
                    and saturation_spread < DARK_LOGO_MAXIMUM_SATURATION_SPREAD):
                pixels[x, y] = (255, 255, 255, alpha)
    return dark_logo


def resize_to_width(image: Image.Image, target_width_pixels: int) -> Image.Image:
    """비율 유지 축소 (높이 반올림, LANCZOS)"""
    target_height_pixels = round(image.height * target_width_pixels / image.width)
    return image.resize((target_width_pixels, target_height_pixels), Image.Resampling.LANCZOS)


def resize_to_height(image: Image.Image, target_height_pixels: int) -> Image.Image:
    """비율 유지 축소 (폭 반올림, LANCZOS)"""
    target_width_pixels = round(image.width * target_height_pixels / image.height)
    return image.resize((target_width_pixels, target_height_pixels), Image.Resampling.LANCZOS)


def build_open_graph_image() -> Image.Image:
    """밝은 배경 1200x630 가운데 가로 로고"""
    background_color = load_brand_colors()["openGraphBackground"]
    canvas = Image.new("RGB", OPEN_GRAPH_SIZE_PIXELS, background_color)
    logo = resize_to_width(load_logo_horizontal(), round(OPEN_GRAPH_SIZE_PIXELS[0] * OPEN_GRAPH_LOGO_WIDTH_RATIO))
    left = (canvas.width - logo.width) // 2
    top = (canvas.height - logo.height) // 2
    canvas.paste(logo, (left, top), logo)
    return canvas


def build_square_icon(size_pixels: int) -> Image.Image:
    return Image.open(SOURCE_APP_ICON).convert("RGB").resize((size_pixels, size_pixels), Image.Resampling.LANCZOS)


def build_largest_server_favicon() -> Image.Image:
    # ICO 저장 시 이 이미지에서 SERVER_FAVICON_SIZES_PIXELS 크기들을 함께 축소해 담음
    return build_square_icon(max(width for width, _ in SERVER_FAVICON_SIZES_PIXELS))


def build_ios_launch_image_contents_json() -> str:
    """LaunchImage.imageset Contents.json (라이트 3장 + luminosity dark 3장)"""
    images = []
    for file_prefix, is_dark in (("LaunchImage", False), ("LaunchImageDark", True)):
        for scale, suffix in IOS_SCALE_SUFFIXES.items():
            entry = {"idiom": "universal", "filename": f"{file_prefix}{suffix}.png", "scale": f"{scale}x"}
            if is_dark:
                entry["appearances"] = [{"appearance": "luminosity", "value": "dark"}]
            images.append(entry)
    return json.dumps({"images": images, "info": {"version": 1, "author": "xcode"}}, indent=2) + "\n"


# ---------- 사본 목록 ----------

def list_brand_asset_copies() -> list[BrandAssetCopy]:
    """원본 > 사본 전체 목록 (이 목록이 곧 사본 위치 문서)"""
    copies = [
        # 원본 그대로 복사 (앱 로고·아이콘, 관리자 로고)
        BrandAssetCopy("app/assets/logo.png", copied_from=SOURCE_LOGO_HORIZONTAL),
        # 웹 로고: 번들 크기 절감용 축소본
        BrandAssetCopy("client/src/assets/logo/logo.png",
                       build_image=lambda: resize_to_height(load_logo_horizontal(), WEB_LOGO_HEIGHT_PIXELS)),
        BrandAssetCopy("server/PQL-Web/src/main/resources/static/images/logo.png", copied_from=SOURCE_LOGO_HORIZONTAL),
        BrandAssetCopy("app/assets/app_icon_1024.png", copied_from=SOURCE_APP_ICON),
        BrandAssetCopy("app/assets/app_icon_foreground.png", copied_from=SOURCE_APP_ICON_ADAPTIVE_FOREGROUND),
        # 다크 로고 (앱, 관리자 다크 테마용)
        BrandAssetCopy("app/assets/logo_dark.png", build_image=build_dark_logo),
        BrandAssetCopy("server/PQL-Web/src/main/resources/static/images/logo_dark.png", build_image=build_dark_logo),
        # 웹 OG·파비콘, 관리자 파비콘
        BrandAssetCopy("client/public/og-image.png", build_image=build_open_graph_image),
        BrandAssetCopy("client/public/favicon.png", build_image=lambda: build_square_icon(WEB_FAVICON_SIZE_PIXELS)),
        BrandAssetCopy("client/src/assets/logo/app_icon.png", build_image=lambda: build_square_icon(WEB_APP_ICON_SIZE_PIXELS)),
        BrandAssetCopy("server/PQL-Web/src/main/resources/static/favicon.ico",
                       build_image=build_largest_server_favicon, image_format="ICO"),
        BrandAssetCopy(f"{IOS_LAUNCH_IMAGE_DIRECTORY}/Contents.json", build_text=build_ios_launch_image_contents_json),
    ]

    # iOS 시작 화면 로고 (라이트·다크 x 1·2·3배)
    for scale, suffix in IOS_SCALE_SUFFIXES.items():
        width_pixels = LAUNCH_LOGO_WIDTH_POINTS * scale
        copies.append(BrandAssetCopy(f"{IOS_LAUNCH_IMAGE_DIRECTORY}/LaunchImage{suffix}.png",
                                     build_image=lambda w=width_pixels: resize_to_width(load_logo_horizontal(), w)))
        copies.append(BrandAssetCopy(f"{IOS_LAUNCH_IMAGE_DIRECTORY}/LaunchImageDark{suffix}.png",
                                     build_image=lambda w=width_pixels: resize_to_width(build_dark_logo(), w)))

    # Android 시작 화면 로고 (drawable-{밀도} 라이트, drawable-night-{밀도} 다크)
    for density, scale in ANDROID_DENSITY_SCALES.items():
        width_pixels = round(LAUNCH_LOGO_WIDTH_POINTS * scale)
        copies.append(BrandAssetCopy(f"{ANDROID_RESOURCE_DIRECTORY}/drawable-{density}/{ANDROID_LAUNCH_LOGO_FILE_NAME}",
                                     build_image=lambda w=width_pixels: resize_to_width(load_logo_horizontal(), w)))
        copies.append(BrandAssetCopy(f"{ANDROID_RESOURCE_DIRECTORY}/drawable-night-{density}/{ANDROID_LAUNCH_LOGO_FILE_NAME}",
                                     build_image=lambda w=width_pixels: resize_to_width(build_dark_logo(), w)))
    return copies


# ---------- 쓰기·비교 ----------

def write_brand_asset_copy(asset_copy: BrandAssetCopy) -> None:
    target_path = REPOSITORY_ROOT / asset_copy.relative_path
    target_path.parent.mkdir(parents=True, exist_ok=True)
    if asset_copy.copied_from is not None:
        shutil.copyfile(asset_copy.copied_from, target_path)
    elif asset_copy.build_text is not None:
        target_path.write_text(asset_copy.build_text(), encoding="utf-8")
    elif asset_copy.image_format == "ICO":
        asset_copy.build_image().save(target_path, format="ICO", sizes=SERVER_FAVICON_SIZES_PIXELS)
    else:
        asset_copy.build_image().save(target_path, format="PNG", optimize=True)


def build_expected_image(asset_copy: BrandAssetCopy) -> Image.Image:
    if asset_copy.copied_from is not None:
        return Image.open(asset_copy.copied_from)
    if asset_copy.image_format == "ICO":
        # 저장 후 다시 읽어 실제 파일과 같은 조건(가장 큰 크기 프레임)으로 비교
        buffer = io.BytesIO()
        asset_copy.build_image().save(buffer, format="ICO", sizes=SERVER_FAVICON_SIZES_PIXELS)
        buffer.seek(0)
        return Image.open(buffer)
    return asset_copy.build_image()


def is_pixel_identical(expected_image: Image.Image, actual_image: Image.Image) -> bool:
    """크기 + RGBA 픽셀 비교 (PNG 재인코딩 차이 무시, 채널당 허용 오차 내)"""
    if expected_image.size != actual_image.size:
        return False
    channel_differences = ImageChops.difference(expected_image.convert("RGBA"), actual_image.convert("RGBA"))
    return all(largest <= PIXEL_TOLERANCE_PER_CHANNEL for _, largest in channel_differences.getextrema())


def describe_copy_difference(asset_copy: BrandAssetCopy) -> Optional[str]:
    """사본 1개 비교 > 다르면 사유, 같으면 None"""
    target_path = REPOSITORY_ROOT / asset_copy.relative_path
    if not target_path.exists():
        return "missing"
    if asset_copy.build_text is not None:
        is_same = json.loads(target_path.read_text(encoding="utf-8")) == json.loads(asset_copy.build_text())
        return None if is_same else "content differs"
    if not is_pixel_identical(build_expected_image(asset_copy), Image.open(target_path)):
        return "pixels differ"
    return None


def run_check_mode() -> int:
    differences = []
    for asset_copy in list_brand_asset_copies():
        reason = describe_copy_difference(asset_copy)
        if reason is not None:
            differences.append(f"{asset_copy.relative_path}: {reason}")
    differences.extend(find_brand_color_mismatches())

    if differences:
        print("[brand assets] out of date copies (run: python3 brand/generate_brand_assets_for_all_platforms.py)")
        for difference in differences:
            print(f"  - {difference}")
        return 1
    print(f"[brand assets] all {len(list_brand_asset_copies())} copies match brand/ sources")
    return 0


def run_generate_mode() -> int:
    # 내용이 같은 사본은 다시 쓰지 않음 (PNG 재인코딩만으로 생기는 git 변경 방지)
    for asset_copy in list_brand_asset_copies():
        if describe_copy_difference(asset_copy) is None:
            continue
        write_brand_asset_copy(asset_copy)
        print(f"[brand assets] wrote {asset_copy.relative_path}")
    # 색은 각 플랫폼 파일이 원본이 아니라 검사 대상 (자동 수정 안 함)
    color_mismatches = find_brand_color_mismatches()
    for mismatch in color_mismatches:
        print(f"[brand assets] color mismatch : {mismatch}")
    return 1 if color_mismatches else 0


def main() -> int:
    parser = argparse.ArgumentParser(description="brand/ 원본으로 플랫폼별 브랜드 사본 생성")
    parser.add_argument("--check", action="store_true", help="생성하지 않고 현재 사본이 원본과 같은지만 검사")
    arguments = parser.parse_args()
    return run_check_mode() if arguments.check else run_generate_mode()


if __name__ == "__main__":
    sys.exit(main())
