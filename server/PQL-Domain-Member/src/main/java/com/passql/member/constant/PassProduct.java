package com.passql.member.constant;

import java.util.Arrays;
import java.util.Optional;

/**
 * 판매 이용권 단일 원본 (Play 소모형 상품 ID, 이용 일수), 선언 순서 = 결제 시트 표시 순서 (3개월 먼저)
 * 자동 갱신 없음, 같은 회원 재구매는 현재 만료일 뒤로 이어 붙임 (#591)
 */
public enum PassProduct {

    PRO_PASS_3M("pro_pass_3m", 90),  // 3개월 이용권 (기본 선택)
    PRO_PASS_1M("pro_pass_1m", 30);  // 1개월 이용권 (연장용)

    private final String productId;
    private final int durationDays;

    PassProduct(String productId, int durationDays) {
        this.productId = productId;
        this.durationDays = durationDays;
    }

    public String getProductId() {
        return productId;
    }

    public int getDurationDays() {
        return durationDays;
    }

    /** Play 상품 ID > 이용권, 판매하지 않는 ID(옛 pro_exam_pass 등)·null 이면 empty */
    public static Optional<PassProduct> fromProductId(String productId) {
        return Arrays.stream(values())
            .filter(passProduct -> passProduct.productId.equals(productId))
            .findFirst();
    }
}
