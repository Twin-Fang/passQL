---
type: completion-report
id: ISS-0317
created: 2026-10-17
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0317-architecture-audit-freeze-rules]]"
related: ["[[DEC-0145-frozen-architecture-rule-ledger]]"]
source: "https://github.com/Twin-Fang/passQL/issues/517"
---

# ISS-0317 완료 리포트: 동결 규칙 10개와 스택별 규칙 테스트, 기존 위반 49건 중 41건 수정

GitHub #517 보고 댓글 기준 (2026-10-17, PR #526, deploy `8c62076f`, gh-pages PR #518).

## 해결 방법
- 동결 규칙 `docs/architecture/rules/<id>.rule`, 고정된 현재 위반 `<id>.allow`. 판정은 스택별 테스트(`ai/tests/architecture/test_architecture_rules.py`, `app/test/architecture/architecture_rules_test.dart`, `client/test/architecture/architecture.rules.test.mjs`, `server/PQL-Web/src/test/java/architecture/ArchitectureRulesTest.java`).
- server: 내부 예외 메시지를 응답 detail에 붙이지 않음(관리자 DDL 검증만 원문), `/api/meta/tags`는 `ConceptTagResponse`, 데일리 챌린지 대체 출제 저장은 `DailyChallengeFallbackWriter`(REQUIRES_NEW), 벡터 색인은 `QuestionSavedEvent` AFTER_COMMIT, 샌드박스 실행은 `SandboxExecutor.runInTemporarySandbox` 한 곳, 컨트롤러 인프라 주입 3곳 서비스 경유.
- client: 손타입을 생성 타입 별칭으로, `toUserErrorMessage`, SSE 401 시 재발급 후 1회 재요청.
- app: `AdRequestPreparer`로 광고 준비 단계 통합, `TokenReissueClient`·`ReportReason` 포트, `StorageKeys`·`DevicePreferences`.
- ai: `redis.asyncio`, 공유 HTTP 클라이언트와 재시도(최대 2회), 입력 오류 400, `compare_digest`.
- 운영 실측: health 200, `/api/meta/tags` 200 `[]`, 인증 필요 API 401 고정 문구.

## 근본 원인 (확정)
원본에 적혀 있지 않다.

## 재발 방지
- `.allow`에는 줄을 더하지 않는다. 새 위반은 코드를 고쳐서 없애고, 고치면 그 줄을 지워야 테스트가 통과한다(`ledger tighten`).
- client 규칙 테스트는 `npm run build`에도 걸려 있어 위반 시 Vercel 빌드가 실패한다.
- 공통 지점 파일(`ad_request_preparer.dart`, `device_preferences.dart`)은 규칙 `exclude`로 허용 — 옮기면 `.rule`도 고친다.
- 남은 일: 웹 죽은 파일 삭제 승인, gh-pages 약관 자동 재생성 워크플로, 서버 enum String 응답의 계약 enum 전환, 준비도 문구·토픽 아이콘 매핑 두 벌.

## 교훈
(원본에 없음, 볼트 정리) 규칙 위반을 한 번에 다 고칠 수 없으면 현재 위반을 목록에 고정하고 새 위반만 테스트로 막는다.
