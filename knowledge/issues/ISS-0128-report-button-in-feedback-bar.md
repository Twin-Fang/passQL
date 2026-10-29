---
type: issue
id: ISS-0128
created: 2026-04-13
topics: [question-bank, practice]
symptoms: [PracticeFeedbackBar, "문제 신고 버튼 없음", ReportModal, "신고 진입점", "POST /api/questions/{questionUuid}/report", REPORT_ALREADY_EXISTS]
root_cause: "문제 신고 진입점이 세션 종료 후 `PracticeResult`에만 있어 제출 직후 바텀시트에서 신고할 수 없음"
status: resolved
resolution: "[[ISS-0128-report-button-in-feedback-bar-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/234"
---

# ISS-0128: 제출 직후 피드백 바에서 문제를 신고할 수 없음

GitHub #234 (원본: 이슈 본문과 댓글).

## 증상
문제 신고 API(`POST /api/questions/{questionUuid}/report`)와 관리자 화면은 구현돼 있지만 신고 진입점이 결과 화면(`PracticeResult`)에만 있다. 제출 직후 정답/오답 바텀시트(`PracticeFeedbackBar`)에는 신고 버튼이 없다.

## 재현 조건
문제 풀이 → 제출 → 피드백 바에서 신고 시도.

## 조사 기록
- 2026-04-13: 제안 — 헤더 우측 `lucide-react` `Flag` 아이콘, 기존 `ReportModal` 재사용, `submissionUuid` 기준 중복 신고 시 비활성(`opacity-40`, `cursor-not-allowed`). API: 카테고리 `WRONG_ANSWER | WEIRD_QUESTION | WEIRD_CHOICES | WEIRD_EXECUTION | ETC`, 201, 400, 409(`REPORT_ALREADY_EXISTS`).
- 2026-04-13 QA 댓글: 이미 신고된 문제에 안내 필요 / 관리자 신고 상세에서 어떤 선택지를 신고했는지 알 수 없음(문제 상세로만 이동) / 모달을 열고 닫은 뒤 버튼을 다시 눌러도 모달이 안 뜸(lock 여부 확인 필요) / 신고 문구를 친근한 말투로 순화 / 관리자 화면 "관리자 UUID를 찾을수없습니다"(인증 없음) / 디자인 문제는 별도 이슈로 분리.

## 근본 원인
신고 진입점이 결과 화면에만 구현돼 있었다.
