---
type: decision
id: DEC-0235
created: 2026-11-01
reviewed: null
topics: [store-release]
status: active
supersedes: DEC-0233
superseded_by: null
related: ["[[DEC-0233-store-images-accent-keyword-style]]", "[[DEC-0234-no-pro-mark-on-store-images]]", "[[ISS-0439-store-images-no-sql-keyword]]", "[[ISS-0439-store-images-no-sql-keyword-report]]"]
---

# DEC-0235: 스토어 홍보 이미지와 그래픽 이미지에 큰 SQL 키워드를 넣지 않는다

## 문제 정의 (Context)
[[DEC-0233-store-images-accent-keyword-style]]의 큰 SQL 키워드를 두고, SQL을 모르는 사람은 `DISTINCT`, `HAVING`이 왜 있는지 알 수 없다는 피드백을 받았다 (GitHub #778). 3, 4, 5장을 쉬운 단어로 바꿔 보니 왼쪽 정렬 헤드라인과 가운데 정렬 키워드가 어긋나고, 짧은 단어는 양옆이 비어 보였다.

## 결정 (Decision)
- 홍보 이미지 8장과 Play 그래픽 이미지에서 큰 SQL 키워드를 뺀다.
- 키워드가 있던 자리만큼 폰을 위로 올려 앱 화면을 더 보여 준다.
- **DEC-0233에서 유지:** 바탕은 `accent` 단색, 글자는 `onAccent`, 헤드라인은 Pretendard Bold다. 색과 글꼴은 앱 토큰만 쓰고, 그라데이션 글자, 글로우 그림자, 빛 번짐 배경, 뱃지와 보조 문구를 쓰지 않는다. 8장을 다 쓰고, 1·2장은 폰 한 대가 경계에 걸치며, 7장은 대각선으로 나눈다. 화면은 최신 앱의 실제 캡처만 쓴다.
- **DEC-0169에서 이어 온 것도 유지:** 이미지와 설명 문구는 한국어만 만들고, 문구는 `app/tool/store_art/scenes.json`만 고쳐 `render.py`로 재생성한다.

## 검토한 대안 (Alternatives)
- **3, 4, 5장을 `UPDATE`, `WHERE`, `NOW`로 교체:** 실제로 렌더해 봤지만 정렬 어긋남과 빈 공간이 남아 버렸다.
- **키워드를 왼쪽 정렬로 되돌리기:** 제안했지만, 사용자가 키워드 제거를 골라 렌더하지 않았다.

## 결과 (Consequences)
**긍정**
- 키워드 선택을 설명할 필요가 없고, 앱 화면이 더 많이 보인다.

**부정**
- 이미지에서 눈길을 끄는 큰 글자가 사라진다. 사용자 반응은 아직 측정하지 않았다.
- 폰 위치에 맞춰 일부 캡처의 위나 아래가 잘린다. 구체적인 위치는 [[ISS-0439-store-images-no-sql-keyword-report]]에 있다.
- App Store는 문구를 바꾸면 새 버전 심사가 필요하다는 DEC-0169의 제약은 그대로다.

## 영향 범위 (Scope)
`app/tool/store_art/`, `app/docs/store/promo/`.

## 출처 (References)
- GitHub #778 이슈 본문, 리포트 댓글 6558838513 (2026-11-01)
