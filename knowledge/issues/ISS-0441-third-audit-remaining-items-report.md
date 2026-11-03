---
type: completion-report
id: ISS-0441
created: 2026-11-03
topics: [dev-workflow, design-system, admin]
status: resolved
resolves: "[[ISS-0441-third-audit-remaining-items]]"
related: ["[[ISS-0441-third-audit-remaining-items]]", "[[DEC-0237-request-body-dto-with-validation]]", "[[ISS-0440-third-architecture-audit-followup-report]]", "[[DEC-0121-unified-brand-color]]"]
source: "https://github.com/Twin-Fang/passQL/issues/791"
---

# ISS-0441 완료 리포트: 요청 DTO, 개념 결과 화면 분할, 강조색·관리자 대화창 검사

## 해결 방법
커밋 5개 (#790 위에 쌓은 브랜치).
- 서버·계약: `Map` 본문 10곳 > `@Valid` 요청 DTO([[DEC-0237-request-body-dto-with-validation]]). JSON 필드 이름 그대로. `plan` 은 도메인 `MemberPlan`(FREE, PRO)으로 계약에 `enum` 노출, `openapi.json`·웹 생성 타입 갱신. 관리자 프롬프트 테스트 `variables` 는 키가 템플릿마다 달라 `Map` 유지.
- 앱: 결과 화면 1158 > 278줄, 점수판 599 > 316줄(조각 8개). `ConceptUnitProgress` 는 `data/models/concept/` 로, "N단원" 은 `toConceptUnitLabel()`. `conceptUnitProgressProvider` 가 진행 집계, `build` 안 상태 변경 제거. 더 불러오기 4벌 > `appendNextPage()`(실패는 로그 + 오류 수집). `MemberPlanType` enum(`unknown` 은 무료 판정).
- 브랜드: `brand_color_consistency.py` 가 강조색 사본 5곳 비교, 매치 0건도 위반.
- 관리자: `confirm()` 5곳 > `AdminUi.confirmDanger`·새 `AdminUi.confirmBeforeSubmit`(폼 제출을 막고 확인 후 `requestSubmit` 으로 다시 제출).
- 웹: boolean 이름 3개 `is` 접두사, `client/CLAUDE.md` push 규칙을 루트(요청 시에만)와 일치.

응답이 달라진 곳: 공개 API 3곳 오류 코드(키 누락 `VALIDATION_ERROR`, UUID 형식 `MESSAGE_NOT_READABLE`, 타입 오류 500 > 400), 관리자 API 키 누락 시 false·null 저장 > 400.

검증: server test 55, client lint·test 8·build·gen:api 차이 없음, app analyze 0·test 98, 분할 전후 화면 렌더 4장(오답·만점 × 라이트·다크) 픽셀 동일, 관리자 확인 창 브라우저 확인, 동결 규칙 12개 위반 0.

## 근본 원인 (확정)
공통 지점과 강제 검사가 없어 화면·컨트롤러가 각자 처리했다.

## 재발 방지
- 앱 `file_size_rules_test.dart`: `app/lib` 손작성 파일 500줄 초과 금지 (예외 0)
- 동결 규칙 `server-admin-no-native-dialog` (관리자 템플릿·JS 의 `alert(`·`confirm(`, 허용 0)
- 브랜드 검사 워크플로 경로에 강조색 사본 4개 파일 추가
- `QuestionControllerRequestValidationTest` (키 누락 400)
- 남긴 것: 웹 제출 실패 정책·앱 `data/feedback`·`data/push` 직접 사용·서버 Config·enum 위치는 팀 결정 대기, 300~500줄 앱 파일, AI `get_setting`·서버 빈 스텁 삭제 여부

## 교훈
- 화면 분할 같은 구조 변경은 같은 가짜 데이터로 전후 화면을 그려 픽셀 비교하면 시뮬레이터 없이도 "그대로"를 증명할 수 있다.
- `onsubmit` 은 Promise 확인 창을 기다리지 못한다. 막고 확인 후 표시를 남겨 `requestSubmit` 으로 다시 보낸다.
