---
type: issue
id: ISS-0471
created: 2026-11-07
topics: [practice]
symptoms: ["풀이 중 모의고사 다시 들어가면 시작 안내", "시작하면 90분 타이머가 바로 돌아가요", "이어서 풀기 대신 시작하기", "canStart true 풀이 중 회차", "모의고사 회차 목록 풀이 중", mock_exam_guide_page.dart, mock_exam_round_list_page.dart]
root_cause: "서버가 풀이 중 회차에도 canStart true 를 주는데, 앱 회차 목록은 canStart 만 보고 안내 화면으로 보냈고 안내 화면은 진행 여부와 관계없이 시작 안내만 그렸다"
status: resolved
resolution: "[[ISS-0471-mock-exam-resume-shows-start-guide-report]]"
related: ["[[ISS-0463-sqld-mock-exam]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]"]
source: "https://github.com/Twin-Fang/passQL/issues/902"
---

# ISS-0471: 풀이 중인 모의고사 회차에 다시 들어가면 90분 시작 안내가 뜸

GitHub #902 (https://github.com/Twin-Fang/passQL/issues/902). 실기기 사용자 제보. 모의고사 자체는 [[ISS-0463-sqld-mock-exam]], [[DEC-0264-mock-exam-fixed-rounds-server-judged]]. 원본 사본: `_sources/issues/ISS-0471-mock-exam-resume-shows-start-guide.md`(로컬).

## 증상
이미 시작해 타이머가 흐르는 모의고사에 다시 들어가면 안내 화면이 "시작하기" 버튼과 "시작하면 90분 타이머가 바로 돌아가요" 확인 창을 띄움. 실제로는 서버 기준 남은 시간으로 이어서 풀리지만 화면은 처음부터 90분인 것처럼 안내.

## 재현 조건
모의고사 회차 시작 > 몇 문항 풀고 나가기 > 문제 탭 > 회차 목록 > 같은 회차("풀이 중") 누르기 > 안내 화면 "시작하기". 홈의 "이어서 풀기" 줄은 바로 풀이로 가서 문제없음.

## 조사 기록
- 2026-11-07: 이슈 본문에서 원인 확인, PR #906으로 앱만 수정 (웹은 이미 이어 풀기로 동작).

## 근본 원인
서버가 풀이 중 회차에도 `canStart: true`를 준다. 앱 회차 목록은 `canStart`만 보고 안내 화면으로 보냈고, 안내 화면은 진행 여부를 보지 않았다.
