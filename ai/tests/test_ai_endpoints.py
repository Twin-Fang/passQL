"""AI 엔드포인트 동작 고정: 인증, 응답 형태, 오류 응답 (외부 클라이언트는 가짜로 대체)"""
from src.core.config import settings
from src.clients.gemini_client import gemini_client
from src.clients.ollama_client import ollama_client
from src.clients.qdrant_search_client import qdrant_search_client
from src.services import question_vector_index_service as question_vector_index_service_module

LLM_CONFIG = {
    "model": "gemini-test",
    "system_prompt": "system",
    "user_template": "stem={stem}",
    "response_schema": {"type": "object"},
}
CHOICE_SET_CONTEXT = {
    "question_uuid": "question-1",
    "stem": "문제",
    "answer_sql": "SELECT 1",
    "schema_ddl": "CREATE TABLE t (id INT)",
    "schema_sample_data": "",
    "difficulty": 2,
}
GENERATED_CHOICES = [
    {"key": key, "body": f"SELECT {key}", "is_correct": key == "A", "rationale": "이유"}
    for key in ("A", "B", "C", "D")
]


def test_request_without_api_key_is_rejected(api_client):
    response = api_client.post("/api/ai/recommend", json={}, headers={"X-API-Key": ""})
    assert response.status_code == 401


def test_generate_choice_set_returns_choices_and_metadata(api_client, monkeypatch):
    rendered_user_prompts = []

    async def fake_chat_structured(**kwargs):
        rendered_user_prompts.append(kwargs["user_prompt"])
        return {"choices": GENERATED_CHOICES}

    monkeypatch.setattr(gemini_client, "chat_structured", fake_chat_structured)
    response = api_client.post(
        "/api/ai/generate-choice-set",
        json={"context": CHOICE_SET_CONTEXT, "llm_config": LLM_CONFIG},
    )
    assert response.status_code == 200
    body = response.json()
    assert [choice["key"] for choice in body["choices"]] == ["A", "B", "C", "D"]
    assert body["metadata"]["model_name"] == "gemini-test"
    assert rendered_user_prompts == ["stem=문제"]


def test_generate_choice_set_schema_violation_returns_500_with_reason(api_client, monkeypatch):
    async def fake_chat_structured(**kwargs):
        return {"unexpected": []}

    monkeypatch.setattr(gemini_client, "chat_structured", fake_chat_structured)
    response = api_client.post(
        "/api/ai/generate-choice-set",
        json={"context": CHOICE_SET_CONTEXT, "llm_config": LLM_CONFIG},
    )
    assert response.status_code == 500
    assert response.json()["detail"].startswith("AI 응답 스키마 위반")


def test_unexpected_error_returns_generic_500(api_client, monkeypatch):
    async def broken_chat_structured(**kwargs):
        raise RuntimeError("boom")

    monkeypatch.setattr(gemini_client, "chat_structured", broken_chat_structured)
    response = api_client.post(
        "/api/ai/generate-choice-set",
        json={"context": CHOICE_SET_CONTEXT, "llm_config": LLM_CONFIG},
    )
    assert response.status_code == 500
    assert response.json() == {"detail": "서버 내부 오류가 발생했습니다"}


def test_recommend_without_wrong_answer_vectors_returns_empty(api_client, monkeypatch):
    async def fake_get_vector(collection, point_id):
        return None

    monkeypatch.setattr(qdrant_search_client, "get_vector", fake_get_vector)
    response = api_client.post(
        "/api/ai/recommend",
        json={"size": 3, "recent_wrong_question_uuids": ["wrong-1"]},
    )
    assert response.status_code == 200
    assert response.json() == {"items": [], "query_source_count": 0}


def test_recommend_searches_with_average_vector_excluding_solved(api_client, monkeypatch):
    vector_by_question_uuid = {"wrong-1": [1.0, 3.0], "wrong-2": [3.0, 5.0]}
    search_calls = []

    async def fake_get_vector(collection, point_id):
        return vector_by_question_uuid.get(point_id)

    async def fake_search(collection, vector, top_k, must_not_ids):
        search_calls.append((collection, vector, top_k, must_not_ids))
        return [{"score": 0.9, "payload": {"question_uuid": "recommended-1"}}, {"score": 0.1, "payload": {}}]

    monkeypatch.setattr(qdrant_search_client, "get_vector", fake_get_vector)
    monkeypatch.setattr(qdrant_search_client, "search", fake_search)
    response = api_client.post(
        "/api/ai/recommend",
        json={
            "size": 2,
            "recent_wrong_question_uuids": ["wrong-1", "wrong-2"],
            "solved_question_uuids": ["solved-1"],
        },
    )
    assert response.status_code == 200
    assert response.json() == {
        "items": [{"question_uuid": "recommended-1", "score": 0.9}],
        "query_source_count": 2,
    }
    assert search_calls == [(settings.QDRANT_COLLECTION, [2.0, 4.0], 2, ["solved-1"])]


