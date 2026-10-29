---
type: decision
id: DEC-0087
created: 2026-04-27
reviewed: null
topics: [ai, practice]
status: active
supersedes: DEC-0028
superseded_by: null
related: ["[[ISS-0167-choice-generation-practice-real-mode]]", "[[ISS-0174-app-wrong-notes-nickname-choice-mode]]", "[[DEC-0028-realtime-choice-set-with-prefetch]]", "[[DEC-0141-curated-only-oracle-verified-choices]]", "[[DEC-0158-new-questions-concept-only-curated]]", "[[DEC-0052-result-match-policy-equivalence-type]]"]
---

# DEC-0087: 선택지 생성 모드를 연습(`PRACTICE`, 검증된 선택지 재사용)과 실전(`REAL`, 항상 AI 실시간 생성)으로 나눈다

## 문제 정의 (Context)
프리페치 미스 때마다 AI 실시간 생성(최대 60초 가까이 대기)을 하면서 다른 사용자용으로 검증된 선택지를 버리고 있었다 (GitHub #313).

## 결정 (Decision)
사용자 설정 `choiceGenerationMode`(`PRACTICE` / `REAL`)를 둔다.
- 연습 모드: (1) 본인 프리페치(`source=AI_PREFETCH`, `generatedForMemberUuid=현재사용자`, `consumed_at IS NULL`) → (2) 다른 사용자 포함 전체 `status=OK` 중 최신 1건 → (3) 모두 미스면 AI 실시간 생성.
- 실전 모드: 프리페치·기존 선택지 조회 없이 바로 AI 실시간 생성(`source=AI_RUNTIME`).

이 내용은 #313 이슈 본문의 제안이며, #313에는 구현 완료 기록이 없다. 앱 GitHub #329가 서버 API `/members/me/settings/choice-generation-mode`와 `PRACTICE/REAL` 토글을 구현했다고 적는다.

## 검토한 대안 (Alternatives)
- 기존 방식(본인 프리페치만 히트, 나머지는 항상 실시간 생성): 대기 시간 문제로 바꾸려 함. 이것이 실전 모드로 남는다.
- 그 밖의 대안: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 연습 모드에서 검증된 선택지를 재사용해 대기를 줄인다(원본 동기).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`ChoiceSetResolver`, 선택지 조회 쿼리, 회원 설정, 웹 `Settings.tsx`, 선택지 생성 API 요청, 앱 설정 토글(GitHub #329).

## 출처 (References)
- GitHub #313 이슈 본문 "해결 방안"
- GitHub #329 구현 댓글(2026-10-02)
