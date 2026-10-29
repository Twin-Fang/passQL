---
type: completion-report
id: ISS-0364
created: 2026-10-24
topics: [practice]
status: resolved
resolves: "[[ISS-0364-result-table-choice-executed-as-sql]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/607"
---

# ISS-0364 완료 리포트: `kind=SQL` 보기만 실행, 배지는 `실행 결과 문제`

GitHub #607 리포트 댓글(`## 개요`, 2026-10-24) 기준.

## 해결 방법
- `SubmissionService`: 선택 보기와 정답 보기가 `kind=SQL`일 때만 실행하고 `selectedSql`/`correctSql`도 그때만 채움(`sqlBodyOrNull`).
- `question_sections.dart`: 배지 문구 `SQL 실행` > `실행 결과 문제`, 재생 아이콘 > 표 아이콘.

## 근본 원인 (확정)
제출 채점 경로가 보기 `kind`를 확인하지 않았다(다른 경로는 이미 구분).

## 재발 방지
- 서버 deploy 병합 배포, 새 컨테이너 healthy. 운영에서 해당 문제를 실제로 제출해 보는 확인은 못 했다.
- 범위 밖: 결과표 보기의 "정답/내 답" 카드는 JSON 코드 대신 정답 라벨만 보인다(결과표 표시는 미개선).
- 앱 배지 변경은 다음 앱 배포부터(iOS 1.44.0은 변경 전 빌드로 심사 대기).

## 교훈
(원본에 없음, 볼트 정리) 보기 종류(`kind`)로 분기해야 하는 처리는 생성·검증·해설·채점 경로를 모두 함께 확인한다 — 한 경로만 빠져도 같은 데이터가 다른 결과를 낸다.
