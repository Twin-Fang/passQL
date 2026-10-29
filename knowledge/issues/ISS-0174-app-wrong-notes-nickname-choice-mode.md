---
type: issue
id: ISS-0174
created: 2026-10-02
topics: [auth-member, practice]
symptoms: ["앱 오답 목록 없음", "닉네임 직접 변경", "닉네임 중복 확인", "선택지 생성 모드", "/progress/wrong-questions", "/members/me/nickname", "choice-generation-mode"]
root_cause: "해당 없음 — 웹 마이페이지/설정 기능이 앱에 없거나 일부만 있음"
status: resolved
resolution: "[[ISS-0174-app-wrong-notes-nickname-choice-mode-report]]"
related: ["[[DEC-0088-app-settings-tab-as-mypage]]", "[[ISS-0163-retry-wrong-questions-mypage]]", "[[DEC-0087-choice-generation-practice-real-mode]]"]
source: "https://github.com/Twin-Fang/passQL/issues/329"
---

# ISS-0174: 앱 마이페이지 오답 목록, 닉네임 변경, 선택지 생성 모드

GitHub #329 (원본: 이슈 본문과 댓글 2개). 선행 GitHub #327, #328. 관련 GitHub #287.

## 증상
(현재 문제점) 앱에 오답 목록이 없고, 닉네임은 랜덤 재생성만 가능(직접 변경·중복 확인 없음), 선택지 생성 모드 변경이 없다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-02 서버 API: `/progress/wrong-questions`, `/members/me/nickname`(PATCH), `/members/me/nickname/check`, `/members/me/settings/choice-generation-mode`.

## 근본 원인
해당 없음 (기능 추가).
