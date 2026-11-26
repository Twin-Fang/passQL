---
type: completion-report
id: ISS-0548
created: 2026-11-26
topics: [store-release]
status: resolved
resolves: "[[ISS-0548-store-promo-recapture-new-ui]]"
related: ["[[ISS-0438-store-promo-images-v2]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1179#issuecomment-7180020827"
---

# ISS-0548 완료 리포트: 캡처 기기를 17 Pro로 바꾸고 홍보 이미지 전체를 다시 찍음

GitHub #1179 리포트 댓글 7180020827 기준 (2026-11-26).

> 머지 상태: 작성 시점에 PR #1180 미머지. 이미지 커밋은 `1c99f9ee`이다. 스토어 업로드는 하지 않았다.

## 해결 방법
- **캡처 기기:** `capture_store_set.sh`의 시뮬레이터 ID를 iPhone 17 Pro로 바꾸고 README 표기를 고쳤다.
- **이미지:** 원본 캡처 8장 재촬영, `render.py`로 iOS 6.9·6.5·6.3, Android 각 8장과 Play 그래픽 이미지를 다시 만들었다. 문구(`scenes.json`)는 그대로다.
- **검증:** 원본 8장을 열어 로딩·빈 화면이 없는지 확인, 규격별 크기 확인, `test_render.py` 4개 통과.

## 근본 원인 (확정)
앱 UI가 바뀐 뒤 원본 캡처를 다시 찍지 않았고, 캡처 스크립트가 사라진 시뮬레이터 ID에 묶여 있었다.

## 재발 방지
- 캡처 기기는 사용자가 정한 시뮬레이터만 쓴다. 기기가 바뀌면 스크립트의 `DEVICE`와 README를 함께 고친다.
- 탭 화면 구조가 바뀌는 UI 작업 뒤에는 홍보 이미지 재촬영이 필요한지 확인한다.

## 교훈
- `-t` 진입점으로 빌드하면 커밋에서 빠지는 `ios/Flutter/Generated.xcconfig`에 캡처용 진입점(`FLUTTER_TARGET`)이 남는다. 캡처 뒤 `flutter build ios --config-only --simulator`로 `lib/main.dart`에 되돌린다.
- `render.py`·`test_render.py`는 Pillow가 필요하다. 시스템 python3에 없으면 임시 가상환경에서 실행한다.
- 캡처 빌드 중 `pod install`이 `app/ios/Podfile.lock`을 바꿀 수 있다. 이 작업과 상관없으면 커밋에서 뺀다.
- 6장 프로필은 캡처용 가짜 데이터라 "과락 위험, 예상 40점"이 보인다. 홍보용으로 바꿀지는 아직 정하지 않았다.
