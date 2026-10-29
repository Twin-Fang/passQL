---
type: issue
id: ISS-0069
created: 2026-04-11
topics: [practice, design-system]
symptoms: ["카테고리 카드 hover", "토픽 아이콘", "중복 문구", "Questions.tsx", "QuestionDetail.tsx", lucide-react]
root_cause: "기능 개선 요청 — 카드 hover 피드백이 배경색 변경뿐이고 토픽 아이콘·중복 문구 정리가 없었다"
status: resolved
resolution: "[[ISS-0069-questions-detail-page-ui-polish-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/120"
---

# ISS-0069: Questions / QuestionDetail 페이지 UI 개선

GitHub #120 (원본: 이슈 본문과 작업 댓글).

## 증상
- `Questions.tsx`: 카테고리 9개에 토픽 아이콘이 없고, 카드 hover 피드백이 배경색 변경뿐. 토픽 선택 안내 등 중복 문구.
- `QuestionDetail.tsx`: 지문 토글·선택지 카드 선택/hover 피드백이 약하다.
- 요청 조건: 아이콘은 `lucide-react`(이모지 금지), 인터랙션은 transition 기반.

## 재현 조건
해당 없음 (디자인 개선 요청).

## 조사 기록
- 2026-04-12: 작업 댓글로 완료 보고.

## 근본 원인
해당 없음 (기능 개선).
