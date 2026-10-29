---
type: decision
id: DEC-0153
created: 2026-10-17
reviewed: null
topics: [ads]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0324-tab-bar-native-ad-strip]]", "[[ISS-0324-tab-bar-native-ad-strip-report]]", "[[DEC-0148-inline-card-ads-interstitial-cap]]", "[[DEC-0189-home-section-layout-single-cta]]"]
---

# DEC-0153: 탭별 적응형 배너 대신 메인 탭바 아래 한 줄 네이티브 광고 띠 하나를 상시 둔다

## 문제 정의 (Context)
광고를 홈·문제·통계 탭마다 적응형 배너로 따로 붙여(GitHub #506) 배너가 탭 내용 위를 차지하고 탭을 옮길 때마다 새로 로드했다 (GitHub #527).

## 결정 (Decision)
- 알라미처럼 하단 탭바 바로 아래 얇은 한 줄 네이티브 광고 띠(AD 배지 + 광고 문구 + 바로가기)를 메인 탭 전체에 상시 둔다. 탭 전환 시 다시 로드하지 않는다.
- 높이 약 44dp, 라이트·다크 색. 로드 실패·미설정이면 자리를 접는다.
- 풀이·결과·로그인 등 탭 밖 화면에는 띠가 없다(기존 광고 금지 규칙 유지).
- 탭별 적응형 배너 3곳을 제거한다.

## 검토한 대안 (Alternatives)
- 탭별 적응형 배너(GitHub #506 방식): 탭 내용을 차지하고 탭 전환마다 재로드해서 바꿨다(이슈 본문).
- 그 밖의 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 띠 하나를 셸 생존 동안 한 번만 로드한다.

**부정**
- factoryId·customOptions 키를 Dart·Kotlin·Swift 세 곳에서 맞춰야 한다.

## 영향 범위 (Scope)
앱 `AdPlacement`, `app_shell.dart`, 네이티브 팩토리(Android·iOS), 광고 위치 규칙 테스트, `.env`·`ENV_FILE`.

## 출처 (References)
- GitHub #527 이슈 본문 (2026-10-17), 보고 댓글 (2026-10-18)
- [[ISS-0324-tab-bar-native-ad-strip]]
