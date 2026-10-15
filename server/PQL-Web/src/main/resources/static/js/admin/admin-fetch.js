/**
 * 관리자 화면 공통: CSRF 헤더, JSON 요청, 오류 메시지 해석, 토스트, 위험 동작 확인 창
 * layout.html <head> 에서 페이지 스크립트보다 먼저 로드
 */
(function () {
    'use strict';

    // 새로고침 뒤 보여 줄 토스트 (sessionStorage 키)
    const FLASH_TOAST_STORAGE_KEY = 'passqlAdminFlashToast';
    // 토스트 표시 시간 (밀리초)
    const TOAST_VISIBLE_MILLISECONDS = 3500;
    // 서버가 본문 없이 실패했을 때 상태 코드별 기본 문구
    const DEFAULT_ERROR_MESSAGE_BY_STATUS = {
        401: '로그인이 만료되었습니다. 다시 로그인해 주세요.',
        403: '권한이 없습니다. 조회 전용 계정은 변경할 수 없습니다.',
        404: '대상을 찾을 수 없습니다.',
        429: '요청이 많습니다. 잠시 후 다시 시도해 주세요.'
    };

    // ── CSRF: 같은 출처 변경 요청(GET/HEAD 외)에 토큰 공통 부착 (#391) ──
    const csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
    const csrfHeaderName = document.querySelector('meta[name="_csrf_header"]')?.content;
    if (csrfToken && csrfHeaderName) {
        const originalFetch = window.fetch.bind(window);
        window.fetch = function (input, init) {
            const method = ((init && init.method) || (input instanceof Request ? input.method : 'GET')).toUpperCase();
            const url = new URL(input instanceof Request ? input.url : String(input), location.href);
            if (method === 'GET' || method === 'HEAD' || url.origin !== location.origin) {
                return originalFetch(input, init);
            }
            const headers = new Headers((init && init.headers) || (input instanceof Request ? input.headers : undefined));
            if (!headers.has(csrfHeaderName)) headers.set(csrfHeaderName, csrfToken);
            return originalFetch(input, { ...init, headers });
        };
    }

    /** 서버 오류 응답 ({errorCode, message}) 보관용 오류 */
    class AdminApiError extends Error {
        constructor(message, status, errorCode) {
            super(message);
            this.status = status;
            this.errorCode = errorCode;
        }
    }

    /** 응답 > 본문 (JSON 이면 객체, 비었으면 null), 실패 시 AdminApiError */
    async function readResponseBody(response) {
        const text = await response.text();
        let body = null;
        if (text) {
            try { body = JSON.parse(text); } catch (ignored) { body = text; }
        }
        if (response.ok) return body;
        const serverMessage = body && typeof body === 'object' ? body.message : null;
        const message = serverMessage || DEFAULT_ERROR_MESSAGE_BY_STATUS[response.status]
            || ('요청을 처리하지 못했습니다. (' + response.status + ')');
        throw new AdminApiError(message, response.status, body && body.errorCode);
    }

    /**
     * JSON 요청 1건: body 객체 > JSON 직렬화, 응답 JSON 해석, 실패 시 AdminApiError
     * 네트워크 실패도 AdminApiError(status 0)로 통일
     */
    async function request(url, options = {}) {
        const headers = { 'Accept': 'application/json', 'X-Requested-With': 'fetch', ...(options.headers || {}) };
        const init = { method: options.method || 'GET', headers };
        if (options.body !== undefined) {
            headers['Content-Type'] = 'application/json';
            init.body = JSON.stringify(options.body);
        }
        let response;
        try {
            response = await fetch(url, init);
        } catch (networkError) {
            throw new AdminApiError('네트워크 오류가 발생했습니다.', 0, null);
        }
        return readResponseBody(response);
    }

    // ── 토스트 ──
    function ensureToastContainer() {
        let container = document.getElementById('adminToastContainer');
        if (!container) {
            container = document.createElement('div');
            container.id = 'adminToastContainer';
            container.className = 'toast toast-top toast-end z-[1000]';
            document.body.appendChild(container);
        }
        return container;
    }

    /** 토스트 1건 (type: success | error | info | warning) */
    function toast(message, type = 'success') {
        const alertElement = document.createElement('div');
        alertElement.className = 'alert alert-' + type + ' shadow-lg max-w-sm';
        alertElement.setAttribute('role', type === 'error' ? 'alert' : 'status');
        const textElement = document.createElement('span');
        textElement.className = 'whitespace-pre-line break-words';
        textElement.textContent = message;
        alertElement.appendChild(textElement);
        ensureToastContainer().appendChild(alertElement);
        setTimeout(() => alertElement.remove(), type === 'error' ? TOAST_VISIBLE_MILLISECONDS * 2 : TOAST_VISIBLE_MILLISECONDS);
    }

    /** 오류 > 오류 토스트 (AdminApiError 는 서버 message 그대로) */
    function showError(error, fallbackMessage) {
        const message = (error && error.message) || fallbackMessage || '요청을 처리하지 못했습니다.';
        toast(message, 'error');
    }

    /** 새로고침 뒤 토스트 예약 > 새로고침 */
    function reloadWithToast(message, type = 'success') {
        try { sessionStorage.setItem(FLASH_TOAST_STORAGE_KEY, JSON.stringify({ message, type })); } catch (ignored) { }
        location.reload();
    }

    /** 이동 뒤 토스트 예약 > 이동 */
    function navigateWithToast(url, message, type = 'success') {
        try { sessionStorage.setItem(FLASH_TOAST_STORAGE_KEY, JSON.stringify({ message, type })); } catch (ignored) { }
        location.href = url;
    }

    function showReservedFlashToast() {
        let reserved = null;
        try {
            reserved = JSON.parse(sessionStorage.getItem(FLASH_TOAST_STORAGE_KEY) || 'null');
            sessionStorage.removeItem(FLASH_TOAST_STORAGE_KEY);
        } catch (ignored) { }
        if (reserved && reserved.message) toast(reserved.message, reserved.type || 'success');
        // 서버 리다이렉트 플래시 (layout.html adminFlashToast)
        const serverFlash = document.getElementById('adminFlashToast');
        if (serverFlash && serverFlash.dataset.message) toast(serverFlash.dataset.message, 'success');
    }

    // ── 위험 동작 확인 창 (daisyUI modal, Promise<boolean>) ──
    function confirmDanger(message, options = {}) {
        const confirmLabel = options.confirmLabel || '확인';
        const title = options.title || '확인이 필요합니다';
        return new Promise(resolve => {
            const dialog = document.createElement('dialog');
            dialog.className = 'modal';
            dialog.innerHTML =
                '<div class="modal-box">' +
                '  <h3 class="font-bold text-lg text-error" data-role="title"></h3>' +
                '  <p class="py-4 whitespace-pre-line" data-role="message"></p>' +
                '  <div class="modal-action">' +
                '    <button type="button" class="btn btn-ghost" data-role="cancel">취소</button>' +
                '    <button type="button" class="btn btn-error" data-role="confirm"></button>' +
                '  </div>' +
                '</div>' +
                '<form method="dialog" class="modal-backdrop"><button>close</button></form>';
            dialog.querySelector('[data-role="title"]').textContent = title;
            dialog.querySelector('[data-role="message"]').textContent = message;
            dialog.querySelector('[data-role="confirm"]').textContent = confirmLabel;

            let isConfirmed = false;
            dialog.querySelector('[data-role="confirm"]').addEventListener('click', () => { isConfirmed = true; dialog.close(); });
            dialog.querySelector('[data-role="cancel"]').addEventListener('click', () => dialog.close());
            dialog.addEventListener('close', () => { dialog.remove(); resolve(isConfirmed); });
            document.body.appendChild(dialog);
            dialog.showModal();
        });
    }

    /** HTML 이스케이프 (innerHTML 템플릿용) */
    function escapeHtml(value) {
        if (value === null || value === undefined) return '';
        return String(value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    document.addEventListener('DOMContentLoaded', showReservedFlashToast);

    window.AdminApi = {
        request,
        get: (url) => request(url),
        post: (url, body) => request(url, { method: 'POST', body }),
        put: (url, body) => request(url, { method: 'PUT', body }),
        delete: (url, body) => request(url, { method: 'DELETE', body }),
        AdminApiError
    };
    window.AdminUi = { toast, showError, reloadWithToast, navigateWithToast, confirmDanger, escapeHtml };
})();
