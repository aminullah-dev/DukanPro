# DukanPro server: FastAPI on uvicorn. It migrates the database on start
# (docker-entrypoint.sh). See docs/deploy.md.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app
COPY pyproject.toml alembic.ini docker-entrypoint.sh ./
COPY dukan ./dukan
COPY migrations ./migrations
RUN pip install ".[postgres]" \
    && chmod +x docker-entrypoint.sh \
    && useradd --system --uid 10001 --home-dir /app dukan

USER dukan
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD python -c "import sys, urllib.request; sys.exit(urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=4).status != 200)"
ENTRYPOINT ["./docker-entrypoint.sh"]
