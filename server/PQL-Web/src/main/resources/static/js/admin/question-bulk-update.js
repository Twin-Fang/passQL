/**
 * 문제 목록 일괄 변경: 선택 활성화, 선택 토픽·난이도 변경 (선택 체크박스는 question-import-export.js 의 getSelectedUuids)
 */

/** 선택 문제 일괄 활성화: 확인 창 > 요청 > 새로고침 토스트 */
async function activateSelected() {
    const questionUuids = getSelectedUuids();
    if (questionUuids.length === 0) {
        AdminUi.toast('활성화할 문제를 선택해주세요.', 'warning');
        return;
    }
    if (!await AdminUi.confirmDanger(`선택한 ${questionUuids.length}개 문제를 다시 회원에게 노출하고 추천 색인에 적재합니다.\n이미 활성인 문제는 건너뜁니다.`,
        { title: '선택한 문제를 활성화할까요?', confirmLabel: '활성화' })) return;
    AdminApi.post('/admin/questions/bulk/activate', { questionUuids })
        .then(result => AdminUi.reloadWithToast(`활성화 완료: ${result.updated}건 활성화, ${result.skipped}건 건너뜀`))
        .catch(error => AdminUi.showError(error));
}

function openBulkClassifyModal() {
    const questionUuids = getSelectedUuids();
    if (questionUuids.length === 0) {
        AdminUi.toast('변경할 문제를 선택해주세요.', 'warning');
        return;
    }
    document.getElementById('bulkClassifyCount').textContent = questionUuids.length;
    document.getElementById('bulkClassifyTopic').value = '';
    document.getElementById('bulkClassifyDifficulty').value = '';
    onBulkClassifyTopicChanged();
    document.getElementById('bulkClassifyModal').showModal();
}

/** 토픽 선택 > 해당 토픽 서브토픽만 표시 (토픽 미선택이면 서브토픽 선택 불가) */
function onBulkClassifyTopicChanged() {
    const topicCode = document.getElementById('bulkClassifyTopic').value;
    const subtopicSelect = document.getElementById('bulkClassifySubtopic');
    subtopicSelect.value = '';
    subtopicSelect.disabled = !topicCode;
    Array.from(subtopicSelect.options).forEach(option => {
        if (!option.dataset.topicCode) return;
        option.hidden = option.dataset.topicCode !== topicCode;
    });
}

/** 토픽·난이도 일괄 변경 요청 > 새로고침 토스트 */
function confirmBulkClassify() {
    const topicCode = document.getElementById('bulkClassifyTopic').value;
    const subtopicCode = document.getElementById('bulkClassifySubtopic').value;
    const difficultyValue = document.getElementById('bulkClassifyDifficulty').value;
    if (!topicCode && !difficultyValue) {
        AdminUi.toast('변경할 토픽 또는 난이도를 선택해주세요.', 'warning');
        return;
    }
    const confirmButton = document.getElementById('bulkClassifyConfirmBtn');
    confirmButton.disabled = true;
    AdminApi.put('/admin/questions/bulk/classification', {
        questionUuids: getSelectedUuids(),
        topicCode: topicCode || null,
        subtopicCode: subtopicCode || null,
        difficulty: difficultyValue ? parseInt(difficultyValue, 10) : null
    })
        .then(result => {
            document.getElementById('bulkClassifyModal').close();
            AdminUi.reloadWithToast(`변경 완료: ${result.updated}건 변경, ${result.skipped}건 건너뜀`);
        })
        .catch(error => {
            confirmButton.disabled = false;
            AdminUi.showError(error);
        });
}
