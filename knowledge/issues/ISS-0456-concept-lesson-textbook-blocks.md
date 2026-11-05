---
type: issue
id: ISS-0456
created: 2026-11-05
topics: [concept-learning, design-system]
symptoms: ["개념 줄글", "개념 화면 못생김", "누가 읽고 싶어하냐", "말 순서 딱딱", "요점정리", "외우는 법", "암기법", "교과서처럼"]
root_cause: "개념 글이 긴 문장 나열이고, 순서·분류·함정처럼 외우는 방식이 다른 내용을 모두 같은 글 문단으로 보여 줬다"
status: resolved
resolution: "[[ISS-0456-concept-lesson-textbook-blocks-report]]"
related: ["[[ISS-0456-concept-lesson-textbook-blocks-report]]", "[[ISS-0453-app-concept-reading-readability-redesign]]", "[[DEC-0256-concept-lesson-blocks-by-table-header]]"]
source: "_sources/issues/ISS-0456-concept-lesson-textbook-blocks.md"
---

# ISS-0456: 개념 학습이 줄글이라 읽히지 않음 — 교과서형 요점정리로

GitHub #848 이슈 본문 기준. 외부 출처: https://github.com/Twin-Fang/passQL/issues/848 · 완료 리포트: [[ISS-0456-concept-lesson-textbook-blocks-report]]

## 증상
#835 한 스크롤 카드 화면([[ISS-0453-app-concept-reading-readability-redesign]])도 긴 문장 나열이었다. 사용자: "누가 이런 거 읽고 싶어하냐", "방식이 중요해 내용보다도", "유형마다 외우는 방식이 다르다", "수험생들이 만든 암기법(원부이결다조)을 넣어라".

## 요청
교과서처럼 제목·부제·여러 형식의 섹션, 요점정리(용어는 크게, 비교는 표, 순서는 단계), 스크롤 애니메이션, 63개 개념 전체.

## 근본 원인
글 자체가 줄글이고, 내용 유형별 외우는 방식이 화면에 없었다.
