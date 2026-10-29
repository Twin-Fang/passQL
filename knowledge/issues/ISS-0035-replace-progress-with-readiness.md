---
type: issue
id: ISS-0035
created: 2026-04-10
topics: [progress-stats, home]
symptoms: ["진도율 오독", correctRate, "progress 바", "무제한 문제", "합격 준비도", Readiness, toneKey]
root_cause: "무제한 문제 생성 서비스라 진도율 개념이 성립하지 않는데 홈이 `correctRate`를 progress 바 width로 써 '전체 중 몇 % 완료'로 오독됐다"
status: resolved
resolution: "[[ISS-0035-replace-progress-with-readiness-report]]"
related: ["[[DEC-0033-readiness-replaces-progress-rate]]"]
source: "https://github.com/Twin-Fang/passQL/issues/52"
---

# ISS-0035: 홈 진도율을 합격 준비도(Readiness)로 대체

GitHub #52 (원본: 이슈 본문과 댓글).

## 증상
- passQL은 AI Agent가 무제한으로 문제를 생성하므로 "전체 N문제 중 M개 완료" 같은 진도율이 성립하지 않는다.
- 그런데 홈은 `correctRate`를 progress 바 width로 렌더링해(`client/src/pages/Home.tsx` line 81~84 부근) 사용자가 진도율로 오독했다.
- 사용자가 알고 싶은 것은 "나 지금 시험 치면 붙을 수 있어?"이고, SQLD/SQLP는 끝(시험일)이 있는 시험인데 홈 지표가 이를 반영하지 못했다.
- `GET /api/progress` 응답(`solvedCount`, `correctRate`, `streakDays`)만으로는 합격 근접도를 표현할 수 없었다.

## 재현 조건
홈 화면의 progress 바 (이슈 본문).

## 조사 기록
- 2026-04-10: `@suh-lab server build` 호출 2회, 프론트 담당에게 수정·확인 요청.
- 2026-04-10: 프론트 구현 보고 댓글 (아래 리포트), "완료했습니다" 댓글.
- 백엔드 구현 완료 보고 댓글은 없다 (백엔드 작업 항목은 이슈 본문에만 있음).

## 근본 원인
진도율을 전제로 한 지표를 무제한 문제 환경에 그대로 쓴 것, 그리고 정답률을 진도 바로 렌더링한 것 (이슈 본문).
