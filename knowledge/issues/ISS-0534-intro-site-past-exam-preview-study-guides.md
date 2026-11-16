---
type: issue
id: ISS-0534
created: 2026-11-16
topics: [store-release, question-bank]
symptoms: ["검색 유입 콘텐츠", "공개 콘텐츠 적음", "문항 공개 페이지", "회차별 정리", "공부 글", "sqld/past", "sqld/guide", "null-traps", "window-functions", "join-types", "기출 복원 메뉴", "가채점 강조 기간", "개념 카드 PDF"]
root_cause: "소개 사이트에 검색으로 들어올 공개 콘텐츠가 시험 정보 페이지뿐이었다(문항·회차·공부 글 부재)"
status: resolved
resolution: "[[ISS-0534-intro-site-past-exam-preview-study-guides-report]]"
related: ["[[ISS-0535-past-exam-restored-rounds]]", "[[DEC-0326-site-past-exam-five-question-preview]]", "[[DEC-0327-answer-key-highlight-exam-date-plus-7]]", "[[DEC-0295-seo-public-exam-info-no-hidden-text]]"]
source: "_sources/issues/ISS-0534-intro-site-past-exam-preview-study-guides.md"
---

# ISS-0534: 소개 사이트 검색 유입 콘텐츠 — 기출 일부 공개, 회차 페이지, 공부 글

GitHub #1088 (닫힘, 작업완료). 원본: https://github.com/Twin-Fang/passQL/issues/1088 · 보고서는 #1079 와 공유.

## 증상
검색으로 들어올 공개 콘텐츠가 적었다. 비교 서비스는 문항별 공개 페이지·회차 정리 글·공부법 글·PDF 개념 카드로 검색 유입을 만든다.

## 재현 조건
소개 사이트(https://passql.suhsaechan.kr). 경쟁 서비스 비교(2026-11-14)에서 나온 공백.

## 조사 기록
- 2026-11-14: 이슈 등록. 작업 첫 항목 "공개 범위 결정(무료 공개 문항, PDF 제공 조건)".
- 2026-11-16: 공개 범위 — 사용자가 "기출 문항도 일부 공개"를 골라 회차마다 5문항(다시 쓴 문항)만 지문·보기·정답 공개, 해설·나머지 45문항은 앱([[DEC-0326-site-past-exam-five-question-preview]], [[DEC-0295-seo-public-exam-info-no-hidden-text]] 대체).
- 2026-11-16: 가채점 강조(메뉴·첫 화면 띠)를 시험일 + 7일로 단축([[DEC-0327-answer-key-highlight-exam-date-plus-7]]).
- 2026-11-16: `sqld/past/` 목록·`52/`~`62/` 회차 페이지, 공부 글 3편, 상단 메뉴 '기출 복원' 배포. 신규 15페이지 200, sitemap 32개.
- 개념 카드 PDF 는 보고서에 없다 — 만들지 않은 채 이슈가 닫혔다(이유는 논의 기록 없음).

## 근본 원인
공개 콘텐츠 부재. 완료 리포트 [[ISS-0534-intro-site-past-exam-preview-study-guides-report]].
