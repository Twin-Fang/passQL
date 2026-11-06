---
type: issue
id: ISS-0464
created: 2026-11-07
topics: [admin, ai]
symptoms: ["프롬프트 키 explain_error 로 바뀜", "키 이름 선택 목록 3개", "활성 지시문 못 찾음", "프롬프트 저장 409", prompts.html, PromptService.update, getActivePrompt, ai_analysis_stats, generate_choice_set]
root_cause: "관리자 프롬프트 수정 폼의 키 목록이 3개로 하드코딩돼 목록에 없는 키는 첫 항목으로 선택됐고, 서버 수정 로직이 키 변경을 그대로 받았다. 키 문자열은 서비스 6곳에 흩어져 있었다"
status: resolved
resolution: "[[ISS-0464-admin-prompt-key-single-source-report]]"
related: ["[[DEC-0265-prompt-key-enum-single-source]]", "[[ISS-0459-structured-ai-stats-analysis]]"]
source: "_sources/issues/ISS-0464-admin-prompt-key-single-source.md"
---

# ISS-0464: 관리자 프롬프트 수정 화면 키 목록 누락으로 저장 시 키가 바뀜

GitHub #875 (https://github.com/Twin-Fang/passQL/issues/875).

## 증상
- 관리자 > 프롬프트 관리 수정 폼의 키 이름 선택 목록이 3개(`explain_error`, `diff_explain`, `similar`)만 고정 (`server/PQL-Web/src/main/resources/templates/admin/prompts.html:87-90`).
- 서버가 쓰는 키는 10개 이상. 목록에 없는 키의 지시문을 열면 `explain_error` 가 선택된 채로 보이고, 그대로 저장하면 키가 `explain_error` 로 바뀌어 원래 기능(선택지 생성, AI 분석 등)이 활성 지시문을 못 찾음. `PromptService.update` 도 키 변경을 그대로 받음.
- 키 문자열이 서비스 6곳(`AiCommentService`, `AiExplanationGenerator`, `ChoiceSetExplanationGenerator`, `StatsAnalysisService`, `ChoiceSetGenerationService`, `ChoiceSetIntegrityAuditService`)에 흩어져 화면 목록과 쉽게 어긋남.

## 재현 조건
관리자 > 프롬프트 관리에서 `ai_analysis_stats`(또는 `generate_choice_set`) 지시문 열기 > 키 칸이 `explain_error` > 다른 값만 고치고 저장 > 키가 바뀜 (같은 키·버전이 있으면 409).

## 조사 기록
- 2026-11-07: 운영 확인 — 저장 시도가 중복 버전 409 로 거절돼 실제 변경은 없었음.

## 근본 원인
키 목록의 원본이 없어 화면·서비스가 각자 문자열을 가졌고, 수정 경로가 키 변경을 막지 않았다.
