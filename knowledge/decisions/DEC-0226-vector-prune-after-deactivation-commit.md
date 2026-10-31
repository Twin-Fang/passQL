---
type: decision
id: DEC-0226
created: 2026-10-31
reviewed: null
topics: [ai, question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0434-audit-followup-split-large-files]]", "[[ISS-0434-audit-followup-split-large-files-report]]", "[[ISS-0244-qdrant-orphan-vectors-index-mismatch]]", "[[DEC-0127-question-delete-as-deactivation]]", "[[DEC-0203-discussion-stats-refresh-after-commit-event]]"]
---

# DEC-0226: 문제 비활성화 후 벡터 정리(`pruneIndex`)는 컨트롤러 직접 호출 대신 `QuestionsDeactivatedEvent`를 커밋 후(AFTER_COMMIT) 받아 한 번 하고, 실패는 로그만 남긴다

## 문제 정의 (Context)
관리자 컨트롤러 3곳이 문제 비활성화 뒤 `pruneIndex()`를 직접 불렀다 (GitHub #762 구조 정리).

## 결정 (Decision)
- 문제 비활성화 서비스가 `QuestionsDeactivatedEvent`를 발행하고, `QuestionVectorIndexService.onQuestionsDeactivated`가 커밋 후(AFTER_COMMIT) 벡터 정리를 1회 한다.
- 정리를 하느냐 마느냐와 커밋 뒤에 실행된다는 시점은 예전과 같다.
- 정리 실패는 리스너 안에서 로그만 남긴다(예전에는 요청 처리 중 실행돼 예외가 요청까지 전파될 수 있었다).

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음. (원본: 컨트롤러 3곳의 직접 호출이 사라졌다.)

**부정**
- 리스너가 실제로 실행되는지는 배포 후 관리자 비활성화 로그로 확인해야 한다(리포트 시점 미확인).

## 영향 범위 (Scope)
서버 `QuestionsDeactivatedEvent`, `QuestionVectorIndexService`, 관리자 문제 비활성화 경로, AI `POST /api/ai/prune-index` 호출 시점.

## 출처 (References)
- GitHub #762 리포트 댓글 흐름도·「변경 사항」·「주의 사항」
- [[ISS-0434-audit-followup-split-large-files-report]]
