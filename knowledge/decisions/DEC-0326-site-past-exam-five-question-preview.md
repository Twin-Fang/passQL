---
type: decision
id: DEC-0326
created: 2026-11-16
reviewed: null
topics: [store-release, question-bank]
status: active
supersedes: DEC-0295
superseded_by: null
related: ["[[ISS-0534-intro-site-past-exam-preview-study-guides]]", "[[ISS-0535-past-exam-restored-rounds]]", "[[DEC-0295-seo-public-exam-info-no-hidden-text]]", "[[DEC-0315-exam-answer-page-concept-line-no-original]]", "[[DEC-0328-past-exam-rewrite-operation-rules]]"]
---

# DEC-0326: 소개 사이트는 기출 복원 회차마다 다시 쓴 문항 5개만 지문·보기·정답을 공개하고 해설·나머지 45문항은 앱에 둔다 — DEC-0295 의 "학습 콘텐츠 원문 비공개"만 바꾸고 나머지 항목은 그대로 이어받는다

GitHub #1088·#1079 (공유 보고서 댓글), 2026-11-16 사용자 선택.

## 문제 정의 (Context)
소개 사이트에 검색으로 들어올 공개 콘텐츠가 적었다. 비교 서비스는 문항별 공개 페이지·회차 정리 글로 검색 유입을 만든다(#1088 이슈 본문). [[DEC-0295-seo-public-exam-info-no-hidden-text]]는 학습 콘텐츠(문제·해설) 원문을 공개하지 않기로 했는데, #1079 로 다시 쓴 기출 복원 문항이 생기면서 공개 범위를 다시 정해야 했다(#1088 작업 첫 항목 "공개 범위 결정").

## 결정 (Decision)
**DEC-0295 와의 관계: 일부 대체.** 체인 표기상 DEC-0295 전체를 이 노트가 대체(`supersedes: DEC-0295`)하지만, 내용이 바뀐 것은 "학습 콘텐츠 원문 공개 안 함" 한 항목뿐이다. 그 밖의 DEC-0295 항목은 아래 "유지" 목록으로 이 노트가 그대로 이어받는다.

바뀐 것:
- 기출 복원 회차(`sqld/past/52/` ~ `62/`)마다 **5문항만** 지문·보기·정답을 공개한다(정답은 `<details>` 접기). 공개 문항은 원문이 아니라 passQL 이 다시 쓴 문항이다([[DEC-0328-past-exam-rewrite-operation-rules]]).
- **해설과 나머지 45문항은 공개하지 않고** 앱 [기출 복원] 탭으로 안내한다. 해설은 정적으로 넣지 않고 앱 AI 해설이 담당한다.
- 일반 문제 은행의 문제·해설은 여전히 공개하지 않는다(이번 공개는 기출 복원 회차 미리보기에 한정).

유지(DEC-0295 에서 이어받음):
- 검색 노출은 공개 정보 페이지(시험 일정, 과목·출제 범위, 합격 기준·과락, 공부 방법, FAQ, SQLP 안내)로 늘린다. 이번 공부 글(`sqld/guide/null-traps/`·`window-functions/`·`join-types/`)도 이 방향.
- **숨긴 글씨·키워드 나열은 쓰지 않는다.**
- 리뷰는 앱 안 평가 요청 시점으로만 늘리고 대가를 준 리뷰는 하지 않는다.

## 검토한 대안 (Alternatives)
- 학습 콘텐츠 비공개 유지(DEC-0295 그대로): 2026-11-16 질문에서 사용자가 "기출 문항도 일부 공개"를 골라 탈락. 다른 선택지 문구와 각 탈락 이유는 논의 기록 없음.
- 회차 전체 공개·해설 공개: 논의 기록 없음(보고서는 "5문항만, 해설과 45문항은 앱"만 적음).
- 5라는 수를 고른 이유: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 회차별 문항 페이지가 검색어(회차·개념)를 담은 본문이 되고, 나머지 문항·해설이 앱 설치 동기가 된다(#1088 이슈 본문의 목적).

**부정**
- 다시 쓴 문항이라도 복원 기출에서 파생된 콘텐츠를 공개하므로 게시 중단 요청 대응이 사이트까지 필요하다. 사이트 쪽 내리기 절차는 원본에 따로 없다.
- 공개 문항 수만큼 앱 안 콘텐츠 희소성이 줄어든다 — 그 영향은 논의 기록 없음.

## 영향 범위 (Scope)
소개 사이트 `sqld/past/`·`sqld/past/<회차>/`·`sqld/guide/*`, 상단 메뉴 '기출 복원', sitemap. 회차 가답안 페이지(`sqld/63/`)의 형식은 [[DEC-0315-exam-answer-page-concept-line-no-original]] 그대로(원문 지문·보기 없음).

## 출처 (References)
- GitHub #1088 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1088#issuecomment-6903849682 (#1079 와 같은 본문)
- 2026-11-16 사용자 선택("기출 문항도 일부 공개") — 세션 대화, 원문 미보존

## W4 검사
- [[DEC-0295-seo-public-exam-info-no-hidden-text]]: "학습 콘텐츠 원문 공개 안 함"과 충돌. 사용자가 신규를 골랐으므로 신규로 대체 — DEC-0295 `status: superseded`, `superseded_by: DEC-0326`, 본문은 고치지 않음. 스키마가 결정 하나에 후속 하나만 두므로 일부 대체를 전체 대체 + 나머지 항목 이어받기로 표기했다.
- [[DEC-0315-exam-answer-page-concept-line-no-original]](가답안 페이지는 원문 지문·보기 없이 개념 한 줄): 대상이 회차 가답안 페이지이고, 이번 공개는 다시 쓴 문항이라 원문이 아니다 — 충돌 없음, 그대로 유효.
