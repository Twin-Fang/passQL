---
type: issue
id: ISS-0479
created: 2026-11-05
topics: [question-bank, practice, ai]
symptoms: ["실제 SQLD 출제 형식 부족", "함정 문제 적음", "같은 함정 반복", "결과 행 수 맞히기", "오류 나는 SQL 찾기", "오답 해설 숫자가 결과 표와 다름", "개념형 AI 보기 세트 답 2개"]
root_cause: "문제 은행이 결과 예측, 동치 SQL, 결과가 다른 것, 개념형에 몰려 실제 출제 형식과 함정을 다 다루지 못했다"
status: resolved
resolution: "[[ISS-0479-sqld-real-format-trap-questions-report]]"
related: ["[[ISS-0451-result-table-choices-fabricated-unvalidated-sets]]"]
source: "https://github.com/Twin-Fang/passQL/issues/834"
---

# ISS-0479: 실제 SQLD 출제 형식 다루는 문제 유형 확장과 함정 문제 추가

GitHub #834 (https://github.com/Twin-Fang/passQL/issues/834). 원본 사본: `_sources/issues/ISS-0479-sqld-real-format-trap-questions.md`(로컬). 코드 변경 없이 운영 문제 은행과 출제 지시문(운영 DB에만)으로 처리.

## 증상
- 실제 SQLD 문제는 더 헷갈리고 까다로운데 문제 은행은 결과 예측, 동치 SQL, 결과가 다른 것, 개념형 위주라 실제 출제 형식을 다 다루지 못한다.
- 함정 문제 수가 적고, 다시 풀면 같은 함정이 반복된다.

## 재현 조건
해당 없음 (콘텐츠 확장).

## 조사 기록
- 2026-11-05 1차: 수험생 카페(읽기 전용), 복원 기출, 후기에서 함정 패턴 180개, 문제 형식 14종 정리(원문과 출제 지시문 비공개). 최근 증가 유형: 비교형 보기, 관리 구문 최종 상태 추적, 짧은 쿼리 속 NULL, ROWNUM 실행 순서. 결과 예측 함정 30개, 샌드박스 30/30, 보기 세트 28개(비활성 2개: ORDER BY 순서만 묻는 문제는 결과 비교가 행 순서 무시, 결과 한 열 NOT IN 문제는 오답 조합 부족).
- 3차: 19개(윈도우, 그룹 함수, 함수, 조인, 서브쿼리, DML 상태 추적), 샌드박스 19/19, 세트 18개.
- 4차: 비활성 형식을 열과 행을 늘려 다시 냄, 13개 13/13. 오답 해설이 실제 표와 다른 숫자를 말하던 문제 발견(AI가 실행 전에 결과를 예측해 해설에 적음) > 결과 표 출제 지시문 새 버전(해설은 잘못 안 규칙만, 숫자와 행 금지, 앱 말투), 88문제 중 85문제 세트 교체.
- 5차: 새 형식 2종(결과 행 수 맞히기 6, 오류 나는 SQL 찾기 6)을 새 화면 없이 기존 구조(지문 안 표 + 고정 보기)로. Oracle과 PostgreSQL이 같게 동작하는 오류만 고름.
- 개념형 AI 보기 세트 32개 판정: 정상 20, 약함 6, 틀림 6, 내린 세트 8. 틀린 세트 공통 원인 5가지(지문의 표와 SQL을 무시한 일반론 보기, 실행 없이 결과 비교를 글 보기로, 양변만 바꾼 식을 다른 뜻으로 판정, 지나친 단정으로 답 2개, 해설과 정답 표시 불일치).
- 누적 92개 등록, 활성 88개.

## 근본 원인
frontmatter `root_cause`와 같음. 4차의 해설 숫자 불일치는 실행 전 AI 예측을 해설에 쓴 것이 원인(GitHub #828 [[ISS-0451-result-table-choices-fabricated-unvalidated-sets]]와 같은 계열: 결과는 실제 실행으로만).
