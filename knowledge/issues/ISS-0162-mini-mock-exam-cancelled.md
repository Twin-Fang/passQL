---
type: issue
id: ISS-0162
created: 2026-04-25
topics: [practice]
symptoms: ["미니 모의고사", "실전 시험 감각", "generateMiniExam", "mini_exam.question_count", "이어 풀기", "에픽 취소"]
root_cause: "해당 없음 — 기능 추가, 취소로 닫힘"
status: resolved
resolution: null
related: ["[[ISS-0160-ai-practice-set-epic-cancelled]]"]
source: "https://github.com/Twin-Fang/passQL/issues/305"
---

# ISS-0162: 미니 모의고사 기능 추가

GitHub #305 (원본: 이슈 본문과 2026-10-07 댓글). GitHub 상태는 closed(completed), 라벨 `취소`.

취소로 닫힘: "2026-04 시점의 웹 중심 기획이라 현재 서비스(Flutter 앱 + 데일리 세트 중심 학습 흐름)와 맞지 않는 오래된 명세로 보고 취소한다. 필요하면 현재 기준으로 새 이슈를 만든다."

## 증상
(현재 문제점) 문제를 하나씩만 풀 수 있어 실전 감각(SQLD 40문제 연속)을 익히기 어렵고, 여러 토픽을 짧게 점검하는 기능이 없다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-04-25 기획: 9개 토픽 균등 샘플링 10문제, 이전/다음 이동 없음, 토픽별 정답률 결과, 이탈 시 이어 풀기. BE `QuestionSetService.generateMiniExam()`, `POST /api/question-sets/mini-exam`, `GET /api/question-sets/{setId}`, `POST /api/question-sets/{setId}/questions/{questionUuid}/submit`, `app_setting` 키 `mini_exam.question_count`(기본값 10).
- 2026-10-07: 취소.

## 근본 원인
해당 없음.
