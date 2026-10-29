---
type: completion-report
id: ISS-0320
created: 2026-10-18
topics: [ads, notification, home]
status: resolved
resolves: "[[ISS-0320-ads-cards-notification-sheet-home]]"
related: ["[[DEC-0148-inline-card-ads-interstitial-cap]]", "[[DEC-0149-contextual-notification-permission-prompt]]"]
source: "https://github.com/Twin-Fang/passQL/issues/522"
---

# ISS-0320 완료 리포트: 홈·통계 인라인 광고 카드, 직접 그리는 네이티브 카드, 알림 권한 시트 시점 변경, 단어 단위 줄바꿈

GitHub #522 개요 댓글 기준 (2026-10-18).

## 해결 방법
- 하단 상시 광고는 GitHub #527의 한 줄 띠로 정리된 상태라 그대로 두고, 홈 "학습 현황" 아래·통계 맨 아래에 `AdInlineCard`(로드 전·실패면 자리 없음, 로드되면 펼침·페이드).
- 문제 탭 네이티브: SDK 템플릿 대신 앱이 그리는 팩토리 `passqlNativeCard`(Android·iOS), 왼쪽 120x120 미디어 + 제목·본문·버튼, 색·크기는 Dart 디자인 토큰. 검증기 경고 사라짐.
- 알림 권한 시트: 결과 화면을 본 뒤 탭으로 돌아올 때나 두 번째 실행부터. 닫기 X 제거, 아이콘 정렬·큰 글자 대응.
- `PassqlKeepAllText`로 한국어 단어 단위 줄바꿈. 긴 인사말은 제목을 "홈"으로 두고 본문 맨 위에 여러 줄.
- 전면 광고: 설치 후 첫 결과 2회 건너뜀, 간격 3분 → 5분, 하루 3회 유지.
- `PassqlReveal`이 애니메이션 후에도 같은 래퍼 구조를 유지하도록 수정.

## 근본 원인 (확정)
이슈 노트 참조.

## 재발 방지
- 쓰지 않는 `ad_banner_slot.dart`는 삭제 규칙상 남겨 둠(사용자 확인 대기).
- 네이티브 광고 글꼴은 시스템 글꼴, 가로로 긴 이미지는 정사각 칸에서 위아래가 빈다.
- 다크·작은 화면 실측은 사용자 기기 테스트로, 홈 상단 재설계는 GitHub #530.

## 교훈
(원본에 없음, 볼트 정리) `AdWidget` 중복 마운트 오류가 나면 광고를 감싼 애니메이션 위젯이 끝 프레임에 트리 구조를 바꾸는지 본다.
