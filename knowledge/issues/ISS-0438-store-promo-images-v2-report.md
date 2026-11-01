---
type: completion-report
id: ISS-0438
created: 2026-11-01
topics: [store-release]
status: resolved
resolves: "[[ISS-0438-store-promo-images-v2]]"
related: ["[[DEC-0233-store-images-accent-keyword-style]]", "[[DEC-0234-no-pro-mark-on-store-images]]"]
source: "https://github.com/Twin-Fang/passQL/issues/776#issuecomment-6557293292"
---

# ISS-0438 완료 리포트: 홍보 이미지 8장과 그래픽 이미지를 토큰 스타일로 교체하고 최신 앱으로 재촬영

GitHub #776 리포트 댓글 6557293292 기준 (2026-11-01).

> 머지 상태: 작성 시점(2026-11-01)에 PR #777 미머지. 코드 마지막 커밋은 `1fad8e8d`이다. 스토어 업로드는 하지 않았다.

## 해결 방법
- **렌더러:** `scenes.json`에 장면 종류(`single`, `pair`, `diagonal`), 키워드, `align`, 규격별 `gap`을 넣고 `render.py`가 종류별 템플릿으로 렌더한다. 뱃지와 보조 문구를 뺐다. Android는 2160x3840이다.
- **연결 쌍:** 1, 2장은 넓은 캔버스를 찍어 가운데 간격을 버리고 좌우로 자른다. 간격은 iOS 6.9" 40, Android 128, 6.5" 39, 6.3" 37이다.
- **캡처:** `capture_store_set.sh`로 iPhone 16 Pro 시뮬레이터에서 전 장면을 찍는다. `main_shots.dart`에 `real-mode` 연출(선택지 생성 중에서 멈춤)을 넣고 순위를 10줄로 늘렸다.
- **검증:** `test_render.py` 6개 항목 통과, 수정 전후 iOS 6.9" 전체 장과 그래픽 이미지 비교.
- **확인하지 못한 것:** 스토어 콘솔에서 연결 쌍이 맞물리는지.

## 근본 원인 (확정)
이미지가 앱 디자인 토큰이 아닌 앱 아이콘 색과 검정 바탕으로 만들어졌고, 앱 개편 뒤 캡처를 다시 찍지 않았다.

## 재발 방지
- `app/docs/store/README.md`에 토큰만 쓰는 규칙과 촬영 명령을 적었다.
- `test_render.py`가 결과물 크기, 쌍 자르기, 루트 README 표를 검사한다.
- 결제 스위치를 켤 때 설명 문구에 무료, 프로 구분을 함께 추가한다 ([[DEC-0234-no-pro-mark-on-store-images]]).

## 교훈
- 폰 크기를 바꾸면 `render.py`의 비율 계산과 템플릿 값을 함께 고친다. 두 곳이 같은 값을 따로 갖고 있다.
- 촬영 스크립트는 16 Pro의 passQL을 캡처용 앱으로 바꾼다. 끝나면 `flutter run`으로 되돌린다.
