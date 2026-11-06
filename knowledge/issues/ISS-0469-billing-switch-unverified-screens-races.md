---
type: issue
id: ISS-0469
created: 2026-11-07
topics: [billing, practice, ads, ops-infra]
symptoms: ["하루 한도 제출 거부 토스트만", "광고 보너스 경로 없음", "한도 1문제 동시 제출 초과", "제출 한도 잠금 없음", "무료 해설 대체 근거 카드 빔", "웹 무료 해설 null 근거 화면 깨짐", "점검 모드 AdMob 콜백 503", "점검 중 App Store 서버 알림 503", "해외 가격 하루 약 0원", "$5.99 원 환산", "iOS 27 UIScene", "ads.reward.ssv_required", DailyQuestionSubmitAdmission, SubmissionAdmissionCheck, ExternalCallbackPaths, MaintenanceModeFilter, pass_option_pricing.dart]
root_cause: "결제 스위치가 꺼져 전원이 프로라 무료 경로의 제출 거부·해설·한도 경합·외부 콜백·해외 통화가 실제 조건으로 검증되지 않았다"
status: open
resolution: null
related: ["[[DEC-0271-daily-limit-judged-in-submit-record-tx]]", "[[DEC-0272-non-krw-price-hides-won-amounts]]", "[[DEC-0273-maintenance-mode-passes-external-callbacks]]", "[[ISS-0458-server-side-free-limit-pro-gating]]", "[[ISS-0458-server-side-free-limit-pro-gating-report]]", "[[ISS-0361-billing-switch-final-checks]]", "[[ISS-0459-structured-ai-stats-analysis]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]", "[[DEC-0005-ship-with-billing-switch-off]]"]
source: "_sources/issues/ISS-0469-billing-switch-unverified-screens-races.md"
---

# ISS-0469: 결제 스위치 켜기 전 미확인 화면과 경합 점검

GitHub #867 (https://github.com/Twin-Fang/passQL/issues/867, 시험 요청). #596([[ISS-0361-billing-switch-final-checks]]), #860([[ISS-0458-server-side-free-limit-pro-gating]]), #861 의 「알고 남긴 것」을 이어받는다. 작성 시점: 수정 PR #898 main 머지, 리포트 댓글 게시(2026-11-07), 이슈는 사람 확인 항목이 남아 열림(`작업중`) — 이슈가 닫히면 완료 리포트 노트로 닫는다.

## 증상
시험 대상 (결제 스위치를 켰을 때만 드러나는 항목):
- 하루 무료 문제를 다 쓴 뒤 안내 시트 (한도 + 광고 보너스 경로).
- iOS 27 기기에서 앱 시작 직후 종료 위험 (디버그 빌드 UIScene 미적용 기록) — 출시 빌드도 해당하는지.
- 한도 1문제 남았을 때 서로 다른 문제 동시 제출 > 최대 1문제 초과 가능 (잠금 없음).
- 무료 회원이 고정 보기 세트 문제를 다시 풀 때 해설 실패 대체 근거 카드.
- 점검 모드 중 AdMob 보상 콜백 503 (점검 중 본 광고 보상 미기록).
- 광고 보너스 서버 검증: 콘솔 콜백 등록 > 새 앱 보상 기록 > `ads.reward.ssv_required` 켠 뒤 옛 앱 426 안내.

## 재현 조건
결제 켜짐 심사 계정 목록의 무료 회원으로 하루 한도 소진 > 안내 시트·광고 보너스 > 재개. iOS 27 시뮬레이터·기기에 출시 빌드 설치. 보상형 광고 시청 > 서버 콜백 기록 > 보너스 반영 (Android·iOS).

## 조사 기록
- 2026-11-07 (리포트 댓글, PR #898 머지): 실제 결함 6건 수정, 결제 스위치는 켜지 않음(지금은 전원이 프로라 운영 사용자에게 보이는 변화 없음). 앱 변경이 있어 스토어 심사 제출을 한 번으로 줄이려 #880 과 같은 배포에 묶음.
  - 한도 안내 시트 자체는 라이트·다크 정상. 결함은 **제출 단계** — 여러 문제를 열어 두고 몰아서 제출하거나 동시 제출에서 지면 토스트만 뜨고 광고 보너스·이용권으로 갈 수 없음 > 단건·챕터·랜덤 풀이 모두 사유 시트, 시트에서 보너스를 받거나 이용권을 사면 같은 답을 다시 제출.
  - 동시 제출: 하루 한도 판정을 제출 기록 트랜잭션 안, 회원 행 잠금 뒤로 — [[DEC-0271-daily-limit-judged-in-submit-record-tx]].
  - 무료 해설: 앱은 판정까지 빈 응답·폴백 없는 실패면 제출 결과로 만든 판정 한 줄 + 잠금 미리보기. **웹은 스위치를 켜면 무료 해설 화면이 깨지던 문제**(무료 응답 근거 `null` 을 바로 문자열 처리) > 받은 값을 한 곳에서 정리, 글 없는 해설 카드는 그리지 않음.
  - 점검 모드 중 외부 콜백 통과 — [[DEC-0273-maintenance-mode-passes-external-callbacks]].
  - 해외 가격 "$5.99 하루 약 0원" — [[DEC-0272-non-krw-price-hides-won-amounts]].
  - 검증: 서버 테스트 121개 실패 0, `flutter analyze` 0·`flutter test` 118개, 웹 lint·vitest 31개·`tsc` 통과, 한도 시트·한도 화면·광고 소진·판정 한 줄·달러 가격을 라이트·다크 위젯 렌더로 확인.
- 남은 사람 확인 (스위치 켜기 전):
  - 무료 테스트 계정으로 실기기 한도 소진 > 광고 > 이어 풀기.
  - 배포 후 같은 회원으로 두 문제 동시 제출 > 1건만 통과하는지.
  - 배포 후 웹 무료 회원 결과 화면.
  - iOS 27: 출시 CI 는 Xcode 26 이라 해당하지 않을 것으로 판단. #880 실기기 소셜 로그인 확인 후 머지, CI 를 Xcode 27 로 올리기 전 iOS 27 기기에서 시작 확인.
  - AdMob 서버 검증: 실광고 빌드로 Android·iOS 각각 보너스 +5 와 `ssv_transaction_id` 기록 확인. `ads.reward.ssv_required` 는 새 앱 비중이 충분하고 최소 버전을 올린 뒤 켬.
  - 스위치를 켤 때 최소 지원 버전을 이번 수정이 들어간 버전으로.
- 후속 후보: 웹은 광고가 없어 제출이 하루 한도로 거부될 때 광고 보너스 경로가 없음(이용권 안내만 할지 결정 필요). 해외 통화 구매 내역 금액이 `6 USD` 처럼 반올림돼 보임.

## 근본 원인
결제 스위치가 꺼진 동안 전원이 프로라 무료 경로(제출 거부 사유, 무료 해설 응답 형태, 한도 경합)와 외부 콜백·해외 통화 조건이 실제로 실행되지 않아 검증되지 않았다. 하루 한도 판정은 제출 기록과 다른 시점에 잠금 없이 이뤄졌고, 점검 필터는 외부 콜백을 구분하지 않았으며, 가격 표시는 원화를 전제했다.
