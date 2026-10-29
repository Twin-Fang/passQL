---
type: issue
id: ISS-0116
created: 2026-04-13
topics: [community, design-system]
symptoms: ["설정 탭 무거움", FeedbackForm, FeedbackList, "/settings/feedback", SubpageLayout, "레이아웃 콜랩스", "div onClick 접근성", bg-accent-light]
root_cause: "설정 탭이 건의사항 입력 폼·목록을 직접 펼쳐 기능 페이지 역할을 겸하고 있었다"
status: resolved
resolution: "[[ISS-0116-feedback-settings-subpage-split-report]]"
related: ["[[DEC-0069-settings-tab-rows-only-subpages]]"]
source: "https://github.com/Twin-Fang/passQL/issues/209"
---

# ISS-0116: 건의사항을 설정 서브페이지로 분리

GitHub #209 (원본: 이슈 본문과 작업 리포트 댓글).

## 증상
설정 탭(`Settings.tsx`)에 `FeedbackForm`·`FeedbackList`가 풀 UI로 노출. 항목이 늘수록 탭이 무거워지고, iOS 설정 앱·토스 등 표준 모바일 패턴과 달리 설정 탭이 기능 페이지 역할을 겸한다(이슈 본문).

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-13: GitHub #200 댓글 "건의사항은 따로 페이지에서 관리해야될것같습니다" 이후 이슈 등록.
- 2026-04-13: 구현 중 `max-w-lg mx-auto` 콘텐츠가 명시적 width 없이 수축해 텍스트가 좁은 띠로 렌더링되는 버그 수정. GitHub #208이 먼저 머지되어 `App.tsx` 충돌 수동 해소.

## 근본 원인
설정 탭이 입력 폼을 직접 포함하는 구조.
