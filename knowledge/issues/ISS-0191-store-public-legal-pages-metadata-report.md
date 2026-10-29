---
type: completion-report
id: ISS-0191
created: 2026-10-07
topics: [store-release]
status: resolved
resolves: "[[ISS-0191-store-public-legal-pages-metadata]]"
related: ["[[ISS-0192-play-closed-test-and-ios-review-submit]]"]
source: "https://github.com/Twin-Fang/passQL/issues/346"
---

# ISS-0191 완료 리포트: Vercel에 약관·방침·계정 삭제 안내 정적 페이지 배포, 심사 정보 입력

GitHub #346 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
- 스토어용 공개 약관·개인정보처리방침·계정 삭제 안내 정적 페이지를 `passql.vercel.app/legal/...`에 배포 (계정 삭제 안내 `https://passql.vercel.app/legal/delete-account.html`, Vercel 배포 확인 200).
- 심사 제출 정보 입력 완료 (GitHub #347). 진행 현황 댓글: Play 앱 콘텐츠 선언 10개, 스토어 등록정보, 비공개 테스트 검토 전송 / iOS 수동 서명 프로파일 `passql-appstore-manual`, `PROJECT-FLUTTER-IOS-TESTFLIGHT` 성공, 빌드 0.0.222(87235540) TestFlight 업로드, 개인정보 URL·데이터 수집 설문 게시.
- 스크린샷 생성 도구 `app/tool/store_shots/main_shots.dart` (가짜 API로 로그인 이후 화면을 시뮬레이터에서 촬영).

## 근본 원인 (확정)
공개 URL과 심사 정보 미준비.

## 재발 방지
원본에 적혀 있지 않다. 진행 댓글의 주의: Play 로그인 세부정보에는 개인 계정 비밀번호를 넣지 않았고, 프로덕션 심사 전에 리뷰용 전용 테스트 계정이 필요하다. TestFlight 워크플로우 수정 커밋(`7d69571`)에 `Co-Authored-By` 줄이 들어갔고 이미 push되어 force push 없이는 못 고친다.

## 교훈
(원본에 없음, 볼트 정리) 약관 공개 URL은 이후 GitHub Pages(GitHub #359)에도 생겼다 — 본문을 고칠 때 공개 사본이 여러 곳인지 확인한다.
