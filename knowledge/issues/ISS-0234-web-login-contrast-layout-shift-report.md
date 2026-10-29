---
type: completion-report
id: ISS-0234
created: 2026-10-07
topics: [design-system, auth-member]
status: resolved
resolves: "[[ISS-0234-web-login-contrast-layout-shift]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/401"
---

# ISS-0234 완료 리포트: 약관 링크 `#6B7280`·오류 `#DC2626`, 오류 자리 확보, 제공자 표시명

GitHub #401 완료 댓글 기준 (PR #407, 운영 v0.0.247). `## 개요` 형식 리포트는 없음.

## 해결 방법
`client/src/pages/Login.tsx`: 약관 링크 `#6B7280`·오류 `#DC2626`, 약관 링크 탭 높이 44px, 오류 문구 자리를 미리 확보, 제공자 이름을 사람이 읽는 이름으로("Apple 로그인은 준비 중입니다.").

## 근본 원인 (확정)
이슈 본문의 대비·탭 영역·레이아웃·enum 표기 문제.

## 재발 방지
운영 실측: 오류 표시 시 로고 이동 0px(수정 전 약 18px), 문구 "Apple 로그인은 준비 중입니다.", 약관 링크 탭 높이 44px.

## 교훈
원본에 적혀 있지 않다.
