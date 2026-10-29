---
type: issue
id: ISS-0291
created: 2026-10-15
topics: [design-system]
symptoms: [assets/fonts 23MB, Pretendard 미사용 굵기, JetBrainsMono 미등록, iOS Android 코드 글꼴 다름, pubspec]
root_cause: "Pretendard 9종 중 4종만 쓰면서 전부 포함했고, 타이포 토큰이 쓰는 JetBrainsMono는 pubspec에 등록되지 않았다"
status: resolved
resolution: "[[ISS-0291-remove-unused-fonts-register-code-font-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/485"
---

# ISS-0291: 앱 미사용 폰트와 미등록 코드 폰트

GitHub #485 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- `assets/fonts` 23MB, Pretendard 9종 중 4종만 사용.
- 타이포 토큰이 JetBrainsMono를 쓰지만 pubspec에 등록되지 않아 iOS/Android 코드 글꼴이 다름.
- 위치: `app/pubspec.yaml`, `app/lib/presentation/design/tokens/passql_typography.dart:39,47,54`.

## 재현 조건
SQL 코드 표시 화면을 iOS와 Android에서 비교.

## 조사 기록
- 2026-10-15: 제안 — 미사용 5종 제거 또는 가변 폰트 1개로, 코드 폰트 등록 또는 토큰 정리.

## 근본 원인
frontmatter `root_cause`와 같음.
