/**
 * 관리자 알림 발송 화면: 탭 전환, 발송 폼, 발송 전 확인, 회수, 알림 설정 저장
 * 요청·토스트·확인 창은 admin-fetch.js (AdminApi, AdminUi)
 */
(function () {
    'use strict';

    const pageData = document.getElementById('pushPageData').dataset;
    // 전체 발송 확인 문구용 수: 알림함 대상 회원, 푸시 수신 동의 기기
    const inboxRecipientCount = pageData.inboxRecipientCount;
    const pushEnabledDeviceCount = pageData.pushEnabledDeviceCount;

    const titleInput = document.getElementById('pushTitle');
    const bodyInput = document.getElementById('pushBody');
    const audienceSelect = document.getElementById('pushAudience');
    const deliveryModeSelect = document.getElementById('pushDeliveryMode');
    const linkTargetSelect = document.getElementById('pushLinkTarget');
    const PANEL_NAMES = ['send', 'history', 'settings'];

    window.switchPushTab = function (tabName) {
        PANEL_NAMES.forEach(name => {
            document.getElementById('panel-' + name).classList.toggle('hidden', name !== tabName);
            document.getElementById('tab-' + name).classList.toggle('tab-active', name === tabName);
        });
    };

    function isMemberAudience() {
        return audienceSelect.value === 'MEMBER';
    }

    function isQuestionLinkSelected() {
        return linkTargetSelect.selectedOptions[0].dataset.questionRequired === 'true';
    }

    function isPushIncluded() {
        return deliveryModeSelect.value === 'PUSH_AND_INBOX';
    }

    // 대상 수 안내: 전체 > 알림함 대상 회원 수 (+ 푸시 기기 수), 특정 회원 > 1명
    function describeTargetCount() {
        if (isMemberAudience()) return '알림함 대상 1명 (푸시는 그 회원의 수신 동의 기기)';
        return '알림함 대상 ' + inboxRecipientCount + '명'
            + (isPushIncluded() ? ' · 푸시 수신 동의 기기 ' + pushEnabledDeviceCount + '대' : '');
    }

    // 조건부 입력칸 (회원 UUID, 문제 UUID) + 대상 수 안내
    window.syncConditionalFields = function () {
        document.getElementById('memberUuidField').classList.toggle('hidden', !isMemberAudience());
        document.getElementById('questionUuidField').classList.toggle('hidden', !isQuestionLinkSelected());
        document.getElementById('targetCountHint').textContent = describeTargetCount();
    };

    titleInput.addEventListener('input', () => document.getElementById('titleLength').textContent = titleInput.value.length);
    bodyInput.addEventListener('input', () => document.getElementById('bodyLength').textContent = bodyInput.value.length);

    function buildRequest() {
        return {
            title: titleInput.value.trim(),
            body: bodyInput.value.trim(),
            audience: audienceSelect.value,
            targetMemberUuid: isMemberAudience() ? document.getElementById('pushMemberUuid').value.trim() : null,
            linkTarget: linkTargetSelect.value,
            linkQuestionUuid: isQuestionLinkSelected() ? document.getElementById('pushQuestionUuid').value.trim() : null,
            deliveryMode: deliveryModeSelect.value
        };
    }

    // 발송 전 확인 (필수값 > 요약 표시)
    window.openConfirm = function () {
        const request = buildRequest();
        if (!request.title || !request.body) {
            AdminUi.toast('제목과 본문을 입력해 주세요.', 'warning');
            return;
        }
        document.getElementById('confirmAudience').textContent =
            (isMemberAudience() ? '특정 회원 ' + request.targetMemberUuid : '전체') + ' (' + describeTargetCount() + ')';
        document.getElementById('confirmDeliveryMode').textContent = deliveryModeSelect.selectedOptions[0].textContent;
        document.getElementById('confirmLink').textContent = linkTargetSelect.selectedOptions[0].textContent
            + (request.linkQuestionUuid ? ' ' + request.linkQuestionUuid : '');
        document.getElementById('confirmTitle').textContent = request.title;
        document.getElementById('confirmBody').textContent = request.body;
        document.getElementById('confirmModal').showModal();
    };

    // 발송 접수 > 이력 새로고침 안내 (성공·실패 공통으로 버튼 복구)
    window.sendPush = function () {
        const button = document.getElementById('confirmSendButton');
        button.disabled = true;
        AdminApi.post('/admin/push/send', buildRequest())
            .then(accepted => {
                document.getElementById('confirmModal').close();
                AdminUi.reloadWithToast('발송을 접수했습니다. 알림함 대상 ' + accepted.targetMemberCount
                    + '명, 푸시 결과는 발송 이력에서 확인하세요.');
            })
            .catch(error => {
                document.getElementById('confirmModal').close();
                AdminUi.showError(error, '발송에 실패했습니다.');
            })
            .finally(() => button.disabled = false);
    };

    // 회수: 확인 창 > 받은 회원 알림함에서 숨김
    window.retractPush = async function (pushSendHistoryUuid, title) {
        const isConfirmed = await AdminUi.confirmDanger(
            '"' + title + '" 알림을 받은 회원들의 알림함에서 숨깁니다.\n이미 나간 푸시는 취소할 수 없습니다.',
            { title: '발송을 회수할까요?', confirmLabel: '회수' });
        if (!isConfirmed) return;
        AdminApi.post('/admin/push/' + encodeURIComponent(pushSendHistoryUuid) + '/retract')
            .then(result => AdminUi.reloadWithToast('회수했습니다. 숨긴 알림 ' + result.hiddenCount + '건'))
            .catch(error => AdminUi.showError(error, '회수에 실패했습니다.'));
    };

    // 알림 설정 저장 (보관 기간 숫자 확인은 서버가 범위까지 검증)
    window.saveNotificationSettings = function () {
        const retentionDays = parseInt(document.getElementById('retentionDays').value, 10);
        if (Number.isNaN(retentionDays)) {
            AdminUi.toast('보관 기간을 숫자로 입력해 주세요.', 'warning');
            return;
        }
        AdminApi.put('/admin/push/settings', {
            retentionDays,
            isReportResolvedEnabled: document.getElementById('isReportResolvedEnabled').checked,
            isDailySetReminderEnabled: document.getElementById('isDailySetReminderEnabled').checked
        }).then(() => AdminUi.reloadWithToast('알림 설정을 저장했습니다.'))
          .catch(error => AdminUi.showError(error, '저장에 실패했습니다.'));
    };

    syncConditionalFields();
})();
