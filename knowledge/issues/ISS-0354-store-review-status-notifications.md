---
type: issue
id: ISS-0354
created: 2026-10-21
topics: [store-release, ci-deploy]
symptoms: ["심사 결과 메일", "개인 메일로 못 받음", "App Store Connect", "Play Console", PROJECT-COMMON-STORE-REVIEW-WATCH.yaml, store_review_watch.py, "심사 상태 알림"]
root_cause: "심사 결과 메일이 스토어 계정으로만 가서 개인 메일로 결과를 알 수 없었다"
status: resolved
resolution: "[[ISS-0354-store-review-status-notifications-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/569"
---

# ISS-0354: 스토어 심사 결과를 개인 메일로 받기 — 자동 상태 알림과 계정 알림 설정

GitHub #569 (원본: 이슈 본문과 댓글). 원본의 개인 메일 주소는 옮기지 않았다.

## 증상
기능 이슈. 심사 결과 메일이 스토어 계정(App Store Connect 팀 계정, Play Console 개발자 계정)으로만 가서, 사용자 개인 메일로는 심사 통과·거절을 바로 알 수 없다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-21 제안: (1) 30분마다 iOS 심사 상태(App Store Connect API)와 Android 트랙 상태(Play Developer API)를 조회해 바뀌었을 때만 추적 이슈에 댓글 → 구독자에게 GitHub 메일. (2) 소유자가 스토어 계정에 개인 메일 사용자를 초대하고 알림 설정.

## 근본 원인
스토어 알림 수신자가 스토어 계정뿐이었다.
