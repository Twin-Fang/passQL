/**
 * 선택지 세트 목록 일괄 처리: 선택 체크박스 > 일괄 비활성화·재사용 풀 승격
 */

function getSelectedChoiceSetUuids() {
    return Array.from(document.querySelectorAll('.choice-set-checkbox:checked')).map(checkbox => checkbox.dataset.uuid);
}

function toggleAllChoiceSets(master) {
    document.querySelectorAll('.choice-set-checkbox').forEach(checkbox => { checkbox.checked = master.checked; });
    updateChoiceSetBulkButtons();
}

/** 선택 건수에 맞춰 일괄 버튼 활성화·라벨 갱신 */
function updateChoiceSetBulkButtons() {
    const selectedCount = getSelectedChoiceSetUuids().length;
    [['bulkPromoteBtn', 'bulkPromoteLabel', '선택 재사용 풀 승격'], ['bulkDisableBtn', 'bulkDisableLabel', '선택 비활성화']]
        .forEach(([buttonId, labelId, baseLabel]) => {
            document.getElementById(buttonId).disabled = selectedCount === 0;
            document.getElementById(labelId).textContent = selectedCount > 0 ? `${baseLabel} (${selectedCount})` : baseLabel;
        });
}

/** 확인 창 > 일괄 요청 > 새로고침 토스트 (결과: updated·skipped) */
async function runChoiceSetBulk(url, confirmMessage, confirmOptions, doneLabel) {
    const choiceSetUuids = getSelectedChoiceSetUuids();
    if (choiceSetUuids.length === 0) return;
    if (!await AdminUi.confirmDanger(confirmMessage.replace('{count}', choiceSetUuids.length), confirmOptions)) return;
    AdminApi.put(url, { choiceSetUuids })
        .then(result => AdminUi.reloadWithToast(`${doneLabel}: ${result.updated}건 처리, ${result.skipped}건 건너뜀`))
        .catch(error => AdminUi.showError(error));
}

function bulkDisableChoiceSets() {
    runChoiceSetBulk('/admin/choice-sets/bulk-disable',
        '선택한 {count}개 세트를 비활성화합니다. 이미 비활성인 세트는 건너뜁니다.',
        { title: '선택 세트를 비활성화할까요?', confirmLabel: '비활성화' }, '비활성화 완료');
}

function bulkPromoteChoiceSets() {
    runChoiceSetBulk('/admin/choice-sets/bulk-promote',
        '선택한 {count}개 세트를 관리자 큐레이션 출처로 바꾸고 재사용 풀에 넣습니다. 상태가 OK 가 아닌 세트는 건너뜁니다.',
        { title: '선택 세트를 재사용 풀로 승격할까요?', confirmLabel: '승격' }, '승격 완료');
}
