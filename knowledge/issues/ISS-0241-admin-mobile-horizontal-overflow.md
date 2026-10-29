---
type: issue
id: ISS-0241
created: 2026-10-07
topics: [admin, design-system]
symptoms: ["관리자 390px 가로 넘침", scrollWidth, "ml-auto flex", "배지 한 줄 고정", "미처리만 보기 세로로 깨짐", flex-wrap, whitespace-nowrap]
root_cause: "문제·건의사항·신고 화면의 헤더·액션 행이 줄바꿈되지 않았다"
status: resolved
resolution: "[[ISS-0241-admin-mobile-horizontal-overflow-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/409"
---

# ISS-0241: 관리자 모바일 폭에서 문제·건의사항·신고 화면 가로 넘침

GitHub #409 (원본: 이슈 본문과 완료 댓글).

## 증상
390px 폭에서 페이지가 가로로 넘친다(scrollWidth 실측).
- 문제 관리 526px — 오른쪽 액션 버튼 묶음(`ml-auto flex`)이 줄바꿈 안 됨
- 건의사항 505px — 상태 요약 배지 4개 + 새로고침 한 줄 고정
- 신고 관리 422px — 요약 배지 한 줄 고정, "미처리만 보기" 라벨이 한 글자씩 세로로 깨짐

## 재현 조건
관리자 화면을 390px 폭으로 열기.

## 조사 기록
- 2026-10-07: 해결 방안 — 해당 행에 `flex-wrap`, 라벨은 `whitespace-nowrap`.

## 근본 원인
행 레이아웃에 줄바꿈 설정이 없었다.
