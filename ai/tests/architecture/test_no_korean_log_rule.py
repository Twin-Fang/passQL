"""ai-no-korean-log 규칙 스캔 검증: 한글 로그는 잡고, 영어 로그·로그 밖 한글은 통과"""
from test_architecture_rules import RULES_DIRECTORY, find_violating_files, parse_rule

NO_KOREAN_LOG_RULE = parse_rule(RULES_DIRECTORY / "ai-no-korean-log.rule")

# 파일명 > (내용, 위반 여부)
SAMPLE_SOURCE_BY_FILE_NAME = {
    "korean_single_line.py": ('logger.info(f"추천 완료: {len(items)}개")\n', True),
    # 여러 줄 + 중첩 괄호 뒤 한글
    "korean_multi_line.py": ('logger.debug(\n    f"[index-status] {len(a)} "\n    f"미색인={len(b)}"\n)\n', True),
    "korean_root_logging.py": ('logging.info("로깅 초기화")\n', True),
    "english_log.py": ('logger.info(f"[recommend] completed : item_count={len(items)}")\n', False),
    # 로그 호출 밖 한글 (주석·예외 메시지) 은 대상 아님
    "korean_outside_log.py": ('logger.info("[x] done")  # 완료\nraise ValueError("한글 메시지")\n', False),
}


def test_no_korean_log_rule_detects_only_korean_log_calls(tmp_path):
    # 스캔 자체 동작 확인 (항상 통과하는 빈 규칙 방지)
    source_folder = tmp_path / "ai" / "src"
    source_folder.mkdir(parents=True)
    for file_name, (source, _) in SAMPLE_SOURCE_BY_FILE_NAME.items():
        (source_folder / file_name).write_text(source, encoding="utf-8")

    expected_violations = sorted(
        f"ai/src/{file_name}"
        for file_name, (_, is_violation) in SAMPLE_SOURCE_BY_FILE_NAME.items()
        if is_violation
    )
    assert find_violating_files(tmp_path, NO_KOREAN_LOG_RULE) == expected_violations
