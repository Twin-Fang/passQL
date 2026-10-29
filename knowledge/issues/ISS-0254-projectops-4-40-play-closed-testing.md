---
type: issue
id: ISS-0254
created: 2026-10-10
topics: [ci-deploy, store-release]
symptoms: [비공개 테스트 승급 안 됨, PROMOTE_TO_CLOSED_TESTING, alpha 0.0.220 정체, projectops 4.36.4, "Version code 267 has already been used"]
root_cause: "Android Play 워크플로 사본이 #618 이전 버전이라 비공개 테스트 승급 스위치(`PROMOTE_TO_CLOSED_TESTING`)를 Fastlane에 넘기는 줄이 없었다"
status: resolved
resolution: "[[ISS-0254-projectops-4-40-play-closed-testing-report]]"
related: ["[[DEC-0115-android-play-build-from-main]]"]
source: "https://github.com/Twin-Fang/passQL/issues/448"
---

# ISS-0254: Android 배포가 내부 테스트까지만 올라가고 비공개 테스트가 0.0.220에 머묾

GitHub #448 (원본: 이슈 본문과 완료 보고 댓글).

## 증상
passQL의 projectops 템플릿이 4.36.4(최신 4.40.0). Android Play 워크플로 사본에 비공개 테스트(alpha) 승급 스위치(`PROMOTE_TO_CLOSED_TESTING`)를 Fastlane에 넘기는 줄이 없어, 배포해도 내부 테스트까지만 올라가고 비공개 테스트는 0.0.220에 머문다.

## 재현 조건
Android Play 배포 워크플로 실행 시.

## 조사 기록
- 2026-10-10: 업데이트 후 1차 실행 실패 `Version code 267 has already been used` — 워크플로가 `deploy`(v0.5.1) 브랜치를 빌드했기 때문. 2차 실행(`main` 빌드) 성공.

## 근본 원인
frontmatter `root_cause`와 같음 (#618이 무엇인지는 원본에 설명 없음).
