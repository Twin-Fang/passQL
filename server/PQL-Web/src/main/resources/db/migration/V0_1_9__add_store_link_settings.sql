-- 스토어 다운로드 링크 설정 (#433)
-- 빈 값이면 웹의 앱 안내 배너가 숨겨진다. 출시 후 관리자 > 설정에서 https URL 을 넣으면 바로 노출된다.
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'store.android_url', 'STRING', '', 'STORE', 'Google Play 스토어 링크 (비우면 웹 안내 숨김)'),
    (gen_random_uuid(), 'store.ios_url', 'STRING', '', 'STORE', 'App Store 링크 (비우면 웹 안내 숨김)')
ON CONFLICT (setting_key) DO NOTHING;
