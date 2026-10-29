---
type: issue
id: ISS-0362
created: 2026-10-24
topics: [design-system]
symptoms: ["바텀시트 닫기 X", "제목 왼쪽", showPassqlSheet, passql_sheet.dart, hasCloseButton, "시트 모양 두 종류", "iOS 시트 관례"]
root_cause: "공통 바텀시트가 제목 왼쪽 + 닫기 X를 기본으로 보여 주고, 2곳만 hasCloseButton: false로 달라 시트 모양이 갈려 있었다"
status: resolved
resolution: "[[ISS-0362-bottom-sheet-close-x-center-title-report]]"
related: ["[[DEC-0170-sheet-no-close-x-centered-title]]"]
source: "https://github.com/Twin-Fang/passQL/issues/601"
---

# ISS-0362: 바텀시트 닫기 X 제거와 제목 가운데 정렬

GitHub #601 (원본: 이슈 본문과 댓글).

## 증상
- 공통 바텀시트(`showPassqlSheet`, `app/lib/presentation/design/components/passql_sheet.dart`)가 제목을 왼쪽에 두고 오른쪽에 닫기 X를 기본으로 보여 준다. 화면 모드 선택 같은 짧은 시트에도 나온다.
- 손잡이·바깥 탭·아래로 밀기로 이미 닫히므로 X는 중복이고, iOS 시트 관례(제목 가운데, 닫기 X 없음)와도 다르다.
- 사용자 지적(2026-10-24): "바텀시트에 X가 왜 있냐고, 제목이 보통 왼쪽에 저렇게 있나?"

## 재현 조건
설정 > 화면 모드 등 `showPassqlSheet`를 쓰는 시트를 연다.

## 조사 기록
- 2026-10-24 코드 전수 확인: 사용처 11곳(닉네임 변경, 화면 모드, 프로 구매, 이용권 정보, 공지 본문, 알림 권한, AI 해설, 의견 쓰기, 의견 메뉴, 글 신고, 문제 신고). 9곳이 `title:` 사용(제목 왼쪽 + X), 2곳(프로 구매, 알림 권한)은 `hasCloseButton: false` + 본문 가운데 정렬 → 모양 두 종류.
- 같은 검수: 하드코딩 색·이모지·머티리얼 아이콘은 화면 코드에 없음, 다이얼로그는 `passql_dialog.dart` 한 곳. 시뮬레이터 점유·메모리 부족으로 캡처는 못 함.
- 전체 UI/UX 정리는 GitHub #602로 분리, 닉네임 랜덤 버튼 이동은 GitHub #579.

## 근본 원인
공통 시트의 기본값이 X 표시·제목 왼쪽이었다.
