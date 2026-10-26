-- =============================================================================
-- V1_58_0: 사업자 정보 표기 설정 (#658)
-- 앱 설정·웹 푸터·웹 설정이 GET /api/meta/app-config 의 businessInfo 로 같은 값을 읽음
-- 빈 값이면 그 줄 숨김 (통신판매업 신고번호는 신고 후 관리자 > 설정에서 입력)
-- =============================================================================
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'business.company_name', 'STRING', '콜리랩(KOLLYLAB)', 'BUSINESS', '상호 (비우면 사업자 정보 섹션 전체 숨김)'),
    (gen_random_uuid(), 'business.representative_name', 'STRING', '서새찬', 'BUSINESS', '대표자 이름 (비우면 줄 숨김)'),
    (gen_random_uuid(), 'business.registration_number', 'STRING', '331-37-01670', 'BUSINESS', '사업자등록번호 000-00-00000 (비우면 줄 숨김)'),
    (gen_random_uuid(), 'business.contact_email', 'STRING', 'chan4760@naver.com', 'BUSINESS', '문의 이메일 (비우면 줄 숨김)'),
    (gen_random_uuid(), 'business.mail_order_sales_number', 'STRING', '', 'BUSINESS', '통신판매업 신고번호 (신고 전 빈 값, 비우면 줄 숨김)')
ON CONFLICT (setting_key) DO NOTHING;
