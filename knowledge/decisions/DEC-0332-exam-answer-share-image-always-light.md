---
type: decision
id: DEC-0332
created: 2026-11-16
reviewed: null
topics: [design-system, practice]
status: active
supersedes: DEC-0321
superseded_by: null
related: ["[[DEC-0321-exam-answer-screen-list-rows-no-chip-gradient]]", "[[ISS-0538-exam-answer-qa-fixes-empty-attempt-ranking]]", "[[ISS-0538-exam-answer-qa-fixes-empty-attempt-ranking-report]]", "[[DEC-0116-app-apple-hig-design-system]]", "[[DEC-0189-home-section-layout-single-cta]]"]
---

# DEC-0332: 가답안·가채점 화면 디자인 원칙(DEC-0321)은 그대로 두고, 결과 공유 이미지는 다크 모드여도 항상 흰 바탕(라이트 테마·라이트 로고)으로 만든다

## 문제 정의 (Context)
[[DEC-0321-exam-answer-screen-list-rows-no-chip-gradient]]는 결과 공유 이미지를 "흰 바탕(앱 다크 모드는 앱 배경)"으로 정했다. 실기 검수에서 다크 모드로 공유하면 미리보기와 저장 이미지가 검은 바탕으로 만들어졌고, 이슈는 "공유 이미지는 흰 바탕 고정이어야 함"으로 요구했다 (GitHub #1126 결함 4번, [[ISS-0538-exam-answer-qa-fixes-empty-attempt-ranking]]).

## 결정 (Decision)
DEC-0321의 내용을 이어받고 공유 이미지 바탕 규칙 하나만 바꾼다.
- 가답안·가채점 화면(앱 회차 요약·내 가채점·가답안 탭·틀린 문항 시트·홈 진입 행·공유 이미지, 소개 사이트 `sqld/<회차>/`)은 DEC-0116·DEC-0189 원칙: 칩·그라데이션·장식 배지·카드 중첩 없이 grouped 목록 행과 회색 보조 한 줄, 색은 뜻 있는 글자에만, 채운 버튼은 화면당 하나(앱 「결과 공유」, 사이트 「이미지로 공유」). (DEC-0321 그대로)
- **변경:** 결과 공유 이미지는 **앱 화면 모드와 무관하게 항상 흰 바탕(라이트 테마·라이트 로고)**. 앱은 `ExamAnswerShareCard` 전체를 `Theme(data: PassqlTheme.light)`로 감싸 미리보기 = 저장 이미지. 구성은 로고 > 회차 가채점 > 판정 > 점수 > 주소만, 앱과 사이트 같은 구성. (DEC-0321의 "다크면 앱 배경" 대체)

## 검토한 대안 (Alternatives)
- 다크 모드면 앱 배경(DEC-0321 원안): 이슈가 흰 바탕 고정을 요구해 버림. 그 밖에 검토한 대안의 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 공유 이미지가 보내는 사람의 화면 모드와 무관하게 같은 모양이고, 앱 이미지와 소개 사이트 이미지가 같은 바탕이 된다(코드 주석: "받는 쪽 화면과 무관하게 흰 바탕").

**부정**
- 다크 모드 사용자는 공유 미리보기에서 흰 카드가 어두운 화면 위에 뜬다. 그 밖의 비용은 논의 기록 없음.
- 공유 이미지 구성은 여전히 앱(`exam_answer_share_card.dart`)과 사이트(`exam-answer-share.js`) 사본이라 함께 고쳐야 한다(DEC-0321과 같음).

## 영향 범위 (Scope)
앱 `app/lib/presentation/widgets/exam_answer/exam_answer_share_card.dart`(라이트 테마 고정). 나머지 범위는 DEC-0321과 같다: 앱 `widgets/exam_answer/*`, `pages/exam_answer/exam_answer_page.dart`, `widgets/home/exam_answer_home_section.dart`, 소개 사이트 gh-pages `exam-answer.css`, `exam-answer-table.js`, `exam-answer-share.js`, `_src/site_answer_key_pages.py`.

## 출처 (References)
- GitHub #1126 이슈 본문 결함 4번·예상 동작 4번, PR #1127 커밋 c997c097, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1126#issuecomment-6907744218
- W4: [[DEC-0321-exam-answer-screen-list-rows-no-chip-gradient]]의 공유 이미지 바탕 규칙과 충돌 > 사용자 지시로 "신규로 대체" (DEC-0321 → superseded). [[DEC-0116-app-apple-hig-design-system]]·[[DEC-0189-home-section-layout-single-cta]]와는 같은 방향이라 충돌 없음.
