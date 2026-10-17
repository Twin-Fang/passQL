"""검증 실행기: 캐시 키 범위, 캐시 적중 시 실행 생략, 하네스 오류 캐시 제외, 입력 순서 유지"""
import copy

from sqld_harness.verification_runner import VerificationCache, compute_verification_cache_key, run_verifications


def test_cache_key_ignores_presentation_fields(not_in_question):
    edited = copy.deepcopy(not_in_question)
    edited["stem"] = "바뀐 지문?"
    edited["hint"] = "바뀐 힌트"
    edited["choices"][1]["rationale"] = "바뀐 근거"
    assert compute_verification_cache_key(edited) == compute_verification_cache_key(not_in_question)
    edited["choices"][1]["body"] = "9"
    assert compute_verification_cache_key(edited) != compute_verification_cache_key(not_in_question)


def test_second_run_uses_cache(tmp_path, sqlite_executor, fixture_questions):
    cache_path = tmp_path / "cache.json"
    first_results = run_verifications(sqlite_executor, fixture_questions, VerificationCache(cache_path), worker_count=2)
    assert all(result.is_passed for result in first_results)
    assert len(sqlite_executor.opened_question_ids) == 2
    second_results = run_verifications(sqlite_executor, fixture_questions, VerificationCache(cache_path))
    assert len(sqlite_executor.opened_question_ids) == 2
    assert all(result.is_from_cache for result in second_results)
    assert [result.question_id for result in second_results] == [question["id"] for question in fixture_questions]


def test_harness_error_is_not_cached(tmp_path, sqlite_executor, not_in_question):
    not_in_question["ddl"] = "CREATE TABLE"
    cache = VerificationCache(tmp_path / "cache.json")
    run_verifications(sqlite_executor, [not_in_question], cache)
    assert cache.entries == {}


def test_schema_name_is_unique_and_short():
    """병렬 실행 시 id 앞부분이 같은 문제끼리 스키마 이름 충돌 없음 (Oracle 식별자 30자 이내)"""
    from sqld_harness.oracle_executor import to_question_schema_name

    left_name = to_question_schema_name("question_with_long_shared_prefix_a")
    right_name = to_question_schema_name("question_with_long_shared_prefix_b")
    assert left_name != right_name and len(left_name) <= 30
