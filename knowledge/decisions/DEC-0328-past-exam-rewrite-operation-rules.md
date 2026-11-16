---
type: decision
id: DEC-0328
created: 2026-11-16
reviewed: null
topics: [question-bank, admin, billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0535-past-exam-restored-rounds]]", "[[ISS-0534-intro-site-past-exam-preview-study-guides]]", "[[DEC-0142-encrypt-sqld-research-materials]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]", "[[DEC-0315-exam-answer-page-concept-line-no-original]]", "[[DEC-0324-question-internal-tag-namespace-format]]", "[[DEC-0326-site-past-exam-five-question-preview]]"]
---

# DEC-0328: 기출 복원 문항은 지문·보기·정답만 모아 문장을 새로 쓰고 테이블·값을 바꿔 원문 5-gram 유사도 0.35 이하·Oracle 실행 검증을 통과한 것만 등록하며, 원본은 레포 밖에 두고, 가장 최근 기출 1회차는 무료, 게시 중단 요청 시 round 태그로 비활성화한다

GitHub #1079 (이슈 본문, 범위 추가 댓글, 보고서 댓글).

## 문제 정의 (Context)
수험생 공부의 중심은 회차별 기출 복원인데 passQL 에는 없었다. 응시자들이 함께 복원해 공개한 SQLD 45~62회(900문항)를 쓰되, 원문을 그대로 옮기면 저작권 위험이 있다(비교: [[DEC-0315-exam-answer-page-concept-line-no-original]]가 원문 복원을 피한 이유). 수집·변형·검증·무료 범위·게시 중단 대응 규칙을 정해야 했다.

## 결정 (Decision)
- **수집:** 지문·보기·정답·회차·과목만. 외부 해설과 외부 제작 그림 원본(SVG)은 가져오지 않는다. 그림은 그림 속 정보(설명·라벨·관계)만 추출한다.
- **원본 보관:** 원문 정리본·다시 쓴 YAML 은 레포 밖 연구 폴더(`docs/sqld-research/...`, 로컬 전용)에 두고 커밋은 암호화본만([[DEC-0142-encrypt-sqld-research-materials]]).
- **다시 쓰기:** 지문·보기 문장을 새로 쓰고, 테이블 데이터·수치를 바꾸고, 보기 순서를 섞는다. 그림 문항은 엔터티를 바꿔 다시 구성하고 관계를 지문에 글로 적는다. 해설은 외부 것을 쓰지 않고 앱 AI 해설이 담당한다.
- **등록 조건:** 원문 대비 5-gram 유사도 **0.35 이하**(넘으면 다시 씀), SQL 문항은 **Oracle(21c) 실행 검증** 통과, 하네스 lint 0, 서버 형식 규칙 통과.
- **추적:** 문항마다 내부 태그 `source`·`round`·`batch`([[DEC-0324-question-internal-tag-namespace-format]])를 붙여 회차 문항 uuid 를 태그로 확보한다.
- **무료 범위:** **가장 최근 기출 회차 1개**는 무료 회원도 응시(`isFreePastExamRound`), 모의고사 무료 체험 횟수와 별개.
- **게시 중단:** 출제기관 요청이 오면 `round:{회차}` 태그로 해당 회차 문항을 찾아 비활성화하고 회차를 보관 처리한다.

## 검토한 대안 (Alternatives)
- 무료 공개 범위: #1079 댓글(2026-11-14)이 "전체 무료 / 일부 회차 무료 / 학습 모드만 무료 등"을 설계 항목으로 올렸고, 가장 최근 1회차 무료로 구현됐다. 고른 이유와 나머지 탈락 이유는 논의 기록 없음. 무료 한도·이용권 정책은 현행 유지(#1087 취소).
- 그림을 머메이드로 그려 앱에서 렌더링: 이슈 댓글의 계획이었으나 이번에는 지문에 관계를 글로 적고 머메이드 필드는 앱에 보내지 않았다(후속). 이유는 논의 기록 없음.
- 유사도 기준값 0.35·n=5 를 고른 이유: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 원문을 옮기지 않고 회차 구성(시험 번호 순서·과목 배분)을 살린 기출 복원 회차를 제공한다. 정답은 실행 검증으로 확인된다(550/550).
- 게시 중단 요청을 태그 한 번으로 회차 단위 대응할 수 있다.

**부정**
- 복원 자료가 틀리거나 비어 있으면 문항을 새로 써야 한다(57회 7번: 1과목이 9개뿐이라 모델링 문항을 새로 씀).
- 변형 문항이라 원래 기출과 문장이 달라 "기출 그대로"를 기대하는 사용자에게는 차이가 있다 — 앱에 면책 한 줄로 안내. 영향은 논의 기록 없음.

## 영향 범위 (Scope)
연구 폴더 `docs/sqld-research/questions/past-exams/sqld-{회차}.yaml`(레포 밖), 문제 생성 하네스, 관리자 JSON 가져오기·`POST /admin/api/mock-exams/past-rounds`, Flyway `V1_133_3__mock_exam_round_type.sql`, 모의고사 공개 API(`isFreePastExamRound`), 앱 모의고사 [기출 복원] 탭.

## 출처 (References)
- GitHub #1079 이슈 본문·댓글 https://github.com/Twin-Fang/passQL/issues/1079#issuecomment-6874926289, https://github.com/Twin-Fang/passQL/issues/1079#issuecomment-6878017359
- 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1079#issuecomment-6903849347

## W4 검사
- [[DEC-0142-encrypt-sqld-research-materials]](조사 원문 로컬, 암호본만 커밋): 같은 방향 — 충돌 없음.
- [[DEC-0315-exam-answer-page-concept-line-no-original]](원문 지문·보기 게시 안 함): 원문이 아니라 다시 쓴 문항이라 충돌 없음.
- [[DEC-0264-mock-exam-fixed-rounds-server-judged]](모의고사 무료는 공개 회차 중 가장 작은 번호 1회 체험): 기출 복원 회차(`round_type = PAST_EXAM`)에만 "가장 최근 1회차 무료"를 따로 더한다. 모의고사 체험 규칙은 바뀌지 않아 둘 다 조건부 유지로 기록 — DEC-0264 는 대체하지 않는다. 이 무료 추가가 사용자 확인을 거쳤는지는 원본에 명시가 없다(구현·배포됨).
