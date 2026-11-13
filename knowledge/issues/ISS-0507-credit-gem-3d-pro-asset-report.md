---
type: completion-report
id: ISS-0507
created: 2026-11-12
topics: [design-system, billing]
status: resolved
resolves: "[[ISS-0507-credit-gem-3d-pro-asset]]"
related: ["[[DEC-0299-gem-3d-via-perspective-single-pro-gem]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1014"
---

# ISS-0507 완료 리포트: 원근 회전 부품 Passql3dTilt와 PRO 무한 젬

## 해결 방법
- `brand/pro_icon_1024.png` 원본 > `generate_brand_assets_for_all_platforms.py`(`build_gem_icon`)로 앱 사본 1·2·3배, `--check` 35개 일치.
- 디자인 시스템 `Passql3dTilt`(원근 스핀 등장·빛 쓸기·값 변경 뒤집기·드래그 기울기, 동작 줄이기면 정지), `PassqlProIcon`, 모션·아이콘 크기 토큰.
- 적용: 보상 창 젬 스핀, 크레딧 알약 뒤집기, 이용권 시트 머리·PASS 탑승권·프로필 업그레이드 배너에 PRO 젬.
- PR #1023, 배포 #1024. 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/1014#issuecomment-6825819314

## 근본 원인 (확정)
정지 이미지 사용, PRO 에셋 부재.

## 재발 방지
- 원본은 `brand/`, 사본은 스크립트 생성(`--check`).
- 검증: app analyze 무경고, test 166건, 실기기 QA(v1.114.0, iOS 시뮬레이터, 다크) 통과. 정지 캡처라 움직임 자체는 미확인.
- 후속 점검: 비교표 FREE 해설 칸 `정답 해설 (세트 전체)`가 랜덤 무료 해설(#999)을 빼먹은 것처럼 읽힐 수 있음.

## 교훈
- 새 화면에서 3D 연출을 쓸 때 동작 줄이기 분기를 우회하지 않는다.
