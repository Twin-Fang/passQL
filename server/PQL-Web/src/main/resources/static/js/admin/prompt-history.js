/**
 * 프롬프트 관리 화면: 삭제, 버전 목록(비교·롤백), 변경 이력(비교·되돌리기), 줄 단위 diff 모달
 * selectedPromptUuid 는 prompts.html 인라인 스크립트가 선언 (신규 등록 화면이면 null)
 */
(function () {
    'use strict';

    // 변경 이력 종류 > 표시 이름
    const CHANGE_TYPE_LABELS = {
        CREATE: '등록',
        UPDATE: '수정',
        RESTORE: '되돌림',
        ACTIVATE: '활성화',
        DELETE: '삭제'
    };
    // 비교 대상 필드: [필드 키, 표시 이름, 여러 줄 본문 여부]
    const COMPARED_FIELDS = [
        ['systemPrompt', 'System Prompt', true],
        ['userTemplate', 'User Template', true],
        ['model', '모델', false],
        ['temperature', 'Temperature', false],
        ['maxTokens', 'Max Tokens', false]
    ];

    const escapeHtml = AdminUi.escapeHtml;

    // 현재 화면에 로드된 목록 (비교 버튼이 인덱스로 찾음)
    let loadedVersions = [];
    let loadedHistories = [];

    /** 줄 단위 diff (LCS): 두 텍스트 > [{ type: 'same' | 'added' | 'removed', text }] */
    function diffLines(oldText, newText) {
        const oldLines = (oldText || '').split('\n');
        const newLines = (newText || '').split('\n');
        // 최장 공통 부분 수열 길이 표
        const lengthTable = Array.from({ length: oldLines.length + 1 }, () => new Array(newLines.length + 1).fill(0));
        for (let oldIndex = oldLines.length - 1; oldIndex >= 0; oldIndex--) {
            for (let newIndex = newLines.length - 1; newIndex >= 0; newIndex--) {
                lengthTable[oldIndex][newIndex] = oldLines[oldIndex] === newLines[newIndex]
                    ? lengthTable[oldIndex + 1][newIndex + 1] + 1
                    : Math.max(lengthTable[oldIndex + 1][newIndex], lengthTable[oldIndex][newIndex + 1]);
            }
        }
        const diffLineList = [];
        let oldIndex = 0;
        let newIndex = 0;
        while (oldIndex < oldLines.length && newIndex < newLines.length) {
            if (oldLines[oldIndex] === newLines[newIndex]) {
                diffLineList.push({ type: 'same', text: oldLines[oldIndex] });
                oldIndex++;
                newIndex++;
            } else if (lengthTable[oldIndex + 1][newIndex] >= lengthTable[oldIndex][newIndex + 1]) {
                diffLineList.push({ type: 'removed', text: oldLines[oldIndex++] });
            } else {
                diffLineList.push({ type: 'added', text: newLines[newIndex++] });
            }
        }
        while (oldIndex < oldLines.length) diffLineList.push({ type: 'removed', text: oldLines[oldIndex++] });
        while (newIndex < newLines.length) diffLineList.push({ type: 'added', text: newLines[newIndex++] });
        return diffLineList;
    }

    /** diff 줄 > 색상 줄 HTML (추가 녹색, 삭제 빨강) */
    function renderDiffLines(diffLineList) {
        return diffLineList.map(line => {
            const prefix = line.type === 'added' ? '+ ' : line.type === 'removed' ? '- ' : '  ';
            const colorClass = line.type === 'added' ? 'bg-success/20'
                : line.type === 'removed' ? 'bg-error/20' : '';
            return `<div class="${colorClass} whitespace-pre-wrap break-words">${escapeHtml(prefix + line.text)}</div>`;
        }).join('');
    }

    /** 기준(왼쪽)과 대상(오른쪽) 비교 모달 열기 */
    function openDiffModal(title, baseSnapshot, targetSnapshot) {
        document.getElementById('promptDiffTitle').textContent = title;
        document.getElementById('promptDiffBody').innerHTML = COMPARED_FIELDS.map(([fieldKey, label]) => {
            const baseValue = baseSnapshot[fieldKey] == null ? '' : String(baseSnapshot[fieldKey]);
            const targetValue = targetSnapshot[fieldKey] == null ? '' : String(targetSnapshot[fieldKey]);
            const changeBadge = baseValue === targetValue
                ? '<span class="badge badge-ghost badge-sm">변경 없음</span>'
                : '<span class="badge badge-warning badge-sm">변경됨</span>';
            const body = baseValue === targetValue
                ? `<pre class="bg-base-200 rounded p-2 text-xs font-mono whitespace-pre-wrap break-words">${escapeHtml(baseValue) || '(비어 있음)'}</pre>`
                : `<div class="bg-base-200 rounded p-2 text-xs font-mono">${renderDiffLines(diffLines(baseValue, targetValue))}</div>`;
            return `<div><div class="flex items-center gap-2 mb-1 font-semibold text-sm">${label} ${changeBadge}</div>${body}</div>`;
        }).join('');
        document.getElementById('promptDiffModal').showModal();
    }

    /** 현재 편집 폼 값 (저장 전 수정 내용 포함) */
    function readEditingSnapshot() {
        const form = document.getElementById('promptEditForm');
        const readValue = name => form.elements[name] ? form.elements[name].value : '';
        return {
            systemPrompt: readValue('systemPrompt'),
            userTemplate: readValue('userTemplate'),
            model: readValue('model'),
            temperature: readValue('temperature'),
            maxTokens: readValue('maxTokens')
        };
    }

    function formatDateTime(value) {
        return value ? value.substring(0, 16).replace('T', ' ') : '-';
    }

    // ── 버전 목록 ──
    async function loadVersions() {
        const container = document.getElementById('versionList');
        try {
            loadedVersions = await AdminApi.get(`/admin/prompts/${selectedPromptUuid}/versions`);
            container.innerHTML = loadedVersions.map((version, index) => {
                const isCurrent = version.promptTemplateUuid === selectedPromptUuid;
                const activeBadge = version.isActive
                    ? '<span class="badge badge-success badge-sm">활성</span>'
                    : '<span class="badge badge-ghost badge-sm">비활성</span>';
                const compareButton = isCurrent ? '' :
                    `<button class="btn btn-xs btn-outline" data-index="${index}" onclick="compareVersion(this.dataset.index)">비교</button>`;
                const rollbackButton = version.isActive ? '' :
                    `<button class="btn btn-xs btn-warning btn-outline" data-uuid="${version.promptTemplateUuid}" data-version="${version.version}" onclick="rollbackToVersion(this.dataset.uuid, this.dataset.version)">롤백(활성화)</button>`;
                return `<div class="flex items-center justify-between gap-2 border border-base-300 rounded-lg p-2">
                    <div class="min-w-0">
                        <a class="link link-hover font-medium" href="/admin/prompts/${version.promptTemplateUuid}">v${version.version}</a>
                        ${isCurrent ? '<span class="badge badge-primary badge-sm ml-1">편집 중</span>' : ''} ${activeBadge}
                        <div class="text-xs text-base-content/50">${escapeHtml(version.model || '-')} · ${formatDateTime(version.updatedAt)}</div>
                    </div>
                    <div class="flex gap-1 shrink-0">${compareButton}${rollbackButton}</div>
                </div>`;
            }).join('') || '<p class="text-base-content/50">버전이 없습니다.</p>';
        } catch (error) {
            container.textContent = '불러오지 못했습니다.';
            AdminUi.showError(error);
        }
    }

    window.compareVersion = function (indexText) {
        const targetVersion = loadedVersions[Number(indexText)];
        openDiffModal(`편집 중인 내용 <-> v${targetVersion.version}`, readEditingSnapshot(), targetVersion);
    };

    window.rollbackToVersion = async function (promptUuid, versionNumber) {
        if (!await AdminUi.confirmDanger(`v${versionNumber} 을(를) 활성화합니다. 같은 키의 다른 버전은 즉시 비활성화됩니다.`,
            { title: '버전 롤백', confirmLabel: '롤백' })) return;
        try {
            await AdminApi.put(`/admin/prompts/${promptUuid}/activate`);
            AdminUi.reloadWithToast(`v${versionNumber} 으로 롤백했습니다.`);
        } catch (error) {
            AdminUi.showError(error);
        }
    };

    // ── 변경 이력 ──
    async function loadHistory() {
        const container = document.getElementById('historyList');
        try {
            loadedHistories = await AdminApi.get(`/admin/prompts/${selectedPromptUuid}/history`);
            container.innerHTML = loadedHistories.map((history, index) => {
                const canRestore = history.changeType !== 'DELETE' && history.changeType !== 'ACTIVATE';
                const restoreButton = canRestore
                    ? `<button class="btn btn-xs btn-warning btn-outline" data-uuid="${history.promptTemplateHistoryUuid}" onclick="restoreHistory(this.dataset.uuid)">되돌리기</button>`
                    : '';
                return `<div class="flex items-center justify-between gap-2 border border-base-300 rounded-lg p-2">
                    <div class="min-w-0">
                        <span class="badge badge-outline badge-sm">${CHANGE_TYPE_LABELS[history.changeType] || history.changeType}</span>
                        <span class="font-medium">v${history.version}</span>
                        <div class="text-xs text-base-content/50">${escapeHtml(history.changedByAdminUsername || '-')} · ${formatDateTime(history.changedAt)}</div>
                    </div>
                    <div class="flex gap-1 shrink-0">
                        <button class="btn btn-xs btn-outline" data-index="${index}" onclick="compareHistory(this.dataset.index)">현재와 비교</button>
                        ${restoreButton}
                    </div>
                </div>`;
            }).join('') || '<p class="text-base-content/50">변경 이력이 없습니다. (이력 기능 도입 이전 변경은 감사 로그에서 확인)</p>';
        } catch (error) {
            container.textContent = '불러오지 못했습니다.';
            AdminUi.showError(error);
        }
    }

    window.compareHistory = function (indexText) {
        const history = loadedHistories[Number(indexText)];
        openDiffModal(`${formatDateTime(history.changedAt)} 시점 <-> 편집 중인 내용`, history, readEditingSnapshot());
    };

    window.restoreHistory = async function (historyUuid) {
        if (!await AdminUi.confirmDanger('이 시점의 본문·모델·파라미터로 되돌립니다. 되돌림도 변경 이력으로 남습니다.',
            { title: '이력 시점으로 되돌리기', confirmLabel: '되돌리기' })) return;
        try {
            await AdminApi.post(`/admin/prompts/history/${historyUuid}/restore`);
            AdminUi.reloadWithToast('되돌렸습니다.');
        } catch (error) {
            AdminUi.showError(error);
        }
    };

    // ── 삭제 ──
    window.deletePrompt = async function (promptUuid, label) {
        if (!await AdminUi.confirmDanger(`${label} 을(를) 삭제합니다. 삭제 직전 내용은 변경 이력에 남습니다.`,
            { title: '프롬프트 삭제', confirmLabel: '삭제' })) return;
        try {
            await AdminApi.delete(`/admin/prompts/${promptUuid}`);
            AdminUi.navigateWithToast('/admin/prompts', '삭제했습니다.');
        } catch (error) {
            AdminUi.showError(error);
        }
    };

    if (selectedPromptUuid) {
        loadVersions();
        loadHistory();
    }
})();
