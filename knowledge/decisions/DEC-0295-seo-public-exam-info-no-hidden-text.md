---
type: decision
id: DEC-0295
created: 2026-11-12
reviewed: null
topics: [store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0508-search-visibility-site-domain-aso]]", "[[ISS-0310-sqld-seo-intro-site-revamp]]"]
---

# DEC-0295: 검색 노출은 공개 시험 정보 페이지로 늘리고, 숨긴 글씨·키워드 나열과 학습 콘텐츠 원문 공개는 하지 않는다

GitHub #1027 (이슈 본문).

## 문제 정의 (Context)
"SQLD" 검색에서 passQL이 잘 보이지 않는다. 학습 콘텐츠는 로그인 뒤에 있어 검색 엔진이 읽을 본문이 적다.

## 결정 (Decision)
- 학습 콘텐츠(문제·해설) 원문은 공개하지 않는다(사용자 결정, 이슈 본문).
- 대신 공개 정보 페이지를 늘린다: SQLD 시험 일정, 과목·출제 범위, 합격 기준·과락, 공부 방법, 자주 묻는 질문, SQLP 안내.
- 숨긴 글씨나 키워드 나열은 쓰지 않는다.
- 리뷰는 앱 안 평가 요청 시점으로만 늘리고, 대가를 준 리뷰는 하지 않는다.

## 검토한 대안 (Alternatives)
- 숨긴 글씨·키워드 나열: 검색 엔진 스팸 정책상 오히려 순위가 내려간다(이슈 본문).
- 대가를 준 리뷰: 정책 위반(이슈 본문).
- 학습 콘텐츠 공개: 사용자 결정으로 하지 않음. 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 정책 위반 위험 없이 검색어를 담은 본문이 생긴다.

**부정**
- 문제 원문 같은 긴 꼬리 검색어는 잡지 못한다. 논의 기록 없음(효과 측정 전).

## 영향 범위 (Scope)
gh-pages `_src/site_exam_pages.py`·`site_guides.py`·`site_schema.py`, `app/lib/core/review/*`, `app/docs/store/*`.

## 출처 (References)
- GitHub #1027 이슈 본문 (2026-11-12)
