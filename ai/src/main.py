"""src.main
FastAPI 애플리케이션 진입점
"""
import time
import logging
from contextlib import asynccontextmanager
from importlib.metadata import PackageNotFoundError, version
from fastapi import FastAPI, Request
from src.clients.redis_app_setting_client import close_redis_client
from src.clients.shared_http_client import close_shared_http_client, open_shared_http_client
from src.core.config import settings
from src.core.exception_handlers import register_exception_handlers
from src.core.logging import setup_logging
from src.apis.ai_router import router as ai_router
from src.apis.health_router import router as health_router

# 로깅 초기화
setup_logging(log_level="INFO")
logger = logging.getLogger(__name__)

# pyproject.toml [project].name (버전 원본: version.yml > CI 가 pyproject version 동기화)
PACKAGE_NAME = "passql-ai"
# 요청 로그 제외 경로: 상태 확인 폴링 (Spring 모니터링·컨테이너 헬스체크가 수 초마다 호출)
UNLOGGED_REQUEST_PATHS = frozenset({"/health"})
# 운영 환경 이름 (문서 화면 끔: 엔드포인트 목록·스키마를 외부에 노출하지 않음, #877)
PRODUCTION_ENVIRONMENT = "prod"
# 로컬 직접 실행 포트 (Spring passql.ai-server.base-url 기본값 localhost:8001, Docker 는 8093)
LOCAL_RUN_PORT = 8001


def read_package_version() -> str:
    """설치된 패키지 메타데이터 > 버전 문자열 (미설치 로컬 실행은 0.0.0)"""
    try:
        return version(PACKAGE_NAME)
    except PackageNotFoundError:
        return "0.0.0"


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    애플리케이션 수명주기: 시작 시 공유 HTTP 클라이언트 생성, 종료 시 HTTP·Redis 연결 정리
    """
    # ========== 시작 단계 ==========
    logger.info("[lifespan] passQL AI server starting")
    open_shared_http_client()

    logger.info("[lifespan] passQL AI server ready")

    yield  # 애플리케이션 실행

    # ========== 종료 단계 ==========
    logger.info("[lifespan] passQL AI server shutting down")
    await close_shared_http_client()
    await close_redis_client()


# 문서 화면·스키마: 운영은 끔 (계약 테스트는 app.openapi() 직접 호출이라 영향 없음)
is_api_docs_enabled = settings.ENVIRONMENT.lower() != PRODUCTION_ENVIRONMENT

# FastAPI 앱 생성 (lifespan 컨텍스트 적용)
app = FastAPI(
    title="passQL AI Server",
    description="passQL AI 서버: 문제·선택지 생성, 프롬프트 테스트, RAG 색인·추천·정리",
    version=read_package_version(),
    lifespan=lifespan,
    docs_url="/docs/swagger" if is_api_docs_enabled else None,
    redoc_url="/docs/redoc" if is_api_docs_enabled else None,
    openapi_url="/openapi.json" if is_api_docs_enabled else None,
)

register_exception_handlers(app)

# 라우터 등록
app.include_router(ai_router)
app.include_router(health_router)


@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    """요청 처리 시간: 응답 헤더 X-Process-Time + 로그 (상태 확인 경로는 로그 제외)"""
    started_seconds = time.monotonic()
    response = await call_next(request)
    elapsed_seconds = time.monotonic() - started_seconds

    response.headers["X-Process-Time"] = f"{elapsed_seconds:.4f}"
    if request.url.path not in UNLOGGED_REQUEST_PATHS:
        logger.info(
            f"[http request] completed : {request.method} {request.url.path} "
            f"{response.status_code} {elapsed_seconds:.4f}s"
        )
    return response


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=LOCAL_RUN_PORT, loop="asyncio")
