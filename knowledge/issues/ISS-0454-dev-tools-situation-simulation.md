---
type: issue
id: ISS-0454
created: 2026-11-05
topics: [dev-workflow]
symptoms: ["개발자 도구 확장", "결제 켜짐 흉내", "온보딩 다시 보기", "시험일 흉내", "날짜 넘기기", "자정 초기화 확인", "로그 보기", "푸시 알림 테스트", "권한 안내 다시 보기"]
root_cause: "개발자 도구가 등급 강제·한도 흉내·광고 도구만 있어 온보딩·D-day·자정 초기화·푸시 이동 같은 상황은 저장값을 지우거나 날짜를 기다려야 확인할 수 있었다"
status: resolved
resolution: "[[ISS-0454-dev-tools-situation-simulation-report]]"
related: ["[[ISS-0454-dev-tools-situation-simulation-report]]", "[[ISS-0444-test-build-dev-tools-overlay]]", "[[ISS-0449-dev-tools-store-build-guard]]", "[[DEC-0254-app-clock-single-today-source]]"]
source: "_sources/issues/ISS-0454-dev-tools-situation-simulation.md"
---

# ISS-0454: 개발자 도구 확장 (결제 켜짐, 온보딩, 시험일, 날짜 넘기기, 로그, 푸시, 권한 흉내)

GitHub #819 이슈 본문 기준. 외부 출처: https://github.com/Twin-Fang/passQL/issues/819 · 완료 리포트: [[ISS-0454-dev-tools-situation-simulation-report]]

## 증상
테스트 빌드 개발자 도구([[ISS-0444-test-build-dev-tools-overlay]], #809)로는 결제 켜진 무료 화면·온보딩·시험 D-day 문구·자정 초기화·실기기 로그 같은 상황을 바로 볼 수 없었다.

## 요청
화면 표시·앱 저장값만 바꾸는 상황 흉내 7가지 (서버 데이터 그대로, 운영 빌드에는 없음). 서버 전환(운영 ↔ 로컬)은 하지 않음 (사용자 결정 2026-11-04).

## 근본 원인
개발 강제값 계층이 등급·한도에만 있었고, 앱의 "오늘" 기준이 화면마다 `DateTime.now()`로 흩어져 있었다.
