# ===================================================================
# passQL AI Server Dockerfile
# ===================================================================
#
# 설명:
# - passQL AI FastAPI 서버를 위한 Dockerfile
# - uv를 사용한 빠른 의존성 설치 (uv.lock 고정 버전·해시 검증, #877)
# - Python 3.13 슬림 이미지 기반
#
# 빌드 구조:
# - Python 3.13-slim 기반
# - uv를 통한 패키지 관리
# - EXPOSE 8093
#
# ===================================================================

FROM python:3.13-slim

# 작업 디렉토리 설정
WORKDIR /app

# 시스템 의존성 설치
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# uv 설치 (빠른 Python 패키지 매니저, 버전 고정)
RUN pip install --no-cache-dir uv==0.9.22

# 의존성: uv.lock 고정 버전 그대로 설치 (--frozen 잠금 파일만 사용, 해시 불일치면 실패)
COPY pyproject.toml uv.lock ./
RUN uv export --quiet --frozen --no-dev --no-emit-project --format requirements-txt -o /tmp/requirements.txt \
    && uv pip install --system --no-cache --require-hashes -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

# 프로젝트 파일 복사 (비밀 설정 제외: 배포 시 호스트 config/.env.prod 를 /app/.env.prod 로 읽기 전용 마운트)
COPY src/ ./src/

# 프로젝트 자체만 설치 (버전 메타데이터용, 의존성은 위에서 고정 설치)
RUN uv pip install --system --no-cache --no-deps .

# 타임존 설정 (Asia/Seoul)
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 포트 노출
EXPOSE 8093

# 환경 변수 설정
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV ENVIRONMENT=prod

# 애플리케이션 실행
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8093"]


# ===================================================================
# 사용 방법
# ===================================================================
#
# 1. .env 파일 생성:
#    cp .env.example .env.prod
#
# 2. Docker 이미지 빌드:
#    docker build -t passql-ai:latest .
#
# 3. Docker 컨테이너 실행 (설정은 이미지에 없음 > 마운트):
#    docker run -d -p 8093:8093 -v "$PWD/.env.prod:/app/.env.prod:ro" passql-ai:latest
#
# 4. 헬스체크:
#    curl http://localhost:8093/health
#
# 5. Swagger UI (dev 환경만, prod 는 꺼짐):
#    http://localhost:8093/docs/swagger
#
# 6. 의존성 변경 시: pyproject.toml 수정 > uv lock > uv.lock 함께 커밋
#
# ===================================================================
