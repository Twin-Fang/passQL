---
type: issue
id: ISS-0124
created: 2026-04-13
topics: [practice]
symptoms: [SchemaViewer, "테이블 찌그러짐", "칼럼명 잘림", "카드 경계 불분명", overflow-x-auto, Table2, "가로 나열"]
root_cause: "테이블 목록이 하나의 가로 스크롤 flex 컨테이너라 테이블이 많으면 min-w-0으로 줄어들고, 카드 배경이 없었다"
status: resolved
resolution: "[[ISS-0124-schema-viewer-table-layout-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/225"
---

# ISS-0124: SchemaViewer 테이블 레이아웃과 시각성 개선

GitHub #225 (원본: 이슈 본문, 리포트 댓글, 스크린샷 댓글).

## 증상
- 스키마 테이블 카드에 배경색이 없어 페이지 배경(`#FAFAFA`)에 묻힘.
- 테이블 목록이 `flex` 가로 나열이라 4개일 때 찌그러져 칼럼명이 잘리거나 겹침.
- 헤더에 테이블명만 있어 테이블이라는 식별이 어려움. 칼럼이 많으면 가로 스크롤이 없어 잘림.

## 재현 조건
테이블 여러 개(예: 4개) 또는 칼럼이 많은 문제의 스키마 영역.

## 조사 기록
- 2026-04-13: 이슈 등록과 수정. 같은 날 "개선되었습니다" 스크린샷 댓글.

## 근본 원인
테이블 목록 전체를 하나의 가로 스크롤 컨테이너에 넣는 구조 — 테이블이 4개면 각각 `min-w-0`으로 줄어 칼럼명이 잘렸다(리포트). 카드 배경색 누락.
