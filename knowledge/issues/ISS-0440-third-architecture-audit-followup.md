---
type: issue
id: ISS-0440
created: 2026-11-02
topics: [dev-workflow, security]
symptoms: ["3차 아키텍처 감사", "IllegalArgumentException 원문 응답", "No enum constant 응답 노출", "Invalid UUID string 응답", "삭제된 테스트를 검사 중으로 적은 규칙 문서", "designTokens.test.ts 없음", "passql_contrast_test.dart 없음", "손복사 API 타입 src/api", "debugPrint 릴리스 로그 유실", "ai 한국어 로그", "UUID 파싱 try/catch 복사", "로그 값 정리 사본"]
root_cause: "동결 규칙 범위가 좁아(예외 원문 패턴 한 형태, 손복사 타입 paths 한 파일) 같은 문제가 옆 파일·처리기로 샜고, #680 에서 테스트를 지울 때 규칙 문서를 함께 갱신하지 않아 없는 검사를 있다고 믿게 됐다"
status: resolved
resolution: "[[ISS-0440-third-architecture-audit-followup-report]]"
related: ["[[ISS-0440-third-architecture-audit-followup-report]]", "[[DEC-0236-block-raw-exception-message-at-handler]]", "[[ISS-0433-second-architecture-audit-followup]]", "[[DEC-0224-attach-to-existing-common-points]]", "[[DEC-0145-frozen-architecture-rule-ledger]]", "[[DEC-0013-single-custom-exception-error-code]]"]
source: "https://github.com/Twin-Fang/passQL/issues/789"
---

# ISS-0440: 3차 아키텍처 감사 후속 — 예외 원문 노출 차단과 공통 지점 미사용 사본 정리

GitHub #789 (원본: 이슈 본문과 리포트 댓글). 감사 보고서 `docs/architecture/audits/2026-11-02_passQL_3차_아키텍처_감사.md`.

## 증상
2026-11-02 4개 스택 3차 점검. 10-29 지적 33개 중 22개는 고쳐졌고 동결 규칙 10개는 새 위반 0.
- 서버: `GlobalExceptionHandler` 의 `IllegalArgumentException` 처리기가 `e.getMessage()` 원문을 응답에 넣어 `No enum constant com.passql.meta.constant…`, `Invalid UUID string` 이 공개 API 로 나감. UUID try/catch 4곳·SHA-256 직접 조립·enum 직접 변환 사본.
- 규칙 문서 4곳이 #680(f07d7002)에서 삭제된 테스트를 "검사 중"으로 적음: 웹 `designTokens.test.ts`, 앱 `passql_contrast_test.dart`·`dark_smoke_test.dart`, `FakeMemberApi`, ai 엔드포인트 테스트.
- 웹: 생성 타입이 있는 API 타입 8개·enum 4개 손복사 (`src/api/auth.ts`·`reports.ts`·`legal.ts`), 동결 규칙 paths 가 `types/api.ts` 하나.
- 앱: `debugPrint` 49건이 릴리스에서 사라지고 의견 보내기 로그에도 안 남음(결제 실패 포함), 오류 보고 없이 토스트만 띄우는 catch 3곳.
- AI: 한국어 로그 31건(10-29 감사는 1건으로 셈), 같은 뜻 상수 1곳.

## 재현 조건
잘못된 enum·UUID 값을 요청에 넣으면 응답 메시지에 JDK 원문이 그대로 담김. 나머지는 코드 구조 점검.

## 조사 기록
- 2026-11-02: scan·deps·assets·rule-docs 수집 → 스택별 읽기 전용 감사 4개로 10-29 항목 재판정과 새 문제 확인 → 동작 변경 없이 공통화 가능한 것만 이번 범위, 나머지는 GitHub #791 로 분리.
- 2026-11-02: PR #790 (커밋 `5c2a1afe` 서버, `0646c352` 앱, `b5968a5e` 웹, `ab76aad6` ai) → [[ISS-0440-third-architecture-audit-followup-report]].

## 근본 원인
동결 규칙이 처음 본 형태만 잡도록 좁게 짜여 같은 원인이 다른 모양으로 남았고, 테스트 삭제와 문서 갱신이 묶여 있지 않았다.
