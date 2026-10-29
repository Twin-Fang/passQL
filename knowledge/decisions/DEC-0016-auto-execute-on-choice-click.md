---
type: decision
id: DEC-0016
created: 2026-04-07
reviewed: null
topics: [practice]
status: superseded
supersedes: null
superseded_by: DEC-0051
related: ["[[ISS-0010-five-day-dev-roadmap]]", "[[ISS-0011-screen-spec-api-mapping]]", "[[ISS-0014-replace-mock-with-real-api]]", "[[DEC-0051-no-auto-execute-review-after-submit]]"]
---

# DEC-0016: 선택지 라디오를 클릭하면 그 선택지 SQL을 자동 execute, 같은 선택지 재클릭은 클라 캐시

## 문제 정의 (Context)
문제 상세 화면에서 선택지 SQL 실행 시점을 정해야 했다. GitHub #7은 이 정책을 "(확정)"으로 표기했고, GitHub #8이 다시 명문화했다.

## 결정 (Decision)
사용자가 선택지 라디오를 클릭하는 즉시 해당 선택지의 SQL을 execute API(`POST /api/questions/{id}/execute`)로 자동 호출한다. 동일 선택지를 다시 클릭하면 클라이언트 캐시에서 결과를 재표시해 재호출을 막는다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 자동 실행으로 `ratelimit.execute.per_minute`가 빠르게 소진될 수 있다 → 기본값 60 → 90 조정(#7: "선택지 자동 실행 부하 대응"), 재호출 방지 클라 캐시, 어드민에서 한도 조정 (#8 주의사항).

## 영향 범위 (Scope)
프론트 문제 상세 화면의 선택지별 실행 결과 맵(`Record<choiceKey, ExecuteResult>`), `app_setting`의 `ratelimit.execute.per_minute`. GitHub #13에서 `useExecuteChoice` 로컬 캐시로 구현.

## 출처 (References)
- GitHub #7 이슈 본문 「전제 조건」·「D2 시드 데이터」, GitHub #8 이슈 본문 「핵심 원칙」·「주의사항」
- GitHub #13 작업 보고
