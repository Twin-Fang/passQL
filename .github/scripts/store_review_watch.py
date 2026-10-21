#!/usr/bin/env python3
"""
스토어 심사 상태 감시 (#569): iOS 심사 상태 + Android 트랙 조회 > 이전 상태와 다르면 추적 이슈에 댓글
- android-status: Play Developer API 트랙 조회 (편집을 열어 읽기만 하고 버림)
- android-promote: alpha 최신 릴리스가 production 에 없으면 production 으로 승급 시도 (프로덕션 액세스 승인 전이면 거부되고 넘어감, #568)
- notify: 상태 요약 > 이슈 댓글의 숨김 표식(마지막 상태)과 비교 > 바뀐 경우만 댓글
"""
import argparse
import json
import os
import sys
import urllib.request

# 이슈 댓글에 마지막 상태를 숨겨 두는 표식
STATE_MARKER_PREFIX = "<!-- store-watch-state:"
STATE_MARKER_SUFFIX = " -->"
# 심사 결과로 보는 iOS 상태 (통과·거절)
IOS_APPROVED_STATES = {"PENDING_DEVELOPER_RELEASE", "READY_FOR_SALE", "READY_FOR_DISTRIBUTION"}
IOS_REJECTED_STATES = {"REJECTED", "METADATA_REJECTED", "INVALID_BINARY"}
GITHUB_API = "https://api.github.com"


def cmd_android_status(args: argparse.Namespace) -> int:
    """Play 트랙 목록 > {tracks: {이름: [버전·상태]}, hasProductionRelease}"""
    from google.auth.transport.requests import AuthorizedSession
    from google.oauth2 import service_account

    credentials = service_account.Credentials.from_service_account_file(
        args.key, scopes=["https://www.googleapis.com/auth/androidpublisher"])
    session = AuthorizedSession(credentials)
    base = f"https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{args.package}"
    edit_id = session.post(f"{base}/edits").json()["id"]
    try:
        tracks = session.get(f"{base}/edits/{edit_id}/tracks").json().get("tracks", [])
    finally:
        # 읽기만 하므로 편집은 저장하지 않고 버린다
        session.delete(f"{base}/edits/{edit_id}")
    summary = {
        track["track"]: [f"{release.get('name')}({release.get('status')})" for release in track.get("releases", [])]
        for track in tracks
    }
    # 승인 전에도 빈 production 트랙이 목록에 올 수 있어, 릴리스가 있어야 출시된 것으로 본다
    print(json.dumps({"tracks": summary, "hasProductionRelease": bool(summary.get("production"))}, ensure_ascii=False))
    return 0


def cmd_android_promote(args: argparse.Namespace) -> int:
    """alpha 최신 릴리스 > production 승급 (이미 있으면 그대로, 승인 전 FAILED_PRECONDITION 이면 대기)"""
    from google.auth.transport.requests import AuthorizedSession
    from google.oauth2 import service_account

    credentials = service_account.Credentials.from_service_account_file(
        args.key, scopes=["https://www.googleapis.com/auth/androidpublisher"])
    session = AuthorizedSession(credentials)
    base = f"https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{args.package}"
    edit_id = session.post(f"{base}/edits").json()["id"]
    try:
        tracks = {track["track"]: track for track in session.get(f"{base}/edits/{edit_id}/tracks").json().get("tracks", [])}
        alpha_releases = tracks.get("alpha", {}).get("releases", [])
        if not alpha_releases:
            print(json.dumps({"result": "no_alpha_release"}))
            return 0
        alpha_release = alpha_releases[0]
        production_codes = {code for release in tracks.get("production", {}).get("releases", [])
                            for code in release.get("versionCodes", [])}
        if set(alpha_release.get("versionCodes", [])) <= production_codes:
            print(json.dumps({"result": "already_promoted", "release": alpha_release.get("name")}))
            return 0

        # alpha 와 같은 빌드·출시 노트로 production 전체 출시 (Google 심사 후 공개)
        production_release = {key: alpha_release[key] for key in ("name", "versionCodes", "releaseNotes") if key in alpha_release}
        production_release["status"] = "completed"
        update = session.put(f"{base}/edits/{edit_id}/tracks/production",
                             json={"track": "production", "releases": [production_release]})
        if update.status_code == 400 and "FAILED_PRECONDITION" in update.text:
            print(json.dumps({"result": "access_pending", "release": alpha_release.get("name")}))
            return 0
        update.raise_for_status()
        commit = session.post(f"{base}/edits/{edit_id}:commit")
        commit.raise_for_status()
        edit_id = None
        print(json.dumps({"result": "promoted", "release": alpha_release.get("name")}, ensure_ascii=False))
        return 0
    finally:
        # 커밋하지 않은 편집은 버린다
        if edit_id:
            session.delete(f"{base}/edits/{edit_id}")


