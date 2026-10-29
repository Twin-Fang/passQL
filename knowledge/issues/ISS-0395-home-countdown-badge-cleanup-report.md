---
type: completion-report
id: ISS-0395
created: 2026-10-26
topics: ["home"]
status: resolved
resolves: "[[ISS-0395-home-countdown-badge-cleanup]]"
related: ["[[DEC-0179-remove-countdown-keep-exam-day-urgent]]"]
source: "https://github.com/Twin-Fang/passQL/issues/648"
---

# ISS-0395 완료 리포트: 홈 인사 아래 `COUNTDOWN` 배지 제거, `EXAM_DAY`·`URGENT`만 유지

GitHub #648 완료 리포트 댓글(2026-10-26) 기준. 근거 커밋 `384e7b05`.

## 해결 방법
`app/lib/presentation/widgets/home/greeting_section.dart`: 배지 표시 조건에서 `COUNTDOWN` 제외. v1.47.1부터 반영, 스토어 심사를 통과한 1.51.1 빌드에도 포함.

## 근본 원인 (확정)
인사 배지 표시 조건이 `COUNTDOWN`을 포함해 시험 일정 카드의 D-일수와 같은 정보를 두 번 보여 줬다.

## 재발 방지
카운트다운 문구를 다시 넣으려면 시험 일정 카드와 겹치지 않는지 먼저 확인해야 한다(리포트 주의사항).

## 교훈
(원본에 없음, 볼트 정리) 홈에 시험 관련 문구를 추가할 때는 같은 화면의 시험 일정 카드가 이미 보여 주는 정보인지 먼저 본다.
