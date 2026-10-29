---
type: completion-report
id: ISS-0178
created: 2026-10-07
topics: [home, practice]
status: resolved
resolves: "[[ISS-0178-app-recommendation-single-solve]]"
related: ["[[DEC-0090-app-no-separate-recommendation-screen]]"]
source: "https://github.com/Twin-Fang/passQL/issues/333"
---

# ISS-0178 완료 리포트: 별도 화면 없이 풀이 후 학습 데이터 갱신(`refreshLearningData`) 보완

GitHub #333 구현 댓글(2026-10-02)과 2026-10-07 확인 댓글 기준.

## 해결 방법
- `refreshLearningData` 공통 도우미: 홈과 통계 캐시를 비운다. 새 화면이 학습 현황을 보여 주면 이 함수에 한 줄만 추가.
- 단건 풀이: 제출 성공 즉시 갱신.
- 챕터/오늘의 세트 풀이: 제출이 한 번이라도 있었다면 화면을 벗어날 때 한 번만 갱신(10번 제출해도 홈 API는 한 번, 중간에 나가도 동일).
- 검증: 2026-10-02 테스트 114개(3개 추가). 2026-10-07 테스트 147개, 실계정 E2E·TestFlight/Play 비공개 테스트 확인.

## 근본 원인 (확정)
홈·통계 데이터가 앱 수명 동안 캐시로 남았다.

## 재발 방지
학습 현황을 보여 주는 새 화면은 `refreshLearningData`에 등록한다(원본).

## 교훈
(원본에 없음, 볼트 정리) 풀이 후 홈·통계가 안 바뀌면 캐시 무효화 지점(`refreshLearningData`)에 해당 화면이 등록됐는지 본다.
