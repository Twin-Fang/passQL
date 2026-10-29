---
type: completion-report
id: ISS-0321
created: 2026-10-18
topics: [question-bank, home]
status: resolved
resolves: "[[ISS-0321-latest-trend-notice-badge]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/523"
---

# ISS-0321 완료 리포트: "최신 경향" 배지, 출제 경향 화면, 업데이트 공지

GitHub #523 개요 댓글 기준 (2026-10-18).

## 해결 방법
- 서버: `question.is_latest_trend`(`V1_18_1`), 응답 `isLatestTrend`, 목록 `latestTrend=true` 필터, 경향 API(`/api/exam-trends/latest`, `/latest/topics`), 관리자 일괄 지정 `PUT /admin/questions/latest-trend`(최대 200개, 바뀐 문제만 감사 로그).
- 경향 화면 문구는 서버 JSON 리소스 `exam-trend/sqld-latest-trend.json`. 암호화 대상 조사 원문은 옮기지 않고 공개용 요약만.
- 앱·웹: 불꽃 아이콘 + "최신 경향" 배지, 경향 화면(과목 비중, 늘어난 유형, 개념 TOP, 공부 팁), 토픽의 최신 경향 문제 바로 풀기.
- 운영: 등록 시점·출처 컬럼이 없어 자동 판별 대신 후보 API(활성 + CURATED_ONLY + 고정 보기 세트) 37개를 양산 문항 `schemaIntent`와 대조해 정확히 일치 확인, 일괄 지정 `changedCount 37`. 공지 "2026 SQLD 최신 출제 경향을 반영했어요"를 "중요"로 등록하면서 개념형은 실행이 아니라 근거 확인으로 검증됐으므로 문구를 "실행하거나 근거를 확인해"로 고침.

## 근본 원인 (확정)
해당 없음 (기능 추가).

## 재발 방지
- 경향 문구는 JSON을 고쳐 배포해야 바뀐다(관리자 편집 화면 제외).
- 관리자 목록 필터·상세 토글, 웹 하단 메뉴 탭 추가는 하지 않았다.

## 교훈
(원본에 없음, 볼트 정리) 공지 문구는 실제 검증 방식과 맞는지(실행 검증 vs 근거 확인) 등록 전에 대조한다.
