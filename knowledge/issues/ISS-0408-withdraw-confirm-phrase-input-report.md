---
type: completion-report
id: ISS-0408
created: 2026-10-27
topics: [auth-member]
status: resolved
resolves: "[[ISS-0408-withdraw-confirm-phrase-input]]"
related: ["[[DEC-0185-withdraw-fixed-confirm-phrase]]"]
source: "https://github.com/Twin-Fang/passQL/issues/685"
---

# ISS-0408 완료 리포트: 공통 확인창 `requiredText` 옵션으로 탈퇴 문구 입력

GitHub #685 리포트 댓글 기준.

## 해결 방법
- 앱: `passql_dialog.dart`의 `showPassqlConfirmDialog`에 `requiredText` 옵션(값을 주면 입력칸, 일치할 때만 확인 버튼 활성). `settings_page.dart` 탈퇴 확인창에 `requiredText: '탈퇴하기'`. 입력값은 `StatefulBuilder` 바깥 변수, 비활성은 `CupertinoDialogAction.onPressed`를 `null`로.
- 웹: `client/src/components/ConfirmModal.tsx`에 `requiredText`(불일치 시 `disabled`, 닫히면 입력값 비움), `Settings.tsx`에 `requiredText="탈퇴하기"`.
- 입력값 앞뒤 공백은 무시하고 비교. 옵션을 주지 않으면 기존과 같아 다른 확인창은 영향 없음.

## 근본 원인 (확정)
확인 단계가 버튼 한 번뿐이었다.

## 재발 방지
- 웹 모달이 닫힐 때 입력값을 비우는 처리를 빼면 다시 열었을 때 버튼이 바로 눌릴 수 있다.
- 앱 입력칸이 `CupertinoAlertDialog` 안이라 작은 화면 실기기에서 키보드에 가려지지 않는지 확인 필요(시뮬레이터에서 키보드가 올라오지 않음).
- 탈퇴 처리 흐름(소셜 연결 해제, 실패 처리)은 바꾸지 않음.

## 교훈
(원본에 없음, 볼트 정리) 파괴적 동작 확인을 공통 확인창의 옵션으로 넣으면 다른 화면에도 재사용할 수 있다.
