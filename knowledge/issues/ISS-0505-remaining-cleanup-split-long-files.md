---
type: completion-report
id: ISS-0505
created: 2026-11-12
topics: [dev-workflow, design-system]
status: resolved
resolves: "[[ISS-0505-remaining-cleanup-split-long-files]]"
related: ["[[ISS-0500-code-consult-today-changes]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1029"
---

# ISS-0505 완료 리포트: 남은 정리 항목 (중복 문구, 긴 파일 분리, 잠금화면 점검)

## 해결 방법 (PR #1030, 동작 변경 없음)
- 「결과를 불러올 수 없어요」·「다시 시도」 > `PassqlLoadFailureCopy` 단일 원본.
- 500줄 초과 3개 분리: concept_result_view 1158 > 342, concept_perfect_page 599 > 300, admin app-operation.html 503 > 61(조각 2·정적 JS 2).
- chapter_page 482 > 286(진행 흐름 mixin), QuestionService 443 > 236(AdminQuestionSearchService·QuestionDetailService·QuestionChoiceSetQueryService).
- 잠금화면 boolean 접두사, 크레딧 소진 문구 `freeDailyLimitReason` 사용.

## 주의할 점
- 관리자 인라인 스크립트를 정적 JS로 옮길 때: Thymeleaf 인라인 변수(`[[${...}]]`) 없음 확인 + `onclick` 함수는 `window`에 공개.
- 다른 세션이 바꾸는 중인 app_router·home_page·passql_reward_celebration 은 제외(다음 차례).
