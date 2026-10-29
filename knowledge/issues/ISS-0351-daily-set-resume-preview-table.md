---
type: issue
id: ISS-0351
created: 2026-10-21
topics: [practice]
symptoms: ["이어 풀기", "앱 재실행 진행 사라짐", "1/10부터 다시", "미리보기 파이프 원문", stripCodeFences, "오답 노트 미리보기", "[EMP] | ID"]
root_cause: "오늘의 세트 진행 복원 기능이 없었고, 목록 미리보기 정리가 마크다운 표를 처리하지 않았다"
status: resolved
resolution: "[[ISS-0351-daily-set-resume-preview-table-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/566"
---

# ISS-0351: 오늘의 세트 앱 재실행 시 이어 풀기, 목록 미리보기의 표 원문 정리

GitHub #566 (원본: 이슈 본문과 댓글).

## 증상
- 오늘의 세트를 풀다가 앱을 다시 켜면 진행이 사라지고 1/10부터 다시 시작한다(점수 공정성은 GitHub #561로 서버에서 해결, 진행 복원은 없음).
- 오답 노트·목록 미리보기에 지문 마크다운 표가 `[EMP] | ID | DEPT_ID ...`처럼 파이프 원문으로 보인다(GitHub #550은 지문 본문만 해결).

## 재현 조건
오늘의 세트 몇 문제 제출 후 앱 재실행. 표가 든 지문의 문제가 오답 노트·목록에 있을 때.

## 조사 기록
- 2026-10-21 제안: 이어 풀기는 서버 오늘 제출 기록 활용, 미리보기는 목록용 정리 함수(`stripCodeFences`)에서 표 줄을 걷어 내거나 짧게.

## 근본 원인
기능 부재(진행 복원)와 미리보기 정리 범위 누락(표).
