---
type: issue
id: ISS-0540
created: 2026-11-16
topics: [question-bank, practice, admin]
symptoms: ["아래 ERD", "아래 그림", "그림 문항 그림 없음", "기출 복원 그림 문항 22개", "IE 표기 세로선 원 까마귀발", "식별 실선 비식별 점선", "바커 표기", "figureSvg", "figure_svg", "V1_139_0__question_figure_svg", "QuestionFigureSvgRule", "PUT /admin/questions/{uuid}/figure", "tools/question-figure", "figureSpec", "diagramMermaid", "figure.identifying-line", "QuestionFigure", "그림이 생기며 지문이 정답을 미리 알려 줌", "관리자 편집 폼 CRLF 저장", "오른쪽 세로선 라벨 잘림", "넓은 그림 글자 작음", "조회 전용 관리자는 변경할 수 없습니다"]
root_cause: "문제 데이터에 그림을 담을 필드가 없어 지문이 가리키는 ERD·그림을 보여 줄 수 없었다(기능 부재). 관리자 편집 폼은 줄바꿈을 CRLF 그대로 저장했다"
status: resolved
resolution: "[[ISS-0540-past-exam-figure-erd-generator-report]]"
related: ["[[DEC-0337-question-figure-code-generator-not-ai-image]]", "[[DEC-0338-app-figure-white-paper-tap-to-zoom]]", "[[DEC-0339-figure-style-close-to-exam-sheet]]", "[[DEC-0340-no-short-answer-convert-to-four-choice]]", "[[DEC-0341-final-push-all-members-pro-invite-wording]]", "[[DEC-0328-past-exam-rewrite-operation-rules]]", "[[DEC-0330-final-round-opens-exam-date-minus-3-pro-only]]", "[[ISS-0535-past-exam-restored-rounds]]", "[[ISS-0534-intro-site-past-exam-preview-study-guides]]", "[[LSN-0007-admin-403-read-only-check-csrf-session]]"]
source: "_sources/issues/ISS-0540-past-exam-figure-erd-generator.md"
---

# ISS-0540: 기출 복원 그림 문항에 그림이 없음 — 문제 그림 필드와 시험지 모양 ERD 생성기

GitHub #1132 (닫힘, 작업완료). 원본: https://github.com/Twin-Fang/passQL/issues/1132 · PR #1134 > 릴리스 #1135, 후속 PR #1139 > 릴리스 #1140

## 증상
- 기출 복원 문항 22개가 지문에서 "아래 ERD", "아래 그림"을 가리키지만 앱에 그림이 없다. IE 표기(세로선, 원, 까마귀발, 실선과 점선)나 그림 속 표시((가)~(라), ㄱ~ㄷ)를 읽는 문제라 그림 없이는 문제 의도가 흐려진다.
- 문제 데이터에 그림을 담을 자리가 없다.

## 재현 조건
앱 모의고사 [기출 복원] 회차의 그림 문항([[ISS-0535-past-exam-restored-rounds]]에서는 엔터티를 바꿔 관계를 지문에 글로 적고 머메이드 필드는 앱에 보내지 않았다 — [[DEC-0328-past-exam-rewrite-operation-rules]]).

## 조사 기록
- 2026-11-16: 이슈 등록. 그림 필드(SVG 문자열)를 문제에 두고, AI 이미지 생성은 기호·글자 오류 위험으로 쓰지 않으며 생성기로 그린다. 함께: FINAL 공개 알림 문구.
- 2026-11-16: 1차 구현·배포(PR #1134, 릴리스 #1135). 서버 `figure_svg`(V1_139_0), SVG 검사(스크립트, 외부 참조, 40KB), 문제 상세·모의고사 시험지·결과 응답. 앱 지문 카드 아래 흰 종이 그림 + 눌러서 크게 보기(시안 C). 생성기 `tools/question-figure`(머메이드 또는 명세 > SVG). lint `figure.identifying-line` 이 머메이드 초안 22개 중 12개의 실선·점선 실수를 잡았다. 운영 그림 문항 45개(기출 22, 기존 문제 풀 3, 새 ERD 문항 20 `batch:erd-figure`). 가로로 길어 글자가 작던 10개는 2열 배치로 바꿈. 지문만으로 풀리는 3문항(47-2, 60-4, 60-5)은 그림 없이 둠.
- 2026-11-16: 후속(PR #1139, 릴리스 #1140). 그림 모양을 시험지에 가깝게(이름 상자 밖, 머리칸 채움 없음, 의존 엔터티 둥근 모서리, `(FK)` 붙여 쓰기, 한글 이름, 라벨 상자 없음, 바커 속성 앞 `□`), 오른쪽 세로선 라벨 잘림 수정, 운영 그림 46/46 다시 저장. 47회 2번은 원본에 그림이 있던 문항이라 그림 추가(보고서: "기출 복원 그림 문항 22개 모두 반영" — 1차 수치와의 관계는 원본 표현 그대로).
- 2026-11-16: 독립 검수 46문항 — 정답 오류·그림과 지문 불일치 없음. 운영에서 지문 8문항 수정: 그림이 생기며 지문 설명이 정답을 미리 알려 주게 된 5문항(49-4, 57-10, 58-5, 59-10, 62-4)은 기호 풀이 문장 삭제, 55-4 복수 정답 위험 제거, 50-3 배타 표시, 새 문항 17번 해석 조건 고정. 보기·회차 세트는 그대로.
- 2026-11-16: 관리자 편집 폼이 줄바꿈을 CRLF 로 저장하던 문제를 저장 시 LF 로 통일(#1139). 수정 배포 전에 저장한 8문항은 CRLF 로 남음(앱은 줄마다 공백을 잘라 써서 화면 영향 없음).
- 2026-11-16: 관리자 일괄 작업 중 403 "조회 전용 관리자는 변경할 수 없습니다"를 만남(작업 세션 전달, 보고서에는 기록 없음) — 계정 권한이 아니라 세션·CSRF 문제였다. 교훈 [[LSN-0007-admin-403-read-only-check-csrf-session]].
- 2026-11-16: 함께 처리 — 단답형 지원(#1085)은 같은 개념 4지선다로 바꿔 넣어 필요 없어져 취소([[DEC-0340-no-short-answer-convert-to-four-choice]]). 소개 사이트 회차 페이지에 남은 45문항의 유형 안내, 45~51회 페이지 추가(18회차), 공개 문항 회전을 회차 번호 기준으로 고정.

## 근본 원인
문제 데이터에 그림 필드가 없어 지문이 가리키는 그림을 보여 줄 수 없었다(기능 부재). 관리자 편집 폼은 줄바꿈 정규화 없이 CRLF 를 저장했다.
