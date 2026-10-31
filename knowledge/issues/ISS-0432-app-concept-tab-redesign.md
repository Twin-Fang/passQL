---
type: issue
id: ISS-0432
created: 2026-10-30
topics: [concept-learning, design-system]
symptoms: ["개념 탭", "단원 상세", "개념 읽기", "개념 풀기", "개념 결과 화면", "읽기 풀기 전환", "핵심 자세히", "같은 뜻 반복 글자", concepts_home_page, concept_topic_page, concept_page, concept_solve_view]
root_cause: "개념 탭이 홈·문제·토론·프로필 탭과 다른 카드 톤이었고, 읽기/풀기와 핵심/자세히 전환이 두 줄로 나뉘었으며 같은 뜻을 두 번 이상 말하는 글자가 많았다"
status: resolved
resolution: "[[ISS-0432-app-concept-tab-redesign-report]]"
related: ["[[ISS-0432-app-concept-tab-redesign-report]]", "[[DEC-0217-concept-study-single-segment]]", "[[DEC-0218-concept-result-ring-climax]]", "[[DEC-0219-keep-one-line-headlines-visualize-instructions]]", "[[DEC-0220-check-on-semantic-fill-uses-on-semantic]]", "[[DEC-0221-concept-wrong-rows-expand-in-place]]", "[[DEC-0222-concept-perfect-fullscreen-scoreboard]]", "[[ISS-0358-concept-learning-by-unit]]", "[[ISS-0428-app-profile-tab-redesign]]"]
source: "https://github.com/Twin-Fang/passQL/issues/764"
---

# ISS-0432: 앱 개념 탭 UI/UX 개편

GitHub #764 (원본: 이슈 본문과 리포트 댓글).

## 증상
앱 개념 탭 전체(탭 첫 화면, 단원 상세, 개념 읽기·풀기·결과)를 홈(GitHub #701), 문제 탭(GitHub #726), 토론(GitHub #741), 프로필(GitHub #749)과 같은 톤(좌우 끝까지 닿는 흰 구간 + 회색 띠, 큰 숫자 하나 + 목록 줄)으로 바꾸고, 같은 뜻을 두 번 이상 말하는 글자를 덜어내는 디자인 요청. 서버·API 계약은 바꾸지 않는다.

## 재현 조건
해당 없음 (디자인 개편).

## 조사 기록
- 2026-10-30: 이슈 등록. 시안을 라이트·다크로 반복 검토(폰에서 이미지로 확인). 읽기·풀기 화면은 기존 세그먼트 재사용, 결과 화면은 고리 연출로 확정.
- 2026-10-30: 커밋 0553fa56 푸시, 리포트 댓글 6512843324로 완료 → [[ISS-0432-app-concept-tab-redesign-report]]. 테스트 빌드는 아직 돌리지 않았다.
- 2026-10-31: 결과 화면을 다시 개편(틀린 문제 줄 펼침, 다 맞히면 전체 화면 점수판, 단원 끝 폭죽). 커밋 8830e0e7 푸시, 같은 댓글을 새 화면으로 갱신 → [[DEC-0221-concept-wrong-rows-expand-in-place]], [[DEC-0222-concept-perfect-fullscreen-scoreboard]].
- 2026-10-31: 점수판 효과를 폭죽(위·양쪽 대포) → 파동 → 화면 끝까지 번지는 빛 + 원 빛줄기로 확정, 폭죽은 단원 끝에만. 커밋 7b1ea902, 리포트 댓글 갱신.
- 2026-10-31: 폭죽을 모두 빼고 빛 번짐만 남김(`concept_confetti.dart` 삭제). 커밋 c0e6e8b8, 리포트 댓글 갱신.

## 근본 원인
결함이 아니라 화면 구조 문제. 다른 탭 개편과 톤이 달랐고 전환 줄이 둘, 반복 글자가 많았다.
