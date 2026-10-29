---
type: decision
id: DEC-0201
created: 2026-10-28
reviewed: null
topics: [ci-deploy, store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0422-play-closed-testing-promote-default-off]]", "[[ISS-0422-play-closed-testing-promote-default-off-report]]"]
---

# DEC-0201: Play 수동 배포의 비공개 테스트(alpha) 승급은 기본 끔 — 필요할 때만 체크해서 승급

## 문제 정의 (Context)
배포할 때마다 "프로덕션 + 비공개 테스트 - Alpha" 제출이 새로 생겨 진행 중인 Play 프로덕션 심사가 취소됐다(제출 #38 ~ #46). 비공개 테스트 승급은 프로덕션 액세스 조건(테스터 12명, 14일) 때문에 켜 두었는데 액세스는 이미 승인됐다 (GitHub #729).

## 결정 (Decision)
- `promote_to_closed_testing` 수동 실행 입력 기본값과 입력 없는 실행 기본값을 `false`로. 필요할 때만 체크해서 승급(이슈 본문).
- 심사 기간 동안 CI 서비스 계정의 "프로덕션으로 출시" 권한을 해제하고, 승인 후 다시 켠다.
- 템플릿 쪽 근본 수정은 projectops 이슈(#1005)로 별도 진행.

## 검토한 대안 (Alternatives)
- 레포 변수 `ANDROID_PROMOTE_TO_CLOSED_TESTING`로 끄기: 수동 실행에서는 입력값이 우선해 변수로는 끌 수 없음(이슈 본문).
- 그 외 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 진행 중 심사 유지.

**부정**
- 권한을 꺼 둔 동안 `store_submit`은 프로덕션 단계에서 실패.
- 비공개 테스트 테스터 배포는 수동 체크 필요(그때 진행 중 심사는 취소).
- projectops 템플릿 업데이트 시 기본값이 되돌아갈 수 있음.

## 영향 범위 (Scope)
`.github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`, Play Console 사용자 및 권한.

## 출처 (References)
- GitHub #729 이슈 본문, 리포트 댓글
- [[ISS-0422-play-closed-testing-promote-default-off]]
