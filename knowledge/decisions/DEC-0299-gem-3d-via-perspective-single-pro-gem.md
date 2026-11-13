---
type: decision
id: DEC-0299
created: 2026-11-12
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0507-credit-gem-3d-pro-asset]]"]
---

# DEC-0299: 크레딧·PRO 젬의 3D 표현은 3D 모델 대신 이미지 원근 회전 부품(Passql3dTilt)으로 하고, PRO 에셋은 무한 젬 1종만 둔다

GitHub #1014 (이슈 본문, 「PRO 3D 에셋 시안」 댓글).

## 문제 정의 (Context)
3D 젬 이미지가 앱 안에서 평면으로만 보였고, PRO를 같은 화풍으로 보여 줄 에셋이 없었다.

## 결정 (Decision)
- 진짜 3D 모델 대신 지금 이미지에 원근 회전·빛 쓸기·기울기를 입히는 공통 부품 `Passql3dTilt`를 쓴다. 동작 줄이기 설정이면 모두 정지.
- PRO 에셋은 시안 2안 "무한 젬" 1종. 1개월·3개월은 기간만 달라 개월별 에셋을 만들지 않는다.
- 원본은 `brand/pro_icon_1024.png`, 앱 사본은 생성 스크립트로 만든다.

## 검토한 대안 (Alternatives)
- 진짜 3D 모델: 가볍게 유지하려고 하지 않음(이슈 본문).
- PRO 시안 3 금테·4 겹친 젬: 기각(사용자 2026-11-12). 기각 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 크레딧 젬과 PRO 젬이 같은 부품·같은 화풍을 쓴다.

**부정**
- 진짜 입체 회전은 아니다. 논의 기록 없음(그 외 비용).

## 영향 범위 (Scope)
`app/lib/presentation/design/components/passql_3d_tilt.dart`, `passql_pro_icon.dart`, 보상 창·크레딧 알약·이용권 시트·PASS 탑승권·프로필 배너, `brand/`.

## 출처 (References)
- GitHub #1014 이슈 본문·시안 댓글, PR #1023
