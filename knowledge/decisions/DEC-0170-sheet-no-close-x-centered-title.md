---
type: decision
id: DEC-0170
created: 2026-10-24
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0362-bottom-sheet-close-x-center-title]]", "[[ISS-0362-bottom-sheet-close-x-center-title-report]]"]
---

# DEC-0170: 앱 공통 바텀시트는 닫기 X 없이 제목을 가운데 둔다 (`hasCloseButton` 옵션 폐지)

## 문제 정의 (Context)
공통 시트가 제목 왼쪽 + 닫기 X를 기본으로 보여 주고, 일부 시트만 X를 끄고 있어 앱 안 시트 모양이 두 종류였다. 사용자 지적(2026-10-24) (GitHub #601).

## 결정 (Decision)
- `showPassqlSheet`에서 닫기 X와 `hasCloseButton` 옵션을 없애고 제목을 가운데 정렬한다.
- 닫기는 손잡이 드래그, 바깥 탭, 뒤로가기로 하고, 필요한 시트만 본문 안 버튼으로 닫는다.

## 검토한 대안 (Alternatives)
논의 기록 없음. 이슈 본문이 적은 근거: 손잡이·바깥 탭·아래로 밀기로 이미 닫혀 X는 중복이고, iOS 시트 관례(제목 가운데, 닫기 X 없음)와 다르다.

## 결과 (Consequences)
**긍정**
- 사용처 11곳이 한 모양이 된다.

**부정**
- 논의 기록 없음. (이슈 본문은 X를 쓰던 곳이 닫을 방법이 없어지지 않는지 전수 확인하고, 스크림 탭 시맨틱 라벨이 스크린 리더에서 유지되는지 확인하라고 적었다.)

## 영향 범위 (Scope)
`app/lib/presentation/design/components/passql_sheet.dart`, `showPassqlSheet` 사용처 11곳, 관련 테스트(`components_test`, `accessibility_semantics_test`, `result_screens_test`, `notification_inbox_page_test`, `daily_set_screens_test`).

## 출처 (References)
- GitHub #601 이슈 본문, 검수 댓글·완료 보고(2026-10-24), PR #604
- 관련 기존 결정: DEC-0116(앱은 Apple iOS HIG 스타일 단일 디자인 시스템)
- [[ISS-0362-bottom-sheet-close-x-center-title]]
