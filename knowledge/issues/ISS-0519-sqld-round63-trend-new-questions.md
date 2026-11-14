---
type: issue
id: ISS-0519
created: 2026-11-14
topics: [question-bank]
symptoms: ["출제 경향", "63회", "58~63회", "최신 경향 지정", "비등가 조인", "RATIO_TO_REPORT", "RANGE 프레임", "CHAR VARCHAR2 공백 비교", "바커 표기법", batch06, "T41~T52", "서버 형식 규칙 위반", "가져오기 건너뜀", "내보내기 500건 한도", "sqld-latest-trend.json"]
root_cause: "SQLD 제63회가 끝났지만 출제 경향 데이터와 문제 풀이 58~62회 기준이라 63회에 새로 나온 유형(비등가 조인, 비율·범위 윈도우 함수, 오래된 단일행 규칙 등)이 빠져 있었다"
status: open
resolution: null
related: ["[[ISS-0336-sqld-2026-trend-question-pool-refresh]]", "[[DEC-0158-new-questions-concept-only-curated]]", "[[DEC-0142-encrypt-sqld-research-materials]]", "[[DEC-0277-no-dash-middle-dot-server-cleaner]]", "[[DEC-0038-question-json-roundtrip-format]]", "[[LSN-0002-harness-lint-misses-server-format-rule]]", "[[LSN-0003-question-export-500-limit-backup-by-topic]]"]
source: "_sources/issues/ISS-0519-sqld-round63-trend-new-questions.md"
---

# ISS-0519: SQLD 63회 출제 경향 반영, 신규 유형 문제 등록

GitHub #1074 (열림, 작업중). 원본: https://github.com/Twin-Fang/passQL/issues/1074 · 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1074#issuecomment-6875720697 · PR #1090 (머지 전)

## 증상
- SQLD 제63회(2026-11-14) 시험이 끝났지만 출제 경향 데이터는 58~62회 기준이다.
- 응시 후기에서 새로 확인된 출제 개념이 문제 풀에 없거나 부족하다(이슈 본문 예: RATIO_TO_REPORT, PIVOT, 정규식, CHAR와 VARCHAR2 공백 비교, NATURAL JOIN 공통 컬럼 별칭 오류, 다중 컬럼 IN, 스칼라 서브쿼리 순위, 바커 표기법 관계 선택성).
- 홈·문제 탭의 '최신 경향'과 소개 사이트 경향 안내도 63회를 반영하지 못한다.

## 재현 조건
회차 시험이 끝난 직후. 62회 작업([[ISS-0336-sqld-2026-trend-question-pool-refresh]], #548) 절차를 63회에 재사용.

## 조사 기록
- 2026-11-14: 수집 출처는 시험 당일 복원 사이트 2곳, 오픈채팅 3개 방(익명화), 카페 후기. 복원 원문(지문·보기)은 저장하지 않고 유형과 개념만 기록. 조사 자료는 암호화본만 커밋([[DEC-0142-encrypt-sqld-research-materials]]). 외부 복원 사이트 수집 원본이 커밋에 함께 들어간 것을 발견해 추적에서 제외.
- 2026-11-14: 63회 경향 핵심 — 계산형 대부분·시간 부족, 비등가 조인 신규 2문항, 윈도우 함수 0 > 3(RATIO_TO_REPORT, RANGE 프레임), CHAR/VARCHAR2·날짜 ROUND·CEIL 등 오래된 단일행 규칙 재등장, 관리 구문 9 > 4, 1과목 바커 표기·정의 꼬기. 신규 템플릿 T41~T52.
- 2026-11-14: 서버 `server/PQL-Domain-Question/src/main/resources/exam-trend/sqld-latest-trend.json` 을 제58~63회 기준으로(늘어난 유형 8개 교체, 자주 나오는 개념 6회 합계, 공부 팁 7개). 소개 사이트 경향 안내도 같은 기준으로 갱신해 시놀로지 배포(gh-pages 커밋 cff075ea).
- 2026-11-14: 신규 문제 batch06 38건, Oracle 21c verify 38/38 통과.
- 2026-11-14: 운영 반영 — 백업 499 > 1차 14건 등록(24건은 서버 형식 규칙 #905 위반으로 건너뜀) > 형식 수정(줄표·가운뎃점 38곳, SELECT 목록 줄바꿈 15곳, 지문 자료형 4곳) 후 24건 재등록 > 신규 38건만 최신 경향 지정 > 537. 기존 문제 수정·비활성은 범위 밖.
- 2026-11-14: 하네스 lint 를 통과한 문제가 서버 형식 규칙([[DEC-0277-no-dash-middle-dot-server-cleaner]])에 걸림 > [[LSN-0002-harness-lint-misses-server-format-rule]]. 문제 풀이 500건을 넘어 내보내기 1회 한도(500건)로는 전체 백업이 안 됨 > 토픽별 백업 [[LSN-0003-question-export-500-limit-backup-by-topic]].

## 근본 원인
회차 시험 직후에는 경향 데이터와 문제 풀이 직전 회차 기준으로 남아 있다(별도 결함이 아니라 회차마다 반복되는 갱신 작업).

## 남은 일
- 60회 근거만 남은 기존 문제 5개의 최신 경향 표시 유지 여부 결정
- PR #1090 머지와 서버 배포(서버 경향 JSON 은 배포 후 앱 홈·문제 탭에 반영). 운영 문제 등록은 코드 배포와 무관하게 완료
