---
type: issue
id: ISS-0391
created: 2026-10-24
topics: ["dev-workflow"]
symptoms: ["약어 이름", "이름 규칙", "prevFirstDay", "cfg req val", "boolean 접두사"]
root_cause: "코드 구조 점검에서 이름 규칙(약어 금지, boolean 접두사)에 어긋나는 지역 이름이 확인됐다"
status: resolved
resolution: "[[ISS-0391-expand-abbreviated-local-names-report]]"
related: ["[[DEC-0177-rename-only-checkable-local-names]]"]
source: "https://github.com/Twin-Fang/passQL/issues/642"
---

# ISS-0391: 앱·서버·웹 지역 변수에 약어 이름이 남아 있음 (계약 이름 제외)

GitHub #642 (원본: 이슈 본문과 완료 리포트 댓글).

## 증상
코드 구조 점검(2026-10-24)에서 이름 규칙(약어 금지, boolean 접두사) 후보를 직접 열어 판정했다. 앱 `prevFirstDay`·`_wasCoveredByFullScreen`, 서버 `cfg`·`req`·`val`·`vals`·`uuidStr`·`memberUuidStr`·`groupIdx`, 웹 `prevOverflow`·`idx`·`el`·`res`·`btnRef`·`checkBtnClass`·`statusMsg` 등.

## 재현 조건
해당 없음 (코드 정리 이슈).

## 조사 기록
- 2026-10-24: 범위 — 컴파일러·타입 검사로 확인 가능한 지역 이름만 바꾸고, 계약 이름·프레임워크 시그니처·관용 표현·테스트 코드는 바꾸지 않음. 동작 변경 없음.
- 2026-10-24: 완료 리포트(PR #643, 19개 파일).

## 근본 원인
이름 규칙에 어긋나는 약어 지역 이름이 쓰이고 있었다. 생긴 경위는 원본에 적혀 있지 않다.
