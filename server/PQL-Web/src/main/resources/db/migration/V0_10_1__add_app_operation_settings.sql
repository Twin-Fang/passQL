-- 앱 운영 설정: 최소·권장 버전(플랫폼별), 점검 여부·문구 (#464)
-- 기본값은 차단 없음 (버전 0.0.0, 점검 false). 관리자 > 앱 운영에서 바꾼다.
INSERT INTO app_setting (app_setting_uuid, setting_key, value_type, value_text, category, description)
VALUES
    (gen_random_uuid(), 'app.minimum_version.ios', 'STRING', '0.0.0', 'APP', 'iOS 최소 지원 버전 (x.y.z, 미만이면 업데이트 전까지 사용 차단)'),
    (gen_random_uuid(), 'app.minimum_version.android', 'STRING', '0.0.0', 'APP', 'Android 최소 지원 버전 (x.y.z, 미만이면 업데이트 전까지 사용 차단)'),
    (gen_random_uuid(), 'app.recommended_version.ios', 'STRING', '0.0.0', 'APP', 'iOS 권장 버전 (x.y.z, 미만이면 닫을 수 있는 업데이트 안내)'),
    (gen_random_uuid(), 'app.recommended_version.android', 'STRING', '0.0.0', 'APP', 'Android 권장 버전 (x.y.z, 미만이면 닫을 수 있는 업데이트 안내)'),
    (gen_random_uuid(), 'app.maintenance.enabled', 'BOOLEAN', 'false', 'APP', '점검 여부 (true 이면 앱 점검 화면, 회원 API 503)'),
    (gen_random_uuid(), 'app.maintenance.message', 'STRING', '', 'APP', '점검 화면 문구 (비우면 앱 기본 문구)')
ON CONFLICT (setting_key) DO NOTHING;
