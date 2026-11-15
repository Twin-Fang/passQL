---
type: issue
id: ISS-0526
created: 2026-11-16
topics: [question-bank, admin]
symptoms: ["내부 관리 태그", internalTags, question_internal_tag, QuestionInternalTagRule, "가져오기 태그 사라짐", "trend.templates 유실", "출처 회차 문항 추적 불가", "source:63-17", "trend:t41", "태그 필터", "태그 백필", "internal-tags summary"]
root_cause: "문제 YAML의 출제 유형·근거 회차·개념을 서버 가져오기 형식(QuestionExportDto)이 받지 않아 운영 DB에 들어가면 사라졌고, 운영 문제에는 최신 경향 여부 하나만 있어 출처를 추적할 수 없었다"
status: resolved
resolution: "[[ISS-0526-question-internal-tags-report]]"
related: ["[[DEC-0324-question-internal-tag-namespace-format]]", "[[DEC-0325-import-without-internal-tags-keeps-existing]]", "[[DEC-0038-question-json-roundtrip-format]]", "[[ISS-0519-sqld-round63-trend-new-questions]]", "[[ISS-0527-sqld-round63-batch07-internal-tags]]"]
source: "_sources/issues/ISS-0526-question-internal-tags.md"
---

# ISS-0526: 문제 내부 관리 태그(출처, 유형, 회차, 묶음, 개념)

GitHub #1117 (닫힘, 작업완료). 원본: https://github.com/Twin-Fang/passQL/issues/1117 · 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1117#issuecomment-6903013598 · PR #1120 (머지) · 릴리스 #1121 (서버만)

## 증상
- 문제 원본 YAML(`docs/sqld-research/questions/*.yaml`)의 `trend.templates`(T01~T52), `trend.examRounds`, `concepts`가 가져오기 형식(`QuestionExportDto`)에 없어 운영 DB에 들어가면 사라진다.
- 운영 문제에는 `isLatestTrend` 하나뿐이라 관리자 화면에서 어느 시험 어느 문항, 어느 유형에서 파생됐는지 알 수 없다.
- 기존 `question_concept_tag`는 개념 사전(`concept_tag`) 연결용이라 자유 형식 관리 태그를 담기에 맞지 않는다.

## 재현 조건
하네스로 만든 문제를 관리자 JSON 가져오기로 등록할 때마다.

## 조사 기록
- 2026-11-16: 별도 테이블 `question_internal_tag`(V1_136_0) 추가, 규칙 단일 지점 `QuestionInternalTagRule`, 가져오기·내보내기 `internalTags`, 관리자 목록 표시·필터(정확, 앞부분 일치)·일괄 붙이기·떼기·요약, 상세 편집, 하네스 `verify` 태그 생성(`internal_tags.py`). 형식은 [[DEC-0324-question-internal-tag-namespace-format]], 옛 파일 처리는 [[DEC-0325-import-without-internal-tags-keeps-existing]].
- 2026-11-16: PR #1120 머지, 릴리스 #1121 로 서버만 배포(앱 변경 없음, 심사 없음). 운영 태그 요약 API 200 확인.
- 2026-11-16: 기존 운영 문제 213건(batch04a~e, 05, 06) 태그 백필 changed 213, 실패 0. 이어서 batch07 37건 태그 포함 등록([[ISS-0527-sqld-round63-batch07-internal-tags]]). 운영 요약: source 73종/143, trend 51종/489, round 6종/322, batch 8종/250, concept 513종/737, new-type 75.

## 근본 원인
가져오기 형식과 운영 스키마에 출처·유형 메타데이터를 담을 자리가 없었다(설계 공백).
