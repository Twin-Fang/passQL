---
type: issue
id: ISS-0458
created: 2026-11-07
topics: [billing, security, ads]
symptoms: [FREE_DAILY_LIMIT_REACHED, "하루 한도 우회", "제출 한도 없음", QUIZ_SESSION_CHOICE_SET_MISMATCH, "보기 묶음 소속", choiceSetId, "문제 목록 토픽 정보", "광고 보너스 앱 신고", ad-bonus, AdMob SSV, rationale 재제출, buildSessionStats, "남의 세션", AI_COMMENT]
root_cause: "무료/프로 경계 일부가 앱 화면 흐름에만 의존 (열기에만 한도 검사, 제출은 보기 묶음 소속·한도 미검사)"
status: resolved
resolution: "[[ISS-0458-server-side-free-limit-pro-gating-report]]"
related: ["[[ISS-0361-billing-switch-final-checks]]", "[[DEC-0004-free-pro-feature-boundary]]", "[[DEC-0258-ai-comment-pro-only-all-forms]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]"]
source: "_sources/issues/ISS-0458-server-side-free-limit-pro-gating.md"
---

# ISS-0458: 무료 한도와 프로 기능의 서버 판정 보강, 풀이 세션 소유 확인

GitHub #860 (원본: 이슈 본문). 공개 레포라 재현 절차는 원본에도 없다.

## 증상
- 결제 스위치를 켜면 무료 회원이 앱을 거치지 않고 API 를 직접 불러 프로에 가까운 가치를 얻을 수 있었다 (2026-11-07 서버 판정 점검, #596 후속).
- 하루 한도: 문제 열기(`GET /questions/{id}`, generate-choices)에서만 검사, 제출(`POST /questions/{id}/submit`)은 검사 안 함. 한도는 "오늘 제출 수" 기준이라 열기는 비용이 없었다.
- 제출이 보기 묶음이 URL 문제에 속하는지 보지 않음 > 한도·오늘의 세트 점수·보너스·순위·통계·토론 "먼저 풀기" 판정에 영향.
- 토픽 조건 없는 문제 목록이 문제마다 토픽 정보를 주고 개수 상한이 없어 토픽 골라 풀기(프로)를 대신할 수 있었다. 최신 경향 목록으로 출제 경향(프로) 수치도 다시 계산 가능.
- 보상형 광고 보너스(+5×2)를 광고 시청 증거 없이 지급 (하루 2회 상한은 지켜짐).
- 같은 보기 묶음 반복 제출로 보기별 근거를 모두 모을 수 있었다 (판정 한 줄의 이유 포함).
- 통계 AI 코멘트가 무료에게 하루 1회 제공 (#699) — [[DEC-0004-free-pro-feature-boundary]]의 "AI 코멘트 프로" 와 어긋남.
- 보안: AI 코멘트 세션 집계(`buildSessionStats`)가 세션 소유자를 확인하지 않음.

## 재현 조건
결제가 켜진 무료 회원(심사 계정 목록)이 서버 API 를 직접 호출할 때.

## 조사 기록
- 2026-11-07: 서버 `/api` 컨트롤러·정책 전수 점검. SQL 실행·해설·약점 분석·출제 경향·오답 노트·개념 뒤 단원·실전 모드 강제는 서버에서 막혀 있음 확인. 웹은 서버가 이미 지운 데이터만 받음.
- 2026-11-07: 사용자 결정 "AI 코멘트는 프로 전용" > [[DEC-0258-ai-comment-pro-only-all-forms]].

## 근본 원인
무료/프로 경계 중 하루 한도와 일부 목록·근거가 앱 화면 흐름에만 의존했다. 열기에만 한도 판정이 있었고, 제출은 보기 묶음 소속과 한도를 확인하지 않았다.
