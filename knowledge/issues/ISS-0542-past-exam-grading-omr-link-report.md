---
type: completion-report
id: ISS-0542
created: 2026-11-18
topics: [practice, question-bank, admin]
status: resolved
resolves: "[[ISS-0542-past-exam-grading-omr-link]]"
related: ["[[DEC-0344-past-exam-grading-reuses-answer-key-round]]", "[[DEC-0328-past-exam-rewrite-operation-rules]]", "[[DEC-0327-answer-key-highlight-exam-date-plus-7]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1151"
---

# ISS-0542 완료 리포트: 지난 회차 기출 OMR 가채점과 회차 풀이 연결 (#1151)

보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1151#issuecomment-6937030195 · 배포 실측 댓글: https://github.com/Twin-Fang/passQL/issues/1151#issuecomment-6966309718 · PR #1152 · 릴리스 PR #1154 (2026-11-18)

## 해결 방법
- **서버·앱:** 기출 회차 응답 `hasExamAnswerKey`, 앱 기출 복원 탭 [지난 회차 가채점] 행 > 회차 시트 > 가답안·OMR 화면 재사용(득표 숨김, "복원 자료 기준 정답", [이 회차 기출 풀기] 연결). 구조는 [[DEC-0344-past-exam-grading-reuses-answer-key-round]].
- **사용자 결정(2026-11-17):** 정답 범위는 58~62회만(45~57회는 정답 번호 확보 불가라 가채점 없이 기출 풀기만), 지난 회차 가채점은 모두 무료(기출 풀이·해설은 최근 1회차만 무료). DEC-0344 에 보완으로 반영, 새 결정 노트 없음.
- **운영 입력:** 58~62회 5개 회차·회차당 50문항(CONFIRMED, 회차 OFFICIAL), 입력 전 백업, 되돌리기는 apply 스크립트 `--rollback`(회차 CLOSED). 공개 API 에서 각 50문항·정답 50개 확인, 45회는 404.
- **배포:** 릴리스 #1154 로 서버·AI·웹·Android·iOS 성공. 지난 회차(58~62) 가답안 운영 안내 notice 는 63회와 같은 기준으로 비움(운영 데이터, 배포 불필요). 실측용 62회 답안지 1건은 관리자 삭제로 제거.

## 근본 원인 (확정)
기능 부재 — 63회에만 가답안·가채점이 열려 있었고 지난 회차는 회차 행·정답 데이터·앱 진입이 없었다.

## 재발 방지
- 검증: `flutter analyze`·`flutter test`·`./gradlew build` 통과, 시뮬레이터에서 지난 회차 가채점 행 > 회차 시트 > 62회 가답안 > OMR 채점 > 기출 풀기 연결 통과(라이트·다크).
- 입력·롤백 도구 `tools/past-exam-answer-key/`(점검 기본, `--execute`·`--backup-dir` 필요).

## 남은 확인점
- [이 회차 기출 풀기] 이동 대상 회차는 62회가 목록 맨 위라 시각 구분이 안 됨(다른 회차에서 확인 필요).
- 틀린 문항 개념 복습 수에 "모름" 처리 문항이 포함됨(28문항 입력 시 44). 의도 확인 필요.
