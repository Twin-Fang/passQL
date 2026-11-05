---
type: completion-report
id: ISS-0451
created: 2026-11-05
topics: [practice, ai, question-bank]
status: resolved
resolves: "[[ISS-0451-result-table-choices-fabricated-unvalidated-sets]]"
related: ["[[DEC-0249-result-table-choices-from-executed-sql]]", "[[DEC-0250-never-store-unvalidated-sql-choice-sets]]", "[[DEC-0251-practice-reuse-random-validated-sets]]", "[[ISS-0452-server-only-release-triggers-store-submit]]"]
source: "https://github.com/Twin-Fang/passQL/issues/828"
---

# ISS-0451 완료 리포트: 결과 표는 실제 실행 결과만, 미검증 세트 차단, 운영 전수 재채점

GitHub #828 리포트 기준 (2026-11-05). 원본 사본: `_sources/issues/ISS-0451-result-table-choices-fabricated-unvalidated-sets-report.md` (로컬 전용). PR #829·#831·#833·#837·#839.

## 해결 방법
- 결과 표 보기: AI는 오해 SQL 후보만 쓰고 서버가 실행한 결과를 표로 저장 → [[DEC-0249-result-table-choices-from-executed-sql]]. 시도마다 쓸 만한 오답을 모으고(버림: 실행 오류·열 다름·정답과 같음·중복), 3개가 모이면 정답 표(기준 SQL 결과)와 무작위 위치로 조립. 빈 결과 오답은 예비 1개, 마지막 시도에 모자랄 때만.
- 출제 지시문은 운영 DB 결과 표 전용 프롬프트에만 (공개 레포 코드에 지시문 없음).
- AI 정답 표시 대체 저장 삭제, 실전 모드 실패 시 검증 세트 재사용 → [[DEC-0250-never-store-unvalidated-sql-choice-sets]]. 연습 모드 검증 세트 5개 중 무작위 → [[DEC-0251-practice-reuse-random-validated-sets]].
- 프리페치 정책별 경로(`generateForQuestion`), 제출 응답 결과 표 정답 SQL = 문제 정답 SQL, 앱 `ChoiceItem.isSql`.
- 관리자 전수 검증·문제별 재생성 API.

## 검증
- 1차 전수 검증: 노출 329개 중 정상 23, 틀림 13(옛 방식 표 12, 재실행 정답 3개 1), 실행 검증 대상 아님 293 > 13개 내림, 12개 문제 새 세트.
- 새 결과 예측 함정 문제 30개 등록(샌드박스 30/30), 세트 28개, 생성 불가 2개 비활성(ORDER BY 순서만 묻는 문제, 결과 한 열 문제).
- 2차 전수 검증: 노출 357개 중 정상 64, 틀림 0.
- 운영 적용 중 찾은 결함: 4개 한 번에 통과 방식은 13개 중 4개 실패 > 오답 모으기로, 조립 로그 `contains(null)` NullPointerException(500) > #839 긴급 수정.

## 근본 원인 (확정)
결과 표 오답을 실제 실행 없이 AI가 써서 근거 없는 표가 저장됐고, 검증 실패 세트를 AI 판단으로 저장·재사용하는 경로가 있었다.

## 재발 방지
- 결과 표는 실행 결과로만 만들고, 전수 검증 API로 노출 세트를 다시 채점할 수 있다.

## 알고 남긴 것
- AI 생성 개념형 세트 32개는 실행 검증 불가(이번 범위 밖, #834).
- 행 순서 무시 비교라 ORDER BY 순서 자체를 묻는 문제, 결과가 한 열뿐인 문제는 이 유형에 맞지 않다.

## 교훈
(원본에서 정리)
- AI가 만든 정답·오답은 실행 결과로 대조할 수 있으면 반드시 실행으로 만든다. "정답이 하나인가"만 보는 검증은 오답의 근거를 보장하지 않는다.
