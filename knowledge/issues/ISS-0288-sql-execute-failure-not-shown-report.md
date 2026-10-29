---
type: completion-report
id: ISS-0288
created: 2026-10-15
topics: [practice]
status: resolved
resolves: "[[ISS-0288-sql-execute-failure-not-shown]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/482"
---

# ISS-0288 완료 리포트: `ExecuteFailureCard`와 제출 실패 `AppException` 문구

GitHub #482 구현 보고서 댓글 기준 (1차 통합본).

## 해결 방법
- 실행 실패 사유를 상태(`executeFailure`)에 담고 `ExecuteFailureCard`(사유 문구, 다시 시도) 표시.
- 제출 실패는 `AppException`을 던지고 화면은 `exception.message`를 토스트로 표시.
- 문구는 기존 ErrorCode 매핑 사용(예: `SANDBOX_TIMEOUT` > "쿼리 실행 시간이 초과되었어요.").
- 검증: 실행 실패·다시 시도·제출 실패 문구 테스트 추가, `flutter analyze` 경고 0, `flutter test` 271개 통과.

## 근본 원인 (확정)
이슈 본문과 같음 (실패 상태를 화면에 전달하지 않음, 예외를 null로 삼킴).

## 재발 방지
주의(원본): 실패 카드는 화면 아래쪽에 있어 처음에는 제출 바에 일부가 가려지고 스크롤하면 보인다.

## 교훈
(원본에 없음, 볼트 정리) 실패를 null로 바꾸는 catch는 원인별 안내를 없앤다. 예외를 화면까지 전달한다.
