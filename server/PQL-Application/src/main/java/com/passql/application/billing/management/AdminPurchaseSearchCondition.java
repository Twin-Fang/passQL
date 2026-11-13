package com.passql.application.billing.management;

import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;

import java.time.LocalDate;

/**
 * 결제 목록 필터 (#1032): 스토어·상태(없으면 전체), 구매일 구간(둘 다 포함, 없으면 제한 없음)
 */
public record AdminPurchaseSearchCondition(PurchaseStore store, PurchaseStatus status, LocalDate fromDate,
                                           LocalDate toDate) {
}
