---
type: completion-report
id: ISS-0453
created: 2026-11-05
topics: [concept-learning, design-system]
status: resolved
resolves: "[[ISS-0453-app-concept-reading-readability-redesign]]"
related: ["[[DEC-0252-concept-reading-single-scroll]]", "[[DEC-0253-concept-collapse-only-long-later-sections]]"]
source: "_sources/issues/ISS-0453-app-concept-reading-readability-redesign-report.md"
---

# ISS-0453 완료 리포트: 개념 읽기를 한 스크롤 카드 구조로 재설계

GitHub #835 리포트 기준 (2026-11-05). PR #844.

## 해결 방법
- 한 스크롤: 한 줄 핵심 > 꼭 기억할 것(번호 카드) > 번호 문단 카드 (사이 회색 띠, 태블릿 읽기 폭 640pt) ([[DEC-0252-concept-reading-single-scroll]]).
- 문단 종류를 앵커로 판별(`ConceptReadingParser`): 자주 헷갈리는 점은 굵은 첫 문장 단위 함정 카드, 시험 포인트는 강조 카드.
- 긴 문단만 접기: 앞 3문단·함정·시험 포인트는 항상 펼침, 이후 1200자 이상 일반 문단만 미리보기 3줄 + 이어서 읽기 ([[DEC-0253-concept-collapse-only-long-later-sections]]).
- 세그먼트 `개념 | 확인 문제`, 하단 확인 문제 풀기(보조)·다음 개념(주).
- 디자인 시스템 `PassqlCallout`(강조·주의) 추가.

## 검증
- `flutter analyze` 0건, `flutter test` 103개 통과.
- iOS 18.3 시뮬레이터 라이트·다크·접근성 큰 글씨, 접힘·펼침 실측.

## 근본 원인 (확정)
깊이 전환과 구분 없는 긴 본문으로 핵심·함정이 묻혔다.

## 재발 방지
- 문단 종류 판별·함정 분리를 단위 테스트로 고정.

## 알고 남긴 것
- 서버 `lastDepth` 저장 API는 그대로(화면은 깊이를 안 나눔).
- 앵커 이름을 바꾸면 함정·시험 포인트 카드가 일반 문단으로 보인다.
- 새 Xcode `lipo -verify_arch` 다중 인자 미지원으로 `flutter build ios --simulator` 실패 > `flutter run -d <기기>`로 확인.
- 구조화 블록(풀이 단계·바뀐 칸 강조·문단 중간 퀴즈)은 개념 원본 형식 변경이 필요해 후속.
