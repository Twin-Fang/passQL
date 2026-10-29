---
type: completion-report
id: ISS-0299
created: 2026-10-16
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0299-openapi-spec-accuracy-app-contract-test]]"
related: ["[[DEC-0134-response-fields-required-nullable-marked]]", "[[DEC-0135-app-models-checked-not-generated]]"]
source: "https://github.com/Twin-Fang/passQL/issues/493"
---

# ISS-0299 완료 리포트: 스펙 required·nullable 보강(`OpenApiSchemaContractCustomizer`)과 앱 계약 테스트

GitHub #493 리포트 댓글 기준 (PR #494, 머지 `a543776d`, 1.4.1 배포).

## 해결 방법
- 서버 `OpenApiSchemaContractCustomizer`(신규): 응답 스키마의 모든 필드를 required로 표시(서버는 null 값도 필드로 내보내기 때문). null 가능한 객체 참조는 `oneOf [참조, null]`로(springdoc이 `$ref` 옆에 `type: null`을 붙이면 의미가 깨짐). 요청 스키마(`...Request`)와 Spring 기반 스키마(`Pageable`, `SortObject`, `SseEmitter` 등)는 건드리지 않음.
- DTO 19개에 `@Schema(nullable = true)`(예: `QuestionDetail`, `SubmitResult`, `NotificationItemResponse`, `AppNoticeResponse`, `ExecuteResult`).
- `OpenApiContractTest`의 `@Import`에 커스터마이저 추가. `api-contract/openapi.json` 갱신 결과 required 98개, null 표시 50개.
- 웹: `npm run gen:api` 재생성, null 처리 4곳 보강(`src/pages/QuestionDetail.tsx`, `src/pages/Questions.tsx`, `src/components/practiceResult/PracticeQuestionResultList.tsx`).
- 앱: `app/test/architecture/server_api_schema_test.dart`(신규) — freezed 생성자를 스펙과 비교해 서버 스펙에 없는 필드, 서버가 null을 줄 수 있는데 기본값 없는 non-null, 타입 불일치를 잡음. 이름이 다른 모델은 `_specSchemaByAppClass`, 앱 전용 모델은 `_appOnlyClasses`에 이유와 함께.
- 검증: `OpenApiContractTest` 통과, 웹 tsc 0·vitest 47개·eslint 0·build 성공, 앱 analyze 문제 없음·테스트 321개 통과, PR CI 성공, 1.4.1 배포 헬스체크 200. 서버 전체에서 `ChoiceSetEntityIntegrationTest` 1건 실패(`quiz_session` 외래키, 원본: 무관해 보이나 main에서 따로 확인하지 않음).

## 근본 원인 (확정)
이슈 본문과 같음. 스펙에 required·nullable이 없어 웹이 모든 필드에 값이 있다고 믿었다.

## 재발 방지
주의(원본):
- 스펙을 바꾸면 3단계를 함께: `./gradlew :PQL-Web:test --tests '*OpenApiContractTest*' -PupdateApiContract` → 웹 `npm run gen:api` → 앱 계약 테스트 실행.
- `OpenApiContractTest`의 `@Import`에서 커스터마이저를 빼면 안 된다. 빼도 테스트는 통과하지만 스펙 파일에서 required·nullable이 조용히 사라진다.
- 새 응답 DTO의 null 가능 필드에는 `@Schema(nullable = true)`.
- 앱 계약 테스트는 CI에서 돌지 않는다(앱 CI는 `flutter analyze`만). 서버 스펙을 바꿀 때 로컬에서 앱 테스트를 돌린다.
- 한계: nullable 표시는 웹·앱 선언 합집합에서 엔티티 not null 값만 해제한 것(예: `ChoiceItem.isCorrect`는 SSE 응답에서 null). 운영 `/docs/api-docs`는 로그인이 필요해 실측하지 못함.

## 교훈
- 원본: 같은 목표를 다른 세션이 먼저 main에 넣었으면, 방식이 둘로 갈라지지 않게 자기 브랜치를 버리고 없던 부분만 main 기준으로 옮겼다.
- (원본에 없음, 볼트 정리) 웹 타입이 null 처리 누락을 못 잡으면 해당 DTO 필드에 `@Schema(nullable = true)`가 있는지부터 본다.
