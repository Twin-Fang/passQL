---
type: issue
id: ISS-0318
created: 2026-10-17
topics: [practice]
symptoms: [스키마 보기 안 펼쳐짐, 샘플 데이터 안 보임, schema_section.dart, ExpansionTile 접힘, schemaSampleData, 웹 정규식 파싱 오류]
root_cause: "앱은 샘플 데이터 값을 그리는 코드가 없고 기본 접힘이었으며, 웹은 정규식 파싱으로 따옴표 안 구분자·컬럼 목록·NULL을 잘못 읽음"
status: resolved
resolution: "[[ISS-0318-schema-preview-sample-data-missing-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/520"
---

# ISS-0318: 문제 화면 스키마 보기가 펼쳐지지 않고 샘플 데이터가 보이지 않음

GitHub #520 (원본: 이슈 본문과 댓글).

## 증상
문제 풀이 화면의 "스키마 보기"를 눌러도 펼쳐지지 않는다(iOS 1.13.1, 정답 제출 후 상태). 문제에 딸린 샘플 데이터가 화면 어디에도 보이지 않는다. SQL 실행형 문제는 테이블 구조와 데이터를 봐야 풀 수 있다.

## 재현 조건
앱 > 문제 탭 > SELECT 기본 진입 → "스키마 보기" 누름 → 펼쳐지지 않고 샘플 데이터 영역 없음. iPhone 시뮬레이터 iOS 18.3, passQL 1.13.1.

## 조사 기록
- 2026-10-17: 실측 캡처.
- 2026-10-18: 서버 파서 + 앱·웹 테이블 영역으로 수정.

## 근본 원인
- 앱 `schema_section.dart`는 `schemaSampleData`가 있으면 "샘플 데이터" 글자만 그리고 값을 그리지 않았다. `ExpansionTile` 기본값이 접힘이었다.
- 앱 테마가 누름 효과를 모두 꺼 눌러도 반응이 보이지 않았다 — "안 펼쳐짐"의 의심 원인이지만 확정하지 못했다(원본).
- 웹은 정규식으로 해석해 따옴표 안의 쉼표·괄호, 컬럼 목록이 있는 INSERT, NULL을 잘못 읽었다.
