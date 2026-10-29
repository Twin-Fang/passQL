---
type: completion-report
id: ISS-0244
created: 2026-10-08
topics: [ai, question-bank]
status: resolved
resolves: "[[ISS-0244-qdrant-orphan-vectors-index-mismatch]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/412"
---

# ISS-0244 완료 리포트: AI `POST /api/ai/prune-index`로 고아 벡터 정리

GitHub #412 완료 댓글 기준 (v0.0.249, PR #414). `## 개요` 형식 리포트는 없음.

## 해결 방법
- AI `POST /api/ai/prune-index` — 활성 UUID에 없는 포인트 삭제. 빈 목록은 거부(컬렉션 전체 삭제 방지).
- 단건 삭제 후, 일괄삭제 끝, 전체 색인 뒤에 정리 호출 (실패해도 삭제·색인 흐름은 막지 않음).
- 임베딩 화면에 "남은 벡터 N개" 표시.

## 근본 원인 (확정)
삭제·비활성 때 벡터 삭제 경로가 없고 전체 색인이 upsert만 했다.

## 재발 방지
운영 실행: 전체 색인 192/192 성공, 고아 벡터 47개 삭제(Ollama 로컬 임베딩). 전 192/237/미색인 2/남은 벡터 47 → 후 192/192/0/0.

## 교훈
(원본에 없음, 볼트 정리) 유사 문제 추천 개수가 기대보다 적으면 Qdrant 포인트 수와 활성 문제 수를 먼저 비교한다.
