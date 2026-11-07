---
type: completion-report
id: ISS-0477
created: 2026-11-07
topics: [progress-stats, design-system]
status: resolved
resolves: "[[ISS-0477-stats-radar-default-study-pattern]]"
related: ["[[DEC-0274-stats-radar-above-list-study-pattern-free]]"]
source: "https://github.com/Twin-Fang/passQL/issues/909"
---

# ISS-0477 완료 리포트: 그래프 위 목록 아래(토글 없음), 학습 패턴 API(무료)와 정답률 상세 API(프로), PassqlBarChart

GitHub #909 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/909#issuecomment-6702224931). PR #915 머지, 배포 전. 원본 사본: `_sources/issues/ISS-0477-stats-radar-default-study-pattern-report.md`(로컬).

## 해결 방법
- 서버: `GET /progress/study-pattern`(무료: 최근 4주 날짜별 풀이와 정답, 앞뒤 2주 정답률 변화, 최근 12주 요일과 시간대 분포와 가장 많은 칸(10문제 미만이면 판정 없음), 학습일 수, 최장 연속). `GET /progress/accuracy-detail`(프로 `TOPIC_ANALYSIS`: 난이도별 정답률(문제별 마지막 시도), 틀린 문제와 다시 맞힌 문제 수, 최근 8주 주별 남은 오답). 순수 계산기 `StudyPatternCalculator`, `AccuracyDetailCalculator`, `StreakCalculator.calculateLongest` + 최소 단위 테스트.
- 앱: 영역별 정답률 토글 제거, 차트(위) + 목록(아래, 정렬 토글은 목록 바로 위), 판정 기간 최근 7일 표기. 새 구간 최근 4주 학습, 공부하는 시간, 난이도별 정답률(프로), 오답 정리(프로), 모의고사 점수 추이(프로, 기록 있을 때만). 디자인 시스템 `PassqlBarChart`(라이브러리 없이 토큰 색, 동작 줄이기, 스크린리더 한 문장).
- 웹: recharts로 같은 구간(모의고사 추이 제외), 무료 잠금 미리보기, `gen:api`.
- [[DEC-0274-stats-radar-above-list-study-pattern-free]].

## 검증
- 서버 128개 실패 0(계산기 7개), 앱 `flutter test` 123개, 웹 lint와 31개, `tsc` 통과, 코드 점검 새 위반 0.
- 데이터 많음, 적음, 없음, 무료 잠금, 라이트, 다크 캡처. 캡처 중 막대 옅은 부분 누락, 축 글자, 다크 바탕, 잠금 칸 겹침, 문구를 고침.

## 근본 원인 (확정)
해당 없음 (기능 개선).

## 재발 방지
- 판정(앞뒤 2주 비교, 가장 많은 요일과 시간, 10문제 미만 판정 없음)은 서버 계산기에만. 클라이언트에서 다시 계산하지 않는다.
- 정답률 상세 무료와 프로 구분은 서버 `TOPIC_ANALYSIS` 판정.

## 남은 일
- 웹 통계에 모의고사 점수 추이 없음(앱만), 모의고사 화면 막대 차트는 옛 구현.
- 배포 뒤 실측은 후속 댓글.

## 교훈
통계 화면을 늘릴 때 판정 문구(좋아짐, 가장 많은 시간 등)를 서버 계산기에 두면 앱과 웹이 보여 주기만 해서 기준이 갈라지지 않는다.
