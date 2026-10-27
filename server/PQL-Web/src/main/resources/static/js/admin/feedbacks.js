/**
 * 건의사항 목록 화면: 상태 변경(건별·일괄)
 * API: /admin/feedbacks (AdminApi 공통 요청), 체크박스 묶음은 admin-bulk-select.js 공용
 */
(function () {
    'use strict';

    const FEEDBACK_API_BASE = '/admin/feedbacks';

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

    /** 선택한 건의 상태 일괄 변경 */
    window.bulkUpdateStatus = function () {
        const feedbackUuids = bulkSelection.getSelectedValues();
        const status = document.getElementById('feedbackBulkStatus').value;
        AdminApi.post(FEEDBACK_API_BASE + '/bulk-status', { feedbackUuids, status })
            .then(result => AdminUi.reloadWithToast(result.changedCount + '건의 상태를 변경했습니다.'))
            .catch(error => AdminUi.showError(error));
    };
})();
