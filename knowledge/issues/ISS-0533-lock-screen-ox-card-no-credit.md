---
type: issue
id: ISS-0533
created: 2026-11-16
topics: [practice, concept-learning]
symptoms: ["잠금화면 OX", "잠금화면 OX 카드", "크레딧 없음", "LockScreenOxTurnRule", "문제 3번에 OX 1번", "잠금화면 긴 객관식", "한 문제 더 크레딧"]
root_cause: "Android 잠금화면 문제는 지문이 긴 객관식이라 잠깐 켠 순간 풀기 부담스럽고, 개념 복습을 잠금화면으로 이을 길이 없었다(기능 부재)"
status: resolved
resolution: "[[ISS-0531-ox-quiz-expected-pass-lock-screen-ox-report]]"
related: ["[[ISS-0531-ox-quiz-leitner-review]]", "[[DEC-0314-lock-screen-free-reason-pro-detail-continue]]"]
source: "_sources/issues/ISS-0533-lock-screen-ox-card-no-credit.md"
---

# ISS-0533: 잠금화면에 OX 복습 카드 섞기 (크레딧 없음)

GitHub #1110 (닫힘, 작업완료). 원본: https://github.com/Twin-Fang/passQL/issues/1110 · #1083 보고서 공유. 선행 [[ISS-0531-ox-quiz-leitner-review]].

## 증상
잠금화면 문제는 긴 객관식이라 부담스럽고 "한 문제 더"는 크레딧 1개를 쓴다. OX 복습을 잠금화면에서 이어 갈 수 없었다.

## 재현 조건
Android 잠금화면 문제 기능.

## 조사 기록
- 2026-11-15: 이슈 등록 — OX 카드는 크레딧 미사용, 기본 3:1 섞기 + 설정에서 비율 선택 제안, 기한 카드 우선, 무료는 무료 단원 카드만.
- 2026-11-16 결정 갱신(이슈 댓글): 비율 설정 화면 없음, 문제 3번에 OX 1번 고정(기존 간격 설정 그대로), #1083 과 같은 브랜치에서 이어 구현. 설정 화면을 뺀 이유는 논의 기록 없음.
- 2026-11-15~16 구현: `LockScreenOxTurnRule` 기기 카운터(표시 4번째마다 OX), 카드 없거나 실패면 기존 문제, OX 경로는 크레딧 API 미호출, 응답은 `POST /api/ox/answers` 로 OX 화면과 기록 공유, 인증 Dio·로그인 재확인(#1071) 재사용. 실기기 표시는 미확인(렌더 캡처).

## 근본 원인
기능 부재. 완료 리포트 [[ISS-0531-ox-quiz-expected-pass-lock-screen-ox-report]].
