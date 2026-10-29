---
type: completion-report
id: ISS-0406
created: 2026-10-27
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0406-delete-functional-tests-keep-contracts]]"
related: ["[[DEC-0183-keep-only-contract-architecture-tests]]"]
source: "https://github.com/Twin-Fang/passQL/issues/680"
---

# ISS-0406 완료 리포트: 4개 스택 기능 테스트 삭제

GitHub #680 리포트 댓글 기준 (PR #681).

## 해결 방법
| 스택 | 삭제 | 남긴 테스트 |
|---|---|---|
| 서버 | 135개 파일 | 아키텍처 규칙 2개, OpenAPI 계약 1개 (18개 케이스) |
| 앱 | 123개 파일 | `test/architecture/*`, 에러 코드 계약, API 계약 (47개 케이스) |
| 웹 | 34개 파일 | 디자인 규칙(8개 케이스), 아키텍처 규칙 |
| AI | 3개 파일 | 아키텍처 규칙, 계층 import 규칙, Spring API 계약 |

- 남는 테스트가 쓰는 도우미(앱 `fake_http_client_adapter.dart`, 웹 `setup.ts`, AI `conftest.py`와 계약 스냅샷)는 유지.
- 지운 테스트 경로가 든 허용 목록 `client-no-direct-web-storage.allow` 정리 (안 하면 규칙 테스트가 실패).

## 근본 원인 (확정)
원본에 적혀 있지 않다.

## 재발 방지
- 앞으로 새 기능은 잠금·채점처럼 틀리면 안 되는 핵심 판정만 최소한으로 테스트하고, 나머지는 실제 화면을 띄워 확인.
- 검증: 서버 18개, 앱 47개, 웹 vitest 8개와 아키텍처 테스트 통과, `flutter analyze`·`tsc` 이상 없음, PR CI(서버·앱·웹) 통과 후 머지.

## 교훈
(원본에 없음, 볼트 정리) 테스트 파일을 지울 때 규칙 테스트의 허용 목록에 남은 경로도 같이 정리해야 한다.
