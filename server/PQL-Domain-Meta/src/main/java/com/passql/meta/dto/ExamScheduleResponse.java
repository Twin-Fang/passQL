package com.passql.meta.dto;

import com.passql.common.util.ServiceTimeZone;
import com.passql.meta.constant.ExamSchedulePhase;
import com.passql.meta.constant.ExamScheduleSource;
import com.passql.meta.entity.ExamSchedule;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 시험 일정 1회차: 회차·시험일 + 접수·수험표·사전점수·발표 일정(#991, 없으면 null) + 출처·지금 단계(서버 계산, KST 오늘 기준)
 */
@Getter
@AllArgsConstructor
public class ExamScheduleResponse {

    private UUID examScheduleUuid;
    private String certType;
    private Integer round;
    private LocalDate examDate;
    private Boolean isSelected;
    private LocalDate applicationStartDate;
    private LocalDate applicationEndDate;
    private LocalDate admissionTicketDate;
    private LocalDate preliminaryScoreStartDate;
    private LocalDate preliminaryScoreEndDate;
    private LocalDate resultAnnouncementDate;
    private ExamScheduleSource source;
    private Boolean isManualLocked;
    private LocalDateTime lastCollectedAt;
    private ExamSchedulePhase phase;

    public static ExamScheduleResponse from(ExamSchedule e) {
        LocalDate today = LocalDate.now(ServiceTimeZone.ZONE);
        return new ExamScheduleResponse(
            e.getExamScheduleUuid(),
            e.getCertType().name(),
            e.getRound(),
            e.getExamDate(),
            e.getIsSelected(),
            e.getApplicationStartDate(),
            e.getApplicationEndDate(),
            e.getAdmissionTicketDate(),
            e.getPreliminaryScoreStartDate(),
            e.getPreliminaryScoreEndDate(),
            e.getResultAnnouncementDate(),
            e.getSource(),
            e.getIsManualLocked(),
            e.getLastCollectedAt(),
            ExamSchedulePhase.resolve(e.getApplicationStartDate(), e.getApplicationEndDate(), e.getAdmissionTicketDate(),
                    e.getExamDate(), e.getResultAnnouncementDate(), today)
        );
    }
}
