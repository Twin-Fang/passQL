---
type: decision
id: DEC-0185
created: 2026-10-27
reviewed: null
topics: [auth-member]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0408-withdraw-confirm-phrase-input]]", "[[ISS-0408-withdraw-confirm-phrase-input-report]]"]
---

# DEC-0185: 회원 탈퇴는 고정 문구 `탈퇴하기`를 입력해야 버튼이 활성화된다 (앱·웹 공통, 공통 확인창 옵션)

## 문제 정의 (Context)
되돌릴 수 없는 회원 탈퇴가 확인창 버튼 한 번으로 진행됐다 (GitHub #685).

## 결정 (Decision)
- 앱·웹 탈퇴 확인창에 입력칸을 두고 `탈퇴하기`를 정확히 입력해야(앞뒤 공백 무시) 탈퇴 버튼이 활성화된다.
- 탈퇴 전용 화면이 아니라 공통 확인창의 `requiredText` 옵션으로 구현한다(앱 `showPassqlConfirmDialog`, 웹 `ConfirmModal`).

## 검토한 대안 (Alternatives)
- 닉네임 입력: 고정 문구를 택한 이유(리포트) — 모든 사용자에게 같은 문구라 안내가 쉽고, 닉네임을 불러올 필요가 없다.
- 탈퇴 화면 전용 구현: 공통 옵션으로 넣었다(옵션이 없으면 기존과 같아 로그아웃·이탈 확인 등은 영향 없음). 그 외 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 실수 탈퇴 방지, 같은 옵션을 다른 확인창에서 재사용 가능.

**부정**
- 앱 입력칸이 작은 화면에서 키보드에 가려지는지 미확인.

## 영향 범위 (Scope)
`app/lib/presentation/design/components/passql_dialog.dart`, `app/lib/presentation/pages/settings/settings_page.dart`, `client/src/components/ConfirmModal.tsx`, `client/src/pages/Settings.tsx`.

## 출처 (References)
- GitHub #685 이슈 본문, 리포트 댓글 「주요 구현 내용」
- [[ISS-0408-withdraw-confirm-phrase-input]]
