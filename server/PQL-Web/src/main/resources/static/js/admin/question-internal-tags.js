/**
 * 문제 내부 관리 태그 (#1117): 목록 일괄 붙이기·떼기, 태그 요약, 상세 화면 태그 교체
 * 규칙(정규화·검증)은 서버 QuestionInternalTagRule 단일 지점 > 여기서는 입력 분리만
 */

// 관리자 문제 목록 경로 (요약 값 누르면 태그 필터로 이동)
const INTERNAL_TAG_LIST_PATH = '/admin/questions';

/** 입력 문자열 > 태그 목록 (쉼표·줄바꿈 구분, 빈 항목 제외) */
function parseInternalTagInput(text) {
    return (text || '').split(/[,\n]/).map(tag => tag.trim()).filter(tag => tag.length > 0);
}

function openBulkInternalTagModal() {
    const questionUuids = getSelectedUuids();
    if (questionUuids.length === 0) {
        AdminUi.toast('태그를 바꿀 문제를 선택해주세요.', 'warning');
        return;
    }
    document.getElementById('bulkInternalTagCount').textContent = questionUuids.length;
    document.getElementById('bulkInternalTagAdd').value = '';
    document.getElementById('bulkInternalTagRemove').value = '';
    document.getElementById('bulkInternalTagModal').showModal();
}

/** 일괄 붙이기·떼기 요청 > 결과 토스트 후 새로고침 */
function confirmBulkInternalTag() {
    const addTags = parseInternalTagInput(document.getElementById('bulkInternalTagAdd').value);
    const removeTags = parseInternalTagInput(document.getElementById('bulkInternalTagRemove').value);
    if (addTags.length === 0 && removeTags.length === 0) {
        AdminUi.toast('붙이거나 뗄 태그를 입력해주세요.', 'warning');
        return;
    }
    const confirmButton = document.getElementById('bulkInternalTagConfirmBtn');
    confirmButton.disabled = true;
    AdminApi.put('/admin/questions/internal-tags', { questionUuids: getSelectedUuids(), addTags, removeTags })
        .then(result => {
            document.getElementById('bulkInternalTagModal').close();
            const limitExceededCount = result.tagLimitExceededQuestionUuids.length;
            const limitMessage = limitExceededCount > 0 ? `, 최대 개수 초과 ${limitExceededCount}건 건너뜀` : '';
            AdminUi.reloadWithToast(`태그 변경 완료: ${result.changedCount}건 변경${limitMessage}`);
        })
        .catch(error => {
            confirmButton.disabled = false;
            AdminUi.showError(error);
        });
}

/** 태그 요약 모달: 네임스페이스별 값·문제 수 (활성/전체), 값·묶음 이름 누르면 목록 필터 */
function openInternalTagSummaryModal() {
    const body = document.getElementById('internalTagSummaryBody');
    body.innerHTML = '<div class="flex justify-center py-8"><span class="loading loading-spinner"></span></div>';
    document.getElementById('internalTagSummaryModal').showModal();
    AdminApi.get('/admin/questions/internal-tags/summary')
        .then(summaryGroups => {
            body.innerHTML = summaryGroups.length === 0
                ? '<p class="text-sm text-base-content/60">붙은 태그가 없습니다.</p>'
                : summaryGroups.map(renderInternalTagSummaryGroup).join('');
        })
        .catch(error => {
            body.innerHTML = '';
            AdminUi.showError(error);
        });
}

/** 요약 묶음 1개 HTML (네임스페이스 묶음은 이름에 전체 필터 링크 source:*) */
function renderInternalTagSummaryGroup(summaryGroup) {
    const escapeHtml = AdminUi.escapeHtml;
    const groupTitle = summaryGroup.namespacePrefix
        ? `<a class="link" href="${toInternalTagFilterUrl(summaryGroup.namespacePrefix + ':*')}">${escapeHtml(summaryGroup.label)} (${escapeHtml(summaryGroup.namespacePrefix)}:*)</a>`
        : escapeHtml(summaryGroup.label);
    const tagLinks = summaryGroup.tagCounts.map(tagCount =>
        `<a class="badge badge-outline gap-1" href="${toInternalTagFilterUrl(tagCount.tag)}" title="${escapeHtml(tagCount.tag)}">`
        + `${escapeHtml(tagCount.value)} <span class="text-base-content/60">${tagCount.activeQuestionCount}/${tagCount.questionCount}</span></a>`
    ).join(' ');
    return `<div class="mb-4"><p class="font-semibold text-sm mb-2">${groupTitle}</p>`
        + `<div class="flex flex-wrap gap-1">${tagLinks}</div></div>`;
}

/** 태그 필터 목록 URL (상태 전체: 비활성 문제 태그도 보이게) */
function toInternalTagFilterUrl(tagFilter) {
    const searchParams = new URLSearchParams({ internalTags: tagFilter, activeState: 'ALL' });
    return `${INTERNAL_TAG_LIST_PATH}?${searchParams.toString()}`;
}

/** 상세 화면 태그 교체: 입력 전체를 새 태그 목록으로 저장 > 새로고침 */
function saveQuestionInternalTags(questionUuid) {
    const tags = parseInternalTagInput(document.getElementById('questionInternalTagInput').value);
    const saveButton = document.getElementById('questionInternalTagSaveBtn');
    saveButton.disabled = true;
    AdminApi.put(`/admin/questions/${questionUuid}/internal-tags`, { tags })
        .then(savedTags => AdminUi.reloadWithToast(`내부 태그 ${savedTags.length}개 저장`))
        .catch(error => {
            saveButton.disabled = false;
            AdminUi.showError(error);
        });
}
