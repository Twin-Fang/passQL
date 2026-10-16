package com.passql.web.contract;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.passql.web.config.OpenApiSchemaContractCustomizer;
import com.passql.web.config.SwaggerConfig;
import com.passql.web.config.WebMvcConfig;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.beans.factory.support.BeanDefinitionRegistryPostProcessor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration;
import org.springframework.boot.autoconfigure.data.redis.RedisRepositoriesAutoConfiguration;
import org.springframework.boot.autoconfigure.flyway.FlywayAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;
import org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.util.ClassUtils;
import org.springframework.web.bind.annotation.RestController;

import java.lang.reflect.Constructor;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

/**
 * API 계약 단일 원본 검사: 서버 스펙(/api/**) <-> api-contract/openapi.json, 다르면 실패 (#458)
 * DB·Redis 없이 REST 컨트롤러만 띄움 (컨트롤러 의존 서비스는 Mockito 목으로 자동 등록)
 * 갱신: ./gradlew :PQL-Web:test --tests '*OpenApiContractTest*' -PupdateApiContract
 */
@SpringBootTest(
        classes = OpenApiContractTest.ContractContext.class,
        // application.yml 의 prod 프로필(DB 접속) 대신 빈 프로필, 변경 이력 주입(suh-api-log)은 계약에서 제외
        properties = {"spring.profiles.active=contract", "suhapilog.enabled=false"})
@AutoConfigureMockMvc(addFilters = false)
class OpenApiContractTest {

    // PQL-Web/build.gradle 이 넘기는 시스템 속성: 계약 파일 절대 경로, 갱신 여부(true/false)
    private static final String CONTRACT_FILE_PROPERTY = "apiContractFile";
    private static final String UPDATE_CONTRACT_PROPERTY = "updateApiContract";
    // application.yml springdoc.api-docs.path
    private static final String API_DOCS_PATH = "/docs/api-docs";
    // 회원·공개 API 접두사 (관리자 /admin/** 는 계약 대상 아님)
    private static final String MEMBER_API_PATH_PREFIX = "/api/";

    private static final ObjectMapper CANONICAL_JSON_MAPPER = new ObjectMapper()
            .enable(SerializationFeature.INDENT_OUTPUT)
            .enable(SerializationFeature.ORDER_MAP_ENTRIES_BY_KEYS);

    @Autowired
    private MockMvc mockMvc;

    @Test
    void 서버_스펙이_계약_파일과_같다() throws Exception {
        String generatedContract = fetchCanonicalContract();
        Path contractFile = Path.of(System.getProperty(CONTRACT_FILE_PROPERTY,
                "../../api-contract/openapi.json"));

        // 갱신 모드: 파일 덮어쓰고 종료
        if (Boolean.parseBoolean(System.getProperty(UPDATE_CONTRACT_PROPERTY))) {
            Files.createDirectories(contractFile.getParent());
            Files.writeString(contractFile, generatedContract, StandardCharsets.UTF_8);
            return;
        }

        assertThat(contractFile)
                .as("계약 파일 없음: -PupdateApiContract 로 생성")
                .exists();
        assertThat(Files.readString(contractFile, StandardCharsets.UTF_8))
                .as("API 스펙이 api-contract/openapi.json 과 다름: -PupdateApiContract 로 갱신 후 웹 npm run gen:api")
                .isEqualTo(generatedContract);
    }

    @Test
    void 계약에는_회원_공개_API만_있다() throws Exception {
        JsonNode contract = CANONICAL_JSON_MAPPER.readTree(fetchCanonicalContract());
        List<String> paths = iteratorToList(contract.path("paths").fieldNames());

        assertThat(paths).isNotEmpty().allMatch(path -> path.startsWith(MEMBER_API_PATH_PREFIX));
        assertThat(contract.at("/components/schemas/ErrorCode/enum").isArray()).isTrue();
    }

