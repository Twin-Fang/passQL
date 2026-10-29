---
type: issue
id: ISS-0398
created: 2026-10-25
topics: [notification, auth-member]
symptoms: ["알림 종류별 끄기 없음", "자동 알림 수신 설정", member_notification_preference, "시스템 알림 전체 끔"]
root_cause: "자동 알림 5종(#649)이 생겼지만 회원이 종류를 골라 끌 방법이 없었다"
status: open
resolution: null
related: ["[[ISS-0396-duolingo-style-return-notifications]]"]
source: "https://github.com/Twin-Fang/passQL/issues/653"
---

# ISS-0398: 알림 종류별 수신 설정 (앱 설정 화면 + 서버 저장)

GitHub #653 (원본: 이슈 본문과 댓글). 이슈는 열려 있다(라벨 작업중).

## 증상
GitHub #649로 자동 알림 5종이 생겼지만 사용자가 종류를 골라 끌 방법이 없다. 알림이 너무 자주 오면 사용자가 시스템 알림 전체를 꺼 재방문 수단을 잃는다. 스토어 심사·피로도 대응으로도 종류별 끄기가 필요하다(이슈 본문).

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-10-25: 제안 — 3그룹(학습 리마인더, 복귀 알림, 시험 D-day)을 회원별로 켜기/끄기, 관리자 직접 발송은 항상 수신, 기본값 모두 수신(행이 없는 회원은 전부 켜진 것으로 봄).
- 2026-10-25 리포트: 서버 테이블 `member_notification_preference`(Flyway `V1_57_0`), API `GET·PUT /api/members/me/notifications/preferences`(PUT은 바꿀 항목만, null은 그대로), `AutoNotificationTargetQueryRepository`에 "그 그룹을 끈 회원 제외" 조건, OpenAPI 계약·웹 타입 갱신. 앱 설정 > 알림 그룹에 스위치 3개, 기기 `알림 받기`가 꺼져 있으면 잠그고 안내. 서버 운영 배포 완료, 앱은 main 병합(스토어 빌드 전).
- 확인하지 못함(리포트): 실기기 화면(라이트·다크·320폭), 로그인 계정으로 `GET·PUT preferences` 응답, 끈 회원이 실제로 안 받는지, 스토어 빌드 반영.

## 근본 원인
원본에 적혀 있지 않다 (기능 부재).
