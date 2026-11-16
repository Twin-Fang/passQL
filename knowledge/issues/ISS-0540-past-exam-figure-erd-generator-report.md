---
type: completion-report
id: ISS-0540
created: 2026-11-16
topics: [question-bank, practice, admin]
status: resolved
resolves: "[[ISS-0540-past-exam-figure-erd-generator]]"
related: ["[[DEC-0337-question-figure-code-generator-not-ai-image]]", "[[DEC-0338-app-figure-white-paper-tap-to-zoom]]", "[[DEC-0339-figure-style-close-to-exam-sheet]]", "[[DEC-0340-no-short-answer-convert-to-four-choice]]", "[[DEC-0341-final-push-all-members-pro-invite-wording]]", "[[LSN-0007-admin-403-read-only-check-csrf-session]]"]
source: "_sources/issues/ISS-0540-past-exam-figure-erd-generator-report.md"
---

# ISS-0540 완료 리포트: 문제 그림 필드(SVG), 시험지 모양 ERD 생성기, 그림 문항 46개 운영 반영 (#1132)

보고서 댓글 2개: https://github.com/Twin-Fang/passQL/issues/1132#issuecomment-6908908562 (1차), https://github.com/Twin-Fang/passQL/issues/1132#issuecomment-6909699087 (후속)

## 해결 방법
**1차 (PR #1134 > 릴리스 #1135)**
- **서버:** `V1_139_0__question_figure_svg.sql`, `Question.figureSvg`, 검사 `QuestionFigureSvgRule`(스크립트·외부 참조 차단, 40KB), `QuestionFigureService`, 관리자 `PUT /admin/questions/{uuid}/figure`. 가져오기·내보내기 `figureSvg`: null 이면 기존 그림 유지, 빈 값이면 지움, 검증과 일괄 등록 모두 같은 검사. 문제 상세, 모의고사 시험지·결과 응답에 `figureSvg`. FINAL 공개 알림 문구는 전체 회원 대상 그대로, PRO 응시 권유([[DEC-0341-final-push-all-members-pro-invite-wording]]).
- **앱:** `QuestionFigure` 를 지문 카드 `QuestionStem` 한 곳에 넣어 풀이·모의고사·잠금화면이 같은 부품을 씀. 눌러서 크게 보기(전체 화면 핀치 줌). 토큰 `figurePaper`, `figureInk`, `questionFigureMaxWidth`([[DEC-0338-app-figure-white-paper-tap-to-zoom]]).
- **생성기·하네스:** `tools/question-figure`(`figure_svg.py`, `figure_style.py`, `barker_notation.py`, `generic_shapes.py`, `mermaid_to_spec.py` — 별칭 `NAME["회원 MEMBER"]`, `%% pos` 배치). 하네스 `question_figure.py` 가 `figureSpec`(우선) 또는 `diagramMermaid` 로 `figureSvg` 생성, lint `figure.identifying-line`([[DEC-0337-question-figure-code-generator-not-ai-image]]).
- **콘텐츠:** 기출 22, 기존 문제 풀 3(IE 1, 바커 2), 새 ERD 문항 20(`batch:erd-figure`, 정답 위치 A~D 각 5).

**후속 (PR #1139 > 릴리스 #1140)**
- 그림 모양을 시험지에 가깝게: 이름 상자 밖 한글만(55회 32번만 영문 병기), 머리칸 채움 없음, 의존 엔터티 둥근 모서리, `회원번호(FK)`, 라벨 상자 없음, 바커 속성 앞 `□`, 오른쪽 세로선 라벨 잘림 수정. 운영 그림 46/46 다시 저장([[DEC-0339-figure-style-close-to-exam-sheet]]).
- 독립 검수 46문항, 지문 8문항 관리자 편집으로 수정(보기·회차 세트 그대로). 47회 2번 그림 추가.
- 관리자 편집 폼 저장 시 줄바꿈 LF 통일.
- 소개 사이트: 회차 페이지 "나머지 45문항에는 이런 유형이 있어요", 회차 목록 유형별 합계(45~62회 900문항), 45~51회 페이지 추가, 공개 문항 회전을 회차 번호 기준으로(60회 1과목 공개 문항 하나 바뀜). 유형 수치는 문항 YAML 에서 센 숫자만.

## 근본 원인 (확정)
문제 데이터에 그림 필드가 없었다(기능 부재). CRLF 는 관리자 편집 폼 저장 경로에 줄바꿈 정규화가 없었던 것.

## 재발 방지
- 생성기 lint `figure.identifying-line` 이 외래키 위치로 실선·점선을 검사(머메이드 초안 실수 12/22 검출).
- 서버 `QuestionFigureSvgRuleTest`, `OpenApiContractTest`, 앱 `flutter test` 191건, 하네스 79건 통과. 그림 46개를 앱 실제 부품으로 렌더해 확인.
- 주의 사항(보고서): SVG 글꼴은 앱 Pretendard family 이름을 그대로 써서 `app/pubspec.yaml` 글꼴 이름을 바꾸면 `figure_style.py` 도 함께 바꾼다. 생성기는 자기 참조(순환) 관계를 못 그린다. 넓은 그림(5번, 17번, 기출 50-3)은 폰에서 글자가 작아 크게 보기로 보완. 구버전 앱은 그림 필드를 무시. 실기기 확인은 다음 앱 빌드에서. 실제 시험지 원본은 공개된 것이 없어 비교 기준은 복원 기출과 공식 가이드 그림. CRLF 수정 전에 저장한 8문항은 CRLF 로 남음(화면 영향 없음).

## 교훈
- 그림을 붙이면 지문 설명을 다시 본다 — 그림이 없을 때 넣은 관계 설명이 그림과 함께 정답을 미리 알려 줄 수 있다(5문항).
- 관리자 403 "조회 전용"은 계정 권한보다 세션 만료·CSRF 헤더를 먼저 의심한다: [[LSN-0007-admin-403-read-only-check-csrf-session]].
