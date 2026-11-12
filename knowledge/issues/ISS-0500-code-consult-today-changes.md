---
type: issue
id: ISS-0500
created: 2026-11-12
topics: [dev-workflow]
symptoms: ["낡은 주석", "주석 재작성", "날짜 두 자리 복사", "문구 직접 작성"]
root_cause: "하루에 여러 에이전트가 278개 파일을 바꾸며 주석·문구·날짜 처리 사본이 생겼다"
status: resolved
resolution: "[[ISS-0500-code-consult-today-changes-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/1005"
---

# ISS-0500: 오늘 변경분 코드 점검 반영

GitHub #1005.

## 증상
code-consult diff 후보: 낡은 주석 94, 새 주석 문제 11, 주석 재작성 63, 이름 6.

## 근본 원인
병렬 에이전트 작업에서 공통 상수·포맷터를 확인하지 않고 직접 작성.
