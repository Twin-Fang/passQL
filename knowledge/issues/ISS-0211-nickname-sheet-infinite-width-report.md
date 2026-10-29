---
type: completion-report
id: ISS-0211
created: 2026-10-07
topics: [auth-member, design-system]
status: resolved
resolves: "[[ISS-0211-nickname-sheet-infinite-width]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/366"
---

# ISS-0211 완료 리포트: "중복확인" 버튼에 `minimumSize: Size(88, 48)` 명시

GitHub #366 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
"중복확인" 버튼에 `minimumSize: Size(88, 48)`를 명시해 테마 값을 덮어씀.

## 근본 원인 (확정)
앱 테마 `OutlinedButton`의 `minimumSize: Size.fromHeight(44)`는 최소 폭이 무한대 → 가로 `Row` 안에서 `BoxConstraints forces an infinite width` 예외 → 시트가 그려지지 않고 모달 배경만 남음.

## 재발 방지
앱 테마를 적용한 위젯 테스트 추가 — 수정 전 코드에서 `infinite width`로 실패, 수정 후 통과. 기본 테마 테스트는 이 버그를 못 잡았다. 시뮬레이터 실계정 E2E: 시트 열림 → 입력 → 중복확인 → 저장 → 프로필 카드 반영.

## 교훈
(원본에 없음, 볼트 정리) 시트·다이얼로그가 배경만 뜨고 비어 있으면 레이아웃 예외를 의심하고 `flutter run` 콘솔을 본다. 위젯 테스트는 실제 앱 테마를 적용해야 테마 상속 버그를 잡는다.
