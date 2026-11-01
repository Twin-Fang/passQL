---
type: completion-report
id: ISS-0439
created: 2026-11-01
topics: [store-release]
status: resolved
resolves: "[[ISS-0439-store-images-no-sql-keyword]]"
related: ["[[DEC-0235-store-images-no-sql-keyword]]", "[[DEC-0233-store-images-accent-keyword-style]]"]
source: "https://github.com/Twin-Fang/passQL/issues/778#issuecomment-6558838513"
---

# ISS-0439 완료 리포트: 스토어 이미지 8장과 그래픽 이미지에서 SQL 키워드 제거

GitHub #778 리포트 댓글 6558838513 기준 (2026-11-01).

> 머지 상태: 작성 시점(2026-11-01)에 미머지. 코드 커밋은 `ebd1cfb2`이다. 스토어 업로드는 하지 않았다.

## 해결 방법
- **키워드:** 템플릿 4개, `render.py`, `scenes.json`, `test_render.py`에서 키워드를 지웠다.
- **위치:** 헤드라인 위치를 18에서 20으로, 폰 위치를 152에서 104로, 기운 폰 위치를 150에서 122로 옮겼다. 캡처 위치 계산은 `unit * 108`로 맞췄다.
- **그래픽 이미지:** 로고와 문구를 세로 가운데로 옮겼다.
- **검증:** `test_render.py` 5개 항목 통과. iOS 6.9"와 Android 8장, iOS 6.3" 1~4장, 그래픽 이미지를 눈으로 확인했다. iOS 6.5"는 테스트로만 확인했다.
- **확인하지 못한 것:** 스토어 콘솔에서 1·2장이 맞물리는지.

## 근본 원인 (확정)
큰 SQL 키워드는 SQL을 모르는 사람에게 뜻이 전해지지 않고, 쉬운 단어로 바꿔도 헤드라인과 정렬이 어긋나고 빈 공간이 남았다.

## 재발 방지
- 키워드를 쓰지 않는 기준을 [[DEC-0235-store-images-no-sql-keyword]]에 남겼다.

## 알고 남긴 것
- iOS 3·4장 상단 제목 "SELECT 기본"이 폰 윗선에 걸려 잘린다.
- "실행 성공" 문구가 1·2장 경계에서 잘린다.
- 5~7장 하단 탭 바와 버튼이 잘린다.
- Android 3·4장은 문제 본문 없이 "테이블 1개"부터 시작한다.
- 3장은 `real-mode` 연출인 "선택지 생성 중" 화면이라 선택지가 보이지 않는다. 재촬영하지 않기로 했다.

## 교훈
- 첫 렌더에서 iOS 6.3" 1·2장 아래에 검은 띠가 81줄 생겼다. `test_render.py`가 잡았고 다시 렌더하니 사라졌다. 원인은 고치지 않았으므로 렌더 후 테스트를 꼭 돌린다.
- 폰 위치를 바꾸면 템플릿과 `render.py`의 `unit * 108`을 함께 고친다. 두 곳이 값을 따로 갖고 있다.
