---
type: completion-report
id: ISS-0534
created: 2026-11-16
topics: [store-release, question-bank]
status: resolved
resolves: "[[ISS-0534-intro-site-past-exam-preview-study-guides]]"
related: ["[[ISS-0535-past-exam-restored-rounds]]", "[[DEC-0326-site-past-exam-five-question-preview]]", "[[DEC-0327-answer-key-highlight-exam-date-plus-7]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1088#issuecomment-6903849682"
---

# ISS-0534 완료 리포트: 소개 사이트 기출 일부 공개(회차마다 5문항)와 공부 글

보고서는 #1079(기출 복원 회차)와 공유한다. #1079 는 45~51회·학습 모드가 남아 열려 있다([[ISS-0535-past-exam-restored-rounds]]).

## 해결 방법
- `sqld/past/` 목록, `sqld/past/52/` ~ `62/` 회차별 5문항 공개(다시 쓴 문항, 정답은 `<details>` 접기). 해설·나머지 45문항은 앱 [기출 복원] 탭으로 안내([[DEC-0326-site-past-exam-five-question-preview]]).
- 공부 글 `sqld/guide/null-traps/`·`window-functions/`·`join-types/`, 상단 메뉴 '기출 복원'.
- 가채점 강조(메뉴·첫 화면 띠)를 시험일 + 7일로 단축, 그 뒤에는 문항별 앱 연결이 앞에 온다([[DEC-0327-answer-key-highlight-exam-date-plus-7]]).
- 검증: 신규 15페이지 200, sitemap 32개, 데스크톱·모바일 캡처.

## 근본 원인 (확정)
소개 사이트의 공개 콘텐츠가 시험 정보 페이지뿐이었다([[DEC-0295-seo-public-exam-info-no-hidden-text]] 범위).

## 재발 방지
- 공개 문항은 다시 쓴 문항이며 원문이 아니다. 회차당 5문항 상한과 해설 비공개를 지킨다.
- 출제기관 게시 중단 요청 시 `round:{회차}` 태그로 문항을 찾아 비활성화, 회차 보관([[DEC-0328-past-exam-rewrite-operation-rules]]). 사이트 회차 페이지도 함께 내려야 한다(보고서에 사이트 절차는 따로 없음).
- 개념 카드 PDF 는 만들지 않았다.

## 교훈
검색 유입 콘텐츠를 늘릴 때는 공개 범위(몇 문항·해설 여부)를 먼저 사용자에게 고르게 하고 결정 노트로 남긴다.
