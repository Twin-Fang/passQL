---
type: issue
id: ISS-0355
created: 2026-10-21
topics: [store-release, ci-deploy]
symptoms: ["스토어 심사 상태 자동 알림", PROJECT-COMMON-STORE-REVIEW-WATCH, WAITING_FOR_REVIEW, IN_REVIEW, READY_FOR_SALE, REJECTED, "추적 이슈"]
root_cause: ""
status: open
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/570"
---

# ISS-0355: 스토어 심사 상태 자동 알림 (구독용, 닫지 않음)

GitHub #570 (원본: 이슈 본문). 열린 이슈.

## 증상
문제 이슈가 아니라 알림 수신용 추적 이슈. 워크플로우 `PROJECT-COMMON-STORE-REVIEW-WATCH`가 30분마다 iOS 심사 상태·Android 트랙 상태를 조회해 바뀌었을 때만 이 이슈에 댓글을 단다(GitHub #569). 구독하면 GitHub 알림 메일로 심사 통과·거절을 받는다. 닫지 않고 계속 열어 둔다.

## 재현 조건
해당 없음.

## 조사 기록
- 상태 예: iOS `WAITING_FOR_REVIEW` > `IN_REVIEW` > `PENDING_DEVELOPER_RELEASE`/`READY_FOR_SALE`(통과) 또는 `REJECTED`(거절). Android: 트랙별 버전·상태, production 트랙 유무.
- 사람이 작업할 내용 없음(자동 댓글 수신용).

## 근본 원인
해당 없음.
