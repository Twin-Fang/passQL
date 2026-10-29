---
type: issue
id: ISS-0320
created: 2026-10-17
topics: [ads, notification, home]
symptoms: [하단 상시 배너, "MediaView is too small for video", 네이티브 광고 모양 불일치, 알림 권한 시트 가입 직후, 닫기 버튼 겹침, "'겨 / 뤄요' 줄바꿈", "This AdWidget is already in the Widget tree"]
root_cause: "SDK 네이티브 템플릿의 미디어 칸이 120x120 미만이었고, 알림 권한 시트는 가입 직후 바로 떴으며, 한국어 줄바꿈이 글자 단위였다"
status: resolved
resolution: "[[ISS-0320-ads-cards-notification-sheet-home-report]]"
related: ["[[DEC-0148-inline-card-ads-interstitial-cap]]", "[[DEC-0149-contextual-notification-permission-prompt]]"]
source: "https://github.com/Twin-Fang/passQL/issues/522"
---

# ISS-0320: 하단 상시 광고 제거, 광고 카드화, 알림 권한 시트와 홈 카드 정리

GitHub #522 (원본: 이슈 본문과 댓글).

## 증상
- 홈·문제·통계 탭 아래 상시 배너가 붙어 앱이 지저분해 보인다.
- 문제 탭 네이티브 광고가 다른 카드와 모양이 다르고 AdMob 검증기 경고 "MediaView is too small for video".
- 가입 직후 알림 권한 안내 시트가 홈 위에 바로 뜬다. 닫기(X)와 "나중에" 버튼이 겹치고 아이콘 정렬이 제각각.
- 홈 "오늘의 세트" 카드 설명이 "겨 / 뤄요"처럼 단어 중간에서 줄바꿈.
- (검증 중) iOS 다크 모드 홈 인라인 광고 자리에 빨간 오류 "This AdWidget is already in the Widget tree".

## 재현 조건
iOS 18.3 시뮬레이터, 1.13.1, 운영. 가입 직후 홈 진입.

## 조사 기록
- 2026-10-17: 실측 캡처 4장.
- 2026-10-18: 개요 보고. GitHub #527(탭바 아래 띠)과 충돌해 합침.

## 근본 원인
- 네이티브: SDK 템플릿의 미디어 칸이 작고 검은 테두리 고정.
- AdWidget 중복: `PassqlReveal`이 애니메이션 끝 프레임에 래퍼 구조를 바꿔 이전 `AdWidget`이 dispose 되기 전에 같은 광고가 두 번 마운트됨.
- 나머지는 원본에 원인 서술 없이 변경만 적혀 있다.
