---
type: issue
id: ISS-0212
created: 2026-10-07
topics: [design-system]
symptoms: [하단 탭 글자, BottomNavigationBar 라벨, AppShell, 아이콘만 표시]
root_cause: "해당 없음 — 사용자 요청 기능개선 (하단 탭 글자 제거)"
status: resolved
resolution: "[[ISS-0212-bottom-tab-icons-only-report]]"
related: ["[[DEC-0101-bottom-tab-icons-only]]"]
source: "https://github.com/Twin-Fang/passQL/issues/367"
---

# ISS-0212: 하단 탭 바 글자 제거 — 아이콘만 표시

GitHub #367 (원본: 이슈 본문과 댓글).

## 증상
하단 탭 바에 글자("홈", "문제", "통계", "설정")가 표시된다. 사용자 요청: 글자를 없애고 아이콘만 남긴다 — 아이콘만으로 충분히 구분되고 화면이 더 깔끔해진다.

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-07: 작업 범위 — `AppShell`의 `BottomNavigationBar` 선택/비선택 라벨 숨김, 접근성(스크린리더·롱프레스 툴팁) 라벨 유지, 아이콘 크기 키움.

## 근본 원인
해당 없음.
