---
type: issue
id: ISS-0184
created: 2026-10-02
topics: [ops-infra, store-release]
symptoms: ["출시 기준 없음", "장애 7주 미인지", "헬스 모니터링", PASSQL-HEALTH-CHECK, "리더보드 점수 조작", "debug 키 서명", "DB 백업 없음", "계정 삭제 심사"]
root_cause: "해커톤 종료 후 정식 서비스로 전환하는 기준이 없음"
status: resolved
resolution: "[[ISS-0184-production-launch-criteria-report]]"
related: ["[[DEC-0094-hourly-health-check-workflow]]", "[[ISS-0182-prod-container-down-restart-policy]]", "[[ISS-0185-member-account-deletion]]"]
source: "https://github.com/Twin-Fang/passQL/issues/339"
---

# ISS-0184: 정식 서비스(production) 출시 기준 정립

GitHub #339 (원본: 이슈 본문과 댓글 3개).

## 증상
(현재 문제점) 해커톤 종료 후 정식 서비스 전환 기준이 없다. 장애를 7주간 인지하지 못한 것(GitHub #337)이 대표 사례.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-02 범위: 운영 안정성(헬스 모니터링·알림, 자동 재시작, DB 백업·복구), 보안(시크릿 점검, 앱 JWT 전환 GitHub #327, 개발용 경로 제거), 앱 출시(Apple 로그인, 약관·개인정보 처리방침, 심사 체크리스트), 품질(GitHub #327 ~ #333, #334), 문서(GitHub #335).
- 2026-10-02 확인된 위험: (1) `POST /daily-set/complete`가 앱이 보낸 정답 수를 그대로 저장 → 서버가 `sessionUuid` 기준 직접 집계 필요, (2) Android release가 debug 키로 서명, (3) iOS Sign in with Apple 설정, (4) 개인정보 처리방침·약관, 회원 탈퇴(iOS 심사 필수), (5) DB 백업, (6) 관리자 계정·비밀번호 정책 점검. 제안: 1번과 4번 먼저.

## 근본 원인
해당 없음 (기준 정립 작업).
