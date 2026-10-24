/**
 * 임베딩 관리 화면: 전체 색인 시작·진행률 폴링, 실패 재시도, 미색인 선택 색인
 * 진행률 = GET /admin/embeddings/progress (서버 메모리 상태), 끝나면 새로고침해 이력·상태 갱신
 */
(function () {
    'use strict';

    // 진행률 조회 간격 (밀리초)
    const PROGRESS_POLL_INTERVAL_MILLISECONDS = 2000;

    // 진행 중인 실행을 화면에서 지켜보는지 (끝나면 새로고침해 결과 표시)
    let isWatchingRun = false;

    function setActionButtonsDisabled(isDisabled) {
        ['indexAllButton', 'retryFailedButton', 'indexSelectedBtn'].forEach(buttonId => {
            const button = document.getElementById(buttonId);
            if (button) button.disabled = isDisabled;
        });
    }

    /** 진행률 > 막대·문구 (totalCount 0 은 대상 문제를 모으는 중) */
    function renderProgress(progress) {
        const progressPanel = document.getElementById('progressPanel');
        progressPanel.classList.remove('hidden');
        const runLabel = progress.runType === 'RETRY_FAILED' ? '실패 문제 재시도 중...' : '전체 색인 중...';
        document.getElementById('progressLabel').textContent = progress.totalCount === 0 ? '대상 문제를 준비하는 중...' : runLabel;
        document.getElementById('progressCounts').textContent = progress.totalCount === 0 ? '' :
            `${progress.processedCount} / ${progress.totalCount} (성공 ${progress.succeededCount}, 실패 ${progress.failedCount})`;
        const progressBar = document.getElementById('progressBar');
        progressBar.max = Math.max(progress.totalCount, 1);
        progressBar.value = progress.processedCount;
    }

    /** 진행률 1회 조회: 진행 중이면 표시·다음 조회 예약, 끝났으면 새로고침 */
    async function pollProgress() {
        try {
            const progress = await AdminApi.get('/admin/embeddings/progress');
            if (progress.isRunning) {
                isWatchingRun = true;
                setActionButtonsDisabled(true);
                renderProgress(progress);
                setTimeout(pollProgress, PROGRESS_POLL_INTERVAL_MILLISECONDS);
                return;
            }
            if (isWatchingRun) {
                // 지켜보던 실행이 끝남 > 결과(이력·상태) 새로고침
                AdminUi.reloadWithToast('색인이 끝났습니다. 실행 이력에서 결과를 확인하세요.');
            }
        } catch (error) {
            // 일시적인 조회 실패는 다음 주기에 다시 시도
            setTimeout(pollProgress, PROGRESS_POLL_INTERVAL_MILLISECONDS);
        }
    }

    /** 비동기 실행 시작 요청 > 진행률 폴링 시작 */
    async function startAsyncRun(url, startedMessage) {
        setActionButtonsDisabled(true);
        try {
            await AdminApi.post(url);
            AdminUi.toast(startedMessage);
            isWatchingRun = true;
            pollProgress();
        } catch (error) {
            AdminUi.showError(error);
            setActionButtonsDisabled(false);
        }
    }

    window.confirmIndexAll = function () {
        document.getElementById('confirmModal').showModal();
    };

    window.startIndexAll = function () {
        document.getElementById('confirmModal').close();
        startAsyncRun('/admin/embeddings/index-all', '전체 색인을 시작했습니다.');
    };

    window.retryFailed = function () {
        startAsyncRun('/admin/embeddings/retry-failed', '실패 문제 재시도를 시작했습니다.');
    };

    window.toggleSelectAllUnindexed = function (checkbox) {
        // 두 전체선택 체크박스를 동기화
        document.getElementById('selectAllUnindexed').checked = checkbox.checked;
        document.getElementById('selectAllUnindexed2').checked = checkbox.checked;
        document.querySelectorAll('.unindexed-checkbox').forEach(unindexedCheckbox => {
            unindexedCheckbox.checked = checkbox.checked;
        });
        updateIndexSelectedButton();
    };

    window.onUnindexedCheckboxChange = function () {
        const allCheckboxes = document.querySelectorAll('.unindexed-checkbox');
        const checkedCheckboxes = document.querySelectorAll('.unindexed-checkbox:checked');
        const isAllChecked = allCheckboxes.length > 0 && allCheckboxes.length === checkedCheckboxes.length;
        document.getElementById('selectAllUnindexed').checked = isAllChecked;
        document.getElementById('selectAllUnindexed2').checked = isAllChecked;
        updateIndexSelectedButton();
    };

    function updateIndexSelectedButton() {
        const checkedCount = document.querySelectorAll('.unindexed-checkbox:checked').length;
        document.getElementById('indexSelectedBtn').disabled = checkedCount === 0;
    }

    window.indexSelectedUnindexed = function () {
        const questionUuids = Array.from(document.querySelectorAll('.unindexed-checkbox:checked'))
            .map(unindexedCheckbox => unindexedCheckbox.dataset.uuid);
        if (questionUuids.length === 0) return;

        const indexSelectedButton = document.getElementById('indexSelectedBtn');
        indexSelectedButton.disabled = true;
        indexSelectedButton.innerHTML = '<span class="loading loading-spinner loading-xs"></span> 색인 중...';

        AdminApi.post('/admin/embeddings/index-selected', { uuids: questionUuids })
            .then(data => AdminUi.reloadWithToast(`색인 완료: ${data.succeeded}개 성공, ${data.failed}개 실패`))
            .catch(error => {
                AdminUi.showError(error);
                indexSelectedButton.disabled = false;
                indexSelectedButton.innerHTML = '<i data-lucide="zap" class="size-4"></i> 선택 색인';
                lucide.createIcons();
            });
    };

    lucide.createIcons();
    // 화면을 열었을 때 이미 진행 중인 색인이 있으면 이어서 표시
    pollProgress();
})();
