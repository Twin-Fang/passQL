---
type: issue
id: ISS-0220
created: 2026-10-07
topics: [home, progress-stats]
symptoms: ["서버 연결 실패", "빈 데이터로 표시", "0문제 · 0% · 0일", "아직 학습 데이터가 없습니다", safeCall, "다시 시도 버튼 없음"]
root_cause: "홈·통계 Provider가 각 API를 `safeCall`로 감싸 실패를 null로 바꾸고, 전부 실패해도 빈 데이터로 화면을 그렸다"
status: resolved
resolution: "[[ISS-0220-app-offline-shows-empty-data-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/375"
---

# ISS-0220: 서버 연결 실패 시 앱 홈·통계가 오류 대신 빈 데이터로 보임

GitHub #375 (원본: 이슈 본문과 댓글 2개).

## 증상
서버에 닿지 않을 때 홈과 통계가 오류 대신 "빈 데이터"처럼 보여 기록이 사라졌다고 오해할 수 있다.
- 홈: 인사말 없음, "오늘의 세트를 준비 중이에요", "선택된 일정 없음", 빈 달력
- 통계: "0문제 · 0% · 0일", "아직 학습 데이터가 없습니다"
- 문제: "토픽을 불러올 수 없어요" — 다시 시도 버튼 없음
- 설정: "정보를 불러오지 못했습니다 · 다시 시도" — 정상(기준)

## 재현 조건
QA GitHub #357 영역 9, iPhone 16 Pro. 서버 주소를 닿지 않는 주소로 바꾼 디버그 빌드(로컬 `.env`만 임시 변경 후 복구).

## 조사 기록
- 2026-10-07: 이슈 본문에 원인 기록(아래).

## 근본 원인
홈·통계 Provider가 각 API를 `safeCall`로 감싸 실패를 null로 바꾸고, 전부 실패해도 빈 데이터로 화면을 그린다.
