# AI 해설 품질 하네스 (#521)

샘플 문제 > 선택지 세트 구조화 해설 생성(실호출) 또는 기록본(오프라인) > 서버 저장 직전과 같은 검증 > 가독성 지표 > 리포트.
프롬프트·검증·마크다운은 운영 코드를 그대로 쓴다 (사본 없음).

| 구성 | 위치 |
|---|---|
| 프롬프트 원본 (시스템 지시·응답 스키마) | `server/PQL-Application/src/main/resources/ai-prompts/choice-set-explanation/` |
| 프롬프트 버전 | `ChoiceSetExplanationPrompt.PROMPT_VERSION` |
| 검증 (형식·사실·길이·문체) | `ChoiceSetExplanationValidator` |
| 하네스 코드 | `server/PQL-Application/src/test/java/.../explanation/harness/` |
| 샘플 원본 (Oracle 검증 YAML) | `samples/questions/explanation-samples.yaml` |
| 샘플 (검증 통과분, 하네스 입력) | `samples/oracle-verified-import.json` |
| 응답 기록본 | `recorded/v{프롬프트 버전}/{샘플 id}.json` |
| 리포트 | `reports/prompt-v{프롬프트 버전}.md` |

## 실행

```bash
# 오프라인 (키 불필요, CI 와 같음): 기록본 검증 > server/PQL-Application/build/explanation-harness/report.md
./run.sh

# 실호출: 기록본·리포트 갱신 (Gemini 키 필요)
GEMINI_API_KEY=... ./run.sh live
# 모델 바꾸기·보기 근거 포함
EXPLANATION_HARNESS_MODEL=gemini-2.5-flash-lite EXPLANATION_HARNESS_WITH_RATIONALE=true GEMINI_API_KEY=... ./run.sh live
```

- 운영 Gemini 키는 IP 제한이 걸려 있어 로컬에서 403 이 난다. 제한 없는 개인 키를 쓰거나 운영 서버 IP 에서 실행한다.
- `recorded/v1` 은 실호출이 아니라 **수기 고정 샘플**이다 (형식·검증 경로 확인용). 실호출 후 덮어쓴다.
- 실호출은 샘플 9개 x 최대 2회 호출. 기본은 보기 생성 근거(rationale)를 빼고 AI 자체 추론으로 평가한다.

## 판정 기준

- **위반 (저장 거부)**: JSON 파싱 실패, 필수 필드 빈 값, 핵심 개념·헷갈리는 지점 1~3개 아님, 정답 키 불일치,
  보기 판정이 정답 데이터와 모순, 보기 누락, 본문이 다른 보기를 정답으로 언급, 필드 길이가 상한의 1.5배 초과
- **경고 (저장은 함)**: 필드 길이 상한 초과, 서술 어미(~습니다/~해요), 코드 블록, 수식 기호
- 운영 생성기는 위반이 있으면 위반 목록을 붙여 1회 재시도하고, 그래도 위반이면 저장하지 않는다 (FAILED).

## 샘플 추가

1. `samples/questions/*.yaml` 에 문제 추가 (형식: `tools/sqld-question-harness/README.md`)
2. Oracle 로 정답 검증 > 하네스 입력 갱신
   ```bash
   docker run -d --name sqld-harness-oracle -p 1521:1521 -e ORACLE_PASSWORD=harness gvenzl/oracle-free:23-slim-faststart
   cd samples && python -I ../../sqld-question-harness/harness.py verify questions --output oracle-verified-import.json
   ```
3. `./run.sh live` 로 새 샘플 기록본 생성 (샘플 id = 순번-토픽, 순서가 바뀌면 기록본도 다시 생성)

## 프롬프트 바꾸기

1. 리소스 파일 수정 > `PROMPT_VERSION` 올림
2. `./run.sh live` > `reports/prompt-v{새 버전}.md` 를 이전 버전 리포트와 비교 (통과 수, 재시도, 경고, 길이)
3. 배포하면 저장된 낡은 해설은 즉시 계속 보여 주면서 백그라운드(조회 시·10분 백필)에서 새 버전으로 다시 만든다
