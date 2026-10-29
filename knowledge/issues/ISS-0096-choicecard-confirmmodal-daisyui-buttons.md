---
type: issue
id: ISS-0096
created: 2026-04-12
topics: [design-system]
symptoms: [btn-compact, btn-primary, btn-secondary, ChoiceCard, ConfirmModal, "커스텀 버튼 클래스", daisyUI]
root_cause: "ChoiceCard·ConfirmModal이 커스텀 CSS 버튼 클래스를 써서 Home.tsx의 daisyUI 전환과 일관성이 없었다"
status: resolved
resolution: "[[ISS-0096-choicecard-confirmmodal-daisyui-buttons-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/175"
---

# ISS-0096: ChoiceCard · ConfirmModal 버튼을 daisyUI 클래스로 전환

GitHub #175 (원본: 이슈 본문과 작업 리포트 댓글).

## 증상
`ChoiceCard`는 `btn-compact`, `ConfirmModal`은 `btn-primary`·`btn-secondary` 커스텀 클래스를 쓴다. Home.tsx(GitHub #167)에서 같은 버튼을 daisyUI로 바꾼 것과 일관성이 없다.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-12: 이슈 등록. 제안: `btn-compact` → `btn btn-xs btn-outline btn-primary`, `btn-primary` → `btn btn-primary`, `btn-secondary` → `btn btn-secondary`, 구조 변경 없이 클래스 교체만.

## 근본 원인
커스텀 CSS 버튼 클래스가 daisyUI 전환 이후에도 남아 있었다.
