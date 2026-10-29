---
type: issue
id: ISS-0431
created: 2026-10-29
topics: [home, design-system, notification]
symptoms: ["알림 종 아이콘 검정", "알림 개수 배지 안 보임", "PRO 칩 안 보임", "공지 배너 마퀴", "공지 제목 잘림", "공지 배너 여백", PassqlNotificationBellButton, PassqlCountBadge, PassqlPlanChip, AppNoticeBanner, PassqlMarqueeText]
root_cause: "홈 위쪽 요소들이 앱 강조색 체계와 따로 놀았다: 종은 기본 글자색, 배지는 주황 + 검정 숫자, PRO 칩은 연한 바탕 위 accent(채움용) 글자라 대비가 낮았고, 공지 배너는 스피커·캡슐·흐르는 제목이 한 줄에 몰려 제목이 글자 중간에서 잘린 채 흘렀다"
status: resolved
resolution: "[[ISS-0431-app-home-top-bell-notice-banner-report]]"
related: ["[[ISS-0431-app-home-top-bell-notice-banner-report]]", "[[DEC-0216-count-badge-contrast-exception]]", "[[DEC-0168-text-only-color-tokens]]", "[[ISS-0430-app-bottom-tab-bar-icon-motion]]"]
source: "https://github.com/Twin-Fang/passQL/issues/756"
---

# ISS-0431: 홈 알림 아이콘 색과 공지 배너 개편

GitHub #756 (원본: 이슈 본문). #755(하단 탭 바) 작업 중 홈 위쪽을 보다가 따로 연 이슈.

## 증상
- 홈 상단 종 아이콘이 라이트에서 검은색이라 앱 분위기(인디고)와 따로 논다.
- 공지 배너: 스피커 아이콘 + '중요' 캡슐 + 흐르는 제목이 한 줄에 몰려 복잡하고, 제목이 글자 중간에서 잘린 채 흐른다.
- 작업 중 추가: 공지 배너 아래 여백이 위보다 넓다, 안 읽은 개수 배지가 잘 안 보인다, PRO 칩이 잘 안 보인다.

## 재현 조건
홈 탭 상단 바·첫 구간. 안 읽은 중요 공지와 안 읽은 알림이 있을 때.

## 조사 기록
- 2026-10-29: 공지 배너 아래 여백 = 닫기 버튼 누르는 영역(44)이 글자 묶음(38)보다 커서 위 정렬 시 남는 높이가 아래에만 붙음.
- 2026-10-29: 머리글을 위로 올리자 제목 칸이 넓어져 공지 제목이 칸 안에 들어감 > 마퀴(넘칠 때만 흐름)가 멈춤.
- 2026-10-29: PRO 칩 글자가 `accent`(채움 전용)라 연한 바탕 위 대비가 낮았다 ([[DEC-0168-text-only-color-tokens]] 위반 상태였음).

## 근본 원인
홈 위쪽 요소의 색·배치가 다른 탭의 강조색 체계와 맞지 않았고, 공지 배너는 한 줄에 요소가 몰려 있었다.
