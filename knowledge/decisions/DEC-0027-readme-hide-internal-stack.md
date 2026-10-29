---
type: decision
id: DEC-0027
created: 2026-04-09
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0027-readme-contest-positioning]]", "[[ISS-0027-readme-contest-positioning-report]]"]
---

# DEC-0027: 외부 공개 README에는 테스트·개발 스택을 노출하지 않고 상위 개념으로 표기 (MariaDB → Oracle DB, Gemini → AI Agent, bge-m3 → Gemma Embedding)

## 문제 정의 (Context)
README가 공모전 제출물로 쓰이는데 내부 구현 용어가 포지셔닝과 어긋났다 (GitHub #36).

## 결정 (Decision)
- README는 외부 공개 문서이므로 테스트·개발 환경 스택(MariaDB 등)은 노출하지 않는다. 내부 기술 스택 문서는 `docs/`에서 관리한다 (이슈 본문 「내부 구현 노출 금지 원칙 문서화」).
- README 전반에서 `MariaDB` → `Oracle DB`, `Gemini` → `AI Agent`, `bge-m3` → `Gemma Embedding`으로 치환한다.

## 검토한 대안 (Alternatives)
원본이 각 치환에 적은 이유:
- MariaDB 노출: 실제 SQLD 시험은 Oracle 기반이고 MariaDB는 테스트 환경 한정 → "실제 시험 환경과 동일한 엔진" 차별화 포인트로 전환.
- Gemini 벤더명 노출: `AI Agent`라는 추상화가 기술적 독립성·확장성 측면에서 더 강한 인상.
- bge-m3: "현존 최고 수준 임베딩"인 Gemma Embedding으로 변경 및 어필 포인트화.

## 결과 (Consequences)
**긍정**
- 공모전 포지셔닝 강화 (리포트).

**부정**
- 리포트 주의사항: README의 Gemma Embedding 채택은 향후 방향이며 실제 가동 여부는 재확인이 필요하다 — README 표기와 실제 구현이 다를 수 있다.

## 영향 범위 (Scope)
`README.md`. 내부 문서(`docs/`, 스택별 CLAUDE.md)는 대상이 아니다.

## 출처 (References)
- GitHub #36 이슈 본문 「기술 표현의 추상화·격상」·「내부 구현 노출 금지 원칙 문서화」, `## 개요` 리포트 댓글 (2026-04-09)
