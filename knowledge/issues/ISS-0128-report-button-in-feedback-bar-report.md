---
type: completion-report
id: ISS-0128
created: 2026-04-13
topics: [question-bank, practice]
status: resolved
resolves: "[[ISS-0128-report-button-in-feedback-bar]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/234"
---

# ISS-0128 완료 리포트: 피드백 바에 `Flag` 신고 버튼 추가

GitHub #234 `## 개요` 리포트 댓글(2026-04-13)과 작업 완료 보고(2026-04-22) 기준.

## 해결 방법
- `client/src/components/PracticeFeedbackBar.tsx`: `onReport`, `isReported` props, 헤더 우측 `Flag` 버튼. `onReport` 미전달(=`submissionUuid` 없음)이면 미표시, 이미 신고 시 `opacity-40 cursor-not-allowed disabled`, `guard()`로 이중 클릭 방지.
- `client/src/pages/PracticeSet.tsx`: 신고 상태(`feedbackChoiceSetUuid`, `reportModalOpen`, `reportedSubmissions`, `showReportToast`, `toastTimerIdRef`). `SubmitResult`에 `choiceSetUuid`가 없어 제출 시점 `choiceSetId`를 별도 보관. `ReportModal` 렌더를 IIFE로 감싸 non-null assertion 제거. 토스트 타이머 언마운트 클린업.
- `client/src/pages/PracticeResult.tsx`: 신고 완료 토스트 문구를 `"신고를 접수했어요."`로 통일.

## 근본 원인 (확정)
신고 진입점이 결과 화면에만 있었다.

## 재발 방지
리포트 주의사항: `isReported`는 `Boolean` 래퍼(프로젝트 CLAUDE.md 규칙), JSX 조건에서 `Boolean(isReported)`로 사용. QA 댓글의 지적(재신고 안내, 관리자 신고 상세의 선택지 표시, 모달 재오픈 불가, 관리자 인증)이 이 이슈에서 처리됐는지는 원본에 적혀 있지 않다.

## 교훈
논의 기록 없음.
