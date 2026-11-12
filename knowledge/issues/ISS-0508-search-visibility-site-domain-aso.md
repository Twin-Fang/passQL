---
type: issue
id: ISS-0508
created: 2026-11-12
topics: [store-release, ops-infra]
symptoms: ["SQLD 검색 노출 안 됨", "소개 사이트 github.io", "passql.suhsaechan.kr", "sitemap", "Search Console", "네이버 서치어드바이저", "스토어 키워드", "평가 요청 시점", "passql-site nginx"]
root_cause: "소개 사이트가 본문 3페이지뿐인 공용 도메인(github.io)이었고 웹 앱은 로그인 화면뿐이라 검색 신호가 약하고 흩어졌으며, 스토어 문구에 새 기능이 없었다"
status: open
resolution: null
related: ["[[DEC-0294-intro-site-self-hosted-own-domain]]", "[[DEC-0295-seo-public-exam-info-no-hidden-text]]", "[[ISS-0310-sqld-seo-intro-site-revamp]]", "[[DEC-0139-intro-site-generated-from-src]]", "[[DEC-0247-promo-site-free-banner-while-billing-off]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1027"
---

# ISS-0508: 검색 노출 개선 — 소개 사이트 개편·도메인 이전·스토어 검색 최적화

GitHub #1027 (열림, 작업중). 원본 사본: `_sources/issues/ISS-0508-search-visibility-site-domain-aso.md`(로컬). 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1027#issuecomment-6825819857

## 증상
- "SQLD", "SQLD 시험", "SQL 자격증" 검색에서 passQL이 상위에 뜨지 않는다.
- 소개 사이트(`twin-fang.github.io/passQL/`)는 본문 3페이지, 공용 도메인이라 신뢰도가 낮다. 웹 앱(`passql.vercel.app`)은 로그인 화면 하나.
- 학습 콘텐츠는 로그인 뒤에 있고 공개하지 않는다(사용자 결정). 웹 앱은 지원을 접을 예정, 레포를 비공개로 돌리면 소개 사이트를 옮겨야 한다.

## 재현 조건
상시(검색 엔진·스토어 검색).

## 조사 기록
- 2026-11-12: 소개 사이트(gh-pages `_src/`, ec1eed3d·793dd8ee) — SQLD 정보 페이지 5개(2026 시험 일정·과목·출제 범위·합격 기준·공부 방법·FAQ), 첫 화면 "교재 없이 앱 하나로 SQLD 준비", Event·Organization JSON-LD·다단계 BreadcrumbList, sitemap 11개, 시험 일정 원본 `site_content` 한 곳. 결제가 켜져 무료·Pro 비교표 재노출(항목은 `pro_benefits.dart`와 맞춤, [[DEC-0247-promo-site-free-banner-while-billing-off]]의 켜진 쪽).
- 2026-11-12: 시놀로지 서빙(01b49033·3c39a121) — nginx 컨테이너 `passql-site`(호스트 포트 없음), www·http 301, gzip·캐시·최소 보안 헤더, 빌드 > 업로드 > NAS 동기화 배포 스크립트와 `DEPLOY_SYNOLOGY.md`. NAS 접속 정보는 레포에서 빼고 pro-launch 저장 자격에서 읽음.
- 2026-11-12: 옛 주소 이동(2c1ab0b2) — `--redirect-to`로 github.io 경로별 canonical·즉시 이동·안내 링크, 404는 새 첫 화면, robots 허용 유지·sitemap 제거, 계정 삭제 원본 `_src/hand_managed/`.
- 2026-11-12: PR #1028 — iOS 이름·부제·키워드 100자·프로모션, Play 제목·짧은 설명, 전체 설명(모의고사·시험 일정 알림·무료와 PRO 구분), `app/docs/store/ads.md`. 평가 요청은 보상 창이 닫힌 뒤에도 시도, 좋은 결과 기준 세트 정답률 80%. PR #1037 — 웹 약관·개인정보·계정 삭제 링크를 새 주소로. 배포 #1034·#1038.
- 2026-11-12 운영 실측: https://passql.suhsaechan.kr (DSM 리버스 프록시, Let's Encrypt, www > 루트 301), Cloudflare CNAME 2개, Google Search Console 등록·sitemap 11페이지 인식, 네이버 서치어드바이저 소유 확인·sitemap 제출·루트 수집 요청, github.io 전 경로 새 주소 이동, 웹 새 주소 약관 3개 200.
- 2026-11-12 스토어: Play 제목·설명 저장(1.113.0 심사 중이라 검토 제출 보류), App Store 프로모션 텍스트 1.106.2에 저장(이름·부제·키워드는 다음 버전). 광고 이미지 15장은 레포 밖.

## 근본 원인
검색 신호를 줄 공개 정보 페이지와 보유 도메인이 없었고, 스토어 문구가 새 기능을 반영하지 않았다.

## 남은 일
- Play 스토어 문구 검토 제출(1.113.0 심사 종료 후)
- App Store 이름·부제·키워드 반영(다음 버전)
