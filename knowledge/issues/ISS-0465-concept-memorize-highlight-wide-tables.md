---
type: issue
id: ISS-0465
created: 2026-11-07
topics: [concept-learning, design-system]
symptoms: ["외울 부분 본문에 묻힘", "암기 포인트 부족", "표 가로 넘침", "모바일 표 읽기 어려움", "낱말 쪼개짐 NUL/L", content/concepts, fitColumnWidths]
root_cause: "개념 글에 외울 부분을 표시하는 방법과 과목별 암기 항목이 없었고, 표 폭을 화면 폭 기준으로 검사하지 않았다"
status: open
resolution: null
related: ["[[DEC-0266-concept-bold-highlight-memorize-section]]", "[[DEC-0256-concept-lesson-blocks-by-table-header]]", "[[DEC-0257-concept-animated-diagram-blocks]]", "[[ISS-0457-concept-animated-diagrams]]"]
source: "_sources/issues/ISS-0465-concept-memorize-highlight-wide-tables.md"
---

# ISS-0465: 개념 학습 외울 부분 강조와 과목별 암기 포인트 보강, 가로로 긴 표 정리

GitHub #876 (https://github.com/Twin-Fang/passQL/issues/876). 관련 #853, #848.

## 증상
- 꼭 외워야 할 부분이 본문에 묻혀 시험 직전 훑어볼 때 눈에 띄지 않음.
- 과목마다 외워 두면 점수가 되는 포인트(정규형 단계, 조인 종류별 결과, 함수 NULL 처리, 윈도우 함수 순위 차이, 트랜잭션 격리 수준 등)가 개념 글에 부족.
- 일부 표가 모바일 화면에서 가로로 넘쳐 읽기 어려움.

## 재현 조건
앱 개념 학습에서 표가 넓은 개념을 390pt 폭 폰으로 열 때.

## 조사 기록
- 2026-11-07: 암기 포인트 조사 기록 댓글 — 공식 범위(dataq.or.kr 출제기준: 50문항 10+40, 90분, 60점·과목 40% 과락)와 2024 개정 범위 비교, 1·2과목 항목별 검색어와 참고 출처 목록. 원문은 옮기지 않고 사실 확인에만 사용. 출처 중 Top N 쿼리 설명 오류("RANK <= N 은 N행보다 적을 수 있다"는 틀림, 동점이면 많아짐) 발견.
- 2026-11-07: PR #890 머지 (main 반영) — 63개 개념 모두 "꼭 외울 것" 문단, `**굵게**` 형광펜, 넘치던 표 약 40개 정리, 빌드 점검 추가. 설계는 [[DEC-0266-concept-bold-highlight-memorize-section]].
  - 표 정리 방법: 용어 카드로 옮기기, 나누기, 행·열 바꾸기, 필요한 열만 보이기. 넘치면 칸 안 낱말 단위 줄바꿈, 낱말도 안 들어가면 가로 스크롤.
  - 후속 수정: 잰 폭과 그릴 폭이 같으면 소수 오차로 낱말이 쪼개짐(`NUL/L`) > 열 폭 1pt 여유.
  - 검증(PR 기준): 개념 묶음 빌드 63개, 점검 오류 0, `flutter test` 112개 통과. 미검증: 새 Oracle 오류 확인 SQL 1개 (Docker 복구 후 `verify_concept_sql.py`).
- 2026-11-07 기준 GitHub 이슈는 열림(`작업중`), 완료 리포트 댓글 없음 — 리포트 후 완료 리포트 노트로 닫는다.

## 근본 원인
외울 부분 표시 규칙·암기 문단이 콘텐츠 형식에 없었고, 표 폭을 실제 화면 폭으로 검사하는 점검이 없었다.
