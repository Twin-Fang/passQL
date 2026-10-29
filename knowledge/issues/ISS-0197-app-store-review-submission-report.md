---
type: completion-report
id: ISS-0197
created: 2026-10-16
topics: [store-release]
status: resolved
resolves: "[[ISS-0197-app-store-review-submission]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/352"
---

# ISS-0197 완료 리포트: App Store 심사 통과, iOS 1.0 출시 (2026-10-16)

GitHub #352 「완료 처리 (2026-10-16)」 댓글 기준. `## 개요` 형식 리포트는 없음.

## 해결 방법
App Store 조회 API(`itunes.apple.com/lookup`, bundle ID `com.coldredrice.passql`, 국가 kr) 응답: `PassQL` 버전 1.0, 출시 `2026-10-16T00:42:17Z`(KST 09:42). 스토어 링크 https://apps.apple.com/kr/app/passql/id6762165005. 승인 후 자동 출시 설정대로 출시.

## 근본 원인 (확정)
해당 없음.

## 재발 방지
원본에 적혀 있지 않다. 참고: us 스토어에서는 조회되지 않음(출시 국가 설정 확인 필요 시 별도 처리).

## 교훈
(원본에 없음, 볼트 정리) 심사 대기 중 빌드를 교체해 재제출하면 대기 순번이 새로 시작된다(원본 댓글 기록) — 교체 여부를 이 비용과 함께 판단한다.
