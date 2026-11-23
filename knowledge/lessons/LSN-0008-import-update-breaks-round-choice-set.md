---
type: lesson
id: LSN-0008
created: 2026-11-23
reviewed: null
topics: [question-bank, admin]
trigger: "관리자 문제 가져오기로 회차(모의고사·기출)에 들어간 기존 문항을 갱신할 때, 또는 회차 공개 검사가 '보기 세트가 출제 기준 미달'로 실패할 때"
status: active
source: "ISS-0547 (2026-11-18 #1155 작업 세션)"
supersedes: null
superseded_by: null
related: ["[[ISS-0547-past-exam-real-exam-level-rewrite]]", "[[DEC-0351-choice-order-fixed-and-round-choice-set-repoint]]"]
---

# LSN-0008: 문항 갱신 뒤에는 회차 공개 검사까지 보고, 그림·표·조합 보기 글은 번호로 시작하게 쓴다

- 가져오기 갱신은 새 고정 보기 세트를 만들고 옛 세트를 DISABLED 로 바꾼다. v1.144.0 부터 서버가 회차 문항을 자동 재연결하지만, 그 전 버전이거나 다른 경로로 세트를 바꿨다면 공개 검사(`/admin/api/mock-exams/rounds/{uuid}/publish-check`)로 꼭 확인한다.
- 수동 복구가 필요하면 회차 문항 `choice_set_uuid` 를 같은 문제의 최신 ADMIN_CURATED OK 세트로 바꾸고, 바꾸기 전 행을 백업한다.
- 학습 모드는 보기를 섞는다. 그림·결과 표 보기 글이 "그림 ②"처럼 번호가 뒤에 있으면 섞여서 그림 번호와 자리가 어긋난다. "② 그림"처럼 번호로 시작하게 쓴다.
- 시뮬레이터의 스토어 캡처용 빌드(가짜 세션)는 API 가 401 이라 실측에 쓸 수 없다. `flutter run` 실제 빌드로 확인한다.
