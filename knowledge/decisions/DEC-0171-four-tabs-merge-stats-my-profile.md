---
type: decision
id: DEC-0171
created: 2026-10-24
reviewed: null
topics: [design-system, home, auth-member]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0363-app-wide-ui-ux-cleanup]]", "[[ISS-0363-app-wide-ui-ux-cleanup-report]]", "[[DEC-0167-five-tabs-with-text-labels]]", "[[ISS-0358-concept-learning-by-unit]]"]
---

# DEC-0171: 하단 탭을 홈 / 문제 / 토론 / 내 프로필 4개로 — 기록과 MY를 `내 프로필`로 합치고 설정은 톱니바퀴로 여는 push 화면

## 문제 정의 (Context)
전 화면 UI/UX 검수 중 하단 탭 구성을 정리했다 (GitHub #602, 2026-10-24 진행 댓글).

## 결정 (Decision)
- 하단 탭: 홈 / 문제 / 토론 / 내 프로필.
- `내 프로필`: 맨 위 이용권 카드(결제가 꺼져 있으면 자리째 없음) + 프로필(`ProfileSection`), 아래 기록 화면 전체. 제목줄 오른쪽 이용권 칩 + 톱니바퀴.
- 설정은 탭이 아니라 톱니바퀴로 여는 push 화면(뒤로가기 있음). `AppRoutes.tabRoots`에서 설정 제외.
- 푸시·딥링크 `stats`는 그대로 내 프로필 탭으로.

## 검토한 대안 (Alternatives)
#602 원본에는 논의 기록 없음. 같은 날 GitHub #577 댓글(2026-10-24)에 사용자 결정이 있다: 개념 탭을 더하며 "6개 탭"을 정했다가 정정해 "하단 네비게이션 바를 더 늘리기 애매해 기록+MY를 합치고, 탭 이름은 `내 프로필`", 설정은 "MY에서 오른쪽 위에 톱니바퀴". 개념 탭은 전체 공개 전까지 숨기므로 #602 시점에 보이는 탭은 4개다. (같은 주 GitHub #574는 "탭을 4개로 합치는 안"을 "설정까지 세 번 탭해야 하고 경로 이전 위험"으로 택하지 않고 5탭을 유지했다 — [[DEC-0167-five-tabs-with-text-labels]]. #602 원본은 이 판단을 바꾼다고 명시하지 않았다.)

## 결과 (Consequences)
**긍정**
- 하단 탭 수를 늘리지 않고 개념 탭 자리를 만든다(GitHub #577 사용자 발언 기준).

**부정**
- 닉네임 랜덤 버튼 작업(GitHub #579)의 위치가 `ProfileSection`으로 바뀌었다(리포트 주의사항).

## 영향 범위 (Scope)
`app_routes.dart`, `app_router.dart`, `app_shell.dart`, `stats_page.dart`, `profile_section.dart`, `settings_page.dart`, 차단 안내 문구.

## 출처 (References)
- GitHub #602 진행 댓글·리포트 댓글(2026-10-24), PR #603
- GitHub #577 결정 댓글(2026-10-24 00:16, 00:17) — [[ISS-0358-concept-learning-by-unit]]
- 기존 볼트 결정과 어긋남: DEC-0088(마이페이지 탭을 따로 두지 않고 설정 탭을 마이페이지로 확장), DEC-0018(`홈 / 문제 / 통계 / 설정` 4탭). 원본은 이들을 대체한다고 명시하지 않았다.
- [[ISS-0363-app-wide-ui-ux-cleanup]]
