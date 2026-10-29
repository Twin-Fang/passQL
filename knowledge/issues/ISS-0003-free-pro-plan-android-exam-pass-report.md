---
type: completion-report
id: ISS-0003
created: 2026-10-22
topics: [billing]
status: resolved
resolves: "[[ISS-0003-free-pro-plan-android-exam-pass]]"
related: ["[[DEC-0002-exam-pass-until-next-sqld]]", "[[DEC-0004-free-pro-feature-boundary]]", "[[DEC-0005-ship-with-billing-switch-off]]"]
source: "https://github.com/Twin-Fang/passQL/issues/576"
---

# ISS-0003 완료 리포트: 무료/프로 등급 판정과 Play 회차 패스 결제

GitHub #576 리포트 댓글 기준. 브랜치에 커밋 37개 push, 리포트 시점에 main 미병합.

## 해결 방법
- 서버: `member_entitlement`(회원당 1행: plan, expires_at, source), `entitlement_purchase`(주문·토큰 중복 방지, VERIFIED/REVOKED) — 마이그레이션 `V1_33_0__member_entitlement.sql`. 결제 스위치 시드 false.
- 등급 판정은 `FeatureAccessPolicy` 한 곳. 스위치를 읽지 못하면(저장소 장애) 꺼짐으로 처리해 앱 설정 응답과 같은 기준.
- 기능 전체 잠금은 `@RequiresProFeature` + `ProFeatureInterceptor`, 조건부 잠금(토픽 필터·실전 모드)만 컨트롤러에서 판정. 응답 일부 빼기는 `ProResponseRedactor`(`lockedSections`).
- Play 결제: 상품 확인 > Play Developer API 조회 > 구매 계정 해시 대조 > 기록(ON CONFLICT) > 소모 > 등급 연장. `POST /api/billing/play/verify`. 환불(voided)은 스케줄러가 회수.
- 앱: 블러 미리보기, FREE/PRO 칩, 프로 안내 시트. 관리자는 회원 상세에서 프로 부여·단축·회수, 구매 건별 회수.

## 근본 원인 (확정)
등급 저장소와 판정 단일 지점 부재.

## 재발 방지
- 구매 뒤 등급 갱신은 반드시 `refreshAfterPurchase()` (`refresh()`는 동시 요청을 합쳐 구매 전 무료 응답이 재사용된다).
- 403 감지 인터셉터에서 시트를 띄우지 않는다 (미리 받기·백그라운드 요청에도 시트가 뜬다).
- 출시 앱은 선택지 요청에 `text/event-stream`만 보내 403/429를 연결 실패로 처리 → 스위치를 켤 때 최소 버전 상향 필요.

## 교훈
- 사용자 결정이 남은 것(당시): 제출 API에는 하루 한도 검사가 없어 choiceSetId만 알면 한도를 넘어 제출 가능, 무료 회원 해설 조회에도 AI 해설 생성은 실행됨(응답에서만 뺌, AI 비용 발생).
- 범위 밖 결함: 제출에 `choiceSetId`가 빠지면 400이 아니라 500.
