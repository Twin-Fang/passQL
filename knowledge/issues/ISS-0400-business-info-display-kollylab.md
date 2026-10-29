---
type: issue
id: ISS-0400
created: 2026-10-25
topics: [store-release, billing]
symptoms: ["사업자 정보 표기 없음", "전자상거래 신원 정보", "통신판매업 신고번호", businessInfo, "콜리랩"]
root_cause: "운영 주체를 콜리랩으로 바꿨지만(#638) 앱·웹·사이트 어디에도 사업자 정보 표기가 없었다"
status: open
resolution: null
related: ["[[ISS-0397-promo-site-overhaul-operator-notice]]"]
source: "https://github.com/Twin-Fang/passQL/issues/658"
---

# ISS-0400: 앱·웹·사이트 사업자 정보 표기 (콜리랩)

GitHub #658 (원본: 이슈 본문과 댓글). 이슈는 열려 있다(라벨 작업중). 원본의 대표자·등록번호·연락처 값은 노트에 옮기지 않았다.

## 증상
운영 주체를 콜리랩(KOLLYLAB, 개인사업자)으로 바꿨지만(GitHub #638) 앱·웹·사이트 어디에도 사업자 정보 표기가 없다. 유료 이용권 판매 전(결제 스위치 켜기 전, GitHub #576·#578) 전자상거래 신원 정보 표시 필요 여부를 확인해야 한다 — 이슈 본문은 확정된 법률 판단이 아니며 변호사·관할 기관 확인이 필요하다고 적었다.

## 재현 조건
해당 없음 (기능 이슈).

## 조사 기록
- 2026-10-25: 제안 — 사업자등록증 이미지는 올리지 않고 텍스트로만 표기, 값은 서버 한 곳에서 관리해 앱·웹·사이트가 같은 값을 읽음. 사용자 결정 필요: 자택 주소 공개 여부, 통신판매업 신고 대상·번호, 표기 범위.
- 2026-10-26 리포트(PR #667): 앱 설정, 웹 설정·사이드바 푸터, 홍보 사이트 푸터에 표기. 사업장 주소는 표기하지 않음. 원본은 `app_setting business.*`(관리자 설정) > `GET /api/meta/app-config`의 `businessInfo`, 홍보 사이트는 정적이라 `site_content.py` 상수 별도. 서버 `V1_58_0__business_info_settings.sql`, `BusinessInfoResponse`, 웹 `BusinessInfoNotice.tsx`·`LegalModal.tsx`, 앱 `widgets/settings/business_info_group.dart`.
- 2026-10-26: 관리자 > 약관 관리에서 이용약관(제1조 운영 주체, 제8조 사업자 정보)·개인정보처리방침(8항 운영자 및 보호책임자) 개정 게시. 홍보 사이트 약관 페이지도 재생성(gh-pages `debd7b5e`).
- 남은 일: 통신판매업 신고번호(정부24 2026-10-23 접수, 처리중). 나오면 `business.mail_order_sales_number`와 사이트 `OPERATOR_MAIL_ORDER_SALES_NUMBER` 두 곳에 입력. 앱 화면은 다음 스토어 빌드부터.

## 근본 원인
원본에 적혀 있지 않다 (표기 부재).
