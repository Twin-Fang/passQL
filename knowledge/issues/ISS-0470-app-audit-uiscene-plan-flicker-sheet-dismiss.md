---
type: issue
id: ISS-0470
created: 2026-11-07
topics: [auth-member, billing, ads]
symptoms: ["iOS UIScene 미적용", UIApplicationSceneManifest, "iOS 27 SDK 앱 실행 안 됨", "네이버 로그인 복귀 URL 미호출", "새로고침 등급 깜빡임", "광고 띠 PRO 표시 사라짐", "오프라인 잠금 판정 열림", "확인 중 시트 닫힘 안내 없음", "광고 보너스 확인 중 시트 닫기", "결제 debugPrint 로그 누락", "회원 전환 이전 응답 덮어씀", "보안 저장소 읽기 오류 세션 삭제", "알림 설정 연속 변경 되돌림 경합", AppDelegate.swift, Info.plist, plan_providers.dart, pro_offer_sheet.dart, rewarded_ad_bonus_button.dart, token_store.dart]
root_cause: "iOS 앱이 UIScene 수명주기 없이 앱 대리자에만 URL 처리를 두었고, 등급 새로고침이 무효화 방식이라 값이 비었으며, 확인 중 결과를 시트 반환값으로만 받아 시트를 닫으면 결과가 사라졌다"
status: resolved
resolution: "[[ISS-0470-app-audit-uiscene-plan-flicker-sheet-dismiss-report]]"
related: ["[[ISS-0469-billing-switch-unverified-screens-races]]", "[[ISS-0467-server-audit-llm-limit-osiv-choice-set-cache]]", "[[ISS-0468-web-audit-cross-tab-reissue-logout]]"]
source: "https://github.com/Twin-Fang/passQL/issues/880"
---

# ISS-0470: 앱 전체 점검 수정: iOS UIScene 대응, 새로고침 시 등급 깜빡임, 확인 중 시트 닫힘, 결제 로그

GitHub #880 (https://github.com/Twin-Fang/passQL/issues/880). 2026-11-07 앱 전체 점검에서 원본을 열어 확인. 서버 점검 [[ISS-0467-server-audit-llm-limit-osiv-choice-set-cache]], 웹 점검 [[ISS-0468-web-audit-cross-tab-reissue-logout]]과 같은 날의 앱 쪽 점검. 원본 사본: `_sources/issues/ISS-0470-app-audit-uiscene-plan-flicker-sheet-dismiss.md`(로컬).

## 증상
- (high) iOS UIScene 미적용 (`Info.plist`에 `UIApplicationSceneManifest` 없음, URL 처리가 앱 대리자에만). iOS 27 SDK 빌드에서 앱이 실행되지 않을 위험, 네이버 로그인 복귀 URL 미호출 위험.
- (med) 통계 당겨서 새로고침이 `planProvider`를 무효화해 등급이 잠시 비고, 그동안 광고, PRO 표시, 잠금 UI가 사라졌다 나타남. 오프라인이면 잠금 판정이 "열림"으로 남음.
- (med) 광고 보너스 확인이나 결제 확인 도중 시트를 닫으면 서버에는 반영됐는데 안내가 없고, 막혔던 동작도 다시 하지 않음.
- (med) 결제, 광고 경로의 `debugPrint` 53건 때문에 릴리스와 의견 보내기 로그에서 결제 실패 원인이 빠짐.
- (low-med) 회원 전환 중 이전 회원 응답이 새 회원 상태(등급, 안 읽은 알림)를 덮을 수 있음. 보안 저장소 읽기 오류면 전부 삭제. 알림 설정 연속 변경 실패 시 되돌림 경합.
- (low) SKAdNetwork 식별자 1개뿐, 큰 파일, 없는 테스트를 가리키는 문서.

## 재현 조건
통계 탭에서 당겨서 새로고침하면 광고 띠와 PRO 표시가 잠시 사라짐. 광고 보너스 확인 중 시트를 끌어 닫으면 안내 없음.

## 조사 기록
- 2026-11-07: 앱 전체 점검(이전 감사 2026-11-02 후속)에서 발견, PR #897로 수정. 머지 조건은 소셜 로그인 4종 왕복이었고 시뮬레이터로 채운 뒤 머지.

## 근본 원인
iOS는 UIScene 수명주기 없이 앱 대리자 `open url`에만 네이버 복귀 처리를 두었다. 등급 새로고침은 무효화 방식이라 다시 받는 동안 값이 비었다. 결제와 광고 보너스 확인 결과는 시트 반환값으로만 전달돼 시트를 닫으면 사라졌다. 회원별 상태에 요청 세대 대조가 없어 늦은 응답을 걸러내지 못했다.