def _read_last_json_line(path: str) -> dict:
    """명령 출력 파일 > 마지막 JSON 줄 (없으면 빈 dict)"""
    if not path or not os.path.exists(path):
        return {}
    for line in reversed(open(path, encoding="utf-8").read().splitlines()):
        if line.strip().startswith("{"):
            try:
                return json.loads(line)
            except json.JSONDecodeError:
                continue
    return {}


def _to_state(ios_status: dict, android_status: dict) -> dict:
    """조회 결과 > 비교용 상태 (iOS 최신 열린 버전, Android 트랙)"""
    versions = ios_status.get("versions") or []
    latest = versions[0] if versions else {}
    return {
        "ios": f"{latest.get('version')} {latest.get('appStoreState')}" if latest else "조회 실패",
        "android": android_status.get("tracks") if android_status else "조회 실패",
        "androidProduction": android_status.get("hasProductionRelease") if android_status else None,
    }


def _to_headline(state: dict) -> str:
    """상태 > 한 줄 머리 (통과·거절이면 강조)"""
    ios_text = state["ios"]
    ios_code = ios_text.split(" ")[-1]
    if ios_code in IOS_APPROVED_STATES:
        return f"[통과] iOS 심사 통과: {ios_text}"
    if ios_code in IOS_REJECTED_STATES:
        return f"[거절] iOS 심사 거절: {ios_text}"
    if state.get("androidProduction"):
        return "[출시] Android 프로덕션 트랙에 릴리스 등록"
    return f"[변경] 스토어 상태 변경: iOS {ios_text}"


def _github(method: str, path: str, token: str, body: dict | None = None):
    request = urllib.request.Request(
        f"{GITHUB_API}{path}", method=method,
        data=json.dumps(body).encode() if body is not None else None,
        headers={"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json"})
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.loads(response.read() or b"null")


def _find_last_state(repository: str, issue: int, token: str) -> dict | None:
    """이슈 댓글(최근 100개) > 마지막 숨김 표식 상태"""
    comments = _github("GET", f"/repos/{repository}/issues/{issue}/comments?per_page=100", token)
    for comment in reversed(comments or []):
        body = comment.get("body") or ""
        start = body.find(STATE_MARKER_PREFIX)
        if start >= 0:
            end = body.find(STATE_MARKER_SUFFIX, start)
            try:
                return json.loads(body[start + len(STATE_MARKER_PREFIX):end])
            except json.JSONDecodeError:
                return None
    return None


def cmd_notify(args: argparse.Namespace) -> int:
    """상태 비교 > 바뀌었을 때만 추적 이슈에 댓글"""
    token = os.environ["GITHUB_TOKEN"]
    repository = os.environ["GITHUB_REPOSITORY"]
    state = _to_state(_read_last_json_line(args.ios), _read_last_json_line(args.android))
    last_state = _find_last_state(repository, args.issue, token)
    if last_state == state:
        print(f"[store watch] unchanged : {json.dumps(state, ensure_ascii=False)}")
        return 0

    android_lines = state["android"] if isinstance(state["android"], str) else "\n".join(
        f"  - {track}: {', '.join(releases) or '-'}" for track, releases in sorted(state["android"].items()))
    body = (f"### {_to_headline(state)}\n\n"
            f"- iOS(App Store): `{state['ios']}`\n"
            f"- Android(Play) 트랙:\n{android_lines}\n"
            f"- Android 프로덕션 릴리스: {'있음' if state['androidProduction'] else '없음 (프로덕션 액세스 승인 메일은 계정 소유자에게 옴, #568)'}\n\n"
            f"{STATE_MARKER_PREFIX}{json.dumps(state, ensure_ascii=False)}{STATE_MARKER_SUFFIX}")
    _github("POST", f"/repos/{repository}/issues/{args.issue}/comments", token, {"body": body})
    print(f"[store watch] changed : {json.dumps(last_state, ensure_ascii=False)} -> {json.dumps(state, ensure_ascii=False)}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    android = commands.add_parser("android-status")
    android.add_argument("--key", required=True)
    android.add_argument("--package", required=True)
    promote = commands.add_parser("android-promote")
    promote.add_argument("--key", required=True)
    promote.add_argument("--package", required=True)
    notify = commands.add_parser("notify")
    notify.add_argument("--ios", required=True)
    notify.add_argument("--android", required=True)
    notify.add_argument("--issue", type=int, required=True)
    args = parser.parse_args()
    handlers = {"android-status": cmd_android_status, "android-promote": cmd_android_promote, "notify": cmd_notify}
    return handlers[args.command](args)


if __name__ == "__main__":
    sys.exit(main())
