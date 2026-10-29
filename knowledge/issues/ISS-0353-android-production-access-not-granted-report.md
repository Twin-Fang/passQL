---
type: completion-report
id: ISS-0353
created: 2026-10-26
topics: [store-release, ci-deploy]
status: resolved
resolves: "[[ISS-0353-android-production-access-not-granted]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/568"
---

# ISS-0353 완료 리포트: 프로덕션 액세스 부여 확인, 감시 워크플로우가 alpha 빌드를 자동 승급

GitHub #568 리포트 댓글(`## 개요`, 2026-10-26)과 2026-10-21 댓글 기준. 근거 커밋 `9e5e6bb5`.

## 해결 방법
- 소유자가 Play Console에서 프로덕션 액세스를 신청(2026-10-21).
- `.github/scripts/store_review_watch.py`: alpha 최신 빌드가 production에 없으면 승급을 시도하고, 승인 전 `FAILED_PRECONDITION`이면 `access_pending`으로 넘어감(실측 run 39551459166 `{"result": "access_pending", "release": "1.30.3"}`). 승인 후 다음 실행에서 alpha와 같은 빌드·출시 노트로 production 전체 출시.
- `.github/workflows/PROJECT-COMMON-STORE-REVIEW-WATCH.yaml`: 승급에 필요한 설정 연결.
- iOS는 `store_submit`이 `automatic_release: true`로 제출돼 심사 통과 즉시 자동 출시.

## 근본 원인 (확정)
Play 계정 프로덕션 액세스 미신청·미승인.

## 재발 방지
- 2026-10-26 Play Console 확인: "앱에 Google Play 프로덕션 액세스 권한이 부여되었습니다." 프로덕션 1.51.1 전체 출시 시작, 국가/지역에 대한민국 추가.
- 주의: 1.51.1 실제 공개는 GitHub #570 자동 알림으로 계속 확인. Play 공개 뒤 홍보 페이지 `IS_PLAY_STORE_PUBLIC`(GitHub #650)과 AdMob 스토어 연결(GitHub #506)을 이어 처리. 예약 워크플로우는 기본 브랜치(main) 정의로만 실행된다.

## 교훈
(원본에 없음, 볼트 정리) Play 프로덕션 승급이 `FAILED_PRECONDITION`이고 같은 편집 `validate`가 200이면 빌드가 아니라 계정 프로덕션 액세스 상태를 먼저 본다.
