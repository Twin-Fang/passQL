---
type: issue
id: ISS-0201
created: 2026-10-07
topics: [ai]
symptoms: [AI 해설 모델 선정, gemini-2.5-flash-lite, gemini-3.1-flash-lite, gemini-3.5-flash-lite, 프롬프트 v1 샘플 데이터 없음, "'옳지 않은 것' 오판", LaTeX 기호]
root_cause: "v1 해설 프롬프트에 샘플 데이터·전체 선택지가 없고 시스템 프롬프트가 UNION/JOIN 같은 다른 주제를 유도했다 (실험으로 확인)"
status: resolved
resolution: "[[ISS-0201-ai-explain-model-compare-prompt-report]]"
related: ["[[DEC-0099-explain-model-gemini-3-5-flash-lite]]", "[[DEC-0100-explain-prompt-context-in-server]]", "[[ISS-0199-ai-explain-always-unavailable]]"]
source: "https://github.com/Twin-Fang/passQL/issues/356"
---

# ISS-0201: AI 해설 모델 비교(lite 3종)와 프롬프트 보완

GitHub #356 (원본: 이슈 본문과 댓글).

## 증상
AI 해설(GitHub #354)을 구현하면서 모델을 정해야 한다. 사용자 요청: 비싼 모델은 쓰지 않고 하위 등급 모델 3개 안에서 비교해 고른다.

## 재현 조건
해당 없음 (모델 선정 실험).

## 조사 기록
- 실험 방법: 서버 Gemini 키로 쓸 수 있는 lite 3종(`gemini-2.5-flash-lite`(기존), `gemini-3.1-flash-lite`, `gemini-3.5-flash-lite`), 운영 DB에서 실제 오답이 난 문제 3개(결과표형 윈도우 함수 / SQL형 BETWEEN 범위 / 개념형 CHAR vs VARCHAR "옳지 않은 것"). 같은 프롬프트로 모델만 바꿔 호출(키가 서버 IP로 제한돼 NAS에서 실행), 응답 시간·토큰·정확도 비교.
- 1차(기존 프롬프트 v1): 2.5-flash-lite는 개념형에서 틀림(옳은 설명 A를 틀렸다고 하고 앞뒤 모순), 3.1은 무관한 UNION·JOIN 팁 덧붙임, 3.5는 LaTeX 기호 사용. 세 모델 모두 SQL형은 애매(샘플 데이터 없음). 응답 1.71~2.57초.
- 2차(보완 프롬프트: 샘플 데이터·전체 선택지·'옳지 않은 것' 규칙·LaTeX 금지): 2.5는 개념형 사실 오류 1건, 3.1은 결과표형 오답 원인을 잘못 짚음, 3.5는 전부 정확(표현 일부 부정확). 응답 1.31~2.75초.
- 단가는 확인하지 않았다(토큰 수만 측정).

## 근본 원인
v1 프롬프트의 맥락 부족(샘플 데이터·전체 선택지 없음)과 다른 주제를 유도하는 시스템 프롬프트.
