---
type: issue
id: ISS-0287
created: 2026-10-15
topics: [practice]
symptoms: [챕터 결과 뒤로 가기, "Phase 4에서 구현", 자리표시 화면, "/practice/:sessionId", context.go, iOS 스와이프, Android 뒤로 버튼]
root_cause: "챕터 결과 화면이 `/practice/:sessionId` 하위 경로였고 이동이 `context.go`라 뒤로 가면 자리표시 화면이 나왔다"
status: resolved
resolution: "[[ISS-0287-chapter-result-back-shows-placeholder-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/481"
---

# ISS-0287: 앱 챕터 결과 화면에서 뒤로 가면 미구현 자리표시 화면 표시

GitHub #481 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
챕터 결과 화면이 `/practice/:sessionId` 하위 경로라 뒤로 가기(Android 버튼, iOS 스와이프) 시 "Phase 4에서 구현" 자리표시 화면이 나옴.
위치: `app/lib/presentation/pages/practice/practice_page.dart:3-16`, `app/lib/router/app_router.dart:158-168`, `app/lib/presentation/flows/question_flow.dart:67`.

## 재현 조건
챕터 풀이 완료 → 결과 화면 → 시스템 뒤로 가기.

## 조사 기록
- 2026-10-15: 예상 동작 — 챕터 결과를 최상위 경로로 옮기고 쓰이지 않는 `PracticePage`와 경로 정리, 뒤로 가면 문제 목록.

## 근본 원인
frontmatter `root_cause`와 같음.
