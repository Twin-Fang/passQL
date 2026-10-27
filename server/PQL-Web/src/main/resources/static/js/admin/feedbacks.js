/**
 * 건의사항 관리 화면: 상세 창(메모 저장, 답변 발송), 상태 변경(건별·일괄)
 * API: /admin/feedbacks (AdminApi 공통 요청), 체크박스 묶음은 admin-bulk-select.js 공용
 */
(function () {
    'use strict';

    const FEEDBACK_API_BASE = '/admin/feedbacks';

    const bulkBar = document.getElementById('feedbackBulkBar');
    const bulkCount = document.getElementById('feedbackBulkCount');
    let modalFeedbackUuid = null;

    // 선택 수가 0이면 일괄 작업 바 숨김
    const bulkSelection = AdminBulkSelect.attach(document.getElementById('feedbackTableWrapper'), selectedCount => {
        bulkCount.textContent = selectedCount;
        bulkBar.classList.toggle('hidden', selectedCount === 0);
    });

    window.openModal = function (element) {
        modalFeedbackUuid = element.dataset.uuid;
        const memberLink = document.getElementById('modalMember');
        memberLink.textContent = element.dataset.member;
        memberLink.href = element.dataset.memberHref;
        document.getElementById('modalMemo').value = element.dataset.memo || '';
        document.getElementById('modalMemoUpdatedBy').textContent = element.dataset.updatedBy ? '마지막 수정: ' + element.dataset.updatedBy : '';
        document.getElementById('modalStatus').textContent = element.dataset.status;
        document.getElementById('modalCreated').textContent = element.dataset.created;
        document.getElementById('modalContent').textContent = element.dataset.content;
        document.getElementById('feedbackModal').showModal();
    };

    window.saveMemo = function () {
        const adminMemo = document.getElementById('modalMemo').value;
        AdminApi.put(FEEDBACK_API_BASE + '/' + modalFeedbackUuid + '/memo', { adminMemo })
            .then(() => AdminUi.reloadWithToast('메모를 저장했습니다.'))
            .catch(error => AdminUi.showError(error));
    };

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
