---
type: completion-report
id: ISS-0254
created: 2026-10-10
topics: [ci-deploy, store-release]
status: resolved
resolves: "[[ISS-0254-projectops-4-40-play-closed-testing]]"
related: ["[[DEC-0115-android-play-build-from-main]]"]
source: "https://github.com/Twin-Fang/passQL/issues/448"
---

# ISS-0254 완료 리포트: projectops 4.40.0, 비공개(Alpha) 0.0.220 → 0.7.1

GitHub #448 완료 보고 댓글(2026-10-10) 기준. `## 개요` 형식 리포트는 없음.

## 해결 방법
- 템플릿 4.36.4 → 4.40.0 (`doctor`: Template v4.40.0).
- Android Play 워크플로: `promote_to_closed_testing`(기본 켬), `promote_to_open_testing` 입력과 Fastlane 전달 환경변수 4개 추가.
- 같은 워크플로: 빌드 기준을 `deploy`에서 `main`으로 변경 (iOS와 동일).
- passQL이 고쳐 쓴 워크플로는 덮어쓰지 않았고, 업데이트가 만든 범용 워크플로 7개는 이전에 일부러 지운 종류라 가져오지 않음.

## 근본 원인 (확정)
이슈 노트와 같음. 1차 실행 실패는 `deploy` 브랜치 빌드로 버전 코드 중복.

## 재발 방지
정적 검사: Fastfile이 읽는 승급 변수 5개를 업로드 단계가 모두 전달. 2차 실행 성공, 내부 테스트 0.7.1 게시, 비공개(Alpha) 0.0.220 → 0.7.1 (Play Console 직접 확인). 비공개 승급은 Google 검토를 탄다. 덮어쓰지 않은 수정본 워크플로(iOS TestFlight, Firebase 등)와 새 템플릿 차이는 병합 검토 후보.

## 교훈
(원본에 없음, 볼트 정리) 템플릿 워크플로 사본은 업데이트에서 빠지면 상위 수정(승급 스위치 등)을 놓친다 — 업데이트 때 수정본과 템플릿 차이를 확인한다.
