---
type: issue
id: ISS-0273
created: 2026-10-15
topics: [notification, admin]
symptoms: [푸시 알림 없음, firebase_messaging, FCM 토큰, member_push_token, APNs, "SnackBar(persist:)", Flutter 3.35.5, 실기기 푸시 미확인]
root_cause: "앱에 `firebase_messaging`이 없고 서버에도 FCM 코드가 없어 공지·시험 일정·오늘의 세트를 보낼 수 없었다"
status: open
resolution: null
related: ["[[ISS-0258-github-secret-synology-backup]]"]
source: "https://github.com/Twin-Fang/passQL/issues/467"
---

# ISS-0273: FCM 푸시 알림 (토큰 등록, 발송 화면, 앱 수신)

GitHub #467 (원본: 이슈 본문, 구현 보고서, 진행 보고). 이슈는 열려 있음(`작업중`).

## 증상
앱에 `firebase_messaging`이 없고 서버에도 FCM 코드가 없다. 오늘의 세트, 시험 일정 리마인드, 공지를 보낼 수 없다.

## 재현 조건
해당 없음 (기능 부재).

## 조사 기록
- 2026-10-15: 구현 보고서 — 서버 `PUT /api/members/me/push-token`·`DELETE /api/members/me/push-token?token=`, 발송 공통 지점 `PushNotificationService`(무효 토큰 UNREGISTERED·SENDER_ID_MISMATCH 자동 삭제, 실제 발송은 `PushMessageSender` 뒤), 마이그레이션 `V0_10_30`(`member_push_token`, `push_send_history`), 관리자 `/admin/push`, 앱 `core/push` + `data/push/PushNotificationService`, 허용된 5개 화면으로만 이동, 설정 "알림 받기" 토글. 운영 배포 main `9a47b7e`(0.14.0), Spring run `38821628886`.
- 2026-10-15: 통합 중 Android 스토어·CI 워크플로가 Flutter 3.35.5라 `SnackBar(persist:)`에서 AAB 빌드 실패 → 모든 Flutter 워크플로를 3.38.9로 통일(`7a82773`).
- 2026-10-16: iOS 설정 — 앱 ID Push·프로파일 `aps-environment: production`은 이미 있었고 Secret `APPLE_PROVISIONING_PROFILE_BASE64` 재등록, `project.pbxproj` 3곳을 `RunnerPush.entitlements`로 변경, TestFlight 서명·업로드 성공. Team APNs 키(.p8)가 개수 한도에 걸리고 남은 .p8은 Sandbox 전용이라 `com.coldredrice.passql` 전용 "Apple Push Services" 인증서(만료 2027-11-15)를 발급해 Firebase `PassQL-iOS-Prod`에 등록. 보관: `~/Downloads/passql-apns/`, GitHub Secret `APPLE_APNS_CERT_P12_BASE64`·`APPLE_APNS_CERT_PASSWORD`, NAS(백업 워크플로에 추가).
- 주의(원본): .p12는 OpenSSL 3 기본 암호화(AES)와 RC2-40을 Firebase가 "사용자 인증 정보 형식이 잘못되었습니다"로 거부해 3DES로 다시 만듦. 옛 앱 `PassQL-iOS`(kr.suhsaechan.passql)가 Firebase에서 기본 선택이라 앱을 먼저 골라야 함.

## 근본 원인
frontmatter `root_cause`와 같음. 남은 일(원본): 실기기에서 권한 안내 시트·알림 수신·앱 아이콘 숫자 확인 후 이슈를 닫는다. 백그라운드·종료 상태 알림 탭 이동은 실기기 확인 필요. 오늘의 세트 리마인드 자동 발송은 후속 과제.
