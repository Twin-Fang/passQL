package com.passql.web.notification;

import com.passql.application.notification.MemberNotificationService;
import com.passql.application.notification.NotificationSettingService;
import com.passql.application.service.QuestionReportService;
import com.passql.member.constant.MemberNotificationType;
import com.passql.member.constant.PushLinkTarget;
import com.passql.question.constant.CorrectionScope;
import com.passql.question.entity.QuestionReport;
import com.passql.question.repository.QuestionReportRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 신고 처리 완료·기각 > 신고한 회원에게 REPORT_RESOLVED 알림 (설정으로 끄면 생략) */
class ReportResolvedNotificationTest {

    private final QuestionReportRepository questionReportRepository = mock(QuestionReportRepository.class);
    private final QuestionRepository questionRepository = mock(QuestionRepository.class);
    private final MemberNotificationService memberNotificationService = mock(MemberNotificationService.class);
    private final NotificationSettingService notificationSettingService = mock(NotificationSettingService.class);
    private final QuestionReportService service = new QuestionReportService(
            questionReportRepository, questionRepository, mock(SubmissionRepository.class), event -> { },
            memberNotificationService, notificationSettingService);

    private final UUID reportUuid = UUID.randomUUID();
    private final UUID reporterUuid = UUID.randomUUID();
    private final UUID questionUuid = UUID.randomUUID();

    private void givenPendingReport() {
        QuestionReport report = QuestionReport.builder().questionUuid(questionUuid).memberUuid(reporterUuid)
                .submissionUuid(UUID.randomUUID()).categories(List.of()).build();
        when(questionReportRepository.findById(reportUuid)).thenReturn(Optional.of(report));
    }

    @Test
    void 기각하면_신고한_회원에게_문제_상세_이동_알림을_보낸다() {
        givenPendingReport();
        when(notificationSettingService.isReportResolvedEnabled()).thenReturn(true);

        service.dismissReport(reportUuid, "admin");

        verify(memberNotificationService).notifyMember(eq(reporterUuid), eq(MemberNotificationType.REPORT_RESOLVED),
                any(), any(), eq(PushLinkTarget.QUESTION_DETAIL), eq(questionUuid));
    }

    @Test
    void 처리_완료하면_알림을_보내고_문제를_비활성화했으면_홈으로_이동시킨다() {
        givenPendingReport();
        when(notificationSettingService.isReportResolvedEnabled()).thenReturn(true);
        when(questionRepository.findById(questionUuid)).thenReturn(Optional.of(mock(com.passql.question.entity.Question.class)));

        service.resolveReport(reportUuid, "admin", CorrectionScope.NONE, true);

        verify(memberNotificationService).notifyMember(eq(reporterUuid), eq(MemberNotificationType.REPORT_RESOLVED),
                any(), any(), eq(PushLinkTarget.HOME), eq(null));
    }

    @Test
    void 설정이_꺼져_있으면_알림을_보내지_않는다() {
        givenPendingReport();
        when(notificationSettingService.isReportResolvedEnabled()).thenReturn(false);

        service.dismissReport(reportUuid, "admin");

        verify(memberNotificationService, never()).notifyMember(any(), any(), any(), any(), any(), any());
    }
}
