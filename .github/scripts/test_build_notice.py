#!/usr/bin/env python3
"""
테스트 빌드 결과 댓글의 안내 문구: 버전 조정 사유 + 오래된 브랜치 경고 (#731)
Android·iOS 테스트 빌드 워크플로가 같이 쓴다 > 두 댓글의 안내가 어긋나지 않게

  - 입력: 환경변수 VERSION_CHANGED(true/false), VERSION_REASON / 인자 --base-branch (레포 기본 브랜치, 워크플로가 전달)
  - 출력: GITHUB_OUTPUT 의 notice (여러 줄, 없으면 빈 값)
  - 기준 브랜치 version.yml 을 못 읽으면 경고만 생략 (빌드는 막지 않음)

사용 예:
  VERSION_CHANGED=true VERSION_REASON="..." python3 test_build_notice.py --base-branch main
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
import uuid
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ios_release import parse_version  # noqa: E402

VERSION_FILE = "version.yml"
# version.yml: version: "1.67.2" (따옴표 선택)
_VERSION_LINE = re.compile(r'^version:\s*"?([^"\s]+)"?', re.M)


def read_version(text: str) -> str | None:
    """version.yml 본문 > version 값"""
    m = _VERSION_LINE.search(text)
    return m.group(1) if m else None


def read_base_version(base_branch: str) -> str | None:
    """origin/{기준 브랜치}의 version.yml 값 (조회 실패 시 None)"""
    try:
        text = subprocess.run(["git", "show", f"origin/{base_branch}:{VERSION_FILE}"],
                              capture_output=True, text=True, check=True).stdout
    except (OSError, subprocess.CalledProcessError):
        return None
    return read_version(text)


def is_stale_branch(branch_tuple, base_tuple, is_version_changed: bool) -> bool:
    """오래된 브랜치 판정: 기준보다 낮고 (이미 출시된 버전 또는 major·minor 뒤처짐)
    기본 브랜치 머지마다 패치가 올라 패치만 뒤처진 브랜치는 제외 (경고 남발 방지)"""
    if not (branch_tuple and base_tuple) or branch_tuple >= base_tuple:
        return False
    return is_version_changed or branch_tuple[:2] < base_tuple[:2]


def build_notice_lines(branch_version: str | None, base_version: str | None, base_branch: str,
                       is_version_changed: bool, version_reason: str) -> list[str]:
    """안내 문구 목록: 버전 조정 사유 > 오래된 브랜치 경고"""
    lines = []
    if is_version_changed and version_reason:
        lines.append(f"ℹ️ 버전 조정: {version_reason}")
    if is_stale_branch(parse_version(branch_version), parse_version(base_version), is_version_changed):
        lines.append(f"⚠️ 이 브랜치의 version.yml({branch_version})이 {base_branch}({base_version})보다 낮습니다. "
                     f"`git merge origin/{base_branch}` 후 다시 빌드하면 최신 코드·버전으로 맞춰집니다.")
    return lines


def write_multiline_output(key: str, value: str) -> None:
    """GITHUB_OUTPUT 여러 줄 값 (heredoc 구분자)"""
    path = os.environ.get("GITHUB_OUTPUT")
    if not path:
        print(value)
        return
    delimiter = f"EOF_{uuid.uuid4().hex}"
    with open(path, "a", encoding="utf-8") as f:
        f.write(f"{key}<<{delimiter}\n{value}\n{delimiter}\n")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="테스트 빌드 댓글 안내 문구")
    parser.add_argument("--base-branch", required=True)
    args = parser.parse_args(argv)

    branch_version = read_version(Path(VERSION_FILE).read_text(encoding="utf-8"))
    base_version = read_base_version(args.base_branch)
    lines = build_notice_lines(
        branch_version, base_version, args.base_branch,
        os.environ.get("VERSION_CHANGED", "").lower() == "true",
        os.environ.get("VERSION_REASON", "").strip())
    write_multiline_output("notice", "\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
