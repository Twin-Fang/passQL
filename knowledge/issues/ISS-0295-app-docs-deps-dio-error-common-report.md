---
type: completion-report
id: ISS-0295
created: 2026-10-15
topics: [dev-workflow]
status: resolved
resolves: "[[ISS-0295-app-docs-deps-dio-error-common]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/489"
---

# ISS-0295 완료 리포트: `callApiThrowingAppException` 공통화, 미사용 riverpod 생성기 제거, 문서 현행화

GitHub #489 구현 보고서 댓글 기준 (2차 통합본).

## 해결 방법
- `on DioException catch > asAppException` 반복을 `callApiThrowingAppException` 하나로 모음.
- 사용 0건인 `riverpod_annotation`, `riverpod_generator` 제거.
- `app/CLAUDE.md`의 없는 패키지 기술 현행화.
- 준비된 세트의 선택지가 비면 안내와 다시 시도 표시.
- 검증: `flutter analyze` 경고 0, `flutter test` 292개 통과.

## 근본 원인 (확정)
이슈 본문과 같음.

## 재발 방지
원본에 별도 언급 없음. (이슈 본문은 "Dio 인터셉터에서" 변환을 제안했으나 구현은 `callApiThrowingAppException` 함수로 모았다.)

## 교훈
원본에 없음.
