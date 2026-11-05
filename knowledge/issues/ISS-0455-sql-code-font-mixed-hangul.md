---
type: issue
id: ISS-0455
created: 2026-11-05
topics: [design-system]
symptoms: ["SQL 가독성", "선택지 SQL 안 읽힘", "한글 섞인 SQL", "코드 글꼴", "JetBrains Mono 한글", "울퉁불퉁", "UPDATE 문 폰트"]
root_cause: "코드 글꼴 JetBrains Mono 에 한글이 없어 한글만 본문 글꼴(비고정폭)로 대체돼 한 줄에 두 글꼴이 섞였다"
status: resolved
resolution: "[[ISS-0455-sql-code-font-mixed-hangul-report]]"
related: ["[[ISS-0455-sql-code-font-mixed-hangul-report]]", "[[DEC-0255-code-font-d2coding-subset]]"]
source: "_sources/issues/ISS-0455-sql-code-font-mixed-hangul.md"
---

# ISS-0455: 한글 섞인 SQL 이 두 글꼴로 갈라져 울퉁불퉁하게 읽힘

GitHub #849 이슈 본문 기준. 외부 출처: https://github.com/Twin-Fang/passQL/issues/849 · 완료 리포트: [[ISS-0455-sql-code-font-mixed-hangul-report]]

## 증상
선택지·코드 블록의 SQL(예: UPDATE 문)이 잘 안 읽힌다 (사용자 피드백).

## 근본 원인
코드 글꼴 JetBrains Mono 에 한글이 없어, 한글이 섞인 줄은 한글만 Pretendard(비고정폭)로 대체됐다. 결과 표 칸도 숫자 고정폭·한글 비고정폭이 섞였다.
