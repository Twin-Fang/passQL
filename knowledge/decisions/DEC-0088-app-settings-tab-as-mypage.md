---
type: decision
id: DEC-0088
created: 2026-10-02
reviewed: null
topics: [auth-member]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0174-app-wrong-notes-nickname-choice-mode]]", "[[ISS-0174-app-wrong-notes-nickname-choice-mode-report]]", "[[ISS-0175-app-feedback-write-and-history]]"]
---

# DEC-0088: 앱은 마이페이지 탭을 따로 두지 않고 설정 탭을 마이페이지 역할로 확장한다

## 문제 정의 (Context)
웹 마이페이지/설정의 오답 목록·닉네임 변경·선택지 생성 모드를 앱에 옮겨야 했다 (GitHub #329).

## 결정 (Decision)
"앱에 마이페이지 탭이 없어 설정 탭을 마이페이지 역할로 확장했다"(2026-10-02 구현 댓글). 오답 노트는 `/settings/wrong-notes`, 건의사항은 `/settings/feedback`(GitHub #330)처럼 설정 아래 화면으로 둔다.

## 검토한 대안 (Alternatives)
- 마이페이지 탭 신설: 고르지 않음. 이유는 "앱에 마이페이지 탭이 없어" 외에 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
Flutter 앱 설정 화면과 `/settings/*` 하위 화면(오답 노트, 건의사항, 닉네임, 선택지 생성 모드, 로그아웃·탈퇴).

## 출처 (References)
- GitHub #329 구현 댓글(2026-10-02), 2026-10-07 확인 댓글
- GitHub #330 구현 댓글(`/settings/feedback`)
