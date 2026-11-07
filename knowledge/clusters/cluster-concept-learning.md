---
type: cluster
topic: concept-learning
created: 2026-10-29
members: 21
status: active
related: []
---

# 클러스터: concept-learning

## 이 주제는
개념 학습·단원

## 현재 상태 요약
(2026-11-07, 자동 생성) 활성 결정 10개, 열린 이슈 2개. 개념 글 소제목 부제 구분자는 운영 콘텐츠와 레포 원본 모두 `: `로 바뀌었고 앱 해석기는 `: `와 옛 줄표를 모두 읽는다: [[DEC-0277-no-dash-middle-dot-server-cleaner]] (#905), [[DEC-0278-stem-blocks-single-table-shape]] (#903). [[DEC-0256-concept-lesson-blocks-by-table-header]]의 문단 제목 표기와 부분 충돌해 처리 결정 대기. 개념 글은 유형별 레슨 블록 — [[DEC-0256-concept-lesson-blocks-by-table-header]] (#848), 결과가 만들어지는 과정은 움직이는 그림 블록 — [[DEC-0257-concept-animated-diagram-blocks]] (#853). 외울 말은 `**` 형광펜, 개념마다 꼭 외울 것 문단, 표 폭은 빌드에서 검사 — [[DEC-0266-concept-bold-highlight-memorize-section]] (#876, PR #890 머지·이슈 열림). 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0252-concept-reading-single-scroll]] — 개념 읽기는 한 스크롤 카드 구조, 세그먼트 `개념 | 확인 문제`
- [[DEC-0256-concept-lesson-blocks-by-table-header]] — 개념 글은 유형별 레슨 블록(표 머리글로 구분), 접기 없음, 스크롤 등장
- [[DEC-0257-concept-animated-diagram-blocks]] — 조인 연결·행 거르기·집합 그림 블록(표 머리글로 구분), 스크롤로 들어오면 진행, 외우는 법 타일 뒤집기
- [[DEC-0218-concept-result-ring-climax]] — 개념 결과: 문제마다 한 칸씩 차는 고리 + 햅틱, 큰 연출은 다 맞힘·단원 끝에만, 단원 숫자 `+1` 뒤 롤링
- [[DEC-0219-keep-one-line-headlines-visualize-instructions]] — 감정·행동 한 줄 제목은 남기고 사용 안내 문장만 시각화
- [[DEC-0221-concept-wrong-rows-expand-in-place]] — 틀린 문제는 시트 대신 목록 줄을 눌러 그 자리에서 펼침
- [[DEC-0222-concept-perfect-fullscreen-scoreboard]] — 다 맞히면 듀오링고식 전체 화면 점수판 (앱 토큰 색, 카드 3장)
- [[DEC-0266-concept-bold-highlight-memorize-section]] — 개념 글 `**` 형광펜, 개념마다 꼭 외울 것(`#memorize`, `| 외울 것 | 답 |`) 문단, 표 폭 빌드 점검 (#876)
- [[DEC-0277-no-dash-middle-dot-server-cleaner]]: 문항과 생성 글에 줄표, 가운뎃점 금지(짝은 용어: 분류, 나열은 쉼표), 프롬프트 맨 앞 규칙 + 서버 ForbiddenPunctuationCleaner, 데이터 표는 스키마 한 곳 (#905)
- [[DEC-0278-stem-blocks-single-table-shape]]: 지문은 블록(단락, 보조 설명, 질문, 목록, 표, 코드)으로 앱과 웹 같은 규칙, 표는 지문 카드 안 한 가지 모양(컬럼 이름 + PK, FK, 행 전부), 같은 컬럼 표는 한 번 (#903)

## 대체된 결정 (역사)
- [[DEC-0253-concept-collapse-only-long-later-sections]] — 긴 문단만 접기 > [[DEC-0256-concept-lesson-blocks-by-table-header]]로 대체
- [[DEC-0217-concept-study-single-segment]] — `핵심 | 자세히 | 문제` 세그먼트 > [[DEC-0252-concept-reading-single-scroll]]로 대체

## 관련 이슈
- [[ISS-0474-question-format-rule-forbidden-punctuation]] (resolved, GitHub #905): 문제 형식 규칙 하네스: 줄표 금지, 표는 스키마 한 곳, SQL 서식, 운영 데이터와 프롬프트 정리
- [[ISS-0472-stem-readability-blocks-single-table]] (resolved, GitHub #903): 문제 지문 가독성: 단락, 목록, 질문 구분, 표 한 가지 모양, SQL 상자
- [[ISS-0465-concept-memorize-highlight-wide-tables]] (open, GitHub #876) — 개념 학습 외울 부분 강조와 과목별 암기 포인트 보강, 가로로 긴 표 정리 (PR #890 머지, 리포트 전)
- [[ISS-0457-concept-animated-diagrams]] (resolved, GitHub #853) — 개념 학습 움직이는 그림(조인 연결·행 거르기·집합)과 뒤집는 암기 타일
- [[ISS-0456-concept-lesson-textbook-blocks]] (resolved, GitHub #848) — 개념 학습 교과서형 요점정리 재설계, 개념 글 63개 다시 쓰기
- [[ISS-0453-app-concept-reading-readability-redesign]] (resolved, GitHub #835) — 개념 학습 화면 가독성 개선과 설명 UX 재설계
- [[ISS-0432-app-concept-tab-redesign]] (resolved, GitHub #764) — 앱 개념 탭 UI/UX 개편
- [[ISS-0358-concept-learning-by-unit]] (open, GitHub #577) — 단원별 개념 학습 (수험서 대체)
- [[ISS-0373-admin-concept-exam-choiceset-tools]] (resolved, GitHub #618) — 관리자 개념 문서·시험 일정·선택지 세트 화면의 미리보기·일괄 처리·필터 부족
