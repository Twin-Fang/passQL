---
type: issue
id: ISS-0344
created: 2026-10-20
topics: [admin, ai, ops-infra]
symptoms: ["관리자 대시보드", "접속 중 회원 수", "방문자 수", last_seen_at, ai_call_log, "Gemini 직접 호출 기록 없음", "토큰 수", "AI 비용", "토론 게시글 관리", "사이드바 21개"]
root_cause: "방문 이력·Gemini 직접 호출 기록·모델명·토큰이 수집되지 않아 추이와 비용을 볼 수 없었다"
status: resolved
resolution: "[[ISS-0344-admin-dashboard-stats-ai-cost-report]]"
related: ["[[DEC-0160-ai-call-log-tokens-cost-400-days]]", "[[DEC-0161-member-activity-hourly-online-in-memory]]"]
source: "https://github.com/Twin-Fang/passQL/issues/557"
---

# ISS-0344: 관리자 대시보드 통계 그래프, 접속자 집계, AI 사용량과 비용

GitHub #557 (원본: 이슈 본문과 댓글).

## 증상
기능 이슈. 현재 문제점:
- 관리자 대시보드가 숫자 카드 위주라 가입·방문·학습·토론·AI 사용 추이를 볼 수 없다.
- 접속 중 회원 수, 오늘 방문자 수를 알 방법이 없다. `member.last_seen_at`은 내 정보 조회 때만 갱신되고 이력이 남지 않는다.
- `ai_call_log`는 Python AI 서버 경유 호출만 남는다. Spring이 Gemini를 직접 부르는 해설, AI 코멘트, 선택지 해설, Gemini 대체 경로는 기록이 없다.
- 모델명·토큰 수를 저장하지 않아 비용 추정이 안 되고, Gemini 결제 끊김·한도 초과를 바로 알아챌 수 없다.
- 토론 게시판 게시글 전체 관리 화면이 없다(신고 목록만).
- 사이드바 메뉴 21개가 그룹 없이 나열돼 있다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-20: 대시보드 9개 블록 재구성 제안(Chart.js, 일별 30일 / 월별 12개월). 모델 교체는 실측 후 별도 이슈(GitHub #558)로 분리.
- 2026-10-20 리포트에서 기존 코드의 시간대 불일치 발견(범위 밖): Dockerfile `TZ=Asia/Seoul`인데 `SubmissionRepository`(히트맵)·`ProgressService`는 UTC 가정으로 9시간 변환 → GitHub #560.

## 근본 원인
수집 경로 부재 — 방문 이력 테이블이 없고, AI 호출 기록 지점이 Python 경유 호출에만 있었다.
