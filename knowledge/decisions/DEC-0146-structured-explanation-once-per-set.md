---
type: decision
id: DEC-0146
created: 2026-10-18
reviewed: null
topics: [ai, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0319-ai-explanation-format-speed-ux]]", "[[ISS-0319-ai-explanation-format-speed-ux-report]]"]
---

# DEC-0146: AI 해설은 고정 섹션 형식으로 선택지 세트당 한 번 만들어 저장하고, 없으면 "생성 중"을 돌려주며 백그라운드에서 만든다

## 문제 정의 (Context)
해설이 늦게 나오고 형식이 없어 읽기 어려웠다. 보기 4개 해설을 Gemini 4번 연속 호출로 만들었고, 없으면 요청 중 생성했다 (GitHub #521).

## 결정 (Decision)
- 해설 형식: 판정(서버가 DB 정답으로 생성), 정답 근거, 핵심 개념, 헷갈리는 지점, 보기별 판단, 시험 팁. 항목별 길이 상한·문체 규칙, 저장 전 검증, 1회 재시도, 실패 시 기존 텍스트 폴백.
- 선택지 세트당 한 번 생성·저장하고 저장본을 즉시 응답한다. 없으면 GENERATING 상태를 돌려주고 백그라운드에서 만든다. 프롬프트 버전이 바뀌면 옛 해설을 보여 주며 뒤에서 재생성한다.
- 조회 API `GET /api/ai/choice-explanation`은 제출 기록이 없으면 400(풀기 전 정답 노출 방지).
- 기존 `diff-explain` 응답은 출시된 앱 호환을 위해 구조화 해설을 마크다운으로 그린 글로 유지한다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 운영에서 1회 시도로 1.6~3.3초 생성, 웹 약 2초 안 미리보기 표시.

**부정**
- 문체 혼재가 남았다(프롬프트 v2 과제).
- 해설 문장 속 보기 키는 서버 키라 앱 화면 순번과 다를 수 있다.

## 영향 범위 (Scope)
서버 해설 생성·저장·백필, `GET /api/ai/choice-explanation`, `diff-explain`, `tools/explanation-harness/`, 앱·웹 해설 화면. (해설 모델·프롬프트 컨텍스트에 관한 기존 결정 DEC-0099·DEC-0100과 같은 영역.)

## 출처 (References)
- GitHub #521 개요 댓글 (2026-10-18)
- [[ISS-0319-ai-explanation-format-speed-ux]]
