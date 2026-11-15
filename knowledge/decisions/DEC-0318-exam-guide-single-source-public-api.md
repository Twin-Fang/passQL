---
type: decision
id: DEC-0318
created: 2026-11-16
reviewed: null
topics: [progress-stats, dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0521-sqld-exam-guide-and-yearly-stats]]", "[[DEC-0311-web-app-support-stopped-code-kept]]", "[[DEC-0295-seo-public-exam-info-no-hidden-text]]"]
---

# DEC-0318: SQLD 시험 소개·역대 통계는 서버 JSON 한 곳을 원본으로, 공개 API 를 앱과 소개 사이트가 함께 읽는다

## 문제 정의 (Context)
시험 소개와 연도별 통계를 앱 화면과 소개 사이트 페이지 양쪽에 보여 줘야 했다. 같은 숫자를 플랫폼마다 따로 두면 매년 갱신 때 어긋난다 (GitHub #1077, #1076).

## 결정 (Decision)
- 원본은 `server/PQL-Domain-Meta/src/main/resources/exam-guide/sqld-exam-guide.json` 하나.
- 서버가 기동 시 1회 읽고 검증(연도 누락·중복·응시자 0명이면 원인 담아 기동 실패)한 뒤, 인사이트(7년 전 대비 응시자 배수, 비교 연도 대비 합격률 증감 %p, 비교 연도)를 계산해 `GET /api/meta/exam-guide/sqld`(인증 불필요)로 내린다.
- 앱은 이 API 로 'SQLD 알아보기' 화면을, 소개 사이트는 빌드 때 같은 API 를 읽어 `sqld/stats/` 를 만든다(실패 시 빌드 중단, 옛 값 사본 없음).
- 인사이트 숫자는 문구에 하드코딩하지 않는다.

## 검토한 대안 (Alternatives)
- 앱 상수 + 사이트 파이썬 상수: 같은 숫자 사본 2곳이라 탈락.
- DB 테이블 + 관리자 입력: 연 1회 갱신에 과해서 탈락(JSON 수정 + 배포로 충분).

## 결과 (Consequences)
**긍정**
- 갱신은 JSON 한 줄 추가로 앱·사이트가 함께 바뀐다.

**부정**
- 사이트 빌드가 운영 API 에 의존한다(API 장애 시 사이트 빌드 불가).
- 시험 일정 화면의 고정 정보(`SqldExamFacts`)와 시간·문항·응시료가 겹친다(오프라인 표시용으로 유지).

## 영향 범위 (Scope)
`server/PQL-Domain-Meta`(resources, `SqldExamGuideService`), `MetaController`, `api-contract/openapi.json`, 앱 `presentation/pages/exam_guide`, `widgets/exam_guide`, 소개 사이트 `_src/site_exam_stats.py`.

## 출처 (References)
- GitHub #1077 보고서 댓글 (2026-11-16)
- [[ISS-0521-sqld-exam-guide-and-yearly-stats]]
