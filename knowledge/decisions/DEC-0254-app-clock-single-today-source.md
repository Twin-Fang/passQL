---
type: decision
id: DEC-0254
created: 2026-11-05
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0454-dev-tools-situation-simulation]]"]
---

# DEC-0254: 앱의 "오늘" 판정은 AppClock 하나로 하고, 개발자 도구 흉내는 앱 표시만 바꾼다

## 문제 정의 (Context)
자정 초기화·하루 횟수 제한·D-day를 확인하려면 날짜를 기다려야 했다. 앱 곳곳이 `DateTime.now()`를 직접 읽어 한 곳에서 날짜를 바꿀 수 없었다 (GitHub #819).

## 결정 (Decision)
- 앱 "오늘"의 단일 원본은 `AppClock` (기기 시각 + 개발자 도구가 넘긴 일수). 홈, D-day, 히트맵, 광고 하루 노출 횟수, 이용권 문구가 이를 쓴다.
- 개발자 도구의 상황 흉내는 앱 표시·기기 기록만 바꾸고, 서버 데이터·서버 한도는 그대로 둔다. 흉내 상태는 메모리에만 둔다.
- 푸시 흉내는 시스템 알림 배너 없이 실제 알림 처리 경로에 흉내 메시지를 넣는다.

## 검토한 대안 (Alternatives)
- 로컬 알림 패키지로 시스템 배너 띄우기: 스토어 빌드에도 네이티브 코드가 들어가고 iOS에서 Firebase 알림 처리 지점과 겹칠 위험이 있어 버렸다.
- 서버 전환(운영 ↔ 로컬): 사용자 결정(2026-11-04)으로 하지 않는다.

## 결과 (Consequences)
**긍정**
- 날짜를 기다리지 않고 자정 이후 화면을 확인할 수 있다.

**부정**
- "오늘" 판정을 새로 만들 때 `DateTime.now()`를 쓰면 흉내가 적용되지 않는다.
- 서버 기준 값(하루 한도 등)은 흉내로 바뀌지 않는다.

## 영향 범위 (Scope)
`app/lib/core/utils/app_clock.dart`, 개발자 도구 탭들, `dev_situation_overrides.dart`, `dev_simulated_push_messaging_client.dart`.

## 출처 (References)
- GitHub #819 PR #846 (2026-11-05)
- 이슈: [[ISS-0454-dev-tools-situation-simulation]]
