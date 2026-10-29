---
type: issue
id: ISS-0271
created: 2026-10-15
topics: [notification, ops-infra]
symptoms: [장애 알림 없음, 5xx 알림, AI 서킷 열림, 배포 실패 알림, Discord 웹훅]
root_cause: "서버 5xx는 DB(ServerErrorLogService)에만 남고 누구에게도 알림이 가지 않았다"
status: resolved
resolution: null
related: ["[[ISS-0250-admin-monitor-server-errors-swagger-lock]]"]
source: "https://github.com/Twin-Fang/passQL/issues/465"
---

# ISS-0271: Discord 장애 알림 웹훅 (취소)

GitHub #465 (원본: 이슈 본문과 정리 댓글).

취소로 닫힘: "이후 명세가 많이 바뀌어 이 이슈 내용은 지금 방향과 맞지 않아 정리합니다. 이미 반영된 부분은 다른 이슈(무료/프로 플랜 #576, 광고 #506·#522 등)로 들어갔고, 다시 필요한 기능은 지금 명세에 맞춰 새 이슈로 엽니다." (2026-10-26)

## 증상
서버 5xx는 DB(`ServerErrorLogService`)에만 남고 누구에게도 알림이 가지 않는다. AI 서킷 열림, 배포 실패도 직접 확인해야만 안다.

## 재현 조건
해당 없음 (기능 부재).

## 조사 기록
- 2026-10-15: 제안 — Discord 웹훅으로 5xx 급증·AI 서킷 열림·배포 실패 알림(같은 종류 묶음 전송), 웹훅 URL은 GitHub Secret과 서버 설정으로 주입. 보류: Discord 채널과 웹훅 준비 후. (GitHub #458 진행 보고에도 "보류 (웹훅 URL 필요)".)
- 2026-10-26: 취소로 닫힘.

## 근본 원인
frontmatter `root_cause`와 같음 (구현되지 않음).
