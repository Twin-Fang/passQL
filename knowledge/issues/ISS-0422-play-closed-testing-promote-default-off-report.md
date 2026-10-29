---
type: completion-report
id: ISS-0422
created: 2026-10-28
topics: [ci-deploy, store-release]
status: resolved
resolves: "[[ISS-0422-play-closed-testing-promote-default-off]]"
related: ["[[DEC-0201-play-promote-closed-testing-default-false]]"]
source: "https://github.com/Twin-Fang/passQL/issues/729"
---

# ISS-0422 완료 리포트: 승급 기본값 `false`, 심사 기간 서비스 계정 프로덕션 출시 권한 해제

GitHub #729 리포트 댓글 기준 (커밋 `95f871d1`, PR #730).

## 해결 방법
- `.github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml`: 수동 실행 입력 `promote_to_closed_testing` 기본값 `true` > `false`, 설명에 심사 취소 경고. `env.PROMOTE_TO_CLOSED_TESTING` 입력 없는 실행 기본값 `'true'` > `'false'`.
- Play Console(코드 밖): CI 서비스 계정의 passQL "프로덕션으로 출시" 권한 해제, "앱을 테스트 트랙으로 출시"는 유지.
- 검증: main 워크플로 파일 반영, YAML 파싱 통과, 권한 재확인. 워크플로 실제 실행은 하지 않음(실행 자체가 새 제출을 만들 수 있어서).

## 근본 원인 (확정)
승급 기본값 `true`와 서비스 계정의 프로덕션 자동 제출.

## 재발 방지
- 심사 승인 후 "프로덕션으로 출시" 권한을 다시 켜야 한다. 꺼 둔 동안 `store_submit`은 프로덕션 단계에서 권한 오류로 실패(의도된 동작).
- 권한 수가 8개에서 5개로 줄어듦(직접 끈 것은 1개, 나머지 2개는 콘솔이 함께 해제한 것으로 보임) — 다시 켤 때 확인.
- 비공개 테스트 테스터에게 새 빌드를 주려면 수동 실행에서 직접 체크 — 진행 중인 프로덕션 심사가 있으면 취소된다.
- projectops 템플릿 업데이트 시 기본값이 `true`로 돌아갈 수 있음(#1005 반영 여부 확인).

## 교훈
(원본에 없음, 볼트 정리) 스토어 심사가 계속 "취소됨"이면 배포 워크플로가 매번 새 제출(트랙 승급)을 만들고 있는지부터 본다.
