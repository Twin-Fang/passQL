---
type: issue
id: ISS-0507
created: 2026-11-12
topics: [design-system, billing]
symptoms: ["크레딧 젬 평면", "PRO 에셋 없음", "Passql3dTilt", "PassqlProIcon", "pro_icon_1024.png", "보상 창 젬 스핀", "동작 줄이기"]
root_cause: "3D 젬 이미지를 정지 이미지로만 써 입체감이 없었고, 크레딧 무제한(PRO)을 같은 화풍으로 보여 줄 에셋이 없었다"
status: resolved
resolution: "[[ISS-0507-credit-gem-3d-pro-asset-report]]"
related: ["[[DEC-0299-gem-3d-via-perspective-single-pro-gem]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1014"
---

# ISS-0507: 크레딧 젬 3D 연출, PRO 3D 에셋

GitHub #1014. 원본 사본: `_sources/issues/ISS-0507-credit-gem-3d-pro-asset.md`(로컬).

## 증상
- 크레딧 아이콘을 3D 둥근 사각 젬으로 바꿨지만(#999, PR #1013) 앱 안에서는 평면 이미지로만 보인다.
- 이용권(PRO)을 그림으로 보여 주는 에셋이 없어 이용권 시트·PASS 탑승권이 크레딧 젬과 같은 화풍으로 이어지지 않는다.

## 재현 조건
보상 창, 크레딧 알약, 이용권 시트, PASS 탑승권.

## 조사 기록
- 2026-11-12: PRO 3D 에셋 시안 4안 — 2안 무한 젬 채택(사용자), 3 금테·4 겹친 젬 기각.
- 2026-11-12: PR #1023(099d4986), 배포 #1024.

## 근본 원인
정지 이미지 사용, PRO 전용 에셋 부재.
