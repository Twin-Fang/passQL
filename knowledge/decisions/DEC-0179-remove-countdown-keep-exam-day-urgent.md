---
type: decision
id: DEC-0179
created: 2026-10-26
reviewed: null
topics: ["home"]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0395-home-countdown-badge-cleanup]]", "[[ISS-0395-home-countdown-badge-cleanup-report]]"]
---

# DEC-0179: 홈 인사 배지에서 `COUNTDOWN`만 없애고 `EXAM_DAY`·`URGENT`는 유지, 서버 `messageType`은 그대로 둔다

GitHub #648 (원본: 이슈 본문 「해결 방안」「작업 내용」과 2026-10-26 완료 리포트).

## 문제 정의 (Context)
홈 인사 아래 "시험까지 카운트다운 중이에요"(`COUNTDOWN`)가 같은 화면 시험 일정 카드의 D-일수와 겹치고, 무엇을 세는지 모르는 문장이라 어색했다(사용자 지적).

## 결정 (Decision)
- 홈 인사 아래 `COUNTDOWN` 배지를 없앤다. 시험 정보는 시험 일정 카드 한 곳에서 보여 준다.
- 시험 당일(`EXAM_DAY`)과 임박(`URGENT`) 배지는 남긴다.
- 서버 인사 응답(`messageType`)은 바꾸지 않는다(앱 표시 조건만 변경).

## 검토한 대안 (Alternatives)
- 배지를 모두 지우기: 버림. 리포트가 밝힌 이유 — "당일과 임박 상태가 시험 일정 카드만으로는 눈에 덜 띄기 때문".
- 서버 `messageType`에서 제거하기: 하지 않음. 이슈 본문의 이유 — "호환을 위해 그대로 둔다 (구버전 앱이 읽음)".

## 결과 (Consequences)
**긍정**
- 홈에서 시험 D-일수 정보가 한 곳(시험 일정 카드)으로 모인다.

**부정**
- 카운트다운 문구를 다시 넣으려면 시험 일정 카드와 겹치지 않는지 먼저 확인해야 한다(리포트 주의사항).

## 영향 범위 (Scope)
앱 `app/lib/presentation/widgets/home/greeting_section.dart`의 배지 표시 조건. v1.47.1 이후 빌드. 서버 인사 API는 영향 없음.

## 출처 (References)
- GitHub #648 이슈 본문, 완료 리포트 댓글(커밋 `384e7b05`)
- [[ISS-0395-home-countdown-badge-cleanup]]
