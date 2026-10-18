package com.passql.question.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.question.constant.CommunityReportCategory;
import com.passql.question.constant.CommunityReportStatus;
import com.passql.question.constant.CommunityReportTargetType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

/** 글·댓글 신고 1건 (대상당 회원 1회, 사유 카테고리 + 선택 상세) */
@Entity
@Table(
    name = "community_report",
    uniqueConstraints = @UniqueConstraint(name = "uk_community_report_reporter",
        columnNames = {"target_type", "target_uuid", "reporter_member_uuid"}),
    indexes = @Index(name = "idx_community_report_target_status", columnList = "target_type, target_uuid, status")
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class CommunityReport extends BaseEntity {

    // 신고 상세 최대 길이 (문자 수)
    public static final int MAX_DETAIL_LENGTH = 200;

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID reportUuid;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private CommunityReportTargetType targetType;

    @Column(nullable = false)
    private UUID targetUuid;

    @Column(nullable = false)
    private UUID reporterMemberUuid;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private CommunityReportCategory category;

    @Column(length = MAX_DETAIL_LENGTH)
    private String detail;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private CommunityReportStatus status;

    public static CommunityReport ofPost(UUID postUuid, UUID reporterMemberUuid, CommunityReportCategory category, String detail) {
        CommunityReport report = new CommunityReport();
        report.targetType = CommunityReportTargetType.POST;
        report.targetUuid = postUuid;
        report.reporterMemberUuid = reporterMemberUuid;
        report.category = category;
        report.detail = detail;
        report.status = CommunityReportStatus.PENDING;
        return report;
    }
}
