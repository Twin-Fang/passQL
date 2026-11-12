package com.passql.application.billing.management;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 실수령액 읽기 전용 집계 (PostgreSQL native, #1032): 구매 시각 구간, 테스트 계정 제외
 * 금액 = price_amount_micros (회수 포함 판매 총액 / 그중 회수분), 금액·통화 없는 구매는 따로 셈
 */
@Repository
@RequiredArgsConstructor
public class BillingPayoutQueryRepository {

    // 구매 행 > 회원 연결 + 테스트 계정 제외 (entitlement_purchase p 와 함께 사용)
    private static final String JOIN_NON_TEST_MEMBER_OF_PURCHASE =
        "JOIN member m ON m.member_uuid = p.member_uuid AND m.is_test_account = FALSE";

    private final NamedParameterJdbcTemplate jdbcTemplate;

    /** 스토어·상품·통화별 판매 총액·회수 금액·건수 (금액이 기록된 구매만) */
    public List<ProductAmountRow> sumAmountByStoreProductCurrency(LocalDateTime start, LocalDateTime end) {
        String sql = """
            SELECT p.store, p.product_id, p.currency_code,
                   COALESCE(SUM(p.price_amount_micros), 0),
                   COALESCE(SUM(p.price_amount_micros) FILTER (WHERE p.status = 'REVOKED'), 0),
                   COUNT(*), COUNT(*) FILTER (WHERE p.status = 'REVOKED')
            FROM entitlement_purchase p %s
            WHERE p.purchased_at >= :start AND p.purchased_at < :end
              AND p.price_amount_micros IS NOT NULL AND p.currency_code IS NOT NULL
            GROUP BY p.store, p.product_id, p.currency_code
            ORDER BY p.currency_code, p.store, p.product_id
            """.formatted(JOIN_NON_TEST_MEMBER_OF_PURCHASE);
        return jdbcTemplate.query(sql, periodParameters(start, end), (resultSet, rowNumber) -> new ProductAmountRow(
            resultSet.getString(1), resultSet.getString(2), resultSet.getString(3), resultSet.getLong(4),
            resultSet.getLong(5), resultSet.getLong(6), resultSet.getLong(7)));
    }

    /** 금액 미확인 구매 수 (금액 또는 통화 없음, 회수 포함) */
    public long countPurchasesWithoutAmount(LocalDateTime start, LocalDateTime end) {
        String sql = """
            SELECT COUNT(*) FROM entitlement_purchase p %s
            WHERE p.purchased_at >= :start AND p.purchased_at < :end
              AND (p.price_amount_micros IS NULL OR p.currency_code IS NULL)
            """.formatted(JOIN_NON_TEST_MEMBER_OF_PURCHASE);
        Long count = jdbcTemplate.queryForObject(sql, periodParameters(start, end), Long.class);
        return count == null ? 0 : count;
    }

    /** 통화 1개의 월·스토어별 판매 총액·회수 금액 (월: yyyy-MM) */
    public List<MonthlyAmountRow> sumMonthlyAmountByStore(String currencyCode, LocalDateTime start, LocalDateTime end) {
        String sql = """
            SELECT TO_CHAR(p.purchased_at, 'YYYY-MM'), p.store,
                   COALESCE(SUM(p.price_amount_micros), 0),
                   COALESCE(SUM(p.price_amount_micros) FILTER (WHERE p.status = 'REVOKED'), 0),
                   COUNT(*), COUNT(*) FILTER (WHERE p.status = 'REVOKED')
            FROM entitlement_purchase p %s
            WHERE p.purchased_at >= :start AND p.purchased_at < :end
              AND p.price_amount_micros IS NOT NULL AND p.currency_code = :currencyCode
            GROUP BY 1, 2
            """.formatted(JOIN_NON_TEST_MEMBER_OF_PURCHASE);
        MapSqlParameterSource parameters = periodParameters(start, end).addValue("currencyCode", currencyCode);
        return jdbcTemplate.query(sql, parameters, (resultSet, rowNumber) -> new MonthlyAmountRow(
            resultSet.getString(1), resultSet.getString(2), resultSet.getLong(3), resultSet.getLong(4),
            resultSet.getLong(5), resultSet.getLong(6)));
    }

    private static MapSqlParameterSource periodParameters(LocalDateTime start, LocalDateTime end) {
        return new MapSqlParameterSource().addValue("start", start).addValue("end", end);
    }

    /** 스토어·상품·통화별 합계 (금액 micros, 판매 수 회수 포함) */
    public record ProductAmountRow(String store, String productId, String currencyCode, long grossAmountMicros,
                                   long refundAmountMicros, long purchaseCount, long revokedCount) {}

    /** 월·스토어별 합계 */
    public record MonthlyAmountRow(String month, String store, long grossAmountMicros, long refundAmountMicros,
                                   long purchaseCount, long revokedCount) {}
}
