---
type: completion-report
id: ISS-0233
created: 2026-10-07
topics: [ops-infra]
status: resolved
resolves: "[[ISS-0233-web-robots-favicon-return-index-html]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/400"
---

# ISS-0233 완료 리포트: robots.txt 제공, 확장자 있는 경로는 rewrite 제외

GitHub #400 완료 댓글 기준 (PR #407, 운영 v0.0.247). `## 개요` 형식 리포트는 없음.

## 해결 방법
완료 댓글은 실측 결과만 적었다. 이슈 「예상 동작」: robots.txt를 실제 파일로 제공하고 확장자가 있는 정적 파일 경로는 SPA rewrite 대상에서 제외. 실제 변경 내용은 원본에 적혀 있지 않다.

## 근본 원인 (확정)
이슈 본문 기준: rewrite 범위와 robots.txt 부재.

## 재발 방지
```
/robots.txt -> 200 text/plain; charset=utf-8
/favicon.ico -> 404 text/plain; charset=utf-8
/sitemap.xml -> 404 text/plain; charset=utf-8
/legal/privacy.html -> 200 text/html; charset=utf-8
/login -> 200 text/html; charset=utf-8
/no-such-page -> 200 text/html; charset=utf-8
```
없는 SPA 경로는 앱이 404 화면을 그린다(GitHub #397).

## 교훈
원본에 적혀 있지 않다.
