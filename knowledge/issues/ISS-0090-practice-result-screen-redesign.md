---
type: issue
id: ISS-0090
created: 2026-04-12
topics: [practice, design-system]
symptoms: [StepNavigator, PracticeResult, "1/3 텍스트 중복", "점 인디케이터", "평균 레이블 불명확", "AI 리뷰 브랜딩 부재", "문제 preview 없음", "Zustand 결과 누락"]
root_cause: "디자인 개선 — 결과 화면 헤더·인디케이터 중복, 스텝별 콘텐츠의 애니메이션·AI 브랜딩·복습 기능 부족"
status: resolved
resolution: "[[ISS-0090-practice-result-screen-redesign-report]]"
related: ["[[DEC-0061-no-inline-style-rule]]"]
source: "https://github.com/Twin-Fang/passQL/issues/161"
---

# ISS-0090: 문제 풀이 결과 화면 UI 전면 개선

GitHub #161 (원본: 이슈 본문과 리포트 댓글).

## 증상
- StepNavigator: 첫 스텝만 홈 아이콘, 이후 `<` 아이콘으로 불일치. 상단 `1/3`과 하단 점 인디케이터 중복. "다음 >"의 ChevronRight, "다른 카테고리 ⊞"가 맥락에 안 맞음.
- PracticeResult: 스텝 1 통계가 한꺼번에 표시, "평균"이 무엇의 평균인지 불명확. 스텝 2 AI 리뷰가 단순 텍스트. 스텝 3 문제 카드에 preview 없음.

## 재현 조건
해당 없음 (디자인 개선). 스펙 문서 `docs/superpowers/specs/2026-04-12-practice-result-ui-redesign.md`.

## 조사 기록
- 2026-04-12: 요청 조건 — 인라인 `style={{ }}` 금지, 아이콘은 `lucide-react`(이모지 금지), `client/.claude/rules/Design.md` 준수.

## 근본 원인
해당 없음 (디자인 개선).
