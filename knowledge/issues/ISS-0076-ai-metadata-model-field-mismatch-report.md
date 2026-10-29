---
type: completion-report
id: ISS-0076
created: 2026-04-11
topics: [ai]
status: resolved
resolves: "[[ISS-0076-ai-metadata-model-field-mismatch]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/132"
---

# ISS-0076 완료 리포트: 작업 완료 (수정 방식 기록 없음)

GitHub #132 "작업 완료" 댓글 기준 (2026-04-11). 리포트 형식 댓글은 없음.

## 해결 방법
원본에 적혀 있지 않다. 어느 쪽(Python 필드명 / Java DTO)을 고쳤는지 기록이 없다.

## 근본 원인 (확정)
이슈 본문 기준 필드명 불일치(`model` vs `model_name`). 완료 댓글에서 따로 확인한 내용은 없다.

## 재발 방지
원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) Python AI 서버 호출이 실패하고 Gemini fallback으로 빠지면 네트워크·인증(GitHub #125)뿐 아니라 응답 역직렬화 오류도 확인한다.
