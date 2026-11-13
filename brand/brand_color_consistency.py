"""
brand-colors.json <-> 플랫폼 색 정의 일치 검사 (읽기 전용, 자동 수정 안 함)
배경 5개(Android splash 라이트·다크, Android·pubspec 아이콘 배경, iOS LaunchBackground) + 강조색 사본 5곳(앱·웹·관리자·푸시)
"""

import json
import re
from pathlib import Path

BRAND_DIRECTORY = Path(__file__).resolve().parent
REPOSITORY_ROOT = BRAND_DIRECTORY.parent
SOURCE_BRAND_COLORS = BRAND_DIRECTORY / "brand-colors.json"

# 강조색 사본: (파일, 검사 범위 정규식 또는 None=파일 전체, 색 6자리를 잡는 정규식, accent 라이트·다크)
# 매치 1건 이상, 전부 같아야 함. 앱 토큰은 투명도 앞자리(0xAA)만 다른 accentTint·passGlow 도 같은 RGB
APP_COLOR_TOKEN_PATTERN = r"\b(?:accent|accentTint|passGlow): Color\(0x[0-9A-Fa-f]{2}([0-9A-Fa-f]{6})\)"
ACCENT_COLOR_COPIES = [
    ("app/lib/presentation/design/tokens/passql_colors.dart",
     r"static const light = PassqlColors\((.*?)\n  \);", APP_COLOR_TOKEN_PATTERN, "light"),
    ("app/lib/presentation/design/tokens/passql_colors.dart",
     r"static const dark = PassqlColors\((.*?)\n  \);", APP_COLOR_TOKEN_PATTERN, "dark"),
    ("client/src/styles/tokens.css", None, r"--color-brand:\s*#([0-9A-Fa-f]{6});", "light"),
    ("server/PQL-Domain-Member/src/main/java/com/passql/member/push/FirebasePushMessageSender.java",
     None, r'ANDROID_ACCENT_COLOR = "#([0-9A-Fa-f]{6})"', "light"),
    ("server/PQL-Web/src/main/resources/templates/admin/auto-notifications.html",
     None, r"(?:linear-gradient\(135deg, |bg-\[)#([0-9A-Fa-f]{6})", "light"),
]


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
    mismatches.extend(find_accent_color_mismatches(brand_colors))
    return mismatches


def find_accent_color_mismatches(brand_colors: dict) -> list[str]:
    """brand-colors.json accent <-> 강조색 사본 5곳 비교 (매치 0건도 위반: 형식이 바뀌어 검사가 빠지는 것 방지)"""
    mismatches = []
    for relative_path, scope_pattern, color_pattern, appearance in ACCENT_COLOR_COPIES:
        expected_color = brand_colors["accent"][appearance].upper()
        content = (REPOSITORY_ROOT / relative_path).read_text(encoding="utf-8")
        if scope_pattern is not None:
            scope_match = re.search(scope_pattern, content, re.DOTALL)
            content = scope_match.group(1) if scope_match else ""
        actual_colors = ["#" + color.upper() for color in re.findall(color_pattern, content)]
        if not actual_colors:
            mismatches.append(f"{relative_path} accent {appearance}: not found (expected {expected_color})")
        for actual_color in actual_colors:
            if actual_color != expected_color:
                mismatches.append(f"{relative_path} accent {appearance}: {actual_color} (expected {expected_color})")
    return mismatches
