/**
 * 회원 제재·푸시 창 공통 (회원 목록 일괄 작업, 회원 상세 단건 작업)
 * 창 조각: fragments/member-detail-panels.html 의 suspend-modal, push-modal
 * 대상 회원은 창을 열 때 UUID 배열로 전달 (1명이면 단건 제재 API, 여러 명이면 일괄 API)
 */
(function () {
    'use strict';

    const MEMBER_API_BASE = '/admin/members';
    // 제재 만료 일시 입력(datetime-local)에 붙이는 초 단위
    const SECONDS_SUFFIX = ':00';

    let targetMemberUuids = [];

    function openModal(modalId, memberUuids) {
        targetMemberUuids = memberUuids;
        document.getElementById(modalId).showModal();
    }

    /** 일괄 처리 결과 > 토스트 문구 (처리·건너뜀·실패 건수) */
    function toBulkResultMessage(actionLabel, result) {
        const parts = [actionLabel + ' ' + result.succeededCount + '명'];
        if (result.skippedCount > 0) parts.push('건너뜀 ' + result.skippedCount + '명(관리자·탈퇴·없는 회원)');
        if (result.failedCount > 0) parts.push('실패 ' + result.failedCount + '명');
        return parts.join(', ');
    }

    window.openSuspendModal = memberUuids => openModal('suspendModal', memberUuids);
    window.openPushModal = memberUuids => openModal('pushModal', memberUuids);

    /** 제재 적용: 분류·사유·만료 일시 검증 > 1명이면 단건 API, 여러 명이면 일괄 API */
    window.submitSuspendModal = async function () {
        const reasonCategory = document.getElementById('suspendReasonCategory').value;
        const reason = document.getElementById('suspendReason').value;
        const suspendUntilInput = document.getElementById('suspendUntil').value;
        if (!suspendUntilInput) {
            AdminUi.toast('제재 만료 일시를 입력해주세요.', 'warning');
            return;
        }
        const suspendUntil = suspendUntilInput + SECONDS_SUFFIX;
        try {
            if (targetMemberUuids.length === 1) {
                await AdminApi.post(MEMBER_API_BASE + '/' + targetMemberUuids[0] + '/suspend', { reasonCategory, reason, suspendUntil });
                AdminUi.reloadWithToast('제재를 적용했습니다.');
                return;
            }
            const result = await AdminApi.post(MEMBER_API_BASE + '/bulk-suspend',
                { memberUuids: targetMemberUuids, reasonCategory, reason, suspendUntil });
            AdminUi.reloadWithToast(toBulkResultMessage('제재', result), result.failedCount > 0 ? 'warning' : 'success');
        } catch (error) {
            AdminUi.showError(error);
        }
    };

    /** 푸시 발송: 제목·본문 검증 > 일괄 푸시 API (푸시 + 알림함) */
    window.submitPushModal = async function () {
        const title = document.getElementById('pushTitle').value.trim();
        const body = document.getElementById('pushBody').value.trim();
        if (!title || !body) {
            AdminUi.toast('제목과 본문을 입력해주세요.', 'warning');
            return;
        }
        const isConfirmed = await AdminUi.confirmDanger(
            targetMemberUuids.length + '명에게 푸시와 알림함 알림을 보냅니다. 보낸 푸시는 되돌릴 수 없습니다.',
            { title: '푸시를 보낼까요?', confirmLabel: '보내기' });
        if (!isConfirmed) return;
        try {
            const result = await AdminApi.post(MEMBER_API_BASE + '/bulk-push', { memberUuids: targetMemberUuids, title, body });
            document.getElementById('pushModal').close();
            AdminUi.toast(toBulkResultMessage('발송', result), result.failedCount > 0 ? 'warning' : 'success');
        } catch (error) {
            AdminUi.showError(error);
        }
    };
})();
