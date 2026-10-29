---
type: issue
id: ISS-0353
created: 2026-10-21
topics: [store-release, ci-deploy]
symptoms: ["Precondition check failed", FAILED_PRECONDITION, "프로덕션 승급 실패", "production 트랙 없음", "프로덕션 액세스", store_submit, PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD, "Play Developer API"]
root_cause: "Play 개인 개발자 계정에 프로덕션 액세스가 없었다 — 기준은 충족했으나 신청을 하지 않은 상태"
status: resolved
resolution: "[[ISS-0353-android-production-access-not-granted-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/568"
---

# ISS-0353: Android 프로덕션 승급 실패 — Play 계정 프로덕션 액세스 미승인

GitHub #568 (원본: 이슈 본문과 댓글).

## 증상
2026-10-21 v1.27.0 Android `store_submit`: 내부 테스트·비공개 테스트(alpha) 업로드는 성공, 프로덕션 승급에서 Play API `Google Api Error: Invalid request - Precondition check failed.`로 실패.

## 재현 조건
Actions `PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD`를 `deploy_mode=store_submit`로 실행 → 프로덕션 승급에서 실패(run 39534115760).

## 조사 기록
- 2026-10-21 Play Developer API 직접 확인(조회·검증만): 트랙 목록에 production 없음(`internal`·`alpha`만, 1.27.0, versionCode 340). production에 같은 빌드를 넣으면 `400 FAILED_PRECONDITION`, 같은 편집 `validate`는 200 → 빌드·메타데이터 문제 아님.
- 개인 개발자 계정은 비공개 테스트(테스터 12명 이상 14일 연속) 후 Play Console에서 "프로덕션 액세스 신청"(Google 검토, 보통 7일 안팎)을 해야 production 트랙이 열린다. 신청은 소유자 로그인으로만 가능.
- 2026-10-21 13:22: 대시보드 확인 결과 기준 3개 모두 충족, 신청만 안 된 상태 → 신청 제출. 정정 기록: "프로덕션 준비" 답변의 "실기기에서 다시 확인" 문구는 사실과 다름(iOS 시뮬레이터 확인), 제출 뒤라 수정 불가.
- 2026-10-21: 스토어 감시 워크플로우에 Android 자동 승급 추가(커밋 9e5e6bb5).

## 근본 원인
프로덕션 액세스 신청을 하지 않아 계정에 production 트랙이 없었다.
