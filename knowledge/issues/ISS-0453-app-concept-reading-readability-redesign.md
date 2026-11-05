---
type: issue
id: ISS-0453
created: 2026-11-05
topics: [concept-learning, design-system]
symptoms: ["개념 가독성", "개념 화면 빽빽함", "핵심이 안 보임", "긴 글머리표", "핵심 | 자세히 | 문제", "개념 설명 UX"]
root_cause: "핵심·자세히 깊이 전환으로 전체 흐름이 끊기고, 자세히 본문이 구분 없는 긴 글이라 함정·시험 포인트가 일반 설명에 묻혔다"
status: resolved
resolution: "[[ISS-0453-app-concept-reading-readability-redesign-report]]"
related: ["[[ISS-0453-app-concept-reading-readability-redesign-report]]", "[[ISS-0432-app-concept-tab-redesign]]", "[[DEC-0252-concept-reading-single-scroll]]", "[[DEC-0253-concept-collapse-only-long-later-sections]]"]
source: "_sources/issues/ISS-0453-app-concept-reading-readability-redesign.md"
---

# ISS-0453: 앱 개념 학습 화면 가독성이 떨어져 핵심이 안 보임

GitHub #835 이슈 본문 기준. 외부 출처: https://github.com/Twin-Fang/passQL/issues/835 · 완료 리포트: [[ISS-0453-app-concept-reading-readability-redesign-report]]

## 증상
개념 학습 화면(핵심·자세히·문제)에서 긴 글머리표 목록이 빽빽하게 이어져 핵심이 안 보이고 모바일에서 읽기 어렵다. 사용자 표현: "뭐가 뭔지".

## 요청
개념을 잘 설명하는 자료·학습 서비스를 조사해 개념 화면에 있으면 좋은 요소(핵심 한 줄, 예시 표, 자주 틀리는 점, 시험 포인트, 바로 확인 문제 등)를 정리하고, 정보 구조·디자인·UX를 다시 설계한다.

## 근본 원인
- 깊이 전환(`핵심 | 자세히`)으로 한 화면에서 전체 흐름이 보이지 않았다 ([[DEC-0217-concept-study-single-segment]]).
- 자세히 본문이 문단 구분 약한 긴 글이라 함정·시험 포인트가 묻혔다.
