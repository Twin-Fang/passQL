---
type: decision
id: DEC-0065
created: 2026-04-12
reviewed: null
topics: [store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0099-license-ban-commercial-use]]", "[[ISS-0099-license-ban-commercial-use-report]]"]
---

# DEC-0065: 저장소 라이선스를 MIT에서 자체 Source-Available License 1.0으로 — 상업적 이용 영구 금지

## 문제 정의 (Context)
MIT라 누구나 상업적으로 이용 가능했다. 이슈 본문: passQL은 AI 기능 기반 유료 서비스 전환 예정이라 제3자의 상업적 이용을 제한해야 한다 (GitHub #180).

## 결정 (Decision)
`LICENSE`를 passQL Source-Available License 1.0으로 교체한다.
- 허용: 개인 자연인의 로컬 비상업적 학습·연구·평가 실행, 비상업 조건의 포크·수정본 공개.
- 금지: 상업적 이용, 프로덕션 배포, 회사·학교·비영리·정부기관 업무 이용, Hosted Service(SaaS·플랫폼·API), 제3자 대상 서비스.
- 그 밖의 이용은 사전 서면 허가(별도 상업 라이선스). 준거법 대한민국.
- Change Date 없음 — 상업적 이용 금지가 영구 유지된다.

## 검토한 대안 (Alternatives)
- MIT 유지: 상업적 이용 제한 조항이 없어 서비스 보호 불가(이슈 본문).
- BUSL-1.1: 이슈 본문의 제안이었으나 실제로는 자체 커스텀 라이선스를 택했다. BUSL-1.1 대신 자체 라이선스를 고른 이유는 원본에 적혀 있지 않다(리포트는 "BUSL-1.1의 Change Date/Change License 자동 전환 조항은 포함되어 있지 않다"고만 적음).

## 결과 (Consequences)
**긍정**
- 제3자의 상업적·기관적 이용 차단, 별도 상업 라이선스 계약 구조 마련(리포트).

**부정**
- 리포트 주의사항: 외부 기여 코드를 받을 때 기여자 동의를 명확히 해야 함(CLA 또는 README 안내 권장). README 라이선스 섹션 갱신이 필요할 수 있음.

## 영향 범위 (Scope)
레포 루트 `LICENSE`, README 라이선스 섹션, 외부 기여 정책.

## 출처 (References)
- GitHub #180 이슈 본문, 리포트 댓글 (2026-04-12)
- [[ISS-0099-license-ban-commercial-use]]
