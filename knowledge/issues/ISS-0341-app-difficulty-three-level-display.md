---
type: issue
id: ISS-0341
created: 2026-10-20
topics: [practice, question-bank]
symptoms: ["난이도 4 / 3", "별 3개", "난이도 필터 1~3", StarRating.tsx, question_sections.dart, recommendations_section.dart, "★☆☆", "난이도 범위"]
root_cause: "난이도 실제 범위는 1~5인데 앱은 3단계 기준으로 그렸고 웹 목록 필터는 1~3만 있었다"
status: resolved
resolution: "[[ISS-0341-app-difficulty-three-level-display-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/553"
---

# ISS-0341: 앱 난이도 표시가 3단계 기준이라 4, 5 문제가 4 / 3으로 표시

GitHub #553 (원본: 이슈 본문과 댓글).

## 증상
- 앱 풀이 화면: 접근성 라벨 "난이도 4 / 3", 별은 3개로 잘려 높은 난이도 구분 불가(`app/lib/presentation/widgets/question/question_sections.dart:40`).
- 앱 홈 추천: 1~3 외 값은 `★☆☆`로 떨어져 가장 쉬운 문제처럼 보임(`recommendations_section.dart:18`).
- 웹 문제 목록 난이도 필터는 1~3만 있음(`client/src/pages/Questions.tsx`).

## 재현 조건
앱 홈 > 오늘의 세트(2026-10-20) > 2번, 3번 문제(난이도 4) > VoiceOver·접근성 트리로 라벨 확인. 웹 문제 목록 > 난이도 필터 > 4 없음.

## 조사 기록
- 2026-10-20: 등록 때는 "GitHub #504로 난이도가 4단계(L1~L4)"라고 적었다.
- 2026-10-20 정정 댓글: 실제 계약은 **1~5**. 관리자 등록·수정 슬라이더 1~5(`question-register.html`, `question-edit.html`), AI 서버 `ai/src/models/ai_request.py` difficulty `ge=1, le=5`, 웹 별 5개(`StarRating.tsx`). #504의 L1~L4는 출제 비율 계획일 뿐 데이터 범위가 아니다. 어긋난 곳은 앱(3단계)과 웹 난이도 필터(1~3) 두 곳. 서버 범위 검증 누락은 관리자 화면이 1~5로 막고 있어 범위에서 제외.

## 근본 원인
앱과 웹 필터가 실제 범위(1~5)와 다른 최대값을 하드코딩했다.
