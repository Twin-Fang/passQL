"""스토어 홍보 이미지 생성: 원본 캡처 + scenes.json 문구 > 스토어 규격 PNG

    python3 -I app/tool/store_art/render.py            # 세로형 전 규격 + 그래픽 이미지
    python3 -I app/tool/store_art/render.py --only ios-6.9

- 원본 캡처: app/docs/store/promo/source (tool/store_shots 로 찍음)
- 결과: app/docs/store/promo/{규격}/{id}.png, app/docs/store/promo/feature-graphic.png
- Chrome 헤드리스로 정확한 픽셀 크기로 찍음. 글꼴은 앱의 Pretendard
"""

import argparse
import html
import json
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

APP_ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
SOURCE_DIR = APP_ROOT / "docs/store/promo/source"
OUT_DIR = APP_ROOT / "docs/store/promo"
FONT_DIR = APP_ROOT / "assets/fonts"
LOGO = APP_ROOT / "assets/app_icon_1024.png"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
# Play 그래픽 이미지 규격 (배지·가격 문구 넣지 않음)
FEATURE_GRAPHIC_SIZE = (1024, 500)


def read_aspect(shot: Path) -> float:
    """캡처 가로/세로 비율"""
    with Image.open(shot) as image:
        return image.width / image.height


def fill_template(template_name: str, values: dict) -> Path:
    """틀의 {{키}} 채움 > 임시 html 경로"""
    page_html = (HERE / template_name).read_text(encoding="utf-8")
    for key, value in values.items():
        page_html = page_html.replace("{{" + key + "}}", value)
    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False, encoding="utf-8") as page:
        page.write(page_html)
    return Path(page.name)


def capture_page(page: Path, width: int, height: int, out: Path) -> None:
    """Chrome 헤드리스로 정확한 픽셀 크기 캡처 > 크기 검증"""
    out.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
            "--force-device-scale-factor=1", f"--window-size={width},{height}",
            # 글꼴·이미지가 다 그려질 시간 (짧으면 기본 글꼴로 찍힘)
            "--virtual-time-budget=3000", "--allow-file-access-from-files",
            f"--screenshot={out}", page.as_uri(),
        ],
        check=True, capture_output=True,
    )
    with Image.open(out) as image:
        if image.size != (width, height):
            sys.exit(f"size mismatch: {out} {image.size}")
        # 스토어는 알파 없는 이미지를 요구 (App Store 업로드 거절 방지)
        image.convert("RGB").save(out)


def pair_crop_boxes(width: int, height: int, gap: int) -> tuple[tuple[int, int, int, int], tuple[int, int, int, int]]:
    """넓은 캔버스에서 좌우 장의 영역 (가운데 간격은 버림)"""
    return (0, 0, width, height), (width + gap, 0, width * 2 + gap, height)


def keyword_font_size(keyword: str, slide_width: int) -> int:
    """키워드가 폭을 채우는 글자 크기. JetBrains Mono 글자 폭은 0.6em, 시안 기준 사용 폭은 190 중 166"""
    return int(slide_width * 166 / 190 / (0.6 * len(keyword)))


def shot_offset(target: dict, align: str, aspect: float) -> int:
    """align=bottom 이면 캡처 아래쪽이 슬라이드 아래에 오도록 위로 미는 양(px). 비율은 template.html 의 폰 값과 같음"""
    if align != "bottom":
        return 0
    unit = target["width"] / 190
    screen_height = unit * 154 / aspect
    visible_height = target["height"] - unit * 156
    return max(0, int(screen_height - visible_height))


