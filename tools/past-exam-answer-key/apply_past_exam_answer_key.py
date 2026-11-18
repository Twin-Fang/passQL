"""지난 회차 가답안 운영 반영·롤백 (로컬 전용, 기본은 점검만, --execute 일 때만 운영에 씀) (#1151)

반영 순서(회차마다): 백업 > 회차 생성 > 문항 50개 입력 > 회차 상태 OFFICIAL (앱 가채점 진입이 열림)
롤백(--rollback <백업 폴더>): 이 스크립트가 만든 회차를 상태 CLOSED 로 바꾸고 문항 입력을 지움 (앱 진입 사라짐, 회차 행은 남음)
관리자 로그인: ~/.projectops/config/config.json 의 passql-admin 계정, 변경 요청은 CSRF 헤더 필수 (값은 출력하지 않음)

사용
  점검: python3 -I apply_past_exam_answer_key.py --payload-dir <폴더>
  반영: python3 -I apply_past_exam_answer_key.py --payload-dir <폴더> --backup-dir <새 빈 폴더> --execute
  롤백: python3 -I apply_past_exam_answer_key.py --rollback <백업 폴더> --execute
"""
import argparse
import json
import os
import re
import sys
from pathlib import Path

import requests

BASE_URL = "https://api.passql.suhsaechan.kr"
QUESTION_COUNT = 50
# 롤백으로 문항 입력을 지우는 본문 ("" 와 0 은 지움)
CLEAR_ITEM = {"conceptTitle": "", "conceptTags": "", "topicCode": "", "operatorAnswer": 0,
              "operatorAnswerStatus": "UNKNOWN", "alternativeAnswers": "", "note": ""}


def login_admin_session() -> requests.Session:
    """관리자 폼 로그인 > 세션 (계정 값은 출력하지 않음)"""
    config = json.load(open(os.path.expanduser("~/.projectops/config/config.json")))

    def find_credential(node):
        if isinstance(node, dict):
            if isinstance(node.get("passql-admin"), dict) and "account" in node["passql-admin"]:
                return node["passql-admin"]
            for child in node.values():
                found = find_credential(child)
                if found:
                    return found
        return None

    credential = find_credential(config)
    if not credential:
        sys.exit("passql-admin 계정 설정이 없음")
    session = requests.Session()
    login_page = session.get(BASE_URL + "/admin/login").text
    form = {"username": credential["account"], "password": credential["password"]}
    token_match = re.search(r'name="_csrf"\s+value="([^"]+)"', login_page)
    if token_match:
        form["_csrf"] = token_match.group(1)
    response = session.post(BASE_URL + "/admin/login", data=form, allow_redirects=True)
    if "/admin/login" in response.url:
        sys.exit("관리자 로그인 실패")
    return session


def read_csrf_headers(session: requests.Session) -> dict:
    """관리자 화면 meta 에서 CSRF 헤더 이름·값 (변경 요청마다 새로 읽음)"""
    page = session.get(BASE_URL + "/admin/exam-answers").text
    header_name = re.search(r'name="_csrf_header"\s+content="([^"]+)"', page)
    token_value = re.search(r'name="_csrf"\s+content="([^"]+)"', page)
    if not header_name or not token_value:
        sys.exit("CSRF meta 를 못 찾음 (세션 만료 가능)")
    return {header_name.group(1): token_value.group(1)}


def send_json(session, method, path, body):
    response = session.request(method, BASE_URL + path, json=body, headers=read_csrf_headers(session))
    if not response.ok:
        sys.exit(f"{method} {path} 실패 {response.status_code}: {response.text[:200]}")
    return response.json() if response.text else None


def apply_rounds(payload_dir: Path, backup_dir: Path, is_execute: bool) -> None:
    create_files = sorted(payload_dir.glob("round-*.create.json"))
    print(f"대상 회차 {len(create_files)}개: {[f.name for f in create_files]}")
    if not is_execute:
        print("점검만 했음 (--execute 없으면 운영에 쓰지 않음)")
        return
    backup_dir.mkdir(parents=True, exist_ok=True)
    session = login_admin_session()
    # 백업: 반영 전 회차 목록 전체 (이미 있는 회차 확인용)
    existing_rounds = session.get(BASE_URL + "/admin/exam-answers", headers={"Accept": "application/json"})
    (backup_dir / "before-rounds.html").write_text(existing_rounds.text, encoding="utf-8")

    created_rounds = []
    for create_file in create_files:
        create_body = json.loads(create_file.read_text(encoding="utf-8"))
        item_body = json.loads(create_file.with_name(create_file.name.replace(".create.", ".items.")).read_text(encoding="utf-8"))
        created = send_json(session, "POST", "/admin/exam-answers", create_body)
        round_uuid = created["roundUuid"]
        created_rounds.append({"roundNumber": create_body["roundNumber"], "roundUuid": round_uuid,
                              "title": create_body["title"], "examDate": create_body["examDate"],
                              "notice": create_body["notice"]})
        # 만든 회차 기록을 바로 저장 (중간에 실패해도 롤백 가능)
        (backup_dir / "created-rounds.json").write_text(json.dumps(created_rounds, ensure_ascii=False, indent=2), encoding="utf-8")
        send_json(session, "PUT", f"/admin/exam-answers/{round_uuid}/items", item_body)
        send_json(session, "PUT", f"/admin/exam-answers/{round_uuid}",
                  {"title": create_body["title"], "examDate": create_body["examDate"],
                   "status": "OFFICIAL", "notice": create_body["notice"]})
        print(f"[반영] {create_body['roundNumber']}회 {round_uuid}")


def rollback_rounds(backup_dir: Path, is_execute: bool) -> None:
    created_rounds = json.loads((backup_dir / "created-rounds.json").read_text(encoding="utf-8"))
    print(f"롤백 대상 {len(created_rounds)}개 회차")
    if not is_execute:
        print("점검만 했음")
        return
    session = login_admin_session()
    for created in created_rounds:
        round_uuid = created["roundUuid"]
        send_json(session, "PUT", f"/admin/exam-answers/{round_uuid}",
                  {"title": created["title"], "examDate": created["examDate"],
                   "status": "CLOSED", "notice": created["notice"]})
        send_json(session, "PUT", f"/admin/exam-answers/{round_uuid}/items",
                  [{"questionNo": number, **CLEAR_ITEM} for number in range(1, QUESTION_COUNT + 1)])
        print(f"[롤백] {created['roundNumber']}회 CLOSED + 문항 비움")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--payload-dir")
    parser.add_argument("--backup-dir")
    parser.add_argument("--rollback")
    parser.add_argument("--execute", action="store_true")
    arguments = parser.parse_args()
    if arguments.rollback:
        rollback_rounds(Path(arguments.rollback), arguments.execute)
    elif arguments.payload_dir:
        if arguments.execute and not arguments.backup_dir:
            sys.exit("--execute 에는 --backup-dir 가 필요함")
        apply_rounds(Path(arguments.payload_dir), Path(arguments.backup_dir or "."), arguments.execute)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
