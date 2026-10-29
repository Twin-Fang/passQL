---
type: issue
id: ISS-0076
created: 2026-04-11
topics: [ai]
symptoms: [UnrecognizedPropertyException, "Unrecognized field \"model\"", GenerationMetadataDto, model_name, snakeCaseMapper, CircuitBreaker, "Gemini fallback"]
root_cause: "Python AI 서버는 metadata에 'model' 키를 쓰고 Java GenerationMetadataDto는 SNAKE_CASE로 'model_name'을 기대해 역직렬화 실패"
status: resolved
resolution: "[[ISS-0076-ai-metadata-model-field-mismatch-report]]"
related: ["[[ISS-0073-ai-server-401-env-file-missing]]"]
source: "https://github.com/Twin-Fang/passQL/issues/132"
---

# ISS-0076: Python AI 서버 GenerationMetadata `model` 필드명 불일치로 파싱 오류

GitHub #132 (원본: 이슈 본문과 "작업 완료" 댓글).

## 증상
Python AI 서버가 정상 응답해도 Spring이 `metadata.model`을 파싱하지 못해 `UnrecognizedPropertyException`이 나고, Resilience4j CircuitBreaker가 실패로 처리해 Gemini fallback으로 우회된다. 로그: `Unrecognized field "model" (class com.passql.ai.dto.GenerationMetadataDto), not marked as ignorable (7 known properties: "model_name", ...)`.

## 재현 조건
`choiceSetPolicy=AI_ONLY`인 EXECUTABLE 문제 상세 진입 → 선택지 생성 SSE.

## 조사 기록
- 2026-04-11: 관련 파일 `ai/src/models/ai_response.py`(`GenerationMetadata.model`), `GenerationMetadataDto.java`(`modelName` → `model_name`), `AiGatewayClient.java`(`snakeCaseMapper`).

## 근본 원인
Python 응답 키(`model`)와 Java DTO 기대 키(`model_name`)가 달랐다(이슈 본문 기준).
