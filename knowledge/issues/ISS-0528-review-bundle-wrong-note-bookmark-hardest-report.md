---
type: completion-report
id: ISS-0528
created: 2026-11-16
topics: [practice, progress-stats]
status: resolved
resolves: "[[ISS-0528-wrong-note-subject-filter-retry-set]]"
related: ["[[ISS-0529-hardest-questions-top30]]", "[[ISS-0530-question-bookmark-practice]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1081#issuecomment-6902549837"
---

# ISS-0528 완료 리포트: 복습 묶음 — 오답노트 강화(#1081), 즐겨찾기(#1082), 오답률 TOP 30(#1080)

세 이슈가 보고서 1개를 공유한다(#1080·#1082 댓글도 같은 본문). 이 리포트가 [[ISS-0528-wrong-note-subject-filter-retry-set]]·[[ISS-0529-hardest-questions-top30]]·[[ISS-0530-question-bookmark-practice]] 를 함께 닫는다. PR #1108 > 릴리스 PR #1112. 서버·Android 반영, iOS 는 1.132.0 심사 중이라 TestFlight 까지(다음 iOS 릴리스에 포함).

## 해결 방법
- 공통: 세 기능 모두 앱 `QuestionFlow`(문제 묶음 순서 풀이) 위에 얹어 풀이 화면은 새로 만들지 않음. 공통 행 `QuestionPreviewRow`, 흐름 3종 `WrongNoteRetryFlow`·`BookmarkFlow`·`HardestFlow`, 서버 지문 미리보기 `QuestionStemPreview` 단일화.
- 오답노트: `GET /api/progress/wrong-questions?subject&sort&includeResolved&size`(항목 `wrongCount`·`isResolved`·`subject`), `GET /api/progress/wrong-questions/retry-set`(정리 안 된 오답 최대 10개). 정리됨 = 그 문제 최신 제출이 정답. `WrongNoteSelector`(순수 함수: 과목 거르기 > 정리됨 빼기 > 정렬). 앱: 과목 세그먼트, 정렬 시트, 정리된 문제 보기 스위치.
- 즐겨찾기: `V1_133_1__question_bookmark.sql`, `PUT|DELETE /api/questions/{uuid}/bookmark`(멱등), `GET /api/bookmarks`, `GET /api/bookmarks/practice-set`(랜덤 10), 문제 상세 `isBookmarked`. 무료 포함 개수 제한 없음. 앱 별 버튼(먼저 반영, 실패 시 되돌림), 프로필 즐겨찾기 행.
- 오답률 TOP: `GET /api/questions/hardest?limit=30` — `HardestQuestionQueryRepository`(회원별 첫 제출만, 테스트 계정 제외) + `HardestQuestionRanker`(첫 제출 20명 이상, 오답률 내림차순) + `HardestQuestionService`(1시간 캐시). 앱 문제 탭 입구(무료 포함).
- 검증: 서버 테스트 254, `OpenApiContractTest`, `flutter analyze` 0, `flutter test` 188. 로컬 PostgreSQL 실측(검증용 회원 25명·제출 61건, 확인 후 삭제). 운영 마이그레이션 v1.133.1 적용·정상 기동.

## 근본 원인 (확정)
기능 부재(복습 기능 공백 3개, 경쟁 서비스 비교 2026-11-14).

## 재발 방지
- 오답률 집계는 1시간마다 submission 전체를 훑는다. 제출이 크게 늘면 미리 집계 테이블로 옮긴다.
- 문제 탭 오답노트 개수는 "정리 안 된 오답" 기준이라 예전보다 작게 보일 수 있다(문의 대응 시 참고).
- 해설 결과 화면(`ResultPage`)에는 별이 없다 — 별 상태를 읽으려면 문제 상세를 다시 불러야 해 무료 한도에 영향.

## 교훈
새 문제 묶음 풀이 기능은 `QuestionFlow` 에 흐름 클래스 하나를 더하는 방식으로 붙인다. 오답·즐겨찾기 개수가 이상하면 정리됨 판정(최신 제출 정답)과 `includeResolved` 를 먼저 확인한다.
