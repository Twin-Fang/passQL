---
type: decision
id: DEC-0112
created: 2026-10-08
reviewed: null
topics: [auth-member, store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0247-web-withdrawal-app-release-banner]]", "[[ISS-0247-web-withdrawal-app-release-banner-report]]"]
---

# DEC-0112: 웹(React)·앱(Flutter) 투트랙 유지, 화면 1:1이 아니라 핵심 기능 동등성을 맞춘다

## 문제 정의 (Context)
웹에는 회원 탈퇴가 없고 앱에만 있는 등 웹·앱 기능 차이가 있었다 (GitHub #433).

## 결정 (Decision)
웹(React, Vercel)과 앱(Flutter)을 투트랙으로 유지한다. 화면 1:1이 아니라 **핵심 기능 동등성**을 맞추는 방향으로 정했다(이슈 본문). 대응표는 `docs/FEATURE-PARITY.md`에 둔다.

## 검토한 대안 (Alternatives)
- 화면 1:1 일치: 원본이 "화면 1:1이 아니라"고만 적었고 탈락 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 웹 이용자도 스스로 계정 삭제 가능 (개인정보 보호법·스토어 정책 대응, 이슈 본문 기대 효과).

**부정**
- 논의 기록 없음. (원본 주의사항: Apple 로그인은 웹에 없어 iOS Apple 가입자는 웹에 로그인할 수 없다.)

## 영향 범위 (Scope)
`client/` 설정·홈, `docs/FEATURE-PARITY.md`, 서버 `/api/meta/app-links`.

## 출처 (References)
- GitHub #433 이슈 본문 「배경」, 리포트 댓글 (2026-10-08)
