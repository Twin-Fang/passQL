package com.passql.meta.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.meta.constant.CertType;
import com.passql.meta.constant.ExamScheduleSource;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
    name = "exam_schedule",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_exam_schedule_cert_round", columnNames = {"cert_type", "round"})
    },
    indexes = {
        @Index(name = "idx_exam_schedule_cert", columnList = "cert_type"),
        @Index(name = "idx_exam_schedule_selected", columnList = "is_selected")
    }
)
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class ExamSchedule extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID examScheduleUuid;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private CertType certType;

    @Column(nullable = false)
    private Integer round;

    @Column(nullable = false)
    private LocalDate examDate;

    @Column(nullable = false)
    private Boolean isSelected = false;

    // 원서접수 시작·마감 (#991, 공식 페이지 "원서접수"/"접수기간" 열)
    private LocalDate applicationStartDate;

    private LocalDate applicationEndDate;

    // 수험표 발급일
    private LocalDate admissionTicketDate;

    // 사전점수 공개·재검토 접수 시작·마감
    private LocalDate preliminaryScoreStartDate;

    private LocalDate preliminaryScoreEndDate;

    // 합격(예정)자 발표일
    private LocalDate resultAnnouncementDate;

    // 값 출처: AUTO 공식 페이지 수집, MANUAL 관리자 입력
    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private ExamScheduleSource source = ExamScheduleSource.MANUAL;

    // 수동 고정: true 면 자동 수집이 이 행을 덮어쓰지 않음
    @Builder.Default
    @Column(nullable = false)
    private Boolean isManualLocked = false;

    // 자동 수집이 이 행을 마지막으로 확인한 시각 (KST, 수집 이력 없으면 null)
    private LocalDateTime lastCollectedAt;
}
