---
type: completion-report
id: ISS-0356
created: 2026-10-22
topics: [home, design-system, practice]
status: resolved
resolves: "[[ISS-0356-home-questions-tab-restructure]]"
related: ["[[DEC-0166-tab-roles-home-read-questions-solve]]", "[[DEC-0167-five-tabs-with-text-labels]]", "[[DEC-0168-text-only-color-tokens]]"]
source: "https://github.com/Twin-Fang/passQL/issues/574"
---

# ISS-0356 완료 리포트: 탭 역할 분리, 탭 이름 표시, 디자인 시스템 공통 접근성 수정

GitHub #574 리포트 댓글 4개(`## 개요`, 2026-10-21 두 건, 2026-10-22 두 건)와 배포 결과 댓글 기준. PR #583(`25b23ba2`), 서버·웹 변경 없음.

## 해결 방법
1차(출제 경향 분리):
- 홈: '이번 시험 출제 경향' 섹션 + 오늘의 공부 팁 카드. 문제 탭: 세그먼트 3개 `주제별`(맨 위 오답 노트 바로가기) / `최신 경향` / `개념 TOP 10`. 설정 '기록' 묶음 제거. 출제 경향 전용 화면 삭제, `/exam-trend`는 문제 탭 `최신 경향`으로 리다이렉트.
- `app/lib/router/questions_tab_view.dart`(세그먼트 ↔ `?view=` 쿼리), `exam_trend_providers.dart`(로그아웃 가드를 Provider 안으로, `selectDailyStudyTip`), 광고 규칙 테스트에서 문제 탭 네이티브 광고 1칸 → 3칸.
- 구현 근거(리포트): 홈과 문제 탭이 같은 `examTrendReportProvider`를 써서 값이 어긋나지 않게, 세그먼트 상태의 원본은 URL(`context.go(view.location)`), 유형·개념 `latestTrendQuestionCount`는 토픽 전체 문제 수(`ExamTrendService.questionCountOf`)라 "토픽명 문제 N개"로 표시, 광고는 페이지에서 만들어 `adSlot`으로 넘김.

2차(앱 전체 발견성·접근성, `b3679881..ed51d99e`, 114개 파일):
- 하단 탭 아이콘 + 이름(홈 / 문제 / 토론 / 기록 / MY), 높이 49, 경로 유지 — [[DEC-0167-five-tabs-with-text-labels]].
- 홈: '일정 선택하기' 제거(사용자가 시험 일정을 고르는 서버 API가 없음, 관리자 API만), 오늘의 세트 카드에 '순위 보기'. 문제 탭 공통 영역에 오답 노트·풀이 모드 스위치. 기록 탭 재구성·빈 상태 안내. MY에 '알림함·공지'.
- 결과·풀이 나가기를 `leaveSolvingFlow`로 모아 들어온 곳으로 복귀(딥링크면 홈). 오늘의 세트는 `pushReplacement`.
- 접근성: `PassqlSemanticButton`(탭 동작 7곳 복구, 규칙 테스트), `PassqlPressable` 이중 낭독 제거·44pt, `PassqlSegmentedControl` 통합, 글자 전용 토큰 `accentText`·`warningText`·`onSemantic`·`iconSecondary` — [[DEC-0168-text-only-color-tokens]], `PassqlLoadingSemantics`, 글자 크기 상한 1.4 유지·고정 높이 배율 대응, 동작 줄이기 시 스켈레톤 반짝임 정지.

3차(`c447dc56`): 홈 출제 경향을 강조색 유형 카드 1장씩 넘김(`PageView`) + 페이지 점, 시작 카드는 `rotateToDailyStart`로 날짜마다 회전(공부 팁과 순환 계산 공유). `PassqlCard.shouldChildFillHeight` 추가.

GitHub #576 결제 병합(f3595aad, PR #582): 충돌 12개 해소하며 무료 잠금을 새 화면 구조로 옮김.

## 근본 원인 (확정)
원본에 따로 서술 없음. 이슈 본문의 "기능은 많은데 찾기 어렵다"와 점검 결과가 출발점.

## 재발 방지
- 검증: `flutter test` 546 → 604 → 606(병합본), #576 병합본 673 통과. 시뮬레이터 라이트·다크·글자 최대 캡처. 배포 #584 후 운영 `GET /api/meta/app-config` 200, `isAndroidBillingEnabled: false`. iOS `1.36.1` 심사 제출, Android `1.36.0(355)` internal·alpha(production은 GitHub #568 대기).
- 주의: `QuestionsTabView.queryValue`와 탭 경로는 외부 링크 값(이름을 바꾸면 옛 링크가 깨짐). `leaveSolvingFlow`의 흐름 경로 집합(`router/solving_flow_exit.dart`)은 풀이 라우트와 맞아야 함. 글자에 `accent`를 직접 쓰면 다크 대비 미달. 광고 개수는 `ad_placement_rules_test.dart`가 고정. 출제 경향 응답 null은 무료 잠금이라는 뜻(실패로 바꾸면 무료 사용자에게 오류 화면). 넘김 카드 높이 상수(`_baseCardContentHeight`·`_scalingTextLines`). `shouldChildFillHeight`는 높이가 바깥에서 정해지는 곳에서만. 운영 공지 본문이 옛 화면을 안내함(앱 업데이트 때 수정 필요).
- 남은 일: 실기기 VoiceOver/TalkBack 확인, 작은 화면(SE) 캡처 미실시, 웹 출제 경향 화면은 범위 밖.

## 교훈
(원본에 없음, 볼트 정리) 접근성 결함은 화면별이 아니라 공통 컴포넌트(시맨틱 버튼·토큰)에서 고치고 규칙 테스트로 고정한다.
