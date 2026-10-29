---
type: completion-report
id: ISS-0096
created: 2026-04-12
topics: [design-system]
status: resolved
resolves: "[[ISS-0096-choicecard-confirmmodal-daisyui-buttons]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/175"
---

# ISS-0096 완료 리포트: ChoiceCard·ConfirmModal 버튼 daisyUI 교체와 인라인 style 제거

GitHub #175 작업 리포트 댓글 기준 (2026-04-12).

## 해결 방법
- `client/src/components/ChoiceCard.tsx`: `btn-compact` / `btn-compact-inverted` → `btn btn-xs btn-outline`. 미선택은 `text-primary border-primary`, 선택(파란 배경)은 `bg-white text-primary border-white`.
- `client/src/components/ConfirmModal.tsx`: 오버레이 인라인 `style={{ backgroundColor: "rgba(17, 24, 39, 0.5)" }}` → `bg-base-content/50`. 버튼 `btn-primary w-full` → `btn btn-primary w-full`, `btn-secondary w-full` → `btn btn-secondary w-full`.
- `components.css`의 `.btn-primary`, `.btn-secondary`, `.btn-compact`는 `DailyChallenge.tsx`, `QuestionDetail.tsx`, `AnswerFeedback.tsx`, `SqlPlayground.tsx` 등에서 아직 써서 삭제하지 않음.
- 현재 구현과 맞지 않아 전부 실패하던 `src/` 하위 `.test.ts(x)` 12개를 재작성 전제로 전체 삭제.

## 근본 원인 (확정)
커스텀 버튼 클래스가 남아 있었다. 교체 중 `btn-primary` 클래스명을 그대로 쓰면 `components.css`의 `.btn-primary { height: 44px }`와 충돌해 버튼이 커졌다 → `text-primary border-primary` 유틸리티로 우회.

## 재발 방지
리포트 참고사항: 커스텀 버튼 클래스와 daisyUI 클래스가 같은 이름을 공유하면 높이/패딩이 충돌할 수 있다. 이후 마이그레이션은 유틸리티로 우회하거나 CSS 삭제와 병행 권장. `bg-neutral/50`(`#1F2937`) ≠ `bg-base-content/50`(`#111827`).

## 교훈
(원본에 없음, 볼트 정리) daisyUI 전환 후 버튼 크기가 이상하면 같은 이름의 커스텀 CSS 클래스(`components.css`)가 남아 있는지부터 본다.
