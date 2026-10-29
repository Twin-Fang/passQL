---
type: decision
id: DEC-0162
created: 2026-10-21
reviewed: null
topics: [ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0345-cheapest-model-per-feature-benchmark]]", "[[ISS-0345-cheapest-model-per-feature-benchmark-report]]"]
---

# DEC-0162: 해설·오류 설명·개념 선택지는 `gemini-3.5-flash-lite`, SQL·결과표 선택지·AI 코멘트·문제 생성은 `gemini-2.5-flash-lite` 유지

## 문제 정의 (Context)
기능별로 품질을 유지하는 최저가 모델을 찾기 위해 최신 단가를 조사하고 가장 비싼 기능(diff_explain)을 실측했다 (GitHub #558).

## 결정 (Decision)
| 기능 | 모델 |
|---|---|
| 해설 (`diff_explain`), 오류 설명 (`explain_error`), 개념 선택지 | `gemini-3.5-flash-lite` 유지 |
| SQL·결과표 선택지, AI 코멘트, 문제 생성 | `gemini-2.5-flash-lite` 유지 |

모델 변경 없음.

## 검토한 대안 (Alternatives)
- 해설 계열을 `gemini-2.5-flash-lite`로 내리기: 건당 차이 약 $0.0012로 작고, 2.5는 사실 오류(계층 쿼리 탐색 방향)가 나와 버림. GitHub #356 결과와 같은 경향.
- `gemini-3.1-flash-lite`: 단가가 2.5-flash-lite보다 높고 이르면 2027-05-07 종료라 후보에서 제외.
- `gemini-3.6-flash`/`3.8-flash`: 단가표에 올렸으나 실측 계획에서 "기준점으로 1회(선택)"였고 실측 결과는 원본에 없다.

## 결과 (Consequences)
**긍정**
- SQL·결과표 선택지는 이미 최저가이고 샌드박스·검증기가 있다.

**부정**
- `gemini-2.5-flash-lite`는 신규 계정 사용 제한이 있어 키를 바꾸면 3.5-flash-lite로 옮겨야 할 수 있다.

## 영향 범위 (Scope)
운영 프롬프트 모델 설정(코드 변경 없음). 비용 모니터링은 GitHub #557 대시보드.

## 출처 (References)
- GitHub #558 조사 댓글(2026-10-20), 실측 결과 댓글(2026-10-21), PR #573
- 관련 기존 결정: DEC-0099(해설 모델 3.5-flash-lite, #356) — 이 결정은 그 선택을 유지한다.
- [[ISS-0345-cheapest-model-per-feature-benchmark]]
