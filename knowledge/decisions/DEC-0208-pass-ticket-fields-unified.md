---
type: decision
id: DEC-0208
created: 2026-10-29
reviewed: null
topics: [design-system, billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0428-app-profile-tab-redesign]]", "[[ISS-0428-app-profile-tab-redesign-report]]"]
---

# DEC-0208: 프로필·정보 시트 탑승권 칸은 승객 · 남은 날 · 시험일, 떼는 칸 글자는 "사용 중"으로 통일하고 바코드 폭은 그 글자 폭에 맞춘다

## 문제 정의 (Context)
#750 뒤 프로필 탭의 프로 탑승권과 이용권 정보 시트의 탑승권이 서로 다른 칸을 썼고, 프로필에는 "이용권 ~까지" 칸이 따로 있었다 (PR #752).

## 결정 (Decision)
- 프로필 탭 프로 탑승권을 정보 시트와 같게: 정보 칸은 승객 · 남은 날 · 시험일, 떼는 칸 글자는 "사용 중".
- 프로필의 "이용권 ~까지" 칸은 뺀다 — PR #752: "겹치던 '이용권 ~까지' 칸 제거", 사용자 정리: 시험일과 겹쳐서.
- 떼는 칸 바코드 폭은 그 아래 글자 폭에 맞춘다 ("사용 중"과 양끝이 맞음).

## 검토한 대안 (Alternatives)
- "이용권 ~까지" 칸 유지: 시험일과 겹쳐 뺐다 (사용자 정리). 그 밖의 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 세 곳(프로필·구매 시트·정보 시트) 탑승권이 같은 칸과 글자를 쓴다.

**부정**
- PR #752 테스트 메모: 프로필 탭 "사용 중" 글자는 접힌 상태로 시작해 화면으로 확인하지 못했다.

## 영향 범위 (Scope)
앱 `widgets/profile/profile_pass_slot.dart`, `widgets/pro/pro_info_sheet.dart`, `design/components/passql_pass_ticket.dart`.

## 출처 (References)
- PR #752 본문 (2026-10-29 07:30 main 머지), GitHub #749 리포트 댓글 6490566222 「변경 사항 1·2」「리뷰 반영」
- 사용자 정리 (2026-10-29 대화, "#752에서 정한 것")
- [[ISS-0428-app-profile-tab-redesign-report]]
