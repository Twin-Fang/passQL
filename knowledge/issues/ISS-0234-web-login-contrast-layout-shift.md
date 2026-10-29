---
type: issue
id: ISS-0234
created: 2026-10-07
topics: [design-system, auth-member]
symptoms: ["WCAG AA 미달", "대비 2.45:1", "#9CA3AF", "#EF4444", "레이아웃 밀림", "APPLE 로그인은 준비 중입니다", "enum 노출", "탭 영역 44"]
root_cause: "로그인 화면 약관 링크·오류 문구 색과 크기가 AA 대비 미달이고, 오류 문구 자리가 확보돼 있지 않았으며, 제공자 enum 값을 그대로 출력했다"
status: resolved
resolution: "[[ISS-0234-web-login-contrast-layout-shift-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/401"
---

# ISS-0234: 로그인 화면 약관 링크·오류 문구 대비 부족과 오류 표시 시 레이아웃 밀림 (웹)

GitHub #401 (원본: 이슈 본문과 완료 댓글).

## 증상
- 약관 링크 `#9CA3AF` / 12px, 대비 약 2.45:1(WCAG AA 4.5:1 미달), 탭 영역 41×16·83×16(권장 44 이상).
- 오류 문구 `#EF4444` / 14px, 흰 배경 대비 약 3.8:1(AA 미달).
- 오류 문구가 나타나면 중앙 정렬 때문에 로그인 카드 전체가 약 18px 위로 밀림.
- 미지원 로그인을 누르면 "APPLE 로그인은 준비 중입니다."처럼 내부 enum 값(APPLE·KAKAO)이 대문자 그대로 노출.

## 재현 조건
웹 로그인 화면에서 미지원 로그인 버튼(예: Apple) 클릭.

## 조사 기록
- 2026-10-07: 대상 `client/src/pages/Login.tsx` 스타일·문구.

## 근본 원인
색·크기·레이아웃·문구 표기 문제. 그 밖의 원인 설명은 원본에 적혀 있지 않다.
