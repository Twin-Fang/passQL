---
type: completion-report
id: ISS-0342
created: 2026-10-21
topics: [practice, design-system]
status: resolved
resolves: "[[ISS-0342-choice-card-layout-jump-table-font]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/554"
---

# ISS-0342 완료 리포트: 채점 아이콘 자리 상시 확보, 한글 섞인 칸은 본문 글꼴

GitHub #554 리포트 댓글(`## 개요`, 2026-10-21) 기준. 커밋 89921f02, v1.27.0.

## 해결 방법
- `passql_choice_card.dart`: 채점 아이콘 자리를 항상 확보.
- `result_rows_table.dart`: `toTableCellTextStyle` — 한글이 섞인 칸은 본문 글꼴, 그 외 코드 글꼴. `schema_table_preview.dart`도 같은 규칙.
- `stem_text.dart`: 인라인 코드 안 공백을 줄바꿈 안 되는 공백으로.
- `execute_result_card.dart`, `question_solving_body.dart`: 실행 결과 머리에 "보기 B · 실행 성공"처럼 실행한 보기 표시.
- `daily_set_result_page.dart`: 상단 바 제목과 같은 점수 고리 캡션 제거.

## 근본 원인 (확정)
항목별로 위 해결 방법에 적힌 위젯이 원인이었다(별도 원인 서술 없음).

## 재발 방지
- 검증: iOS 시뮬레이터 1번 채점 전후 A 보기 폭·줄바꿈 동일, "알 수 없음" 띄어쓰기 정상. `flutter analyze` 이슈 0, `flutter test` 통과.
- 주의: 아이콘 자리 확보로 채점 전에도 보기 내용 폭이 아이콘 너비만큼 좁다(흔들림 제거와 맞바꾼 것). 실행 결과 열 이름 소문자(`id`)는 샌드박스 DB가 돌려준 이름이라 범위에서 제외. QA 중 보류한 "결과 화면 점수 미노출"은 목록이 스크롤된 상태였던 것으로 확인돼 결함이 아니다.

## 교훈
(원본에 없음, 볼트 정리) 상태 전환 때 붙는 아이콘은 자리를 미리 확보해 레이아웃 점프를 막는다.
