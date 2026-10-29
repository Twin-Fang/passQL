---
type: completion-report
id: ISS-0032
created: 2026-04-09
topics: [admin, question-bank]
status: resolved
resolves: "[[ISS-0032-admin-direct-question-register]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/46"
---

# ISS-0032 완료 리포트: 직접 등록 UI (화면 캡처)

GitHub #46 캡처 댓글(2026-04-09) 기준. `## 개요` 형식 리포트는 없음.

## 해결 방법
댓글은 화면 캡처와 함께 "직접 등록 UI입니다", "개념형인 경우 / 실행형인 경우", "정답 실행 SQL 테스트입니다"만 적었다. 변경 파일·구현 세부는 이슈 본문의 작업 내용(`AdminQuestionController` `registerForm()`/`register()`, `parseExecutionMode()`/`parseChoiceSetPolicy()`, `createQuestionOnly()`, `question-register.html`, `questions.html` 버튼)뿐이고, 완료 댓글에서 따로 확인한 내용은 없다.

## 근본 원인 (확정)
해당 없음 (기능 이슈).

## 재발 방지
원본에 적혀 있지 않다.

## 교훈
원본에 적혀 있지 않다.
