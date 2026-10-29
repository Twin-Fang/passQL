---
type: decision
id: DEC-0093
created: 2026-10-07
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0183-hackathon-leftover-cleanup]]", "[[ISS-0183-hackathon-leftover-cleanup-report]]"]
---

# DEC-0093: AI 작업 산출물과 해커톤 기획 문서는 삭제하지 않고 `.gitignore`로 레포 추적만 해제한다

## 문제 정의 (Context)
정식 서비스 전환을 위해 해커톤 잔재(문서, 목업, 개발용 화면, `.bak`)를 정리해야 했다 (GitHub #338).

## 결정 (Decision)
`.bak` 10개, AI 작업 산출물(`docs/superpowers`, `docs/projectops`, `client/docs/superpowers`, `app/docs/superpowers`), 해커톤 기획·분석 문서(`docs/product`, `docs/reports`, `client/docs`, `server/docs/apilog`)를 `.gitignore`로 추적 해제한다. "로컬 파일은 그대로 두고 레포에서만 뺐다(git 기록에는 남아 있음)"(커밋 `2acdd33`, `5f7bbe0`).

## 검토한 대안 (Alternatives)
- 파일 삭제: 1차(2026-10-02)에는 일부 문서·목업을 승인 후 삭제했다. 이번 묶음을 삭제 대신 추적 해제로 처리한 이유는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`.gitignore`, 위 경로들. 이미 적용된 마이그레이션은 이 정리에서 유지(원본).

## 출처 (References)
- GitHub #338 "정리 결과" 댓글(2026-10-07)
