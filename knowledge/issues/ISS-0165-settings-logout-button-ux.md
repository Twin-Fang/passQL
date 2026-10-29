---
type: issue
id: ISS-0165
created: 2026-04-26
topics: [auth-member, design-system]
symptoms: ["로그아웃 버튼", SettingsRow, "위험 액션", text-sem-error, "Settings.tsx", "Easter Egg"]
root_cause: "로그아웃이 일반 `SettingsRow`(value + action 조합)로 렌더링되어 위험 액션 구분이 없고 텍스트·아이콘 배치가 어색함"
status: resolved
resolution: "[[ISS-0165-settings-logout-button-ux-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/308"
---

# ISS-0165: 설정 페이지 로그아웃 버튼 UX 개선

GitHub #308 (원본: 이슈 본문과 구현 완료 보고 댓글). 기능 개선 이슈.

## 증상
로그아웃 row 우측에 value("현재 계정에서 로그아웃")와 LogOut 아이콘이 나란히 붙어 어색하다. 위험 액션인데 건의사항·버전 같은 일반 row와 같은 스타일이다. `SettingsRow`의 value + action 구조가 위험 액션 표현에 맞지 않는다.

## 재현 조건
해당 없음 (설정 화면 표시 상태).

## 조사 기록
- 2026-04-26 제안: `SettingsRow` 대신 직접 `<button>`, 라벨 `text-sem-error`, 부가 설명 제거("iOS, 토스 등 표준 설정 UI 패턴과 일치"), 아이콘·로딩 스피너(`border-sem-error`) 색 통일. 대상 `client/src/pages/Settings.tsx`.

## 근본 원인
공용 row 컴포넌트를 위험 액션에도 그대로 쓴 구조.
