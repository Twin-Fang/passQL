---
type: completion-report
id: ISS-0099
created: 2026-04-12
topics: [store-release]
status: resolved
resolves: "[[ISS-0099-license-ban-commercial-use]]"
related: ["[[DEC-0065-source-available-license-no-commercial]]"]
source: "https://github.com/Twin-Fang/passQL/issues/180"
---

# ISS-0099 완료 리포트: MIT → passQL Source-Available License 1.0

GitHub #180 `## 개요` 리포트 댓글 기준 (2026-04-12).

## 해결 방법
`LICENSE`를 MIT에서 passQL Source-Available License 1.0으로 전면 교체. 핵심 조항: Section 2(개인 자연인의 로컬 비상업적 학습·연구·평가만 허용, 모든 단체 제외), Section 4(상업적 이용·프로덕션 배포·회사/학교/비영리/정부기관 업무·Hosted Service·제3자 서비스 금지), Section 5(비상업 조건의 포크·수정본 공개 허용), Section 6(그 밖의 이용은 사전 서면 허가, 문의처 명시 — 연락처는 볼트에 옮기지 않음), Section 13(대한민국 준거법). 상단에 "This software is source-available, not open source." 명시. 상세는 [[DEC-0065-source-available-license-no-commercial]].

## 근본 원인 (확정)
MIT에 상업적 이용 제한 조항이 없었다.

## 재발 방지
리포트 주의사항: BUSL-1.1 표준이 아닌 자체 커스텀 라이선스이며 Change Date/Change License 자동 전환이 없다. README 라이선스 섹션·뱃지 갱신이 필요할 수 있음. 외부 기여는 CLA 또는 README 안내로 라이선스 동의를 명확히 할 것을 권장.

## 교훈
논의 기록 없음.
