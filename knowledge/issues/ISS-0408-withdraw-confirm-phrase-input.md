---
type: issue
id: ISS-0408
created: 2026-10-27
topics: [auth-member]
symptoms: ["회원 탈퇴 실수", "탈퇴 확인창 버튼 한 번", _confirmWithdraw, ConfirmModal, requiredText]
root_cause: "되돌릴 수 없는 탈퇴가 확인창 버튼 한 번으로 진행돼 실수를 막을 장치가 없었다"
status: resolved
resolution: "[[ISS-0408-withdraw-confirm-phrase-input-report]]"
related: ["[[DEC-0185-withdraw-fixed-confirm-phrase]]"]
source: "https://github.com/Twin-Fang/passQL/issues/685"
---

# ISS-0408: 탈퇴 시 확인 문구 입력 추가

GitHub #685 (원본: 이슈 본문과 댓글).

## 증상
회원 탈퇴는 확인창에서 버튼 한 번만 누르면 바로 진행된다. 계정과 개인정보가 삭제되고 되돌릴 수 없는데 실수로 눌러도 막을 장치가 없다.

## 재현 조건
앱 `settings_page.dart`(`_confirmWithdraw`) 또는 웹 `client/src/pages/Settings.tsx` 탈퇴 `ConfirmModal`.

## 조사 기록
- 2026-10-27: 앱·웹 모두 `탈퇴하기` 정확히 입력 시에만 탈퇴 버튼 활성화로 수정.

## 근본 원인
확인 단계가 버튼 한 번뿐이었다.
