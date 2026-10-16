package com.passql.web.config;

import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.auth.presentation.annotation.AuthMember;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.media.ObjectSchema;
import io.swagger.v3.oas.models.media.Schema;
import io.swagger.v3.oas.models.media.StringSchema;
import io.swagger.v3.oas.models.servers.Server;
import org.springdoc.core.customizers.OpenApiCustomizer;
import org.springdoc.core.utils.SpringDocUtils;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Arrays;
import java.util.List;

@Configuration
public class SwaggerConfig {

    // 스펙 공통 스키마 이름 (api-contract/openapi.json 에서 웹·앱이 이 이름으로 참조)
    private static final String ERROR_CODE_SCHEMA_NAME = "ErrorCode";
    private static final String ERROR_RESPONSE_SCHEMA_NAME = "ErrorResponse";

    static {
        // @AuthMember LoginMember 는 JWT 에서 채우는 값 > 스펙에서 query 파라미터로 노출 금지
        SpringDocUtils.getConfig().addAnnotationsToIgnore(AuthMember.class);
    }

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("passQL API")
                .description("SQL 학습 플랫폼 passQL 백엔드 API 문서")
                .version("v0.0.3"))
            .servers(List.of(
                new Server().url("https://api.passql.suhsaechan.kr").description("Production"),
                new Server().url("http://localhost:8080").description("Local")
            ));
    }

    /**
     * 에러 응답 계약 스키마 2개 등록: ErrorCode(enum 이름 전체), ErrorResponse({errorCode, message})
     * GlobalExceptionHandler 가 @Hidden 이라 자동 추출이 안 되므로 직접 등록 (#458)
     */
    @Bean
    public OpenApiCustomizer errorContractSchemaCustomizer() {
        return openApi -> {
            if (openApi.getComponents() == null) {
                openApi.setComponents(new Components());
            }
            StringSchema errorCodeSchema = new StringSchema();
            errorCodeSchema.setDescription("서버 ErrorCode enum 이름 (응답 errorCode 값)");
            errorCodeSchema.setEnum(Arrays.stream(ErrorCode.values()).map(Enum::name).toList());

            ObjectSchema errorResponseSchema = new ObjectSchema();
            errorResponseSchema.setDescription("API 에러 응답 표준 형식");
            errorResponseSchema.addProperty("errorCode", new Schema<String>().$ref("#/components/schemas/" + ERROR_CODE_SCHEMA_NAME));
            errorResponseSchema.addProperty("message", new StringSchema());
            errorResponseSchema.setRequired(List.of("errorCode", "message"));

            openApi.getComponents()
                .addSchemas(ERROR_CODE_SCHEMA_NAME, errorCodeSchema)
                .addSchemas(ERROR_RESPONSE_SCHEMA_NAME, errorResponseSchema);
        };
    }
}
