---
type: completion-report
id: ISS-0462
created: 2026-11-07
topics: [practice, billing]
status: resolved
resolves: "[[ISS-0462-web-wrong-notes-page-404]]"
related: ["[[ISS-0460-ai-analysis-forecast-concept-links-report]]"]
source: "_sources/issues/ISS-0462-web-wrong-notes-page-404-report.md"
---

# ISS-0462 완료 리포트: 웹 오답 노트 화면 추가, 프로 접근 거부 사유 창, 제출 실패 오답 기록 수정

GitHub #865 리포트 기준 (2026-11-07). 운영 배포 릴리스 #886 (Vercel).

## 해결 방법
- 웹 오답 노트 `/mypage/wrong-questions`: 최근 오답 20개, 행마다 "다시 풀기". 로딩·빈 목록·오류·무료 잠금 상태. 마이페이지 "전체보기"와 통계 AI 분석 "오답 노트에서 다시 풀기"가 이 화면으로 연결.
- 사유 창 `ProAccessReasonModal`: 하루 한도·프로 필요·공정 사용 한도일 때 사유, 다시 열리는 시각, 앱 이용권 안내. AI문제·출제 경향·통계 세 곳의 토픽 연습 시작이 `useStartTopicPractice` 결과 4종을 처리.
- 제출 실패: 기록하지 않고 같은 문제에 머묾, 일반 실패는 토스트 후 다시 제출 가능.
- ESC 닫기를 `useCloseOnEscape` 훅으로 모음, 라우트 없는 죽은 페이지 `Questions.tsx` 와 전용 훅 삭제.

## 검증
- tsc 통과, lint 오류 0, vitest 8개·아키텍처 규칙 3개 통과. 로컬 vite + 가짜 API 로 데스크톱·모바일·잠금·빈 목록·오류·사유 창 확인.

## 근본 원인 (확정)
웹 오답 노트 화면이 없었다. 제출 실패를 오답으로 기록하던 처리와 403 무반응은 별도 웹 버그.

## 재발 방지
- 프로 접근 거부는 사유 창 하나로 안내한다 (토픽 연습 시작 결과 4종 공통 처리).

## 알고 남긴 것
- 웹은 다크 모드가 없어 라이트만 확인.
- 오답을 모아서 푸는 세트는 앱과 같게 두어 만들지 않음.

## 교훈
링크를 먼저 만들 때는 대상 라우트가 있는지 확인한다. 실패 응답을 오답으로 해석하는 분기는 채점 결과와 전송 실패를 구분하는지 본다.
