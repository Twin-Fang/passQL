---
type: issue
id: ISS-0361
created: 2026-10-23
topics: [billing, store-release]
symptoms: [billing.android.enabled, isAndroidBillingEnabled, "결제 스위치", pro_pass_3m, pro_pass_1m, "최소 지원 버전", "실구매 점검", billing.preview_member_uuids, PRO_REQUIRED, "심사 계정", "이용권 연장", activeProExpiresAt, "승객 칸 빔", "실행 버튼 잠금"]
root_cause: ""
status: open
resolution: null
related: ["[[DEC-0003-one-and-three-month-pass]]", "[[DEC-0005-ship-with-billing-switch-off]]", "[[DEC-0007-hold-pass-review-until-switch-on]]"]
source: "https://github.com/Twin-Fang/passQL/issues/596"
---

# ISS-0361: 결제 스위치 켜기 전 최종 점검 (실구매·심사·최소 버전)

GitHub #596 (원본: 이슈 본문과 댓글). 열린 이슈. 원본의 심사 계정 회원 식별값은 옮기지 않았다.

## 증상
- 무료/프로 결제는 서버·Android(GitHub #576·#591)·iOS·웹(GitHub #578)까지 구현·배포됐지만 결제 스위치 `billing.android.enabled`는 꺼져 있다(켜면 iOS·Android·웹 전원에 잠금 적용) — [[DEC-0005-ship-with-billing-switch-off]].
- 실제 결제는 스위치를 켜야만 끝까지 확인할 수 있다.

## 재현 조건
해당 없음(점검 이슈).

## 조사 기록
- 2026-10-23 점검 목록: iOS 1.40.0 + 이용권 2개(`pro_pass_3m`·`pro_pass_1m`, [[DEC-0003-one-and-three-month-pass]]) Apple 심사, Play 프로덕션 액세스(GitHub #568) 후 Android production 출시, 최소 지원 버전 상향(출시 앱 1.36·1.37은 잠금 응답을 오류로 처리), Android 라이선스 테스터·iOS 샌드박스 실구매(3개월 신규 > 1개월 연장 > 환불 후 재계산·REFUND 알림), App Store 서버 알림 수신, 스토어 설명·README 무료/프로 구분, 스위치 이름(`billing.android.enabled`·`isAndroidBillingEnabled`가 이제 전 플랫폼 스위치) 변경 검토, 스위치 켜기 후 운영 실측.
- 2026-10-23 GitHub #578에서 이관: 이용권 2개("개발자가 취소함")를 스위치를 켤 iOS 버전과 함께 심사 제출 — [[DEC-0007-hold-pass-review-until-switch-on]]. 심사자가 구매 화면에 도달하려면 심사 기간에 스위치를 켜거나 심사용 계정 우회가 필요(결정 필요로 적힘).
- 2026-10-23 진행(PR #597, 배포 #598): 관리자 설정 `billing.preview_member_uuids`(V1_41_0 운영 적용) — 목록 회원만 결제 켜짐(`FeatureAccessPolicy.isBillingEnabledFor`), 앱은 등급 응답의 `isBillingEnabled`를 따름. 네이버 테스트 계정으로 운영 가입한 심사 계정을 목록에 등록, 웹에서 `FREE` 칩 확인(일반 회원은 결제 꺼짐 그대로). iOS 1.41.0(빌드 88676698) + 이용권 2개 심사 대기(17:41), 1.40.0 단독 제출은 취소. Android 1.41.0 internal·alpha.
  - 원본 메모: "결제 스위치가 꺼진 채 상품을 제출하면 심사자가 구매 화면에 도달할 수 없어 반려 위험 > 회원별 미리 켜기로 해결".
  - (볼트 정리) 이 진행은 [[DEC-0007-hold-pass-review-until-switch-on]]의 "스위치를 켤 버전과 함께 제출"을 전체 스위치가 아니라 심사 계정 단위 켜기로 충족한 것이다. 원본은 DEC-0007을 바꾼다고 적지 않았다.
- 2026-10-23 웹 수정(PR #599, 배포 #600): `/progress/wrong-questions`는 프로 기능(`TOPIC_ANALYSIS`)이라 결제 켜짐 무료 회원에게 403 `PRO_REQUIRED` → 웹이 일반 오류로 표시하던 것을 잠금 미리보기 + "앱에서 이용권으로 열기"로. vitest 125/125.
- 남은 일(전부 외부 결과 대기): Apple 심사 결과, 심사 통과 뒤 실구매·환불 알림, Play 프로덕션 액세스 > Android 실구매, 최소 지원 버전 1.41.0 상향 > 스위치 켜기 > 심사 계정 목록 비우기 > 스토어 문구·README, 스위치 이름 정리.
- 2026-11-04 화면 검증(iOS 18.3 시뮬레이터·Android 에뮬레이터·운영 웹, 가짜 API·가짜 결제 포트): 결론은 "지금 품질로는 스위치를 켜지 않는다". 고칠 것 4건 — 이용권 시트 미리보기 탑승권 `승객` 칸이 처음 열 때 빔(`settingsDataProvider`를 `valueOrNull`로 한 번만 읽음), 프로 회원이 이용권을 연장할 진입점이 없음, 무료 회원 `직접 실행해보기 > 실행`이 열려 있다가 누른 뒤에야 잠금이 두 번 보임, 프로필 영역별 정답률 잠긴 행을 눌러도 반응 없음. 사소: 1개월권 권유 문구 `씩)`만 줄바꿈. 못 본 것: 하루 한도 소진 뒤 사유 시트, iOS 27(Xcode 27 빌드 디버그 앱이 UIScene 미적용으로 즉시 종료 `UIApplicationEvaluateRuntimeIssueForNoSceneLifecycleAdoption`), 웹 Android 배지 "출시 준비 중".
- 2026-11-05 앱 수정(브랜치 커밋 c2fe8b24·d27f20d6): 이용권 시트가 닉네임·시험 일정을 본문에서 `ref.watch`로 읽어 늦게 도착해도 채움. 이용권 정보 시트에 `이용권 연장하기` 버튼(정보 시트를 결과 `extend`로 닫고 이용권 시트를 새로 엶, 시트 한 장 규칙 유지). 프로 이용 중(`proExpiresAt`가 `AppClock.now()` 뒤)이면 시트가 연장 모드 — 제목 "N일 남은 이용권, 이어서 연장해요", 무료 최대치 줄·「PRO로 달라지는 점」 숨김, 무료 > 프로 탑승권 연출 생략, 완료 문구 "이용권을 연장했어요". #816의 프로필 「이어서 연장」 카드([[DEC-0243-profile-top-card-style-a]])도 같은 시트라 연장 모드로 열림. 결제 켜짐 무료 회원의 SQL 실행 버튼은 자물쇠 아이콘 > 서버 요청 없이 이용권 시트(강조 혜택: SQL 직접 실행). 잠긴 영역별 정답률 행 전체를 눌러 시트(강조: 통계). 권유 문구 `PassqlKeepAllText`. 서버는 이미 이용 중 재구매를 현재 만료일 뒤에 이어 붙여(`PassExpiryCalculator`) 앱만 고침. analyze 통과, 테스트 106개 통과. 실제 연장 결제(샌드박스·라이선스 테스터)는 아직 안 봄 — Play 소모성(`autoConsume:false`, 서버 소비)·iOS 비갱신 구독에서 이용 중 재구매가 막히지 않는지 함께 확인 필요.
- 2026-11-05 앱 빌드 중 CI 문제: `ubuntu-latest`가 ubuntu-26.04가 되며 `ruby/setup-ruby` 3.4.1 설치 실패 > Android 빌드·Play 배포 잡을 `ubuntu-24.04`로 고정(GitHub #826, PR #827). iOS 테스트 빌드는 macOS 러너를 15분간 못 받아 취소된 적 있음(코드 무관).

## 근본 원인
해당 없음(진행 중인 점검).
