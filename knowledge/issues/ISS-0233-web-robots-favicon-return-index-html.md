---
type: issue
id: ISS-0233
created: 2026-10-07
topics: [ops-infra]
symptoms: [robots.txt, favicon.ico, sitemap.xml, "200 text/html", vercel.json, "SPA rewrite"]
root_cause: "`client/vercel.json` rewrite가 `assets/`를 뺀 모든 경로를 index.html로 보내고, `client/public/`에 robots.txt가 없었다"
status: resolved
resolution: "[[ISS-0233-web-robots-favicon-return-index-html-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/400"
---

# ISS-0233: `robots.txt`·`favicon.ico` 요청에 index.html이 반환됨 (웹)

GitHub #400 (원본: 이슈 본문과 완료 댓글).

## 증상
`/robots.txt`·`/sitemap.xml`·`/favicon.ico`가 404가 아니라 200 + index.html(`200 text/html 1847B`). 크롤러가 HTML을 robots로 읽는다.

## 재현 조건
`curl -sI https://passql.vercel.app/robots.txt` → `200 text/html`.

## 조사 기록
- 2026-10-07: `client/vercel.json` rewrite와 `client/public/`에 robots.txt 없음 확인.

## 근본 원인
SPA rewrite가 확장자 있는 정적 파일 경로까지 index.html로 보냈다.
