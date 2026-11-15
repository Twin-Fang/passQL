---
type: completion-report
id: ISS-0524
created: 2026-11-16
topics: [design-system, practice]
status: resolved
resolves: "[[ISS-0524-exam-answer-screen-no-card-chip-gradient]]"
related: ["[[DEC-0321-exam-answer-screen-list-rows-no-chip-gradient]]", "[[DEC-0116-app-apple-hig-design-system]]", "[[DEC-0189-home-section-layout-single-cta]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1109#issuecomment-6898334844"
---

# ISS-0524 완료 리포트: 가답안·가채점 화면을 grouped 목록 행과 글자 위계로 정리 (앱·소개 사이트)

PR #1113 머지 · 소개 사이트 커밋 dd16038 · 릴리스 PR #1115

## 해결 방법
기능·API·화면 이동은 그대로 두고 장식만 걷어냈다 — [[DEC-0321-exam-answer-screen-list-rows-no-chip-gradient]].
- 앱 회차 요약: 알약 칩 3개 > 회색 보조 한 줄 `N명 참여 | N분 전 갱신 | 공식 정답 아님`, 면책 전문은 각주.
- 앱 내 가채점: 물결 배지·칩·두꺼운 막대 > 판정 한 줄(의미색 글자) + 큰 점수, grouped 목록(과목 점수 행 + 얇은 막대·과락 눈금, 점수 범위, 순위). 채운 버튼은 「결과 공유」 하나, 「답안 수정」은 글자 버튼.
- 앱 가답안 탭: 상태 배지·합의율 막대·정오 아이콘 > `상태(의미색) | 합의 N% | 내 답 N번` 한 줄, 학습 연결은 글자 링크 `개념 학습 ›`.
- 공유 이미지(앱·사이트 공통 구성): 흰 바탕(앱 다크는 앱 배경) + 로고 > 회차 가채점 > 판정 > 점수 > 주소.
- 홈 진입 행: 아이콘 타일 제거, 목록 행 + `›`. 안 쓰는 토큰(`examAnswerScoreBarHeight`, `examAnswerAgreementBarWidth`, `PassqlOpacity.examAnswerScoreRange`) 삭제.
- 소개 사이트(`exam-answer.css`, `exam-answer-table.js`, `exam-answer-share.js`, `_src/site_answer_key_pages.py`): 행 카드 > 과목 목록 하나(구분선 행), 알약 > 의미색 글자, 그라데이션·보라 번짐 제거, 카카오톡·X 는 테두리 버튼.

## 근본 원인 (확정)
화면이 앱 공용 부품 대신 전용 장식(칩·그라데이션·배지·카드 중첩)으로 만들어져 앱 디자인 원칙과 어긋났다.

## 검증
- `flutter analyze` 이상 없음, `flutter test` 전체 통과(규칙 테스트 포함). 실제 위젯 테스트 렌더로 라이트·다크 전/후 캡처(PR #1113 본문).
- 이슈 브랜치 Android APK·iOS TestFlight 빌드 성공.
- 릴리스 PR #1115: 서버·AI·웹·Android 배포 성공, iOS(TestFlight·심사 제출)는 2026-11-16 기준 진행 중(결과는 이슈 후속 댓글). 배포 후 운영 가답안 API 정상. 소개 사이트 새 디자인 배포.

## 재발 방지
- 미확정 상태(갈림 등)도 칩 대신 의미색 글자로 드러낸다 — 글자를 빼면 확정 정답으로 오해한다.
- 앱(`exam_answer_share_card.dart`)과 사이트(`exam-answer-share.js`)의 공유 이미지는 구성이 같은 별도 사본이라 함께 고친다.

## 교훈
공개·이벤트성 화면을 급히 낼 때도 앱 공용 부품(목록 행·의미색 글자·토큰)으로 먼저 짠다. 칩·그라데이션이 보이면 원칙 위반 신호.
