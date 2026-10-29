---
type: issue
id: ISS-0167
created: 2026-04-27
topics: [ai, practice]
symptoms: [ChoiceSetResolver, "프리페치 미스", AI_RUNTIME, "선택지 생성 대기 60초", choiceGenerationMode, "연습 모드", "실전 모드", "status=OK 선택지 재사용"]
root_cause: "프리페치 미스 시 다른 사용자용으로 검증 완료(`status=OK`)된 선택지가 있어도 무조건 AI 실시간 생성을 수행"
status: resolved
resolution: null
related: ["[[DEC-0087-choice-generation-practice-real-mode]]"]
source: "https://github.com/Twin-Fang/passQL/issues/313"
---

# ISS-0167: 문제풀이 선택지 생성 모드를 연습/실전으로 분리

GitHub #313 (원본: 이슈 본문과 이미지만 있는 댓글 1개). 2026-04-27 생성·당일 닫힘, 라벨 `작업전`. 완료 내용(리포트·결과 댓글)은 원본에 없다.

## 증상
(현재 문제점) `ChoiceSetResolver`는 본인 대상 프리페치 선택지(`generatedForMemberUuid = 현재사용자`)만 캐시 히트로 인정한다. 미스 시 DB에 다른 사용자용 `status=OK` 선택지가 있어도 항상 AI 실시간 생성(`AI_RUNTIME`)을 하고, AI 호출 + 샌드박스 SQL 검증 최대 3회 반복으로 최대 60초 가까이 기다린다. 원본은 "선택지가 문제 특성상 개인화가 불필요함에도 재사용 가능한 선택지를 버리고 있다"고 적음.

## 재현 조건
해당 없음 (프리페치 미스 상황 전반).

## 조사 기록
- 2026-04-27 제안: 설정에 선택지 생성 모드 추가(`PRACTICE`/`REAL`), `ChoiceSetResolver` 모드 분기, 연습 모드 전용 조회 쿼리, `Settings.tsx` 토글, 클라이언트가 모드 값을 선택지 생성 API에 전달.
- 같은 날 이미지 댓글 1개, 닫힘. 구현 여부는 #313 원본에 적혀 있지 않다. (앱 쪽 GitHub #329가 서버 API `/members/me/settings/choice-generation-mode`와 `PRACTICE/REAL` 토글을 다룬다.)

## 근본 원인
리졸버가 다른 사용자용 검증 완료 선택지를 재사용 대상으로 보지 않는 구조.
