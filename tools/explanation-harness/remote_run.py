"""
AI 해설 원격 실측 (#558): 운영 AI 서버 컨테이너 안에서 실행 (키 IP 제한·암호화 > 키를 밖으로 꺼내지 않음)
요청 JSON(stdin) > 모델별·반복별 호출 > 원문·지연·토큰 JSON(stdout), 키·예외 원문은 출력하지 않음

실행 (NAS):
  docker exec -i -w /app passql-ai-blue python - --models gemini-2.5-flash-lite,gemini-3.5-flash-lite --runs 2 \
    < remote-requests.json > remote-results.json   (스크립트는 python - 앞에 cat 으로 넘김, run.sh remote 참고)
"""

import argparse
import asyncio
import json
import sys
import time

from google import genai
from google.genai import types

from src.clients.redis_app_setting_client import get_gemini_api_key

# 호출 1건 대기 상한 (밀리초, 운영 GeminiClient 와 같은 수준)
CALL_TIMEOUT_MILLISECONDS = 60_000


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--models", required=True, help="쉼표 구분 모델 목록")
    parser.add_argument("--runs", type=int, default=1, help="샘플당 반복 횟수")
    return parser.parse_args()


def to_usage(response) -> dict:
    """usage_metadata > 입력·출력·thinking 토큰 (없으면 None)"""
    usage = response.usage_metadata
    if usage is None:
        return {"promptTokenCount": None, "candidatesTokenCount": None, "thoughtsTokenCount": None}
    return {
        "promptTokenCount": usage.prompt_token_count,
        "candidatesTokenCount": usage.candidates_token_count,
        "thoughtsTokenCount": usage.thoughts_token_count,
    }


async def call_once(client: genai.Client, model: str, request: dict) -> dict:
    """요청 1건 호출 > 원문·지연·토큰 (실패는 예외 클래스 이름만)"""
    config = types.GenerateContentConfig(
        system_instruction=request["systemInstruction"],
        temperature=request["temperature"],
        max_output_tokens=request["maxOutputTokens"],
        response_mime_type="application/json",
        response_schema=json.loads(request["responseSchemaJson"]),
    )
    started_at = time.monotonic()
    try:
        response = await client.aio.models.generate_content(model=model, contents=request["userPrompt"], config=config)
        return {
            "rawResponse": response.text,
            "elapsedMilliseconds": int((time.monotonic() - started_at) * 1000),
            "error": None,
            **to_usage(response),
        }
    except Exception as error:
        return {
            "rawResponse": None,
            "elapsedMilliseconds": int((time.monotonic() - started_at) * 1000),
            "error": type(error).__name__ + (f" {getattr(error, 'code', '')}" if getattr(error, "code", None) else ""),
            "promptTokenCount": None, "candidatesTokenCount": None, "thoughtsTokenCount": None,
        }


async def main() -> None:
    arguments = parse_arguments()
    requests = json.load(sys.stdin)
    client = genai.Client(api_key=await get_gemini_api_key(),
                          http_options=types.HttpOptions(timeout=CALL_TIMEOUT_MILLISECONDS))
    results = []
    # 모델 > 반복 > 샘플 순 (순차 호출, 동시 호출로 한도 초과 방지)
    for model in [name.strip() for name in arguments.models.split(",") if name.strip()]:
        for run_index in range(1, arguments.runs + 1):
            for request in requests:
                result = await call_once(client, model, request)
                results.append({"model": model, "run": run_index, "sampleId": request["sampleId"], **result})
                print(f"[remote run] {model} run={run_index} {request['sampleId']} "
                      f"{result['elapsedMilliseconds']}ms error={result['error']}", file=sys.stderr)
    json.dump(results, sys.stdout, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    asyncio.run(main())
