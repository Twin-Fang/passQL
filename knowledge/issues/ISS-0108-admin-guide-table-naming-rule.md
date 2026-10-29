---
type: issue
id: ISS-0108
created: 2026-04-12
topics: [admin, question-bank]
symptoms: ["테이블 이름", SQLD_14, SQLD46_01_EMP, schemaDdl, "문제 등록 가이드", SchemaViewer, "시험 내부 코드 노출"]
root_cause: "문제 등록 가이드 어디에도 테이블 이름 작성 지침이 없어 시험 회차·번호가 테이블 이름에 들어갔다"
status: resolved
resolution: "[[ISS-0108-admin-guide-table-naming-rule-report]]"
related: ["[[DEC-0067-short-meaningful-table-names]]"]
source: "https://github.com/Twin-Fang/passQL/issues/193"
---

# ISS-0108: 문제 등록 가이드에 테이블 이름 작성 규칙 추가

GitHub #193 (원본: 이슈 본문, 리포트 댓글, "Stable 적용" 댓글).

## 증상
관리자가 `SQLD_14`, `SQLD46_01_EMP`처럼 시험 회차·문제 번호를 테이블 이름에 쓴다. 문제마다 독립 Sandbox라 충돌이 없는데도 긴 이름을 쓰고, 학습자 화면(SchemaViewer)에 시험 내부 코드가 노출된다. 단건·대량 가이드와 관리자 가이드 모달에 지침이 없다.

## 재현 조건
해당 없음 (콘텐츠 가이드 개선).

## 조사 기록
- 2026-04-12: 이슈 등록과 수정. 2026-04-12 "Stable 적용" 댓글.

## 근본 원인
가이드에 Sandbox 격리 사실과 테이블 이름 규칙이 명시되어 있지 않았다.
