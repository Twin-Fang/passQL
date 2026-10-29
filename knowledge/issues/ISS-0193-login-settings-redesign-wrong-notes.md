---
type: issue
id: ISS-0193
created: 2026-10-06
topics: [auth-member, design-system]
symptoms: [로고 중복, 로그인 버튼 모양 불일치, 설정 회원 ID 노출, 오답 노트 설정 화면 펼침, "/settings/wrong-notes"]
root_cause: "TestFlight 0.0.222 실기기에서 로그인·설정 화면 완성도가 낮았다 (디자인 문제)"
status: resolved
resolution: "[[ISS-0193-login-settings-redesign-wrong-notes-report]]"
related: ["[[ISS-0195-legal-text-escaped-newlines]]"]
source: "https://github.com/Twin-Fang/passQL/issues/348"
---

# ISS-0193: 로그인·설정 화면 디자인 개선 및 오답 노트 화면 분리

GitHub #348 (원본: 이슈 본문과 댓글).

## 증상
TestFlight 빌드(0.0.222)를 실기기에서 보니:
- 로그인: 워드마크 로고 아래에 같은 "passQL" 텍스트가 한 번 더 나와 로고가 두 개로 보임
- 로그인: Google 버튼(흰 바탕)과 Apple 버튼(검정 공식 위젯)의 모양·모서리·글꼴 크기가 다름
- 설정: 회원 ID(UUID)가 맨 위에 노출, 카드가 한 줄씩 길게 이어짐
- 설정: 오답 노트 목록이 설정 화면 안에 펼쳐져 화면이 길어짐

## 재현 조건
TestFlight 0.0.222에서 로그인·설정 화면 진입.

## 조사 기록
- 2026-10-06: 시뮬레이터(iPhone 16 Pro)에서 `app/tool/store_shots`로 수정 전후 촬영 비교(커밋 `73ff662`).
- 2026-10-07: 실계정 E2E(Maestro)에서 약관 화면 `\n` 표시 버그를 함께 발견·수정(커밋 `afa45db`, 별도 이슈 GitHub #350).

## 근본 원인
디자인 완성도 문제. 원인 분석은 원본에 적혀 있지 않다.
