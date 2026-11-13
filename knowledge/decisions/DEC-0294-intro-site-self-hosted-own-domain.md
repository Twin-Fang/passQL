---
type: decision
id: DEC-0294
created: 2026-11-12
reviewed: null
topics: [store-release, ops-infra]
status: active
supersedes: DEC-0119
superseded_by: null
related: ["[[DEC-0119-legal-urls-on-github-pages]]", "[[DEC-0139-intro-site-generated-from-src]]", "[[ISS-0508-search-visibility-site-domain-aso]]"]
---

# DEC-0294: 소개 사이트·약관 공개 주소는 보유 도메인 passql.suhsaechan.kr 을 시놀로지에서 직접 서빙하고, github.io 는 경로별 이동 페이지로 넘긴다

GitHub #1027 (이슈 본문, gh-pages 커밋 01b49033·2c1ab0b2, PR #1037).

## 문제 정의 (Context)
소개 사이트는 공용 도메인(github.io)이라 신뢰도가 낮고, 레포를 비공개로 돌리면 옮겨야 한다(이슈 본문). [[DEC-0119-legal-urls-on-github-pages]]는 약관 공개 URL을 GitHub Pages에 두고 웹 `/legal/*`을 그쪽으로 리다이렉트했다. 이슈 본문이 "소개 사이트를 보유 도메인(`suhsaechan.kr` 하위)으로 옮긴다. 기존 주소는 새 주소로 이동"을 명시했다.

## 결정 (Decision)
- 소개 사이트와 약관·개인정보·계정 삭제 페이지의 공개 주소를 `https://passql.suhsaechan.kr`로 한다.
- 시놀로지 nginx 컨테이너(`passql-site`)가 서빙하고 DSM 리버스 프록시·Let's Encrypt, www > 루트 301.
- github.io는 `--redirect-to` 생성물로 경로별 canonical + 즉시 이동 + 안내 링크를 두고, sitemap은 빼고 robots는 허용한다.
- 웹 `siteUrls.ts`·`/legal/*`·`vercel.json`은 새 주소를 가리킨다.
- 원본은 계속 gh-pages `_src/` 생성기 하나([[DEC-0139-intro-site-generated-from-src]]).

## 검토한 대안 (Alternatives)
- github.io 유지: 공용 도메인 신뢰도와 레포 비공개 전환 문제(이슈 본문).
- 다른 호스팅(예: 트윈팡 공식 사이트로 이전)은 이슈 본문에 언급만 있고 고르지 않은 이유는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 보유 도메인으로 검색 신호를 모으고, 레포 공개 여부와 무관하게 사이트를 유지한다.

**부정**
- NAS·인증서·DNS를 직접 운영해야 한다. GitHub Pages는 서버 301을 못 줘 옛 주소 이동은 페이지 방식이다.

## 영향 범위 (Scope)
gh-pages `_src/build_site.py`·`site_redirect.py`·`synology/*`·`DEPLOY_SYNOLOGY.md`, `client/src/constants/siteUrls.ts`, `client/public/legal/*`, `client/vercel.json`, 검색 콘솔 등록.

## 출처 (References)
- GitHub #1027 이슈 본문, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1027#issuecomment-6825819857
