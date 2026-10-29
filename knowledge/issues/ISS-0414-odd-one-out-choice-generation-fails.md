---
type: issue
id: ISS-0414
created: 2026-10-27
topics: [ai, question-bank, practice]
symptoms: [ODD_ONE_OUT, "선택지 생성 중 멈춤", "correctCount=0", CHOICE_SET_VALIDATION_NO_CORRECT, "결과가 다른 것", validateOddOneOut, generate_choice_set]
root_cause: "공통 선택지 생성 프롬프트는 정답 1개만 기준과 같은 결과를 지시하는데 ODD_ONE_OUT 검증은 3개 같은 결과·1개 다른 결과일 때만 통과 — 지시와 검증이 반대"
status: resolved
resolution: "[[ISS-0414-odd-one-out-choice-generation-fails-report]]"
related: ["[[ISS-0412-ai-explanation-quality-cost-optimization]]", "[[ISS-0416-choice-set-prompts-claude-gemini]]"]
source: "https://github.com/Twin-Fang/passQL/issues/704"
---

# ISS-0414: '결과가 다른 것' 유형 선택지 생성이 항상 실패

GitHub #704 (원본: 이슈 본문과 댓글).

## 증상
"다음 중 SQL 실행 결과가 나머지 셋과 다른 것은?" 유형(`ODD_ONE_OUT`) 문제에서 선택지가 만들어지지 않고 "선택지 생성 중..."에서 멈춘다. 운영 로그: AI 응답은 정상 수신, 샌드박스 검증 `correctCount=0` 3회 반복 > `CHOICE_SET_VALIDATION_NO_CORRECT`.

## 재현 조건
그룹함수 / 집계 > 실행 결과 문제 중 "나머지 셋과 다른 것" 문제 진입 (예: `SELECT SUM(A + B) FROM T`). 운영 모델 `claude-haiku-5-5`.

## 조사 기록
- 운영 기록: Gemini도 이 유형 성공 14 / 실패 10(오답끼리 결과가 우연히 겹칠 때만 통과), Haiku는 오답을 서로 다르게 만들어 전부 실패 — Claude로 바꾼 뒤 문제가 드러났다(리포트).
- 2026-10-27: 같은 원인을 GitHub #699에서도 고침(전용 프롬프트, 컬럼 이름 제외 비교). 이 이슈 반영분과 보완 관계.
- 2026-10-27 운영 경로 재현: 운영 문제 18개 x Haiku·Gemini x 2회, 3회 안 성공률 Haiku 100%(36/36), Gemini 78%(28/36). 후속은 GitHub #710.

## 근본 원인
출제 지시(`generate_choice_set`, 모든 유형 공통)와 `SandboxValidator.validateOddOneOut` 판정 기준이 반대였다. 지시대로 만들면 결과가 1:1:1:1이나 2:2로 나뉘어 항상 `correctCount=0`.
