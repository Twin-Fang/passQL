---
type: completion-report
id: ISS-0212
created: 2026-10-07
topics: [design-system]
status: resolved
resolves: "[[ISS-0212-bottom-tab-icons-only]]"
related: ["[[DEC-0101-bottom-tab-icons-only]]"]
source: "https://github.com/Twin-Fang/passQL/issues/367"
---

# ISS-0212 완료 리포트: 탭 라벨 숨김, 아이콘 22, 접근성 라벨·툴팁 유지

GitHub #367 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
`BottomNavigationBar`의 선택/비선택 라벨 숨김, 아이콘 크기 22로 키움. 접근성(스크린리더)용 라벨과 `tooltip`은 유지.

## 근본 원인 (확정)
해당 없음 (기능개선).

## 재발 방지
위젯 테스트 통과, `flutter analyze` 이슈 없음.

## 교훈
(원본에 없음, 볼트 정리) 화면에서 라벨을 숨겨도 접근성 라벨·툴팁은 남긴다.
