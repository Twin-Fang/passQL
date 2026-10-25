package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

/**
 * 회원별 자동 알림 수신 설정: 그룹 3개 켜기/끄기 (회원당 1행, 행이 없으면 전부 수신)
 * 관리자 직접 발송은 이 설정과 무관하게 항상 수신
 */
@Entity
@Table(name = "member_notification_preference")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MemberNotificationPreference extends BaseEntity {

    @Id
    @Column(updatable = false, nullable = false)
    private UUID memberUuid;

    // 학습 리마인더 (오늘의 세트·연속 학습 위험)
    @Column(nullable = false)
    private Boolean isStudyReminderEnabled = true;

    // 복귀 알림 (3일·7일 미접속)
    @Column(nullable = false)
    private Boolean isComebackEnabled = true;

    // 시험 D-day 알림
    @Column(nullable = false)
    private Boolean isExamCountdownEnabled = true;

    public static MemberNotificationPreference ofDefault(UUID memberUuid) {
        MemberNotificationPreference preference = new MemberNotificationPreference();
        preference.memberUuid = memberUuid;
        return preference;
    }

    /** null 인 항목은 그대로 둠 */
    public void update(Boolean isStudyReminderEnabled, Boolean isComebackEnabled, Boolean isExamCountdownEnabled) {
        if (isStudyReminderEnabled != null) {
            this.isStudyReminderEnabled = isStudyReminderEnabled;
        }
        if (isComebackEnabled != null) {
            this.isComebackEnabled = isComebackEnabled;
        }
        if (isExamCountdownEnabled != null) {
            this.isExamCountdownEnabled = isExamCountdownEnabled;
        }
    }
}