    /**
     * /docs/api-docs > 키 정렬 JSON 문자열 (중첩 포함, 배열 순서 유지, 마지막 줄바꿈)
     */
    private String fetchCanonicalContract() throws Exception {
        String rawSpec = mockMvc.perform(get(API_DOCS_PATH))
                .andReturn().getResponse().getContentAsString(StandardCharsets.UTF_8);
        Object specTree = CANONICAL_JSON_MAPPER.readValue(rawSpec, Object.class);
        return CANONICAL_JSON_MAPPER.writeValueAsString(specTree) + "\n";
    }

    private static List<String> iteratorToList(Iterator<String> iterator) {
        List<String> values = new ArrayList<>();
        iterator.forEachRemaining(values::add);
        return values;
    }

    /**
     * 계약 생성 전용 최소 컨텍스트: REST 컨트롤러 + Swagger·MVC 설정, DB·Redis·요청 로깅 자동설정 제외
     */
    @Configuration
    @EnableAutoConfiguration(exclude = {
            DataSourceAutoConfiguration.class,
            DataSourceTransactionManagerAutoConfiguration.class,
            HibernateJpaAutoConfiguration.class,
            JpaRepositoriesAutoConfiguration.class,
            FlywayAutoConfiguration.class,
            RedisAutoConfiguration.class,
            RedisRepositoriesAutoConfiguration.class
    }, excludeName = {
            // suh-logger 가 자기 패키지 @SpringBootApplication 까지 스캔 > 위 제외가 무시됨, 요청 로깅은 계약과 무관
            "kr.suhsaechan.suhlogger.config.SuhLoggerAutoConfiguration"
    })
    @ComponentScan(basePackages = "com.passql.web.controller", useDefaultFilters = false,
            includeFilters = @ComponentScan.Filter(type = FilterType.ANNOTATION, classes = RestController.class),
            // 관리자 컨트롤러는 계약 대상 아님 (/admin/**)
            excludeFilters = @ComponentScan.Filter(type = FilterType.REGEX, pattern = "com\\.passql\\.web\\.controller\\.admin\\..*"))
    @Import({SwaggerConfig.class, WebMvcConfig.class, OpenApiSchemaContractCustomizer.class})
    static class ContractContext {

        @Bean
        static BeanDefinitionRegistryPostProcessor controllerDependencyMockRegistrar() {
            return new ControllerDependencyMockRegistrar();
        }
    }

    /**
     * REST 컨트롤러 생성자 의존(com.passql 타입) > Mockito 목 싱글톤 등록 (새 서비스 추가돼도 테스트 수정 불필요)
     * 싱글톤 직접 등록이라 목에는 @Value·@Autowired 주입이 일어나지 않음
     */
    static class ControllerDependencyMockRegistrar implements BeanDefinitionRegistryPostProcessor {

        private static final String PROJECT_PACKAGE_PREFIX = "com.passql.";

        private final Set<Class<?>> dependencyTypes = new LinkedHashSet<>();

        @Override
        public void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) {
            for (String beanName : registry.getBeanDefinitionNames()) {
                Class<?> beanClass = resolveBeanClass(registry.getBeanDefinition(beanName));
                if (beanClass == null || !beanClass.isAnnotationPresent(RestController.class)) {
                    continue;
                }
                for (Constructor<?> constructor : beanClass.getDeclaredConstructors()) {
                    Arrays.stream(constructor.getParameterTypes())
                            .filter(type -> type.getName().startsWith(PROJECT_PACKAGE_PREFIX))
                            .forEach(dependencyTypes::add);
                }
            }
        }

        @Override
        public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) {
            dependencyTypes.forEach(type -> beanFactory.registerSingleton("contractMock" + type.getName(), Mockito.mock(type)));
        }

        private static Class<?> resolveBeanClass(BeanDefinition definition) {
            String className = definition.getBeanClassName();
            if (className == null) {
                return null;
            }
            try {
                return ClassUtils.forName(className, ControllerDependencyMockRegistrar.class.getClassLoader());
            } catch (ClassNotFoundException | LinkageError exception) {
                return null;
            }
        }
    }
}
