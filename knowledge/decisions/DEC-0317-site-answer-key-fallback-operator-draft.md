---
type: decision
id: DEC-0317
created: 2026-11-14
reviewed: null
topics: [store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0520-sqld-round-answer-key-omr-grading]]", "[[DEC-0316-exam-answer-two-sources-operator-first]]", "[[DEC-0294-intro-site-self-hosted-own-domain]]"]
---

# DEC-0317: 소개 사이트 가답안 페이지는 서버 API 가 실패하면 빌드 때 넣은 운영 가답안 초안 스냅샷을 보여 주고, 채점은 브라우저에서 같은 규칙으로 계산해 서버 없이도 동작한다

GitHub #1075 (설계 스펙, gh-pages 커밋 4fb0caf3·350f485a, 보고서 댓글).

## 문제 정의 (Context)
소개 사이트 `sqld/63/` 은 시험 당일 먼저 배포하고, 서버·앱은 PR 상태로 남았다(서버 배포는 앱 심사 동반이라 보류, [[LSN-0004-app-change-release-means-ios-review]]). 서버 가답안 API 가 아직 없거나 실패하면 페이지가 비게 된다.

## 결정 (Decision)
- 페이지는 서버 공개 API 를 1분마다 읽고, 실패하면 빌드 때 포함한 스냅샷 JSON 으로 표시한다(스펙: 오프라인 안전).
- 스냅샷은 빈 표가 아니라 운영 가답안 초안(`_src/answer_key_drafts/sqld-63.json`, 응시 후기 종합, 우세 30·갈림 18·미복원 2, 공개용 짧은 안내만)이다.
- 득표가 없는 문항은 '합의 0%' 대신 '응답 모으는 중 · passQL 운영 가답안'으로 표시한다.
- OMR 채점은 브라우저에서 사이트 과목·합격선 원본으로 만든 같은 규칙으로 계산한다.

## 검토한 대안 (Alternatives)
- 스냅샷을 "50문항 집계 중"(빈 가답안)으로 두기: 첫 구현(4fb0caf3)이 그랬고, 350f485a 에서 운영 초안으로 바꿨다. 바꾼 이유는 커밋 메시지의 "빈 가답안 대신" 외에 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 서버 배포 전에도 시험 당일 가답안·가채점이 동작한다.

**부정**
- 서버가 배포되면 서버 응답이 우선이라, 운영 가답안을 입력하기 전에는 사이트가 미확정 50문항으로 덮인다(배포 직후 입력 필요).
- 사이트 채점 규칙과 서버·앱 규칙이 각각의 원본에서 나와 기준을 바꿀 때 세 곳을 함께 맞춰야 한다.

## 영향 범위 (Scope)
gh-pages `_src/site_answer_key_content.py`·`site_answer_key_pages.py`·`answer_key_drafts/`, `exam-answer.js`·`exam-answer-grading.js`·`exam-answer-table.js`.

## 출처 (References)
- GitHub #1075 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1075#issuecomment-6875720871
- 설계 스펙 `docs/superpowers/specs/2026-11-14-exam-answer-key-design.md` (로컬 전용)

## W4 검사
[[DEC-0294-intro-site-self-hosted-own-domain]](원본은 gh-pages `_src/` 생성기, 시놀로지 서빙)을 그대로 따른다 — 충돌 없음.
