---
type: decision
id: DEC-0339
created: 2026-11-16
reviewed: null
topics: [question-bank]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0540-past-exam-figure-erd-generator]]", "[[ISS-0540-past-exam-figure-erd-generator-report]]", "[[DEC-0337-question-figure-code-generator-not-ai-image]]"]
---

# DEC-0339: 문제 그림 모양은 시험지와 "어느 정도 비슷하게" — 이름은 상자 밖 한글, 머리칸 채움 없음, 의존 엔터티 둥근 모서리, `(FK)` 붙여 쓰기, 라벨 상자 없음, 바커 속성 앞 `□`

GitHub #1132 (후속 보고서 댓글, 작업 세션 사용자 발언).

## 문제 정의 (Context)
1차 생성기 그림은 기호는 맞지만 모양이 시험지와 달랐다(머리칸 채움, 영문 이름 등). 복원 기출과 SQL 전문가 가이드 그림을 여러 출처에서 비교하니 기호 체계(IE 차수, 식별 실선, 비식별 점선, 바커)는 원래 같았고 그리는 모양만 달랐다.

## 결정 (Decision)
- 모양만 시험지에 가깝게 맞춘다. 완전히 똑같게 그리는 것은 목표가 아니다. 사용자 발언(작업 세션): "완벽히 똑같을 필요는 없다", "어느정도는 비슷하게".
- **엔터티 이름:** 상자 바깥 왼쪽 위, 한글만. 보기가 영문 이름을 쓰는 문항(55회 32번)만 영문 병기. 머리칸 채움 없음(흑백).
- **의존 엔터티:** 부모 식별자를 물려받은 엔터티는 둥근 모서리, 독립 엔터티는 직각.
- **외래키:** `회원번호(FK)`처럼 붙여 쓴다.
- **라벨:** ㄱ, (가) 같은 표시는 상자 없이 선 옆에.
- **바커:** 속성 줄 앞에 `□`.
- 공통 모양은 `figure_style.py` 한 곳.

## 검토한 대안 (Alternatives)
- 시험지와 완전히 같은 모양: 목표로 하지 않음(사용자 발언). 실제 시험지 원본은 공개된 것이 없어 비교 기준은 복원 기출과 공식 가이드 그림.
- 그 밖의 대안: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 운영 그림 46개를 새 모양으로 다시 저장(46/46), 수험생이 시험장에서 볼 그림과 비슷한 모양으로 연습한다.

**부정**
- 원본 시험지를 보지 못해 실제 시험지와의 차이는 확인할 수 없다(보고서 주의 사항).
- 바커 표기는 "엔터티에 맞닿은 선 절반이 그 엔터티의 참여(실선 필수, 점선 선택)"라는 표준 해석을 따랐다 — 교재마다 다를 수 있다(새 문항 17번은 해석 조건 한 줄로 고정).

## 영향 범위 (Scope)
`tools/question-figure/figure_style.py`, `figure_svg.py`, `barker_notation.py`, 운영 문항 `figure_svg` 46개.

## 출처 (References)
- 후속 보고서 https://github.com/Twin-Fang/passQL/issues/1132#issuecomment-6909699087

## W4 검사
- 그림 모양에 관한 이전 결정 없음(검색 "그림", "ERD", "머메이드") — 충돌 없음.
