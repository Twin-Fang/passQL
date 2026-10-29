---
type: completion-report
id: ISS-0362
created: 2026-10-24
topics: [design-system]
status: resolved
resolves: "[[ISS-0362-bottom-sheet-close-x-center-title]]"
related: ["[[DEC-0170-sheet-no-close-x-centered-title]]"]
source: "https://github.com/Twin-Fang/passQL/issues/601"
---

# ISS-0362 완료 리포트: 공통 시트 한 곳 수정으로 11곳 통일

GitHub #601 완료 보고 댓글(2026-10-24) 기준. `## 개요` 형식 리포트는 없음. PR #604, 앱 1.43.0.

## 해결 방법
공통 시트 `showPassqlSheet`에서 닫기 X와 `hasCloseButton` 옵션 제거, 제목 가운데 정렬. 사용처 11곳이 같은 모양.

## 근본 원인 (확정)
공통 시트 기본 머리 줄 구성.

## 재발 방지
- 검증: CI `분석과 테스트` 통과. Android 내부·alpha 업로드, iOS TestFlight 업로드(App Store 심사 제출 대기).
- 남은 확인: 실기기(에뮬레이터)에서 시트 모양 직접 확인은 못 했다.

## 교훈
(원본에 없음, 볼트 정리) 시트 모양 같은 공통 UI는 옵션으로 갈래를 두기보다 공통 컴포넌트 한 곳에서 한 모양으로 고정한다.
