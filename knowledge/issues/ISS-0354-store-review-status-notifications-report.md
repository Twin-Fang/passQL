---
type: completion-report
id: ISS-0354
created: 2026-10-21
topics: [store-release, ci-deploy]
status: resolved
resolves: "[[ISS-0354-store-review-status-notifications]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/569"
---

# ISS-0354 완료 리포트: 30분 주기 스토어 상태 감시, 바뀔 때만 GitHub #570에 댓글

GitHub #569 리포트 댓글(`## 개요`, 2026-10-21) 기준.

## 해결 방법
- `.github/workflows/PROJECT-COMMON-STORE-REVIEW-WATCH.yaml`: cron 30분 + 수동 실행, 이슈 쓰기 권한만, 키는 임시 파일로 쓰고 바로 삭제.
- `.github/scripts/store_review_watch.py`: `android-status`(트랙별 버전·상태, production 릴리스 유무), `notify`(마지막 상태를 GitHub #570 댓글 숨김 표식과 비교 → 바뀐 경우만 댓글, 통과·거절은 머리에 [통과]/[거절]). Android는 Play API 편집을 열고 읽기만 한 뒤 버린다.

## 근본 원인 (확정)
스토어 알림 수신자가 스토어 계정뿐이었다.

## 재발 방지
- 검증: 첫 실행에서 GitHub #570에 현재 상태 댓글(iOS `1.27.0 WAITING_FOR_REVIEW`, Android internal·alpha 1.27.0). 첫 실행에서 Play API가 승인 전에도 빈 production 트랙을 돌려줘 "승인"으로 오판 → 릴리스 유무로 판단하게 고치고 댓글 정정. 두 번째 실행 `unchanged` → 댓글 없음.
- 사용자 조치: GitHub #570을 구독해야 메일이 온다. 스토어 메일 자체를 개인 메일로 받으려면 소유자가 App Store Connect·Play Console에서 사용자 초대 후 알림 설정.
- 주의: Play 프로덕션 액세스 승인 여부는 API로 알 수 없다(승인 메일은 계정 소유자에게).

## 교훈
(원본에 없음, 볼트 정리) Play API의 production 트랙 존재만으로 프로덕션 액세스 승인을 판단하지 않는다 — 릴리스 유무로 본다.
