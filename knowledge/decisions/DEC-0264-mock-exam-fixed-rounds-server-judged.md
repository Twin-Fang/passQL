---
type: decision
id: DEC-0264
created: 2026-11-07
reviewed: null
topics: [practice, billing, admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0463-sqld-mock-exam]]", "[[DEC-0261-real-mode-renamed-new-choices]]", "[[DEC-0004-free-pro-feature-boundary]]", "[[DEC-0174-never-show-total-question-count]]", "[[DEC-0138-solving-detail-hides-answers]]"]
---

# DEC-0264: SQLD 모의고사는 관리자가 만드는 고정 회차(검증된 보기 세트)로 출제하고, 시간·채점·응시 수는 서버가 판정하며, 무료는 1회 체험·프로는 무제한이다

## 문제 정의 (Context)
프로 요금제의 핵심 결제 동기 기능으로 실제 시험 형식 모의고사를 만든다 (GitHub #866, [[ISS-0463-sqld-mock-exam]]).

## 결정 (Decision)
- **형식:** 공식 기준(dataq.or.kr) — 50문항 90분, 1과목 10·2과목 40, 문항당 2점, 60점 이상 합격, 과목별 40% 미만 과락(1과목 8점·2과목 32점 미만). 안 푼 문항은 오답.
- **출제:** 관리자가 만드는 고정 회차(문제 + 고정 보기 세트). 50문제 실시간 AI 생성은 하지 않는다. 자동 구성은 출제 경향 토픽 비율을 따르고 최근 3회차와 겹치지 않게, 난이도를 섞어 고른다. 공개 전 검사를 거치고, 공개한 뒤에는 문항을 바꿀 수 없다.
- **서버 판정:** 타이머(시작·마감 서버 KST, 마감 뒤 15초 유예 후 답 거부), 자동 채점(마감 뒤 조회 시와 10분 주기 스케줄러), 회원당 풀이 중 응시 1개(부분 유일 인덱스), 무료 체험 1회.
- **등급 (`ProFeature.MOCK_EXAM`):** 무료는 체험 회차(공개 회차 중 가장 작은 번호) 1회로 총점·합격 여부·정오까지. 프로는 모든 회차·재응시·과목별 분석·문항 해설·다음에 할 일·점수 추이. 잠긴 부분은 `ProResponseRedactor` 가 응답에서 제거.
- **이름:** "실전"은 모의고사에 쓴다 ([[DEC-0261-real-mode-renamed-new-choices]]).
- **기록 연결:** 답한 문항은 제출 기록(session_uuid = 응시)으로 남겨 오답 노트·통계에 반영하고, 하루 무료 한도·예전에 푼 문제 판정에서는 제외한다.
- 사용자에게 문제 수는 노출하지 않는다 (#636, [[DEC-0174-never-show-total-question-count]]).

## 검토한 대안 (Alternatives)
- 50문제 실시간 AI 생성: 느리고 비싸며 오류 위험이 있어 금지 (이슈 본문).
- 이전 기획 #500: 2026-10-26 명세 변경으로 취소, 풀이 UX(남은 시간·번호판·이어 풀기)만 계승.
- 그 밖의 대안: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 시간·채점·응시 수를 클라이언트가 우회할 수 없다. 출제 품질은 관리자 검수·공개 검사로 보장.

**부정**
- 회차는 관리자가 만들어 공개해야 생긴다 (운영 작업 필요, 구조상 결과 — 원본에 별도 논의 기록 없음).

## 영향 범위 (Scope)
서버 `application/mockexam/*`, `submission` 모의고사 엔티티·저장소·DTO, `ProFeature`·`FeatureAccessPolicy`·`ProResponseRedactor`, `ErrorCode`, Flyway `V1_78_1_1__mock_exam.sql`, 관리자 `/admin/mock-exams`, 앱 `pages/mock_exam`, 웹 모의고사 화면, `api-contract/openapi.json`.

## 출처 (References)
- GitHub #866 이슈 본문 (2026-11-06), PR #889 본문, 커밋 2be18de0 (2026-11-07). 이슈 리포트 댓글은 아직 없음.
