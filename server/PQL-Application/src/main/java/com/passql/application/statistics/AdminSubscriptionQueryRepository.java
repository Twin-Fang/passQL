package com.passql.application.statistics;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 관리자 구독·매출 읽기 전용 집계 (PostgreSQL native): 프로 회원, 만료 임박, 상품별 판매, 회수, 금액, 전환
 * 테스트 계정 제외 (member.is_test_account), 시각은 서버 로컬 LocalDateTime 그대로 비교
 */
@Repository
@RequiredArgsConstructor
public class AdminSubscriptionQueryRepository {

    // 구매 행 > 회원 연결 + 테스트 계정 제외 (entitlement_purchase p 와 함께 사용)
    private static final String JOIN_NON_TEST_MEMBER_OF_PURCHASE =
            "JOIN member m ON m.member_uuid = p.member_uuid AND m.is_test_account = FALSE";

    private final NamedParameterJdbcTemplate jdbcTemplate;

    /** 지금 유효한 프로 회원 수 (PRO 이고 만료 전, 탈퇴 제외) */
    public long countActiveProMembers(LocalDateTime now) {
        String sql = """
                SELECT COUNT(*) FROM member_entitlement e
                JOIN member m ON m.member_uuid = e.member_uuid
                WHERE e.plan = 'PRO' AND e.expires_at > :now
                  AND m.is_test_account = FALSE AND m.is_deleted = FALSE
                """;
        return queryForLong(sql, new MapSqlParameterSource("now", now));
    }

    /** now ~ until 사이 만료되는 프로 회원 수 (만료 임박) */
    public long countProMembersExpiringBetween(LocalDateTime now, LocalDateTime until) {
        String sql = """
                SELECT COUNT(*) FROM member_entitlement e
                JOIN member m ON m.member_uuid = e.member_uuid
                WHERE e.plan = 'PRO' AND e.expires_at > :now AND e.expires_at <= :until
                  AND m.is_test_account = FALSE AND m.is_deleted = FALSE
                """;
        return queryForLong(sql, new MapSqlParameterSource().addValue("now", now).addValue("until", until));
    }

    /** 구간 구매 건수 (회수 포함) */
    public long countPurchases(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT COUNT(*) FROM entitlement_purchase p %s
                WHERE p.purchased_at >= :start AND p.purchased_at < :end
                """.formatted(JOIN_NON_TEST_MEMBER_OF_PURCHASE);
        return queryForLong(sql, periodParameters(start, end));
    }

    /** 구간 안에 회수된 구매 건수 (status REVOKED, 회수 시각 = updated_at) */
    public long countRevokedPurchases(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT COUNT(*) FROM entitlement_purchase p %s
                WHERE p.status = 'REVOKED' AND p.updated_at >= :start AND p.updated_at < :end
                """.formatted(JOIN_NON_TEST_MEMBER_OF_PURCHASE);
        return queryForLong(sql, periodParameters(start, end));
    }

    /** 구간 상품·스토어별 판매 건수와 그중 회수 건수 */
    public List<ProductSalesRow> countSalesByProduct(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT p.product_id, p.store, COUNT(*), COUNT(*) FILTER (WHERE p.status = 'REVOKED')
                FROM entitlement_purchase p %s
                WHERE p.purchased_at >= :start AND p.purchased_at < :end
                GROUP BY p.product_id, p.store
                ORDER BY COUNT(*) DESC, p.product_id
                """.formatted(JOIN_NON_TEST_MEMBER_OF_PURCHASE);
        return jdbcTemplate.query(sql, periodParameters(start, end), (resultSet, rowNumber) -> new ProductSalesRow(
                resultSet.getString(1), resultSet.getString(2), resultSet.getLong(3), resultSet.getLong(4)));
    }

    /** 구간 유효 구매(회수 제외)의 통화별 금액 합 (금액·통화가 기록된 건만, micros 단위) */
    public List<CurrencyAmountRow> sumVerifiedAmountByCurrency(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT p.currency_code, COALESCE(SUM(p.price_amount_micros), 0), COUNT(*)
                FROM entitlement_purchase p %s
                WHERE p.status = 'VERIFIED' AND p.purchased_at >= :start AND p.purchased_at < :end
                  AND p.price_amount_micros IS NOT NULL AND p.currency_code IS NOT NULL
                GROUP BY p.currency_code
                ORDER BY p.currency_code
                """.formatted(JOIN_NON_TEST_MEMBER_OF_PURCHASE);
        return jdbcTemplate.query(sql, periodParameters(start, end), (resultSet, rowNumber) -> new CurrencyAmountRow(
                resultSet.getString(1), resultSet.getLong(2), resultSet.getLong(3)));
    }

