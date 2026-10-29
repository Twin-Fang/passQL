---
type: issue
id: ISS-0358
created: 2026-10-22
topics: [concept-learning, billing]
symptoms: ["개념 학습", "수험서 대체", "단원별 개념 설명 없음", concept_tag, concept_doc, concept.is_published, "확인 문제", "개념 탭", "무료 1·2단원", PRO_REQUIRED]
root_cause: ""
status: open
resolution: null
related: ["[[DEC-0004-free-pro-feature-boundary]]", "[[DEC-0005-ship-with-billing-switch-off]]", "[[DEC-0171-four-tabs-merge-stats-my-profile]]"]
source: "https://github.com/Twin-Fang/passQL/issues/577"
---

# ISS-0358: 단원별 개념 학습 (수험서 대체)

GitHub #577 (원본: 이슈 본문과 댓글, 2026-10-27까지). 열린 이슈.

## 증상
기능 이슈. 현재 문제점:
- passQL의 목표는 SQLD 수험서를 완전히 대체하는 모바일 플랫폼인데 책의 단원별 개념 설명이 없다.
- 개념 설명이 없으면 수험생이 책을 따로 사야 해 "책 살 돈으로 passQL을 결제한다"는 수익 구조(GitHub #576)가 성립하지 않는다.
- 결제 켜기(#576 결제 스위치)는 이 작업이 끝난 뒤로 정했다 — [[DEC-0005-ship-with-billing-switch-off]].

## 재현 조건
해당 없음.

## 조사 기록
- 2026-10-23 설계 브레인스토밍, 운영 DB 실측(읽기 전용): `concept_tag`·`concept_doc`·`question_concept_tag`·`subtopic` 0행, `question` 374 → 개념 데이터는 처음부터 만든다.
- 2026-10-23 사용자 결정: 개념 학습 화면에는 SQL 실행 기능을 넣지 않는다("실행을 굳이?? 이건 하지마"). 이슈 본문의 "가능하면 예시를 바로 실행"은 폐기.
- 2026-10-23 Claude 판단 후 사용자 확정("그렇게 해봐"): AI 초안 + 관리자 검수 후 공개(수험서 문장·예제 복제 금지, 런타임 AI 생성 안 함), `concept_tag` 1개 = 개념 화면 1개(단원 topic 직접 연결, `subtopic` 미사용), 개념당 쉬운 확인 문제 5개 신규, 진행 기록 서버 저장, 무료 1·2단원·3~9단원 프로 블러 잠금, 하단 탭 `개념` 신설.
- 2026-10-24 사용자 결정들: 확인 문제 결과는 `member_concept_progress`에만(기록·오답 노트·무료 하루 10문제 한도·출제 경향에 반영 안 함), 무료 범위 1·2단원 재확인("1,2단원만", `app_setting` 무료 단원 수 = 2), 단원별 순차 공개 없이 전체 완성 후 한 번에 공개하고 결제 켜기와 시점을 맞춤("그냥 공개하지마", Claude 해석), 하단 탭 6개 결정 후 정정 — 기록+MY 합쳐 `내 프로필`, 최종 홈 / 개념 / 문제 / 토론 / 내 프로필(사용자: 하단 네비게이션 바를 더 늘리기 애매함). 시안 v4(평평한 앱 스타일) 확정, 바텀시트 X 없음·제목 가운데로 체크리스트 정정.
- 2026-10-27 1단계(PR #679, 배포): `V1_59_0` — `concept_tag`에 단원·공개 상태·요약, `concept_doc` 핵심만/자세히(`## 제목 {#앵커}`), 확인 문제·진행 테이블, 설정 3개(공개 스위치 `concept.is_published` 기본 꺼짐, 무료 단원 수 2, 초안 미리보기 회원 목록). 회원 API `/api/concepts`, 관리자 `/admin/concepts/learning`. 확인 문제는 기존 문제 테이블이 아닌 전용 테이블(설계 문서와 다르게 — 랜덤·오늘의 문제·실전·추천·하루 한도 등 12곳 넘는 조회에 제외 조건을 넣어야 하는 위험 때문).
- 2026-10-27 2단계(PR #682): 앱 개념 탭(서버가 이용 가능하다고 답할 때만 보임), 단원 상세, 읽기/풀기·핵심만/자세히 전환, `PassqlProgressRing`, 코드 글꼴 한글 대체 Pretendard.
- 2026-10-27 3단계(PR #698): 개념 63개·확인 문제 315개(`content/concepts/`), Oracle 21c 실행 검증 63/63(2,209문장), 초보자 검증 315문제 중 312 정답, 운영 문제 309개를 개념에 연결(`related_questions.json`, 연결 430개), 개념 결과 화면 "실전 문제 N개 더 풀기". 시뮬레이터 실측(PR #702)·63개 전수 점검(PR #713)으로 표·코드 줄바꿈 결함 정리.
- 2026-10-27 배포 1.65.1: 서버·AI·웹 UP, Android 1.65.1 production 승급·심사 등록, iOS 1.65.1 심사 대기. 개념 탭은 공개 스위치가 꺼져 일반 회원에게 보이지 않음.
- 남은 일: 공개 스위치와 결제 켜기 시점은 사용자 결정 후.

## 근본 원인
해당 없음(기능 개발 진행 중).
