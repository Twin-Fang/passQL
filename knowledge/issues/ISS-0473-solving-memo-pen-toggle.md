---
type: issue
id: ISS-0473
created: 2026-11-07
topics: [practice, design-system]
symptoms: ["풀이 화면 메모", "지문에 동그라미 보기에 X", "펜 버튼 켜고 끄기", "메모 끄면 보기 선택 그대로", "메모 켜면 스크롤 멈춤", PassqlMemoScope, PassqlMemoCanvas, SolvingMemoBoard, useSolvingMemo]
root_cause: "기능 요청: 풀이 화면 안에 끄적일 방법이 없었고, 기기 화면 메모는 앱 밖 기능이라 풀이 흐름이 끊겼다"
status: resolved
resolution: "[[ISS-0473-solving-memo-pen-toggle-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/904"
---

# ISS-0473: 풀이 화면 메모: 켜고 끄는 펜, 끄면 보기 선택 그대로

GitHub #904 (https://github.com/Twin-Fang/passQL/issues/904). 기능 추가. 원본 사본: `_sources/issues/ISS-0473-solving-memo-pen-toggle.md`(로컬).

## 증상
문제를 풀면서 지문에 동그라미를 치거나 보기에 X를 그어 볼 방법이 없음. 종이 시험처럼 끄적이며 풀고 싶다는 요청. 기기 화면 메모(마크업)는 기능이 너무 많고 앱 밖이라 풀이 흐름이 끊김.

## 재현 조건
해당 없음 (기능 요청). 요구 기준: 메모를 끈 상태에서 기존 동작(보기 탭, 스크롤, 이전과 다음, 번호판)이 하나라도 달라지면 실패.

## 조사 기록
- 2026-11-07: 앱(e1eb206f), 웹(7ba2bd85) 구현, PR #910 머지.

## 근본 원인
해당 없음 (기능 요청).
