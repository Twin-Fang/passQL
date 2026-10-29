---
type: issue
id: ISS-0260
created: 2026-10-15
topics: [design-system]
symptoms: [하단 탭바 여백 과다, PqTabBar, SafeArea, "49 + 34 = 83pt", 아이콘 떠 보임, 제스처 바]
root_cause: "#367에서 탭 글자를 숨기고 아이콘만 남겼는데 탭바 높이는 글자 있는 iOS 규격(49) + 하단 inset 전체 그대로였다"
status: resolved
resolution: "[[ISS-0260-tab-bar-bottom-padding-reduce-report]]"
related: ["[[ISS-0256-app-apple-style-redesign-dark-mode]]"]
source: "https://github.com/Twin-Fang/passQL/issues/454"
---

# ISS-0260: 하단 탭바 아래 빈 공간이 지나치게 큼

GitHub #454 (원본: 이슈 본문, 구현 보고서, 배포 댓글).

## 증상
`PqTabBar`는 iOS 규격 높이 49에 하단 안전 영역(inset)을 통째로 더한다. iPhone 16 Pro 기준 49 + 34 = 83pt. GitHub #367 결정으로 탭 글자를 숨기고 아이콘(24pt)만 남겼는데 높이가 그대로라 아이콘이 위로 떠 보이고 아래 빈 공간이 크다. Android 제스처 내비게이션도 같은 현상.

## 재현 조건
홈 인디케이터·제스처 바가 있는 기기에서 하단 탭바 표시.

## 조사 기록
- 2026-10-15: 처음에는 inset에서 14를 고정으로 빼는 방식 → Android는 inset이 작아 아이콘이 제스처 바에 붙어 보여 비율(60%) 방식으로 변경.

## 근본 원인
frontmatter `root_cause`와 같음.
