---
type: issue
id: ISS-0359
created: 2026-10-22
topics: [auth-member]
symptoms: ["닉네임 랜덤 재생성", "새로고침 아이콘", "3일 쿨다운 우회", NICKNAME_COOLDOWN, nicknameChangedAt, regenerateNickname, "확인 없이 즉시 변경", ProfileCard]
root_cause: "랜덤 재생성이 쿨다운을 확인하지 않고 변경 시각(nicknameChangedAt)도 갱신하지 않아 직접 변경의 3일 제한이 우회됐다"
status: resolved
resolution: "[[ISS-0359-nickname-regenerate-cooldown-bypass-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/579"
---

# ISS-0359: 닉네임 랜덤 재생성에 3일 쿨다운 적용과 새로고침 버튼 안내 보강

GitHub #579 (원본: 이슈 본문과 댓글).

## 증상
- 설정 프로필 카드의 닉네임 변경 경로 둘의 규칙이 다르다. `편집`(직접 변경)은 3일 쿨다운(`NICKNAME_COOLDOWN`), 새로고침 아이콘(랜덤 재생성)은 쿨다운 확인도 없고 `nicknameChangedAt`도 갱신하지 않아 횟수 제한 없이 바뀐다 → `편집` 직후에도 새로고침으로 바로 바꿀 수 있다.
- 새로고침 아이콘은 회색 아이콘 하나라 무슨 버튼인지 알기 어렵고, 누르면 확인 없이 즉시 바뀌며 성공 안내도 없다.

## 재현 조건
설정 > 프로필 카드 > `편집`으로 닉네임 변경 직후 새로고침 아이콘 탭.

## 조사 기록
- 2026-10-22: 서버 `MemberService.regenerateNickname` 쿨다운 적용, 앱 확인 창·토스트. API 경로·DTO·ErrorCode 변경 없음.
- 2026-10-24 사용자 추가 요청: 프로필 카드의 랜덤 닉네임 아이콘을 없애고 `편집` 시트(`nickname_edit_sheet.dart`) 안으로 옮김.

## 근본 원인
두 변경 경로가 쿨다운 규칙·변경 시각을 공유하지 않았다.
