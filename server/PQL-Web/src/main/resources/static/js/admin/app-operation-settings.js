/**
 * 관리자 앱 운영 점검·버전 영역: 점검 배지 미리보기, 형식 검증 > 저장 전 확인 > 저장
 * 요청·토스트는 admin-fetch.js (AdminApi, AdminUi)
 */
(function () {
    'use strict';

    // 버전 형식: 숫자 3개 (x.y.z) — 서버 AppOperationService 와 같은 규칙
    const VERSION_PATTERN = /^\d{1,4}\.\d{1,4}\.\d{1,4}$/;
    const VERSION_INPUT_IDS = ['iosMinimumVersion', 'iosRecommendedVersion', 'androidMinimumVersion', 'androidRecommendedVersion'];

    // 점검 토글 > 배지 즉시 반영 (저장 전 미리보기)
    document.getElementById('isMaintenanceEnabled').addEventListener('change', (event) => {
        document.getElementById('maintenanceBadge').classList.toggle('hidden', !event.target.checked);
    });

    // 최소 지원 버전 입력 (저장 전 변경 전후 확인 대상)
    const MINIMUM_VERSION_INPUTS = [
        {id: 'iosMinimumVersion', platformName: 'iOS'},
        {id: 'androidMinimumVersion', platformName: 'Android'}
    ];

    // x.y.z 비교: version 이 baseVersion 보다 높으면 true
    function isVersionHigher(version, baseVersion) {
        const versionParts = version.split('.').map(Number);
        const baseVersionParts = baseVersion.split('.').map(Number);
        for (let index = 0; index < versionParts.length; index++) {
            if (versionParts[index] !== baseVersionParts[index]) return versionParts[index] > baseVersionParts[index];
        }
        return false;
    }

    // 저장 전 확인 문구: 최소 버전 변경 전후 + 영향 + 미배포 버전 경고, 점검 모드 켜짐 (확인할 것 없으면 빈 문자열)
    function buildSaveConfirmMessage(isMaintenanceEnabled) {
        const releaseVersion = document.getElementById('versionSettings').dataset.releaseVersion || '';
        const lines = [];
        MINIMUM_VERSION_INPUTS.forEach(({id, platformName}) => {
            const input = document.getElementById(id);
            const newVersion = input.value.trim();
            if (newVersion === input.dataset.savedValue) return;
            lines.push(platformName + ' 최소 지원 버전: ' + input.dataset.savedValue + ' > ' + newVersion);
            if (VERSION_PATTERN.test(releaseVersion) && isVersionHigher(newVersion, releaseVersion)) {
                lines.push('  경고: ' + newVersion + ' 은 현재 서버 빌드 버전(' + releaseVersion + ')보다 높습니다. 아직 배포되지 않은 버전일 수 있습니다.');
            }
        });
        if (lines.length) {
            lines.push('새 최소 버전 미만 사용자는 업데이트 전까지 앱을 쓸 수 없습니다.');
        }
        if (isMaintenanceEnabled) {
            lines.push('점검 모드를 켠 상태로 저장합니다. 앱 사용과 회원 API 가 막힙니다.');
        }
        return lines.join('\n');
    }

    // 점검·버전 저장: 형식 검증 > 확인 창(최소 버전 변경·점검 켜짐) > PUT > 새로고침
    async function saveOperationSettings() {
        let hasInvalidVersion = false;
        VERSION_INPUT_IDS.forEach(id => {
            const input = document.getElementById(id);
            const isValid = VERSION_PATTERN.test(input.value.trim());
            input.classList.toggle('input-error', !isValid);
            if (!isValid) hasInvalidVersion = true;
        });
        if (hasInvalidVersion) {
            AdminUi.toast('버전은 x.y.z 형식의 숫자로 입력해 주세요.', 'error');
            return;
        }
        const isMaintenanceEnabled = document.getElementById('isMaintenanceEnabled').checked;
        const confirmMessage = buildSaveConfirmMessage(isMaintenanceEnabled);
        if (confirmMessage && !await AdminUi.confirmDanger(confirmMessage, {title: '저장 전 확인', confirmLabel: '저장'})) {
            return;
        }
        const request = {
            iosMinimumVersion: document.getElementById('iosMinimumVersion').value.trim(),
            iosRecommendedVersion: document.getElementById('iosRecommendedVersion').value.trim(),
            androidMinimumVersion: document.getElementById('androidMinimumVersion').value.trim(),
            androidRecommendedVersion: document.getElementById('androidRecommendedVersion').value.trim(),
            isMaintenanceEnabled: isMaintenanceEnabled,
            maintenanceMessage: document.getElementById('maintenanceMessage').value,
            maintenanceStartsAt: document.getElementById('maintenanceStartsAt').value || null,
            maintenanceEndsAt: document.getElementById('maintenanceEndsAt').value || null
        };
        try {
            await AdminApi.put('/admin/app-operation/settings', request);
        } catch (error) {
            AdminUi.showError(error);
            return;
        }
        AdminUi.reloadWithToast('저장했습니다.');
    }

    window.saveOperationSettings = saveOperationSettings;
})();
