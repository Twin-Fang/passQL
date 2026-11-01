---
type: issue
id: ISS-0439
created: 2026-11-01
topics: [store-release]
symptoms: ["스토어 이미지 SQL 키워드", "DISTINCT HAVING 이해 못 함", "키워드 가운데 정렬 어긋남", "짧은 키워드 양옆 빔", store_art, scenes.json, feature-graphic]
root_cause: "큰 SQL 키워드는 SQL을 모르는 사람에게 뜻이 전해지지 않고, 쉬운 단어로 바꿔도 헤드라인과 정렬이 어긋나고 빈 공간이 남았다"
status: resolved
resolution: "[[ISS-0439-store-images-no-sql-keyword-report]]"
related: ["[[ISS-0439-store-images-no-sql-keyword-report]]", "[[DEC-0235-store-images-no-sql-keyword]]", "[[DEC-0233-store-images-accent-keyword-style]]", "[[ISS-0438-store-promo-images-v2]]"]
source: "https://github.com/Twin-Fang/passQL/issues/778"
---

# ISS-0439: 스토어 이미지에서 SQL 키워드 제거

GitHub #778 (원본: 이슈 본문과 구현 세션).

> 상태: 이 노트는 코드 수정과 같은 PR로 들어간다. 작성 시점(2026-11-01)에는 미머지이며, 스토어 업로드는 이 이슈 범위 밖이다. 완료 리포트: [[ISS-0439-store-images-no-sql-keyword-report]]

## 증상
- SQL을 모르는 사람은 `DISTINCT`, `HAVING`이 왜 있는지 알 수 없다는 피드백을 받았다.
- 3, 4, 5장을 `UPDATE`, `WHERE`, `NOW`로 바꾸자 왼쪽 정렬 헤드라인과 가운데 정렬 키워드가 어긋났다.
- 글자 크기를 6글자 기준으로 고정해 `NOW`, `RANK`는 양옆이 크게 비었다.

## 재현 조건
`app/tool/store_art/scenes.json`의 키워드를 3~5글자 단어로 바꾸고 `render.py`로 렌더하면 나타난다.

## 조사 기록
- 2026-11-01: 키워드 교체 결과를 iOS 6.9"와 Android 8장에서 확인했다. 정렬과 빈 공간 문제가 보였다.
- 2026-11-01: 키워드를 뺀 시안을 임시 복사본으로 렌더해 비교한 뒤 제거를 확정했다.

## 근본 원인
큰 SQL 키워드는 SQL을 모르는 사람에게 뜻이 전해지지 않는다. 쉬운 단어로 바꿔도 정렬 어긋남과 빈 공간이 남았다. 피드백 대상 사용자 수나 반응은 측정하지 않았다 (논의 기록 없음).
