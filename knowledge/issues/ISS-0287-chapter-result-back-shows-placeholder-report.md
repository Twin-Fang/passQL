---
type: completion-report
id: ISS-0287
created: 2026-10-15
topics: [practice]
status: resolved
resolves: "[[ISS-0287-chapter-result-back-shows-placeholder]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/481"
---

# ISS-0287 완료 리포트: 최상위 `/chapter-result` 경로와 `pushReplacement`

GitHub #481 구현 보고서 댓글 기준 (1차 통합본).

## 해결 방법
- 최상위 경로 `AppRoutes.chapterResult = '/chapter-result'` 추가, `/practice/:sessionId` 경로와 자리표시 화면 삭제.
- 결과로 갈 때 `pushReplacement`: 챕터 화면 자리에 결과가 들어가 뒤로 가면 챕터 진입 전 화면(문제 목록).
- `PracticeResultPage`를 `pages/questions/chapter_result_page.dart`의 `ChapterResultPage`로 이동. Analytics 화면 이름 표도 `chapter_result`로.
- 검증: 시스템 뒤로 가기 위젯 테스트 추가, `flutter analyze` 경고 0, `flutter test` 271개 통과, 시뮬레이터 스와이프 확인(라이트·다크).

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
주의(원본): Android 실기기 뒤로 버튼은 직접 확인하지 못했고, 같은 pop 경로라 위젯 테스트로 확인했다.

## 교훈
(원본에 없음, 볼트 정리) 결과 화면처럼 되돌아가면 안 되는 화면은 이동 방식(`go`/`push`/`pushReplacement`)과 경로 계층을 함께 본다.
