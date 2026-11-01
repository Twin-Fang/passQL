---
type: decision
id: DEC-0233
created: 2026-11-01
reviewed: null
topics: [store-release]
status: superseded
supersedes: DEC-0169
superseded_by: DEC-0235
related: ["[[DEC-0169-store-listing-korean-only]]", "[[ISS-0438-store-promo-images-v2]]", "[[ISS-0438-store-promo-images-v2-report]]", "[[DEC-0234-no-pro-mark-on-store-images]]", "[[DEC-0235-store-images-no-sql-keyword]]"]
---

# DEC-0233: 스토어 홍보 이미지는 앱 토큰의 `accent` 단색 바탕과 큰 SQL 키워드로 만들고, 한국어와 `scenes.json` 렌더 방식은 유지한다

## 문제 정의 (Context)
[[DEC-0169-store-listing-korean-only]]의 이미지 방식(검정 바탕, 앱 아이콘의 보라 > 하늘 그라데이션)이 AI가 만든 티가 났고 앱 디자인 토큰도 아니었다 (GitHub #776).

## 결정 (Decision)
- 바탕은 8장 모두 `accent` 단색, 글자는 `onAccent`로 한다. 헤드라인은 Pretendard Bold, 장마다 다른 SQL 키워드는 JetBrains Mono NL Bold로 크게 쓴다.
- 색과 글꼴은 앱 디자인 토큰만 쓴다. 그라데이션 글자, 글로우 그림자, 빛 번짐 배경을 쓰지 않는다. 뱃지와 보조 문구도 뺀다.
- 8장을 다 쓴다. 1, 2장은 폰 한 대와 `SELECT`가 경계를 넘어 이어지고, 폰 화면은 다크, 라이트를 번갈아 쓰며, 7장은 개념 화면을 대각선으로 나눈다.
- 화면은 최신 앱에서 찍은 실제 캡처만 쓴다. 색 반전이나 손으로 고친 캡처를 쓰지 않는다.
- **DEC-0169에서 유지:** 이미지와 설명 문구는 한국어만 만들고, 문구는 `app/tool/store_art/scenes.json`만 고쳐 `render.py`로 재생성한다.

## 검토한 대안 (Alternatives)
시안을 비교해 스타일을 골랐고, 그래픽 이미지는 시안 A1을 선택했다. 다른 시안의 구체적인 내용은 저장소에 남아 있지 않다 (시안 파일은 로컬 전용).

## 결과 (Consequences)
**긍정**
- 이미지가 앱 토큰을 따르므로 앱과 색이 어긋나지 않는다.

**부정**
- 앱 화면이 바뀌면 전 장면을 다시 찍어야 한다. App Store는 문구를 바꾸면 새 버전 심사가 필요하다는 DEC-0169의 제약도 그대로다.

## 영향 범위 (Scope)
`app/tool/store_art/`, `app/tool/store_shots/`, `app/docs/store/`, `README.md`.

## 출처 (References)
- GitHub #776 이슈 본문, 리포트 댓글 6557293292 (2026-11-01)
- 스타일 선택 근거: 구현 세션 설계 문서의 "결정된 것 (사용자)" 항목
