---
type: issue
id: ISS-0409
created: 2026-10-27
topics: [design-system, auth-member]
symptoms: ["토스트 캡슐 모양", StadiumBorder, "홀수 radius", "프로필 편집 버튼 어색", "닉네임 눌러도 반응 없음", "닉네임 시트 버튼 순서"]
root_cause: "모서리 둥글기 값(카드 16, 버튼 12, 캡슐, 홀수 7·17)이 섞여 있고 프로필 편집 진입과 시트 버튼 위계가 일관되지 않았다"
status: resolved
resolution: "[[ISS-0409-radius-tokens-nickname-edit-cleanup-report]]"
related: ["[[DEC-0186-card-radius-equals-button-even-tokens]]"]
source: "https://github.com/Twin-Fang/passQL/issues/687"
---

# ISS-0409: 모서리, 닉네임 편집 정리 (앱)

GitHub #687 (원본: 이슈 본문과 댓글).

## 증상
- 공통 토스트(스낵바)가 완전히 둥근 캡슐이라 버튼·입력창과 어울리지 않는다.
- 내 프로필 카드의 '편집' 글자 버튼이 어색하고 닉네임을 눌러도 반응이 없다.
- 닉네임 변경 시트에서 주 버튼 '저장'이 '랜덤 닉네임으로 바꾸기'보다 위에 있다.
- 둥글기에 홀수 값(설정 아이콘 타일 7, 홈 오늘의 세트 카드 버튼 캡슐 17)이 섞여 짝수 토큰(8, 12, 16) 체계와 맞지 않는다.

## 재현 조건
앱 내 프로필 탭, 닉네임 변경 시트, 홈 오늘의 세트 카드, 토스트 표시.

## 조사 기록
- 이슈 본문: 코드 수정 전에 변경 전후 비교안을 먼저 확인받는다.
- 2026-10-27: 리포트로 완료.

## 근본 원인
둥글기 토큰 체계가 정리되지 않았다. 원인 분석은 원본에 따로 적혀 있지 않다.
