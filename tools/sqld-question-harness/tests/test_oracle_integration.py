"""Oracle Free 통합: 실제 컨테이너에서 fixture 문제 검증 (pytest --run-oracle)"""
import pytest

pytestmark = pytest.mark.oracle


def test_fixture_questions_pass_on_oracle(fixture_questions):
    from sqld_harness.oracle_executor import OracleExecutor
    from sqld_harness.verification_runner import run_verifications

    executor = OracleExecutor()
    try:
        results = run_verifications(executor, fixture_questions, worker_count=2)
    finally:
        executor.close()
    assert [result.is_passed for result in results] == [True, True], [result.report_lines for result in results]

