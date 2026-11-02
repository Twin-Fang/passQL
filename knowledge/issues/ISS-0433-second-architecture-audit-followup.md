---
type: issue
id: ISS-0433
created: 2026-10-31
topics: [dev-workflow]
symptoms: ["2차 아키텍처 감사", "Crashlytics 보고 누락", "reportIfUnexpectedFailure", "더 불러오기 320px 복사", "context.isDark 우회", "UUID 파싱 try/catch 복사", "No enum constant 응답 노출", "재시도 로그 스택트레이스 누락", "원인 예외 유실", "임의 px 소수", "NotificationCategory 손복사", "LLM 타임아웃 상수 중복"]
root_cause: "공통 지점(UuidUtils, PassqlThemeContext, crash_reporter, 생성 타입 등)이 이미 있는데도 쓰지 않고 따로 만든 사본이 4개 스택에 남아 있었고, 일부 catch가 사용자 문구로만 바꾸고 오류 보고를 하지 않았다"
status: resolved
resolution: "[[ISS-0433-second-architecture-audit-followup-report]]"
related: ["[[ISS-0433-second-architecture-audit-followup-report]]", "[[DEC-0223-audit-followup-small-fixes-split-design]]", "[[DEC-0224-attach-to-existing-common-points]]", "[[ISS-0434-audit-followup-split-large-files]]", "[[ISS-0317-architecture-audit-freeze-rules]]", "[[DEC-0145-frozen-architecture-rule-ledger]]", "[[DEC-0118-single-source-commonization-rules]]"]
source: "https://github.com/Twin-Fang/passQL/issues/759"
---

# ISS-0433: 2차 아키텍처 감사 후속 — 오류 보고 누락과 복사 로직 정리

GitHub #759 (원본: 이슈 본문과 리포트 댓글).

## 증상
2026-10-29 4개 스택 코드 구조 점검(GitHub #517 후속)에서 소스를 열어 확인한 문제. 동결 규칙 10개는 새 위반 없이 통과.
- 앱: 일부 catch가 사용자 문구로만 바꾸고 Crashlytics 보고를 하지 않아 unknown·5xx 오류가 기록되지 않음(`settings_page.dart`, `question_providers.dart`, `chapter_providers.dart`, `settings_providers.dart`, `sql_practice_providers.dart`, `feedback_page.dart`). "더 불러오기" 스크롤 판정(320px) 4곳 복사, `context.isDark`를 우회하는 다크 판정 8곳, 탑승권의 이름 없는 투명도 숫자.
- 서버: 선택지 생성 재시도 로그의 인자 순서 오류로 예외 스택이 남지 않음, 다시 던질 때 원인 예외 유실, 잘못된 필터 값이 enum 내부 이름(`No enum constant ...`)을 응답에 노출, UUID 파싱 try/catch 7곳 복사, 페이지 크기·네이버 토큰 주소·번들 ID 상수 중복, 설정값 형식 오류를 경고 없이 기본값으로 대체.
- 웹: 임의 px 금지 규칙이 소수(`10.5px`)를 못 잡음, 제출 후 캐시 갱신 묶음 4곳 복사, 생성 타입이 있는 `NotificationCategory` 손복사.
- AI 서버: 호출 타임아웃·로그 길이·5xx 기준 상수가 3곳에 각각 존재.

## 재현 조건
해당 없음 (코드 구조 점검).

## 조사 기록
- 2026-10-29: 스캐너 수치 수집 → 스택별 소스를 열어 오탐 제거 → 수정 규모로 분류(작음·동작 그대로 / 설계 필요 / 제품 결정 필요) → [[DEC-0223-audit-followup-small-fixes-split-design]].
- 2026-10-29: PR #761, 커밋 `8f91a85e`로 작은 수정 반영, 리포트 댓글로 완료 → [[ISS-0433-second-architecture-audit-followup-report]]. 설계 필요 항목은 GitHub #762로 분리 → [[ISS-0434-audit-followup-split-large-files]].
- 점검 보고서: `docs/architecture/audits/2026-10-29_passQL_2차_아키텍처_감사.md`.

## 근본 원인
기존 공통 지점을 쓰지 않은 사본과 오류 보고가 빠진 catch. 1차 감사(2026-10-18, [[ISS-0317-architecture-audit-freeze-rules]])의 큰 결함은 대부분 고쳐진 상태였다.
