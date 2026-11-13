/**
 * 관리자 앱 운영 잠금화면 문제 영역 (#990): 스위치·기본 간격·실행형 포함 저장
 * 요청·토스트는 admin-fetch.js (AdminApi, AdminUi)
 */
(function () {
    'use strict';

    // 기본 표시 간격 허용 범위 (분, 서버 LockScreenSettingsRequest 와 같은 값)
    const MIN_INTERVAL_MINUTES = 0;
    const MAX_INTERVAL_MINUTES = 1440;

    /** 입력 검증 > PUT > 새로고침 (범위 검사는 서버도 함) */
    async function saveLockScreenSettings() {
        const intervalText = document.getElementById('lockScreenDefaultIntervalMinutes').value.trim();
        const defaultIntervalMinutes = Number(intervalText);
        if (!intervalText || !Number.isInteger(defaultIntervalMinutes)
            || defaultIntervalMinutes < MIN_INTERVAL_MINUTES || defaultIntervalMinutes > MAX_INTERVAL_MINUTES) {
            AdminUi.toast('기본 표시 간격은 0~1440 사이 정수(분)로 입력해 주세요.', 'error');
            return;
        }
        const request = {
            isEnabled: document.getElementById('lockScreenEnabled').checked,
            defaultIntervalMinutes,
            isExecutableIncluded: document.getElementById('lockScreenExecutableIncluded').checked
        };
        try {
            await AdminApi.put('/admin/app-operation/lockscreen', request);
        } catch (error) {
            AdminUi.showError(error);
            return;
        }
        AdminUi.reloadWithToast('잠금화면 문제 설정을 저장했습니다.');
    }

    window.saveLockScreenSettings = saveLockScreenSettings;
})();
