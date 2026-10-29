---
type: issue
id: ISS-0345
created: 2026-10-20
topics: [ai]
symptoms: [gemini-2.5-flash-lite, gemini-3.5-flash-lite, "모델별 단가", "기능별 비용", diff_explain, explain_error, generate_choice_set_concept, "thinking 토큰", "모델 비교"]
root_cause: "프롬프트별 모델이 2.5/3.5-flash-lite로 섞여 있고 #356 이후 재비교가 없었으며, 토큰을 저장하지 않아 기능별 실제 비용을 몰랐다"
status: resolved
resolution: "[[ISS-0345-cheapest-model-per-feature-benchmark-report]]"
related: ["[[DEC-0162-keep-per-feature-gemini-models]]"]
source: "https://github.com/Twin-Fang/passQL/issues/558"
---

# ISS-0345: 기능별 최저가 모델 실측 비교

GitHub #558 (원본: 이슈 본문과 댓글).

## 증상
기능 이슈. 현재 문제점:
- 프롬프트별 모델이 `gemini-2.5-flash-lite`와 `gemini-3.5-flash-lite`로 섞여 있다. 마지막 비교(GitHub #356) 이후 더 싸거나 나은 모델이 나왔을 수 있다.
- 목표: 기능마다 적당한 품질을 유지하면서 가장 싼 모델.
- 토큰 수를 저장하지 않아 기능별 실제 비용을 모른다(GitHub #557에서 토큰 기록 추가 예정).

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-20 조사(코드 수정 없음): 프롬프트 키별 활성 모델 — `explain_error`·`diff_explain`(V0_0_228)·`generate_choice_set_concept`(V0_0_229)은 3.5-flash-lite, `generate_choice_set`·`generate_choice_set_result_match`·`generate_question_full`·`ai_comment`·`ai_comment_stats`·`similar`는 2.5-flash-lite. app_setting `ai.default_model`·`ai.gemini_model`과 yml `gemini.model`은 읽는 코드가 없거나 부르는 곳이 없음. Spring·Python 모두 thinking 설정을 넘기지 않아 모델 기본값 적용(3.5-flash-lite는 minimal).
- 2026-10-20 단가(공식 페이지): 2.5-flash-lite $0.10/$0.40, 3.1-flash-lite $0.25/$1.50(이르면 2027-05-07 종료), 3.5-flash-lite $0.30/$2.50, 3.6/3.8-flash $0.75/$3.75(2027-01-01부터 $1.50/$7.50). 2.5-flash-lite는 신규 계정에 막혀 있음. 3.1-flash-lite는 후보에서 제외.
- 2026-10-21 실측: diff_explain을 운영 프롬프트 v2로 운영 AI 서버 컨테이너(NAS) 안에서 두 모델 호출, 운영 검증기로 채점(샘플 9개 x 2회).

## 근본 원인
모델 선택 근거가 #356의 소표본 비교뿐이었고 비용 데이터가 없었다.
