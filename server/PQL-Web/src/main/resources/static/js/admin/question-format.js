/**
 * 관리자 문제 형식 검사 화면 (#905): 자동 정리 미리보기(문제별 필드 전후) > 고른 문제 적용 > 새로고침
 * 적용 내용은 서버가 다시 계산 (화면은 문제 UUID 만 보냄)
 */
(function () {
    'use strict';

    const PREVIEW_URL = '/admin/api/question-format/auto-fix/preview';
    const APPLY_URL = '/admin/api/question-format/auto-fix/apply';

    const previewButton = document.getElementById('formatFixPreviewButton');
    const applyButton = document.getElementById('formatFixApplyButton');
    const applyLabel = document.getElementById('formatFixApplyLabel');
    const previewContainer = document.getElementById('formatFixPreviewContainer');
    const escapeHtml = AdminUi.escapeHtml;

    function selectedQuestionUuids() {
        return Array.from(previewContainer.querySelectorAll('input[data-role="fix-select"]:checked'))
            .map(checkbox => checkbox.value);
    }

    function updateApplyButton() {
        const selectedCount = selectedQuestionUuids().length;
        applyButton.disabled = selectedCount === 0;
        applyLabel.textContent = selectedCount > 0 ? '선택 적용 (' + selectedCount + '문제)' : '선택 적용';
    }

    // 필드 1개 전후 (나란히, 긴 글은 상자 안 스크롤)
    function renderChange(change) {
        return '<div class="mt-2"><p class="text-xs font-semibold">' + escapeHtml(change.fieldName) + '</p>'
            + '<div class="grid grid-cols-1 md:grid-cols-2 gap-2">'
            + '<pre class="text-xs bg-error/5 rounded p-2 whitespace-pre-wrap break-words max-h-64 overflow-auto">'
            + escapeHtml(change.before || '') + '</pre>'
            + '<pre class="text-xs bg-success/5 rounded p-2 whitespace-pre-wrap break-words max-h-64 overflow-auto">'
            + escapeHtml(change.after || '') + '</pre></div></div>';
    }

    // 문제 1개: 선택 상자 + 지문 앞부분 + 정리 이름 + 펼치면 필드 전후
    function renderPreviewItem(preview) {
        const fixBadges = preview.fixNames.map(name => '<span class="badge badge-success badge-outline badge-sm">' + escapeHtml(name) + '</span>').join(' ');
        const mockExamBadge = preview.mockExamLabel
            ? '<span class="badge badge-info badge-sm">모의고사 ' + escapeHtml(preview.mockExamLabel) + '</span>' : '';
        return '<div class="border border-base-300 rounded-lg p-3">'
            + '<div class="flex flex-wrap items-center gap-2">'
            + '<input type="checkbox" class="checkbox checkbox-sm" data-role="fix-select" checked value="' + escapeHtml(preview.questionUuid) + '">'
            + '<a class="link link-hover text-sm mr-auto" href="/admin/questions/' + encodeURIComponent(preview.questionUuid) + '">'
            + escapeHtml(preview.stemPreview) + '</a>' + mockExamBadge + fixBadges + '</div>'
            + '<details class="mt-1"><summary class="text-xs cursor-pointer">바뀌는 필드 ' + preview.changes.length + '개</summary>'
            + preview.changes.map(renderChange).join('') + '</details></div>';
    }

    async function loadPreview() {
        previewButton.disabled = true;
        previewContainer.innerHTML = '<span class="loading loading-spinner loading-sm"></span>';
        try {
            const previews = await AdminApi.get(PREVIEW_URL);
            if (previews.length === 0) {
                previewContainer.innerHTML = '<p class="text-sm text-base-content/60">자동으로 고칠 문제가 없습니다.</p>';
            } else {
                previewContainer.innerHTML = '<label class="flex items-center gap-2 text-sm"><input type="checkbox" class="checkbox checkbox-sm" data-role="fix-select-all" checked>'
                    + '전체 선택 (' + previews.length + '문제)</label>'
                    + '<div class="space-y-2 max-h-[60vh] overflow-auto">' + previews.map(renderPreviewItem).join('') + '</div>';
            }
        } catch (error) {
            previewContainer.innerHTML = '';
            AdminUi.showError(error, '미리보기를 불러오지 못했습니다.');
        } finally {
            previewButton.disabled = false;
            updateApplyButton();
        }
    }

    async function applySelected() {
        const questionUuids = selectedQuestionUuids();
        if (questionUuids.length === 0) return;
        const isConfirmed = await AdminUi.confirmDanger(questionUuids.length + '문제의 지문·스키마·보기 글을 미리보기대로 바꿉니다.\n감사 로그에 문제마다 남습니다.',
            { title: '형식 자동 정리 적용', confirmLabel: '적용' });
        if (!isConfirmed) return;
        applyButton.disabled = true;
        try {
            const applyResult = await AdminApi.post(APPLY_URL, { questionUuids });
            AdminUi.reloadWithToast('정리 ' + applyResult.fixedQuestionCount + '문제 (필드 ' + applyResult.changedFieldCount + '개), 바뀐 것 없음 '
                + applyResult.unchangedQuestionCount + '문제');
        } catch (error) {
            AdminUi.showError(error, '정리를 적용하지 못했습니다.');
            updateApplyButton();
        }
    }

    previewContainer.addEventListener('change', event => {
        if (event.target.dataset.role === 'fix-select-all') {
            previewContainer.querySelectorAll('input[data-role="fix-select"]').forEach(checkbox => {
                checkbox.checked = event.target.checked;
            });
        }
        updateApplyButton();
    });
    previewButton.addEventListener('click', loadPreview);
    applyButton.addEventListener('click', applySelected);
})();
