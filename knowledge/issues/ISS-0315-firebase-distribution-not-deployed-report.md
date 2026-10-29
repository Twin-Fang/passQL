---
type: completion-report
id: ISS-0315
created: 2026-10-17
topics: [ci-deploy]
status: resolved
resolves: "[[ISS-0315-firebase-distribution-not-deployed]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/513"
---

# ISS-0315 완료 리포트: Play Store 워크플로에서 같은 서명 APK를 빌드해 Firebase 테스터에게 별도 job으로 배포

GitHub #513 구현 보고서 댓글 기준 (2026-10-17, `8c47304b`).

## 해결 방법
- `build-android`: AAB 빌드 뒤 같은 서명·`--build-name`·`--build-number`로 APK를 빌드해 `android-apk` 아티팩트로 올린다.
- 새 job `deploy-firebase`: APK와 `release-notes`를 내려받아 `testers` 그룹에 배포(`wzieba/Firebase-Distribution-Github-Action` 고정 SHA). Play 배포와 분리된 job이라 서로의 실패가 영향을 주지 않는다. `FIREBASE_SERVICE_ACCOUNT_JSON_BASE64`가 비면 건너뛰고, 서비스 계정 파일은 성공·실패 공통으로 지운다.
- 검증: run 39038164337에서 Firebase job 성공, 새 릴리스 1.12.2 (306) 확인.

## 근본 원인 (확정)
이슈 노트와 같다.

## 재발 방지
- Firebase로 가는 것은 APK다. Play와 연동하면 AAB도 가능하지만 같은 서명 APK라 지금 구조로 충분하다(원본).
- 프로덕션 액세스(12명 이상 14일 비공개 테스트) 승인 전 `store_submit`은 프로덕션 승급 단계에서 계속 실패로 끝난다. 내부·비공개·Firebase 단계는 그 전에 끝난다.

## 교훈
(원본에 없음, 볼트 정리) 테스터 배포가 안 되면 실제로 쓰이는 배포 워크플로에 해당 단계가 있는지부터 본다 — 별도 워크플로는 트리거가 꺼져 있을 수 있다.
