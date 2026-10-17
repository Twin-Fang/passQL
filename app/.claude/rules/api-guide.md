# API 연동 가이드 (Flutter 앱)

```
app ──(BACKEND_BASE_URL, Bearer JWT)──> server(Spring) ──(x-api-key)──> ai(FastAPI)
```

- 앱은 **server 하고만** 통신한다. AI 서버 직접 호출 금지.
- 엔드포인트 목록·요청/응답 형태는 이 문서에 복사하지 않는다. 원본은 코드다.
  - 엔드포인트: `lib/data/sources/*_api.dart` (Retrofit 정의, `@GET`/`@POST` 등)
  - 모델: `lib/data/models/**` (freezed + json_serializable)
  - 서버 계약 고정 테스트: `test/data/api_contract_test.dart`

## 1. 계층

```
pages·widgets·flows ──> providers(Riverpod) ──> data/sources(Retrofit 클라이언트) ──> core/network(Dio)
```

| 계층 | 위치 | 하는 일 |
|---|---|---|
| HTTP | `lib/core/network/dio_client.dart` | Dio 생성(`buildBackendDio`: baseUrl·타임아웃 상수·디버그 로그, GET 연결 실패 1회 재시도), 인증 없는 `plainDioProvider` |
| 인증 | `lib/core/auth/` | 토큰 저장, Bearer 붙이기·401 재발급(재발급 포트 `TokenReissueClient`), 세션 만료 신호 |
| 클라이언트 | `lib/data/sources/*_api.dart`, `api_providers.dart` | Retrofit 클라이언트와 그 Provider, `authApiProvider`, 인증 인터셉터를 붙인 `dioProvider` 조립 |
| 상태·업무 | `lib/presentation/providers/` | 호출·조합·캐시 무효화, 업무 규칙(`...Service`, `...Notifier`) |
| 화면 | `lib/presentation/pages`, `widgets`, `flows` | provider 를 watch/read 만 한다 |

- **화면은 API 클라이언트를 직접 부르지 않는다.** `data/sources` import 는 규칙 테스트(`test/architecture/layer_dependency_test.dart`)가 막는다.
- **core·data 는 presentation 을 모른다.** 안쪽에서 바깥에 알려야 하면 core 에 신호를 두고 바깥이 구독한다(예: `SessionExpirySignal`).
- **core 는 data 를 모른다.** core 가 data 기능이 필요하면 core 에 포트를 두고 data 가 구현한다(예: `TokenReissueClient` <- `AuthApi`, `ReportReason` <- `ReportCategory`).

## 2. 인증 (Bearer JWT)

- 로그인: 소셜 로그인(Firebase) idToken > `POST /auth/login` > access/refresh 토큰을 `TokenStore`(보안 저장소)에 저장
- 모든 요청: `AuthInterceptor` 가 `Authorization: Bearer {accessToken}` 를 붙인다. `/auth/*` 는 인증 없는 `plainDioProvider` 로 보낸다
- 401: 재발급(`POST /auth/reissue`)을 한 번만 수행하고 대기 요청이 결과를 공유, 성공하면 원래 요청 재시도
- 재발급이 401/403 으로 거부되면 세션 삭제 > `SessionExpirySignal.announceExpired()` > `AuthNotifier` 가 로그아웃 상태로 > 라우터가 로그인 화면으로
- 네트워크 끊김·5xx 로 재발급이 실패하면 로그인을 유지하고 원래 오류만 전달
- 403 `MEMBER_SUSPENDED`(이용 제한): `MemberSuspensionInterceptor` > `MemberSuspensionSignal` > `AuthNotifier` 가 세션 정리·로그아웃 > 로그인 화면이 안내 문구(`loginNoticeProvider`) 표시 (#484)

## 3. 새 엔드포인트 추가 순서

1. `lib/data/models/<도메인>/` 에 freezed 모델 추가
2. `lib/data/sources/<도메인>_api.dart` 에 Retrofit 메서드 추가 (새 클라이언트면 `api_providers.dart` 에 Provider 추가)
3. `dart run build_runner build --delete-conflicting-outputs`
4. `lib/presentation/providers/` 에 Provider 또는 Service/Notifier 추가 (화면 전용 조회는 `FutureProvider.autoDispose`)
5. 화면은 그 Provider 를 watch. 요청 형태가 중요하면 `test/data/api_contract_test.dart` 에 고정 테스트 추가

## 4. 오류 처리

- 모든 오류는 `AppException` 하나로 변환한다(`e.asAppException`). 화면은 `code`(`ErrorCode`)로 분기하고 `message` 를 그대로 보여 준다
- 서버 `errorCode` > `ErrorCode` 매핑 원본: `lib/core/error/error_code.dart` (`ErrorCodeMapper`). 서버에 새 코드가 생기면 여기 한 줄 추가. 모르는 코드는 HTTP 상태로 분류되고 원문은 `serverCode` 에 남는다
- 4xx 서버 메시지는 사용자용 한국어라 그대로 쓰고, 5xx·프록시 HTML 은 기본 문구로 바꾼다
- 화면 일부(카드·섹션)를 채우는 선택 호출은 `safeCall` — 실패하면 null 로 섹션만 숨기고, **인증 만료는 삼키지 않고 다시 던진다**
- 한 화면을 채우는 여러 호출은 `safeCallAll` + `SafeCallSlot<T>` — 타입 그대로 결과를 읽고, 전부 실패하거나 `isRequired` 호출이 실패하면 오류 화면(#375)
- `catch (_)` 로 오류를 통째로 삼키지 않는다. 401 을 삼키면 세션 만료가 화면에 드러나지 않는다

## 5. SSE (선택지 생성)

- `POST /questions/{questionUuid}/generate-choices` 를 `SseQuestionClient` 가 Dio 스트림으로 읽는다(Retrofit 미지원)
- 응답 대기는 일반 요청보다 긴 SSE 전용 값(`choiceGenerationStreamReceiveTimeout`, 서버 SSE 제한보다 길게)
- 이벤트 `status` / `complete` / `error`. 줄 파싱은 `parseSseLines`, 이벤트 변환은 `toSseEvent`
- `error` 이벤트 코드는 `errorCode` 를 우선하고, 없으면 `code` 를 쓴다
- complete/error 없이 스트림이 끝나면 재시도 가능한 오류(`STREAM_CLOSED`)로 바꿔 스피너가 남지 않게 한다

## 6. 테스트에서 서버 바꾸기

- Provider override: `aiApiProvider.overrideWithValue(가짜)` 처럼 클라이언트 Provider 를 바꾼다
- 공용 가짜: `test/helpers/fakes/` (`FakeHttpClientAdapter`, `FakeMemberApi`). 같은 가짜를 테스트마다 다시 만들지 않는다
