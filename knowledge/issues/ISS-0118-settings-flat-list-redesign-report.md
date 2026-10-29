---
type: completion-report
id: ISS-0118
created: 2026-04-13
topics: [design-system]
status: resolved
resolves: "[[ISS-0118-settings-flat-list-redesign]]"
related: ["[[DEC-0071-settings-flat-grouped-list]]"]
source: "https://github.com/Twin-Fang/passQL/issues/211"
---

# ISS-0118 완료 리포트: grouped flat 리스트, 가로형 SettingsRow, 피드백 toast

GitHub #211 작업 리포트 댓글 기준 (2026-04-13).

## 해결 방법
- `SettingsRow.tsx`: `isLast` 제거(구분선은 부모 `divide-y`), 세로형 → 가로형(label 왼쪽 `flex-1`, value+action 오른쪽), `px-5 py-4` → `px-4 py-3.5`.
- `SettingsSection.tsx`: 인디고 pill count 장식 제거, 라벨 `text-xs` → `text-sm`, `mb-1` → `mb-2`.
- `Settings.tsx`, `DevPage.tsx`: 카드 래퍼 → `bg-surface-card border-y border-border divide-y divide-border`, section 인라인 `mt-6` 제거, footer `mt-8` → `mt-12`.
- 피드백 UX: 닉네임 재설정 성공 toast "닉네임이 변경됐어요", 복사 `<Check>`에 `text-sem-success` 직접 지정, toast 배경 `bg-toast-bg` → `bg-brand`.
- 설계: [[DEC-0071-settings-flat-grouped-list]].

## 근본 원인 (확정)
카드 컨테이너 중심 레이아웃.

## 재발 방지
리포트 참고사항: `SettingsSection`의 `count` prop은 인터페이스에 남기되 렌더링하지 않음(하위 호환). `divide-y`는 직계 자식 사이에만 border를 만들어 조건부 렌더링(`devUnlocked && ...`)과 함께 써도 마지막 row 문제 없음. 검증: toast, 복사 체크, Easter Egg, DevPage 레이아웃.

## 교훈
논의 기록 없음.
