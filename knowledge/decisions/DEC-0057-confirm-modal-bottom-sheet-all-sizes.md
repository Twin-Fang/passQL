---
type: decision
id: DEC-0057
created: 2026-04-12
reviewed: null
topics: [design-system, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0081-confirm-modal-desktop-layout-broken]]", "[[ISS-0081-confirm-modal-desktop-layout-broken-report]]", "[[DEC-0053-spa-only-leave-blocker]]"]
---

# DEC-0057: `ConfirmModal`은 데스크톱도 화면 너비 100% 바텀시트 단일 레이아웃

## 문제 정의 (Context)
GitHub #121의 `ConfirmModal`은 모바일 바텀시트 / 데스크톱 중앙 모달이었는데, 데스크톱 `md:` 클래스가 레이아웃을 깨뜨렸다 (GitHub #142).

## 결정 (Decision)
카드의 `md:` 반응형 클래스를 모두 지우고 모든 화면 크기에서 `w-full rounded-t-2xl` 바텀시트로 표시한다. 리포트는 이를 "디자인 가이드(모든 화면 크기 일관성)에 따른 결정"이라고 적었다.

## 검토한 대안 (Alternatives)
- 데스크톱 중앙 팝업(`flex items-center` + `max-w-sm mx-auto rounded-2xl`): 모바일/데스크톱 분기가 생기므로 별도 이슈로 논의 권장으로 남겼다. 그 이상의 비교는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 모든 화면 크기에서 같은 레이아웃.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`src/components/ConfirmModal.tsx`와 이를 쓰는 이탈 확인 화면(`PracticeSet`, `DailyChallenge`, `QuestionDetail`).

## 출처 (References)
- GitHub #142 리포트 댓글 (2026-04-12)
- [[ISS-0081-confirm-modal-desktop-layout-broken]]
