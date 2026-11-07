---
type: completion-report
id: ISS-0412
created: 2026-11-07
topics: [ai, practice]
status: resolved
resolves: "[[ISS-0412-ai-explanation-quality-cost-optimization]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/699"
---

# ISS-0412 완료 리포트: 고정 세트 구조화 해설 공유, 백필과 미리 생성 범위 축소, 연결 실패만 재시도, 토큰 기록, '결과가 다른 것' 전용 프롬프트, 해설 시트 닫기 X 제거

GitHub #699 리포트 댓글 기준 (2026-11-07, https://github.com/Twin-Fang/passQL/issues/699#issuecomment-6702514613) + 배포 후 실측 댓글(2026-11-07). 구현 상세는 2026-10-27 구현 보고서 댓글. 이슈 닫힘. 원본 사본: `_sources/issues/ISS-0412-ai-explanation-quality-cost-optimization-report.md`(로컬).

## 해결 방법
- 관리자 고정 세트도 세트당 1회 구조화 해설을 만들어 모든 사용자가 공유, 생성 전에는 검증된 메모 표시 (`ChoiceExplanationService`).
- 백필과 미리 생성은 공용 세트(고정 세트, 문제별 최신 OK AI 세트)만. 실전 모드 1인용 세트는 처음 열 때 생성.
- 내 정보 AI 리뷰 캐시 키 `날짜 + 갱신 구간`(프로 10문제 단위, 무료 하루 1회), TTL 24시간.
- `AiServerRetryPredicate`: 연결 실패만 재시도, 서버 응답 오류와 읽기 시간 초과는 재호출 안 함.
- AI 서버 `token_usage.py`로 토큰 사용량 반환, 추천과 색인 호출은 `AiCallSource.VECTOR_SEARCH`로 LLM 통계에서 분리.
- '결과가 다른 것'(ODD_ONE_OUT): 전용 프롬프트 `generate_choice_set_odd_one_out`(`V1_63_2`, `V1_63_3`), 검증은 행 값만 비교.
- 앱 `AiExplanationDock` 닫기 X 제거(끌어 내려 접고 닫음), `*_sheet.dart`, `*_dock.dart` X 금지 규칙 테스트.
- 배포: PR #703, #707, #709, #712 (2026-10-27), v1.66.1부터 앱 포함.

## 검증
- 서버 아키텍처와 계약 테스트 18개, AI 서버 테스트 46개, 앱 analyze 0과 테스트 48개.
- 운영 백필 13개 READY, AI 서버 경유 토큰 기록(입력 995, 출력 615), '결과가 다른 것' 수정 전 9회 전부 실패 > 수정 뒤 4회 중 4회 통과.
- 배포 후 실측(2026-11-07, 1.88.0 main 빌드 시뮬레이터, 운영 서버): 연습 제출 뒤 AI 해설 한 줄 요약 접힘, 전체 보기 시트에 정답 근거와 시험 팁(라이트).

## 근본 원인 (확정)
이슈 노트 frontmatter `root_cause`와 같음 (구현 보고서 「원인」 표).

## 재발 방지
- `ChoiceSetExplanationPrompt.PROMPT_VERSION`을 올리면 공용 세트 해설(약 260개)이 전부 다시 생성된다. 문구만 다듬을 때는 버전 유지 여부를 먼저 판단한다.
- AI 서버 `@Retry` 판정을 바꾸면 같은 LLM 호출이 중복 과금될 수 있다.
- ODD_ONE_OUT 전용 프롬프트와 GitHub #704 유형 지시는 함께 동작한다. 한쪽만 되돌리면 성공률이 달라진다.

## 남은 일
- 이후 변경: 무료 개방했던 통계 AI 리뷰는 GitHub #860(커밋 `32745077`)에서 결과 화면과 통계 모두 프로 전용으로 다시 묶였다. 현재 기준은 #860.
- 해설 시트 다크 모드 캡처는 없음.

## 교훈
비용이 사용자 수에 비례해 늘면 캐시 키에 사용자 행동 값(풀이 수 해시 등)이 들어가 있는지, 재시도가 두 층에서 겹치는지부터 본다.
