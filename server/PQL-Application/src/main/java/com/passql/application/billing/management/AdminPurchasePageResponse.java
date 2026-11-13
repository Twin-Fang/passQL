package com.passql.application.billing.management;

import java.util.List;

/** 결제 목록 한 페이지 (#1032): 행, 0부터 시작하는 페이지, 크기, 전체 건수, 전체 페이지 수 */
public record AdminPurchasePageResponse(List<AdminPurchaseRowResponse> rows, int page, int size, long totalCount,
                                        int totalPageCount) {
}
