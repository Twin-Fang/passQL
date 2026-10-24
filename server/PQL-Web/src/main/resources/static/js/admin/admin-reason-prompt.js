/**
 * 관리자 공통: 처리 사유 입력 창 (daisyUI modal, Promise<string|null>)
 * 취소 > null, 확인 > 입력한 사유 (비워도 확인 가능, 앞뒤 공백 제거)
 * admin-fetch.js 의 confirmDanger 와 같은 방식 (alert·prompt 금지)
 */
(function () {
    'use strict';

    // 사유 입력 기본 최대 글자 수
    const DEFAULT_MAXIMUM_LENGTH = 200;

    /**
     * options: title, message, confirmLabel, placeholder, maximumLength, isDanger(확인 버튼 색)
     */
    function ask(options = {}) {
        const maximumLength = options.maximumLength || DEFAULT_MAXIMUM_LENGTH;
        return new Promise(resolve => {
            const dialog = document.createElement('dialog');
            dialog.className = 'modal';
            dialog.innerHTML =
                '<div class="modal-box">' +
                '  <h3 class="font-bold text-lg" data-role="title"></h3>' +
                '  <p class="py-3 whitespace-pre-line text-sm" data-role="message"></p>' +
                '  <textarea class="textarea textarea-bordered w-full" rows="3" data-role="reason"></textarea>' +
                '  <div class="modal-action">' +
                '    <button type="button" class="btn btn-ghost" data-role="cancel">취소</button>' +
                '    <button type="button" class="btn" data-role="confirm"></button>' +
                '  </div>' +
                '</div>' +
                '<form method="dialog" class="modal-backdrop"><button>close</button></form>';
            dialog.querySelector('[data-role="title"]').textContent = options.title || '처리 사유';
            dialog.querySelector('[data-role="message"]').textContent = options.message || '';
            const reasonInput = dialog.querySelector('[data-role="reason"]');
            reasonInput.placeholder = options.placeholder || '처리 사유 (선택, ' + maximumLength + '자)';
            reasonInput.maxLength = maximumLength;
            const confirmButton = dialog.querySelector('[data-role="confirm"]');
            confirmButton.textContent = options.confirmLabel || '확인';
            confirmButton.classList.add(options.isDanger ? 'btn-error' : 'btn-primary');

            let reason = null;
            confirmButton.addEventListener('click', () => { reason = reasonInput.value.trim(); dialog.close(); });
            dialog.querySelector('[data-role="cancel"]').addEventListener('click', () => dialog.close());
            dialog.addEventListener('close', () => { dialog.remove(); resolve(reason); });
            document.body.appendChild(dialog);
            dialog.showModal();
            reasonInput.focus();
        });
    }

    window.AdminReasonPrompt = { ask };
})();
