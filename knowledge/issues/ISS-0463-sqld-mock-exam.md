---
type: issue
id: ISS-0463
created: 2026-11-07
topics: [practice, billing, admin]
symptoms: ["모의고사 없음", "프로 핵심 기능 없음", "50문항 90분", "과목별 과락", MockExamService, MOCK_EXAM, /admin/mock-exams]
root_cause: "프로 요금제에 결제 이유가 한 문장으로 설명되는 핵심 기능(실제 시험 형식 모의고사)이 없었다 (이전 기획 #500 은 명세 변경으로 취소)"
status: open
resolution: null
related: ["[[DEC-0264-mock-exam-fixed-rounds-server-judged]]", "[[DEC-0261-real-mode-renamed-new-choices]]", "[[DEC-0089-shared-question-flow-for-solving]]", "[[DEC-0138-solving-detail-hides-answers]]", "[[ISS-0458-server-side-free-limit-pro-gating]]"]
source: "_sources/issues/ISS-0463-sqld-mock-exam.md"
---

# ISS-0463: SQLD 모의고사 (50문항 90분, 과목별 과락, 프로 핵심 기능)

GitHub #866 (https://github.com/Twin-Fang/passQL/issues/866). 이전 기획 #500 은 2026-10-26 명세 변경으로 취소됐고, 이 이슈가 지금 명세(무료/프로 #576, 서버 판정 #860)에 맞춘 재추진이다.

## 증상
- 프로 요금제에서 결제 이유가 한 문장으로 설명되는 핵심 기능이 없음. 자격증 앱에서 결제 동기가 가장 큰 기능은 실제 시험처럼 풀고 합격 여부를 판정받는 모의고사.

## 재현 조건
해당 없음 (기능 부재).

## 조사 기록
- 2026-11-07: 이슈 본문 제안 — 실제 SQLD 형식(구현 전 공식 기준 재확인), 남은 시간·번호판·표시·한 번에 제출·자동 제출·이어 풀기(#500 설계 계승), 결과(합격·과락·문항별 해설·점수 추이), 검증된 재사용 보기 세트에서만 출제(50문제 실시간 AI 생성 금지: 느리고 비쌈·오류 위험), 시간·회차 수·채점 모두 서버 판정, 무료 1회 체험·프로 무제한, 문제 수 사용자 비노출(#636). 목표: 제63회(2026-11-14) 이후 다음 회차.
- 2026-11-07: PR #889 머지 (main 반영). 공식 기준(dataq.or.kr) 확인: 50문항 90분, 1과목 10·2과목 40, 60점 이상 합격, 과목별 40% 미만 과락. 설계는 [[DEC-0264-mock-exam-fixed-rounds-server-judged]].
  - 서버: 회차·문항·응시·답 엔티티, Flyway `V1_78_1_1__mock_exam.sql`, `ProFeature.MOCK_EXAM`, `MockExamNextStepPlanner`(다음에 할 일: 과락 > 총점 미달 > 합격선 근처 > 안정권, #861 바로 풀기 버튼 재사용). 답한 문항은 제출 기록(session_uuid = 응시)으로 남겨 오답 노트·통계에 반영, 하루 무료 한도·예전에 푼 문제 판정에서는 제외.
  - 앱·웹: 회차 목록, 시험 안내, 풀이(남은 시간·번호판·표시·자동 저장·이어 풀기), 결과(합격·과락·토픽·문항 해설·다음에 할 일·점수 추이). 앱 모의고사는 전용 화면(`pages/mock_exam`).
  - 관리자: `/admin/mock-exams` 목록·자동 구성·검수·교체·공개·문항 통계·응시 기록.
  - 검증(PR 기준): 서버 테스트 114개, 앱 111개, 웹 lint·테스트 13개·tsc 통과. 로컬 서버로 자동 구성 > 공개 > 무료 응시 > 과락 판정, 재응시 403, 동시 시작 409, 마감 뒤 저장 409 확인.
- 2026-11-07 기준 GitHub 이슈는 열림(`작업중`), 완료 리포트 댓글 없음 — 운영 배포·리포트 후 완료 리포트 노트로 닫는다.

## 근본 원인
기능 부재 (요금제 상품 구성의 빈칸).
