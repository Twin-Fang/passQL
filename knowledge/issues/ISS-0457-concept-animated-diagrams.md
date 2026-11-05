---
type: issue
id: ISS-0457
created: 2026-11-05
topics: [concept-learning, design-system]
symptoms: ["개념 전자책 같음", "교재 E book", "애니메이션", "벡터 움직임", "조인 그림", "집합 그림", "외우는 법 예쁘게"]
root_cause: "레슨 블록이 모두 멈춰 있는 표·카드라, 조인·조건·집합 연산의 결과가 왜 그렇게 나오는지 움직임으로 보여 주지 못했다"
status: resolved
resolution: "[[ISS-0457-concept-animated-diagrams-report]]"
related: ["[[ISS-0457-concept-animated-diagrams-report]]", "[[ISS-0456-concept-lesson-textbook-blocks]]", "[[DEC-0257-concept-animated-diagram-blocks]]"]
source: "_sources/issues/ISS-0457-concept-animated-diagrams.md"
---

# ISS-0457: 개념 학습이 전자책 같음 — 앱다운 움직이는 그림으로

GitHub #853 이슈 본문 기준. 외부 출처: https://github.com/Twin-Fang/passQL/issues/853 · 완료 리포트: [[ISS-0457-concept-animated-diagrams-report]]

## 증상
#848 레슨 블록([[ISS-0456-concept-lesson-textbook-blocks]]) 뒤에도 화면이 교재를 옮긴 것처럼 보였다. 사용자: "교재 E book 말고 넌 앱이야", "애니메이션, 이해가 쉬운 벡터 움직임", "외우는 것도 예쁘게".

## 요청
디지털 강점을 살린 그림: 움직이는 연출, 외우는 법을 예쁘게.

## 근본 원인
모든 블록이 정지 화면이라 결과 행이 만들어지는 과정을 볼 수 없었다.
