---
type: completion-report
id: ISS-0409
created: 2026-10-27
topics: [design-system, auth-member]
status: resolved
resolves: "[[ISS-0409-radius-tokens-nickname-edit-cleanup]]"
related: ["[[DEC-0186-card-radius-equals-button-even-tokens]]"]
source: "https://github.com/Twin-Fang/passQL/issues/687"
---

# ISS-0409 완료 리포트: 카드·버튼·토스트 12, 아이콘 타일 8, 프로필 카드 전체 탭으로 닉네임 편집

GitHub #687 리포트 댓글 기준.

## 해결 방법
- 토큰: `passql_size.dart` `avatar` 52 > 40, `passql_radius.dart` `lg` 16 > 12(버튼 `md`와 같은 값), `iconTile` 7 > 8.
- `app_toast.dart`: `StadiumBorder` > `RoundedRectangleBorder(12)`. 색, 글자(15), 여백 그대로.
- `profile_card.dart`: '편집' 버튼 제거, 카드 전체를 `PassqlPressable`로, 오른쪽 `chevron_forward`(22, `tertiaryLabel`), 카드 높이 84 > 72, 스크린리더 '닉네임 {이름}, 편집'.
- `nickname_edit_sheet.dart`: 버튼 순서 '랜덤 닉네임으로 바꾸기' > '저장'.
- `daily_set_card.dart`: 홈 '풀어보기' 버튼 small(34, 캡슐) > 기본 large(50, 12).
- `main_shots.dart`: `nickname-sheet`, `nickname-toast`, `nickname-edit` 촬영 연출.

## 근본 원인 (확정)
둥글기 값과 버튼 크기·위계가 화면마다 달랐다.

## 재발 방지
- `PassqlRadius.lg`와 `md`가 둘 다 12지만 의미(카드·버튼) 구분을 위해 토큰은 따로 둔다.
- 시트 위쪽 모서리와 광고 인라인 카드도 `lg`라 함께 12. 네이티브 광고 카드 안 미디어·CTA는 네이티브 코드에서 따로 정해져 무관.
- 작은 인라인 버튼(다시 시도, 더 보기, 해제 등)은 계속 캡슐.
- 검증: `flutter analyze` 무이슈, `flutter test` 통과. 시뮬레이터 다크 모드 가짜 API 촬영. 실계정과 라이트 모드는 확인하지 않음.

## 교훈
(원본에 없음, 볼트 정리) 같은 용도의 버튼 모양이 다르면 모양 예외 규칙보다 크기 옵션 통일을 먼저 검토한다(리포트의 되돌린 예외 규칙 사례).
