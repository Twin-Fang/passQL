"""src.core.external_call_limits
외부 호출 공통 상한값: LLM 호출 대기 시간, 실패 로그 응답 길이
"""

# LLM 호출 1회 응답 대기 상한 (30초, Java 쪽 AI 서버 호출 제한보다 길지 않게) (#497, #688)
LLM_CALL_TIMEOUT_SECONDS = 30
# 실패·파싱 실패 로그에 남길 응답 본문 최대 길이 (글자 수)
LOGGED_RESPONSE_TEXT_MAXIMUM_LENGTH = 500
