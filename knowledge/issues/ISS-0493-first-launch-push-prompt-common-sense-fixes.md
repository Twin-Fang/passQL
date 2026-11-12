---
type: issue
id: ISS-0493
created: 2026-11-12
topics: [notification, home, practice]
symptoms: ["알림 허용을 처음에 안 물어봄", "1번째 문제 3번째 문제", "결과 화면 번호만 있음", "크레딧을 다 썼어요 다음에 할 일", "홈에서 광고 권유", "모의고사 무료 1회가 안 보임", "세트 보너스 이름이 제각각"]
root_cause: "알림 권한 안내가 첫 실행 흐름에 연결되지 않았고, 결과 화면 3종이 번호뿐인 목록을 각자 만들었으며, 크레딧 0일 때 홈 다음 할 일이 광고 권유로만 갈라졌다"
status: resolved
resolution: "[[ISS-0493-first-launch-push-prompt-common-sense-fixes-report]]"
related: ["[[ISS-0491-first-run-guide-home-next-step]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]"]
source: "https://github.com/Twin-Fang/passQL/issues/980"
---

# ISS-0493: 처음 켤 때 알림 허용 안내와 상식적으로 어색한 화면

GitHub #980.

## 증상
- 앱을 처음 켜도 알림 허용을 묻지 않음.
- 오늘의 세트·랜덤 풀이·단원 결과 화면에 「1번째 문제 · 3번째 문제」처럼 번호만 나열.
- 크레딧을 다 쓴 날 홈 「다음에 할 일」이 "오늘 크레딧을 다 썼어요" 광고 권유로 뜸.
- 모의고사 무료 1회가 홈·무료 문제 탭에서 보이지 않아 랜덤 풀기만 보임.
- 세트 보너스 이름, 모의고사 안내 문구, 토스트 말투가 화면마다 다름.

## 재현 조건
새로 설치한 앱, 무료 회원, 크레딧 0인 날.

## 근본 원인
알림 안내가 첫 실행 흐름에 없었고, 결과 목록이 3곳에서 따로 만들어졌으며, 홈 다음 할 일 판정에 모의고사 무료 분기가 없었다.
