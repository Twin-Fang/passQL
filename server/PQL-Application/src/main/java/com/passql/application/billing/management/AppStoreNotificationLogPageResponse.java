package com.passql.application.billing.management;

import java.util.List;

/** App Store 알림 수신 기록 한 페이지 (#1032) */
public record AppStoreNotificationLogPageResponse(List<AppStoreNotificationLogResponse> rows, int page, int size,
                                                  long totalCount, int totalPageCount) {
}
