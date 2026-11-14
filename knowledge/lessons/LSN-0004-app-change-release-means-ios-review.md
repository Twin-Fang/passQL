---
type: lesson
id: LSN-0004
created: 2026-11-14
reviewed: null
topics: [ci-deploy, store-release]
trigger: "서버 변경과 앱(app/**) 변경이 함께 든 PR·릴리스를 배포하려 할 때"
status: active
source: "ISS-0520"
supersedes: null
superseded_by: null
related: ["[[ISS-0520-sqld-round-answer-key-omr-grading]]", "[[ISS-0452-server-only-release-triggers-store-submit]]"]
---

# LSN-0004: 앱 변경이 든 릴리스의 deploy 푸시는 iOS 심사 자동 제출까지 가므로, 서버 배포라도 앱 배포로 보고 따로 확인받는다

## 규칙
릴리스에 `app/**` 변경(`app/pubspec.yaml` 만 바뀐 경우 제외)이 들어 있으면 deploy 푸시가 서버와 함께 스토어 워크플로를 돌려 iOS 심사 자동 제출까지 간다. 그런 배포는 서버만 급하더라도 앱 배포로 취급해 사용자에게 개별 확인을 받는다.

## Why
#1075(가답안·가채점)는 서버·앱이 한 PR(#1089)이라 서버만 먼저 내보낼 수 없었고, 앱 심사 동반 확인이 필요해 서버·앱 배포를 보류했다. 서버만 바꾼 릴리스는 [[ISS-0452-server-only-release-triggers-store-submit]] 수정으로 스토어 워크플로가 돌지 않지만, 앱 파일이 섞이면 다시 돈다.

## How to apply
- 배포 전 릴리스 범위에 `app/**` 변경이 있는지 확인한다.
- 있으면 "서버 배포"라도 앱 심사 제출 여부를 사용자에게 묻고, 승인 전에는 PR 까지만 둔다.
- #1075 에서는 서버를 내지 못하는 동안 소개 사이트가 서버 없이 동작하게 해 시험 당일 공백을 메웠다([[DEC-0317-site-answer-key-fallback-operator-draft]]).
