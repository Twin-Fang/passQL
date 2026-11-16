---
type: issue
id: ISS-0531
created: 2026-11-16
topics: [concept-learning, practice]
symptoms: ["OX 퀴즈", "OX 카드", "간격 반복", "Leitner", "바로 확인 표", "concept_quick_check_card", "ConceptQuickCheckExtractor", "OxCardCatalog", "OxQuizService", "/api/ox/cards", "/api/ox/answers", "OX_CARD_NOT_FOUND", "ox_card_review", "연속 정답"]
root_cause: "OX 문항이 개념 읽기 안 확인 카드에만 있어 짧은 시간에 개념을 반복할 독립 복습 모드가 없었다(기능 부재)"
status: resolved
resolution: "[[ISS-0531-ox-quiz-expected-pass-lock-screen-ox-report]]"
related: ["[[ISS-0532-expected-pass-rate-mock-exam]]", "[[ISS-0533-lock-screen-ox-card-no-credit]]", "[[LSN-0006-ops-lookup-output-not-truncated]]"]
source: "_sources/issues/ISS-0531-ox-quiz-leitner-review.md"
---

# ISS-0531: OX 퀴즈 모드 — 간격 반복 복습, 연속 정답

GitHub #1083 (닫힘, 작업완료). 원본: https://github.com/Twin-Fang/passQL/issues/1083 · #1083·#1086·#1110 보고서 1개 공유.

## 증상
OX 문항은 개념 읽기 안 확인 카드(`concept_quick_check_card.dart`)에만 있어 개념을 짧게 반복할 독립 모드가 없었다.

## 재현 조건
앱 개념 학습. 경쟁 서비스 비교(2026-11-14)에서 나온 공백.

## 조사 기록
- 2026-11-14: 이슈 등록(즉시 해설, 간격 반복, 콤보, 하루 목표, 개념 확인 카드 데이터 재사용, 잠금화면 OX 검토).
- 2026-11-15: 구현 — 개념 '자세히' 본문의 '바로 확인' 표를 카드로 추출(코드 블록 안 표 제외), 카드 키 = 개념 uuid + 문장 해시, Leitner 5칸(틀리면 1칸, 맞히면 +1, 간격 1·2·4·7·14일). 노출은 개념 학습 공개·무료 단원 규칙 재사용. PR #1118 > 릴리스 #1119, 운영 v1.133.2.
- 2026-11-16: 운영 개념 학습 공개 스위치 확인 — 이미 켜져 있음(무료 단원 2개). 잘라 본 조회 출력으로 꺼져 있다고 잘못 판단한 일이 있었다([[LSN-0006-ops-lookup-output-not-truncated]]).

## 근본 원인
기능 부재. 완료 리포트 [[ISS-0531-ox-quiz-expected-pass-lock-screen-ox-report]].
