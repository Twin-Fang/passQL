---
type: completion-report
id: ISS-0389
created: 2026-10-24
topics: ["store-release"]
status: resolved
resolves: "[[ISS-0389-license-holder-kollylab]]"
related: ["[[DEC-0176-license-holder-kollylab]]"]
source: "https://github.com/Twin-Fang/passQL/issues/638"
---

# ISS-0389 완료 리포트: `LICENSE` 저작권자·Licensor를 KOLLYLAB (콜리랩)으로, 문의 연락처를 하나로

GitHub #638 완료 리포트 댓글(2026-10-24) 기준. PR #639.

## 해결 방법
- `LICENSE`: `Copyright (c) 2026 passQL-Lab` > `KOLLYLAB (콜리랩)`, `Licensor` 정의 동일 변경, 상업 문의 연락처를 운영자 이메일 하나로 정리.
- `README.md`: 라이선스 문의 연락처를 같은 이메일 하나로 정리.
- 변경하지 않은 것: 조항 본문(상업 이용·서비스 운영·배포 금지), 사업자등록번호·대표자 정보는 공개 레포에 넣지 않음.

## 근본 원인 (확정)
사업자 등록 뒤 저작권자·연락처 표기를 갱신하지 않았다.

## 재발 방지
남은 것(리포트): 앱 이용약관·개인정보처리방침의 운영 주체 표기는 레포에서 찾지 못함(서버나 관리자 설정에 있다면 별도 확인 필요), 스토어 개발자 이름이 콜리랩과 일치하는지 확인 필요, 코드 저작권 등록(한국저작권위원회)과 "passQL" 상표 등록은 별도 절차.

## 교훈
(원본에 없음, 볼트 정리) 운영 주체가 바뀌면 `LICENSE`·README뿐 아니라 약관·개인정보처리방침·스토어 개발자 이름까지 함께 점검한다.
