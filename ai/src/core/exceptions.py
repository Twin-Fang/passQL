"""src.core.exceptions
커스텀 예외 정의 (Spring CustomException 스타일): 메시지 + 응답 상태 코드 + 실패 종류(error_kind)
"""
from enum import StrEnum
from http import HTTPStatus


class ErrorKind(StrEnum):
    """
    실패 응답 본문 error_kind 값 (Spring AiServerErrorKind 와 같은 이름, tests/snapshots/error_kinds.json 고정)
    Spring 판정: INVALID_REQUEST·LLM_* > 대체 호출 안 함·서킷 실패 아님, INTERNAL_ERROR·본문 없음 > AI 서버 장애
    """
    # 요청 값 오류 (400·422, LLM 호출 전 거부)
    INVALID_REQUEST = "INVALID_REQUEST"
    # LLM 연결 전부 실패·요청 시간 상한 초과 (AI 서버는 정상)
    LLM_UNAVAILABLE = "LLM_UNAVAILABLE"
    # LLM 응답은 왔지만 빈 응답·JSON·스키마 위반 (이미 과금됨)
    LLM_RESPONSE_INVALID = "LLM_RESPONSE_INVALID"
    # 그 외 AI 서버 내부 오류
    INTERNAL_ERROR = "INTERNAL_ERROR"


class CustomError(Exception):
    """
    업무 실패 예외: 메시지 + 응답 상태 코드 (기본 500) + 실패 종류

    Examples:
        >>> raise CustomError("Ollama 임베딩 생성에 실패했습니다")
        >>> raise InvalidRequestError("response_schema 가 필수입니다")  # 400
    """

    def __init__(
        self,
        message: str,
        status_code: int = HTTPStatus.INTERNAL_SERVER_ERROR,
        error_kind: ErrorKind = ErrorKind.INTERNAL_ERROR,
    ):
        self.message = message
        self.status_code = int(status_code)
        self.error_kind = error_kind
        super().__init__(self.message)

    def __str__(self):
        return self.message


class InvalidRequestError(CustomError):
    """요청 값이 처리 조건을 못 갖춤 > 400 INVALID_REQUEST (Spring 은 대체 호출하지 않음)"""

    def __init__(self, message: str):
        super().__init__(message, status_code=HTTPStatus.BAD_REQUEST, error_kind=ErrorKind.INVALID_REQUEST)


class LlmUnavailableError(CustomError):
    """LLM 연결 전부 실패·시간 상한 초과 > 503 LLM_UNAVAILABLE (같은 연결 목록이라 Spring 대체 호출 무의미)"""

    def __init__(self, message: str):
        super().__init__(message, status_code=HTTPStatus.SERVICE_UNAVAILABLE, error_kind=ErrorKind.LLM_UNAVAILABLE)


class LlmResponseInvalidError(CustomError):
    """LLM 응답 형식 오류 > 502 LLM_RESPONSE_INVALID (호출부가 새 생성으로 재시도)"""

    def __init__(self, message: str):
        super().__init__(message, status_code=HTTPStatus.BAD_GATEWAY, error_kind=ErrorKind.LLM_RESPONSE_INVALID)
