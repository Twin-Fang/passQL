---
type: decision
id: DEC-0015
created: 2026-04-07
reviewed: null
topics: [dev-workflow]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0010-five-day-dev-roadmap]]", "[[ISS-0011-screen-spec-api-mapping]]", "[[ISS-0020-home-greeting-api]]", "[[ISS-0021-progress-api-streak-calculator]]"]
---

# DEC-0015: 프론트 비즈니스 로직 제로 원칙 — 계산·판정은 전부 백엔드, 프론트는 응답을 그대로 렌더링

## 문제 정의 (Context)
5일 로드맵(GitHub #7)과 화면 명세(GitHub #8)에서 FE/BE 책임 경계를 정해야 했다. #8은 "향후 구현 분쟁을 차단"하려고 이 원칙을 명문화한다고 적었다.

## 결정 (Decision)
날짜 계산(D-day), 정답 판정, 닉네임 생성, 정답률 집계 등 모든 비즈니스 로직은 백엔드 책임이다. 프론트는 응답을 그대로 렌더링한다. 예: 오늘의 문제 D-day는 `app_setting.exam.target_date` 기준으로 백엔드가 계산해 내려준다 (#8 주의사항).
이후 GitHub #24(인사말 문장 완성)와 #25(정답률 반올림·스트릭 계산)가 이 원칙을 근거로 들었다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- #8: 향후 구현 분쟁을 차단한다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
프론트 `client/src/` 전체, 백엔드 응답 DTO 설계(예: `/api/questions/today`, `/api/home/greeting`, `/api/progress`).

## 출처 (References)
- GitHub #7 이슈 본문 「전제 조건」, GitHub #8 이슈 본문 「핵심 원칙」·「주의사항」
- GitHub #24, #25 이슈 본문
