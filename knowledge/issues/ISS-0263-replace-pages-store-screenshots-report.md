---
type: completion-report
id: ISS-0263
created: 2026-10-15
topics: [store-release]
status: resolved
resolves: "[[ISS-0263-replace-pages-store-screenshots]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/457"
---

# ISS-0263 완료 리포트: GitHub Pages 5장 교체, 스토어 규격 이미지 준비(업로드는 다음 심사 때)

GitHub #457 구현 보고서(2026-10-15)와 완료 처리 댓글(2026-10-16) 기준.

## 해결 방법
- 촬영: `app/tool/store_shots/main_shots.dart`(가짜 API 촬영 진입점), 촬영 전용 시뮬레이터(iPhone 16 Pro Max 1320×2868, iPad Pro 13 M4 2064×2752, iOS 18.3), 라이트 모드, 상태바 9:41, 기준 main `cb3878a`.
- GitHub Pages(`gh-pages` `26edcf3`): `shots/home·questions·detail·stats·rank.jpg` 486×972로 교체, HTML·CSS 변경 없음.
- 스토어 이미지(로컬 `docs/projectops/store-assets/`, 커밋 대상 아님): `ios-6.9` 1290×2796, `ios-6.5` 1242×2688, `ios-6.3` 1206×2622(폭 맞춤 후 위아래 가운데 자르기), `ipad-13` 2064×2752(원본), `android-phone` 1080×2160·`android-phone-9x16` 1080×1920(높이 맞춤 후 좌우 배경색 채우기). 이전 이미지는 `store-assets/_old_20261007/`.
- README는 앱 화면 이미지가 없어 바꾸지 않음.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 검증: `https://twin-fang.github.io/passQL/` 200, `shots/home.jpg` 해시 일치, `sips`로 6개 폴더 규격 일치.
- 재촬영 방법(원본): `flutter build ios --simulator --debug -t tool/store_shots/main_shots.dart` 빌드 → 경로를 `/tmp/passql_shot_route.txt`에 적고 `simctl launch`로 실행해 촬영.
- 남은 것(원본): 스토어 업로드 실제 반영 여부는 확인하지 않음. 홈 큰 제목 "오늘도 한 문제씩, 합격에 가까워지고 있어요"가 한 줄 말줄임으로 보임(문구·두 줄 허용은 별도 결정). iPad는 폰 레이아웃이 늘어나 홈 달력 칸이 매우 큼.

## 교훈
원본: Android 2:1 이미지는 예전처럼 iPhone 화면을 위아래로 자르면 상태바와 하단 탭바가 잘려, 높이에 맞추고 좌우를 채우는 방식으로 바꿨다.
