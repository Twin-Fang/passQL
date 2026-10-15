"""src.services.question_generation_service
문제·선택지 생성 (Gemini structured output), 관리자 프롬프트 테스트
"""
import json
import logging
import time
from typing import Any

from src.clients.gemini_client import gemini_client
from src.core.exceptions import CustomError
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


class QuestionGenerationService:
    """
    문제 생성: 관리자 문제 등록(stem+정답+선택지), 사용자 풀이 선택지 세트, 프롬프트 테스트
    Spring 이 내려준 프롬프트·모델·response_schema > 변수 치환 > Gemini 호출
    """

    @staticmethod
    def _render(template: str, variables: dict) -> str:
        """단순 {var} 치환. 없는 키는 빈 문자열."""
        try:
            # 모든 format 실패 방지를 위해 수동 치환
            rendered = template
            for k, v in variables.items():
                rendered = rendered.replace("{" + k + "}", str(v) if v is not None else "")
            return rendered
        except Exception as e:
            raise CustomError(f"프롬프트 템플릿 치환 실패: {e}")

    @staticmethod
    async def _generate_structured_payload(
        llm_config: LlmConfig, user_prompt: str
    ) -> tuple[dict[str, Any], int]:
        """Gemini structured 호출 > (응답 dict, 소요 ms)"""
        started = time.monotonic()
        payload = await gemini_client.chat_structured(
            system_prompt=llm_config.system_prompt,
            user_prompt=user_prompt,
            model=llm_config.model,
            temperature=llm_config.temperature,
            max_tokens=llm_config.max_tokens,
            response_schema=llm_config.response_schema,
        )
        elapsed_ms = int((time.monotonic() - started) * 1000)
        return payload, elapsed_ms

    async def generate_question_full(
        self, req: GenerateQuestionFullRequest
    ) -> GenerateQuestionFullResponse:
        """
        관리자 문제 등록용: stem + answer_sql + seed_choices(4) 생성.
        Spring 이 내려준 프롬프트 전문과 response_schema 를 그대로 Gemini 에 전달.
        """
        ctx = req.context
        cfg = req.llm_config
        variables = {
            "schema_ddl": ctx.schema_ddl,
            "schema_sample_data": ctx.schema_sample_data,
            "schema_intent": ctx.schema_intent or "",
            "topic": ctx.topic,
            "subtopic": ctx.subtopic or "",
            "difficulty": ctx.difficulty,
            "hint": ctx.hint or "",
        }
        user_prompt = self._render(cfg.user_template, variables)

        if not cfg.response_schema:
            raise CustomError("generate_question_full 은 response_schema 가 필수입니다")

        logger.info(f"[generate-question-full] topic={ctx.topic}, difficulty={ctx.difficulty}")
        payload, elapsed_ms = await self._generate_structured_payload(cfg, user_prompt)

        try:
            stem = payload["stem"]
            answer_sql = payload["answer_sql"]
            raw_choices = payload["seed_choices"]
            seed_choices = [GeneratedChoice(**c) for c in raw_choices]
        except (KeyError, TypeError, ValueError) as e:
            logger.error(f"generate_question_full 응답 스키마 위반: {e} payload={payload}")
            raise CustomError(f"AI 응답 스키마 위반: {e}")

        return GenerateQuestionFullResponse(
            stem=stem,
            answer_sql=answer_sql,
            seed_choices=seed_choices,
            metadata=GenerationMetadata(
                model_name=cfg.model,
                elapsed_ms=elapsed_ms,
                raw_response_json=payload,
            ),
        )

    async def generate_choice_set(
        self, req: GenerateChoiceSetRequest
    ) -> GenerateChoiceSetResponse:
        """
        사용자 풀이용: 기존 문제에 대한 선택지 4개 세트 생성.
        메인 트래픽 경로.
        """
        ctx = req.context
        cfg = req.llm_config
        variables = {
            "question_uuid": ctx.question_uuid,
            "stem": ctx.stem,
            "answer_sql": ctx.answer_sql,
            "schema_ddl": ctx.schema_ddl,
            "schema_sample_data": ctx.schema_sample_data,
            "schema_intent": ctx.schema_intent or "",
            "difficulty": ctx.difficulty,
        }
        user_prompt = self._render(cfg.user_template, variables)

        if not cfg.response_schema:
            raise CustomError("generate_choice_set 은 response_schema 가 필수입니다")

        logger.info(f"[generate-choice-set] question_uuid={ctx.question_uuid}")
        payload, elapsed_ms = await self._generate_structured_payload(cfg, user_prompt)

        try:
            raw_choices = payload["choices"]
            choices = [GeneratedChoice(**c) for c in raw_choices]
        except (KeyError, TypeError, ValueError) as e:
            logger.error(f"generate_choice_set 응답 스키마 위반: {e} payload={payload}")
            raise CustomError(f"AI 응답 스키마 위반: {e}")

        return GenerateChoiceSetResponse(
            choices=choices,
            metadata=GenerationMetadata(
                model_name=cfg.model,
                elapsed_ms=elapsed_ms,
                raw_response_json=payload,
            ),
        )

    async def test_prompt(self, req: TestPromptRequest) -> TestPromptResponse:
        """
        관리자 프롬프트 테스트: 임의 변수 dict 로 프롬프트 렌더 후 Gemini 호출.
        response_schema 가 있으면 structured, 없으면 일반 chat.
        """
        cfg = req.llm_config
        user_prompt = self._render(cfg.user_template, req.variables)

        logger.info(f"[test-prompt] model={cfg.model}")
        if cfg.response_schema:
            payload, elapsed_ms = await self._generate_structured_payload(cfg, user_prompt)
            result_text = json.dumps(payload, ensure_ascii=False, indent=2)
        else:
            started = time.monotonic()
            result_text = await gemini_client.chat(
                system_prompt=cfg.system_prompt,
                user_prompt=user_prompt,
                model=cfg.model,
                temperature=cfg.temperature,
                max_tokens=cfg.max_tokens,
            )
            elapsed_ms = int((time.monotonic() - started) * 1000)

        return TestPromptResponse(result=result_text, elapsed_ms=elapsed_ms)


# 싱글턴 인스턴스
question_generation_service = QuestionGenerationService()
