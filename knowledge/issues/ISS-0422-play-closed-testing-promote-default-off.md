---
type: issue
id: ISS-0422
created: 2026-10-28
topics: [ci-deploy, store-release]
symptoms: ["Play 심사 취소됨", "제출 #38 ~ #46 취소", promote_to_closed_testing, ANDROID_PROMOTE_TO_CLOSED_TESTING, "레포 변수 무시", "비공개 테스트 Alpha 승급"]
root_cause: "수동 배포 입력 promote_to_closed_testing 기본값이 true라 배포마다 Alpha 승급 + 프로덕션 제출이 새로 생겨 진행 중인 심사가 취소됐고, CI 서비스 계정이 프로덕션 자동 제출 권한을 갖고 있었다"
status: resolved
resolution: "[[ISS-0422-play-closed-testing-promote-default-off-report]]"
related: ["[[DEC-0201-play-promote-closed-testing-default-false]]"]
source: "https://github.com/Twin-Fang/passQL/issues/729"
---

# ISS-0422: Play 수동 배포 비공개 테스트 승급 기본값 끄기

GitHub #729 (원본: 이슈 본문과 댓글).

## 증상
Play 프로덕션 심사(1.66.1, 제출 #47) 진행 중 배포할 때마다 새 심사 제출이 생겨 기존 심사가 취소됨. 10/26 ~ 10/27 제출 #38 ~ #46 9건이 모두 "취소됨". 제출은 매번 "프로덕션, 비공개 테스트 - Alpha" 묶음.

## 재현 조건
`PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml` 수동 실행(입력 기본값 그대로).

## 조사 기록
- `github.event.inputs.promote_to_closed_testing || vars.ANDROID_PROMOTE_TO_CLOSED_TESTING || 'true'` — 수동 실행에는 입력값이 항상 있어 레포 변수가 무시된다.
- 비공개 테스트 승급은 프로덕션 액세스 조건(테스터 12명, 14일) 때문에 켜 두었는데 액세스는 이미 승인됨.
- 2026-10-28: 커밋 `95f871d1`, PR #730 main 머지. 템플릿 근본 수정은 Cassiiopeia/projectops#1005.

## 근본 원인
수동 실행 입력 기본값 `true`와 레포 변수보다 입력이 우선하는 식, CI 서비스 계정의 프로덕션 출시 권한.
