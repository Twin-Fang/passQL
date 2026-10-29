---
type: completion-report
id: ISS-0343
created: 2026-10-21
topics: [question-bank, ai]
status: resolved
resolves: "[[ISS-0343-daily-set-question-quality-audit]]"
related: ["[[DEC-0159-ai-explanation-grounded-on-execution]]"]
source: "https://github.com/Twin-Fang/passQL/issues/555"
---

# ISS-0343 완료 리포트: 모든 생성 경로에 보기 중복 차단, AI 해설은 실측 근거

GitHub #555 리포트 댓글(`## 개요`, 2026-10-21)과 처리 내용 댓글 기준. 커밋 bd8e564e, c53f1b12, v1.27.0.

## 해결 방법
- 보기 중복 차단: `ChoiceBodyDuplicateFinder.java`(결과 JSON은 공백 무시, SQL·글은 연속 공백 하나로 비교). `CuratedChoiceValidator.java` 거부 사유 "보기 본문 중복". `ChoiceSetGenerationService.java`는 RESULT_MATCH AI 생성 결과에 중복이 있으면 저장하지 않고 재생성. 하네스 `quality_linter.py`에 `choice.duplicate-body` error.
- AI 해설 정확도: `ChoiceSetExecutionEvidenceCollector.java`가 실행형 SQL 보기를 임시 샌드박스에서 실행해 보기별 요약(최대 10행, NULL 표기, 오류 코드). `ChoiceSetExplanationPrompt.java`/`ChoiceSetExplanationGenerator.java`에 실측 요약 오버로드, `PROMPT_VERSION` 2. `ai-prompts/choice-set-explanation/system-instruction.md`: 실측이 있으면 그 값만, 없으면 샘플 데이터로 따진 값만, 내부 자료 이름 금지. `ChoiceSetExplanationValidator.java`는 "기준 SQL", "생성 근거" 언급을 위반으로 재생성.
- 숫자 보기 순서: 하네스 `balance.numeric-order` info > warning(`lint --strict`에서 차단).
- 대량 생성 가이드: `question-bulk-guide.md`·`question-single-guide.md`에 "날카로운 문제 품질 기준" 10가지 + 등록 전 점검 순서, 관리자 AI 변환 프롬프트(`question-list.js`, `question-register.js`)에도 같은 기준.

## 근본 원인 (확정)
해설 오류는 모델이 실행 결과를 추론으로 서술한 탓, 보기 중복은 생성·가져오기 경로에 검사가 없던 탓.

## 재발 방지
- 검증: 서버 단위 테스트(CuratedChoiceValidator 12, ChoiceSetGeneration 7, ResultMatch 10, 해설 Validator 9·Prompt 3·Collector 3, AiExplainService 18, 아키텍처 16), 하네스 pytest 66 통과. 통합 테스트 2건은 로컬 dev DB가 없어 컨텍스트 로드 실패(변경과 무관).
- 운영 실측(2026-10-21): 배포 5분 뒤 백필이 6세트 재생성(위반 0), '기준 SQL' 미언급. 남은 세트는 10분마다 6세트씩 순차 교체.
- 주의: `PROMPT_VERSION`을 올리면 저장된 해설이 조회 시 백그라운드로 다시 만들어져 Gemini 호출과 샌드박스 실행이 일시적으로 는다. 해설 프롬프트 리소스는 서버·해설 하네스 공통이라 문구를 바꾸면 버전을 올리고 하네스를 다시 돌린다. 고정 보기 세트(CURATED_ONLY)는 원래 AI 해설을 쓰지 않아 대상 아님.
- 권장 대량 생성 순서: 경향 템플릿(T01~) 선택 > YAML v2(`trapDesign`, `difficultyReason`, 오답별 `whyPlausible` 필수) > `harness.py lint --strict` > `verify`(Oracle 실행) > 관리자 JSON 가져오기 검증 > 앱에서 표본 직접 풀이.
- 남은 것: 공개 문제 전수 점검은 GitHub #565.

## 교훈
(원본에 없음, 볼트 정리) AI 해설이 실행 결과와 어긋나면 프롬프트에 실측 결과가 들어갔는지부터 확인한다.
