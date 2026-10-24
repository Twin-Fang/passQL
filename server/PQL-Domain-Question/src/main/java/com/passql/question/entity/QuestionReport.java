package com.passql.question.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.question.constant.CorrectionScope;
import com.passql.question.constant.ReportCategory;
import com.passql.question.constant.ReportStatus;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class QuestionReport extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID questionReportUuid;

    @Column(nullable = false)
    private UUID questionUuid;

    private UUID choiceSetUuid;

    @Column(nullable = false)
    private UUID memberUuid;

    @Column(nullable = false)
    private UUID submissionUuid;

    @ElementCollection
    @CollectionTable(name = "question_report_category",
            joinColumns = @JoinColumn(name = "question_report_uuid"))
    @Column(name = "category")
    @Enumerated(EnumType.STRING)
    private List<ReportCategory> categories;

    @Column(columnDefinition = "TEXT")
    private String detail;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReportStatus status;

    private LocalDateTime resolvedAt;

    // 처리한 관리자 로그인 아이디 (관리자는 회원이 아니라 UUID 대신 아이디 저장, 옛 resolved_by UUID 컬럼은 미사용)
    @Column(length = 100)
    private String resolvedByAdminUsername;

    @Enumerated(EnumType.STRING)
    private CorrectionScope correctionScope;

    // 처리·기각 사유 메모 (최대 500자, 없으면 null)
    @Column(length = 500)
    private String resolutionNote;

    @Builder
    public QuestionReport(UUID questionUuid, UUID choiceSetUuid, UUID memberUuid,
                          UUID submissionUuid, List<ReportCategory> categories, String detail) {
        this.questionUuid = questionUuid;
        this.choiceSetUuid = choiceSetUuid;
        this.memberUuid = memberUuid;
        this.submissionUuid = submissionUuid;
        this.categories = categories;
        this.detail = detail;
        this.status = ReportStatus.PENDING;
    }

    /** 기각: 보정 없이 종료 (처리자·시각은 처리완료와 같은 컬럼) */
    public void dismiss(String resolvedByAdminUsername, String resolutionNote) {
        this.resolutionNote = resolutionNote;
        this.status = ReportStatus.DISMISSED;
        this.resolvedAt = LocalDateTime.now();
        this.resolvedByAdminUsername = resolvedByAdminUsername;
        this.correctionScope = CorrectionScope.NONE;
    }

    public boolean isPending() {
        return status == ReportStatus.PENDING;
    }

    public void resolve(String resolvedByAdminUsername, CorrectionScope correctionScope, String resolutionNote) {
        this.resolutionNote = resolutionNote;
        this.status = ReportStatus.RESOLVED;
        this.resolvedAt = LocalDateTime.now();
        this.resolvedByAdminUsername = resolvedByAdminUsername;
        this.correctionScope = correctionScope;
    }
}
