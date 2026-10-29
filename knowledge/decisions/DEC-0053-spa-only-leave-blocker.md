---
type: decision
id: DEC-0053
created: 2026-04-11
reviewed: null
topics: [practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0070-leave-warning-modal-during-solving]]", "[[ISS-0070-leave-warning-modal-during-solving-report]]"]
---

# DEC-0053: 풀이 이탈 경고는 `useBlocker`로 SPA 내 이동만 막고 `beforeunload`(탭 닫기·새로고침)는 막지 않는다

## 문제 정의 (Context)
풀이 중 경고 없이 화면을 떠나 `PracticeSet` 세션 기록이 유실될 수 있었다 (GitHub #121).

## 결정 (Decision)
React Router DOM v7 `useBlocker` + 공통 `ConfirmModal`로 `PracticeSet`·`DailyChallenge`·`QuestionDetail`(단독 모드)의 앱 내 이동을 막는다. 화면별 해제 시점은 각 저장 구조에 맞춘다(결과 페이지 이동 직전 / `submitAnswer` 성공 후 / 제출 후). 브라우저 탭 닫기·새로고침(`beforeunload`)은 의도적으로 제외한다.

## 검토한 대안 (Alternatives)
- `beforeunload` 차단: "과도한 UX 방해로 판단"해 제외했다(리포트 주의사항). 그 밖의 대안은 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 앱 내 모든 이탈 경로(사이드바, Home 버튼, 브라우저 뒤로가기)에서 확인을 받는다.

**부정**
- 탭 닫기·새로고침으로는 경고 없이 기록이 유실될 수 있다(제외 결정의 결과).

## 영향 범위 (Scope)
`client/src/components/ConfirmModal.tsx`, `PracticeSet.tsx`, `DailyChallenge.tsx`, `QuestionDetail.tsx`.

## 출처 (References)
- GitHub #121 리포트 댓글 (2026-04-11)
- [[ISS-0070-leave-warning-modal-during-solving]]
