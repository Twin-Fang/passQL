---
type: completion-report
id: ISS-0345
created: 2026-10-21
topics: [ai]
status: resolved
resolves: "[[ISS-0345-cheapest-model-per-feature-benchmark]]"
related: ["[[DEC-0162-keep-per-feature-gemini-models]]"]
source: "https://github.com/Twin-Fang/passQL/issues/558"
---

# ISS-0345 완료 리포트: diff_explain 실측 결과 모델 변경 없음, 원격 실측 하네스 남김

GitHub #558 실측 결과 댓글(2026-10-21) 기준. `## 개요` 형식 리포트는 없음. PR #573(운영 코드 변경 없음).

## 해결 방법
실측(diff_explain, 샘플 9개 x 2회, 1회 시도):

| 모델 | 운영 검증 통과 | 평균 시간 | 입력/출력 토큰 | 건당 추정 비용 | 사람 판정 |
|---|---|---|---|---|---|
| gemini-2.5-flash-lite | 18 / 18 | 2.4초 | 849 / 561 | 약 $0.00031 | 07 계층 쿼리에 사실 오류(PRIOR MGR = EMPNO 탐색 방향 반대), 문체 지시 위반 샘플당 4~10곳 |
| gemini-3.5-flash-lite | 18 / 18 | 2.2초 | 849 / 494 | 약 $0.0015 | 사실 오류 없음, 경고 0~4곳 |

- 3.5-flash-lite의 thinking 토큰은 0.
- 결론: 모델 변경 없음 — [[DEC-0162-keep-per-feature-gemini-models]].
- 남긴 것: `tools/explanation-harness/remote_run.py`(AI 서버 컨테이너 안 원격 호출기, 키·예외 원문 출력 안 함), `RemoteExplanationHarness` + 테스트 진입점 2개, `tools/explanation-harness/reports/model-comparison-prompt-v2.md`, README 원격 실측 절차.

## 근본 원인 (확정)
해당 없음(조사·실측 이슈). 운영 검증기는 형식·정답 키만 봐서 두 모델 모두 통과했고, 내용 차이는 사람 판정으로만 드러났다.

## 재발 방지
- 실제 월 비용은 GitHub #557 대시보드(AI 사용량·통계)로 계속 본다.
- 2.5-flash-lite는 신규 계정 사용 제한이 있어 키를 바꾸면 3.5-flash-lite로 옮겨야 할 수 있다.
- 확인하지 못한 것(조사 댓글): 운영 DB의 실제 model 값, 모델별 RPM/RPD 한도, 3.6/3.8-flash의 JSON 스키마 지원.

## 교훈
(원본에 없음, 볼트 정리) 운영 검증기 통과율만으로는 해설 모델의 사실 오류를 구분할 수 없다 — 모델 비교에는 사람 판정을 함께 둔다.
