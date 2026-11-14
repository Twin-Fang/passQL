---
type: decision
id: DEC-0314
created: 2026-11-14
reviewed: null
topics: [practice, billing, ads, store-release]
status: active
supersedes: DEC-0290
superseded_by: null
related: ["[[DEC-0290-lock-screen-question-policy]]", "[[ISS-0517-lock-screen-free-pro-explanation-continue]]", "[[DEC-0282-ad-bonus-unlimited-fair-use-200]]"]
---

# DEC-0314: 잠금화면 문제는 무료도 이유를 보고 이어 풀며(크레딧), PRO 안내는 해설 한 곳만 짧게, 선택지 방식은 앱 설정 하나를 따른다

## 문제 정의 (Context)
잠금화면 해설이 무료·PRO 구분 없이 한 줄뿐이었고, 무료는 한 문제만 풀고 끝났으며, 잠금화면 전용 선택지 방식으로 무료도 AI 새 보기를 쓸 수 있었다(GitHub #1068). 사용자: "free는 이유를 알려줘야 되고 pro는 자세히", "계속 풀고 싶은 사람도 있잖아", "너무 결제해라 밝히는 게 아니라 기본적인 기능 주면서 흘러가는 flow".

## 결정 (Decision)
- [[DEC-0290-lock-screen-question-policy]] 의 정책(Android만, 무료도 앱과 같은 하루 크레딧, 크레딧 0 소진 화면, 광고·결제는 잠금 풀고 앱에서, 강제 없음, 간격·종류 선택지, 유도 규칙)은 그대로 이어받는다. 아래만 바꾼다.
- **이어 풀기:** "한 문제 더"는 무료·PRO 공통. 무료는 문제마다 크레딧을 쓰고 0 이면 소진 화면, PRO 는 공정 상한까지.
- **해설:** 앱 AI 해설과 같은 규칙. 무료는 판정과 정답 해설(이유)까지, 상세 해설은 짧게 흐린 맛보기와 PRO 버튼 하나. PRO 는 상세 해설 전체.
- **PRO 안내 한 곳:** 잠금화면에서는 흐린 실행 결과 표를 보이지 않는다(무료 실행 결과 잠금은 그대로, 안내는 해설 쪽만).
- **선택지 방식:** 잠금화면 전용 설정을 없애고 앱 "새 보기로 풀기"(PRO)를 따른다. 무료는 기본 보기.
- **켜기 전 고르기:** 간격·문제 종류는 켜기 화면에서 먼저 고른다.
- **삼성 절전 예외:** 앱이 확인할 수 없으므로 사용자가 "추가했어요"를 누를 때만 끝난 것으로 본다.
- **보조 기능:** 낙서, 토론(앱 의견 목록으로), 신고를 잠금화면에도 둔다.

## 검토한 대안 (Alternatives)
- 무료 흐린 상세 해설을 앱처럼 전체 길이로 보이기: 화면 두 장 넘게 흐린 영역과 PRO 버튼 두 개가 이어져 "결제 유도가 과하다"는 방향과 맞지 않아 버림.
- PRO 는 잠금화면에서 요약만, 자세한 해설은 앱으로 이동: 논의 기록 없음(사용자 질문 전 다음 메시지로 진행).

## 결과 (Consequences)
**긍정**
- 무료도 학습 흐름이 끊기지 않고, 크레딧 소진 시점에 자연스럽게 광고·PRO 로 이어진다.
- 무료/PRO 경계가 앱과 잠금화면에서 같다.

**부정 / 조건**
- 무료 회원의 잠금화면 크레딧 소모가 빨라질 수 있다.
- PRO 계정 화면과 삼성 절전 예외 목록 직접 열기는 실기기 확인 전(2026-11-14).

## 영향 범위 (Scope)
앱 `lock_screen_page.dart`, `lock_screen_question_view.dart`, `lock_screen_question_actions.dart`, `lock_screen_question_providers.dart`, `lock_screen_permission_page.dart`, `lock_screen_option_rows.dart`, `settings_providers.dart`(`isFreshChoiceModeEffective`), `ai_explanation_*`·`pro_locked_section.dart`·`passql_locked_preview.dart`(`previewMaxHeight`), Android `LockScreenChannel.kt`.

## 출처 (References)
- GitHub #1068, PR #1069, 커밋 08fbf055
- 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1068#issuecomment-6872626996
- W4 충돌 검사: [[DEC-0290-lock-screen-question-policy]] 의 "프로는 한 문제 더"와 충돌 > 사용자 요청으로 대체(supersede). 크레딧·공정 상한은 [[DEC-0282-ad-bonus-unlimited-fair-use-200]] 그대로.
