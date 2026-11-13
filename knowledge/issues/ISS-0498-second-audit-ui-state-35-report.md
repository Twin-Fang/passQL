---
type: completion-report
id: ISS-0498
created: 2026-11-12
topics: [practice, community, notification, auth-member, design-system]
status: resolved
resolves: "[[ISS-0498-second-audit-ui-state-35]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/995"
---

# ISS-0498 완료 리포트: 2차 전체 점검 UI·UX·상태 처리 정리 35건

## 해결 방법 (PR #1000)
- 의견 잠금 갱신, flutter_localizations(한국어), 세션 만료 안내, 재진입·점검 오류 시 설정 재조회, 알림함 위로 쌓기, 작성 중 이탈 확인 공통 위젯, 선택지 생성 실패 재시도, 오류 원인별 화면, Android 탭 뒤로 가기.
- 공통화: `PassqlMessageSlot`, `PassqlLoadFailureCopy`, 날짜 형식, 더 불러오기 재시도 줄.
- 서버 GreetingService 인사말 D-숫자 제거. 웹 크레딧 배지·해요체·탭 이름.

## 재발 방지
- 실기기 E2E(운영 계정)로 흐름을 직접 눌러 확인 — 코드 점검만으로는 '✨ 1'·펜 버튼 가림을 못 찾았다.

## 교훈
- 남은 결정: 문제 탭 '토픽'과 개념 탭 '단원' 용어 통일 여부(논의 기록 없음).
