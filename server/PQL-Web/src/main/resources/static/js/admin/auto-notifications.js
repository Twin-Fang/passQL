/**
 * 관리자 자동 알림 화면: 규칙 카드별 저장, 켜기/끄기 라벨, 잠금 화면 미리보기, 지금 대상 수
 * 요청·토스트는 admin-fetch.js (AdminApi, AdminUi)
 */
(function () {
    'use strict';

    const SAMPLE_DAYS = '3';

    const field = (card, name) => card.querySelector('[data-field="' + name + '"]');

    // {days} 는 규칙의 일수 입력값으로, 일수 입력이 없는 규칙은 예시 숫자로 바꿔 보여줌
    const previewDays = (card) => {
        const thresholdInput = field(card, 'thresholdDays');
        return thresholdInput && thresholdInput.value ? thresholdInput.value : SAMPLE_DAYS;
    };

    function renderPreview(card) {
        const days = previewDays(card);
        card.querySelector('[data-role="preview-title"]').textContent = field(card, 'title').value.replace(/\{days\}/g, days);
        card.querySelector('[data-role="preview-body"]').textContent = field(card, 'body').value.replace(/\{days\}/g, days);
    }

    function readRequest(card) {
        const thresholdInput = field(card, 'thresholdDays');
        return {
            isEnabled: field(card, 'isEnabled').checked,
            sendHour: parseInt(field(card, 'sendHour').value, 10),
            thresholdDays: thresholdInput ? parseInt(thresholdInput.value, 10) : null,
            title: field(card, 'title').value,
            body: field(card, 'body').value,
            linkTarget: field(card, 'linkTarget').value
        };
    }

    document.querySelectorAll('[data-rule-type]').forEach(card => {
        const ruleType = card.dataset.ruleType;
        renderPreview(card);

        ['title', 'body'].forEach(name => field(card, name).addEventListener('input', () => renderPreview(card)));
        const thresholdField = field(card, 'thresholdDays');
        if (thresholdField) thresholdField.addEventListener('input', () => renderPreview(card));

        const enabledToggle = field(card, 'isEnabled');
        enabledToggle.addEventListener('change', () => {
            card.querySelector('[data-role="enabled-label"]').textContent = enabledToggle.checked ? '켜짐' : '꺼짐';
        });

        card.querySelector('[data-action="save"]').addEventListener('click', async () => {
            const request = readRequest(card);
            if (request.isEnabled) {
                const isConfirmed = await AdminUi.confirmDanger(
                    '이 규칙을 켜면 매일 ' + request.sendHour + '시에 대상 회원에게 실제 푸시가 나갑니다.\n제목: ' + request.title,
                    { title: '자동 알림을 켤까요?', confirmLabel: '저장하고 켜기' });
                if (!isConfirmed) return;
            }
            AdminApi.put('/admin/auto-notifications/' + encodeURIComponent(ruleType), request)
                .then(() => AdminUi.reloadWithToast('저장했습니다.'))
                .catch(error => AdminUi.showError(error, '저장에 실패했습니다.'));
        });

        card.querySelector('[data-action="target-count"]').addEventListener('click', () => {
            AdminApi.get('/admin/auto-notifications/' + encodeURIComponent(ruleType) + '/target-count')
                .then(result => {
                    const badge = card.querySelector('[data-role="target-count"]');
                    badge.textContent = '지금 대상 ' + result.memberCount + '명';
                    badge.classList.remove('hidden');
                })
                .catch(error => AdminUi.showError(error, '대상 수를 불러오지 못했습니다.'));
        });
    });
})();
