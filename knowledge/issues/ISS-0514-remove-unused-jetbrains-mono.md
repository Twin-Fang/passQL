---
type: issue
id: ISS-0514
created: 2026-11-05
topics: [design-system]
symptoms: ["쓰지 않는 글꼴 파일", JetBrainsMonoNL-Regular.ttf, JetBrainsMonoNL-Bold.ttf, JetBrainsMono-OFL.txt, "코드 글꼴 D2Coding"]
root_cause: "#849 에서 코드 글꼴을 D2Coding 으로 바꾼 뒤 예전 JetBrains Mono NL 파일 3개가 레포에 남았다"
status: resolved
resolution: "[[ISS-0514-remove-unused-jetbrains-mono-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/858"
---

# ISS-0514: 쓰지 않는 JetBrains Mono 글꼴 파일 정리

GitHub #858.

## 증상
- `app/assets/fonts/JetBrainsMonoNL-Regular.ttf`(206KB), `JetBrainsMonoNL-Bold.ttf`(203KB), `JetBrainsMono-OFL.txt`(라이선스)가 레포에 남아 있다.
- `pubspec.yaml`·`bundled_font_licenses.dart`·코드 어디에서도 쓰지 않는다(앱 번들에는 이미 빠져 있음).

## 재현 조건
레포 `app/assets/fonts/`.

## 조사 기록
- 2026-11-05: 삭제해도 앱 동작·번들 크기 변화 없음(레포 정리만).

## 근본 원인
글꼴 교체(#849) 때 예전 파일을 지우지 않았다.
