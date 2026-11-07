/**
 * 관리자 문제 저장 전 형식 검사 (#905): data-format-check 폼 제출 > 서버 검사(저장 관문과 같은 판정) > 막는 위반 있으면 중단·사유 표시
 * 폼 속성 2개: data-question-uuid(편집, 저장본에 있던 사유는 경고), data-execution-mode(실행 모드 입력 없는 폼)
 */
(function () {
    'use strict';

    const CHECK_URL = '/admin/api/question-format/check';
    const RESULT_ELEMENT_CLASS = 'question-format-check-result';

    // 폼 입력 1개 값 (라디오는 고른 값, 없으면 null)
    function readField(form, name) {
        const field = form.elements.namedItem(name);
        if (!field) return null;
        return field.value === undefined || field.value === '' ? null : field.value;
    }

    // AI 생성 검수 폼의 보기 (choiceKeys·choiceBodies·choiceRationales 순서 대응, SQL 보기)
    function readChoices(form) {
        const keys = Array.from(form.querySelectorAll('[name="choiceKeys"]')).map(input => input.value);
        if (keys.length === 0) return null;
        const bodies = Array.from(form.querySelectorAll('[name="choiceBodies"]')).map(input => input.value);
        const rationales = Array.from(form.querySelectorAll('[name="choiceRationales"]')).map(input => input.value);
        return keys.map((choiceKey, index) => ({
            choiceKey, kind: 'SQL', body: bodies[index] || '', rationale: rationales[index] || '', isCorrect: null
        }));
    }

    function toRequest(form) {
        return {
            questionUuid: form.dataset.questionUuid || null,
            stem: readField(form, 'stem'),
            hint: readField(form, 'hint'),
            schemaDdl: readField(form, 'schemaDdl'),
            schemaSampleData: readField(form, 'schemaSampleData'),
            executionMode: readField(form, 'executionMode') || form.dataset.executionMode || null,
            choices: readChoices(form)
        };
    }

    function toViolationItems(violations) {
        return violations.map(violation =>
            '<li><span class="badge badge-outline badge-sm mr-1">' + AdminUi.escapeHtml(violation.reasonDisplayName) + '</span>'
            + AdminUi.escapeHtml(violation.location) + ': ' + AdminUi.escapeHtml(violation.detail) + '</li>').join('');
    }

    // 결과 상자 (막는 위반 > 오류색, 기존 위반 > 경고색), 폼 맨 위에 하나만
    function renderResult(form, response) {
        let resultElement = form.querySelector('.' + RESULT_ELEMENT_CLASS);
        if (!resultElement) {
            resultElement = document.createElement('div');
            resultElement.className = RESULT_ELEMENT_CLASS + ' space-y-2';
            form.prepend(resultElement);
        }
        let html = '';
        if (response.blockingViolations.length > 0) {
            html += '<div class="alert alert-error items-start"><div><p class="font-semibold">형식 규칙 위반 '
                + response.blockingViolations.length + '건: 고친 뒤 저장</p><ul class="text-sm mt-1 space-y-1">'
                + toViolationItems(response.blockingViolations) + '</ul></div></div>';
        }
        if (response.existingViolations.length > 0) {
            html += '<div class="alert alert-warning items-start"><div><p class="font-semibold">기존 형식 위반 '
                + response.existingViolations.length + '건 (저장은 됨, 문제 형식 검사 화면에서 정리)</p><ul class="text-sm mt-1 space-y-1">'
                + toViolationItems(response.existingViolations) + '</ul></div></div>';
        }
        resultElement.innerHTML = html;
        if (html) resultElement.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    async function onSubmit(event) {
        const form = event.currentTarget;
        if (form.dataset.formatChecked === 'true') return;
        event.preventDefault();
        try {
            const response = await AdminApi.post(CHECK_URL, toRequest(form));
            renderResult(form, response);
            if (!response.canSave) {
                AdminUi.toast('형식 규칙 위반이 있어 저장하지 않았습니다.', 'error');
                return;
            }
            // 통과 > 기본 제출 (submit() 은 submit 이벤트를 다시 부르지 않음)
            form.dataset.formatChecked = 'true';
            form.submit();
        } catch (error) {
            AdminUi.showError(error, '형식 검사를 하지 못했습니다.');
        }
    }

    document.addEventListener('DOMContentLoaded', () => {
        document.querySelectorAll('form[data-format-check]').forEach(form => form.addEventListener('submit', onSubmit));
    });
})();