def render_pair(target_name: str, target: dict, scene: dict) -> list[Path]:
    """이어지는 두 장: 넓은 캔버스를 찍어 좌우로 잘라 저장"""
    width, height, gap = target["width"], target["height"], target["gap"]
    shot = SOURCE_DIR / scene["shot"]
    canvas_width = width * 2 + gap
    page = fill_template("pair_template.html", {
        "width": str(width), "height": str(height), "gap": str(gap), "canvas_width": str(canvas_width),
        "font_dir": FONT_DIR.as_uri(), "shot": shot.as_uri(), "shot_aspect": f"{read_aspect(shot):.6f}",
        "keyword": html.escape(scene["keyword"]),
        "headline_left": scene["headlines"][0], "headline_right": scene["headlines"][1],
    })
    wide = OUT_DIR / target_name / f"{scene['ids'][0]}_wide.png"
    capture_page(page, canvas_width, height, wide)
    outs = []
    with Image.open(wide) as image:
        for scene_id, box in zip(scene["ids"], pair_crop_boxes(width, height, gap)):
            out = OUT_DIR / target_name / f"{scene_id}.png"
            image.crop(box).save(out)
            outs.append(out)
    wide.unlink()
    return outs


def render_single(target_name: str, target: dict, scene: dict) -> list[Path]:
    """세로형 1장: 키워드·헤드라인 + 원본 캡처 > {규격}/{id}.png"""
    shot = SOURCE_DIR / scene["shot"]
    aspect = read_aspect(shot)
    # 문구는 scenes.json 의 신뢰된 값 — headline 은 <br> 그대로, 키워드는 이스케이프
    page = fill_template("template.html", {
        "width": str(target["width"]), "height": str(target["height"]),
        "font_dir": FONT_DIR.as_uri(), "shot": shot.as_uri(), "shot_aspect": f"{aspect:.6f}",
        "shot_offset": str(shot_offset(target, scene.get("align", "top"), aspect)),
        "keyword": html.escape(scene["keyword"]),
        "keyword_size": str(keyword_font_size(scene["keyword"], target["width"])),
        "headline": scene["headline"],
    })
    out = OUT_DIR / target_name / f"{scene['id']}.png"
    capture_page(page, target["width"], target["height"], out)
    return [out]


def render_scene(target_name: str, target: dict, scene: dict) -> list[Path]:
    """장면 종류에 맞는 렌더 > 만든 파일 목록"""
    if scene["kind"] == "pair":
        return render_pair(target_name, target, scene)
    return render_single(target_name, target, scene)


def render_feature_graphic(wide: dict) -> Path:
    """Play 그래픽 이미지: 로고·문구 + 휴대폰 2대 > feature-graphic.png"""
    width, height = FEATURE_GRAPHIC_SIZE
    page = fill_template("wide_template.html", {
        "width": str(width), "height": str(height), "font_dir": FONT_DIR.as_uri(),
        "logo": LOGO.as_uri(), "app_name": html.escape(wide["app_name"]),
        "headline": wide["headline"], "sub": html.escape(wide["sub"]),
        "shot_front": (SOURCE_DIR / wide["front"]).as_uri(),
        "shot_back": (SOURCE_DIR / wide["back"]).as_uri(),
        "shot_aspect": f"{read_aspect(SOURCE_DIR / wide['front']):.6f}",
    })
    out = OUT_DIR / "feature-graphic.png"
    capture_page(page, width, height, out)
    return out


def main() -> None:
    config = json.loads((HERE / "scenes.json").read_text(encoding="utf-8"))
    parser = argparse.ArgumentParser()
    parser.add_argument("--only", choices=[*config["targets"], "feature"], help="한 규격만 생성")
    args = parser.parse_args()

    # 세로형: 규격 x 장면
    for target_name, target in config["targets"].items():
        if args.only and args.only != target_name:
            continue
        for scene in config["scenes"]:
            for out in render_scene(target_name, target, scene):
                print(f"made {out.relative_to(APP_ROOT)}")
    # 가로형 그래픽 이미지
    if args.only in (None, "feature"):
        print(f"made {render_feature_graphic(config['wide']).relative_to(APP_ROOT)}")


if __name__ == "__main__":
    main()
