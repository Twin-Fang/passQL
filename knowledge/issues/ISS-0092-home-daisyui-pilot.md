---
type: issue
id: ISS-0092
created: 2026-04-12
topics: [design-system, home]
symptoms: [daisyUI, "card-base", "수동 커스텀 클래스", skeleton, "badge-warning", "base-100", useStagger, "style prop"]
root_cause: "기능 개선 — daisyUI 5와 passql 테마가 있는데 컴포넌트가 daisyUI 클래스를 전혀 쓰지 않아 수동 클래스 유지보수 부담"
status: resolved
resolution: "[[ISS-0092-home-daisyui-pilot-report]]"
related: ["[[DEC-0063-daisyui-incremental-adoption]]", "[[ISS-0091-stagger-fadein-tab-sections]]"]
source: "https://github.com/Twin-Fang/passQL/issues/167"
---

# ISS-0092: Home.tsx daisyUI 컴포넌트 클래스 적용 (파일럿)

GitHub #167 (원본: 이슈 본문과 작업 댓글).

## 증상
daisyUI 5와 passql 커스텀 테마가 정의돼 있지만 실제 컴포넌트는 daisyUI 클래스를 쓰지 않는다. 카드·버튼·뱃지·스켈레톤이 모두 수동 커스텀 클래스라 유지보수 부담이 있다.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-12: 이슈 본문 — Home.tsx를 파일럿으로 1:1 대체 가능한 클래스만 교체(`card-base` → `card card-body`, 재시도 버튼 → `btn btn-xs btn-outline btn-primary`, 수동 pulse → `skeleton`, 연속 학습 뱃지 → `badge badge-warning`), passQL 전용 클래스는 유지.

## 근본 원인
해당 없음 (기능 개선).
