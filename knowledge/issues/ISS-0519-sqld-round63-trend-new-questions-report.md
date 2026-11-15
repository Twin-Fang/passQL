---
type: completion-report
id: ISS-0519
created: 2026-11-15
topics: [question-bank]
status: resolved
resolves: "[[ISS-0519-sqld-round63-trend-new-questions]]"
related: ["[[ISS-0336-sqld-2026-trend-question-pool-refresh]]", "[[ISS-0520-sqld-round-answer-key-omr-grading]]", "[[LSN-0002-harness-lint-misses-server-format-rule]]", "[[LSN-0003-question-export-500-limit-backup-by-topic]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1074#issuecomment-6875720697"
---

# ISS-0519 완료 리포트: 63회 경향 반영, 신규 38문항 등록, 2026-11-15 배포

배포 실측 댓글: https://github.com/Twin-Fang/passQL/issues/1074#issuecomment-6894676868 · PR #1090, #1093 머지 · 릴리스 PR #1094

## 해결 방법
- 서버 `server/PQL-Domain-Question/src/main/resources/exam-trend/sqld-latest-trend.json` 을 제58~63회 기준으로 갱신(늘어난 유형 8개 교체, 자주 나오는 개념 6회 합계, 공부 팁 7개). 소개 사이트 경향 안내도 같은 기준으로 갱신해 배포(gh-pages).
- 조사 자료(암호화본 `docs/sqld-research-encrypted/`): 63회 복원 문항표(유형·개념만), 경향 분석 63회 절, 템플릿 T41~T52, 당일 노트(익명화), 신규 문제 batch06.
- 운영 문제 풀: 백업 499 > 신규 38건 등록(1차 14건, 서버 형식 규칙 #905 위반 24건 형식 수정 후 재등록) > 신규 38건 최신 경향 지정 > 537. Oracle 21c 검증 38/38.
- 60회 근거만 남은 기존 문제 5개는 최신 경향 표시를 해제(사용자 결정). 결정 이유는 논의 기록 없음.
- 2026-11-15 릴리스 PR #1094 로 서버·AI·웹·Android(Play 내부 테스트)·iOS(TestFlight·심사 제출) 배포 워크플로 모두 성공 > 서버 경향 JSON 이 앱 홈·문제 탭에 반영되는 배포 완료.

## 근본 원인 (확정)
회차 시험 직후에는 경향 데이터와 문제 풀이 직전 회차(58~62회) 기준으로 남아 있다. 결함이 아니라 회차마다 반복되는 갱신 작업.

## 재발 방지
- 하네스 lint 는 서버 형식 규칙(#905)을 못 잡는다 > 운영 등록 전 서버 형식 규칙과 같은 검사를 따로 돌린다([[LSN-0002-harness-lint-misses-server-format-rule]]).
- 문제 내보내기 API 는 1회 500건 한도 > 전체 백업은 토픽별로 나눠 받는다([[LSN-0003-question-export-500-limit-backup-by-topic]]).

## 교훈
- 다음 회차 갱신은 62회([[ISS-0336-sqld-2026-trend-question-pool-refresh]])·63회 절차를 재사용: 당일 수집(원문 미저장) > 경향 JSON·소개 사이트 동시 갱신 > 신규 문제 검증 > 백업(토픽별) > 등록 전 서버 형식 검사 > 등록 > 신규만 최신 경향 지정.
