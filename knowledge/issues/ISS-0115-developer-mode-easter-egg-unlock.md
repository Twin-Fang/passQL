---
type: issue
id: ISS-0115
created: 2026-04-13
topics: [dev-workflow]
symptoms: ["개발자 섹션 노출", "localStorage 초기화", Easter Egg, devUnlocked, DevGuard, "/dev", sessionStorage]
root_cause: "설정 화면 개발자 섹션(localStorage 초기화)이 모든 사용자에게 항상 노출되어 있었다"
status: resolved
resolution: "[[ISS-0115-developer-mode-easter-egg-unlock-report]]"
related: ["[[DEC-0068-dev-mode-hidden-easter-egg]]"]
source: "https://github.com/Twin-Fang/passQL/issues/208"
---

# ISS-0115: 개발자 모드 Easter Egg 잠금 해제

GitHub #208 (원본: 이슈 본문과 작업 리포트 댓글).

## 증상
`client/src/pages/Settings.tsx`의 개발자 섹션(localStorage 초기화 버튼)이 모든 사용자에게 노출되어 혼란·오작동 위험(이슈 본문).

## 재현 조건
설정 화면 진입 → 개발자 섹션 보임.

## 조사 기록
- 2026-04-13: 이슈 등록. 제안: 앱 정보 5번 연속 클릭으로 잠금 해제, 3·4번째 toast 안내, "세션 한정 (새로고침 시 다시 숨겨짐)", 초기화 1차 클릭 시 경고.
- 2026-04-13: 구현 중 버그 4건(DevPage 콘텐츠 미표시, Toast 세로 깨짐, DevGuard 초기화 오류, 페이지 재진입 시 row 숨김) 수정(리포트).

## 근본 원인
개발자 전용 기능에 노출 조건이 없었다.
