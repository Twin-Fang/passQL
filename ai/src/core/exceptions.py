"""src.core.exceptions
커스텀 예외 정의 (Spring CustomException 스타일)
"""
from http import HTTPStatus


class CustomError(Exception):
    """
    업무 실패 예외: 메시지 + 응답 상태 코드 (기본 500)

    Examples:
        >>> raise CustomError("Ollama 임베딩 생성에 실패했습니다")
        >>> raise InvalidRequestError("response_schema 가 필수입니다")  # 400
    """

    def __init__(self, message: str, status_code: int = HTTPStatus.INTERNAL_SERVER_ERROR):
        self.message = message
        self.status_code = int(status_code)
        super().__init__(self.message)

    def __str__(self):
        return self.message


class InvalidRequestError(CustomError):
    """요청 값이 처리 조건을 못 갖춤 > 400 (Spring 은 4xx·5xx 모두 AI_SERVER_UNAVAILABLE 로 감쌈)"""

    def __init__(self, message: str):
        super().__init__(message, status_code=HTTPStatus.BAD_REQUEST)
