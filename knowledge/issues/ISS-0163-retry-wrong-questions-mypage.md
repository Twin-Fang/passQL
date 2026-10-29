---
type: issue
id: ISS-0163
created: 2026-04-25
topics: [practice]
symptoms: ["틀린 문제 다시 풀기", "오답 노트", "오답 목록", "/api/progress/wrong-questions", "/settings/wrong-notes", "해결됨 표시"]
root_cause: "해당 없음 — 기능 추가(오답 재시도 동선 부재)"
status: resolved
resolution: "[[ISS-0163-retry-wrong-questions-mypage-report]]"
related: ["[[ISS-0160-ai-practice-set-epic-cancelled]]", "[[ISS-0174-app-wrong-notes-nickname-choice-mode]]"]
source: "https://github.com/Twin-Fang/passQL/issues/306"
---

# ISS-0163: 마이페이지 틀린 문제 다시 풀기

GitHub #306 (원본: 이슈 본문과 2026-10-07 댓글). 기능 이슈, 에픽 GitHub #303의 하위 이슈.

## 증상
(현재 문제점) 오답을 제출한 뒤 다시 돌아가 풀 방법이 없고, 마이페이지 학습 통계에서 틀린 문제 재시도로 이어지는 동선이 없다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-04-25 기획: 마이페이지 "틀린 문제" 탭(최신순), "다시 풀기" 버튼, 재시도 정답 시 "해결됨", 토픽별/최근 N일 필터. BE `GET /api/progress/wrong-questions?memberUuid=&topic=&limit=&page=`, `submission` 테이블 `is_retry: true` 플래그.
- 2026-10-07: 구현 확인 댓글(아래 리포트).

## 근본 원인
해당 없음 (기능 추가).
