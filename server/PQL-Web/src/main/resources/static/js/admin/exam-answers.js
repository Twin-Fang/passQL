/**
 * 관리자 회차별 가답안 (#1075): 회차 생성·정보 저장, 공식 정답 반영, 문항 50개 일괄 저장
 * 요청·토스트·확인 창은 admin-fetch.js (AdminApi, AdminUi)
 */
(function () {
    'use strict';

    // 공식 정답 문자열 길이 (문항 수)
    const OFFICIAL_ANSWER_LENGTH = 50;
    // 문항 행에서 읽는 입력 칸 (data-field)
    const ITEM_FIELD_NAMES = ['conceptTitle', 'conceptTags', 'topicCode', 'operatorAnswer', 'operatorAnswerStatus', 'alternativeAnswers', 'note'];

    const page = document.getElementById('examAnswerPage');
    if (!page) return;
    const roundUuid = page.dataset.roundUuid;
    const canWriteAdmin = page.dataset.canWriteAdmin === 'true';

    // 조회 전용 계정: 저장 버튼 비활성
    if (!canWriteAdmin) {
        document.querySelectorAll('[data-requires-write]').forEach(button => { button.disabled = true; });
    }

    const roundPagePath = uuid => '/admin/exam-answers?roundUuid=' + encodeURIComponent(uuid);

    // 회차 생성 > 그 회차 화면으로
    document.getElementById('createRoundForm')?.addEventListener('submit', async event => {
        event.preventDefault();
        try {
            const created = await AdminApi.post('/admin/exam-answers', {
                certType: document.getElementById('createCertType').value,
                roundNumber: Number(document.getElementById('createRoundNumber').value),
                examDate: document.getElementById('createExamDate').value,
                title: document.getElementById('createTitle').value,
                notice: document.getElementById('createNotice').value
            });
            AdminUi.navigateWithToast(roundPagePath(created.roundUuid), '회차를 만들었어요 (문항 50개)');
        } catch (error) {
            AdminUi.showError(error, '회차를 만들지 못했어요');
        }
    });

    if (!roundUuid) return;

    // 회차 정보 저장
    document.getElementById('roundForm')?.addEventListener('submit', async event => {
        event.preventDefault();
        try {
            await AdminApi.put('/admin/exam-answers/' + roundUuid, {
                title: document.getElementById('roundTitle').value,
                examDate: document.getElementById('roundExamDate').value,
                status: document.getElementById('roundStatus').value,
                notice: document.getElementById('roundNotice').value
            });
            AdminUi.reloadWithToast('회차 정보를 저장했어요');
        } catch (error) {
            AdminUi.showError(error, '회차 정보를 저장하지 못했어요');
        }
    });

    // 공식 정답 입력 길이 표시
    const officialAnswersInput = document.getElementById('officialAnswers');
    const officialAnswersLength = document.getElementById('officialAnswersLength');
    officialAnswersInput?.addEventListener('input', () => {
        officialAnswersInput.value = officialAnswersInput.value.replace(/[^0-4]/g, '');
        officialAnswersLength.textContent = officialAnswersInput.value.length + ' / ' + OFFICIAL_ANSWER_LENGTH;
    });

    // 공식 정답 반영 (확인 창)
    document.getElementById('officialForm')?.addEventListener('submit', async event => {
        event.preventDefault();
        const officialAnswers = officialAnswersInput.value;
        if (officialAnswers.length !== OFFICIAL_ANSWER_LENGTH) {
            AdminUi.toast('공식 정답은 50자여야 해요', 'error');
            return;
        }
        const isConfirmed = await AdminUi.confirmDanger(
            '0 이 아닌 문항의 운영 가답안을 공식 정답으로 바꾸고 상태를 OFFICIAL 로, 회차를 OFFICIAL 로 바꿉니다.',
            { confirmLabel: '공식 정답 반영' });
        if (!isConfirmed) return;
        try {
            const result = await AdminApi.put('/admin/exam-answers/' + roundUuid + '/official-answers', { answers: officialAnswers });
            AdminUi.reloadWithToast('공식 정답 ' + result.updatedCount + '문항 반영했어요');
        } catch (error) {
            AdminUi.showError(error, '공식 정답을 반영하지 못했어요');
        }
    });

    // 문항 50개 일괄 저장 (모든 칸을 보냄, 빈 칸은 지움)
    document.getElementById('saveItemsButton')?.addEventListener('click', async () => {
        const itemRequests = Array.from(document.querySelectorAll('#itemTableBody tr[data-question-no]')).map(row => {
            const itemRequest = { questionNo: Number(row.dataset.questionNo) };
            ITEM_FIELD_NAMES.forEach(fieldName => {
                const input = row.querySelector('[data-field="' + fieldName + '"]');
                itemRequest[fieldName] = fieldName === 'operatorAnswer' ? Number(input.value) : input.value;
            });
            return itemRequest;
        });
        try {
            const result = await AdminApi.put('/admin/exam-answers/' + roundUuid + '/items', itemRequests);
            AdminUi.reloadWithToast(result.updatedCount + '문항 저장했어요');
        } catch (error) {
            AdminUi.showError(error, '문항을 저장하지 못했어요');
        }
    });
})();
