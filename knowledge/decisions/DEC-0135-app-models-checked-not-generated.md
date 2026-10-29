---
type: decision
id: DEC-0135
created: 2026-10-16
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0299-openapi-spec-accuracy-app-contract-test]]", "[[DEC-0134-response-fields-required-nullable-marked]]"]
---

# DEC-0135: 앱 Dart 모델은 스펙에서 생성하지 않고 손으로 유지하되, 스펙과의 어긋남을 테스트로 검사

## 문제 정의 (Context)
API 계약을 OpenAPI 스펙 단일 원본으로 맞추면서 앱 freezed 모델 36개를 어떻게 다룰지 정해야 했다. 이슈 본문은 "소유자 결정: 웹·앱 모두 생성"이었다 (GitHub #493).

## 결정 (Decision)
- 앱 모델은 생성하지 않고 그대로 두며, `app/test/architecture/server_api_schema_test.dart`가 서버 스펙과 대조해 세 가지를 실패로 잡는다: 앱이 읽는 필드가 스펙에 없음, 서버가 null을 줄 수 있는데 앱은 기본값 없는 non-null, 타입 불일치.
- 서버 필드가 새로 생기는 것은 앱에 영향이 없어 잡지 않는다.

## 검토한 대안 (Alternatives)
- 스펙에서 앱 모델 생성(소유자 결정): 버림. 원본 이유 — 앱 모델에는 스펙에 없는 방어 장치(`@Default`: 서버가 필드를 빠뜨려도 앱이 죽지 않게 하는 기본값, `unknownEnumValue`: 새 enum 값에도 구버전 앱이 죽지 않게 함, 앱 전용 값)가 있어, 생성하면 이 보호가 사라지고 스토어에 배포된 구버전 앱이 서버 변경에 그대로 노출된다.
- 원본: 앱까지 생성하려면 `@Default`와 `unknownEnumValue`를 스펙 확장 속성(`x-...`)으로 서버에 표시하는 방안이 필요하고 별도 이슈로 진행해야 한다. 소유자 결정과 다른 선택이라 설계 댓글에 "(확인 필요)"로 적혔고, 이후 확인 결과는 원본에 적혀 있지 않다(최종 리포트는 이 방식으로 머지).

## 결과 (Consequences)
**긍정**
- 구버전 앱 보호 장치를 유지하면서 서버 필드 삭제·null 변경·타입 변경을 잡는다(필드를 일부러 추가해 테스트가 실패하는 것 확인).

**부정**
- 앱 계약 테스트는 CI에서 돌지 않는다(앱 CI는 `flutter analyze`만). 서버 스펙 변경 시 로컬 실행이 필요하다.

## 영향 범위 (Scope)
`app/lib/data/models`, `app/test/architecture/server_api_schema_test.dart`(`_specSchemaByAppClass`, `_appOnlyClasses`). 기존 결정 DEC-0123은 앱 Dart 모델 생성을 범위 밖으로 두었다.

## 출처 (References)
- GitHub #493 설계·진행 댓글 "앱을 생성하지 않고 검사로 바꾼 이유 (확인 필요)", 리포트 댓글 "왜 앱은 생성이 아니라 검사인가"
- [[ISS-0299-openapi-spec-accuracy-app-contract-test]]
