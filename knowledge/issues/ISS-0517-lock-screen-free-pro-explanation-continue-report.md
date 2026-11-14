---
type: completion-report
id: ISS-0517
created: 2026-11-14
topics: [practice, billing, design-system]
status: resolved
resolves: "[[ISS-0517-lock-screen-free-pro-explanation-continue]]"
related: ["[[DEC-0314-lock-screen-free-reason-pro-detail-continue]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1068#issuecomment-6872626996"
---

# ISS-0517 완료 리포트: 잠금화면 무료는 이유와 이어 풀기, PRO는 상세 해설

## 해결 방법
- 잠금화면 해설을 앱 `AiExplanationContent` 로(무료: 판정 > 정답 해설 > 220 높이 흐린 상세 + PRO 버튼 1개, PRO: 상세 전체). 제출 결과에 세트 ID 를 붙여 해설 조회.
- 무료도 "한 문제 더"(크레딧 0 이면 소진 화면), 낙서(앱 메모 재사용), 채점 뒤 토론(`discussion:<uuid>` 경로로 앱 의견 목록)·신고(잠금화면 위 시트).
- 잠금화면 "선택지 방식" 삭제 > `isFreshChoiceModeEffective` 로 앱 "새 보기로 풀기" 를 따름.
- 켜기 화면 맨 위 간격·문제 종류 고르기, `enable(selectedIntervalMinutes:)`.
- 삼성 절전 예외: "추가했어요" 를 눌러야 체크, 절전 예외 목록 직접 열기 인텐트 시도(실기기 미확인).
- 크레딧 아이콘 40 + 등장 연출, SQL 이름표 `;` 뒤 분리, 알림 제목 "화면 켤 때마다 한 문제씩", 비교표 "기본 해설".
- PR #1069, 커밋 08fbf055.

## 근본 원인 (확정)
잠금화면이 앱 해설·선택지·등급 규칙을 재사용하지 않고 전용 구현을 둬서 무료/PRO 경계가 앱과 달랐다. 해설 조회 키(세트 ID)는 응답이 아닌 클라이언트가 붙이는 값이라 잠금화면에서 빠졌다.

## 재발 방지
- 잠금화면 기능은 앱 위젯·provider 를 재사용하고, 앱 전용 기능(라우터·구매 시트)은 `unlockAndOpen` 경로로만 연다.

## 교훈
- 제출 응답의 `choiceSetUuid` 는 JSON 에 없는 클라이언트 값이다. 새 풀이 화면을 만들면 반드시 붙여야 AI 해설이 나온다.
