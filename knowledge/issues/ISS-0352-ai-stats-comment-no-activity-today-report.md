---
type: completion-report
id: ISS-0352
created: 2026-10-21
topics: [ai, progress-stats]
status: resolved
resolves: "[[ISS-0352-ai-stats-comment-no-activity-today]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/567"
---

# ISS-0352 완료 리포트: 프롬프트에 오늘·N일 전, 캐시 키에 활동 요약 해시, 앱 갱신 대상 추가

GitHub #567 리포트 댓글(`## 개요`, 2026-10-21) 기준.

## 해결 방법
- `AiCommentService.java`: `toRecentActivitySummary`(오늘: yyyy-MM-dd, 최근 활동일 "(오늘)/(N일 전)"), 통계 캐시 키 `ai-comment:{회원}:stats:{요약 해시}`.
- `AiCommentRecentActivityTest.java`: 오늘·N일 전·없음 3건.
- `app/lib/presentation/providers/learning_refresh.dart`: 풀이 후·날짜 변경 갱신에 `statsAiCommentProvider` 추가.

## 근본 원인 (확정)
프롬프트에 오늘 날짜가 없어 모델이 최근 활동일을 과거로 해석했고, 캐시 무효화 호출 부재와 앱 갱신 제외로 고친 뒤에도 옛 문구가 남았다.

## 재발 방지
- 운영 검증: 수정 전 "2026년 10월 21일 이후 활동이 없어" > 수정 후 "최근 7일 동안 20문제를 풀이하며 꾸준히 학습하고 계시니". 문제 1개 제출 후 통계 탭 진입만으로 ai-comment 재요청 확인.
- 주의: 같은 활동 상태면 서버 캐시를 재사용해 Gemini 호출은 "새로 푼 뒤 통계를 볼 때" 1회. 앱 갱신 변경은 다음 앱 버전부터(Android 1.30.3 업로드, iOS는 1.27.0 심사 중이라 다음 버전).

## 교훈
(원본에 없음, 볼트 정리) 상대 시간 표현을 모델에 맡길 때는 기준일(오늘)을 프롬프트에 함께 넣는다. 고친 뒤에도 문구가 그대로면 캐시와 클라이언트 재요청 여부를 차례로 본다.
