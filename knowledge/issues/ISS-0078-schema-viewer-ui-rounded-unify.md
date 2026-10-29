---
type: issue
id: ISS-0078
created: 2026-04-11
topics: [practice, design-system]
symptoms: [SchemaViewer, schemaIntent, "DDL 토글", "EMP 샘플", "rounded-xl 통일", "border-t 제거"]
root_cause: "디자인 개선 요청 — SchemaViewer가 설계자 메모·DDL 등 불필요한 정보를 노출하고 radius가 컴포넌트마다 달랐다"
status: resolved
resolution: null
related: ["[[ISS-0075-fixed-bottom-action-buttons]]", "[[ISS-0080-stem-markdown-schema-toggle]]"]
source: "https://github.com/Twin-Fang/passQL/issues/135"
---

# ISS-0078: SchemaViewer UI 개선 및 전체 rounded 통일

GitHub #135 (원본: 이슈 본문과 스크린샷 댓글).

## 증상
- `SchemaViewer`가 `schemaIntent`(DB 설계자용 메모)와 DDL 접기/펼치기, "EMP 샘플" 같은 어색한 레이블을 노출.
- 요청: 스키마 구조 카드와 샘플 데이터 카드 분리(8px 간격), PK/FK를 `ID(PK)`, `DEPT_ID(FK)` 인라인 텍스트로, `rounded-lg` / `rounded-2xl` / `rounded-md` → `rounded-xl` 통일, fixed bottom 버튼 영역의 `border-t border-border` 제거.
- 제외: `HeatmapCalendar`의 `rounded-sm`·`rounded-full`, `ConfirmModal`·`AiExplanationSheet`의 `rounded-t-xl`.

## 재현 조건
해당 없음 (디자인 개선 요청).

## 조사 기록
- 2026-04-11: 스크린샷 댓글 1건만 있다. 완료 내용을 적은 댓글은 없다.

## 근본 원인
해당 없음 (디자인 개선).
