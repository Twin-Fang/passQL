---
type: issue
id: ISS-0336
created: 2026-10-20
topics: [question-bank]
symptoms: ["출제 경향", "2026 경향", "58~62회", "약한 오답 보기", "정답 오류", "문제 풀 보강", "최신 경향 지정", batch04, batch05]
root_cause: "#511·#523·#524로 추가한 37문제의 경향 근거가 얕아 빈 유형이 남았고, 기존 풀에 경향과 먼 문제·약한 보기가 남아 있었다"
status: resolved
resolution: "[[ISS-0336-sqld-2026-trend-question-pool-refresh-report]]"
related: ["[[DEC-0158-new-questions-concept-only-curated]]"]
source: "https://github.com/Twin-Fang/passQL/issues/548"
---

# ISS-0336: SQLD 2026 출제 경향 재수집, 신규 문제 양산, 기존 문제 풀 보강

GitHub #548 (원본: 이슈 본문과 댓글).

## 증상
기능 이슈. 현재 문제점:
- GitHub #511, #523, #524로 2026년 58~62회 경향을 반영한 문제 37개를 추가했지만 경향 근거가 얕았고 문제 풀에 빈 유형이 남아 있다.
- 기존 문제 풀에 2026 경향(결과 추적형, 개념 2~3개 결합)과 거리가 먼 문제와 약한 오답 보기가 남아 있다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-20: 경향 근거 보강, 유형 목록 갱신(상세 자료는 암호화본), 신규 문제 묶음 작성 후 검증 도구 Oracle 실행 검증, 운영 반영.

## 근본 원인
경향 근거가 얕아 유형 목록에 빈 곳이 있었고 기존 풀 점검이 되어 있지 않았다(이슈 본문 기준).
