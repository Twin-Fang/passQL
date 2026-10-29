---
type: completion-report
id: ISS-0217
created: 2026-10-07
topics: [practice]
status: resolved
resolves: "[[ISS-0217-daily-set-revisit-per-question-results]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/372"
---

# ISS-0217 완료 리포트: 완료 세트면 `results`를 내려주고 마지막 제출로 문제별 정오 복원

GitHub #372 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
- 서버(`HomeService.getToday`): 이미 완료한 세트면 `results`(문제별 정답 여부, questions 순서와 동일)를 함께 내려준다. 세트 기록에는 정답 수만 있으므로 완료 시각 이전의 마지막 제출로 문제별 정오를 복원(`SubmissionRepository.findFirstBy…SubmittedAtBetweenOrderBySubmittedAtDesc`).
- 앱: `DailySetTodayResponse.results` 추가, 재진입 화면이 이 값으로 "문제별 결과" 표시. 기록이 빠진 문제가 있으면 정오를 지어내지 않도록 목록을 숨긴다.

## 근본 원인 (확정)
세트 기록에 문제별 정오가 저장되지 않고 정답 수만 있었다.

## 재발 방지
서버 `DailySetTodayResultsTest` 2건, 앱 모델 테스트 2건 통과. 서버 배포 후 실측: 10문제 완료 → 재진입 시 완료 직후와 같은 문제별 결과(4·5번 정답) 표시.

## 교훈
(원본에 없음, 볼트 정리) 문제별 정오는 세트 기록이 아니라 제출 기록에서 복원된다. 제출 기록이 빠지면 목록이 숨겨지는 것이 정상 동작이다.
