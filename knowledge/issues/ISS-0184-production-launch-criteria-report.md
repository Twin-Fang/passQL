---
type: completion-report
id: ISS-0184
created: 2026-10-07
topics: [ops-infra, store-release]
status: resolved
resolves: "[[ISS-0184-production-launch-criteria]]"
related: ["[[DEC-0094-hourly-health-check-workflow]]"]
source: "https://github.com/Twin-Fang/passQL/issues/339"
---

# ISS-0184 완료 리포트: 출시 기준 대부분 충족, 남은 항목은 별도 이슈로

GitHub #339 진행 댓글(2026-10-02, 2026-10-07)과 "완료 처리" 댓글(2026-10-07) 기준.

## 해결 방법
- 헬스 모니터링 `PASSQL-HEALTH-CHECK`: 1시간마다 `/actuator/health`와 `/api/meta/topics`(DB 조회) 확인, 일시적 502 대비 3회 재시도 후 실패하면 워크플로우 실패로 GitHub 알림.
- 컨테이너 자동 재시작 back `unless-stopped`(GitHub #337), 앱 CI `PASSQL-APP-CI` 신설, 항상 실패하던 CI 정리(GitHub #336).
- 인증 JWT 전환(GitHub #327), 점수 서버 검증(GitHub #342), 회원 탈퇴(GitHub #340), Apple 로그인·약관·개인정보 페이지·스토어 심사 제출(GitHub #347), 앱 기능 동등성(GitHub #327~#333), 의존성 정리(GitHub #334), 문서 현행화(GitHub #335).
- 관리자 계정: 문서에 `permitAll`로 남아 있던 서술을 정정(GitHub #338).

## 근본 원인 (확정)
해당 없음.

## 재발 방지
남은 항목은 별도 관리: iOS App Store 심사 제출 → GitHub #352, Android Play 비공개 테스트(→ 프로덕션 신청) → GitHub #353, 운영 DB 일일 백업은 NAS에서 사용자가 직접 설정. 2026-10-07 진행 댓글에는 장애 알림 채널 연결, 심사용 리뷰 테스트 계정도 남은 것으로 적혀 있었다(완료 처리 댓글에서 처리 결과는 언급 없음).

## 교훈
원본에 적혀 있지 않다.
