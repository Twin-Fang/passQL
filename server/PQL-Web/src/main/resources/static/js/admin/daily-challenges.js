/**
 * 데일리 세트 관리 화면: 캘린더, 날짜별 배정(자동·직접 선택), 난이도 분포·비활성 경고, 기간 자동 배정·복사
 * 서버 API: /admin/daily-challenges (api, api/candidates, api/auto-assign-range, api/copy, {date})
 */
(function () {
    'use strict';

    // 하루 세트 최대 문제 수 (서버 MAX_QUESTIONS_PER_DAY 와 같은 값)
    const MAX_QUESTIONS_PER_DAY = 10;
    // 캘린더 이벤트 색: 정상 / 비활성·삭제 문제 포함
    const EVENT_COLOR_NORMAL = '#6366f1';
    const EVENT_COLOR_WARNING = '#dc2626';

    const escapeHtml = AdminUi.escapeHtml;

    let calendar;
    let selectedDate = null;
    // 직접 선택 패널에서 고른 문제 (순서 = 배정 순서)
    let chosenQuestions = [];
    let lastCandidateContent = [];
    // 마지막 후보 검색 응답 (추가 버튼 상태 갱신용)
    let lastCandidatePage = null;

    /** 배정 목록 > 난이도별 문제 수 문구 (예: "Lv.1 3 · Lv.2 5") */
    function describeDifficultyDistribution(challenges) {
        const countByDifficulty = {};
        challenges.forEach(challenge => {
            const key = challenge.difficulty == null ? '?' : challenge.difficulty;
            countByDifficulty[key] = (countByDifficulty[key] || 0) + 1;
        });
        return Object.keys(countByDifficulty).sort()
            .map(difficulty => `Lv.${difficulty} ${countByDifficulty[difficulty]}`).join(' · ');
    }

    /** 비활성·삭제 문제가 하나라도 있는지 */
    function hasInactiveQuestion(challenges) {
        return challenges.some(challenge => !challenge.isActive);
    }

    // ── 캘린더 ──
    document.addEventListener('DOMContentLoaded', function () {
        calendar = new FullCalendar.Calendar(document.getElementById('calendar'), {
            initialView: 'dayGridMonth',
            locale: 'ko',
            height: 'auto',
            headerToolbar: { left: 'prev,next today', center: 'title', right: '' },
            events: async function (info, successCallback, failureCallback) {
                try {
                    const from = info.startStr.substring(0, 10);
                    const to = info.endStr.substring(0, 10);
                    const challenges = await AdminApi.get(`/admin/daily-challenges/api?from=${from}&to=${to}`);
                    // 날짜별 그룹핑: 같은 날짜 여러 문제를 1개 이벤트로 표시
                    const challengesByDate = {};
                    challenges.forEach(challenge => {
                        (challengesByDate[challenge.challengeDate] = challengesByDate[challenge.challengeDate] || []).push(challenge);
                    });
                    successCallback(Object.entries(challengesByDate).map(([date, dayChallenges]) => {
                        const hasWarning = hasInactiveQuestion(dayChallenges);
                        const distribution = describeDifficultyDistribution(dayChallenges);
                        return {
                            title: `${hasWarning ? '⚠ ' : ''}${dayChallenges.length}문제 (${distribution})`,
                            start: date,
                            color: hasWarning ? EVENT_COLOR_WARNING : EVENT_COLOR_NORMAL
                        };
                    }));
                } catch (error) {
                    failureCallback(error);
                    AdminUi.showError(error);
                }
            },
            dateClick: info => openDate(info.dateStr),
            eventClick: info => openDate(info.event.startStr)
        });
        calendar.render();
        lucide.createIcons();
    });

    async function openDate(dateStr) {
        try {
            const challenges = await AdminApi.get(`/admin/daily-challenges/api?from=${dateStr}&to=${dateStr}`);
            openModal(dateStr, challenges);
        } catch (error) {
            AdminUi.showError(error);
        }
    }

    // ── 배정 현황 모달 ──
    function openModal(dateStr, challenges) {
        selectedDate = dateStr;
        document.getElementById('modalDate').textContent = dateStr;

        const summary = document.getElementById('assignSummary');
        const listElement = document.getElementById('assignedList');
        listElement.innerHTML = '';
        if (challenges && challenges.length > 0) {
            summary.innerHTML = `<span class="badge badge-outline">${challenges.length}문제</span>
                <span class="text-base-content/70">난이도 분포: ${escapeHtml(describeDifficultyDistribution(challenges))}</span>
                ${hasInactiveQuestion(challenges)
                    ? '<span class="badge badge-error gap-1">비활성·삭제 문제 포함, 풀이 화면에 영향이 있을 수 있어요</span>' : ''}`;
            challenges.forEach((challenge, index) => {
                const row = document.createElement('tr');
                row.innerHTML = `<td>${index + 1}</td>
                    <td><span class="badge badge-outline badge-sm">${escapeHtml(challenge.topicName || '')}</span></td>
                    <td>Lv.${challenge.difficulty == null ? '?' : challenge.difficulty}</td>
                    <td class="text-xs">${escapeHtml(challenge.stemPreview ? challenge.stemPreview.substring(0, 50) : '')}</td>
                    <td>${challenge.isActive ? '' : '<span class="badge badge-error badge-sm">비활성</span>'}</td>`;
                listElement.appendChild(row);
            });
            document.getElementById('unassignBtn').classList.remove('hidden');
        } else {
            summary.innerHTML = '';
            listElement.innerHTML = '<tr><td colspan="5" class="text-center text-base-content/50 py-4">배정 없음 (자동 배정 또는 직접 선택으로 배정)</td></tr>';
            document.getElementById('unassignBtn').classList.add('hidden');
        }

        // 직접 선택 패널은 현재 배정을 시작값으로 다시 준비
        chosenQuestions = (challenges || []).filter(challenge => challenge.isActive).map(challenge => ({
            questionUuid: challenge.questionUuid,
            topicName: challenge.topicName,
            difficulty: challenge.difficulty,
            stemPreview: challenge.stemPreview
        }));
        document.getElementById('pickerPanel').classList.add('hidden');
        renderChosenQuestions();

        document.getElementById('assignModal').showModal();
        lucide.createIcons();
    }

    window.closeModal = function () {
        document.getElementById('assignModal').close();
    };

    window.autoAssign = async function () {
        try {
            const challenges = await AdminApi.put(`/admin/daily-challenges/${selectedDate}`, { questionUuids: [] });
            calendar.refetchEvents();
            openModal(selectedDate, challenges);
            AdminUi.toast('자동 배정했습니다.');
        } catch (error) {
            AdminUi.showError(error);
        }
    };

    window.unassignChallenge = async function () {
        if (!await AdminUi.confirmDanger(`${selectedDate} 배정을 해제합니다.`, { confirmLabel: '해제' })) return;
        try {
            await AdminApi.delete(`/admin/daily-challenges/${selectedDate}`);
            calendar.refetchEvents();
            closeModal();
            AdminUi.toast('배정을 해제했습니다.');
        } catch (error) {
            AdminUi.showError(error);
        }
    };

    // ── 직접 선택 ──
    window.togglePicker = function () {
        document.getElementById('pickerPanel').classList.toggle('hidden');
    };

    /** 배정 후보 1페이지 검색 (검색어·토픽·난이도) */
    window.searchCandidates = async function (page) {
        const params = new URLSearchParams({ page: String(page) });
        const keyword = document.getElementById('candidateKeyword').value.trim();
        const topic = document.getElementById('candidateTopic').value;
        const difficulty = document.getElementById('candidateDifficulty').value;
        if (keyword) params.set('keyword', keyword);
        if (topic) params.set('topic', topic);
        if (difficulty) params.set('difficulty', difficulty);
        try {
            const candidatePage = await AdminApi.get(`/admin/daily-challenges/api/candidates?${params}`);
            lastCandidatePage = candidatePage;
            lastCandidateContent = candidatePage.content;
            renderCandidates(candidatePage);
        } catch (error) {
            AdminUi.showError(error);
        }
    };

    function isChosen(questionUuid) {
        return chosenQuestions.some(chosen => chosen.questionUuid === questionUuid);
    }

    function renderCandidates(candidatePage) {
        const listElement = document.getElementById('candidateList');
        listElement.innerHTML = lastCandidateContent.map((candidate, index) => {
            const isDisabled = isChosen(candidate.questionUuid) || chosenQuestions.length >= MAX_QUESTIONS_PER_DAY;
            return `<tr>
                <td><span class="badge badge-outline badge-sm">${escapeHtml(candidate.topicName || '')}</span></td>
                <td>Lv.${candidate.difficulty}</td>
                <td class="text-xs">${escapeHtml(candidate.stemPreview || '')}</td>
                <td><button class="btn btn-xs btn-outline" data-index="${index}" ${isDisabled ? 'disabled' : ''}
                    onclick="addCandidate(this.dataset.index)">추가</button></td>
            </tr>`;
        }).join('') || '<tr><td colspan="4" class="text-center text-base-content/50 py-4">조건에 맞는 문제가 없습니다.</td></tr>';

        const pager = document.getElementById('candidatePager');
        pager.innerHTML = candidatePage.totalPages <= 1 ? '' : `<div class="join">
            <button class="join-item btn btn-xs" ${candidatePage.page <= 0 ? 'disabled' : ''} onclick="searchCandidates(${candidatePage.page - 1})">«</button>
            <button class="join-item btn btn-xs btn-active">${candidatePage.page + 1} / ${candidatePage.totalPages} (${candidatePage.totalElements}건)</button>
            <button class="join-item btn btn-xs" ${candidatePage.page + 1 >= candidatePage.totalPages ? 'disabled' : ''} onclick="searchCandidates(${candidatePage.page + 1})">»</button>
        </div>`;
    }

    window.addCandidate = function (indexText) {
        const candidate = lastCandidateContent[Number(indexText)];
        if (!candidate || isChosen(candidate.questionUuid) || chosenQuestions.length >= MAX_QUESTIONS_PER_DAY) return;
        chosenQuestions.push({
            questionUuid: candidate.questionUuid,
            topicName: candidate.topicName,
            difficulty: candidate.difficulty,
            stemPreview: candidate.stemPreview
        });
        renderChosenQuestions();
        refreshCandidateButtons();
    };

    /** 추가 버튼 활성 상태만 다시 계산 (서버 재조회 없이 마지막 검색 결과 재그림) */
    function refreshCandidateButtons() {
        if (lastCandidatePage) renderCandidates(lastCandidatePage);
    }

    function renderChosenQuestions() {
        document.getElementById('chosenCount').textContent = `${chosenQuestions.length}/${MAX_QUESTIONS_PER_DAY}`;
        document.getElementById('savePickerBtn').disabled = chosenQuestions.length === 0;
        document.getElementById('chosenList').innerHTML = chosenQuestions.map((chosen, index) => `<tr>
            <td class="w-8">${index + 1}</td>
            <td><span class="badge badge-outline badge-sm">${escapeHtml(chosen.topicName || '')}</span></td>
            <td>Lv.${chosen.difficulty}</td>
            <td class="text-xs">${escapeHtml(chosen.stemPreview || '')}</td>
            <td class="w-28 whitespace-nowrap">
                <button class="btn btn-xs btn-ghost" data-index="${index}" ${index === 0 ? 'disabled' : ''} onclick="moveChosen(this.dataset.index, -1)">▲</button>
                <button class="btn btn-xs btn-ghost" data-index="${index}" ${index === chosenQuestions.length - 1 ? 'disabled' : ''} onclick="moveChosen(this.dataset.index, 1)">▼</button>
                <button class="btn btn-xs btn-ghost text-error" data-index="${index}" onclick="removeChosen(this.dataset.index)">✕</button>
            </td>
        </tr>`).join('') || '<tr><td class="text-center text-base-content/50 py-3">위 후보에서 문제를 추가하세요.</td></tr>';
    }

    window.moveChosen = function (indexText, direction) {
        const index = Number(indexText);
        const targetIndex = index + direction;
        if (targetIndex < 0 || targetIndex >= chosenQuestions.length) return;
        [chosenQuestions[index], chosenQuestions[targetIndex]] = [chosenQuestions[targetIndex], chosenQuestions[index]];
        renderChosenQuestions();
    };

    window.removeChosen = function (indexText) {
        chosenQuestions.splice(Number(indexText), 1);
        renderChosenQuestions();
        refreshCandidateButtons();
    };

    window.saveChosenQuestions = async function () {
        if (chosenQuestions.length === 0) return;
        try {
            const challenges = await AdminApi.put(`/admin/daily-challenges/${selectedDate}`,
                { questionUuids: chosenQuestions.map(chosen => chosen.questionUuid) });
            calendar.refetchEvents();
            openModal(selectedDate, challenges);
            AdminUi.toast('선택한 문제로 배정했습니다.');
        } catch (error) {
            AdminUi.showError(error);
        }
    };

    // ── 기간 일괄 작업 ──
    window.autoAssignRange = async function () {
        const fromDate = document.getElementById('autoRangeFrom').value;
        const toDate = document.getElementById('autoRangeTo').value;
        if (!fromDate || !toDate) {
            AdminUi.toast('시작일과 종료일을 입력하세요.', 'warning');
            return;
        }
        if (!await AdminUi.confirmDanger(`${fromDate} ~ ${toDate} 중 배정이 없는 날짜를 자동 배정합니다.`,
            { title: '기간 자동 배정', confirmLabel: '배정' })) return;
        try {
            const result = await AdminApi.post('/admin/daily-challenges/api/auto-assign-range', { fromDate, toDate });
            calendar.refetchEvents();
            AdminUi.toast(`${result.processedDateCount}일 배정, ${result.skippedDateCount}일 건너뜀`);
        } catch (error) {
            AdminUi.showError(error);
        }
    };

    window.copyAssignment = async function () {
        const sourceDate = document.getElementById('copySourceDate').value;
        const targetFromDate = document.getElementById('copyTargetFrom').value;
        const targetToDate = document.getElementById('copyTargetTo').value;
        const isOverwriteExisting = document.getElementById('copyOverwrite').checked;
        if (!sourceDate || !targetFromDate || !targetToDate) {
            AdminUi.toast('복사할 날짜와 붙여넣을 기간을 입력하세요.', 'warning');
            return;
        }
        const overwriteNotice = isOverwriteExisting ? '\n이미 배정된 날짜는 덮어씁니다.' : '\n이미 배정된 날짜는 건너뜁니다.';
        if (!await AdminUi.confirmDanger(`${sourceDate} 의 배정을 ${targetFromDate} ~ ${targetToDate} 에 복사합니다.${overwriteNotice}`,
            { title: '배정 복사', confirmLabel: '복사' })) return;
        try {
            const result = await AdminApi.post('/admin/daily-challenges/api/copy',
                { sourceDate, targetFromDate, targetToDate, isOverwriteExisting });
            calendar.refetchEvents();
            AdminUi.toast(`${result.processedDateCount}일 복사, ${result.skippedDateCount}일 건너뜀`);
        } catch (error) {
            AdminUi.showError(error);
        }
    };
})();
