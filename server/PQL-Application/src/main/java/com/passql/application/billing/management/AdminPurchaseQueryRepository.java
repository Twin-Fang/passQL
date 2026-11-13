package com.passql.application.billing.management;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 관리자 결제 목록 읽기 전용 조회 (PostgreSQL native, #1032): 필터(스토어·상태·구매일) > 최신 구매순, 테스트 계정 포함(표시만)
 */
@Repository
@RequiredArgsConstructor
public class AdminPurchaseQueryRepository {

    private static final String SELECT_COLUMNS = """
        SELECT p.entitlement_purchase_uuid, p.member_uuid, m.nickname, m.is_test_account, p.store, p.product_id,
               p.status, p.price_amount_micros, p.currency_code, p.purchased_at, p.granted_expires_at, p.revoked_at,
               p.order_id
        FROM entitlement_purchase p
        LEFT JOIN member m ON m.member_uuid = p.member_uuid
        """;

    private final NamedParameterJdbcTemplate jdbcTemplate;

    /** 조건에 맞는 구매 (최신 구매순, offset·limit) */
    public List<PurchaseRow> findPurchases(AdminPurchaseSearchCondition condition, long offset, int limit) {
        MapSqlParameterSource parameters = new MapSqlParameterSource().addValue("offset", offset).addValue("limit", limit);
        String sql = SELECT_COLUMNS + buildWhereClause(condition, parameters)
            + " ORDER BY p.purchased_at DESC, p.entitlement_purchase_uuid OFFSET :offset LIMIT :limit";
        return jdbcTemplate.query(sql, parameters, PURCHASE_ROW_MAPPER);
    }

    /** 조건에 맞는 구매 수 */
    public long countPurchases(AdminPurchaseSearchCondition condition) {
        MapSqlParameterSource parameters = new MapSqlParameterSource();
        String sql = "SELECT COUNT(*) FROM entitlement_purchase p" + buildWhereClause(condition, parameters);
        Long count = jdbcTemplate.queryForObject(sql, parameters, Long.class);
        return count == null ? 0 : count;
    }

    /** 필터 4개(스토어·상태·시작일·종료일) > WHERE 절 + 바인딩 값 (없는 필터는 생략) */
    private static String buildWhereClause(AdminPurchaseSearchCondition condition, MapSqlParameterSource parameters) {
        List<String> predicates = new ArrayList<>();
        if (condition.store() != null) {
            predicates.add("p.store = :store");
            parameters.addValue("store", condition.store().name());
        }
        if (condition.status() != null) {
            predicates.add("p.status = :status");
            parameters.addValue("status", condition.status().name());
        }
        if (condition.fromDate() != null) {
            predicates.add("p.purchased_at >= :start");
            parameters.addValue("start", condition.fromDate().atStartOfDay());
        }
        if (condition.toDate() != null) {
            predicates.add("p.purchased_at < :end");
            parameters.addValue("end", condition.toDate().plusDays(1).atStartOfDay());
        }
        return predicates.isEmpty() ? "" : " WHERE " + String.join(" AND ", predicates);
    }

    private static final RowMapper<PurchaseRow> PURCHASE_ROW_MAPPER = (resultSet, rowNumber) -> new PurchaseRow(
        resultSet.getObject(1, UUID.class), resultSet.getObject(2, UUID.class), resultSet.getString(3),
        (Boolean) resultSet.getObject(4), resultSet.getString(5), resultSet.getString(6), resultSet.getString(7),
        (Long) resultSet.getObject(8), resultSet.getString(9), toLocalDateTime(resultSet.getTimestamp(10)),
        toLocalDateTime(resultSet.getTimestamp(11)), toLocalDateTime(resultSet.getTimestamp(12)), resultSet.getString(13));

    private static LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toLocalDateTime();
    }

    /** 구매 1행 원본 (금액 micros, 탈퇴 등으로 회원 행이 없으면 nickname·isTestAccount null) */
    public record PurchaseRow(UUID entitlementPurchaseUuid, UUID memberUuid, String memberNickname, Boolean isTestAccount,
                              String store, String productId, String status, Long priceAmountMicros,
                              String currencyCode, LocalDateTime purchasedAt, LocalDateTime grantedExpiresAt,
                              LocalDateTime revokedAt, String orderId) {}
}
