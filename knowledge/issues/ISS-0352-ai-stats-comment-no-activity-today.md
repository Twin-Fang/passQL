---
type: issue
id: ISS-0352
created: 2026-10-21
topics: [ai, progress-stats]
symptoms: ["AI 영역 분석", "활동이 없어", "오늘 날짜 없음", buildRecentActivitySummary, AiCommentService, evictCache, "통계 코멘트 캐시", statsAiCommentProvider, "learning_refresh"]
root_cause: "프롬프트에 오늘 날짜가 없었고, 통계 코멘트 캐시(2시간)를 비우는 호출이 없었으며, 앱 공통 갱신이 통계 AI 코멘트를 제외했다"
status: resolved
resolution: "[[ISS-0352-ai-stats-comment-no-activity-today-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/567"
---

# ISS-0352: AI 영역 분석이 오늘 푼 기록을 두고 '10월 21일 이후 활동이 없다'고 서술

GitHub #567 (원본: 이슈 본문과 댓글).

## 증상
통계 탭 AI 영역 분석이 "2026년 10월 21일 이후 활동이 없어 꾸준한 학습 습관을 유지하는 것이 중요"라고 서술. 실제로는 2026-10-21 당일 문제를 풀었다.

## 재현 조건
오늘 문제를 1개 이상 풀고 통계 탭 > AI 영역 분석 문구 확인. iOS 18.3 시뮬레이터, 운영 서버.

## 조사 기록
- 2026-10-21 디버깅 경위(리포트):
  1. 제출 시각 저장 기준 확인: KST 저장(GitHub #560) → 날짜 계산은 정상.
  2. 프롬프트에 "최근 활동일: 2026-10-21"만 있고 오늘 날짜 없음 → 모델이 과거로 해석(1차 수정).
  3. 배포 뒤에도 같은 문구 → 앱 Dio 로그로 배포 뒤 ai-comment 요청 0건, 서버 캐시 삭제 함수(`evictCache`)는 운영 코드에서 호출하는 곳이 없음 → 캐시 키에 활동 요약 해시(2차).
  4. 당겨서 새로고침하면 새 문구, 풀이 후 탭 이동만으로는 갱신 안 됨 → 앱 공통 갱신(GitHub #497)이 AI 코멘트를 "풀이와 무관"으로 제외 → 갱신 대상에 추가(3차).

## 근본 원인
세 겹: 프롬프트에 오늘 날짜 없음, 서버 통계 코멘트 캐시 무효화 없음, 앱이 풀이 후 통계 AI 코멘트를 다시 받지 않음.
