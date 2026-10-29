---
type: completion-report
id: ISS-0322
created: 2026-10-18
topics: [question-bank, dev-workflow]
status: resolved
resolves: "[[ISS-0322-question-harness-restructure]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/524"
---

# ISS-0322 완료 리포트: 하네스를 단계별 18개 모듈과 YAML v2로 개편, 기존 CLI·가져오기 형식 유지

GitHub #524 개요 댓글 기준 (2026-10-18).

## 해결 방법
- `tools/sqld-question-harness/sqld_harness/` 18개 모듈: 경향 근거 → 초안(YAML v2) → Oracle 실행 검증 → 품질 점검 → 해설 초안 훅 → 등록 JSON·리포트. 기존 CLI(`verify`, `render`)와 가져오기 JSON 형식 유지.
- YAML v2(`schemaVersion: 2`): 출제 의도, 함정 설계, 난이도 근거, 개념 태그, 오답별 `whyPlausible`, 최신 경향 태그 필수. v1도 동작.
- Oracle 검증 병렬 실행, 실행에 영향을 주는 필드만 캐시 키.
- 품질 점검: 정답만 긴 보기, 지문 체크리스트, 표 행 모양, ORDER BY 없는 순서 비교, 정답 위치 쏠림, 중복 탐지. 새 명령 `lint`, `stats`, `report`, `explain`, `scaffold`.
- 검증: 오프라인 테스트 65건, 기존 37문항 회귀 v1 37/37·v2 36/37, 16.4초 → 8.6초(병렬 4), 캐시 재실행 1.6초.
- 하네스가 찾은 운영 결함: `b03_like_escape` 표 행 값이 문자열이라 글자마다 칸이 쪼개져 렌더링(`| A | _ | 1 |`). 원문 수정·재검증 후 운영 갱신(`updated: 1`).

## 근본 원인 (확정)
원본에 적혀 있지 않다.

## 재발 방지
- 정답 위치 분포는 원본 YAML 기준 참고값(CURATED_ONLY는 풀이 때 순서를 섞음).
- `docs/superpowers/`는 gitignore 대상이라 설계 문서가 커밋되지 않는다.
- LLM 해설 생성기는 `ExplanationDrafter` 인터페이스만 있고 연결은 GitHub #521 이후 단계.

## 교훈
(원본에 없음, 볼트 정리) 검증 하네스에 표 행 모양 같은 형식 검사를 넣으면 실행 결과는 맞지만 화면이 깨지는 문항을 잡는다.