def test_index_status_reports_unindexed_and_orphan_counts(api_client, monkeypatch):
    async def fake_scroll_all_ids(collection):
        return ["indexed-1", "orphan-1"]

    monkeypatch.setattr(qdrant_search_client, "scroll_all_ids", fake_scroll_all_ids)
    response = api_client.post(
        "/api/ai/index-status",
        json={"question_uuids": ["indexed-1", "unindexed-1"]},
    )
    assert response.status_code == 200
    assert response.json() == {
        "collection_points_count": 2,
        "db_question_count": 2,
        "unindexed_count": 1,
        "unindexed_uuids": ["unindexed-1"],
        "orphan_count": 1,
    }


def test_prune_index_rejects_empty_active_list(api_client):
    response = api_client.post("/api/ai/prune-index", json={"question_uuids": []})
    assert response.status_code == 500
    assert response.json() == {"detail": "활성 문제 UUID 목록이 비어 있어 정리를 거부합니다"}


def test_prune_index_deletes_only_orphans(api_client, monkeypatch):
    deleted_point_ids = []

    async def fake_scroll_all_ids(collection):
        return ["active-1", "orphan-2", "orphan-1"]

    async def fake_delete_points(collection, point_ids):
        deleted_point_ids.extend(point_ids)

    monkeypatch.setattr(qdrant_search_client, "scroll_all_ids", fake_scroll_all_ids)
    monkeypatch.setattr(qdrant_search_client, "delete_points", fake_delete_points)
    response = api_client.post("/api/ai/prune-index", json={"question_uuids": ["active-1"]})
    assert response.status_code == 200
    assert response.json() == {"deleted_count": 2, "deleted_uuids": ["orphan-1", "orphan-2"]}
    assert deleted_point_ids == ["orphan-1", "orphan-2"]


INDEX_QUESTION_REQUEST = {
    "question_uuid": "question-1",
    "topic_display_name": "JOIN",
    "difficulty": 2,
    "stem": "문제 본문",
}


def _fake_index_question_dependencies(monkeypatch, embedding_vector: list[float]) -> dict:
    """색인 경로 외부 호출 가짜 대체 (관리자 임베딩 모델 설정, Ollama, Qdrant)"""
    recorded_calls = {"embed_models": [], "upserted_point_ids": []}

    async def fake_create_collection_if_not_exists(collection, vector_size):
        return False

    async def fake_get_vector(collection, point_id):
        return None

    async def fake_embed(model, text):
        recorded_calls["embed_models"].append(model)
        return embedding_vector

    async def fake_upsert(collection, point_id, vector, payload):
        recorded_calls["upserted_point_ids"].append(point_id)

    monkeypatch.setattr(question_vector_index_service_module, "get_ollama_embed_model", lambda: "admin-embed-model")
    monkeypatch.setattr(qdrant_search_client, "create_collection_if_not_exists", fake_create_collection_if_not_exists)
    monkeypatch.setattr(qdrant_search_client, "get_vector", fake_get_vector)
    monkeypatch.setattr(qdrant_search_client, "upsert", fake_upsert)
    monkeypatch.setattr(ollama_client, "embed", fake_embed)
    return recorded_calls


def test_index_question_embeds_with_admin_configured_model(api_client, monkeypatch):
    recorded_calls = _fake_index_question_dependencies(
        monkeypatch, [0.0] * settings.EMBEDDING_VECTOR_DIMENSION
    )
    response = api_client.post("/api/ai/index-question", json=INDEX_QUESTION_REQUEST)
    assert response.status_code == 200
    assert response.json() == {"question_uuid": "question-1", "created": True}
    assert recorded_calls == {"embed_models": ["admin-embed-model"], "upserted_point_ids": ["question-1"]}


def test_index_question_rejects_embedding_dimension_mismatch(api_client, monkeypatch):
    recorded_calls = _fake_index_question_dependencies(monkeypatch, [0.0, 1.0])
    response = api_client.post("/api/ai/index-question", json=INDEX_QUESTION_REQUEST)
    assert response.status_code == 500
    assert response.json()["detail"].startswith("임베딩 차원 불일치")
    assert recorded_calls["upserted_point_ids"] == []
