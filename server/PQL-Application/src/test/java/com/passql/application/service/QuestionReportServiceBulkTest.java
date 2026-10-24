package com.passql.application.service;

import com.passql.application.notification.MemberNotificationService;
import com.passql.application.notification.NotificationSettingService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.constant.CorrectionScope;
import com.passql.question.constant.ReportCategory;
import com.passql.question.constant.ReportStatus;
import com.passql.question.entity.QuestionReport;
import com.passql.question.repository.QuestionReportRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationEventPublisher;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 신고 일괄 처리 (#613): 한 번 호출로 처리, 같은 문제 보정은 1회, 처리된 건은 건너뜀 */
class QuestionReportServiceBulkTest {

    private final QuestionReportRepository questionReportRepository = mock(QuestionReportRepository.class);
    private final QuestionRepository questionRepository = mock(QuestionRepository.class);
    private final SubmissionRepository submissionRepository = mock(SubmissionRepository.class);
    private final NotificationSettingService notificationSettingService = mock(NotificationSettingService.class);

    private final QuestionReportService questionReportService = new QuestionReportService(
            questionReportRepository, questionRepository, submissionRepository,
            mock(ApplicationEventPublisher.class), mock(MemberNotificationService.class), notificationSettingService);

    private QuestionReport newReport(UUID questionUuid) {
        return QuestionReport.builder()
                .questionUuid(questionUuid).memberUuid(UUID.randomUUID()).submissionUuid(UUID.randomUUID())
                .categories(List.of(ReportCategory.WRONG_ANSWER)).build();
    }

    @Test
    void 같은_문제_신고_여러_건은_소급_보정을_한_번만_하고_이미_처리된_건은_건너뛴다() {
        UUID questionUuid = UUID.randomUUID();
        QuestionReport first = newReport(questionUuid);
        QuestionReport second = newReport(questionUuid);
        QuestionReport alreadyDismissed = newReport(questionUuid);
        alreadyDismissed.dismiss("other-admin", null);
        List<QuestionReport> reports = List.of(first, second, alreadyDismissed);
        // 엔티티 UUID 는 저장 시 생성되므로 테스트에서는 조회 결과를 직접 지정
        when(questionReportRepository.findByQuestionReportUuidIn(any())).thenReturn(reports);
        List<UUID> requestedUuids = List.of(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID());

        QuestionReportService.BulkProcessResult result = questionReportService.resolveReports(
                requestedUuids, "passql-admin", CorrectionScope.QUESTION_WIDE, false, "  정답 수정  ");

        assertThat(result.processedCount()).isEqualTo(2);
        assertThat(result.skippedCount()).isEqualTo(1);
        assertThat(first.getStatus()).isEqualTo(ReportStatus.RESOLVED);
        assertThat(first.getResolutionNote()).isEqualTo("정답 수정");
        assertThat(alreadyDismissed.getStatus()).isEqualTo(ReportStatus.DISMISSED);
        verify(submissionRepository, times(1)).correctAllByQuestionUuid(questionUuid);
    }

    @Test
    void 선택지_세트_기준_보정인데_세트가_없는_신고가_있으면_전체_취소() {
        QuestionReport withoutChoiceSet = newReport(UUID.randomUUID());
        when(questionReportRepository.findByQuestionReportUuidIn(any())).thenReturn(List.of(withoutChoiceSet));

        assertThatThrownBy(() -> questionReportService.resolveReports(
                List.of(UUID.randomUUID()), "passql-admin", CorrectionScope.CHOICE_SET_ONLY, false, null))
                .isInstanceOf(CustomException.class)
                .extracting(error -> ((CustomException) error).getErrorCode())
                .isEqualTo(ErrorCode.REPORT_CHOICE_SET_REQUIRED);
        assertThat(withoutChoiceSet.getStatus()).isEqualTo(ReportStatus.PENDING);
        verify(submissionRepository, never()).correctAllByChoiceSetUuid(any());
    }

    @Test
    void 존재하지_않는_신고_UUID가_섞이면_REPORT_NOT_FOUND() {
        when(questionReportRepository.findByQuestionReportUuidIn(any())).thenReturn(List.of());

        assertThatThrownBy(() -> questionReportService.dismissReports(
                List.of(UUID.randomUUID()), "passql-admin", null))
                .isInstanceOf(CustomException.class)
                .extracting(error -> ((CustomException) error).getErrorCode())
                .isEqualTo(ErrorCode.REPORT_NOT_FOUND);
    }
}
