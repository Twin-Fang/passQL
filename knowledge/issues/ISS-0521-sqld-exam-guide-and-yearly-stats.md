---
type: issue
id: ISS-0521
created: 2026-11-16
topics: [progress-stats, home, ci-deploy]
symptoms: ["SQLD 알아보기", "시험 소개", "역대 합격률", "연도별 응시자", "합격률 통계", "exam-guide", "/api/meta/exam-guide/sqld", "sqld-exam-guide.json", "sqld/stats", "61회 26%", "회차별 합격률 비공개", "PQI 자격취득현황", "SqldExamFacts 중복"]
root_cause: "SQLD 를 모르는 사람용 시험 소개와 수험생이 궁금해하는 역대 합격률·응시자 통계를 앱 어디에서도 볼 수 없었다(기능 부재)"
status: resolved
resolution: "[[ISS-0521-sqld-exam-guide-and-yearly-stats-report]]"
related: ["[[DEC-0318-exam-guide-single-source-public-api]]", "[[DEC-0319-round-pass-rate-unofficial-only]]", "[[LSN-0004-app-change-release-means-ios-review]]", "[[DEC-0311-web-app-support-stopped-code-kept]]", "[[DEC-0295-seo-public-exam-info-no-hidden-text]]", "[[ISS-0520-sqld-round-answer-key-omr-grading]]"]
source: "_sources/issues/ISS-0521-sqld-exam-guide-and-yearly-stats.md"
---

# ISS-0521: SQLD 알아보기 — 시험 소개와 역대 응시자·합격률 통계 (앱, 소개 사이트)

GitHub #1077 (닫힘, 작업완료), 함께 처리 #1076 (닫힘). 원본: https://github.com/Twin-Fang/passQL/issues/1077 · 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1077#issuecomment-6896691133 · 서버 PR #1097 (머지) · 배포 PR #1098 · 소개 사이트 https://passql.suhsaechan.kr/sqld/stats/ (배포 완료)

## 증상
- 경쟁 학습 서비스 비교 컨설팅(2026-11-14)에서 나온 누락 기능. SQLD 가 무슨 시험인지 모르는 사람을 위한 안내와, 연도·회차별 합격률 같은 통계 자료가 앱에 없었다.
- 앱 시험 일정 화면은 고정 정보 4개(`SqldExamFacts`)만 보여 줬고, 소개 사이트 합격률 FAQ 는 "숫자를 싣지 않는다"고 답하고 있었다.

## 재현 조건
앱 홈·시험 일정 화면, 소개 사이트 SQLD 안내 페이지 어디에서든.

## 조사 기록
- 2026-11-14: 공식 통계 조사 — PQI(민간자격정보서비스)에 2011~2025 연도별 접수자·응시자·취득자·합격률(발급기관 입력값), 공공데이터포털 15148115·15062838 CSV(합격자 수, 회차 시험일). **회차별 응시자·합격률은 공식 비공개**. 커뮤니티 조사로 확정 수치는 61회 약 26%(수험생 전언) 하나 — [[DEC-0319-round-pass-rate-unofficial-only]].
- 2026-11-14: 설계(로컬 스펙 `docs/superpowers/specs/2026-11-14-sqld-exam-guide-and-stats-design.md`, 시안은 사용자 위임으로 에이전트 추천안) — [[DEC-0318-exam-guide-single-source-public-api]].
- 2026-11-15: 서버 — `PQL-Domain-Meta` resources `exam-guide/sqld-exam-guide.json`, `SqldExamGuideService`(기동 시 로드·검증·인사이트 계산), `GET /api/meta/exam-guide/sqld`. 전체 테스트 246건 통과. 리뷰 반영으로 `previousYear` 추가(연도 누락 시 "전년" 문구 오류 방지).
- 2026-11-15: 앱 — `ExamGuidePage`(시험 소개/역대 통계 세그먼트), CustomPainter 차트(막대 자람 + 합격률 선), 진입점 2곳(시험 일정 행, 홈 첫 방문 안내). 로그인 필요 + 로컬 서버 소셜 로그인 불가로 실기기 대신 실제 응답 데이터 렌더 캡처(라이트·다크·글자 2배)로 확인, 과목 막대 높이 0·인사이트 줄바꿈·큰 글자 날짜 깨짐 3건 수정.
- 2026-11-15: 배포 분리 — deploy 에 `app/` 변경이 섞이면 스토어 제출 자동 실행([[LSN-0004-app-change-release-means-ios-review]] 적용). 서버만 담은 브랜치로 PR #1097 > 배포 PR #1098, 스토어 워크플로 미실행 확인. 운영 API 200, insights 2025/2024/2018/11.5배/-15.61%p 실측.
- 2026-11-16: 소개 사이트 — 운영 사이트가 gh-pages 가 아닌 #1075 사이트 브랜치로 배포된 상태라 그 브랜치 기준으로 `sqld/stats/` 추가(빌드 때 API 읽기, 실패 시 빌드 중단). 합격률 FAQ 답변 수정. 시놀로지 배포, 200 실측, 기존 `sqld/63/` 유지 확인.
- 2026-11-15: 앱 출시 반영(후속 댓글) — 앱 PR #1102 머지 > 릴리스 PR #1104(서버·앱). Android Play 업로드, iOS 1.132.0(빌드 90690619) — 심사 대기 중이던 1.130.1 을 심사에서 빼고 1.132.0 으로 재제출(가채점 기능 포함). 스토어 '새로운 기능' 문구는 고정 문구 유지. #1077·#1076 닫힘.

## 근본 원인
기능 부재. 완료 리포트 [[ISS-0521-sqld-exam-guide-and-yearly-stats-report]]. 실기기 확인 기록은 원본에 없다.
