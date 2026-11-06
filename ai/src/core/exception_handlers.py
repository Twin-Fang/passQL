"""src.core.exception_handlers
공통 예외 응답: {"detail": 사유, "error_kind": 실패 종류}
CustomError > 자기 상태 코드·종류, 요청 검증 실패 > 422 INVALID_REQUEST, 그 외 예외 > 500 INTERNAL_ERROR + 고정 문구
"""
import logging
from http import HTTPStatus

from fastapi import FastAPI, Request
from fastapi.encoders import jsonable_encoder
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from src.core.exceptions import CustomError, ErrorKind

logger = logging.getLogger(__name__)

# 예기치 않은 오류 응답 문구 (내부 원인 비노출)
UNEXPECTED_ERROR_DETAIL = "서버 내부 오류가 발생했습니다"


def _build_error_response(status_code: int, detail, error_kind: ErrorKind) -> JSONResponse:
    return JSONResponse(status_code=status_code, content={"detail": detail, "error_kind": error_kind.value})


async def handle_custom_error(request: Request, error: CustomError) -> JSONResponse:
    """업무 실패 > error.status_code (4xx 는 호출부 입력 문제라 warning)"""
    if error.status_code < HTTPStatus.INTERNAL_SERVER_ERROR:
        logger.warning(f"[{request.url.path}] rejected {error.status_code} {error.error_kind} : {error.message}")
    else:
        logger.error(f"[{request.url.path}] failed {error.status_code} {error.error_kind} : {error.message}")
    return _build_error_response(error.status_code, error.message, error.error_kind)


async def handle_request_validation_error(request: Request, error: RequestValidationError) -> JSONResponse:
    """요청 형식 오류 > 422 (FastAPI 기본 detail 목록 유지 + INVALID_REQUEST)"""
    logger.warning(f"[{request.url.path}] rejected 422 : {len(error.errors())} validation errors")
    return _build_error_response(
        HTTPStatus.UNPROCESSABLE_ENTITY, jsonable_encoder(error.errors()), ErrorKind.INVALID_REQUEST
    )


async def handle_unexpected_error(request: Request, error: Exception) -> JSONResponse:
    """예기치 않은 예외 > 500 고정 문구"""
    logger.error(f"[{request.url.path}] unexpected error : {error}", exc_info=error)
    return _build_error_response(HTTPStatus.INTERNAL_SERVER_ERROR, UNEXPECTED_ERROR_DETAIL, ErrorKind.INTERNAL_ERROR)


def register_exception_handlers(app: FastAPI) -> None:
    """앱 전역 예외 처리기 등록 (인증 401 HTTPException 은 FastAPI 기본 처리 유지)"""
    app.add_exception_handler(CustomError, handle_custom_error)
    app.add_exception_handler(RequestValidationError, handle_request_validation_error)
    app.add_exception_handler(Exception, handle_unexpected_error)
