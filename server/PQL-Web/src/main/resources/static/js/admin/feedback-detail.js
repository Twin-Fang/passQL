/**
 * 의견 상세 화면: 상태 변경, 관리자 메모 저장, 로그 뷰어 맨 아래로 스크롤
 * API: /admin/feedbacks (AdminApi 공통 요청)
 */
(function () {
    'use strict';

    const FEEDBACK_API_BASE = '/admin/feedbacks';
    const feedbackUuid = document.getElementById('feedbackDetailRoot').dataset.uuid;

    document.getElementById('feedbackStatusSaveButton').addEventListener('click', () => {
        const status = document.getElementById('feedbackStatusSelect').value;
        AdminApi.post(FEEDBACK_API_BASE + '/' + feedbackUuid + '/status', { status })
            .then(() => AdminUi.reloadWithToast('상태를 변경했습니다.'))
            .catch(error => AdminUi.showError(error));
    });

    document.getElementById('feedbackMemoSaveButton').addEventListener('click', () => {
        const adminMemo = document.getElementById('feedbackMemo').value;
        AdminApi.put(FEEDBACK_API_BASE + '/' + feedbackUuid + '/memo', { adminMemo })
            .then(() => AdminUi.reloadWithToast('메모를 저장했습니다.'))
            .catch(error => AdminUi.showError(error));
    });

    // 로그는 뒤쪽(최근)이 중요하므로 맨 아래부터 보여 줌
    const logViewer = document.getElementById('feedbackLogViewer');
    if (logViewer) {
        logViewer.scrollTop = logViewer.scrollHeight;
    }

    // 이미지 로드 실패 시 자리 표시 문구로 교체
    document.querySelectorAll('.feedback-image').forEach(image => {
        image.addEventListener('error', () => {
            image.closest('a').outerHTML = '<div class="flex items-center justify-center size-32 bg-base-200 rounded text-xs text-base-content/50">불러올 수 없음</div>';
        });
    });
})();
