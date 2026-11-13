/**
 * 건의사항 목록 화면: 상태 변경(건별·일괄), 관제소 연동 켜기/끄기 (#959)
 * API: /admin/feedbacks, /admin/settings/{key} (AdminApi 공통 요청), 체크박스 묶음은 admin-bulk-select.js 공용
 */
(function () {
    'use strict';

    const FEEDBACK_API_BASE = '/admin/feedbacks';
    const SETTING_API_BASE = '/admin/settings';

    const bulkBar = document.getElementById('feedbackBulkBar');
    const bulkCount = document.getElementById('feedbackBulkCount');

    // 선택 수가 0이면 일괄 작업 바 숨김
    const bulkSelection = AdminBulkSelect.attach(document.getElementById('feedbackTableWrapper'), selectedCount => {
        bulkCount.textContent = selectedCount;
        bulkBar.classList.toggle('hidden', selectedCount === 0);
    });

    window.updateStatus = function (uuid) {
        const status = document.getElementById('select-' + uuid).value;
        AdminApi.post(FEEDBACK_API_BASE + '/' + uuid + '/status', { status })
            .then(() => AdminUi.reloadWithToast('상태를 변경했습니다.'))
            .catch(error => AdminUi.showError(error));
    };

    /** 관제소 연동 켜기/끄기: 앱 설정 저장 (감사 기록은 서버), 실패 시 토글 되돌림 */
    window.toggleControlTowerAttention = function (toggle) {
        const isEnabled = toggle.checked;
        AdminApi.put(SETTING_API_BASE + '/' + encodeURIComponent(toggle.dataset.settingKey), { value: String(isEnabled) })
            .then(() => AdminUi.reloadWithToast(isEnabled ? '관제소 연동을 켰습니다.' : '관제소 연동을 껐습니다.'))
            .catch(error => {
                toggle.checked = !isEnabled;
                AdminUi.showError(error);
            });
    };

    /** 선택한 건의 상태 일괄 변경 */
    window.bulkUpdateStatus = function () {
        const feedbackUuids = bulkSelection.getSelectedValues();
        const status = document.getElementById('feedbackBulkStatus').value;
        AdminApi.post(FEEDBACK_API_BASE + '/bulk-status', { feedbackUuids, status })
            .then(result => AdminUi.reloadWithToast(result.changedCount + '건의 상태를 변경했습니다.'))
            .catch(error => AdminUi.showError(error));
    };
})();
