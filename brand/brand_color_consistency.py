"""
brand-colors.json <-> 플랫폼 색 정의 일치 검사 (읽기 전용, 자동 수정 안 함)
대상 5개: Android splash 라이트·다크, Android 아이콘 배경, pubspec 아이콘 배경, iOS LaunchBackground
"""

import json
import re
from pathlib import Path

BRAND_DIRECTORY = Path(__file__).resolve().parent
REPOSITORY_ROOT = BRAND_DIRECTORY.parent
SOURCE_BRAND_COLORS = BRAND_DIRECTORY / "brand-colors.json"


def load_brand_colors() -> dict:
    return json.loads(SOURCE_BRAND_COLORS.read_text(encoding="utf-8"))


def find_brand_color_mismatches() -> list[str]:
    """brand-colors.json <-> 플랫폼 색 정의 비교 (Android colors.xml, iOS colorset, pubspec 아이콘 배경)"""
    brand_colors = load_brand_colors()
    expected_colors_by_location = {
        ("app/android/app/src/main/res/values/colors.xml", "splash_background"): brand_colors["splashBackground"]["light"],
        ("app/android/app/src/main/res/values-night/colors.xml", "splash_background"): brand_colors["splashBackground"]["dark"],
        ("app/android/app/src/main/res/values/colors.xml", "ic_launcher_background"): brand_colors["appIconBackground"],
    }
    mismatches = []

    # Android colors.xml
    for (relative_path, color_name), expected_color in expected_colors_by_location.items():
        content = (REPOSITORY_ROOT / relative_path).read_text(encoding="utf-8")
        match = re.search(rf'<color name="{color_name}">(#[0-9A-Fa-f]{{6}})</color>', content)
        actual_color = match.group(1) if match else None
        if actual_color is None or actual_color.upper() != expected_color.upper():
            mismatches.append(f"{relative_path} {color_name}: {actual_color} (expected {expected_color})")

    # pubspec 적응형 아이콘 배경
    pubspec = (REPOSITORY_ROOT / "app/pubspec.yaml").read_text(encoding="utf-8")
    match = re.search(r'adaptive_icon_background:\s*"(#[0-9A-Fa-f]{6})"', pubspec)
    actual_color = match.group(1) if match else None
    if actual_color is None or actual_color.upper() != brand_colors["appIconBackground"].upper():
        mismatches.append(f"app/pubspec.yaml adaptive_icon_background: {actual_color} "
                          f"(expected {brand_colors['appIconBackground']})")

    # iOS LaunchBackground colorset (1번째 라이트, 2번째 다크)
    colorset_path = "app/ios/Runner/Assets.xcassets/LaunchBackground.colorset/Contents.json"
    colorset = json.loads((REPOSITORY_ROOT / colorset_path).read_text(encoding="utf-8"))
    for color_entry in colorset["colors"]:
        is_dark = any(appearance.get("value") == "dark" for appearance in color_entry.get("appearances", []))
        expected_color = brand_colors["splashBackground"]["dark" if is_dark else "light"]
        components = color_entry["color"]["components"]
        actual_color = "#" + "".join(f"{round(float(components[channel]) * 255):02X}"
                                     for channel in ("red", "green", "blue"))
        if actual_color != expected_color.upper():
            mismatches.append(f"{colorset_path} {'dark' if is_dark else 'light'}: {actual_color} (expected {expected_color})")
    return mismatches
