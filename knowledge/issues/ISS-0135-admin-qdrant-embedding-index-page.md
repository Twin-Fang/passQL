---
type: issue
id: ISS-0135
created: 2026-04-13
topics: [admin, ai]
symptoms: ["Qdrant 색인 실패 확인 불가", "미색인 문제", "전체 재색인", "/admin/embeddings", "POST /api/ai/index-status", AdminEmbeddingController]
root_cause: "Qdrant 색인 상태를 관리자가 확인하거나 재색인을 트리거할 화면이 없음"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/250"
---

# ISS-0135: Qdrant 임베딩 색인 상태를 관리자가 확인·재색인할 수 없음

GitHub #250 (원본: 이슈 본문, 댓글은 스크린샷 2장뿐).

## 증상
- 문제 등록 시 Qdrant 자동 색인의 실패 여부를 관리자가 확인할 방법이 없다.
- 전체 재색인 기능이 Python AI 서버에 있으나 관리자 화면에서 트리거할 수 없다.
- DB에는 있고 Qdrant에 벡터가 없는 미색인 문제를 탐지할 수단이 없다.
- 선택한 문제만 재색인하는 UI가 없다.

## 재현 조건
해당 없음 (기능 추가).

## 조사 기록
- 2026-04-13: 제안 — `/admin/embeddings` 페이지(총 포인트 수 / DB 문제 수 / 미색인 수 카드, 미색인 목록, 전체 재색인), `/admin/questions` 툴바 "선택 색인", Python `POST /api/ai/index-status`(Qdrant scroll로 포인트 UUID 수집 후 DB UUID와 차집합), 주요 경로 로그. 작업 목록: `get_collection_info()`, `scroll_all_ids()`, `IndexStatusRequest`/`IndexStatusResponse`, `AiGatewayClient.getIndexStatus()`, `QuestionRepository.findAllQuestionUuids()`, `AdminEmbeddingController`, `embeddings.html`.
- 2026-04-13 댓글: 스크린샷 2장만 있다. 완료 내용을 설명하는 글은 원본에 없다.

## 근본 원인
해당 없음 (미구현 기능).
