---
type: issue
id: ISS-0244
created: 2026-10-07
topics: [ai, question-bank]
symptoms: ["임베딩 색인 불일치", "Qdrant 237", "활성 문제 192", "미색인 2", "고아 벡터", "top_k 슬롯", "추천 개수 줄어듦"]
root_cause: "문제 삭제·비활성 때 Qdrant 벡터를 지우는 경로가 없고 전체 색인은 upsert만 해 벡터가 쌓였다"
status: resolved
resolution: "[[ISS-0244-qdrant-orphan-vectors-index-mismatch-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/412"
---

# ISS-0244: 임베딩 색인 불일치 — Qdrant 237 vs 활성 문제 192, 미색인 2

GitHub #412 (원본: 이슈 본문과 완료 댓글).

## 증상
관리자 > 임베딩 관리: DB 활성 문제 192, Qdrant 벡터 237, 미색인 문제 2. 벡터가 활성 문제보다 45개 많아 삭제·비활성 문제의 벡터가 유사 문제 검색에 섞일 수 있다. 미색인 2건(`935641dd…`, `1a95d0cc…`)은 유사 문제 검색에서 빠진다.

## 재현 조건
관리자 > 임베딩 관리 화면 수치 확인.

## 조사 기록
- 2026-10-07: 해결 방안 — 문제 삭제·비활성 시 Qdrant 벡터 삭제 여부 확인. 운영 재색인은 AI 호출 비용이 생겨 승인 후 실행.

## 근본 원인
벡터 삭제 경로가 없었다. 고아 벡터가 추천 top_k 슬롯을 차지해 DB 조회 뒤 추천 개수가 줄어드는 구조였다 (완료 댓글).
