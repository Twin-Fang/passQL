---
type: completion-report
id: ISS-0521
created: 2026-11-16
topics: [progress-stats, home, ci-deploy]
status: resolved
resolves: "[[ISS-0521-sqld-exam-guide-and-yearly-stats]]"
related: ["[[DEC-0318-exam-guide-single-source-public-api]]", "[[DEC-0319-round-pass-rate-unofficial-only]]", "[[LSN-0004-app-change-release-means-ios-review]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1077#issuecomment-6896691133"
---

# ISS-0521 완료 리포트: SQLD 알아보기(시험 소개·역대 통계) 서버·소개 사이트·앱 출시

#1077·#1076 함께. 보고서 댓글(2026-11-15) + 앱 출시 반영 후속 댓글 https://github.com/Twin-Fang/passQL/issues/1077#issuecomment-6897550405 (#1076 에도 같은 후속 댓글).

## 해결 방법
- 서버: 원본 `server/PQL-Domain-Meta/src/main/resources/exam-guide/sqld-exam-guide.json`(소개, FAQ 5개, 2011~2025 PQI 연도별 통계, 56~62회 체감 난이도, 61회 26% 비공식, SQLP 비교, 출처 4개) > `SqldExamGuideService`(기동 시 로드·검증·인사이트 계산, `previousYear` 포함) > `GET /api/meta/exam-guide/sqld`(공개). PR #1097 > 배포 PR #1098([[DEC-0318-exam-guide-single-source-public-api]]).
- 소개 사이트: `_src/site_exam_stats.py` 로 `sqld/stats/`(빌드 때 API 읽기, 실패 시 빌드 중단), 합격률 FAQ 답변 수정. #1075 사이트 브랜치 기준 배포.
- 앱: `ExamGuidePage`([시험 소개 | 역대 통계]), CustomPainter 차트, 진입점 2곳(시험 일정 행, 홈 첫 방문 안내). 앱 PR #1102 > 릴리스 PR #1104(서버·앱) — Android Play 업로드, iOS 1.132.0 재제출(심사 대기 중이던 1.130.1 을 빼고 교체).
- 검증: 서버 테스트 246, 운영 API 200(insights 2025/2024/2018/11.5배/-15.61%p), 사이트 200, 앱 렌더 캡처(라이트·다크·글자 2배).

## 근본 원인 (확정)
SQLD 를 처음 접하는 사람용 시험 소개와 역대 응시자·합격률 통계가 앱·사이트에 없었다(기능 부재). 회차별 합격률은 공식 비공개라 61회 26%만 비공식 표시([[DEC-0319-round-pass-rate-unofficial-only]]).

## 재발 방지
- 서버·앱 변경이 함께면 deploy 가 스토어 제출까지 간다 — 서버만 담은 브랜치로 먼저 배포하고 앱은 출시 때 병합([[LSN-0004-app-change-release-means-ios-review]]).
- 통계 갱신은 매년 PQI 등록 후 JSON `yearlyStatistics` 한 줄 추가. 회차별 수치는 데이터자격검정센터 문의가 유일한 경로.
- 소개 사이트 브랜치는 gh-pages 에 합쳐지지 않은 채 #1057 > #1062 > #1075 > #1077 순으로 이어져 있다 — 다음 사이트 작업은 최신 사이트 브랜치 기준.
- 시험 일정 화면 `SqldExamFacts` 는 API 값과 일부 겹친다(오프라인 표시용 유지).

## 교훈
앱 실기기 확인은 로그인 필요·로컬 소셜 로그인 불가로 렌더 캡처로 대신했다. 실기기 확인 결과는 원본에 기록이 없다.
