"""스냅샷 다시 쓰기: legacy/ 와 examples/ 명세 > 같은 이름 .svg (모양을 일부러 바꿨을 때만 실행)

사용: python3 tests/record_snapshots.py
"""
import sys
from pathlib import Path

GENERATOR_DIRECTORY = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(GENERATOR_DIRECTORY))
from figure_svg import load_spec, render_figure  # noqa: E402

# 스냅샷 폴더 2개: 기존 모양 고정(legacy), 새 유형 예시(examples)
SNAPSHOT_DIRECTORIES = [GENERATOR_DIRECTORY / "tests" / "legacy", GENERATOR_DIRECTORY / "examples"]
SPEC_SUFFIXES = (".json", ".mmd")


def find_spec_paths():
    return sorted(path for directory in SNAPSHOT_DIRECTORIES for path in directory.iterdir()
                  if path.suffix in SPEC_SUFFIXES)


if __name__ == "__main__":
    for spec_path in find_spec_paths():
        spec_path.with_suffix(".svg").write_text(render_figure(load_spec(spec_path)), encoding="utf-8")
        print("recorded", spec_path.with_suffix(".svg").name)
