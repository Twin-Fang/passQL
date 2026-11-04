---
type: completion-report
id: ISS-0450
created: 2026-11-05
topics: [store-release, design-system]
status: resolved
resolves: "[[ISS-0450-promo-site-dynamic-revamp]]"
related: ["[[DEC-0247-promo-site-free-banner-while-billing-off]]", "[[DEC-0248-site-icons-generated-from-brand]]", "[[DEC-0139-intro-site-generated-from-src]]"]
source: "https://github.com/Twin-Fang/passQL/issues/823"
---

# ISS-0450 완료 리포트: 움직이는 첫 화면, 새 아이콘 생성, Play 공개·무료 안내 반영

GitHub #823 리포트 기준 (2026-11-05). 원본 사본: `_sources/issues/ISS-0450-promo-site-dynamic-revamp-report.md` (로컬 전용). 사이트는 gh-pages `aa1f4095`·`3bf48a5e`로 게시, main 변경은 PR #825.

## 해결 방법
- **첫 화면**: 새 앱 아이콘(떠오름), 오로라 배경, 캡처 4장이 3.2초마다 바뀌는 폰, 떠 있는 카드 3개. 아래로 흐르는 주제 띠, 올라가는 숫자 4칸, 스크롤에 맞춰 폰이 기울어지며 들어오는 기능 자세히 5줄. 효과 CSS는 `effects.css`, 동작은 `site.js`(스크롤 값 `--lift`·`--tilt`·`--focus`를 한 프레임에 한 번).
- **새 기능 반영**: 기능 카드 12개(단원별 개념 학습, 내 답 vs 정답 비교, 매번 새 선택지 추가), 캡처를 스토어 캡처 세트(#776)로 교체.
- **Play 공개**: `IS_PLAY_STORE_PUBLIC = True` 한 줄로 설치 버튼·JSON-LD 설치 주소·FAQ 갱신. Android 방문자는 Play 버튼이 앞으로(`html.is-android`).
- **결제 꺼짐 동안 무료 안내** → [[DEC-0247-promo-site-free-banner-while-billing-off]].
- **아이콘 원본 생성** → [[DEC-0248-site-icons-generated-from-brand]]. 사이트 `_src/build_icons.py`, main 브랜드 생성 목록에 Play 등록정보 아이콘 512px 추가.
- **main (PR #825)**: Play 그래픽 이미지 재생성, 스토어 설명에 새 기능 3개, README Play 배지·소개 페이지 배지·핵심 기능 2칸.
- **검증**: 운영 주소를 pro-launch로 모바일 390·데스크톱 1366, 라이트·다크 캡처. 핵심 문구 4개 통과, 콘솔 오류 0, 가로 넘침 없음. 코드 점검으로 직접 쓴 색 2곳을 토큰으로, OG 색을 brand-colors.json에서 읽게 수정.

## 근본 원인 (확정)
홍보 자산이 앱 변경을 따라 갱신되는 절차가 없었고, 사이트 아이콘·OG가 원본에서 생성되지 않는 사본이었다.

## 재발 방지
- 사이트 아이콘·OG는 `_src/build_icons.py`가 main 아이콘 원본·브랜드 색에서 생성. Play 등록정보 아이콘은 브랜드 `--check` 대상.

## 알고 남긴 것
- Play Console 등록정보(아이콘 512·그래픽 이미지·설명) 교체는 콘솔 본인 인증(비밀번호 재입력) 때문에 사용자가 직접 해야 한다.
- 레포 About 홈페이지를 소개 페이지로 바꾸는 것은 승인 대기 (pro-oss-consult 진단 권고).
- 안 쓰는 옛 캡처 `shots/home.webp`·`questions.webp`는 삭제 허락 범위가 아니라 남김.

## 교훈
(원본에서 정리)
- 아이콘·스토어 공개 상태가 바뀌면 소개 사이트·README·스토어 그래픽까지 같은 이슈에서 함께 갱신한다. 손 사본 대신 원본에서 생성하는 스크립트를 둔다.
