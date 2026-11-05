---
type: completion-report
id: ISS-0454
created: 2026-11-05
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0454-dev-tools-situation-simulation]]"
related: ["[[DEC-0254-app-clock-single-today-source]]", "[[ISS-0449-dev-tools-store-build-guard]]"]
source: "_sources/issues/ISS-0454-dev-tools-situation-simulation-report.md"
---

# ISS-0454 완료 리포트: 개발자 도구 세 탭과 상황 흉내 7가지

GitHub #819 리포트 기준 (2026-11-05). PR #846.

## 해결 방법
- 시트를 등급·결제 / 상황 흉내 / 진단 세 탭으로 나눔. 시트가 열린 동안 플로팅 버튼 숨김.
- 시험일 흉내(D-14·D-1·당일·끝남), 날짜 넘기기(`AppClock`, [[DEC-0254-app-clock-single-today-source]]), 처음 상태 다시 보기(온보딩·권한 안내·첫 설치).
- 푸시 흉내: 실제 푸시 클라이언트를 감싸 흉내 알림을 넣음 > 실제 알림과 같은 이동 경로.
- 로그: 최근 200건 메모리 보관, 네트워크 오류 분리, 복사.
- 규칙 테스트: 새 개발 전용 파일 서버 API import 금지, 운영 코드 연결 지점 6곳 스토어 빌드 제외 확인.

## 검증
- `flutter analyze` 0건, `flutter test` 104개 통과.
- iOS 18.3 시뮬레이터: 탭 전환, D-1 반영, 통계 알림 탭 열기 > 프로필 이동, 시트 열림 중 버튼 숨김.

## 근본 원인 (확정)
개발 강제값이 등급·한도에만 있었고 "오늘" 기준이 흩어져 있었다.

## 재발 방지
- 새 "오늘" 판정은 `AppClock`을 거쳐야 흉내가 적용된다 (앱 CLAUDE.md에 한 줄).

## 알고 남긴 것
- 시스템 알림 배너는 없음 (로컬 알림 패키지를 넣으면 스토어 빌드에 네이티브 코드가 들어가고 Firebase 알림 처리 지점과 겹칠 수 있음).
- 날짜를 넘겨도 서버 한도·오늘의 세트·히트맵 기록은 서버 날짜 그대로.
- 기기 알림 권한을 이미 정했으면 권한 안내는 다시 뜨지 않음.
- 흉내 상태는 메모리 보관, 앱을 다시 켜면 꺼짐.
