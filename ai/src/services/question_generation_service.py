"""src.services.question_generation_service
문제·선택지 생성 (LLM structured output), 관리자 프롬프트 테스트
"""
import json
import logging
import re
import time
from typing import Any

from src.clients import llm_client
from src.clients.llm_client import LlmResult
from src.core.exceptions import InvalidRequestError, LlmResponseInvalidError
from src.core.external_call_limits import LOGGED_RESPONSE_TEXT_MAXIMUM_LENGTH
from src.models.ai_request import (
    GenerateChoiceSetRequest,
    GenerateQuestionFullRequest,
    LlmConfig,
    TestPromptRequest,
)
from src.models.ai_response import (
    GeneratedChoice,
    GenerateChoiceSetResponse,
    GenerateQuestionFullResponse,
    GenerationMetadata,
    TestPromptResponse,
)

logger = logging.getLogger(__name__)

# 템플릿 변수 자리 {이름} (이름 = 영문·숫자·밑줄, JSON 예시 중괄호는 해당 없음)
TEMPLATE_VARIABLE_PATTERN = re.compile(r"\{([A-Za-z_][A-Za-z0-9_]*)\}")


def _truncate_payload_for_log(payload: Any) -> str:
    """AI 응답 dict > 로그용 문자열 (LOGGED_RESPONSE_TEXT_MAXIMUM_LENGTH 자 제한)"""
    return str(payload)[:LOGGED_RESPONSE_TEXT_MAXIMUM_LENGTH]


def render_template(template: str, variables: dict[str, Any]) -> str:
    """
    {변수} 한 번에 치환 (값 None > 빈 문자열, 모르는 이름은 그대로)
    한 번만 훑어 치환한 값 안의 {다른 변수} 가 다시 치환되지 않음 (Spring GeminiFallbackClient 와 같은 규칙)
    """

    def replace_variable(match: re.Match) -> str:
        variable_name = match.group(1)
        if variable_name not in variables:
            return match.group(0)
        variable_value = variables[variable_name]
        return "" if variable_value is None else str(variable_value)

    return TEMPLATE_VARIABLE_PATTERN.sub(replace_variable, template)


