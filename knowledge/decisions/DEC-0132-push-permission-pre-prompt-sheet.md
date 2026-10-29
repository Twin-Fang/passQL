---
type: decision
id: DEC-0132
created: 2026-10-16
reviewed: null
topics: [notification, store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0297-notification-inbox-badge]]", "[[DEC-0131-member-notification-inbox-single-entry]]"]
---

# DEC-0132: 알림 권한은 앱 안내 시트 뒤 "알림 받기"를 눌렀을 때만 시스템 창으로 요청, "나중에"는 7일간 다시 묻지 않음

## 문제 정의 (Context)
알림함(GitHub #491)을 도입하면서 알림 권한을 언제 어떻게 물을지 정했다. 설계안 댓글은 이 흐름을 "App Store 심사 기준"으로 적었다.

## 결정 (Decision)
- 첫 실행·로그인 직후 시스템 창을 바로 띄우지 않고, 홈 첫 진입 또는 알림 켜기 선택 시 앱 자체 안내 시트(무엇을 받는지, 나중에 버튼)를 먼저 보여 준다.
- "알림 받기"를 눌렀을 때만 시스템 권한 창. "나중에"는 7일 뒤 다시.
- 거부해도 모든 기능을 쓸 수 있고 알림함은 그대로 동작한다. 설정에서 켜기는 기기 설정으로 안내.
- 이번 범위는 서비스 알림만(마케팅 푸시는 별도 동의가 필요해 제외).

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 권한 거부가 기능 사용을 막지 않는다.

**부정**
- 시뮬레이터에서는 알림 권한을 허용하지 못해 앱 아이콘 숫자·푸시 수신은 실기기 확인이 필요하다.

## 영향 범위 (Scope)
앱 알림 권한 안내 시트, 푸시 토큰 등록 시점, 설정 화면 알림 켜기.

## 출처 (References)
- GitHub #491 설계안 댓글 "알림 권한 흐름 (App Store 심사 기준)", 구현 보고서 댓글(2026-10-16)
- [[ISS-0297-notification-inbox-badge]]
