---
type: issue
id: ISS-0517
created: 2026-11-14
topics: [practice, billing, design-system]
symptoms: ["잠금화면 해설 한 줄", "rationale 만 보임", "무료 PRO 해설 구분 없음", "선택지 방식 두 개", "잠금화면 AI로 새로 만들기 무료", "삼성 절전 예외 자동 체크", "절전 예외 앱 다녀오기만 해도 체크", "켜기 전 간격 못 고름", "크레딧 아이콘 작음", "-- X 이름표 깨짐", "SQL 라벨 코드 안에 남음", "한 문제만 풀고 끝", "잠금화면 낙서 없음", "잠금화면 신고 토론 없음"]
root_cause: "잠금화면이 앱 AI 해설 대신 생성 근거 한 줄을 그렸고(제출 응답에 세트 ID 가 없어 해설 조회 키도 없었음), 선택지 방식·이어 풀기·권한 확인이 잠금화면 전용으로 따로 만들어져 앱의 무료/PRO 규칙과 어긋났다"
status: resolved
resolution: "[[ISS-0517-lock-screen-free-pro-explanation-continue-report]]"
related: ["[[DEC-0314-lock-screen-free-reason-pro-detail-continue]]", "[[DEC-0290-lock-screen-question-policy]]", "[[ISS-0501-lock-screen-question-android]]"]
source: "_sources/issues/ISS-0517-lock-screen-free-pro-explanation-continue.md"
---

# ISS-0517: 잠금화면 무료·PRO 해설 구분, 선택지 방식 통합, 삼성 절전 예외 확인, 켜기 전 간격 고르기, 크레딧 아이콘

GitHub #1068. 원본: https://github.com/Twin-Fang/passQL/issues/1068 · 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1068#issuecomment-6872626996

## 증상
- 잠금화면 채점 뒤 해설이 무료·PRO 모두 어색한 한 줄(예: "LOWER 도 함수라 값 하나를 돌려준다고 본 값이다.")뿐이었다(사용자: "AI 답지가 왜 이래").
- 설정에 선택지 방식이 두 개(앱 "새 보기로 풀기", 잠금화면 "선택지 방식")였고 잠금화면 쪽은 무료도 AI 생성을 고를 수 있었다.
- 삼성 "절전 예외 앱에 추가"가 아무것도 안 해도 체크됐다(사용자: "안 해도 체크되고 넘어가지네").
- 켜기 전에 간격을 고를 수 없어 설정에 가야 알 수 있었다.
- 빈 줄 없이 이어 쓴 SQL 의 `-- Y`, `-- Z` 이름표가 코드 안에 남았다.
- 무료는 한 문제만 풀고 끝났고, 낙서·토론·신고가 없었다.

## 재현 조건
결제 켜진 운영 서버, Android 잠금화면 문제 켜짐, 무료 계정.

## 조사 기록
- 2026-11-14: 잠금화면 `_buildGradedSection` 이 `submitResult.rationale` 만 그림. 앱 해설 위젯으로 바꿨으나 에뮬레이터에서 여전히 한 줄 > 제출 응답 JSON 에 `choiceSetUuid` 가 없어(`includeFromJson: false`) `ChoiceExplanationRequest.fromSubmission` 이 null. 앱 풀이처럼 `copyWith(choiceSetUuid: choiceSetId)` 로 해결.
- 2026-11-14: 무료 흐린 상세 해설이 화면 두 장 넘게 이어지고 PRO 버튼이 두 개 > 잠금화면은 흐린 상세를 220 높이로 자르고 흐린 실행 결과 표를 뺌.
- 2026-11-14: `stem_blocks.dart` 캡션 판정이 "첫 줄·빈 줄 다음"뿐 > `;` 로 끝난 줄 다음도 새 SQL 시작으로 봄.
