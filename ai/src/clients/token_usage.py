"""src.clients.token_usage
LLM 호출 1건의 토큰 사용량 전달: 클라이언트(응답 수신 시 기록) > llm_client(결과에 포함) > Spring 호출 기록·비용 추정 (#699)
클라이언트 메서드 반환 모양을 바꾸지 않으려고 호출마다 그릇 하나를 만들어 채운다.
"""
from contextvars import ContextVar
from dataclasses import dataclass


@dataclass
class TokenUsage:
    """토큰 수 (모르면 None)"""
    prompt_tokens: int | None = None
    completion_tokens: int | None = None


# 진행 중인 호출의 그릇 (객체 자체를 채우므로 SDK 내부 작업이 문맥을 복사해도 같은 그릇을 봄)
_current_token_usage: ContextVar[TokenUsage | None] = ContextVar("current_token_usage", default=None)


def start_token_usage() -> TokenUsage:
    """호출 직전: 새 그릇을 현재 문맥에 둔다"""
    usage = TokenUsage()
    _current_token_usage.set(usage)
    return usage


def record_token_usage(prompt_tokens: int | None, completion_tokens: int | None) -> None:
    """응답 수신 시: 현재 그릇에 기록 (그릇 없으면 무시)"""
    usage = _current_token_usage.get()
    if usage is None:
        return
    usage.prompt_tokens = prompt_tokens
    usage.completion_tokens = completion_tokens
