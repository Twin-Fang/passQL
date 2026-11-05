---
type: completion-report
id: ISS-0456
created: 2026-11-05
topics: [concept-learning, design-system]
status: resolved
resolves: "[[ISS-0456-concept-lesson-textbook-blocks]]"
related: ["[[DEC-0256-concept-lesson-blocks-by-table-header]]"]
source: "_sources/issues/ISS-0456-concept-lesson-textbook-blocks-report.md"
---

# ISS-0456 완료 리포트: 레슨 블록 렌더러와 개념 글 63개 다시 쓰기

GitHub #848 리포트 기준 (2026-11-05). PR #851.

## 해결 방법
- 표 머리글로 블록 구분: 용어 카드, 단계, 외우는 법, 헷갈리는 말, OX 바로 확인, 비교 표 ([[DEC-0256-concept-lesson-blocks-by-table-header]]).
- 문단 머리(큰 번호·종류 라벨·제목·부제), 읽은 정도 막대, 목차 칩, 맨 끝 한 장 요약.
- `PassqlScrollReveal`: 스크롤로 들어올 때 차례로 등장.
- 개념 63개 다시 쓰기 (확인 문제 그대로). 수험생 암기법은 사실 검증한 것만.
- 긴 문단 접기 제거.

## 검증
- `flutter analyze` 0건, `flutter test` 106개 통과.
- 개념 구조 검증 63개 경고 0, Oracle 21c 검증 63/63.
- 확인 문제 63개 원본과 같음, 다시 읽기 앵커 빠짐 0.

## 근본 원인 (확정)
줄글 원본 + 유형 구분 없는 화면.

## 재발 방지
- content/concepts/README.md 「레슨 블록」 작성 규칙.

## 알고 남긴 것
- 운영 반영은 개념별 본문 수정 API 로 (묶음 가져오기는 확인 문제 UUID 를 바꿔 회원 풀이 기록이 어긋남).
- 출처 없는 두문자(프웨그해셀오, 추단명)는 "수험생 공용"으로 소개하지 않음.
- SQL 많은 단원은 4~5분 분량.
