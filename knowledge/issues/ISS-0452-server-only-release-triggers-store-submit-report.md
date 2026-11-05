---
type: completion-report
id: ISS-0452
created: 2026-11-05
topics: [ci-deploy, store-release]
status: resolved
resolves: "[[ISS-0452-server-only-release-triggers-store-submit]]"
related: ["[[ISS-0451-result-table-choices-fabricated-unvalidated-sets-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/840"
---

# ISS-0452 완료 리포트: 스토어 자동 실행 경로에서 app/pubspec.yaml 제외

GitHub #840 리포트 기준 (2026-11-05). 원본 사본: `_sources/issues/ISS-0452-server-only-release-triggers-store-submit-report.md` (로컬 전용). PR #841.

## 해결 방법
- 두 스토어 워크플로 deploy 푸시 자동 실행 경로를 `['app/**', '!app/pubspec.yaml']`로. 수동 실행은 그대로.

## 검증
- 수정 후 #842 릴리스(서버만 변경)에서 deploy 푸시 실행은 서버·AI·웹뿐, 스토어 워크플로 미실행.

## 근본 원인 (확정)
릴리스 버전 커밋이 `app/pubspec.yaml`을 바꿔 자동 실행 경로에 걸렸다.

## 재발 방지
- 버전 줄만 바뀐 푸시는 스토어 워크플로가 돌지 않는다.

## 알고 남긴 것
- 앱 의존성만 바꾼 푸시(`app/pubspec.yaml`만)도 자동 실행되지 않아, 스토어에 내려면 수동 실행한다.

## 교훈
(원본에서 정리)
- 경로 기반 자동 실행은 자동화가 매번 만드는 커밋(버전 줄)까지 따져서 정한다.