    /** 구간 유효 구매 중 금액 미기록 건수 */
    public long countVerifiedPurchasesWithoutAmount(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT COUNT(*) FROM entitlement_purchase p %s
                WHERE p.status = 'VERIFIED' AND p.purchased_at >= :start AND p.purchased_at < :end
                  AND (p.price_amount_micros IS NULL OR p.currency_code IS NULL)
                """.formatted(JOIN_NON_TEST_MEMBER_OF_PURCHASE);
        return queryForLong(sql, periodParameters(start, end));
    }

    /** 일별 구매 건수 */
    public List<DailyCountRow> countPurchasesByDay(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT CAST(p.purchased_at AS date), COUNT(*)
                FROM entitlement_purchase p %s
                WHERE p.purchased_at >= :start AND p.purchased_at < :end
                GROUP BY 1
                """.formatted(JOIN_NON_TEST_MEMBER_OF_PURCHASE);
        return jdbcTemplate.query(sql, periodParameters(start, end), (resultSet, rowNumber) -> new DailyCountRow(
                resultSet.getDate(1).toLocalDate(), resultSet.getLong(2)));
    }

    /** 구간 가입자 수와 그중 구매 이력이 있는 회원 수 (무료 > 프로 전환) */
    public ConversionRow countSignupConversion(LocalDateTime start, LocalDateTime end) {
        String sql = """
                SELECT COUNT(*), COUNT(*) FILTER (WHERE EXISTS (
                           SELECT 1 FROM entitlement_purchase p WHERE p.member_uuid = m.member_uuid))
                FROM member m
                WHERE m.is_test_account = FALSE AND m.created_at >= :start AND m.created_at < :end
                """;
        return queryForConversion(sql, periodParameters(start, end));
    }

    /** 현재 남아 있는 전체 회원 수와 그중 구매 이력이 있는 회원 수 */
    public ConversionRow countAllMemberConversion() {
        String sql = """
                SELECT COUNT(*), COUNT(*) FILTER (WHERE EXISTS (
                           SELECT 1 FROM entitlement_purchase p WHERE p.member_uuid = m.member_uuid))
                FROM member m
                WHERE m.is_test_account = FALSE AND m.is_deleted = FALSE
                """;
        return queryForConversion(sql, new MapSqlParameterSource());
    }

    private ConversionRow queryForConversion(String sql, MapSqlParameterSource parameters) {
        return jdbcTemplate.queryForObject(sql, parameters, (resultSet, rowNumber) ->
                new ConversionRow(resultSet.getLong(1), resultSet.getLong(2)));
    }

    private long queryForLong(String sql, MapSqlParameterSource parameters) {
        Long count = jdbcTemplate.queryForObject(sql, parameters, Long.class);
        return count == null ? 0 : count;
    }

    private static MapSqlParameterSource periodParameters(LocalDateTime start, LocalDateTime end) {
        return new MapSqlParameterSource().addValue("start", start).addValue("end", end);
    }

    /** 상품·스토어별 판매 (soldCount 회수 포함, revokedCount 그중 회수) */
    public record ProductSalesRow(String productId, String store, long soldCount, long revokedCount) {}

    /** 통화별 금액 합 (amountMicros = 통화 단위 x 1,000,000) */
    public record CurrencyAmountRow(String currencyCode, long amountMicros, long purchaseCount) {}

    /** 일별 건수 */
    public record DailyCountRow(LocalDate date, long count) {}

    /** 회원 수와 그중 구매 이력 있는 회원 수 */
    public record ConversionRow(long memberCount, long purchasedMemberCount) {}
}
