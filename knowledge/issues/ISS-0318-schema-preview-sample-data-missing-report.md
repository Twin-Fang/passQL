---
type: completion-report
id: ISS-0318
created: 2026-10-18
topics: [practice]
status: resolved
resolves: "[[ISS-0318-schema-preview-sample-data-missing]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/520"
---

# ISS-0318 완료 리포트: 서버 `SchemaPreviewParser`가 `schemaTables`를 내려주고 앱·웹이 지문 아래 기본 펼침 테이블로 표시

GitHub #520 개요 댓글 기준 (2026-10-18).

## 해결 방법
- 서버 `SchemaPreviewParser`: DDL(컬럼 이름·타입, PK·FK)과 샘플 INSERT(여러 행 VALUES, 컬럼 목록, 따옴표 안 구분자, `''` 이스케이프, NULL, `DATE '...'`) 해석. 해석 못 하는 문장은 건너뛰고 예외를 던지지 않음. 테이블당 샘플 최대 50행.
- 문제 상세 응답에 `schemaTables` 추가. 기존 문자열 필드는 배포된 앱을 위해 유지.
- 앱·웹 같은 구조: "테이블 N개" 영역 지문 아래 기본 펼침, 테이블별 컬럼·PK·FK, 샘플 5행 + "N행 더 보기", NULL 흐리게. 해석 결과가 비면 원문 코드 블록.
- 검증: 운영 활성 206문제 중 DDL 126, 샘플 124개. `INSERT ... SELECT`는 1건(원문 폴백). 운영 웹에서 `SALES` 테이블 표시 확인.

## 근본 원인 (확정)
이슈 노트 참조. "눌러도 안 펼쳐짐"의 누름 효과 원인은 확정되지 않았다.

## 재발 방지
- 구버전 앱(1.13.1 이하)은 서버 배포만으로 바뀌지 않는다.
- MySQL식 백슬래시 이스케이프(`\'`)와 `INSERT ... SELECT`는 해석하지 않고 원문으로 보여 준다.

## 교훈
(원본에 없음, 볼트 정리) SQL 텍스트 해석을 클라이언트 정규식에 맡기면 따옴표·NULL 같은 경계에서 깨진다 — 서버에서 한 번 구조화해 내려준다.
