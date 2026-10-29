---
type: decision
id: DEC-0209
created: 2026-10-29
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0428-app-profile-tab-redesign]]", "[[ISS-0428-app-profile-tab-redesign-report]]"]
---

# DEC-0209: 탑승권 정보 칸은 라벨만 12 → 11로 줄이고 값은 13을 유지한다

## 문제 정의 (Context)
PR #752에서 탑승권 정보 칸(승객·남은 날·시험일)의 글자 크기를 다시 정했다.

## 결정 (Decision)
- 라벨 12 → 11 (리포트: "값 13보다 한 단계 작게").
- 값은 13 유지.

## 검토한 대안 (Alternatives)
- 값까지 줄이기: 줄여 보니 너무 작아 보여 되돌렸다 (사용자 정리). GitHub 원본에는 "값 크기는 유지"만 적혀 있다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음

**부정**
- 논의 기록 없음

## 영향 범위 (Scope)
앱 `design/components/passql_pass_ticket.dart`.

## 출처 (References)
- PR #752 본문 (2026-10-29 07:30 main 머지), GitHub #749 리포트 댓글 6490566222 「변경 사항 1·2」「리뷰 반영」
- 사용자 정리 (2026-10-29 대화, "#752에서 정한 것")
- [[ISS-0428-app-profile-tab-redesign-report]]
