---
type: decision
id: DEC-0248
created: 2026-11-05
reviewed: null
topics: [store-release, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0450-promo-site-dynamic-revamp]]", "[[DEC-0139-intro-site-generated-from-src]]", "[[DEC-0242-app-icon-lavender-two-line-pass-ql]]"]
---

# DEC-0248: 소개 사이트 아이콘·공유 이미지와 Play 등록정보 아이콘은 앱 아이콘 원본에서 생성한다

## 문제 정의 (Context)
앱 아이콘을 바꿨는데(#766) 소개 사이트(gh-pages) 아이콘·파비콘·공유 이미지(OG)는 손으로 둔 옛 사본이라 따라 바뀌지 않았다. gh-pages 브랜치에는 `brand/` 폴더가 없다 (GitHub #823).

## 결정 (Decision)
- 사이트: `_src/build_icons.py <main 레포 루트>`가 main `brand/app_icon_1024.png`로 `icon/mark.png`·`favicon-32/180`·`favicon.ico`를 만들고, `brand-colors.json`의 아이콘 그라데이션·강조색으로 OG(1200x630)를 Chrome 헤드리스로 찍는다. 이후 `build_site.py`.
- Play 등록정보 아이콘 512px(`app/docs/store/play-listing-icon-512.png`)는 main 브랜드 생성 목록에 넣어 `--check` 대상으로 둔다. Play Console에는 사람이 올린다.
- [[DEC-0139-intro-site-generated-from-src]](사이트는 `_src/`로만 생성)를 아이콘·OG까지 넓힌다.

## 검토한 대안 (Alternatives)
- **gh-pages에 아이콘 사본을 손으로 복사:** 다음 아이콘 변경 때 다시 어긋나서 버렸다.
- 논의 기록 없음 (그 밖의 대안).

## 결과 (Consequences)
**긍정**
- 아이콘을 바꾸면 스크립트 2개 실행으로 사이트·스토어 사본이 맞춰진다.

**부정**
- gh-pages 생성에 main 레포 경로가 필요하다 (인자로 받음). OG는 로컬 Chrome이 있어야 찍힌다.

## 영향 범위 (Scope)
gh-pages `_src/build_icons.py`·`icon/`·`favicon.ico`, main `brand/generate_brand_assets_for_all_platforms.py`·`app/docs/store/play-listing-icon-512.png`.

## 출처 (References)
- GitHub #823 리포트 「변경 사항」·「이렇게 한 이유」 (2026-11-05)
- 이슈: [[ISS-0450-promo-site-dynamic-revamp]]
