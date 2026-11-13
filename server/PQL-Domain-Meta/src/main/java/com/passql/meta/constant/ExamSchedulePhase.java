package com.passql.meta.constant;

import java.time.LocalDate;

/**
 * 회차 1건의 지금 단계 6종 (이름이 앱·API 와이어 계약, 변경 금지)
 * 순서: 접수 전 > 접수 중 > 수험표 대기 > 시험 대기(수험표 발급~시험 당일) > 발표 대기 > 끝(발표일부터)
 * 비어 있는 날짜는 건너뛰고 다음 기준 날짜로 판정
 */
public enum ExamSchedulePhase {
    BEFORE_APPLICATION("접수 전"),
    APPLICATION_OPEN("접수 중"),
    WAITING_ADMISSION_TICKET("수험표 대기"),
    WAITING_EXAM("시험 대기"),
    WAITING_RESULT("발표 대기"),
    FINISHED("끝");

    private final String label;

    ExamSchedulePhase(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    /** 일정 날짜 + 오늘 > 단계 (시험일 필수, 나머지 null 허용) */
    public static ExamSchedulePhase resolve(LocalDate applicationStartDate, LocalDate applicationEndDate,
                                            LocalDate admissionTicketDate, LocalDate examDate,
                                            LocalDate resultAnnouncementDate, LocalDate today) {
        // 시험 뒤: 발표일 전이면 발표 대기, 발표일이 없거나 지났으면 끝
        if (today.isAfter(examDate)) {
            boolean isWaitingResult = resultAnnouncementDate != null && today.isBefore(resultAnnouncementDate);
            return isWaitingResult ? WAITING_RESULT : FINISHED;
        }
        // 시험 당일까지: 접수 시작 전 > 접수 기간 > 수험표 전 > 시험 대기
        if (applicationStartDate != null && today.isBefore(applicationStartDate)) {
            return BEFORE_APPLICATION;
        }
        if (applicationEndDate != null && !today.isAfter(applicationEndDate)) {
            return APPLICATION_OPEN;
        }
        if (admissionTicketDate != null && today.isBefore(admissionTicketDate)) {
            return WAITING_ADMISSION_TICKET;
        }
        return WAITING_EXAM;
    }
}
