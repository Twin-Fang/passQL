/**
 * 관리자 앱 운영 공지 영역: 등록·수정 모달, 마크다운 미리보기, 삭제·활성 전환, 결과 토스트
 */
(function () {
    'use strict';

    function showToast(message, type) {
        const toast = document.getElementById('toast');
        document.getElementById('toastAlert').className = 'alert ' + (type === 'error' ? 'alert-error' : 'alert-success');
        document.getElementById('toastMessage').textContent = message;
        toast.classList.remove('hidden');
        setTimeout(() => toast.classList.add('hidden'), 4000);
    }

    // 실패 응답 본문(ErrorResponse) 의 message 우선
    async function readErrorMessage(response, fallbackMessage) {
        try {
            const body = await response.json();
            return body.message || fallbackMessage;
        } catch (e) {
            return fallbackMessage;
        }
    }

    // 공지 모달 열기 (dataset 없으면 새 공지)
    function openNoticeModal(dataset) {
        document.getElementById('noticeModalTitle').textContent = dataset ? '공지 수정' : '새 공지';
        document.getElementById('noticeUuid').value = dataset ? dataset.uuid : '';
        document.getElementById('noticeTitle').value = dataset ? dataset.title : '';
        document.getElementById('noticeBody').value = dataset ? dataset.body : '';
        document.getElementById('noticeStartsAt').value = dataset ? dataset.startsAt : '';
        document.getElementById('noticeEndsAt').value = dataset ? dataset.endsAt : '';
        document.getElementById('noticeIsActive').checked = dataset ? dataset.isActive === 'true' : true;
        document.getElementById('noticeIsImportant').checked = dataset ? dataset.isImportant === 'true' : false;
        document.getElementById('noticeDisplayPriority').value = dataset ? dataset.displayPriority : 0;
        document.getElementById('noticePreview').classList.add('hidden');
        document.getElementById('noticeSendPush').checked = false;
        document.getElementById('noticeSendPushField').classList.toggle('hidden', !!dataset);
        document.getElementById('noticeModal').showModal();
    }

    // 공지 저장: uuid 있으면 수정(PUT), 없으면 등록(POST)
    async function saveNotice() {
        const noticeUuid = document.getElementById('noticeUuid').value;
        const request = {
            title: document.getElementById('noticeTitle').value,
            body: document.getElementById('noticeBody').value,
            startsAt: document.getElementById('noticeStartsAt').value || null,
            endsAt: document.getElementById('noticeEndsAt').value || null,
            isActive: document.getElementById('noticeIsActive').checked,
            isImportant: document.getElementById('noticeIsImportant').checked,
            displayPriority: parseInt(document.getElementById('noticeDisplayPriority').value, 10) || 0
        };
        const isPushRequested = !noticeUuid && document.getElementById('noticeSendPush').checked;
        const url = noticeUuid ? '/admin/app-operation/notices/' + encodeURIComponent(noticeUuid)
            : '/admin/app-operation/notices?sendPush=' + isPushRequested;
        const response = await fetch(url, {
            method: noticeUuid ? 'PUT' : 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(request)
        });
        if (response.ok) {
            await announcePushResult(response, noticeUuid, isPushRequested);
            location.reload();
        } else {
            showToast(await readErrorMessage(response, '공지 저장에 실패했습니다.'), 'error');
        }
    }

    // 공지 등록 응답의 푸시 결과 안내 (실패는 등록이 끝났음을 알리고 3초 보여 줌)
    async function announcePushResult(response, noticeUuid, isPushRequested) {
        if (noticeUuid || !isPushRequested) return;
        const pushResult = (await response.json()).pushResult;
        const messageByResult = {
            SENT: ['공지를 등록하고 푸시를 발송했습니다.', 'success'],
            SCHEDULED: ['공지를 등록하고 노출 시작 시각에 푸시를 예약했습니다.', 'success'],
            SKIPPED: ['공지를 등록했습니다. 비활성 공지라 푸시는 보내지 않았습니다.', 'success'],
            FAILED: ['공지는 등록됐지만 푸시 발송에 실패했습니다. 알림 발송 화면에서 다시 보내 주세요.', 'error']
        };
        const [message, type] = messageByResult[pushResult];
        showToast(message, type);
        await new Promise(resolve => setTimeout(resolve, 3000));
    }

    // HTML 이스케이프 (미리보기 본문은 입력 그대로 innerHTML 에 넣지 않는다)
    function escapeHtml(text) {
        return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    // 한 줄 안 서식: **굵게**, [이름](https://링크)
    function renderInlineMarkdown(line) {
        return escapeHtml(line)
            .replace(/\*\*(.+?)\*\*/g, '<b>$1</b>')
            .replace(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/g, '<a class="link link-primary" href="$2" target="_blank" rel="noopener noreferrer">$1</a>');
    }

    // 본문 > 문단(빈 줄 구분) / 목록(- 로 시작하는 줄) HTML
    function renderMarkdownPreview(markdown) {
        return markdown.trim().split(/\n{2,}/).map(block => {
            const lines = block.split('\n');
            if (lines.every(line => line.trim().startsWith('- '))) {
                return '<ul class="list-disc pl-5">' + lines.map(line => '<li>' + renderInlineMarkdown(line.trim().slice(2)) + '</li>').join('') + '</ul>';
            }
            return '<p>' + lines.map(renderInlineMarkdown).join('<br>') + '</p>';
        }).join('');
    }

    // 미리보기 토글 (입력 중인 제목·본문 기준)
    function toggleNoticePreview() {
        const preview = document.getElementById('noticePreview');
        document.getElementById('noticePreviewTitle').textContent = document.getElementById('noticeTitle').value;
        document.getElementById('noticePreviewBody').innerHTML = renderMarkdownPreview(document.getElementById('noticeBody').value);
        preview.classList.toggle('hidden');
    }

    // 공지 삭제: 확인 > DELETE (읽음 기록도 함께 정리, 숨기기만 원하면 비활성화)
    async function deleteNotice(noticeUuid, title) {
        if (!confirm('"' + title + '" 공지를 삭제합니다. 되돌릴 수 없습니다. 숨기기만 원하면 비활성화를 쓰세요.')) return;
        const response = await fetch('/admin/app-operation/notices/' + encodeURIComponent(noticeUuid), {method: 'DELETE'});
        if (response.ok) {
            location.reload();
        } else {
            showToast(await readErrorMessage(response, '삭제에 실패했습니다.'), 'error');
        }
    }

    async function changeNoticeActive(noticeUuid, isActive) {
        const response = await fetch('/admin/app-operation/notices/' + encodeURIComponent(noticeUuid) + '/active', {
            method: 'PUT',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({isActive: isActive})
        });
        if (response.ok) {
            location.reload();
        } else {
            showToast(await readErrorMessage(response, '상태 변경에 실패했습니다.'), 'error');
        }
    }

    window.openNoticeModal = openNoticeModal;
    window.saveNotice = saveNotice;
    window.toggleNoticePreview = toggleNoticePreview;
    window.deleteNotice = deleteNotice;
    window.changeNoticeActive = changeNoticeActive;
})();
