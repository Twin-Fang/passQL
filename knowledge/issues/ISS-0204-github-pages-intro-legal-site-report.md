---
type: completion-report
id: ISS-0204
created: 2026-10-07
topics: [store-release]
status: resolved
resolves: "[[ISS-0204-github-pages-intro-legal-site]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/359"
---

# ISS-0204 완료 리포트: `gh-pages` 브랜치로 소개·약관·방침 3개 URL 공개

GitHub #359 완료 댓글 기준 (`gh-pages` 7ae91a3, 2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
- `gh-pages` 브랜치 push, Pages 활성. 3개 URL HTTP 200: `https://twin-fang.github.io/passQL/`(서비스 소개, 마케팅 URL), `.../terms.html`(이용약관), `.../privacy.html`(개인정보처리방침, 스토어 필수).
- 약관·방침 본문은 앱 내 `legal` 테이블(운영 DB)과 동일.
- 디자인은 앱 테마(밝은 배경 #FAFAFA, 인디고 #4F46E5) 기준. 구조 `index.html` / `terms.html` / `privacy.html` / `style.css` / `shots/` / `icon/`.

## 근본 원인 (확정)
해당 없음.

## 재발 방지
후속: App Store Connect / Play Console에 등록된 개인정보처리방침 URL을 위 주소로 교체할지 확인 필요(현재 등록값은 별도 점검). 약관·방침 본문 수정 시 앱 DB `legal`과 `gh-pages`를 함께 갱신해야 한다.

## 교훈
(원본에 없음, 볼트 정리) 약관 본문은 앱 DB `legal`, `gh-pages`, Vercel `/legal/`(GitHub #346) 여러 곳에 사본이 있다 — 고칠 때 모두 확인한다.
