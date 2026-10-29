---
type: issue
id: ISS-0389
created: 2026-10-24
topics: ["store-release"]
symptoms: ["LICENSE 저작권자", "Licensor", "passQL-Lab", "KOLLYLAB", "라이선스 문의 연락처 불일치"]
root_cause: "`LICENSE`·README가 해커톤 시절 팀 이름(passQL-Lab)과 이전 공동 작업자 연락처를 가리키고 있었다"
status: resolved
resolution: "[[ISS-0389-license-holder-kollylab-report]]"
related: ["[[DEC-0176-license-holder-kollylab]]"]
source: "https://github.com/Twin-Fang/passQL/issues/638"
---

# ISS-0389: LICENSE 저작권자·Licensor가 해커톤 팀 이름으로 남아 있고 문의 연락처가 정리되지 않음

GitHub #638 (원본: 이슈 본문과 완료 리포트 댓글).

## 증상
수익화를 위해 사업자(콜리랩, KOLLYLAB)를 등록했는데 `LICENSE`와 README는 아직 해커톤 시절 팀 이름(passQL-Lab)과 이전 공동 작업자 연락처를 가리킨다. `README.md`와 `LICENSE`의 문의 이메일 주소도 서로 달랐다.

## 재현 조건
해당 없음 (문서 이슈).

## 조사 기록
- 2026-10-24: 공동 작업자와의 권리 합의는 사용자가 이미 받은 것으로 확인(원본 기재).
- 2026-10-24: 완료 리포트(PR #639).

## 근본 원인
사업자 등록 이후 `LICENSE`·README 표기를 갱신하지 않았다. 그 밖의 원인 설명은 원본에 적혀 있지 않다.
