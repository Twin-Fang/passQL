---
type: completion-report
id: ISS-0351
created: 2026-10-21
topics: [practice]
status: resolved
resolves: "[[ISS-0351-daily-set-resume-preview-table]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/566"
---

# ISS-0351 완료 리포트: 서버가 문제별 오늘 첫 제출 정오를 내려 이어 풀기, 미리보기 표는 `[표]`

GitHub #566 리포트 댓글(`## 개요`, 2026-10-21) 기준. 커밋 99ba2396(미리보기), 0a551181(이어 풀기).

## 해결 방법
- 미리보기: `server/PQL-Common/.../MarkdownTextStripper.java`가 표 블록을 `[표]`로(`replaceTables`), 평문 변환이 `EMP_ID`의 밑줄까지 지우던 것을 강조 밑줄만 지우게. `QuestionService.toSummary`(문제 목록·추천), `ProgressService.buildStemPreview`(오답 노트)에 적용.
- 이어 풀기: `DailySetTodayResponse.answeredResults`, `HomeService`가 풀다 만 세트의 문제별 오늘 첫 제출 정오를 내림(완료·비로그인 null). `api-contract/openapi.json`·웹 생성 타입 갱신. `DailySetService` 완료 점수를 오늘 세트 전체 문제의 오늘 첫 제출로 계산(세션이 나뉘어도 앞 세션 문제 포함). 앱 `ChapterStart`, `QuestionFlow.loadStart`, `ChapterNotifier.load`, 웹 `toResumedResults`, `startSession`.
- 앞에서부터 이어진 제출만 결과로 복원하고 마지막 문제는 남긴다.

## 근본 원인 (확정)
진행 복원 데이터가 응답에 없었고, 미리보기 정리가 표를 다루지 않았다.

## 재발 방지
- 검증: 서버 DailySet·MarkdownTextStripper·OpenAPI 계약·아키텍처 테스트, 앱 `flutter test` 529, 웹 vitest 103 통과. 운영 배포 후 iOS 시뮬레이터에서 1·2번 제출한 세트가 3 / 10부터 시작, 오답 노트 미리보기 `[SALES_Q] [표]`.
- 주의: 이어 푼 문제의 소요 시간은 0, 선택 보기 원문 없음("이전 풀이에서 제출"). 마지막 문제까지 제출한 채 완료 등록에 실패했다면 마지막 문제를 다시 풀어 완료(이번 세션 제출이 있어야 완료 가능). 문제 순서는 회원+날짜 고정 셔플이라 셔플 규칙을 바꾸면 이어 풀기 순서도 확인한다.
- 앱 반영: Android 1.30.3 내부·비공개 테스트 업로드. iOS는 1.27.0 심사 중이라 다음 버전으로.

## 교훈
(원본에 없음, 볼트 정리) 지문에 새 문법을 넣으면 본문 렌더러뿐 아니라 서버 미리보기 정리 함수도 함께 고친다.
