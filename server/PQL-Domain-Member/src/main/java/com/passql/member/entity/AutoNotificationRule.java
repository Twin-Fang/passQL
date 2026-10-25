package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.member.constant.AutoNotificationRuleType;
import com.passql.member.constant.PushLinkTarget;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

/** 재방문 자동 알림 규칙 1건: 켜기/끄기, 발송 시각(KST), 미접속 일수, 문구, 이동 화면 (규칙 종류당 1행) */
@Entity
@Table(
    name = "auto_notification_rule",
    uniqueConstraints = @UniqueConstraint(name = "uk_auto_notification_rule_type", columnNames = "rule_type")
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AutoNotificationRule extends BaseEntity {

    // 발송 시각 허용 범위 (시)
    public static final int MIN_SEND_HOUR = 0;
    public static final int MAX_SEND_HOUR = 23;
    // 미접속 일수 허용 범위 (일)
    public static final int MIN_THRESHOLD_DAYS = 1;
    public static final int MAX_THRESHOLD_DAYS = 60;

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID autoNotificationRuleUuid;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false, updatable = false)
    private AutoNotificationRuleType ruleType;

    @Column(nullable = false)
    private Boolean isEnabled = false;

    // 발송 시각 (0~23시, KST)
    @Column(nullable = false)
    private Integer sendHour;

    // 미접속 일수 (COMEBACK 규칙만 값, 그 외 null)
    private Integer thresholdDays;

    @Column(length = PushSendHistory.MAX_TITLE_LENGTH, nullable = false)
    private String title;

    @Column(length = PushSendHistory.MAX_BODY_LENGTH, nullable = false)
    private String body;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private PushLinkTarget linkTarget;

    /** 관리자 수정: 값 범위 검증은 서비스가 먼저 하고 여기서는 반영만 */
    public void update(boolean isEnabled, int sendHour, Integer thresholdDays, String title, String body,
                       PushLinkTarget linkTarget) {
        this.isEnabled = isEnabled;
        this.sendHour = sendHour;
        this.thresholdDays = thresholdDays;
        this.title = title;
        this.body = body;
        this.linkTarget = linkTarget;
    }
}
