"""render.py 계산 검사: python3 -I app/tool/store_art/test_render.py"""

import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from PIL import Image
from render import keyword_font_size, pair_crop_boxes

SCENES = HERE / "scenes.json"


def test_pair_crop_boxes():
    assert pair_crop_boxes(1320, 2868, 40) == ((0, 0, 1320, 2868), (1360, 0, 2680, 2868))
    assert pair_crop_boxes(2160, 3840, 128) == ((0, 0, 2160, 3840), (2288, 0, 4448, 3840))


def test_target_gaps():
    targets = json.loads(SCENES.read_text(encoding="utf-8"))["targets"]
    assert {name: t["gap"] for name, t in targets.items()} == {
        "ios-6.9": 40, "ios-6.5": 39, "ios-6.3": 37, "android-phone": 128}
    assert (targets["android-phone"]["width"], targets["android-phone"]["height"]) == (2160, 3840)


def test_keyword_fits_slide():
    # JetBrains Mono 글자 폭 0.6em: 슬라이드 안에 들어와야 안 잘림
    for keyword in ("DISTINCT", "ORDER BY", "HAVING", "COUNT", "BEGIN", "RANK"):
        for width in (1206, 1320, 2160):
            assert keyword_font_size(keyword, width) * 0.6 * len(keyword) <= width


def test_outputs_exist_with_exact_size():
    config = json.loads(SCENES.read_text(encoding="utf-8"))
    promo = HERE.parents[1] / "docs/store/promo"
    for name, target in config["targets"].items():
        for number in range(1, 9):
            with Image.open(promo / name / f"{number:02d}.png") as image:
                assert image.size == (target["width"], target["height"]), (name, number, image.size)
                # 스토어는 알파 없는 이미지를 요구
                assert image.mode == "RGB", (name, number, image.mode)
    with Image.open(promo / "feature-graphic.png") as image:
        assert image.size == (1024, 500)
        assert image.mode == "RGB"


def test_root_readme_shows_all_scenes():
    # 이미지만 바뀌고 표가 그대로면 설명이 어긋난다
    readme = (HERE.parents[2] / "README.md").read_text(encoding="utf-8")
    for number, alt in enumerate(("앱 하나로 SQLD", "직접 실행", "새 선택지", "AI 해설", "출제 경향", "내 실력", "개념", "함께 겨뤄요"), 1):
        assert f'ios-6.3/{number:02d}.png" width="150" alt="' in readme, number
        line = next(l for l in readme.splitlines() if f"ios-6.3/{number:02d}.png" in l)
        assert alt in line, (number, line)


if __name__ == "__main__":
    for name, test in sorted(globals().items()):
        if name.startswith("test_"):
            test()
            print(f"ok {name}")
