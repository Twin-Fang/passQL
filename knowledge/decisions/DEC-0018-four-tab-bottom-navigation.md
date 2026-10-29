---
type: decision
id: DEC-0018
created: 2026-04-07
reviewed: null
topics: [design-system]
status: superseded
supersedes: null
superseded_by: DEC-0101
related: ["[[ISS-0011-screen-spec-api-mapping]]", "[[DEC-0101-bottom-tab-icons-only]]"]
---

# DEC-0018: 하단 탭은 `홈 / 문제 / 통계 / 설정` 4탭 (노트·순위·내정보 탭 미채택)

## 문제 정의 (Context)
디자인 시안마다 하단 탭 구성이 달랐다 (GitHub #8).

## 결정 (Decision)
하단 탭은 `홈 / 문제 / 통계 / 설정` 4탭으로 확정한다. 디자인에 등장한 "노트", "순위", "내정보" 탭은 채택하지 않는다.

## 검토한 대안 (Alternatives)
컷오프 표의 사유:
- 노트 탭: PRD에 없음, 5일 내 구현 불가
- 순위 탭: 인증 필요
- 내정보 탭: 설정 탭과 중복

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
프론트 라우팅과 레이아웃 컴포넌트(하단 탭).

## 출처 (References)
- GitHub #8 이슈 본문 「핵심 원칙」·「컷오프 종합」
