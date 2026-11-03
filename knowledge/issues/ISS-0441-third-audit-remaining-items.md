---
type: issue
id: ISS-0441
created: 2026-11-03
topics: [dev-workflow, design-system, admin]
symptoms: ["Map 요청 본문", "@RequestBody Map", "키 누락 NPE 500", "openapi additionalProperties", "plan 문자열 손복사", "concept_result_view.dart 1158줄", "build 안 addPostFrameCallback 상태 변경", "N단원 라벨 복사", "더 불러오기 본문 4벌", "브랜드 강조색 accent 손복사", "brand_color_consistency accent 미검사", "관리자 confirm() 사용", "client CLAUDE.md push 절대 금지 충돌"]
root_cause: "요청 DTO·집계 Provider·일치 검사 같은 공통 지점 없이 화면·컨트롤러가 각자 처리했고, 크기·강조색·관리자 기본 대화창을 막는 검사가 없어 사본과 큰 파일이 그대로 쌓였다"
status: resolved
resolution: "[[ISS-0441-third-audit-remaining-items-report]]"
related: ["[[ISS-0441-third-audit-remaining-items-report]]", "[[DEC-0237-request-body-dto-with-validation]]", "[[ISS-0440-third-architecture-audit-followup]]", "[[DEC-0121-unified-brand-color]]", "[[DEC-0145-frozen-architecture-rule-ledger]]"]
source: "https://github.com/Twin-Fang/passQL/issues/791"
---

# ISS-0441: 3차 아키텍처 감사 남은 항목 — 요청 DTO, 개념 결과 화면 분할, 브랜드 강조색 검사

GitHub #791 (원본: 이슈 본문). [[ISS-0440-third-architecture-audit-followup]] 에서 범위가 크거나 응답이 달라져 뺀 항목.

## 증상
- 서버: 공개 `/api` 3곳(`AiController` 2, `QuestionController` 1)과 관리자 7곳이 요청 본문을 `Map` 으로 받아 OpenAPI 계약이 `additionalProperties`, 키가 없으면 NPE·ClassCastException 500.
- `MemberPlanResponse.plan` 이 문자열이라 웹 `proAccess.ts`·앱 `member_plan_response.dart` 가 값을 손복사.
- 앱 `concept_result_view.dart` 1158줄(모델이 위젯 파일 안), `concept_perfect_page.dart` 599줄. 개념 진행 계산이 `concept_page`·`concept_topic_page` 의 `build` 안, 같은 `build` 에서 `addPostFrameCallback` 으로 상태 변경. "N단원" 문구 3곳.
- 앱 더 불러오기 본문 4벌(알림함·커뮤니티 피드·의견·공지).
- 브랜드 강조색 사본(앱 토큰, 웹 `tokens.css`, 관리자 `auto-notifications.html`, 푸시 `ANDROID_ACCENT_COLOR`)을 `brand_color_consistency.py` 가 검사하지 않음 (값은 같았음).
- 관리자 `confirm()` 5곳 (`server/CLAUDE.md` 금지 규칙 위반), `client/CLAUDE.md` push "절대 금지" 와 루트 "요청 시에만" 충돌.

## 재현 조건
`POST /api/questions/{uuid}/execute` 에 `{}` 를 보내면 500. 나머지는 코드 구조 점검.

## 조사 기록
- 2026-11-03: #790 브랜치 위에 작업 브랜치 생성 → 서버·계약과 앱은 병렬 에이전트, 브랜드·관리자·웹 이름은 직접 → 커밋 `3bea45f4`(서버·계약·웹) `a7aff770`(브랜드) `de261acd`(관리자) `1af4690e`(웹) `ded84184`(앱) → [[ISS-0441-third-audit-remaining-items-report]].

## 근본 원인
공통 지점(요청 DTO, 진행 집계 Provider, 더 불러오기 함수)과 이를 강제하는 검사(파일 크기, 강조색 일치, 관리자 기본 대화창)가 없어 각 화면·컨트롤러가 따로 처리했다.
