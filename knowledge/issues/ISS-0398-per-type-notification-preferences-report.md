---
type: completion-report
id: ISS-0398
created: 2026-11-07
topics: [notification, auth-member]
status: resolved
resolves: "[[ISS-0398-per-type-notification-preferences]]"
related: ["[[ISS-0396-duolingo-style-return-notifications]]", "[[ISS-0415-feedback-single-submit-attachments-diagnostics]]"]
source: "https://github.com/Twin-Fang/passQL/issues/653"
---

# ISS-0398 완료 리포트: 회원별 알림 묶음 3개 끄기(서버 저장, 자동 발송 제외), 앱 설정 스위치, 스토어 앱 포함

GitHub #653 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/653#issuecomment-6702514820) + 배포 후 실측 댓글(2026-11-07). 이슈 닫힘. 원본 사본: `_sources/issues/ISS-0398-per-type-notification-preferences-report.md`(로컬).

## 해결 방법
- 서버(PR #654, #655, 2026-10-25 운영 배포): 테이블 `member_notification_preference`(Flyway `V1_57_0`, 행 없으면 모두 수신), `GET`, `PUT /api/members/me/notifications/preferences`, 묶음 3개(학습 리마인더, 복귀 알림, 시험 D-day), 관리자 직접 발송은 항상 수신, 자동 발송 대상 조회에서 그 묶음을 끈 회원 제외. API 계약과 웹 생성 타입 갱신.
- 앱: 설정 알림 묶음에 스위치 3개, 기기 알림 받기가 꺼져 있으면 스위치 잠금과 안내, 먼저 화면 반영 후 저장 실패 시 되돌리고 토스트.
- 스토어: v1.50.0부터 포함, iOS 1.77.1과 Android 프로덕션 1.83.0에 들어 있음. 관리자 최소 지원 버전은 2026-10-28에 1.66.1([[ISS-0415-feedback-single-submit-attachments-diagnostics]] 보고서 기준).

## 검증
- 서버 컴파일과 OpenAPI 계약 테스트, 앱 analyze 이상 없음, 앱 테스트 684건 통과.
- 운영 로그 `Migrating schema "public" to version "1.57.0 - member notification preference"`.
- 배포 후 실측(2026-11-07, 1.88.0 main 빌드 시뮬레이터, 운영 서버): 알림 받기를 끄면 세 묶음이 잠기고 "알림 받기를 켜면 고를 수 있어요"(라이트).

## 근본 원인 (확정)
기능 부재 (자동 알림 5종에 종류별 끄기가 없었음).

## 재발 방지
- 구버전 앱 호환을 위해 필드와 엔드포인트는 추가만 했다.

## 남은 일
- 끈 회원이 실제로 안 받는지는 운영 발송으로 아직 확인 못 함. 자동 알림 규칙이 운영에서 켜졌는지는 GitHub #649([[ISS-0396-duolingo-style-return-notifications]])에서 확인.

## 교훈
원본에 적혀 있지 않다.
