---
type: cluster
topic: dev-workflow
created: 2026-10-29
members: 60
status: active
related: []
---

# 클러스터: dev-workflow

## 이 주제는
개발 도구·projectops·테스트 정책·문서·API 계약

## 현재 상태 요약
(2026-10-29, 자동 생성) 활성 결정 24개, 열린 이슈 1개. 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0010-spring-multimodule-layering]] — Spring 서버는 `PQL-Common` → `PQL-Domain-*` → `PQL-Application` → `PQL-Web` 단방향 멀티모듈
- [[DEC-0011-code-freeze-tunables-via-admin]] — 코드 프리즈 이후 모든 가변 설정·콘텐츠 변경은 DB/관리자 UI(`app_setting`) 경유
- [[DEC-0013-single-custom-exception-error-code]] — 도메인별 예외 클래스 없이 전역 `CustomException` 1개 + 중앙 `ErrorCode` enum
- [[DEC-0015-zero-business-logic-in-frontend]] — 프론트 비즈니스 로직 제로 원칙 — 계산·판정은 전부 백엔드, 프론트는 응답을 그대로 렌더링
- [[DEC-0027-readme-hide-internal-stack]] — 외부 공개 README에는 테스트·개발 스택을 노출하지 않고 상위 개념으로 표기 (MariaDB → Oracle DB, Gemini → AI Agent, bge-m3 → Gemma Embedding)
- [[DEC-0031-frontend-follows-backend-spec-only]] — 프론트는 백엔드(Spring) API 스펙만 따르고, AI 서버 snake_case → camelCase 변환은 백엔드 프록시 책임
- [[DEC-0061-no-inline-style-rule]] — 프론트에서 인라인 `style` 속성 절대 금지 — Tailwind 유틸리티 또는 `components.css` 커스텀 클래스만
- [[DEC-0068-dev-mode-hidden-easter-egg]] — 웹 개발자 기능은 숨기고 버전 row 5회 클릭으로 탭 세션 동안만 잠금 해제, `/dev` 페이지는 route guard
- [[DEC-0072-idempotent-ddl-migrations]] — Flyway DDL 변경(ALTER·컬럼 추가/삭제/타입 변경)은 멱등하게 — 조건 확인 후 `DO $$` 블록에서 실행
- [[DEC-0079-gstack-and-browse-only-rule]] — AI 워크플로우는 gstack 슬래시 커맨드를 쓰고, 웹 브라우징은 `/browse`만 쓴다
- [[DEC-0091-delete-legacy-passql-app-repo]] — 앱 코드 기준은 모노레포 `app/`, 구 `passQL-app` 레포는 백업 후 삭제한다
- [[DEC-0093-untrack-ai-artifacts-and-hackathon-docs]] — AI 작업 산출물과 해커톤 기획 문서는 삭제하지 않고 `.gitignore`로 레포 추적만 해제한다
- [[DEC-0098-move-repo-to-twin-fang]] — 레포를 `Twin-Fang/passQL`로 옮기고, 구 passQL-Lab 조직은 백업 후 삭제
- [[DEC-0110-dependabot-exclude-major-updates]] — dependabot은 메이저 업데이트를 제외하고 minor·patch만 묶어서 받는다
- [[DEC-0118-single-source-commonization-rules]] — 소유자 코딩 규칙 — 단일 원본, 3개째 공통화, 직관적 이름, 규칙은 테스트로 강제
- [[DEC-0120-pq-prefix-to-passql]] — 앱 디자인 시스템 접두사 `Pq`를 `Passql...`로 풀어 쓴다
- [[DEC-0123-openapi-contract-single-source]] — 서버 `/api/**` 계약 원본은 `api-contract/openapi.json`, 웹 타입은 생성하고 테스트·CI로 강제
- [[DEC-0134-response-fields-required-nullable-marked]] — OpenAPI 응답 스키마 필드는 전부 required, null 가능 필드는 `@Schema(nullable = true)`로 표시
- [[DEC-0135-app-models-checked-not-generated]] — 앱 Dart 모델은 스펙에서 생성하지 않고 손으로 유지하되, 스펙과의 어긋남을 테스트로 검사
- [[DEC-0145-frozen-architecture-rule-ledger]] — 아키텍처 규칙은 `.rule` + 현재 위반 `.allow`로 동결하고, `.allow`에는 줄을 더하지 않는다
- [[DEC-0163-harness-oracle-xe-21c]] — 문제 검증 도구의 Oracle은 XE 21c로 고정하고, 23ai 전용 문법은 warning으로 점검한다
- [[DEC-0173-no-new-tests-in-repo]] — (사용자 지시) 테스트 코드는 저장소에 새로 올리지 않고, 변경으로 깨진 옛 테스트만 정리한다
- [[DEC-0177-rename-only-checkable-local-names]] — 약어 풀어쓰기는 컴파일러·타입 검사로 확인 가능한 지역 이름만 — 계약 이름·프레임워크 시그니처·관용 표현·관리자 정적 JS·테스트는 제외
- [[DEC-0183-keep-only-contract-architecture-tests]] — 기능 테스트는 전부 삭제하고 API 계약 테스트와 아키텍처 규칙 테스트만 남긴다

## 대체된 결정 (역사)
- 없음

