---
type: completion-report
id: ISS-0431
created: 2026-10-29
topics: [home, design-system, notification]
status: resolved
resolves: "[[ISS-0431-app-home-top-bell-notice-banner]]"
related: ["[[DEC-0216-count-badge-contrast-exception]]", "[[DEC-0168-text-only-color-tokens]]"]
source: "https://github.com/Twin-Fang/passQL/issues/756"
---

# ISS-0431 완료 리포트: 종 강조색, 빨강 배지, PRO 칩 채움, 공지 머리글 + 항상 흐르는 제목

GitHub #756 리포트 댓글 기준 (2026-10-29), PR #758.

## 해결 방법
- 종 아이콘 `accentText`. 안 읽은 개수 배지는 새 토큰 `countBadge`(라이트 `#FF3B30`, 다크 `#FF453A`) + `onCountBadge`(흰색) — [[DEC-0216-count-badge-contrast-exception]]. 알림함 탭 배지도 같은 부품이라 함께 바뀜.
- PRO 칩 `accent` 채움 + `onAccent` 흰 글자, FREE 글자 `label`.
- 공지 배너: 머리글 줄(작은 스피커 + "중요 공지 · 어제", `formatNotificationElapsed`) + 아래 제목 한 줄. 줄을 세로 가운데로 맞춰 위아래 여백 같게.
- `PassqlMarqueeText.isAlwaysScrolling`: 켜면 폭 안에 들어가는 제목도 흐름, 두 벌 사이 간격을 칸 폭까지 늘림. 홈 공지만 켬.
- 커밋: b923dd2c, 62aa9bef, bd2e0551, 035d7517, 26edb05f.

## 근본 원인 (확정)
이슈 노트 참고. 마퀴가 멈춘 것은 "넘칠 때만 흐름" 설계 때문이었다.

## 재발 방지
- 머리글이나 아이콘을 옮겨 글자 칸 폭이 바뀌면 마퀴가 멈출 수 있다. 흐름이 필요한 자리는 `isAlwaysScrolling`.
- 아이콘 버튼(44)과 글자 묶음을 한 줄에 둘 때는 세로 가운데 정렬로 위아래 여백을 맞춘다.
- `countBadge`는 흰 숫자 대비 3.5인 의도된 예외라 글자색으로 재사용하지 않는다.

## 교훈
- 버린 안: 공지 마퀴 제거 + 제목 2줄, 공지 왼쪽 확성기 타일, 진한 빨강 배지(#C40012), 배지 바탕색 테두리, 홈 구간 제목 색 타일, 공지 여러 건 돌려 보여 주기(지금처럼 한 건씩 유지).
- 확인하지 못한 것: 라이트 모드 수정 전 화면 녹화.
