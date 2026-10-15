"""src.core.exception_handlers
공통 예외 응답: CustomError > 500 + 사유, 그 외 예외 > 500 + 고정 문구 (라우터별 try/except 대체)
"""
import logging

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from src.core.exceptions import CustomError

logger = logging.getLogger(__name__)

# 예기치 않은 오류 응답 문구 (내부 원인 비노출)
UNEXPECTED_ERROR_DETAIL = "서버 내부 오류가 발생했습니다"


async def handle_custom_error(request: Request, error: CustomError) -> JSONResponse:
    """업무 실패 > 500 {"detail": 사유}"""
    logger.error(f"[{request.url.path}] failed : {error.message}")
    return JSONResponse(status_code=500, content={"detail": error.message})


async def handle_unexpected_error(request: Request, error: Exception) -> JSONResponse:
    """예기치 않은 예외 > 500 {"detail": 고정 문구}"""
    logger.error(f"[{request.url.path}] unexpected error : {error}", exc_info=error)
    return JSONResponse(status_code=500, content={"detail": UNEXPECTED_ERROR_DETAIL})


def register_exception_handlers(app: FastAPI) -> None:
    """앱 전역 예외 처리기 등록 (HTTPException·검증 오류는 FastAPI 기본 처리 유지)"""
    app.add_exception_handler(CustomError, handle_custom_error)
    app.add_exception_handler(Exception, handle_unexpected_error)