## 관련 이슈
- [[ISS-0387-remove-total-question-count-compat]] (open, GitHub #632) — 카테고리별 전체 문제 수(`totalQuestionCount`) 응답 제거 — 구버전 앱 호환 처리와 최소 버전 상향
- [[ISS-0007-sqld-platform-prd-document]] (resolved, GitHub #2) — SQLD 학습 플랫폼 PRD 문서 작성 및 설계 명세화
- [[ISS-0008-react-client-initial-setup]] (resolved, GitHub #5) — React Client 초기 프로젝트 구성
- [[ISS-0010-five-day-dev-roadmap]] (resolved, GitHub #7) — passQL 5일 개발 로드맵 및 일정 관리
- [[ISS-0011-screen-spec-api-mapping]] (resolved, GitHub #8) — 전체 화면 명세 및 API 매핑
- [[ISS-0014-replace-mock-with-real-api]] (resolved, GitHub #13) — Mock 데이터 → 실제 API 연동
- [[ISS-0026-frontend-sync-api-v003]] (resolved, GitHub #35) — be-api-docs.json v0.0.3 API 스펙 변경 프론트 반영
- [[ISS-0027-readme-contest-positioning]] (resolved, GitHub #36) — README 강화 및 AI 교육 공모전 어필 포인트
- [[ISS-0030-frontend-api-field-mismatch]] (resolved, GitHub #41) — 프론트-백엔드 API 매핑 불일치 프론트 수정
- [[ISS-0115-developer-mode-easter-egg-unlock]] (resolved, GitHub #208) — 개발자 모드 Easter Egg 잠금 해제
- [[ISS-0119-flyway-migration-idempotency-rule]] (resolved, GitHub #217) — Flyway 마이그레이션 SQL 멱등성 안전장치 규칙 정립
- [[ISS-0140-e2e-db-user-data-truncate-doc]] (resolved, GitHub #259) — E2E 테스트용 DB 유저 데이터 초기화 절차가 없음
- [[ISS-0144-readme-architecture-tech-stack]] (resolved, GitHub #266) — README에 아키텍처·기술스택 문서가 없음
- [[ISS-0145-install-gstack-add-claude-md]] (resolved, GitHub #270) — AI 협업 워크플로우용 공용 슬래시 커맨드와 CLAUDE.md가 없음
- [[ISS-0168-dev-debug-hud-fab-cancelled]] (resolved, GitHub #314) — 개발자 디버그 HUD FAB 구현
- [[ISS-0173-app-api-client-server-alignment]] (resolved, GitHub #328) — 앱 API 클라이언트 서버 현행화 (memberUuid 제거, 추천 POST)
- [[ISS-0179-app-dependency-lint-build-cleanup]] (resolved, GitHub #334) — 앱 의존성, 린트, 빌드 정리
- [[ISS-0180-passql-app-monorepo-merge-docs]] (resolved, GitHub #335) — passQL-app 통합 마무리 및 API 문서 정리
- [[ISS-0181-projectops-update-workflow-cleanup]] (resolved, GitHub #336) — projectops 최신 적용 및 워크플로우 정리
- [[ISS-0183-hackathon-leftover-cleanup]] (resolved, GitHub #338) — 해커톤 잔재 정리 및 정식 서비스 기준 재정비
- [[ISS-0196-repo-transfer-to-twin-fang]] (resolved, GitHub #351) — 레포 조직 이전 — passQL-Lab → Twin-Fang
- [[ISS-0202-top-level-qa-real-account-e2e]] (resolved, GitHub #357) — 최상위 QA 통합 테스트 — 앱 실계정 E2E 전체 점검
- [[ISS-0238-server-tests-not-compiling]] (resolved, GitHub #405) — `GreetingServiceTest` 컴파일 실패로 서버 테스트가 실행되지 않음
- [[ISS-0245-projectops-update-semver-workflow-cleanup]] (resolved, GitHub #417) — projectops 4.36.4 업데이트, semver 자동 승격, 워크플로우 정리
- [[ISS-0255-projectops-4-44-1-update]] (resolved, GitHub #449) — projectops 템플릿 4.40.0 → 4.44.1 업데이트
- [[ISS-0264-architecture-audit-commonization-refactor]] (resolved, GitHub #458) — 아키텍처 검수 — 같은 대상이 스택마다 사본이라 수정 누락 반복
- [[ISS-0266-server-error-code-unify-archunit]] (resolved, GitHub #460) — 서버 에러 코드가 enum 밖 문자열로 섞이고 컨트롤러가 Repository를 직접 씀
- [[ISS-0267-app-component-layer-passql-rename]] (resolved, GitHub #461) — 앱 공통 컴포넌트 우회·역방향 의존·불명확한 `Pq` 이름
- [[ISS-0295-app-docs-deps-dio-error-common]] (resolved, GitHub #489) — 앱 문서·의존성 불일치와 Dio 오류 변환 반복
- [[ISS-0299-openapi-spec-accuracy-app-contract-test]] (resolved, GitHub #493) — API 계약 단일 원본 — 스펙에 required·nullable이 없고 앱 모델은 스펙과 대조되지 않음
- [[ISS-0317-architecture-audit-freeze-rules]] (resolved, GitHub #517) — 아키텍처 감사 후속 — 동결 규칙과 스택별 상위 문제 수정
- [[ISS-0322-question-harness-restructure]] (resolved, GitHub #524) — 문제 생성 하네스 구조 개편
- [[ISS-0328-multi-device-manual-qa]] (resolved, GitHub #535) — 여러 기기·화면 크기 수동 검수 (사용자)
- [[ISS-0346-harness-env-setup-oracle-21c]] (resolved, GitHub #559) — 문제 검증 도구 환경 준비 자동화, Oracle 버전 호환 점검
- [[ISS-0391-expand-abbreviated-local-names]] (resolved, GitHub #642) — 앱·서버·웹 지역 변수에 약어 이름이 남아 있음 (계약 이름 제외)
- [[ISS-0406-delete-functional-tests-keep-contracts]] (resolved, GitHub #680) — 기능 테스트 삭제, 계약·아키텍처 규칙 테스트만 유지
