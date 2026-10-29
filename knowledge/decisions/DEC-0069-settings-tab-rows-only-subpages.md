---
type: decision
id: DEC-0069
created: 2026-04-13
reviewed: null
topics: [design-system, community]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0116-feedback-settings-subpage-split]]", "[[ISS-0116-feedback-settings-subpage-split-report]]", "[[ISS-0113-feedback-api-implementation]]", "[[DEC-0071-settings-flat-grouped-list]]"]
---

# DEC-0069: 설정 탭은 row 목록만 — 기능(건의사항 등)은 탭바 없는 서브페이지로

## 문제 정의 (Context)
설정 탭에 건의사항 입력 폼·목록이 풀 UI로 펼쳐져 있었다. GitHub #200 댓글(2026-04-13): "건의사항은 따로 페이지에서 관리해야될것같습니다." GitHub #209 이슈 본문: 항목이 늘수록 설정 탭이 무거워지고, iOS 설정 앱·토스 등 표준 모바일 패턴과 다르다.

## 결정 (Decision)
설정 탭은 순수 row 목록만 보여준다. 건의사항은 `SettingsRow` + `ChevronRight`로 `/settings/feedback` 서브페이지에 진입한다. 서브페이지는 AppLayout 밖 독립 라우트(탭바 없는 몰입형)이고 공통 `SubpageLayout`(뒤로가기 헤더)을 쓴다.

## 검토한 대안 (Alternatives)
- 설정 탭에 폼·목록을 직접 펼치기(GitHub #198 구현): 위 이유로 버림.

## 결과 (Consequences)
**긍정**
- 설정 탭이 가벼워지고 표준 모바일 패턴과 맞는다(이슈 본문). FeedbackForm·FeedbackList는 수정 없이 재사용.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
웹 `Settings.tsx`, `SettingsFeedback.tsx`, `SubpageLayout.tsx`, `DevPage.tsx`, `App.tsx` 라우트.

## 출처 (References)
- GitHub #200 댓글 (2026-04-13), GitHub #209 이슈 본문·작업 리포트 (2026-04-13)
- [[ISS-0116-feedback-settings-subpage-split]], [[ISS-0113-feedback-api-implementation]]
