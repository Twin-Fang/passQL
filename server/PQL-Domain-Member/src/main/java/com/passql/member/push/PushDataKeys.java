package com.passql.member.push;

/**
 * 푸시 data 키 (앱과의 와이어 계약, 변경 금지)
 * 앱 원본 대응: app/lib/core/push/push_link.dart PushDataKeys
 */
public final class PushDataKeys {

    // 이동 화면: PushLinkTarget 이름
    public static final String LINK_TARGET = "linkTarget";
    // 문제 상세 이동 시 문제 UUID
    public static final String QUESTION_UUID = "questionUuid";
    // Android 알림 채널 ID (앱 android/app/src/main/res/values/strings.xml default_notification_channel_id)
    public static final String ANDROID_CHANNEL_ID = "passql_general";

    private PushDataKeys() {
    }
}
