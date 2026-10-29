---
type: decision
id: DEC-0101
created: 2026-10-07
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0212-bottom-tab-icons-only]]", "[[ISS-0212-bottom-tab-icons-only-report]]"]
---

# DEC-0101: 앱 하단 탭 바는 글자 없이 아이콘만 표시 (접근성 라벨·툴팁은 유지)

## 문제 정의 (Context)
앱 하단 탭 바에 "홈", "문제", "통계", "설정" 글자가 있었다. 사용자 요청으로 글자를 없앤다 (GitHub #367, QA #357 영역 9).

## 결정 (Decision)
- `AppShell`의 `BottomNavigationBar`에서 선택/비선택 라벨을 숨기고 아이콘만 표시한다. 아이콘 크기는 22로 키운다.
- 스크린리더용 라벨과 `tooltip`은 유지한다.

## 검토한 대안 (Alternatives)
논의 기록 없음. 이유로 적힌 것은 사용자 요청의 "아이콘만으로 충분히 구분되고 화면이 더 깔끔해진다"뿐이다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음 (기대 효과는 위 사용자 요청 문장).

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
앱 `AppShell` 하단 탭 바의 라벨 표시. 원본은 라벨만 다루며 탭 구성이나 웹 하단 탭에 대한 언급은 없다.

## 출처 (References)
- GitHub #367 이슈 본문 「개요」「작업 범위」, 완료 댓글(2026-10-07)
