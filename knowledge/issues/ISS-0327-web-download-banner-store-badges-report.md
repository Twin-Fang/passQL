---
type: completion-report
id: ISS-0327
created: 2026-10-18
topics: [store-release]
status: resolved
resolves: "[[ISS-0327-web-download-banner-store-badges]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/531"
---

# ISS-0327 완료 리포트: 공식 한국어 스토어 배지와 앱 아이콘, Play 비공개 동안 "Android 출시 준비 중"

GitHub #531 보고 댓글 기준 (2026-10-18, PR #533).

## 해결 방법
- App Store·Google Play 공식 한국어 배지, 높이 40px 통일. 왼쪽에 brand 원본에서 생성한 앱 아이콘(모바일 40px/데스크톱 48px).
- `IS_GOOGLE_PLAY_PUBLIC=false`면 "Android 출시 준비 중"을 같은 높이로 표시.
- 모바일 문구를 제목 1줄·설명 1줄로, 배지 두 개를 한 줄에.
- 검증: lint 0, 테스트 86, 빌드, 규칙 10개 실패 0, 1500px·390px 캡처.

## 근본 원인 (확정)
이슈 노트 참조.

## 재발 방지
- Play 공개 후 `client/src/constants/appStoreRelease.ts`의 `IS_GOOGLE_PLAY_PUBLIC`을 `true`로.
- 배지 이미지는 Apple·Google 공식 자산이라 비율·색을 바꾸면 안 된다.
- 소개 사이트 스토어 버튼 통일은 후속.

## 교훈
(원본에 없음, 볼트 정리) 아직 공개되지 않은 스토어 링크는 설정값 하나로 숨기고 비활성 표기를 둔다.