class QuestionGenerationService:
    """
    문제 생성: 관리자 문제 등록(stem+정답+선택지), 사용자 풀이 선택지 세트, 프롬프트 테스트
    Spring 이 내려준 프롬프트·모델·response_schema > 변수 치환 > LLM 호출 (AI 연결 우선순위·fallback)
    """

    @staticmethod
    async def _generate_structured_payload(
        llm_config: LlmConfig, user_prompt: str
    ) -> tuple[LlmResult, int]:
        """LLM structured 호출 > (결과: 응답 dict·사용 연결·사용 모델, 소요 ms)"""
        started_seconds = time.monotonic()
        result = await llm_client.chat_structured(
            system_prompt=llm_config.system_prompt,
            user_prompt=user_prompt,
            prompt_model=llm_config.model,
            temperature=llm_config.temperature,
            max_tokens=llm_config.max_tokens,
            response_schema=llm_config.response_schema,
        )
        elapsed_ms = int((time.monotonic() - started_seconds) * 1000)
        return result, elapsed_ms

    async def generate_question_full(
        self, request: GenerateQuestionFullRequest
    ) -> GenerateQuestionFullResponse:
        """
        관리자 문제 등록용: stem + answer_sql + seed_choices(4) 생성.
        Spring 이 내려준 프롬프트 전문과 response_schema 를 그대로 LLM 에 전달.
        """
        context = request.context
        llm_config = request.llm_config
        variables = {
            "schema_ddl": context.schema_ddl,
            "schema_sample_data": context.schema_sample_data,
            "schema_intent": context.schema_intent or "",
            "topic": context.topic,
            "subtopic": context.subtopic or "",
            "difficulty": context.difficulty,
            "hint": context.hint or "",
        }
        user_prompt = render_template(llm_config.user_template, variables)

        if not llm_config.response_schema:
            raise InvalidRequestError("generate_question_full 은 response_schema 가 필수입니다")

        logger.info(
            f"[generate-question-full] topic={context.topic}, difficulty={context.difficulty}, "
            f"prompt_model={llm_config.model}"
        )
        result, elapsed_ms = await self._generate_structured_payload(llm_config, user_prompt)
        payload = result.content

        try:
            stem = payload["stem"]
            answer_sql = payload["answer_sql"]
            raw_choices = payload["seed_choices"]
            seed_choices = [GeneratedChoice(**raw_choice) for raw_choice in raw_choices]
        except (KeyError, TypeError, ValueError) as error:
            logger.error(
                f"[generate-question-full] schema violation : {error}, payload={_truncate_payload_for_log(payload)}"
            )
            raise LlmResponseInvalidError(f"AI 응답 스키마 위반: {error}") from error

        return GenerateQuestionFullResponse(
            stem=stem,
            answer_sql=answer_sql,
            seed_choices=seed_choices,
            metadata=GenerationMetadata(
                model_name=result.model,
                connection_name=result.connection_name,
                elapsed_ms=elapsed_ms,
                prompt_tokens=result.prompt_tokens,
                completion_tokens=result.completion_tokens,
                raw_response_json=payload,
            ),
        )

    async def generate_choice_set(
        self, request: GenerateChoiceSetRequest
    ) -> GenerateChoiceSetResponse:
        """
        사용자 풀이용: 기존 문제에 대한 선택지 4개 세트 생성.
        메인 트래픽 경로.
        """
        context = request.context
        llm_config = request.llm_config
        variables = {
            "question_uuid": context.question_uuid,
            "stem": context.stem,
            "answer_sql": context.answer_sql,
            "schema_ddl": context.schema_ddl,
            "schema_sample_data": context.schema_sample_data,
            "schema_intent": context.schema_intent or "",
            "difficulty": context.difficulty,
        }
        user_prompt = render_template(llm_config.user_template, variables)

        if not llm_config.response_schema:
            raise InvalidRequestError("generate_choice_set 은 response_schema 가 필수입니다")

        logger.info(f"[generate-choice-set] question_uuid={context.question_uuid}, prompt_model={llm_config.model}")
        result, elapsed_ms = await self._generate_structured_payload(llm_config, user_prompt)
        payload = result.content

        try:
            raw_choices = payload["choices"]
            choices = [GeneratedChoice(**raw_choice) for raw_choice in raw_choices]
        except (KeyError, TypeError, ValueError) as error:
            logger.error(
                f"[generate-choice-set] schema violation : {error}, payload={_truncate_payload_for_log(payload)}"
            )
            raise LlmResponseInvalidError(f"AI 응답 스키마 위반: {error}") from error

        return GenerateChoiceSetResponse(
            choices=choices,
            metadata=GenerationMetadata(
                model_name=result.model,
                connection_name=result.connection_name,
                elapsed_ms=elapsed_ms,
                prompt_tokens=result.prompt_tokens,
                completion_tokens=result.completion_tokens,
                raw_response_json=payload,
            ),
        )

    async def test_prompt(self, request: TestPromptRequest) -> TestPromptResponse:
        """
        관리자 프롬프트 테스트: 임의 변수 dict 로 프롬프트 렌더 후 LLM 호출.
        response_schema 가 있으면 structured, 없으면 일반 chat.
        """
        llm_config = request.llm_config
        user_prompt = render_template(llm_config.user_template, request.variables)

        logger.info(f"[test-prompt] prompt_model={llm_config.model}")
        if llm_config.response_schema:
            result, elapsed_ms = await self._generate_structured_payload(llm_config, user_prompt)
            result_text = json.dumps(result.content, ensure_ascii=False, indent=2)
        else:
            started_seconds = time.monotonic()
            result = await llm_client.chat(
                system_prompt=llm_config.system_prompt,
                user_prompt=user_prompt,
                prompt_model=llm_config.model,
                temperature=llm_config.temperature,
                max_tokens=llm_config.max_tokens,
            )
            result_text = result.content
            elapsed_ms = int((time.monotonic() - started_seconds) * 1000)
        logger.info(f"[test-prompt] answered : connection={result.connection_name}, model={result.model}")

        return TestPromptResponse(result=result_text, elapsed_ms=elapsed_ms)


# 싱글턴 인스턴스
question_generation_service = QuestionGenerationService()
