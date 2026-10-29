---
type: completion-report
id: ISS-0241
created: 2026-10-07
topics: [admin, design-system]
status: resolved
resolves: "[[ISS-0241-admin-mobile-horizontal-overflow]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/409"
---

# ISS-0241 완료 리포트: 헤더·액션 행 `flex-wrap`, 신고 토글 라벨 `whitespace-nowrap`

GitHub #409 완료 댓글 기준 (v0.0.248, PR #413). `## 개요` 형식 리포트는 없음.

## 해결 방법
헤더·액션 행에 `flex-wrap`, 신고 토글 라벨에 `whitespace-nowrap`.

## 근본 원인 (확정)
행 줄바꿈 미설정.

## 재발 방지
390px 폭 가로 넘침(scrollWidth − 뷰포트): 문제 관리 136 → 0, 건의사항 115 → 0, 신고 관리 32 → 0.

## 교훈
원본에 적혀 있지 않다.
