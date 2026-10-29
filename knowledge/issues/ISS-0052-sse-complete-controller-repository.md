---
type: issue
id: ISS-0052
created: 2026-04-11
topics: [practice]
symptoms: [CONCEPT_ONLY, "SSE complete 미전송", "선택지 준비 중... 무한 대기", "[choice-gen-concept] success", choiceSetItemRepository, VirtualThread, "catch 로그 없음", "silent fail"]
root_cause: "원본에 확정 기록 없음 — 이슈 본문은 Controller가 choiceSetItemRepository를 직접 주입해 VirtualThread에서 트랜잭션 없이 조회하다 예외가 났을 가능성과 catch 블록 로그 부재를 지목"
status: resolved
resolution: null
related: ["[[ISS-0050-sse-complete-hikaripool-self-invocation]]"]
source: "https://github.com/Twin-Fang/passQL/issues/95"
---

# ISS-0052: CONCEPT_ONLY 선택지 생성 성공 후 SSE `complete` 미전송 — Controller의 Repository 직접 주입

GitHub #95 (원본: 이슈 본문만, 댓글 없음). `긴급`·`작업완료` 라벨로 닫혔으나 완료 기록은 없다.

## 증상
`executionMode = CONCEPT_ONLY` 문제에서 서버 로그에 `[choice-gen-concept] success`가 찍히는데 브라우저 EventStream에 `complete` 이벤트가 오지 않아 "선택지 준비 중..."에서 무한 대기. `catch (Exception e)` 블록에 로그가 없어 예외 여부를 추적할 수 없다.

## 재현 조건
CONCEPT_ONLY 문제 페이지 진입 → `generate-choices` 요청 → 서버 success 로그 확인 → EventStream에 `complete` 없음. 환경: Docker(Linux) 서버, Vercel·로컬.

## 조사 기록
- 이슈 본문: `QuestionController.generateChoices()`가 `choiceSetItemRepository`를 직접 주입해 호출한다(CLAUDE.md 규칙 "Controller에서 Repository 직접 주입 금지" 위반). VirtualThread 안에서 `@Transactional` 컨텍스트 없이 조회해 예외가 났을 수 있다.
- 예상 동작: Repository 조회는 Service 레이어의 트랜잭션 안에서, catch 블록은 로그를 남긴다. 실제 수정 내용은 원본에 적혀 있지 않다.

## 근본 원인
원본에 확정 기록이 없다(이슈 본문의 추정만 있음).
