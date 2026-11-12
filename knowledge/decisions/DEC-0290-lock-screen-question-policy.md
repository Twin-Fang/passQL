---
type: decision
id: DEC-0290
created: 2026-11-12
reviewed: null
topics: [practice, billing, ads, store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0501-lock-screen-question-android]]", "[[ISS-0501-lock-screen-question-android-report]]", "[[ISS-0499-play-fgs-declaration-lock-screen]]", "[[DEC-0282-ad-bonus-unlimited-fair-use-200]]", "[[DEC-0287-credit-term-top-bar-balance]]"]
---

# DEC-0290: 잠금화면 문제(Android)는 무료도 쓰고 앱과 같은 하루 크레딧을 쓰며, 프로는 한 문제 더, 광고·결제는 잠금을 풀고 앱에서 연다

## 문제 정의 (Context)
문제를 풀려면 앱을 켜야 해서 하루 여러 번 마주칠 접점이 없었고, 무료 사용자가 프로를 체감할 입구도 앱 안에만 있었다 (GitHub #990, [[ISS-0501-lock-screen-question-android]]).

## 결정 (Decision)
- **대상:** Android만. 화면을 켜면 잠금 위 전체 화면에 SQLD 문제 1개. iOS는 오버레이 불가로 범위 밖.
- **무료도 사용:** 잠금화면 제출은 앱과 같은 하루 크레딧을 쓴다. 잠금화면 전용 몫은 없다. 출제 API는 한도를 보지 않고 상세 열기·제출이 기존 판정을 거친다.
- **프로:** 크레딧과 무관하게 "한 문제 더"로 이어 푼다(하루 공정 상한 200 안, [[DEC-0282-ad-bonus-unlimited-fair-use-200]]).
- **출제:** 객관식과 실행형 SQL 모두(운영 설정 `lockscreen.include_executable`, 앱 "객관식만" 옵션). 선택지 세트가 준비된 문제만, 안 푼 문제 우선. 무료는 SQL 실행 결과가 잠기고 "PRO로 결과 보기".
- **크레딧 0:** 그날 한 번만 소진 화면. 광고 +5(주 버튼), PRO 구매(보조 버튼).
- **광고·결제는 앱에서:** 잠금화면 위에서는 광고와 결제를 열지 않는다(Play 정책). 두 버튼 모두 잠금을 풀고 앱에서 연다.
- **강제 없음:** 닫기·잠금 해제 언제든 가능, 기능 기본 꺼짐. 권한 필수 3개(다른 앱 위에 표시, 알림, 배터리 최적화 제외)가 모두 있어야 켜지고, 삼성 절전 예외는 권장(건너뛰기 가능).
- **표시 간격·종류 선택지:** 매번/30분/1시간/3시간, 전체/객관식만. 사용자가 바꾸기 전 간격은 운영 설정 `lockscreen.default_interval_minutes`(기본 30). 전체 사용 여부는 운영 설정 `lockscreen.enabled`.
- **유도:** 몇 문제 푼 뒤 소개 시트 1회, 닫으면 7일 뒤 1번 더, 그 뒤로는 안 띄움. 홈 다음 할 일 카드.

## 검토한 대안 (Alternatives)
논의 기록 없음. (이슈 본문 「해결 방안」이 처음부터 위 정책을 제시. 설정 행 NEW 배지는 구현 뒤 제거 643361b3.)

## 결과 (Consequences)
**긍정**
- 크레딧 판정 원본이 하나라 잠금화면용 한도 로직이 따로 없다.

**부정 / 조건**
- 특수 용도 포그라운드 서비스 권한은 Play Console 신고가 필요하다. 신고 전 업로드가 거절돼 현재 배포 앱은 `LockScreenBridge.isLockScreenShipped = false`로 기능을 숨긴 상태다([[ISS-0499-play-fgs-declaration-lock-screen]], #1002 열림). 운영 app-config `isLockScreenEnabled=true`여도 앱에는 보이지 않는다.
- 실기기 검증은 아직 안 함(2026-11-12).

## 영향 범위 (Scope)
서버 `LockScreenQuestionService`, `LockScreenSettingService`, `QuestionController` `GET /api/questions/lockscreen`, `AppConfigResponse`, 관리자 운영 설정 카드. Android `lockscreen/` 패키지(서비스·활동·엔진·채널·알림·부팅 수신기), AndroidManifest. 앱 `lock_screen_bridge.dart`, `lock_screen_*` 화면·위젯·provider, 설정 행, 홈 다음 할 일.

## 출처 (References)
- GitHub #990 이슈 본문, 커밋 fe222df0·edaa820f·7113cae3·e262e3ab·643361b3·d00454c5, PR #994·#996·#1009, 배포 PR #1012
- 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/990#issuecomment-6821643312
- W4 충돌 검사: 무료 한도·크레딧 결정([[DEC-0282-ad-bonus-unlimited-fair-use-200]], [[DEC-0287-credit-term-top-bar-balance]])과 같은 크레딧·같은 공정 상한을 써서 충돌 없음.
