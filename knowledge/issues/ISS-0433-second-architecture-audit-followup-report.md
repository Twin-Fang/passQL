---
type: completion-report
id: ISS-0433
created: 2026-10-31
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0433-second-architecture-audit-followup]]"
related: ["[[DEC-0223-audit-followup-small-fixes-split-design]]", "[[DEC-0224-attach-to-existing-common-points]]", "[[ISS-0434-audit-followup-split-large-files]]"]
source: "https://github.com/Twin-Fang/passQL/issues/759#issuecomment-6502699106"
---

# ISS-0433 완료 리포트: 동작을 바꾸지 않는 작은 수정으로 오류 보고 추가와 사본 정리

GitHub #759 리포트 댓글 6502699106 기준 (2026-10-29). PR #761, 커밋 `8f91a85e`. 설계가 필요한 큰 항목은 후속 이슈로 분리 → [[DEC-0223-audit-followup-small-fixes-split-design]].

## 해결 방법
- 앱: catch 7곳에 `reportIfUnexpectedFailure` 추가(unknown·5xx가 Crashlytics에 남음). "더 불러오기" 판정을 `widgets/common/load_more_scroll_metrics.dart`의 `ScrollMetrics.isNearLoadMoreEnd` 하나로. `passql_theme.dart`에 `themeBrightness` getter, 다크 판정 8곳을 공통 판정으로. `passql_pass_ticket.dart` 투명도 숫자 7개에 상수 이름. 위젯 폴더의 계산 함수를 `core/utils/exam_dday.dart`, `core/utils/profile_pass_values.dart`로. `pro_info_sheet.dart` 주문 번호 행 `GestureDetector` → `PassqlPressable`. `app/CLAUDE.md` 구조 절에 모듈 7개 추가.
- 서버: UUID 파싱 try/catch 7곳 → `UuidUtils.parseOrEmpty`. `ClientPageSize`, `SocialProviderEndpoints`, `StoreAppIdentifier` 신규(페이지 크기 3벌, 네이버 토큰 주소 2벌, 번들 ID 2벌). `ChoiceSetGenerationService` 재시도 로그 인자 수 수정. `QuizSessionService`는 다시 던질 때 원인 예외를 넘김(응답 detail 문구는 그대로). `PushDispatchStatus.fromRequestValue`는 잘못된 값이면 `INVALID_INPUT_VALUE`. `AppSettingService`, `MonitorAlertService`는 설정값 형식 오류 시 경고 로그(값은 로그에 남기지 않음). 경위 주석 4곳 정리.
- 웹: 제출 후 히트맵·진행률 캐시 갱신을 `lib/learningRecordQueries.ts` 함수 하나와 key 상수로. `client-no-arbitrary-size-class.rule`이 소수 px를 잡도록 보완, 새로 잡힌 1건은 `--text-notice-banner` 토큰으로. `types/api.ts`의 `NotificationCategory`를 생성 타입 별칭으로. 오류를 무시하던 catch 3곳에 `console.warn`. boolean 이름 정리(`isLoggingOut`, `isSubmitting`, `isLoading` 등).
- AI 서버: `core/external_call_limits.py` 신규(LLM 호출 타임아웃 30초, 로그 길이 500). `llm_client.py`의 5xx 기준은 `core/retry.py` 상수. 한국어 로그를 영어로, 문장체 docstring 정리.
- 공통 지점은 새로 만들기보다 기존 위치에 붙였고, 호출부 사정에 따라 일부는 그대로 뒀다 → [[DEC-0224-attach-to-existing-common-points]].

검증: 서버 컴파일, `ArchitectureRulesTest` 10/10, `ArchitectureRuleTest` 6/6, `OpenApiContractTest` 2/2. 앱 `flutter analyze` 0건, `flutter test` 92개(아키텍처 31개 포함). 웹 `tsc -b`, vitest 8/8, 아키텍처 규칙 3/3. AI pytest 46개. 동결 규칙 10개 통과, 시크릿 스캔 0건. PR CI(Spring, Python AI, App, React Build Check) success.

## 근본 원인 (확정)
기존 공통 지점을 쓰지 않은 사본과 오류 보고가 빠진 catch.

## 재발 방지
리포트의 주의사항:
- 동작이 바뀐 두 곳: 앱 Pro 정보 시트 주문 번호 행을 누르면 디자인 시스템 기본 피드백(살짝 흐려지고 작아짐)이 생긴다. 서버 `QuestionService`에서 AI 추천 목록에 null 항목이 섞이면 예전에는 예외, 이제는 그 항목만 건너뛴다.
- `isNearLoadMoreEnd`의 320px 기준은 4개 목록이 함께 쓴다. 화면 하나만 다르게 하려면 값을 바꾸지 말고 인자로 받도록 확장한다.
- 후속 이슈로 넘긴 항목(설계 필요): `pro_offer_sheet.dart`(769줄)·`passql_pass_ticket.dart`(650줄) 분리, 서버 Oracle 변환 3벌 통합, 선택지 생성 재시도 루프 3벌 통합, `components.css`(1230줄) 분할 → [[ISS-0434-audit-followup-split-large-files]].
- 제품 결정이 필요한 항목(미결): 웹에서 제출에 실패하면 연습 모드는 오답으로 기록하고, 데일리·추천 모드는 안내 없이 홈으로 보낸다.

실기기 실행과 운영 배포 후 확인은 리포트 시점에 하지 않았다.

## 교훈
논의 기록 없음.
