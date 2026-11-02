---
type: issue
id: ISS-0438
created: 2026-11-01
topics: [store-release]
symptoms: ["스토어 이미지 AI 티", "보라 하늘 그라데이션 글자", "빛 번짐 배경", "홍보 이미지 옛 앱 캡처", "하단 탭 4개", "개념 학습 빠짐", store_art, store_shots, scenes.json, feature-graphic, "Android 1080x1920"]
root_cause: "홍보 이미지가 앱 디자인 토큰이 아닌 앱 아이콘 색과 검정 바탕으로 만들어졌고, 캡처가 하단 탭 개편과 개념 학습 추가 이전 모습이었다"
status: resolved
resolution: "[[ISS-0438-store-promo-images-v2-report]]"
related: ["[[ISS-0438-store-promo-images-v2-report]]", "[[DEC-0233-store-images-accent-keyword-style]]", "[[DEC-0234-no-pro-mark-on-store-images]]", "[[DEC-0169-store-listing-korean-only]]", "[[ISS-0360-store-promo-images-descriptions]]", "[[ISS-0361-billing-switch-final-checks]]"]
source: "https://github.com/Twin-Fang/passQL/issues/776"
---

# ISS-0438: 스토어 홍보 이미지 v2 교체

GitHub #776 (원본: 이슈 본문과 구현 세션의 설계 문서).

> 상태: 이 노트는 PR #777과 같은 PR로 들어간다. 작성 시점(2026-11-01)에는 미머지이며, 스토어 업로드는 이 이슈 범위 밖이다. 완료 리포트: [[ISS-0438-store-promo-images-v2-report]]

## 증상
- 홍보 이미지 7장이 검정 바탕, 빛 번짐, 보라-하늘 그라데이션 글자라 AI가 만든 티가 난다.
- 색이 앱 디자인 토큰이 아니다.
- 캡처 속 하단 탭이 4개이고 개념 학습이 빠져 있다.

## 재현 조건
해당 없음. `app/docs/store/promo/`의 이전 이미지에서 확인한다.

## 조사 기록
- 2026-11-01: 시안을 비교해 스타일과 8장 구성을 정했다 ([[DEC-0233-store-images-accent-keyword-style]]).
- 2026-11-01: 시안 검토에서 고칠 점을 찾았다. 3장은 일반 풀이 화면이라 "매번 새 선택지"가 안 보였고, 7장은 대각선이 글 위를 지났고, 8장은 순위가 5줄뿐이라 아래가 비었다.

## 근본 원인
이미지가 앱 디자인 토큰이 아닌 앱 아이콘 색과 검정 바탕으로 만들어졌고, 앱 개편 뒤 캡처를 다시 찍지 않았다.
