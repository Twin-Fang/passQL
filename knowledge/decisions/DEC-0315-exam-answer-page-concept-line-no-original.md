---
type: decision
id: DEC-0315
created: 2026-11-14
reviewed: null
topics: [store-release, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0520-sqld-round-answer-key-omr-grading]]", "[[DEC-0295-seo-public-exam-info-no-hidden-text]]", "[[DEC-0294-intro-site-self-hosted-own-domain]]"]
---

# DEC-0315: 회차 가답안 페이지는 원문 지문·보기 대신 문항 번호·과목·우리가 쓴 출제 개념 한 줄과 가답안만 싣고, 면책과 게시 중단 요청 절차를 둔다

GitHub #1075 (이슈 본문, 설계 스펙, 보고서 댓글).

## 문제 정의 (Context)
시험 당일 가답안·가채점 페이지(소개 사이트 `sqld/63/`, 앱)를 만들면서 문항을 어떤 형태로 보여 줄지 정해야 했다. 경쟁 복원 사이트 중 원문 복원 위키형은 참여가 활발하지만 원문 복원이라 저작권 위험이 크다(이슈 본문).

## 결정 (Decision)
- 문항 = 실제 번호 + 과목 + 출제 개념(우리가 쓴 한 줄) + 가답안 정보. 원문 지문·보기는 싣지 않는다.
- 출제 개념은 passQL 개념 학습과 관련 문제(유형 기반 자체 문항)로 연결한다.
- 면책 문구("공식 정답 아님, 한국데이터산업진흥원 발표 확인")와 게시 중단 요청 연락처를 둔다.
- 검색 노출용 제목·설명·FAQ 구조화 데이터는 쓰되 숨김 텍스트는 쓰지 않는다([[DEC-0295-seo-public-exam-info-no-hidden-text]]).

## 검토한 대안 (Alternatives)
- 원문 복원(지문·보기 게시): 저작권 위험(이슈 본문). 스펙 "하지 않는 것"에 명시.
- 사용자 자유 서술 게시판·댓글: 욕설·관리 부담으로 다음 단계로 미룸(스펙).
- 경쟁 사이트 데이터 자동 동기화: 하지 않음. 이유는 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 원문 저작권 위험 없이 가답안·가채점을 제공하고, 개념 한 줄이 앱 학습으로 이어지는 입구가 된다.

**부정**
- 원문이 없어 응시자가 문항을 번호와 개념으로만 떠올려야 한다. 그 영향은 논의 기록 없음.

## 영향 범위 (Scope)
gh-pages `_src/site_answer_key_pages.py`·`site_answer_key_content.py`·`exam-answer*.js`, 서버 `exam_answer_item.concept_title`·`concept_tags`, 앱 `presentation/widgets/exam_answer/*`, 관리자 `/admin/exam-answers`.

## 출처 (References)
- GitHub #1075 이슈 본문, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1075#issuecomment-6875720871
- 설계 스펙 `docs/superpowers/specs/2026-11-14-exam-answer-key-design.md` (로컬 전용)

## W4 검사
[[DEC-0295-seo-public-exam-info-no-hidden-text]](학습 콘텐츠 원문 비공개, 숨김 텍스트 금지)와 같은 방향이다 — 충돌 없음. 개념 한 줄은 우리가 쓴 공개용 요약이며 문제·해설 원문이 아니다. [[DEC-0294-intro-site-self-hosted-own-domain]](보유 도메인 시놀로지 서빙, 원본 `_src/` 생성기)도 그대로 따른다.
