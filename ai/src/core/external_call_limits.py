"""src.core.external_call_limits
외부 호출 공통 상한값: LLM 호출 대기 시간, LLM 요청 전체 시간, 실패 로그 응답 길이
"""

# LLM 호출 1회 응답 대기 상한 (30초, Java 쪽 AI 서버 호출 제한보다 길지 않게) (#497, #688)
LLM_CALL_TIMEOUT_SECONDS = 30
# LLM 요청 1건 전체 상한 (연결 대체·재시도 포함 120초) (#877)
# Spring passql.ai-server.timeout-ms(운영 300초)보다 짧아야 Spring 이 먼저 끊고 대체 호출로 중복 과금하지 않음
LLM_REQUEST_DEADLINE_SECONDS = 120
# 실패·파싱 실패 로그에 남길 응답 본문 최대 길이 (글자 수)
LOGGED_RESPONSE_TEXT_MAXIMUM_LENGTH = 500
