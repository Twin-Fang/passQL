---
type: completion-report
id: ISS-0502
created: 2026-11-12
topics: [practice, question-bank, design-system]
status: resolved
resolves: "[[ISS-0502-stem-table-same-columns-overwritten]]"
related: ["[[DEC-0292-stem-table-match-by-name-short-code-caption]]", "[[ISS-0504-question-structure-audit-harness]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1015"
---

# ISS-0502 완료 리포트: 표는 이름 기준 대체, 코드 제목은 짧은 이름표만 (앱·웹)

## 해결 방법
- 앱 `stem_blocks.dart`, 웹 `stemSchemaTablePlacement.ts`: 스키마 표 대체를 이름 기준으로(지문 표에 이름이 없을 때만 컬럼 서명), 대체한 자리 재사용 금지, 예시 행 없는 스키마 표는 지문 행 유지.
- 앱 `passql_code_block.dart`·`stem_text.dart`, 웹 `stemBlocks.ts`·`QuestionCodeBox.tsx`: 코드 제목은 짧은 이름표 주석(`-- SQL 1`)만, 그 외 `--` 주석은 코드 안 회색 주석.
- 테스트: 앱 `stem_blocks_test.dart`, 웹 `stemBlocks.test.ts`에 EMP·PROJ 사례.
- 커밋 4d349dc7, PR #1018, 배포 PR #1019. 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1015#issuecomment-6821643670

## 근본 원인 (확정)
앱이 스키마 표마다 컬럼 서명이 같은 첫 번째 지문 블록을 교체해, 같은 서명의 두 번째 스키마 표가 이미 교체된 자리를 덮었다. 데이터 결함 아님.

## 재발 방지
- 운영 활성 499건을 새 규칙으로 재검증해 앱·웹 표 소실 0건([[ISS-0504-question-structure-audit-harness]]). 하네스 lint에 이름 다른 같은 컬럼 표 경고 추가.
- 검증: 운영 배포 워크플로우 5개 성공. 실기기 검증은 하지 않음.

## 교훈
- 표 배치 규칙은 앱·웹·서버(`QuestionFormatRule`)·하네스 lint 네 곳에 있다. 한 곳만 바꾸면 어긋난다.
- "지문 표가 안 보인다"는 신고는 데이터보다 배치 코드를 먼저 의심한다.
