---
type: issue
id: ISS-0099
created: 2026-04-12
topics: [store-release]
symptoms: [LICENSE, MIT, "상업적 이용", BUSL-1.1, "Source-Available"]
root_cause: "LICENSE가 MIT라 누구나 상업적으로 이용할 수 있었다"
status: resolved
resolution: "[[ISS-0099-license-ban-commercial-use-report]]"
related: ["[[DEC-0065-source-available-license-no-commercial]]"]
source: "https://github.com/Twin-Fang/passQL/issues/180"
---

# ISS-0099: LICENSE 상업적 이용 금지 정책 수립

GitHub #180 (원본: 이슈 본문과 리포트 댓글).

## 증상
LICENSE가 MIT라 누구나 상업적으로 이용 가능하다. passQL은 AI 기능 기반 유료 서비스 전환 예정이라 제3자 상업적 이용을 제한해야 하는데 MIT에는 제한 조항이 없다(이슈 본문).

## 재현 조건
해당 없음 (정책 이슈).

## 조사 기록
- 2026-04-12: 이슈 등록. 제안: BUSL-1.1로 교체, Additional Use Grant = 개인 비상업적 학습·연구 로컬 실행만, Change Date 없음(영구 제한), Licensor passQL-Lab, README 라이선스 섹션 갱신.
- 2026-04-12: 실제로는 BUSL-1.1이 아닌 passQL 자체 라이선스로 교체(리포트).

## 근본 원인
MIT 라이선스에 상업적 이용 제한 조항이 없다.
