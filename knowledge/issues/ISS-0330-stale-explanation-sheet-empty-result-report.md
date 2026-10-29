---
type: completion-report
id: ISS-0330
created: 2026-10-18
topics: [practice, ai]
status: resolved
resolves: "[[ISS-0330-stale-explanation-sheet-empty-result]]"
related: ["[[DEC-0154-close-explanation-sheet-on-next]]", "[[DEC-0155-exam-tip-after-answer-reason]]"]
source: "https://github.com/Twin-Fang/passQL/issues/538"
---

# ISS-0330 완료 리포트: "다음"에서 해설 시트 닫기, 빈 결과를 표 틀 안에 "결과 없음 · 0행", 시험 팁을 정답 근거 아래로

GitHub #538 보고 댓글(2026-10-18)과 확인 리포트(2026-10-26) 기준.

## 해결 방법
- PR #539: "다음"에서 시트를 닫는다(`closePanel` → `nextQuestion`). 해설함과 백그라운드 재조회는 유지, 상단 해설함 아이콘으로 다시 열 수 있다. 마지막 문제는 결과 화면으로 가서 영향 없음.
- PR #539: 빈 결과 보기를 다른 결과 표와 같은 틀 안에 "결과 없음 · 0행"으로 표시. 문제 데이터·정답 판정은 그대로.
- PR #541: 해설 섹션 순서를 판정 → 정답 근거 → 시험 팁 → 핵심 개념 → 헷갈리는 지점 → 보기별 판단으로, 앱·웹 같게. 서버 응답 필드 순서는 그대로.
- 테스트 최소 추가(빈 결과 렌더링 1, 시험 팁 순서 단언 1 — 구현을 되돌려 실패 확인). 배포 Vercel·AI·Spring 성공.
- 2026-10-26: 시트를 연 채 "다음" → 시트가 닫히고 2/5로 넘어감(가짜 API 빌드).

## 근본 원인 (확정)
이슈 노트 참조.

## 재발 방지
- 이 변경은 GitHub #521의 "다음 문제로 가도 시트 유지" 설계를 바꾼 것. 해설을 본 채로 다음 문제를 풀고 싶다는 요구가 다시 나오면 상단으로 접는 방식 등을 따로 설계해야 한다.
- 시험 팁 순서는 앱 `AiExplanationSections`와 웹 `ExplanationContent` 두 곳이 같아야 한다.

## 교훈
(원본에 없음, 볼트 정리) 0행 결과는 SQLD에서 정당한 답이므로 다른 결과와 같은 틀로 보여 준다.
