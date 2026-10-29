---
type: completion-report
id: ISS-0341
created: 2026-10-21
topics: [practice, question-bank]
status: resolved
resolves: "[[ISS-0341-app-difficulty-three-level-display]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/553"
---

# ISS-0341 완료 리포트: 난이도 최대 단계 상수를 앱·웹 각 한 곳에 두고 1~5로 맞춤

GitHub #553 리포트 댓글(`## 개요`, 2026-10-21) 기준. 커밋 7996f97d, v1.27.0.

## 해결 방법
- 앱: `app/lib/core/utils/question_difficulty.dart`에 `maximumQuestionDifficulty = 5`, 범위 보정, 별 글자 변환. `question_sections.dart` 별 5칸·라벨 "난이도 N / 5". `recommendations_section.dart`의 3단계 switch 제거 > 공통 변환(★★★★☆).
- 웹: `client/src/lib/questionDifficulty.ts`에 `MAX_QUESTION_DIFFICULTY`, `QUESTION_DIFFICULTY_LEVELS`. `StarRating.tsx`, `Questions.tsx`의 별 개수·필터 선택지를 상수에서.

## 근본 원인 (확정)
난이도 실제 범위는 1~5인데 앱만 3단계로 그렸고 웹 필터는 1~3이었다. 이슈 등록 때의 "4단계" 설명은 #504 출제 비율 계획을 데이터 범위로 오인한 것.

## 재발 방지
- 검증: iOS 시뮬레이터 난이도 4 문제 별 5칸 중 4개, 라벨 "난이도 4 / 5", 홈 추천 ★★★★☆. 앱·웹 테스트 통과.
- 주의: 최대 단계는 서버 OpenAPI에 범위로 나오지 않아 앱·웹 상수에 주석으로 원본 위치를 적었다. 범위를 바꾸면 관리자 템플릿·AI 서버·앱·웹 네 곳을 함께 바꾼다.

## 교훈
(원본에 없음, 볼트 정리) 값의 범위를 계획 문서(출제 비율 등)가 아니라 실제 데이터 계약(등록 화면 검증·AI 요청 모델)에서 확인한다.
