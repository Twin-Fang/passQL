/**
 * 관리자 모의고사 화면 공통 (#866): 서버 코드값 > 표시 이름·배지 색, API 경로, 화면 경로
 * 회차 목록·회차 상세·응시 기록 화면이 함께 사용 (페이지 스크립트보다 먼저 로드)
 */
(function () {
    'use strict';

    const API_BASE = '/admin/api/mock-exams';

    // MockExamRoundStatus 3개: 코드 > 표시 이름, 배지 색
    const ROUND_STATUS_LABEL_BY_CODE = { DRAFT: '초안', PUBLISHED: '공개', ARCHIVED: '보관' };
    const ROUND_STATUS_BADGE_CLASS_BY_CODE = { DRAFT: 'badge-ghost', PUBLISHED: 'badge-success', ARCHIVED: 'badge-neutral' };
    // MockExamSubject 2개: 짧은 표시 이름, 과목별 문항 수 (서버 MockExamSubject.questionCount 와 같은 값)
    const SUBJECT_LABEL_BY_CODE = { SUBJECT_ONE: '1과목', SUBJECT_TWO: '2과목' };
    const SUBJECT_QUESTION_COUNT_BY_CODE = { SUBJECT_ONE: 10, SUBJECT_TWO: 40 };
    // ExecutionMode 2개
    const EXECUTION_MODE_LABEL_BY_CODE = { EXECUTABLE: '실행형', CONCEPT_ONLY: '개념형' };
    // ChoiceSetSource 5개 (관리자 고정 2개: ADMIN_SEED, ADMIN_CURATED)
    const CHOICE_SET_SOURCE_LABEL_BY_CODE = {
        ADMIN_SEED: '등록 시 생성', ADMIN_CURATED: '검수 승격',
        AI_RUNTIME: 'AI 실시간', AI_PREFETCH: 'AI 미리 생성', AI_ADMIN_PREVIEW: 'AI 미리보기'
    };
    // MockExamAttemptStatus 2개
    const ATTEMPT_STATUS_LABEL_BY_CODE = { IN_PROGRESS: '풀이 중', SUBMITTED: '채점 끝' };
    const ATTEMPT_STATUS_BADGE_CLASS_BY_CODE = { IN_PROGRESS: 'badge-info', SUBMITTED: 'badge-ghost' };
    // MockExamSubmitReason 2개
    const SUBMIT_REASON_LABEL_BY_CODE = { MEMBER: '회원 제출', TIME_UP: '시간 끝' };
    // MockExamFailReason 3개: 합격 / 과락(우선) / 총점 미달
    const RESULT_LABEL_BY_FAIL_REASON = { NONE: '합격', SUBJECT_FAIL: '과락', TOTAL_SCORE_BELOW: '총점 미달' };
    const RESULT_BADGE_CLASS_BY_FAIL_REASON = { NONE: 'badge-success', SUBJECT_FAIL: 'badge-error', TOTAL_SCORE_BELOW: 'badge-warning' };

    /** 코드 > 표시 이름 (매핑 없으면 코드 그대로, 비었으면 '-') */
    function toLabel(labelByCode, code) {
        if (code === null || code === undefined || code === '') return '-';
        return labelByCode[code] || String(code);
    }

    /** 회차 상태 > 배지 HTML */
    function toRoundStatusBadge(status) {
        return '<span class="badge badge-sm whitespace-nowrap ' + (ROUND_STATUS_BADGE_CLASS_BY_CODE[status] || 'badge-ghost') + '">'
            + AdminUi.escapeHtml(toLabel(ROUND_STATUS_LABEL_BY_CODE, status)) + '</span>';
    }

    /** 회차 번호·제목 > "제1회 · 제목" (제목에 이미 "제1회"가 있으면 제목만) */
    function toRoundName(roundNumber, title) {
        const roundLabel = '제' + roundNumber + '회';
        if (!title) return roundLabel;
        return title.includes(roundLabel) ? title : roundLabel + ' · ' + title;
    }

    // ── 화면 경로 (UUID 는 encodeURIComponent) ──
    function toRoundDetailPath(roundUuid) {
        return '/admin/mock-exams/' + encodeURIComponent(roundUuid);
    }

    function toAttemptsPath(roundUuid) {
        return '/admin/mock-exams/attempts' + (roundUuid ? '?roundUuid=' + encodeURIComponent(roundUuid) : '');
    }

    function toQuestionDetailPath(questionUuid) {
        return '/admin/questions/' + encodeURIComponent(questionUuid);
    }

    function toMemberDetailPath(memberUuid) {
        return '/admin/members/' + encodeURIComponent(memberUuid);
    }

    function toReportDetailPath(questionUuid) {
        return '/admin/reports/' + encodeURIComponent(questionUuid);
    }

    window.MockExamAdmin = {
        API_BASE,
        ROUND_STATUS_LABEL_BY_CODE,
        SUBJECT_LABEL_BY_CODE,
        SUBJECT_QUESTION_COUNT_BY_CODE,
        EXECUTION_MODE_LABEL_BY_CODE,
        CHOICE_SET_SOURCE_LABEL_BY_CODE,
        ATTEMPT_STATUS_LABEL_BY_CODE,
        ATTEMPT_STATUS_BADGE_CLASS_BY_CODE,
        SUBMIT_REASON_LABEL_BY_CODE,
        RESULT_LABEL_BY_FAIL_REASON,
        RESULT_BADGE_CLASS_BY_FAIL_REASON,
        toLabel,
        toRoundStatusBadge,
        toRoundName,
        toRoundDetailPath,
        toAttemptsPath,
        toQuestionDetailPath,
        toMemberDetailPath,
        toReportDetailPath
    };
})();
