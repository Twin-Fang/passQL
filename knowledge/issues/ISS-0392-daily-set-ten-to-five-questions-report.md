---
type: completion-report
id: ISS-0392
created: 2026-10-26
topics: ["practice"]
status: resolved
resolves: "[[ISS-0392-daily-set-ten-to-five-questions]]"
related: ["[[DEC-0178-daily-set-five-questions]]"]
source: "https://github.com/Twin-Fang/passQL/issues/644"
---

# ISS-0392 완료 리포트: 오늘의 세트 5문제: 남은 문서·스토어 설명 문구 정리

GitHub #644 완료 리포트 댓글(2026-10-26) 기준. PR #663, 릴리스 #666. 리포트는 "서버·관리자·홍보 이미지는 이미 5문제로 바뀌었다"고만 적고, 서버 변경의 PR·파일은 이 리포트에 없다.

## 해결 방법
- `README.md`: "같은 10문제" > "같은 5문제".
- `app/docs/store/descriptions/ios-full.txt`, `play-full.txt`: "문제 10개" > "문제 5개".
- `app/docs/PRD.md`: 홈 오늘의 세트 설명 5문제로.

## 근본 원인 (확정)
결함이 아니라 세트 크기 변경. 서버·관리자·홍보 이미지 변경 뒤 문서·스토어 설명에 "10문제"가 남아 있었다.

## 재발 방지
- 확인: 레포 전체에서 오늘의 세트 관련 "10문제" 문구가 더 없음, 앱(iOS 시뮬레이터)에서 "오늘의 5문제"로 표시.
- 남아 있는 "무료 10문제"(하루 무료 한도, GitHub #576), "챕터 풀이 10문제"는 다른 규칙이라 그대로.
- 스토어 실제 반영은 다음 스토어 설명 업로드가 필요.
- 이슈 본문의 "이미 배정된 날짜 데이터 처리 방침"과 "자정 스케줄러 결과 실측"의 결과는 원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) 오늘의 세트 크기를 바꿀 때 "10문제"를 grep하면 무료 한도·챕터 풀이의 10과 섞인다. 규칙별로 구분해서 본다.
