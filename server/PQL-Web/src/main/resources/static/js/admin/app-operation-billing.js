/**
 * 관리자 앱 운영 결제 영역 (#961): 스위치 전환(점검표 미충족 항목 알림), 미리보기 회원 추가·삭제
 * 요청·확인 창·토스트는 admin-fetch.js (AdminApi, AdminUi)
 */
(function () {
    'use strict';

    const BILLING_BASE_URL = '/admin/app-operation/billing';

    /** 점검표 미충족 행 > "- 이름: 상태" 목록 */
    function findMissingReadinessLines() {
        return Array.from(document.querySelectorAll('.billing-readiness-row'))
            .filter(row => row.dataset.isReady !== 'true')
            .map(row => '- ' + row.dataset.label + ': ' + row.dataset.statusText);
    }

    /** 스위치 전환 확인 문구 (켤 때만 미충족 항목 덧붙임) */
    function buildSwitchConfirmMessage(isEnabled) {
        if (!isEnabled) {
            return '결제를 끕니다. 모든 회원에게 모든 기능이 열리고 결제 화면이 숨겨집니다.';
        }
        const lines = ['결제를 켭니다. 무료·프로 제한이 전체 회원에게 적용되고 결제 화면이 보입니다.'];
        const missingReadinessLines = findMissingReadinessLines();
        if (missingReadinessLines.length) {
            lines.push('', '점검표에서 확인이 필요한 항목:', ...missingReadinessLines);
        }
        return lines.join('\n');
    }

    /** 결제 스위치 전환: 확인 > PUT > 새로고침 */
    async function changeBillingEnabled(isEnabled) {
        const isConfirmed = await AdminUi.confirmDanger(buildSwitchConfirmMessage(isEnabled), {
            title: isEnabled ? '결제 켜기' : '결제 끄기',
            confirmLabel: isEnabled ? '켜기' : '끄기'
        });
        if (!isConfirmed) return;
        try {
            await AdminApi.put(BILLING_BASE_URL + '/enabled', {isEnabled});
        } catch (error) {
            AdminUi.showError(error);
            return;
        }
        AdminUi.reloadWithToast(isEnabled ? '결제를 켰습니다.' : '결제를 껐습니다.');
    }

    /** 미리보기 회원 추가: 입력 확인 > POST > 새로고침 (형식·회원 존재 검사는 서버) */
    async function addBillingPreviewMember() {
        const memberUuid = document.getElementById('billingPreviewMemberUuid').value.trim();
        if (!memberUuid) {
            AdminUi.toast('회원 UUID 를 입력해 주세요.', 'error');
            return;
        }
        try {
            await AdminApi.post(BILLING_BASE_URL + '/preview-members', {memberUuid});
        } catch (error) {
            AdminUi.showError(error);
            return;
        }
        AdminUi.reloadWithToast('미리보기 회원을 추가했습니다.');
    }

    /** 미리보기 항목 삭제: 확인 > DELETE > 새로고침 */
    async function removeBillingPreviewMember(entry) {
        const isConfirmed = await AdminUi.confirmDanger(
            entry + ' 항목을 미리보기 목록에서 뺍니다. 결제 스위치가 꺼져 있으면 이 회원은 다시 모든 기능이 열립니다.',
            {confirmLabel: '삭제'});
        if (!isConfirmed) return;
        try {
            await AdminApi.delete(BILLING_BASE_URL + '/preview-members', {memberUuid: entry});
        } catch (error) {
            AdminUi.showError(error);
            return;
        }
        AdminUi.reloadWithToast('미리보기 목록에서 뺐습니다.');
    }

    window.changeBillingEnabled = changeBillingEnabled;
    window.addBillingPreviewMember = addBillingPreviewMember;
    window.removeBillingPreviewMember = removeBillingPreviewMember;
})();
