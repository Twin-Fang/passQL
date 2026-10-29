---
type: completion-report
id: ISS-0165
created: 2026-04-26
topics: [auth-member, design-system]
status: resolved
resolves: "[[ISS-0165-settings-logout-button-ux]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/308"
---

# ISS-0165 완료 리포트: 로그아웃을 전용 `<button>` + `text-sem-error`로, 개발자 모드 Easter Egg 제거

GitHub #308 구현 완료 보고 댓글(2026-04-26) 기준. 커밋 `2e055d5`.

## 해결 방법
- 로그아웃 row: `<SettingsRow>` → `<button>` 직접 렌더링 + `text-sem-error`.
- 개발자 모드 Easter Egg 코드 전체 제거(state, ref, 핸들러, cleanup).
- 버전 row onClick 제거.

Easter Egg 제거 이유는 원본에 적혀 있지 않다. (원본에 없음, 볼트 정리) 버전 row 연속 클릭으로 개발자 기능을 여는 방식은 GitHub #208에서 들어왔다.

## 근본 원인 (확정)
위험 액션에 공용 `SettingsRow`를 쓴 구조.

## 재발 방지
원본에 적혀 있지 않다.

## 교훈
원본에 적혀 있지 않다.
