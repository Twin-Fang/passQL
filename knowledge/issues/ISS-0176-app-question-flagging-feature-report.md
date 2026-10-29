---
type: completion-report
id: ISS-0176
created: 2026-10-07
topics: [question-bank, practice]
status: resolved
resolves: "[[ISS-0176-app-question-flagging-feature]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/331"
---

# ISS-0176 완료 리포트: 제출 결과·챕터 피드백 바에 문제 신고 버튼과 신고 시트

GitHub #331 구현 댓글(2026-10-02)과 2026-10-07 확인 댓글 기준.

## 해결 방법
- 제출 결과 화면과 챕터 피드백 바에 "문제 신고" 버튼(제출 UUID가 있을 때만).
- 신고 시트: 사유 5종(정답 오류, 문제 내용, 선택지, SQL 실행 결과, 기타) 중복 선택, 기타는 상세 내용 필수(500자 이내).
- 이미 신고한 제출은 "신고 완료"로 비활성화, 중복 신고(409)는 성공으로 처리. 전송 실패 시 사유 표시·시트 유지.
- 제출 응답 `submissionUuid`를 모델에 반영, 신고 시 선택지 세트(`choiceSetUuid`)를 앱이 제출 시점에 붙여 전달.
- 검증: 2026-10-02 테스트 82개(16개 추가), `POST /questions/{id}/report`, `GET .../report/status?submissionUuid` 계약 테스트. 2026-10-07 테스트 147개, 실계정 E2E·TestFlight/Play 비공개 테스트 확인(파일 `report_button`/`report_sheet`).

## 근본 원인 (확정)
해당 없음 (기능 추가).

## 재발 방지
연습 모드(PracticePage)는 당시 자리 표시 화면이라 신고 연동 대상이 아니었고, 구현되면 같은 버튼을 붙이면 된다(원본).

## 교훈
원본에 적혀 있지 않다.
