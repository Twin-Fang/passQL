# passQL 아키텍처 검수 보고서 (2026-10-15)

대상: 모노레포 전체(app · server · client · ai), main `eee18c3` 기준. 스택마다 읽기 전용 검수를 따로 돌린 뒤 결과를 합쳤다.
판단 기준은 소유자 코딩 규칙(`~/.claude/coding-conventions.md`)이다.
- 단일 원본
- 같은 것이 3개째 생기면 공통화
- 이름은 길어도 직관적으로, boolean은 `is/has/can/should`로 시작
- 계층 의존은 한 방향으로만
- 규칙은 테스트로 강제

---

## 1. 한 줄 진단

**Flutter 화면 안쪽은 공통화가 잘 돼 있다.** 토큰 밖 하드코딩 색은 1곳뿐이다. Apple풍 재디자인이 한 번에 반영된 것도 이 구조 덕분이다.
**문제는 그 바깥에 몰려 있다.** 네이티브 시작 화면, 웹, 관리자 웹, 서버 에러 코드, API 타입, 설정 키, 규칙 문서는 원본 없이 사본으로 따로 관리된다. 로고 누락(#453)은 우연이 아니다. 이 구조에서는 같은 유형의 누락이 계속 생긴다.

---

## 2. 스택을 넘는 문제 (가장 시급)

| # | 문제 | 근거 | 심각도 |
|---|---|---|---|
| X1 | **지금 운영 중인 화면에 옛 흰 배경 로고가 있다** | 관리자 `templates/admin/login.html:19`, `layout.html:107`이 `static/images/logo.png`(옛 로고, 해시 0377d3)를 쓴다. 웹 `client/public/og-image.png`(SNS 공유 미리보기)도 같은 옛 로고다 | 높음 |
| X2 | 로고 원본이 없고 사본만 4벌 이상이다 | 앱 `assets/logo.png` = 웹 `client/src/assets/logo/logo.png`(새 로고). 서버 static·OG는 옛 로고. 다크 로고는 앱에만 있다. iOS 시작 화면은 손으로 만든 PNG 6장. **Android 시작 화면에는 로고가 아예 없다** | 높음 |
| X3 | 브랜드 색 정의가 7곳 이상이고 값도 다르다 | 웹 `tokens.css`·`theme.css`(oklch로 손 변환)·안 쓰는 `design.ts`·`HeatmapCalendar.tsx`, 앱 `pq_colors.dart`, 약관 HTML 인라인 style. 웹 `#4F46E5` / 앱 `#5856D6`, 성공·오류·경고·배경 색도 모두 다르다 | 높음 |
| X4 | API 타입을 세 스택이 각자 손으로 쓴다 | 웹 `types/api.ts` 389줄, 앱 `data/models/**` freezed, AI `ai_request.py`/`ai_response.py`. OpenAPI는 서버에서 만들어지지만 타입 생성에 쓰지 않는다. 하나 있는 `app/docs/be-api-docs.json`은 경로 22개뿐인 낡은 파일이다 | 높음 |
| X5 | 에러 코드 표를 서버·앱이 따로 갖고 있고, 이미 어긋나 있다 | 서버 `GlobalExceptionHandler`가 enum에 없는 문자열 코드 8종을 낸다. 앱 `error_code.dart:52-68`은 `VALIDATION_ERROR`를 모른다. 그래서 @Valid 실패가 코드로 분류되지 않는다 | 높음 |
| X6 | 규칙 문서가 코드와 다르다 | 앱 `.claude/rules/Design.md`는 웹 문서를 그대로 복사한 것이다(해시 같음). 문서에는 `#4F46E5`, radius 12, lucide가 적혀 있지만 코드는 `#5856D6`, 16, Cupertino다. 앱 `api-guide.md`는 웹용 인증 방식(`X-Member-UUID`)을 안내한다. `server/CLAUDE.md`의 모듈 목록과 마이그레이션 이력은 멈춰 있다. **규칙을 따르면 틀린 코드가 나온다** | 높음 |
| X7 | 약관 사본이 3벌이다 | 원본은 DB(`legal` 테이블)다. 사본은 웹 대체용 `client/public/legal/*.html`과 gh-pages 정적 `terms.html`·`privacy.html`(API를 호출하지 않음). 관리자에서 약관을 고쳐도 사본 두 개는 그대로다 | 중간~높음 |
| X8 | 화면 문구와 매핑을 웹·앱이 따로 갖는다 | 준비도 문구 `readiness_card.dart:7-14`와 `readinessCopy.ts:11-36`(같은 키, 다른 문장). 토픽 아이콘·색 `topic_icons.dart`와 `topicIcons.ts` | 중간 |
| X9 | 설정·키의 원본이 둘이다 | Gemini 키: Java는 yml, Python은 DB·Redis에서 읽는다. 관리자에서 키를 바꾸면 Java 대체 경로에는 반영되지 않는다(코드로 판단했고 실행으로 확인하지는 않음). SSE 60초가 서버와 웹에 따로 있다. 운영 도메인이 웹 3곳에 하드코딩돼 있다 | 중간 |
| X10 | 버전·식별자 사본 | AI `main.py` 버전 `0.0.1`(실제 0.9.2). 번들 ID가 pbxproj 3곳·gradle 2곳·CI secret에 있다. 팀 ID가 pbxproj 3곳에 있다. version.yml 275 / pubspec +274 | 중간 |

---

## 3. 스택별 문제

### 3.1 app (Flutter)
| 문제 | 근거 | 심각도 |
|---|---|---|
| core가 presentation을 import한다(역방향) | `core/network/dio_client.dart:7,67`이 `authProvider`를 직접 호출한다 | 높음 |
| 위젯과 flow가 provider를 거치지 않고 API를 직접 부른다. 401을 삼킨다 | `similar_questions_section.dart:34-38` `catch (_)`, `ai_explain_sheet.dart:51`, `question_flow.dart:55`, `daily_set_flow.dart:53` | 중간 |
| 공통 컴포넌트를 우회한다 | `CupertinoActivityIndicator` 직접 사용 10곳(radius 제각각), 라우트 문자열 직접 사용 9곳(`AppRoutes`가 금지를 선언했는데도), 확인 창 구현 2벌(`settings_page._confirm`, `confirmChapterExit`), 상태 화면 Scaffold 2벌 | 중간 |
| 화면에 업무 로직이 있다 | `chapter_page.dart:66-133` 선택지 세트 재사용 판정 | 중간 |
| Riverpod 패턴이 섞여 있다 | StateNotifier 2개와 Notifier 4개가 섞여 있다. `riverpod_generator`는 의존성에만 있고 쓰이지 않는다. `safeCallAll` 결과를 인덱스로 캐스팅한다(`home_providers.dart:45-60`) | 중간 |
| 이름 | `final c = context.pq` 59곳. `Pq`의 뜻이 어디에도 적혀 있지 않다. `res`, `idx`, `q/e/r/m/t`. `_bottomPadding`. 파일명과 클래스명이 다르다(`pq_type.dart`에 `PqType`, `pq_metrics.dart`에 4개 클래스). `app_icon_512.png`가 실제로는 1024px | 중간 |
| 300줄 초과 | `settings_page.dart` 365(확인 창, 탈퇴 흐름, 예외 매핑, 화면), `chapter_page.dart` 355 | 중간 |
| 테스트 Fake 중복 | `_FakeAdapter` 4벌, `_FakeMemberApi` 2벌. `main_shots.dart`에 API 경로를 다시 적어 둠 | 중간 |

### 3.2 server (Spring)
| 문제 | 근거 | 심각도 |
|---|---|---|
| 컨트롤러가 Repository를 직접 쓰고 업무 로직을 수행한다 | `QuestionController.java:54,131-164`(조회, 매핑, 가상 스레드, SSE), `AdminChoiceSetController.java:33-96`, `AppInitializer.java`가 `AppSettingService`를 우회한다 | 높음 |
| 관리자 응답 형식이 제각각이다 | `AdminEmbeddingController.java:96,112`는 `Map.of("error", e.getMessage())`, `AdminSettingController.java:32`는 본문 없는 403 | 높음 |
| 같은 enum 파싱을 서로 다른 규칙으로 3곳에서 한다 | 예외를 던지는 곳, 조용히 대체하는 곳, 보호 없이 `valueOf`를 부르는 곳 | 높음 |
| 설정 키 문자열이 흩어져 있다 | `"ai.gemini_api_key"` 리터럴 3회, `sandbox.*` 키가 2곳에 따로 있다 | 높음 |
| 페이지 처리 규칙을 복사해서 쓰고, 규칙도 서로 다르다 | 범위 보정이 있는 곳 2곳, 상한만 보정하는 곳 2곳(음수 page면 예외), 200 하드코딩, 기본값 `"20"` 5곳 | 중간 |
| 미리보기 길이 상수가 곳마다 다르다 | 100자, 80자 2곳, 50자 3곳. UUID 앞 8자리 자르기 5곳 | 중간 |
| 모듈 경계 위반 | 다른 도메인 `MemberRepository`를 직접 쓴다. Common이 web·AI 라이브러리를 `api`로 전부 노출한다. Web 모듈에 서비스와 DTO가 있다. 도메인 모듈에 `@Configuration`이 있다. 패키지 규칙이 두 가지다 | 중간 |
| 같은 대상에 이름이 둘이다 | `choiceSetId`와 `choiceSetUuid`. DTO 접미사가 `Dto`, `Result`, `View`, `Item` 등으로 섞여 있다 | 중간 |
| 큰 클래스 | `ChoiceSetGenerationService` 527, `QuestionImportExportService` 470(SQL 방언 변환 포함), `QuestionGenerateService` 372(임베딩 색인 포함), `AdminQuestionController` 311(화면용과 API용 혼재) | 중간 |
| 관리자 템플릿 중복과 방치 | CDN 버전 지정이 3개 파일에 있다. `question-form.html`은 참조 0건이다. 레거시 `quiz/*`가 남아 있다 | 중간 |
| 테스트 위치와 규칙 | 하위 모듈 테스트가 Web 모듈에 의존한다. 테스트가 대상과 다른 모듈에 있다. MockMvc 테스트 0개. assert 금지 규칙이 있지만 16개 파일이 쓴다 | 중간 |

### 3.3 client (React)
| 문제 | 근거 | 심각도 |
|---|---|---|
| 토큰을 우회한 하드코딩 | hex 70건 이상(`Login.tsx` 27건 등), 임의값 클래스 `[#...]` 28건, 토큰에 없는 색 다수, 인라인 style 20건(CLAUDE.md 금지 규칙 위반) | 높음 |
| 300줄 초과 | `components.css` 926, `AnswerFeedback.tsx` 511, `QuestionDetail.tsx` 509, `Home.tsx` 436, `PracticeResult.tsx` 354, `Login.tsx` 333, `PracticeSet.tsx` 308 | 중간 |
| 구조 | `components/` 32개, `pages/` 18개가 기능별로 나뉘지 않은 평면 구조 | 낮음 |
| 이름과 잔재 | `--color-sem-*`, `qs`, `dateUtil`. 안 쓰는 `public/icons.svg`(Vite 템플릿) | 낮음 |

### 3.4 ai (FastAPI)
| 문제 | 근거 | 심각도 |
|---|---|---|
| 문서에는 핵심 기능이라고 적혀 있지만 구현되지 않았다 | `ai_service.py:54-131`의 3개 기능이 "아직 구현되지 않았습니다"를 던진다. 라우터 3개를 호출하는 곳이 없다. 문서에 있는 "Ollama fallback"도 코드에 없다 | 중간 |
| 동적 설정이 반영되지 않는다 | `redis_settings.py`의 모델 getter 3개는 호출 0건이다. 그래서 관리자 화면에서 모델을 바꿔도 반영되지 않는다 | 중간 |
| 상수 사본 | 컬렉션 이름이 `config.py:46`과 `ai_service.py:288`에 따로 있다. `EMBED_DIM = 2560`이 모델에 묶여 있어서 모델을 바꾸면 업서트가 실패한다 | 중간 |
| 큰 파일 | `ai_service.py` 519(생성, RAG 색인, 추천, 정리), `qdrant_client.py` 398, `ai_router.py` 373(같은 try/except 반복) | 낮음~중간 |

---

## 4. 리팩터링 묶음 제안 (우선순위)

각 묶음은 소유자 규칙의 "공통화 설계안 형식"으로 따로 제안한다. 형식은 반복 패턴 → 계층 → 공통 컴포넌트 → 이름 표 → 범위 → 규칙 테스트 → 문서 → 하지 않는 것 순서다. 승인을 받은 뒤 이슈를 만들고 구현한다.

| 순서 | 묶음 | 해결하는 문제 | 재발 방지 장치 |
|---|---|---|---|
| 1 | **브랜드 자산 단일 원본** — 루트 `brand/`(로고 라이트·다크, 아이콘, 색), 원본에서 앱·iOS·Android 시작 화면·웹·관리자·OG로 생성하는 스크립트 | X1, X2, X3 일부 | CI에서 사본 해시와 원본 비교 |
| 2 | **에러 코드 단일 원본** — 서버 `ErrorCode` enum만 사용, SSE 형식 통일, 관리자 응답 통일 | X5, 서버 응답 문제 | 문자열 코드를 금지하는 ArchUnit 테스트 |
| 3 | **API 계약 생성** — springdoc 스펙을 커밋하고 웹(openapi-typescript)·앱 타입 생성, 낡은 `be-api-docs.json` 정리 | X4 | 스펙 diff CI, 생성물 손 수정 금지 |
| 4 | **규칙 문서 정리** — 공용 규칙은 루트 한 곳에 두고 스택 문서에는 차이만, 값은 코드를 원본으로 | X6 | 문서에 값을 복사하지 않음 |
| 5 | **앱 공통 컴포넌트 우회 제거와 계층 정리** — 확인 창·로딩·상태 화면 공통화, `AppRoutes` 통일, 역방향 의존 제거, API 호출을 provider로, 이름 정리(`c`, `Pq` 의미) | 3.1 | Flutter 소스 스캔 규칙 테스트 |
| 6 | **서버 계층·공통화** — 컨트롤러 로직을 서비스로, `AppSettingKeys`, enum 파싱, 페이지·미리보기 공통화, 큰 서비스 분리 | 3.2, X9 | ArchUnit(컨트롤러의 Repository 의존 금지) |
| 7 | **웹 토큰 강제** — hex·인라인 style 제거, `design.ts` 삭제, 큰 페이지 분리 | 3.3 | lint로 `[#`와 인라인 style 차단 |
| 8 | **AI 정리** — 미구현 기능은 문서·라우터에서 정리하거나 구현 이슈로 분리, 설정 경로 단일화, 서비스 분리 | 3.4 | import 검사 테스트 |
| 9 | **약관 공개 URL 하나로**, 문구·토픽 매핑은 서버 응답으로 | X7, X8 | — |

---

## 5. 소유자 결정이 필요한 것
1. **앱과 웹의 브랜드 색을 하나로 맞출지.** 앱은 iOS 시스템 indigo(`#5856D6`)를 의도적으로 따르고 있다(`pq_colors.dart:3-4`). 웹은 `#4F46E5`다.
2. **약관 공개 URL을 웹 `/legal/*`과 GitHub Pages 중 어디로 할지.**
3. **`Pq` 접두사를 풀어 쓸지**(`PassqlColors` 등), 아니면 문서에 의미만 적을지.
4. **AI 미구현 기능 3개를 삭제할지, 구현 이슈로 남길지.**
5. **삭제 대상**(사용자 허락 필요): 안 쓰는 `design.ts`, `icons.svg`, `question-form.html`, 레거시 `quiz/*`, 낡은 `be-api-docs.json`, `macos/linux/windows` 템플릿.

## 6. 확인하지 못한 것
- 관리자 Thymeleaf 화면의 세부 색 사용
- Java Gemini 대체 경로가 실제로 관리자 키 변경을 반영하지 못하는지(실행 확인 안 함)
- version.yml과 pubspec 빌드 번호가 어긋나는 원인
