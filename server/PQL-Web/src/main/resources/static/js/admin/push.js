/**
 * 관리자 알림 발송 화면: 탭 전환, 발송 폼(세그먼트·예약), 템플릿, 테스트 발송, 발송 전 확인, 회수·예약 취소, 실패 기기, 알림 설정 저장
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

    function isInactiveAudience() {
        return audienceSelect.value === 'INACTIVE_MEMBERS';
    }

    // 전체·특정 회원 외 세그먼트 (프로, 무료, 미접속, 플랫폼)
    function isSegmentAudience() {
        return audienceSelect.value !== 'ALL' && !isMemberAudience();
    }

    // 예약 시각 입력값 (비면 null = 즉시)
    function readScheduledAt() {
        return document.getElementById('pushScheduledAt').value || null;
    }

    function isQuestionLinkSelected() {
        return linkTargetSelect.selectedOptions[0].dataset.questionRequired === 'true';
    }

    function isPushIncluded() {
        return deliveryModeSelect.value === 'PUSH_AND_INBOX';
    }

    // 세그먼트 대상 회원 수 (서버 조회 결과, 조회 전·실패면 안내 문구)
    let segmentMemberCountText = '조회 중...';

    // 대상 수 안내: 전체 > 알림함 대상 회원 수 (+ 푸시 기기 수), 특정 회원 > 1명, 세그먼트 > 지금 기준 조회 수
    function describeTargetCount() {
        if (isMemberAudience()) return '알림함 대상 1명 (푸시는 그 회원의 수신 동의 기기)';
        if (isSegmentAudience()) return '알림함 대상 ' + segmentMemberCountText + ' (지금 기준, 예약은 발송 시각에 다시 조회)';
        return '알림함 대상 ' + inboxRecipientCount + '명'
            + (isPushIncluded() ? ' · 푸시 수신 동의 기기 ' + pushEnabledDeviceCount + '대' : '');
    }

    // 세그먼트 대상 회원 수 조회 > 안내 갱신 (실패해도 발송 폼은 그대로 사용)
    function refreshSegmentMemberCount() {
        if (!isSegmentAudience()) return;
        segmentMemberCountText = '조회 중...';
        const inactiveDaysQuery = isInactiveAudience() ? '&inactiveDays=' + encodeURIComponent(document.getElementById('pushInactiveDays').value) : '';
        AdminApi.get('/admin/push/audience-count?audience=' + encodeURIComponent(audienceSelect.value) + inactiveDaysQuery)
            .then(result => segmentMemberCountText = result.memberCount + '명')
            .catch(() => segmentMemberCountText = '조회 실패')
            .finally(() => document.getElementById('targetCountHint').textContent = describeTargetCount());
    }

    // 조건부 입력칸 (회원 UUID, 미접속 일수, 문제 UUID) + 대상 수 안내
    window.syncConditionalFields = function () {
        document.getElementById('memberUuidField').classList.toggle('hidden', !isMemberAudience());
        document.getElementById('inactiveDaysField').classList.toggle('hidden', !isInactiveAudience());
        document.getElementById('questionUuidField').classList.toggle('hidden', !isQuestionLinkSelected());
        document.getElementById('targetCountHint').textContent = describeTargetCount();
        refreshSegmentMemberCount();
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
            deliveryMode: deliveryModeSelect.value,
            inactiveDays: isInactiveAudience() ? parseInt(document.getElementById('pushInactiveDays').value, 10) : null,
            scheduledAt: readScheduledAt()
        };
    }

    // 발송 전 확인 (필수값 > 요약 표시)
    window.openConfirm = function () {
        const request = buildRequest();
        if (!request.title || !request.body) {
            AdminUi.toast('제목과 본문을 입력해 주세요.', 'warning');
            return;
        }
        const audienceLabel = audienceSelect.selectedOptions[0].textContent
            + (isMemberAudience() ? ' ' + request.targetMemberUuid : '')
            + (isInactiveAudience() ? ' (' + request.inactiveDays + '일 이상)' : '');
        document.getElementById('confirmAudience').textContent = audienceLabel + ' (' + describeTargetCount() + ')';
        document.getElementById('confirmSchedule').textContent = request.scheduledAt
            ? request.scheduledAt.replace('T', ' ') + ' 예약' : '지금 바로';
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
                AdminUi.reloadWithToast((readScheduledAt() ? '예약을 접수했습니다. 예상 ' : '발송을 접수했습니다. 알림함 대상 ') + accepted.targetMemberCount
                    + '명, 결과는 발송 이력에서 확인하세요.');
            })
            .catch(error => {
                document.getElementById('confirmModal').close();
                AdminUi.showError(error, '발송에 실패했습니다.');
            })
            .finally(() => button.disabled = false);
    };

    // 테스트 발송: 지정 회원 1명에게 즉시 (제목·본문·이동·전달 방식은 폼 값 사용)
    window.sendTestPush = function () {
        const request = buildRequest();
        request.targetMemberUuid = document.getElementById('pushTestMemberUuid').value.trim();
        if (!request.title || !request.body || !request.targetMemberUuid) {
            AdminUi.toast('제목, 본문, 테스트 수신 회원 UUID 를 입력해 주세요.', 'warning');
            return;
        }
        AdminApi.post('/admin/push/test-send', request)
            .then(() => AdminUi.reloadWithToast('테스트 발송을 접수했습니다. 이력에서 "테스트 포함"으로 확인하세요.'))
            .catch(error => AdminUi.showError(error, '테스트 발송에 실패했습니다.'));
    };

    // 템플릿 불러오기: 제목·본문·이동 경로를 폼에 채움
    window.applyTemplate = function () {
        const option = document.getElementById('pushTemplateSelect').selectedOptions[0];
        if (!option || !option.value) {
            AdminUi.toast('불러올 템플릿을 선택해 주세요.', 'warning');
            return;
        }
        titleInput.value = option.dataset.title;
        bodyInput.value = option.dataset.body;
        linkTargetSelect.value = option.dataset.linkTarget;
        document.getElementById('pushQuestionUuid').value = option.dataset.questionUuid;
        titleInput.dispatchEvent(new Event('input'));
        bodyInput.dispatchEvent(new Event('input'));
        syncConditionalFields();
    };

    // 현재 제목·본문·이동 경로를 이름으로 저장 (같은 이름이면 덮어쓰기)
    window.saveTemplate = function () {
        const name = window.prompt('템플릿 이름 (같은 이름이면 덮어씁니다)');
        if (!name || !name.trim()) return;
        const request = buildRequest();
        AdminApi.post('/admin/push/templates', {
            name: name.trim(), title: request.title, body: request.body,
            linkTarget: request.linkTarget, linkQuestionUuid: request.linkQuestionUuid
        }).then(() => AdminUi.reloadWithToast('템플릿을 저장했습니다.'))
          .catch(error => AdminUi.showError(error, '템플릿 저장에 실패했습니다.'));
    };

    window.deleteTemplate = async function () {
        const option = document.getElementById('pushTemplateSelect').selectedOptions[0];
        if (!option || !option.value) {
            AdminUi.toast('삭제할 템플릿을 선택해 주세요.', 'warning');
            return;
        }
        const isConfirmed = await AdminUi.confirmDanger('"' + option.textContent + '" 템플릿을 삭제합니다.', { confirmLabel: '삭제' });
        if (!isConfirmed) return;
        AdminApi.delete('/admin/push/templates/' + encodeURIComponent(option.value))
            .then(() => AdminUi.reloadWithToast('템플릿을 삭제했습니다.'))
            .catch(error => AdminUi.showError(error, '삭제에 실패했습니다.'));
    };

    // 예약 취소: 확인 > 발송 시각 전 예약만 취소
    window.cancelScheduledPush = async function (pushSendHistoryUuid, title) {
        const isConfirmed = await AdminUi.confirmDanger('"' + title + '" 예약 발송을 취소합니다.',
            { title: '예약을 취소할까요?', confirmLabel: '예약 취소' });
        if (!isConfirmed) return;
        AdminApi.post('/admin/push/' + encodeURIComponent(pushSendHistoryUuid) + '/cancel')
            .then(() => AdminUi.reloadWithToast('예약을 취소했습니다.'))
            .catch(error => AdminUi.showError(error, '예약 취소에 실패했습니다.'));
    };

    // 실패 기기 목록 모달 (값은 textContent 로만 넣어 이스케이프)
    window.showFailures = function (pushSendHistoryUuid) {
        AdminApi.get('/admin/push/' + encodeURIComponent(pushSendHistoryUuid) + '/failures')
            .then(failures => {
                const body = document.getElementById('failuresBody');
                body.replaceChildren();
                failures.forEach(failure => {
                    const row = body.insertRow();
                    row.insertCell().textContent = failure.memberUuid.substring(0, 8);
                    row.insertCell().textContent = failure.tokenSuffix;
                    row.insertCell().textContent = failure.failureReason;
                    row.insertCell().textContent = failure.isTokenExpired ? '삭제됨' : '-';
                    row.insertCell().textContent = (failure.failedAt || '').replace('T', ' ').substring(0, 16);
                });
                if (failures.length === 0) {
                    body.insertRow().insertCell().textContent = '기록된 실패 기기가 없습니다. (이 기능 도입 전 발송은 기록되지 않음)';
                }
                document.getElementById('failuresModal').showModal();
            })
            .catch(error => AdminUi.showError(error, '실패 기기 조회에 실패했습니다.'));
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
            isReportResolvedEnabled: document.getElementById('isReportResolvedEnabled').checked
        }).then(() => AdminUi.reloadWithToast('알림 설정을 저장했습니다.'))
          .catch(error => AdminUi.showError(error, '저장에 실패했습니다.'));
    };

    syncConditionalFields();

    // 검색·페이지 이동 뒤에는 이력 탭을 연다 (?tab=history)
    if (new URLSearchParams(window.location.search).get('tab') === 'history') {
        switchPushTab('history');
    }
})();
