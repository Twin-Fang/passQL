package com.passql.member.constant;

import com.passql.common.util.RequestEnumParser;

/** 관리자 발송 전달 방식 2종: 기기 푸시와 알림함 모두, 알림함에만 쌓기 */
public enum NotificationDeliveryMode {
    PUSH_AND_INBOX("푸시 + 알림함", true),
    INBOX_ONLY("알림함만", false);

    private final String label;
    private final boolean isPushIncluded;

    NotificationDeliveryMode(String label, boolean isPushIncluded) {
        this.label = label;
        this.isPushIncluded = isPushIncluded;
    }

    public String getLabel() {
        return label;
    }

    public boolean isPushIncluded() {
        return isPushIncluded;
    }

    /** 요청값 > NotificationDeliveryMode (null·공백이면 PUSH_AND_INBOX, 없는 값 > INVALID_INPUT_VALUE) */
    public static NotificationDeliveryMode fromRequestValue(String requestValue) {
        if (requestValue == null || requestValue.isBlank()) {
            return PUSH_AND_INBOX;
        }
        return RequestEnumParser.parse(NotificationDeliveryMode.class, requestValue);
    }
}
