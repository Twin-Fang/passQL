"""src.core.exception_handlers
공통 예외 응답: CustomError > 자기 상태 코드(입력 오류 400, 그 외 500) + 사유, 그 외 예외 > 500 + 고정 문구
"""
import logging
from http import HTTPStatus

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from src.core.exceptions import CustomError

logger = logging.getLogger(__name__)

# 예기치 않은 오류 응답 문구 (내부 원인 비노출)
UNEXPECTED_ERROR_DETAIL = "서버 내부 오류가 발생했습니다"


async def handle_custom_error(request: Request, error: CustomError) -> JSONResponse:
    """업무 실패 > error.status_code {"detail": 사유} (4xx 는 호출부 입력 문제라 warning)"""
    if error.status_code < HTTPStatus.INTERNAL_SERVER_ERROR:
        logger.warning(f"[{request.url.path}] rejected {error.status_code} : {error.message}")
    else:
        logger.error(f"[{request.url.path}] failed {error.status_code} : {error.message}")
    return JSONResponse(status_code=error.status_code, content={"detail": error.message})


async def handle_unexpected_error(request: Request, error: Exception) -> JSONResponse:
    """예기치 않은 예외 > 500 {"detail": 고정 문구}"""
    logger.error(f"[{request.url.path}] unexpected error : {error}", exc_info=error)
    return JSONResponse(status_code=500, content={"detail": UNEXPECTED_ERROR_DETAIL})


def register_exception_handlers(app: FastAPI) -> None:
    """앱 전역 예외 처리기 등록 (HTTPException·검증 오류는 FastAPI 기본 처리 유지)"""
    app.add_exception_handler(CustomError, handle_custom_error)
    app.add_exception_handler(Exception, handle_unexpected_error)
