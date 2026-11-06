---
type: decision
id: DEC-0258
created: 2026-11-07
reviewed: null
topics: [billing, ai, progress-stats]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0458-server-side-free-limit-pro-gating]]", "[[DEC-0004-free-pro-feature-boundary]]"]
---

# DEC-0258: AI 코멘트는 결과 화면·통계 화면 모두 프로 전용 (무료 하루 1회 통계 코멘트 폐지)

## 문제 정의 (Context)
[[DEC-0004-free-pro-feature-boundary]]는 AI 코멘트를 프로로 두었지만, GitHub #699 에서 통계 화면 코멘트를 무료에게도 하루 1회 열었다. 결제 전 서버 판정 점검(GitHub #860)에서 두 기준이 어긋남을 확인했다.

## 결정 (Decision)
- AI 코멘트는 형태와 관계없이 프로 전용 (2026-11-07 사용자 결정: "AI코멘트는 프로전용으로가자").
- 서버 판정: `ProgressController` `@RequiresProFeature(AI_COMMENT)`. 무료(결제 켜짐)는 앱·웹에서 요청하지 않고 잠금 미리보기.

## 검토한 대안 (Alternatives)
- 무료 하루 1회 유지 (#699 방식): 논의 기록 없음 (사용자가 프로 전용으로 정함).

## 결과 (Consequences)
**긍정**
- 무료/프로 경계가 한 기준으로 맞춰짐, 무료 회원 AI 비용 없음.

**부정**
- 무료 회원은 통계 화면에서 AI 코멘트를 볼 수 없음 (잠금 미리보기만).

## 영향 범위 (Scope)
서버 `ProgressController`·`AiCommentService`, 앱 `stats_providers.dart`·`ai_analysis_card.dart`, 웹 `Stats.tsx`.

## 출처 (References)
- GitHub #860 이슈 본문·리포트, 2026-11-07 대화의 사용자 결정
