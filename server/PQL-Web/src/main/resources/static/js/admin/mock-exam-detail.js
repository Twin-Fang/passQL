/**
 * 관리자 모의고사 회차 상세 (#866): 회차 정보·상태별 동작(공개 검사·공개·보관·초안 되돌리기·삭제), 공개 검사 결과, 문항 표·교체, 탭 전환
 * 문항 통계 탭은 mock-exam-item-stats.js (MockExamItemStats)
 * API: /admin/api/mock-exams/rounds/{roundUuid} (publish-check, publish, archive, revert-to-draft, items/{itemUuid}/replace, DELETE)
 */
(function () {
    'use strict';

    const mockExam = MockExamAdmin;
    const { formatNumber, formatDateTime } = AdminChart;
    const escapeHtml = AdminUi.escapeHtml;
    const ITEM_TABLE_COLUMN_COUNT = 9;
    // 문제 UUID 형식 (지정 교체 입력 검사)
    const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    const UUID_TEXT_LENGTH = 36;

    const pageElement = document.getElementById('mockExamDetailPage');
    const roundUuid = pageElement.dataset.roundUuid;
    // 조회 전용(VIEWER) 계정이면 동작 버튼 비활성
    const canWriteAdmin = pageElement.dataset.canWriteAdmin === 'true';
    const roundApiPath = mockExam.API_BASE + '/rounds/' + encodeURIComponent(roundUuid);
    const itemTableBody = document.getElementById('itemTableBody');
    const roundActions = document.getElementById('roundActions');
    const publishCheckBox = document.getElementById('publishCheckBox');

    /**
     * 상태별 동작 6개: 키 > 버튼 문구·색, 보이는 상태, 응시 0건 조건, 확인 문구, 요청(경로·메서드), 성공 문구
     * confirmMessage 없으면 확인 창 없이 실행, isPublishCheckRequired: 공개 검사 오류가 있으면 비활성 (최종 판정은 서버)
     */
    const ROUND_ACTIONS = {
        publishCheck: { label: '공개 검사 실행', icon: 'clipboard-check', buttonClass: 'btn-outline', statuses: ['DRAFT'] },
        publish: { label: '공개', icon: 'send', buttonClass: 'btn-primary', statuses: ['DRAFT'], path: '/publish', method: 'post', isPublishCheckRequired: true,
            confirmMessage: '이 회차를 공개합니다. 공개 후에는 문항을 바꿀 수 없고, 응시가 생기면 초안으로 되돌릴 수 없어요.',
            successMessage: '회차를 공개했습니다.' },
        republish: { label: '다시 공개', icon: 'send', buttonClass: 'btn-primary', statuses: ['ARCHIVED'], path: '/publish', method: 'post', isPublishCheckRequired: true,
            confirmMessage: '보관한 회차를 다시 공개합니다. 사용자 회차 목록에 다시 보여요.', successMessage: '회차를 다시 공개했습니다.' },
        archive: { label: '보관', icon: 'archive', buttonClass: 'btn-outline', statuses: ['PUBLISHED'], path: '/archive', method: 'post',
            confirmMessage: '이 회차를 보관합니다. 사용자 목록에서 빠지고, 응시 기록과 결과는 유지돼요. 풀이 중인 응시는 마감까지 그대로 진행돼요.',
            successMessage: '회차를 보관했습니다.' },
        revertToDraft: { label: '초안으로 되돌리기', icon: 'undo-2', buttonClass: 'btn-outline btn-warning', statuses: ['PUBLISHED', 'ARCHIVED'],
            isNoAttemptRequired: true, path: '/revert-to-draft', method: 'post',
            confirmMessage: '이 회차를 초안으로 되돌립니다. 사용자 목록에서 빠지고 문항을 다시 바꿀 수 있어요.', successMessage: '초안으로 되돌렸습니다.' },
        deleteDraft: { label: '초안 삭제', icon: 'trash-2', buttonClass: 'btn-outline btn-error', statuses: ['DRAFT'], path: '', method: 'delete',
            confirmMessage: '이 초안 회차와 문항 50개를 삭제합니다. 되돌릴 수 없어요.', successMessage: '초안을 삭제했습니다.' }
    };

    let currentRound = null;

    // ── 회차 상세 불러오기 ──
    async function loadRoundDetail() {
        try {
            currentRound = await AdminApi.get(roundApiPath);
            renderRoundHeader(currentRound);
            renderPublishCheck(currentRound.publishCheck);
            renderItems(currentRound);
        } catch (error) {
            document.getElementById('roundName').textContent = '회차를 불러오지 못했습니다.';
            itemTableBody.innerHTML = '<tr><td colspan="' + ITEM_TABLE_COLUMN_COUNT + '" class="text-center py-12 text-error">'
                + escapeHtml(error.message || '불러오지 못했습니다.') + '</td></tr>';
        }
    }

    function renderRoundHeader(round) {
        document.getElementById('roundName').textContent = mockExam.toRoundName(round.roundNumber, round.title);
        document.getElementById('roundStatusBadge').innerHTML = mockExam.toRoundStatusBadge(round.status);
        document.getElementById('roundMeta').textContent = '문항 ' + formatNumber(round.items.length) + '개 · 응시 '
            + formatNumber(round.attemptCount) + '건 · 공개일 ' + formatDateTime(round.publishedAt);
        document.getElementById('roundAttemptsLink').href = mockExam.toAttemptsPath(round.roundUuid);
        document.getElementById('itemCountLabel').textContent = round.items.length;

        roundActions.innerHTML = Object.keys(ROUND_ACTIONS)
            .filter(actionKey => ROUND_ACTIONS[actionKey].statuses.includes(round.status))
            .filter(actionKey => !ROUND_ACTIONS[actionKey].isNoAttemptRequired || round.attemptCount === 0)
            .map(actionKey => {
                const action = ROUND_ACTIONS[actionKey];
                return '<button type="button" class="btn btn-sm gap-1 ' + action.buttonClass + '" data-round-action="' + actionKey + '"'
                    + toDisabledAttribute(action, round) + '>'
                    + '<i data-lucide="' + action.icon + '" class="size-4"></i>' + action.label + '</button>';
            }).join('');
        lucide.createIcons();
    }

    /** 동작 버튼 비활성 사유 (조회 전용 계정 > 공개 검사 오류), 없으면 빈 문자열 */
    function toDisabledAttribute(action, round) {
        if (!canWriteAdmin) return ' disabled title="조회 전용 계정은 변경할 수 없습니다."';
        const isPublishBlocked = action.isPublishCheckRequired && round.publishCheck && !round.publishCheck.canPublish;
        return isPublishBlocked ? ' disabled title="공개 검사 오류를 먼저 해결하세요."' : '';
    }

    /** 공개 검사 결과: 오류(빨강, 공개 불가) > 경고(주황) > 둘 다 없으면 통과 */
    function renderPublishCheck(publishCheck) {
        if (!publishCheck) { publishCheckBox.innerHTML = ''; return; }
        const errors = publishCheck.errors || [];
        const warnings = publishCheck.warnings || [];
        const toList = messages => '<ul class="list-disc pl-5 text-sm space-y-0.5 max-h-48 overflow-y-auto">'
            + messages.map(message => '<li>' + escapeHtml(message) + '</li>').join('') + '</ul>';
        let html = '';
        if (errors.length > 0) {
            html += '<div role="alert" class="alert alert-error alert-soft items-start"><i data-lucide="circle-x" class="size-5"></i>'
                + '<div><p class="font-semibold">공개 불가 · 오류 ' + errors.length + '건</p>' + toList(errors) + '</div></div>';
        }
        if (warnings.length > 0) {
            html += '<div role="status" class="alert alert-warning alert-soft items-start"><i data-lucide="triangle-alert" class="size-5"></i>'
                + '<div><p class="font-semibold">경고 ' + warnings.length + '건 (공개 가능)</p>' + toList(warnings) + '</div></div>';
        }
        if (!html) {
            html = '<div role="status" class="alert alert-success alert-soft"><i data-lucide="circle-check" class="size-5"></i>'
                + '<span>공개 검사 통과 · 오류와 경고가 없습니다.</span></div>';
        }
        publishCheckBox.innerHTML = html;
        lucide.createIcons();
    }

    // ── 문항 표 ──
    function renderItems(round) {
        const isDraft = round.status === 'DRAFT';
        document.getElementById('itemActionHeader').hidden = !isDraft;
        if (round.items.length === 0) {
            itemTableBody.innerHTML = '<tr><td colspan="' + ITEM_TABLE_COLUMN_COUNT + '" class="text-center py-12 text-base-content/50">문항이 없습니다.</td></tr>';
            return;
        }
        itemTableBody.innerHTML = round.items.map(item => {
            const eligibleCell = item.isChoiceSetEligible
                ? '<span class="badge badge-success badge-sm badge-soft">가능</span>'
                : '<span class="badge badge-error badge-sm">불가</span>';
            const actionCell = !isDraft ? '' : '<td class="whitespace-nowrap">'
                + '<button type="button" class="btn btn-xs btn-outline" data-replace="auto" data-item-uuid="' + escapeHtml(item.itemUuid) + '"'
                + ' data-question-number="' + item.questionNumber + '"' + (canWriteAdmin ? '' : ' disabled') + '>자동 교체</button> '
                + '<button type="button" class="btn btn-xs btn-ghost" data-replace="specified" data-item-uuid="' + escapeHtml(item.itemUuid) + '"'
                + ' data-question-number="' + item.questionNumber + '"' + (canWriteAdmin ? '' : ' disabled') + '>문제 지정</button></td>';
            return '<tr' + (item.isChoiceSetEligible ? '' : ' class="bg-error/10"') + '>'
                + '<td class="font-bold">' + item.questionNumber + '</td>'
                + '<td class="text-xs whitespace-nowrap">' + escapeHtml(mockExam.toLabel(mockExam.SUBJECT_LABEL_BY_CODE, item.subject)) + '</td>'
                + '<td><span class="badge badge-outline badge-sm whitespace-nowrap">' + escapeHtml(item.topicName || '-') + '</span></td>'
                + '<td class="text-xs">' + (item.difficulty == null ? '-' : 'Lv.' + item.difficulty) + '</td>'
                + '<td class="text-xs whitespace-nowrap">' + escapeHtml(mockExam.toLabel(mockExam.EXECUTION_MODE_LABEL_BY_CODE, item.executionMode)) + '</td>'
                + '<td class="text-sm"><a class="link link-hover" target="_blank" rel="noopener" href="'
                + escapeHtml(mockExam.toQuestionDetailPath(item.questionUuid)) + '" title="문제 상세 (새 탭)">'
                + escapeHtml(item.stemPreview || '(지문 없음)') + '</a></td>'
                + '<td class="text-xs whitespace-nowrap">' + escapeHtml(mockExam.toLabel(mockExam.CHOICE_SET_SOURCE_LABEL_BY_CODE, item.choiceSetSource)) + '</td>'
                + '<td>' + eligibleCell + '</td>' + actionCell + '</tr>';
        }).join('');
    }

    // ── 상태별 동작: (확인 창) > 요청 > 토스트 > 다시 조회 (삭제는 목록으로) ──
    roundActions.addEventListener('click', async event => {
        const button = event.target.closest('button[data-round-action]');
        if (!button || button.disabled) return;
        const actionKey = button.dataset.roundAction;
        if (actionKey === 'publishCheck') {
            await runPublishCheck(button);
            return;
        }
        const action = ROUND_ACTIONS[actionKey];
        if (!await AdminUi.confirmDanger(action.confirmMessage, { title: action.label, confirmLabel: action.label })) return;
        button.disabled = true;
        try {
            await AdminApi.request(roundApiPath + action.path, { method: action.method.toUpperCase() });
            if (actionKey === 'deleteDraft') {
                AdminUi.navigateWithToast('/admin/mock-exams', action.successMessage);
                return;
            }
            AdminUi.toast(action.successMessage);
            MockExamItemStats.reset();
            await loadRoundDetail();
            if (isStatsTabActive()) MockExamItemStats.loadOnce(roundApiPath, currentRound.status);
        } catch (error) {
            button.disabled = false;
            AdminUi.showError(error);
        }
    });

    async function runPublishCheck(button) {
        button.disabled = true;
        try {
            const publishCheck = await AdminApi.get(roundApiPath + '/publish-check');
            currentRound.publishCheck = publishCheck;
            renderRoundHeader(currentRound);
            renderPublishCheck(publishCheck);
            AdminUi.toast(publishCheck.canPublish ? '공개 검사를 통과했습니다.' : '공개 검사 오류 ' + publishCheck.errors.length + '건',
                publishCheck.canPublish ? 'success' : 'warning');
        } catch (error) {
            AdminUi.showError(error);
        } finally {
            button.disabled = false;
        }
    }

    // ── 문항 교체 (초안만): 자동 = 같은 토픽 다른 문제, 지정 = 문제 UUID 입력 ──
    itemTableBody.addEventListener('click', async event => {
        const button = event.target.closest('button[data-replace]');
        if (!button || button.disabled) return;
        const questionNumber = button.dataset.questionNumber;
        let questionUuid = null;
        if (button.dataset.replace === 'specified') {
            questionUuid = await askQuestionUuid(questionNumber);
            if (questionUuid === null) return;
        }
        button.disabled = true;
        try {
            await AdminApi.post(roundApiPath + '/items/' + encodeURIComponent(button.dataset.itemUuid) + '/replace', { questionUuid });
            AdminUi.toast(questionNumber + '번 문항을 교체했습니다.');
            await loadRoundDetail();
        } catch (error) {
            button.disabled = false;
            AdminUi.showError(error);
        }
    });

    /** 문제 UUID 입력 창 > UUID (취소·형식 오류는 null) */
    async function askQuestionUuid(questionNumber) {
        const answer = await AdminReasonPrompt.ask({
            title: questionNumber + '번 문항 문제 지정 교체',
            message: '바꿀 문제의 UUID를 입력하세요. 출제 가능한 활성 문제이고 이 회차에 없는 문제여야 해요.\n다른 과목 문제로 바꾸면 과목 문항 수가 어긋나 공개 검사에서 막혀요.',
            placeholder: '문제 UUID (예: 0b8fc893-0239-475d-a58d-bb045dfbbc18)',
            confirmLabel: '교체',
            maximumLength: UUID_TEXT_LENGTH
        });
        if (answer === null || answer === '') return null;
        if (!UUID_PATTERN.test(answer)) {
            AdminUi.toast('문제 UUID 형식이 아닙니다.', 'warning');
            return null;
        }
        return answer;
    }

    function isStatsTabActive() {
        return !document.getElementById('panel-stats').classList.contains('hidden');
    }

    // ── 탭: 문항 / 문항 통계 (통계는 처음 열 때 조회) ──
    document.querySelectorAll('[role="tab"][data-tab]').forEach(tab => {
        tab.addEventListener('click', () => {
            const tabName = tab.dataset.tab;
            document.querySelectorAll('[role="tab"][data-tab]').forEach(otherTab =>
                otherTab.classList.toggle('tab-active', otherTab.dataset.tab === tabName));
            document.getElementById('panel-items').classList.toggle('hidden', tabName !== 'items');
            document.getElementById('panel-stats').classList.toggle('hidden', tabName !== 'stats');
            if (tabName === 'stats') MockExamItemStats.loadOnce(roundApiPath, currentRound && currentRound.status);
        });
    });

    loadRoundDetail();
})();
