---
type: issue
id: ISS-0535
created: 2026-11-16
topics: [question-bank, practice, admin]
symptoms: ["기출 복원", "기출 회차", "PAST_EXAM", "round_type", "exam_date", "V1_133_3__mock_exam_round_type", "/admin/api/mock-exams/past-rounds", "isFreePastExamRound", "examRoundNumber", "5-gram 유사도", "Oracle 실행 검증", "round:{회차} 태그", "52회 20문항 중복 등록", "내보내기 500개", "서버 형식 규칙 가운뎃점 SELECT 40자 한글 주석", "45~51회", "학습 모드"]
root_cause: "수험생 공부의 중심인 회차별 기출 복원이 없고 모의고사는 자체 문제 자동 구성뿐이었다(기능 부재)"
status: open
resolution: null
related: ["[[ISS-0534-intro-site-past-exam-preview-study-guides]]", "[[DEC-0328-past-exam-rewrite-operation-rules]]", "[[DEC-0326-site-past-exam-five-question-preview]]", "[[DEC-0327-answer-key-highlight-exam-date-plus-7]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]", "[[DEC-0142-encrypt-sqld-research-materials]]", "[[LSN-0002-harness-lint-misses-server-format-rule]]", "[[LSN-0005-question-export-500-limit-split-before-dedupe]]", "[[LSN-0004-app-change-release-means-ios-review]]", "[[ISS-0536-mock-exam-study-mode-final-round]]"]
source: "_sources/issues/ISS-0535-past-exam-restored-rounds.md"
---

# ISS-0535: 기출 복원 회차 — 45~62회 900문항 변형 등록, 실전 모드와 학습 모드

GitHub #1079 (열림, 작업중 — 45~51회·학습 모드 남음). 원본: https://github.com/Twin-Fang/passQL/issues/1079 · 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1079#issuecomment-6903849347 · PR #1124, 릴리스 #1125

## 증상
passQL 에는 기출 회차가 없고 모의고사는 자체 문제로만 자동 구성된다(`MockExamRoundComposer`).

## 재현 조건
앱 모의고사. 응시자들이 함께 복원해 공개한 SQLD 45~62회(18회차, 900문항: 4지선다 840, 단답형 60)가 대상.

## 조사 기록
- 2026-11-14: 이슈 등록. 수집 범위 지문·보기·정답·회차·과목(외부 해설·그림 제외), 원문 정리본은 로컬 전용([[DEC-0142-encrypt-sqld-research-materials]]). 범위 추가 댓글: 그림 22문항은 그림 속 정보만 추출해 머메이드로, 해설은 passQL AI 로 새로.
- 2026-11-14: 설계 결정 항목 추가 — 기출 회차 무료 공개 범위. 무료 한도·이용권은 현행 유지(#1087 취소).
- 2026-11-16: 다시 쓰기 — 회차별 YAML 50문항, 문장 새로·테이블·값 변경·보기 섞기, 원문 5-gram 유사도 최대 0.34(기준 0.35 이하), Oracle 21c 실행 검증 550/550, 하네스 lint 0. 57회 7번은 복원 자료가 SQL 문항이라 1과목이 9개뿐 > 같은 범위 모델링 문항을 새로 씀. 그림 22문항은 엔터티를 바꿔 지문에 관계를 글로 적음(머메이드 필드는 앱 미반영). 원칙은 [[DEC-0328-past-exam-rewrite-operation-rules]].
- 2026-11-16: 운영 등록 — 1차 가져오기에서 서버 형식 규칙(가운뎃점, SELECT 40자, 한글 주석, 질문 2개, 키 표시 문구)에 걸려 수정 후 재등록([[LSN-0002-harness-lint-misses-server-format-rule]] 재발). 내보내기 API 500개 상한으로 집계가 잘려 52회 20문항이 중복 등록 > 중복분 비활성화([[LSN-0005-question-export-500-limit-split-before-dedupe]]).
- 2026-11-16: 서버·앱 — `V1_133_3__mock_exam_round_type.sql`(`round_type` MOCK|PAST_EXAM, `exam_date`, 회차 번호 유일 조건을 종류별로, 운영 out-of-order 적용), 관리자 `POST /admin/api/mock-exams/past-rounds`(50문항 시험 번호 순서, 1~10번 1과목 검증, 중복 409), 공개 API `roundType`·`examRoundNumber`·`examDate`·`isFreePastExamRound`, 가장 최근 기출 1개 무료(모의고사 체험과 별개). 앱 [모의고사 | 기출 복원] 세그먼트·연도별 묶음·무료 배지·면책 한 줄, 홈 가답안 카드 시험일 + 7일까지만([[DEC-0327-answer-key-highlight-exam-date-plus-7]]). 서버·앱 한 릴리스라 앱 배포 동반([[LSN-0004-app-change-release-means-ios-review]]).
- 2026-11-16: **52~62회 11회차(550문항) 공개** — 회차별 50/50, 공개 검사 전 회차 `canPublish: true`, 관리자 목록 PAST_EXAM 11개 PUBLISHED. 소개 사이트 회차마다 5문항 공개([[ISS-0534-intro-site-past-exam-preview-study-guides]]).
- 2026-11-16: 학습 모드는 #1084로 반영 — 기출 회차도 무료 기출 회차는 무료, 나머지는 PRO가 한 문제씩 학습([[ISS-0536-mock-exam-study-mode-final-round]], [[DEC-0329-mock-study-mode-reuses-question-flow-device-progress]]).

## 근본 원인
기능 부재. 남은 일: 45~51회(2024 개정 전 범위), 학습 모드(#1084), 단답형(#1085), 그림 문항 머메이드 렌더링. 해설은 정적으로 넣지 않고 앱 AI 해설이 담당.
