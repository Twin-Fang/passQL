---
type: issue
id: ISS-0195
created: 2026-10-07
topics: [store-release, ops-infra]
symptoms: ["\\n 글자 노출", "## 조항 제목 노출", 약관 한 덩어리, V0_0_159__add_legal_table.sql, legal 테이블]
root_cause: "`V0_0_159__add_legal_table.sql`이 PostgreSQL 일반 문자열(`'...\\n...'`)로 본문을 넣어 줄바꿈이 역슬래시+n 두 글자로 저장됐다"
status: resolved
resolution: "[[ISS-0195-legal-text-escaped-newlines-report]]"
related: ["[[ISS-0193-login-settings-redesign-wrong-notes]]"]
source: "https://github.com/Twin-Fang/passQL/issues/350"
---

# ISS-0195: 약관 화면에 `\n` 글자가 그대로 보이고 조항이 한 덩어리로 표시됨

GitHub #350 (원본: 이슈 본문과 댓글).

## 증상
이용약관·개인정보처리방침 화면에 줄바꿈 대신 `\n` 글자가 보이고, `##` 조항 제목이 처리되지 않아 본문 전체가 한 덩어리로 표시된다. 실계정 E2E(iPhone 16 Pro 시뮬레이터, 2026-10-07)에서 발견.

## 재현 조건
앱 설정 → 이용약관(또는 로그인 화면 하단 링크).

## 조사 기록
- 2026-10-07: 원인 확인 — `V0_0_159__add_legal_table.sql`이 일반 문자열로 본문을 넣음.

## 근본 원인
마이그레이션이 이스케이프 문자열이 아닌 일반 문자열로 `\n`을 넣어 두 글자로 저장됨.
