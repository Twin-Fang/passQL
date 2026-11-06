---
type: completion-report
id: ISS-0458
created: 2026-11-07
topics: [billing, security, ads]
status: resolved
resolves: "[[ISS-0458-server-side-free-limit-pro-gating]]"
related: ["[[DEC-0258-ai-comment-pro-only-all-forms]]", "[[ISS-0361-billing-switch-final-checks]]"]
source: "_sources/issues/ISS-0458-server-side-free-limit-pro-gating-report.md"
---

# ISS-0458 완료 리포트: 하루 한도 제출 판정, 보기 묶음 소속 검사, 목록 잠금, AI 코멘트 프로 전용, 광고 서버 확인

GitHub #860 리포트 기준 (2026-11-07). 커밋 32745077.

## 해결 방법
- 하루 한도: 열기·제출이 같은 판정(`FeatureAccessPolicy.assertWithinDailyQuestionLimit`). 열기는 자리를 맡지 않고 제출 시점 수로 다시 판정.
- 제출: 보기 묶음 문제 <-> URL 문제 다르면 400 `QUIZ_SESSION_CHOICE_SET_MISMATCH` (결제와 무관하게 항상).
- 문제 목록 API 전체 `@RequiresProFeature(TOPIC_PRACTICE)` (앱·웹은 항상 토픽과 함께 호출 > 무료 흐름 사용처 없음), 페이지 크기 최대 50 (전원).
- 무료 재제출: 보기 근거와 판정 한 줄의 이유 제외 (`ProResponseRedactor`, `buildVerdictWithoutReason`).
- AI 코멘트: 결과·통계 모두 `@RequiresProFeature(AI_COMMENT)`, 앱·웹 잠금 미리보기 ([[DEC-0258-ai-comment-pro-only-all-forms]]).
- 세션 집계: 본인 세션만 (`findTopicResultsByMemberUuidAndSessionUuid`, 항상).
- 광고 보너스: AdMob 서버 측 확인 콜백 `GET /api/ads/admob/reward-callback` (ECDSA 서명 검증, 거래 ID·보상 표식 1회), 앱은 광고마다 보상 표식을 `ServerSideVerificationOptions` 로 실음. `ads.reward.ssv_required` 기본 false (출시 앱 호환). 마이그레이션 V1_77_2.

## 검증
- 서버 테스트 74개 실패 0 (서명 판정 5, 제출 한도 3 추가), `flutter test` 107개, 웹 lint·테스트·tsc 통과.
- 실기기 광고 서버 확인·잠금 화면은 미확인 > GitHub #867.

## 근본 원인 (확정)
하루 한도와 일부 목록·근거 응답이 앱 흐름에만 의존. 서버 제출 경로에 소속·한도 판정 없음.

## 재발 방지
- 새 프로 기능은 화면 잠금(`shouldShowProUiProvider`)만으로 두지 않고 서버 판정(`@RequiresProFeature`·`FeatureAccessPolicy`·`ProResponseRedactor`)을 함께 둔다.
- 한도류 판정은 "비용이 생기는 시점"(제출)에서 한다.

## 알고 남긴 것
- 한도 1문제 전 서로 다른 새 문제 동시 제출은 둘 다 통과 가능 (잠금 없음).
- 무료 회원 고정 보기 문제 재풀이 시 해설 실패 대체 근거 카드가 빔.
- 콜백도 점검 모드 필터에 걸려 점검 중 503.
- 사람 할 일: AdMob 콘솔 콜백 URL 등록(배포 후), 새 앱 확산 뒤 `ads.reward.ssv_required` 켜기. 결제 스위치 켤 때 최소 지원 버전 상향.

## 교훈
결제 경계 점검은 "앱 화면에서 잠겼나"가 아니라 "API 를 직접 불러도 막히나"로 한다.
