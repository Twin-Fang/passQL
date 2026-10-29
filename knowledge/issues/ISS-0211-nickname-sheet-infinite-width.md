---
type: issue
id: ISS-0211
created: 2026-10-07
topics: [auth-member, design-system]
symptoms: [닉네임 변경 시트 안 열림, 모달 배경만 표시, "BoxConstraints forces an infinite width", OutlinedButton minimumSize, "Size.fromHeight(44)", nickname_edit_sheet.dart]
root_cause: "앱 테마 `OutlinedButton`의 `minimumSize: Size.fromHeight(44)`(최소 폭 무한대)를 '중복확인' 버튼이 가로 `Row` 안에서 상속해 레이아웃 예외가 났다"
status: resolved
resolution: "[[ISS-0211-nickname-sheet-infinite-width-report]]"
related: ["[[ISS-0202-top-level-qa-real-account-e2e]]"]
source: "https://github.com/Twin-Fang/passQL/issues/366"
---

# ISS-0211: 닉네임 변경 시트가 열리지 않음 — 중복확인 버튼 무한 폭 제약으로 레이아웃 예외

GitHub #366 (원본: 이슈 본문과 댓글).

## 증상
설정 → 프로필 카드를 눌러도 닉네임 변경 시트가 나타나지 않는다. 화면만 어두워지고(모달 배경) 시트 내용은 그려지지 않는다. 닉네임 직접 변경이 사실상 불가.

## 재현 조건
QA GitHub #357 영역 8(iPhone 16 Pro, 실계정, 디버그 빌드): 설정 탭 → "눌러서 닉네임 변경" 카드 탭. Maestro 접근성 검사에서도 "닉네임 변경" 텍스트 없음.

## 조사 기록
- 2026-10-07: `flutter run` 로그로 `BoxConstraints forces an infinite width` 확인 (`nickname_edit_sheet.dart:182`). 위젯 테스트(기본 테마)에서는 재현되지 않아 놓쳤다.

## 근본 원인
테마의 `Size.fromHeight(44)`가 최소 폭을 무한대로 만들고, `Row` 안 버튼이 이를 상속.
