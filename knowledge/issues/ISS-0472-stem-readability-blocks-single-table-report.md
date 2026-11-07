---
type: completion-report
id: ISS-0472
created: 2026-11-07
topics: [practice, question-bank, design-system, concept-learning]
status: resolved
resolves: "[[ISS-0472-stem-readability-blocks-single-table]]"
related: ["[[DEC-0278-stem-blocks-single-table-shape]]", "[[ISS-0474-question-format-rule-forbidden-punctuation]]"]
source: "https://github.com/Twin-Fang/passQL/issues/903"
---

# ISS-0472 완료 리포트: 지문 블록 규칙(앱과 웹 같은 계약), 지문 카드 안 표 한 가지 모양, 테두리 SQL 상자와 캡션

GitHub #903 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/903#issuecomment-6702224135). PR #911 머지, 배포 전. 원본 사본: `_sources/issues/ISS-0472-stem-readability-blocks-single-table-report.md`(로컬).

## 해결 방법
- 블록 규칙: 앱 `stem_blocks.dart`, 웹 `client/src/lib/stemBlocks.ts`(같은 계약). 블록은 단락, 보조 설명(괄호 한 줄, 괄호 유지), 질문(`?`로 끝남, 순서 유지), 목록(`- 용어: 설명`은 용어 굵게, 번호 목록은 번호 유지), 표, 코드. 결정은 [[DEC-0278-stem-blocks-single-table-shape]].
- 표: 앱 `question_data_table.dart`, 웹 `QuestionTable.tsx`. 컬럼 이름 + PK, FK 표시만, 행 전부, 자료형과 샘플 문구 없음. 스키마 표는 지문 카드 안, 같은 컬럼 지문 표 자리에 한 번만(`stemSchemaTablePlacement.ts`). 풀이 화면의 별도 "테이블 N개" 카드 제거(DDL 원문만 있는 문항은 유지).
- SQL 상자: 채움 대신 테두리, 첫 줄 `-- 라벨`은 상자 위 캡션, 코드 속 한글 덩어리는 본문 글꼴, 웹 긴 줄 가로 스크롤.
- 개념 글 소제목: 해석기가 `: `도 부제 구분자로 읽음(옛 줄표도 계속 읽음). #905 콘텐츠 정리 뒤에도 두 줄 유지.
- 적용: 연습, 오늘의 세트, 모의고사 풀이와 해설, 채점 결과 지문.

## 검증
- 앱 `flutter analyze` 0건, `flutter test` 128개(블록 판정 추가). 웹 lint 0, vitest 39개(블록 판정 8개), 아키텍처 규칙 3개, `tsc` 통과. 코드 점검 새 위반 0.
- 라이트, 다크 캡처(웹은 다크 모드 없음).

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 블록 규칙은 앱과 웹 두 곳에 같은 계약으로 있다. 한쪽만 고치면 지문이 갈라지므로 판정 테스트와 함께 양쪽을 고친다.
- 중복 표 판정은 컬럼 구성 비교라, 컬럼 이름이 조금 다르면 두 번 그려진다. 데이터 쪽은 #905 하네스 lint로 막음.
- 자료형을 화면에서 뺐으므로 자료형이 풀이에 필요한 문제는 지문에 적는다.

## 남은 일
- 시뮬레이터, 실기기 실제 화면 확인과 배포 뒤 실측은 후속 댓글.
- W4: 코드 속 한글 본문 글꼴은 [[DEC-0255-code-font-d2coding-subset]]을 DEC-0278 이, 개념 소제목 `: `는 [[DEC-0256-concept-lesson-blocks-by-table-header]]를 DEC-0277 이 대체 (사용자 결정, 2026-11-07).

## 교훈
같은 데이터를 두 경로(지문 글, 스키마 표)로 받는 화면은 "어느 쪽을 그릴지"를 한 판정에 모아야 한다. 각자 그리면 중복과 모양 차이가 생긴다.
