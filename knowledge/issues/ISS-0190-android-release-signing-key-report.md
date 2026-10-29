---
type: completion-report
id: ISS-0190
created: 2026-10-07
topics: [store-release, ci-deploy]
status: resolved
resolves: "[[ISS-0190-android-release-signing-key]]"
related: ["[[DEC-0097-release-signing-key-properties]]"]
source: "https://github.com/Twin-Fang/passQL/issues/345"
---

# ISS-0190 완료 리포트: 업로드 키스토어로 서명한 AAB를 Play 비공개 테스트에 게시

GitHub #345 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
업로드 키스토어, `key.properties`, Firebase SHA-1 등록을 마치고 서명된 AAB를 Play 비공개 테스트에 올려 게시했다 (GitHub #347).

## 근본 원인 (확정)
릴리스 서명 구성 부재.

## 재발 방지
키스토어와 비밀번호는 저장소에 넣지 않고 로컬과 CI 시크릿으로만 관리, 분실 대비 백업 (이슈 본문 계획). 실제 백업 여부는 원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) 릴리스 키를 새로 만들면 그 SHA-1을 Firebase에 등록하고 설정 파일을 재발급해야 구글 로그인이 동작한다.
