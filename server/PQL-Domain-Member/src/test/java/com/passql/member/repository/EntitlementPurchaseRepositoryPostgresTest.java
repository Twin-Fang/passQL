package com.passql.member.repository;

import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.entity.EntitlementPurchase;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 구매 기록 ON CONFLICT 저장·회원 행 잠금 실 PostgreSQL 검증 (#576): 토큰·주문 번호 충돌은 예외 없이 0건
 * 빈 DB 에서만 실행 (create-drop): ENTITLEMENT_PURCHASE_TEST_DB_URL=jdbc:postgresql://localhost:5432/{빈 DB} (+ _USER, _PASSWORD)
 */
@DataJpaTest(properties = {"spring.jpa.hibernate.ddl-auto=create-drop", "spring.flyway.enabled=false"})
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ContextConfiguration(classes = EntitlementPurchaseRepositoryPostgresTest.PostgresTestContext.class)
@Transactional(propagation = Propagation.NOT_SUPPORTED)
@EnabledIfEnvironmentVariable(named = "ENTITLEMENT_PURCHASE_TEST_DB_URL", matches = "jdbc:postgresql:.+")
class EntitlementPurchaseRepositoryPostgresTest {

    @SpringBootConfiguration
    @EnableAutoConfiguration
    @EntityScan(basePackageClasses = EntitlementPurchase.class)
    @EnableJpaRepositories(basePackageClasses = EntitlementPurchaseRepository.class)
    static class PostgresTestContext {
    }

    @DynamicPropertySource
    static void postgresProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", () -> System.getenv("ENTITLEMENT_PURCHASE_TEST_DB_URL"));
        registry.add("spring.datasource.username", () -> envOrDefault("ENTITLEMENT_PURCHASE_TEST_DB_USER", "postgres"));
        registry.add("spring.datasource.password", () -> envOrDefault("ENTITLEMENT_PURCHASE_TEST_DB_PASSWORD", ""));
    }

    @Autowired EntitlementPurchaseRepository purchaseRepository;
    @Autowired MemberRepository memberRepository;
    @Autowired PlatformTransactionManager transactionManager;

    private final UUID memberUuid = UUID.randomUUID();
    private final LocalDateTime now = LocalDateTime.now();

    @BeforeEach
    void setUp() {
        purchaseRepository.deleteAll();
    }

    @Test
    void 같은_토큰이나_주문_번호는_예외_없이_0건이고_처음_저장은_1건() {
        assertThat(insert("GPA.1", "token-1")).isEqualTo(1);
        assertThat(insert("GPA.2", "token-1")).as("같은 토큰").isZero();
        assertThat(insert("GPA.1", "token-2")).as("같은 주문 번호").isZero();

        EntitlementPurchase saved = purchaseRepository.findByPurchaseToken("token-1").orElseThrow();
        assertThat(saved.getStatus()).isEqualTo(PurchaseStatus.VERIFIED);
        assertThat(saved.getStore()).isEqualTo(PurchaseStore.PLAY);
        assertThat(saved.getIsConsumed()).isFalse();
        assertThat(saved.getMemberUuid()).isEqualTo(memberUuid);
        assertThat(purchaseRepository.count()).isEqualTo(1);
    }

    @Test
    void 회원_행_잠금_쿼리는_트랜잭션_안에서_실행된다() {
        // 회원 행이 없으면 빈 값 (SQL·바인딩 확인용)
        Optional<UUID> lockedMemberUuid = new TransactionTemplate(transactionManager)
            .execute(status -> memberRepository.lockByMemberUuid(UUID.randomUUID()));
        assertThat(lockedMemberUuid).isEmpty();
    }

    private int insert(String orderId, String purchaseToken) {
        Integer insertedCount = new TransactionTemplate(transactionManager).execute(status ->
            purchaseRepository.insertVerifiedIfAbsent(UUID.randomUUID(), memberUuid, PurchaseStore.PLAY.name(),
                "pro_exam_pass", orderId, purchaseToken, now, PurchaseStatus.VERIFIED.name(), now.plusDays(90),
                now, "system"));
        return insertedCount == null ? 0 : insertedCount;
    }

    private static String envOrDefault(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? defaultValue : value;
    }
}
