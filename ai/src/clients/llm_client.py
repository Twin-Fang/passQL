"""src.clients.llm_client
LLM 호출 단일 진입점: 관리자 일괄 모델 적용 > 모델 이름으로 제공자 선택 (claude-* > Claude, 그 외 > Gemini)
"""
from typing import Any

from src.clients.claude_client import claude_client
from src.clients.gemini_client import gemini_client
from src.clients.redis_app_setting_client import get_model_override

# 이 접두사로 시작하는 모델은 Claude 로 보냄 (Spring AiModelProvider 와 같은 규칙)
CLAUDE_MODEL_PREFIX = "claude-"


def is_claude_model(model: str) -> bool:
    return model.strip().lower().startswith(CLAUDE_MODEL_PREFIX)


async def resolve_model(prompt_model: str) -> str:
    """관리자 일괄 모델(ai.model_override)이 있으면 그 값, 없으면 프롬프트 모델"""
    return await get_model_override() or prompt_model


def _select_client(model: str):
    return claude_client if is_claude_model(model) else gemini_client


async def chat(system_prompt: str, user_prompt: str, model: str, temperature: float, max_tokens: int) -> str:
    """일반 텍스트 응답 (model 은 resolve_model 을 거친 값)"""
    return await _select_client(model).chat(
        system_prompt=system_prompt,
        user_prompt=user_prompt,
        model=model,
        temperature=temperature,
        max_tokens=max_tokens,
    )


async def chat_structured(
    system_prompt: str,
    user_prompt: str,
    model: str,
    temperature: float,
    max_tokens: int,
    response_schema: dict[str, Any],
) -> dict[str, Any]:
    """JSON 강제 응답 (model 은 resolve_model 을 거친 값)"""
    return await _select_client(model).chat_structured(
        system_prompt=system_prompt,
        user_prompt=user_prompt,
        model=model,
        temperature=temperature,
        max_tokens=max_tokens,
        response_schema=response_schema,
    )
