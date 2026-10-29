---
type: issue
id: ISS-0105
created: 2026-04-12
topics: [practice, design-system]
symptoms: [AnswerFeedback, "단일 문제 결과 화면", "SQL 실행 비교", "선택지 과부하", EXECUTABLE, "문제 보기 토글"]
root_cause: "단일 문제 결과 화면이 모든 선택지를 펼치고 문제 지문 확인 수단이 없는 구조였다"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/189"
---

# ISS-0105: 단일 문제 결과 화면(AnswerFeedback) UI 전면 개선

GitHub #189 (원본: 이슈 본문과 목업·결과 이미지/영상 댓글. 텍스트 완료 리포트 없음).

## 증상
홈의 AI 추천문제·오늘의 문제에서 진입하는 `AnswerFeedback` 화면:
- EXECUTABLE 모드에서 A/B/C/D 선택지가 모두 펼쳐져 정보 과부하.
- 문제를 풀고 나면 어떤 문제였는지 확인할 수단이 없음.
- "SQL 실행 비교" 섹션이 너무 길어 해설 접근이 어려움. 실제 SQL을 실행한다는 점이 UI에 드러나지 않음.

## 재현 조건
해당 없음 (디자인 개선).

## 조사 기록
- 2026-04-12: 이슈 등록. 기대: 접이식 "문제 보기" 카드(`BookOpen`, 기본 접힘), 내 선택·정답 카드 기본 펼침·나머지 접힘(SQL 프리뷰 + 행수 pill), A/B/C/D 키 레이블 제거, "모두 실행" + 개별 "실행" 버튼. 요청: 인라인 style 금지, `FeedbackState`에 `stem`·`topicName` 추가, `QuestionDetail.tsx` navigate state 전달, dead code(`AiExplanationSheet`, `diffMutation`, `diffExplain`) 제거.
- 2026-04-12: 목업 이미지와 결과 영상·스크린샷 댓글. 변경 내용을 설명한 텍스트는 원본에 없다. GitHub #187 리포트가 main의 #189 커밋이 `rationale-card`, `ans-card-wrong/correct` 시맨틱 클래스를 도입했다고 적었다.

## 근본 원인
원본에 적혀 있지 않다 (디자인 개선 요청).
