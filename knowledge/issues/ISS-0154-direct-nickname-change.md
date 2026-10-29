---
type: issue
id: ISS-0154
created: 2026-04-25
topics: [auth-member]
symptoms: ["닉네임 직접 변경 불가", "랜덤 재생성만", NicknameChangeModal, NICKNAME_COOLDOWN, "PATCH /api/members/me/nickname"]
root_cause: "닉네임은 가입 시 자동 생성되고 설정에서 랜덤 재생성만 가능, 직접 입력 변경 기능이 없음"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/287"
---

# ISS-0154: 닉네임을 직접 입력해 바꿀 수 없음

GitHub #287 (원본: 이슈 본문, 댓글은 스크린샷·영상과 "여기로해줘" 한 줄).

## 증상
닉네임은 회원가입 시 자동 생성되고, 설정 페이지에서는 랜덤 재생성만 가능하다.

## 재현 조건
해당 없음 (기능 추가).

## 조사 기록
- 2026-04-25: 제안 — 설정 닉네임 행 연필 아이콘 → 바텀시트 모달, 직접 입력 또는 주사위(랜덤), 중복확인 후 저장, 변경 후 3일 재변경 불가(쿨다운, 백엔드 에러를 토스트로). 작업: `member.nickname_changed_at DATETIME(6)`, `GET /api/members/me/nickname/check`, `PATCH /api/members/me/nickname`(쿨다운·유효성·금지어), `ErrorCode` `NICKNAME_COOLDOWN`·`NICKNAME_INVALID`·`NICKNAME_FORBIDDEN`, `NicknameChangeModal`, `Settings.tsx`.
- 2026-04-25~26 댓글: 스크린샷 2장, 영상 1개와 "여기로해줘". 구현 내용·결과를 설명하는 글은 없다.

## 근본 원인
해당 없음 (미구현 기능). 실제 구현 여부와 쿨다운 정책 확정 여부는 원본에 적혀 있지 않다.
