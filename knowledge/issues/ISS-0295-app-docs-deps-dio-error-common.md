---
type: issue
id: ISS-0295
created: 2026-10-15
topics: [dev-workflow]
symptoms: [app/CLAUDE.md 현행화, flutter_screenutil, font_awesome_flutter, riverpod_generator 미사용, "on DioException catch", asAppException 반복, 선택지 빈 화면]
root_cause: "문서가 실제 의존성과 어긋났고, 미사용 의존성과 Dio 오류 변환 반복 코드가 남아 있었으며, 선택지가 비면 빈 화면이었다"
status: resolved
resolution: "[[ISS-0295-app-docs-deps-dio-error-common-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/489"
---

# ISS-0295: 앱 문서·의존성 불일치와 Dio 오류 변환 반복

GitHub #489 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- `app/CLAUDE.md`에 pubspec에 없는 `flutter_screenutil`, `font_awesome_flutter`가 적혀 있음.
- `riverpod_annotation`, `riverpod_generator`는 사용 0건.
- `on DioException catch > asAppException` 패턴 5곳 반복.
- 선택지가 비면 안내 없이 빈 화면.
- 위치: `app/CLAUDE.md:14,110`, `app/pubspec.yaml:14,46`, `settings_providers.dart`, `auth_provider.dart`, `feedback_providers.dart`, `widgets/question/question_sections.dart:135`.

## 재현 조건
선택지가 빈 준비된 세트를 열 때(빈 화면). 나머지는 해당 없음.

## 조사 기록
- 2026-10-15: 제안 — 문서 현행화, 미사용 의존성 제거, Dio 인터셉터에서 `AppException` 변환을 한 곳으로, 선택지 빈 상태 화면.

## 근본 원인
frontmatter `root_cause`와 같음.
