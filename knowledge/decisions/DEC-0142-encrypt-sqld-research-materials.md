---
type: decision
id: DEC-0142
created: 2026-10-16
reviewed: null
topics: [question-bank, security]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0313-sqld-2026-trend-curated-choices]]", "[[ISS-0313-sqld-2026-trend-curated-choices-report]]"]
---

# DEC-0142: 출제 경향 조사 원문은 로컬에만 두고 레포에는 AES-256 암호본만 커밋한다

## 문제 정의 (Context)
2026 출제 경향 조사(복원 문항표, 카페 후기, 저자 분석)와 문제 원본을 레포에 보관해야 했다 (GitHub #511).

## 결정 (Decision)
- 원문은 `docs/sqld-research/`에 두고 gitignore로 제외한다.
- 레포에는 `docs/sqld-research-encrypted/`의 AES-256 암호본만 커밋한다. pre-commit hook이 커밋할 때 자동으로 암호화한다.
- 키는 루트 `.env`에 두고 GitHub Secret과 시놀로지 백업 워크플로에도 등록한다.

## 검토한 대안 (Alternatives)
논의 기록 없음. (원본 이유: 조사 자료는 앱 자산이라 원문은 로컬에만 둔다.)

## 결과 (Consequences)
**긍정**
- 이후 양산 문제 원본도 암호화본으로 커밋됐다(`63a218ab`).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`docs/sqld-research/`, `docs/sqld-research-encrypted/`, pre-commit hook, 루트 `.env`, GitHub Secret, 시놀로지 백업 워크플로. 공개용 경향 화면 문구는 원문을 옮기지 않고 요약만 쓴다(GitHub #523).

## 출처 (References)
- GitHub #511 이슈 본문 "수집 자료 보호", 보고 댓글 (2026-10-16)
- [[ISS-0313-sqld-2026-trend-curated-choices]]
