---
type: issue
id: ISS-0412
created: 2026-10-27
topics: [ai, practice]
symptoms: ["해설 수준 차이", "관리자 선택지 세트 한 줄 메모", "메모 문장 잘림", "AI 해설 패널 닫기 X", "AI 호출 사용자 수 비례", "대시보드 비용 0", "모델 미기록", ODD_ONE_OUT, "결과가 다른 것 선택지 생성 실패"]
root_cause: "#511에서 고정 세트를 구조화 해설 생성·백필 대상에서 제외했고, AI 코멘트 캐시 키·해설 미리 생성 범위·재시도 중첩·토큰 미기록이 호출과 비용을 키웠다"
status: open
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/699"
---

# ISS-0412: AI 해설 품질, 호출 빈도, 비용 최적화와 해설 시트 정리

GitHub #699 (원본: 이슈 본문과 댓글). 이슈는 열려 있다(라벨 작업중).

## 증상
- 오늘의 문제에서 문제마다 해설 수준이 크게 다르다. AI 선택지 세트는 구조화 해설, 관리자 선택지 세트(212개)는 고른 보기의 한 줄 메모만, 일부는 문장이 잘림(예: "ENAME 은 공통 컬럼이 아니라 E. 허용.").
- AI 해설 패널에 닫기 X가 있어 공통 시트 규칙(손잡이·드래그로 닫기, X 없음)과 다르다. 커뮤니티 글쓰기 시트도 같다.
- AI 호출이 사용자 수·풀이 수에 비례: 내 정보 AI 리뷰 캐시 키에 최근 7일 풀이 수가 들어감(`AiCommentService`), 1인용 세트(실전 모드)까지 해설 미리 생성, 재시도 중첩.
- AI 서버 경유 호출의 토큰 미기록으로 대시보드 비용 0, 추천·색인 호출이 모델 '미기록' AI 호출로 섞임.

## 재현 조건
관리자 출제 고정 세트 문제를 풀고 해설 확인 / 관리자 대시보드 비용 확인.

## 조사 기록
- 2026-10-27 리포트(PR #703·#707·#709): 원인 표 — 고정 세트 제외(`ChoiceExplanationService.getChoiceExplanation`, `findChoiceSetUuidsNeedingExplanation`), 캐시 키 해시, `ChoiceExplanationPregenerationListener`, AI 서버 재시도 위에 Spring `@Retry`가 500·읽기 시간 초과까지 재호출, 토큰 미반환. 조사 중 '실행 결과가 나머지 셋과 다른 것' 유형 선택지 생성이 5월 이후 한 번도 성공하지 못한 문제 발견 — 프롬프트는 "같은 결과 1 + 다른 결과 3", 검증은 3:1, 검증이 컬럼 이름까지 비교(`ChoiceSetGenerationService`, `SandboxValidator.validateOddOneOut`).
- 변경: 고정 세트도 세트당 1회 구조화 해설 생성·공유(생성 전에는 검증된 메모 표시), 백필은 고정 세트·문제별 최신 OK AI 세트로 한정, 실전 모드 세트는 미리 생성 생략, AI 리뷰 캐시 키 `날짜 + 갱신 구간`(프로 10문제 단위, 무료 하루 1회), `AiServerRetryPredicate`로 연결 실패만 재시도, 추천·색인 경로를 `AiCallSource.VECTOR_SEARCH`로 분리, 전용 프롬프트 `generate_choice_set_odd_one_out`(`V1_63_2`, `V1_63_3`)와 행 값만 비교, AI 서버 `token_usage.py`, 앱 `AiExplanationDock` 닫기 X 제거와 `*_sheet.dart`·`*_dock.dart` X 금지 규칙 테스트.
- 검증 수치: '결과가 다른 것' 문제 수정 전 9회 모두 실패 > v1 3회 중 1회 > v2 4회 중 3회 > v2 + GitHub #704 유형 지시 4회 중 4회. 운영 백필 13개 READY, 세트당 입력 약 3천·출력 약 1천 토큰.
- 2026-10-27 후속 댓글(PR #712): `/api/progress/ai-comment` 프로 잠금 해제 — 통계 코멘트는 무료 하루 1회·프로 10문제마다, 결과 화면 세션 코멘트는 프로만(무료 403 `PRO_REQUIRED`). 결제가 꺼져 있어 무료 경로는 결제를 켠 뒤 확인 필요.
- 남은 일(리포트): 앱 실기기에서 시트 끌어 내려 닫기·라이트·다크 확인, 남은 고정 세트 백필(10분마다 6세트).

## 근본 원인
리포트 「원인」 표 참조 (위 조사 기록). 이슈가 열려 있어 최종 정리는 아직이다.
