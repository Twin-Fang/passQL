---
type: issue
id: ISS-0232
created: 2026-10-07
topics: [home]
symptoms: ["홈 카드 빈 데이터", "선택된 일정 없음", "오늘은 준비 중이에요", "안녕하세요,", "API 실패", "실패 표현 불일치"]
root_cause: "`client/src/pages/Home.tsx` 인사말·일정·데일리 카드가 API 실패를 빈 상태로 그렸다"
status: resolved
resolution: "[[ISS-0232-web-home-cards-failure-as-empty-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/399"
---

# ISS-0232: 웹 홈 카드가 API 실패를 빈 데이터로 표시함

GitHub #399 (원본: 이슈 본문과 완료 댓글).

## 증상
API가 실패하면 일정 카드 "선택된 일정 없음", 데일리 카드 "오늘은 준비 중이에요", 인사말은 이름 없는 "안녕하세요,". 같은 화면의 히트맵·합격 준비도 카드는 재시도 버튼이 있는 오류 상태를 보여 실패 표현이 둘로 갈린다. 앱의 같은 문제는 GitHub #375에서 고쳤다.

## 재현 조건
홈 API가 실패하는 상태(서버 오류·네트워크 오류)로 홈 진입.

## 조사 기록
- 2026-10-07: 코드 `client/src/pages/Home.tsx` 인사말·일정·데일리 카드 분기.

## 근본 원인
카드 분기가 실패와 빈 응답을 구분하지 않았다.
