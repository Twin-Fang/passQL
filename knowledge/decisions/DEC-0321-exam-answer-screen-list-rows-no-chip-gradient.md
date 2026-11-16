---
type: decision
id: DEC-0321
created: 2026-11-16
reviewed: null
topics: [design-system, practice]
status: superseded
supersedes: null
superseded_by: DEC-0332
related: ["[[ISS-0524-exam-answer-screen-no-card-chip-gradient]]", "[[ISS-0524-exam-answer-screen-no-card-chip-gradient-report]]", "[[DEC-0116-app-apple-hig-design-system]]", "[[DEC-0189-home-section-layout-single-cta]]", "[[DEC-0310-intro-site-light-app-demo-first-screen]]"]
---

# DEC-0321: 가답안·가채점 화면(앱·소개 사이트)도 앱 디자인 원칙을 따른다 — 칩·그라데이션·장식 배지·카드 중첩 없이 grouped 목록 행과 의미색 글자, 채운 버튼은 화면당 하나, 공유 이미지는 흰 바탕에 로고·회차·판정·점수·주소만

## 문제 정의 (Context)
회차별 가답안·가채점 화면이 알약 칩, 보라 그라데이션, 물결 배지 아이콘, 카드 안의 카드, 나란한 색 버튼으로 "AI가 만든 듯한" 모양이었고, 사용자가 이런 카드 형식을 싫어한다고 지적했다 (GitHub #1109, [[ISS-0524-exam-answer-screen-no-card-chip-gradient]]). [[DEC-0189-home-section-layout-single-cta]]는 홈에만, [[DEC-0116-app-apple-hig-design-system]]은 앱에만 적용돼 있어 홈 밖 화면과 소개 사이트 페이지에 어떤 기준을 쓸지 정해야 했다.

## 결정 (Decision)
가답안·가채점 화면(앱 회차 요약·내 가채점·가답안 탭·틀린 문항 시트·홈 진입 행·공유 이미지, 소개 사이트 `sqld/<회차>/`)에 DEC-0116·DEC-0189 원칙을 적용한다. 기능·API·화면 이동은 바꾸지 않는다.
- 상태·참여 수·갱신 시각·점수 범위·상위 %는 칩 대신 회색 보조 한 줄 또는 grouped 목록 행 값으로. 색은 정답·오답·상태처럼 뜻 있는 글자에만.
- 그라데이션, 장식 배지 아이콘, 카드 안의 카드, 합의율 막대 같은 장식은 쓰지 않는다.
- 채운 버튼은 화면당 하나(앱 「결과 공유」, 사이트 「이미지로 공유」). 나머지는 글자 버튼·테두리 버튼·글자 링크.
- 결과 공유 이미지는 흰 바탕(앱 다크 모드는 앱 배경) + 로고 > 회차 가채점 > 판정 > 점수 > 주소만. 앱과 사이트가 같은 구성.

## 검토한 대안 (Alternatives)
논의 기록 없음. (이슈 본문이 처음부터 "앱 디자인 시스템 기준으로 다시 다듬는다"를 제시.)

## 결과 (Consequences)
**긍정**
- 가답안 화면이 설정·통계·홈과 같은 목록 행·글자 위계로 보인다. 공유 이미지가 단정해진다.
- 앱 공용 부품만 써서 전용 토큰 3개를 지웠다.

**부정**
- 공유 이미지 구성은 앱(`exam_answer_share_card.dart`)과 사이트(`exam-answer-share.js`)에 따로 구현된 사본이라 함께 고쳐야 한다.
- 미확정 상태(갈림 등)를 칩 대신 글자로만 드러내므로, 그 글자를 빼면 확정 정답으로 오해할 수 있다.

## 영향 범위 (Scope)
앱 `app/lib/presentation/widgets/exam_answer/*`, `pages/exam_answer/exam_answer_page.dart`, `widgets/home/exam_answer_home_section.dart`, `core/exam_answer/exam_answer_share_link.dart`, 토큰 `passql_size.dart`·`passql_opacity.dart`. 소개 사이트 gh-pages `exam-answer.css`, `exam-answer-table.js`, `exam-answer-share.js`, `_src/site_answer_key_pages.py`.

## 출처 (References)
- GitHub #1109 이슈 본문 「해결 방안」, PR #1113 본문 「변경 사항」, 소개 사이트 커밋 dd16038, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1109#issuecomment-6898334844
- W4 충돌 검사: [[DEC-0116-app-apple-hig-design-system]](웹은 앱 기준 확정 뒤 따로 맞춘다)·[[DEC-0189-home-section-layout-single-cta]](홈 구간 + 채운 버튼 하나, 문제·토론·프로필 탭은 카드 유지)과 같은 방향의 적용 범위 확장이라 충돌 없음. 가답안 화면은 탭이 아니라 홈에서 들어가는 화면. [[DEC-0310-intro-site-light-app-demo-first-screen]](사이트 밝은 화면 고정)·[[DEC-0248-site-icons-generated-from-brand]](사이트 아이콘·OG 이미지 생성)·[[DEC-0315-exam-answer-page-concept-line-no-original]](문항 형태)과도 대상이 달라 충돌 없음.
