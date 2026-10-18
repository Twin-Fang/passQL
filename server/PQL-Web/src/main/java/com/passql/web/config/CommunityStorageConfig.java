package com.passql.web.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.checksums.RequestChecksumCalculation;
import software.amazon.awssdk.core.checksums.ResponseChecksumValidation;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.S3Configuration;

import java.net.URI;

/**
 * 커뮤니티 이미지 저장소(MinIO, S3 호환) 클라이언트: path-style, 설정 4개가 모두 있을 때만 생성
 * 설정 키(application-prod.yml Secret): passql.storage.endpoint, bucket, access-key, secret-key
 */
@Configuration
@ConditionalOnProperty(prefix = "passql.storage", name = {"endpoint", "bucket", "access-key", "secret-key"})
public class CommunityStorageConfig {

    // MinIO 는 리전을 보지 않지만 SDK 가 요구함
    private static final Region SIGNING_REGION = Region.US_EAST_1;

    @Bean(destroyMethod = "close")
    public S3Client communityStorageS3Client(@Value("${passql.storage.endpoint}") String endpoint,
                                             @Value("${passql.storage.access-key}") String accessKey,
                                             @Value("${passql.storage.secret-key}") String secretKey) {
        return S3Client.builder()
                .endpointOverride(URI.create(endpoint))
                .region(SIGNING_REGION)
                .credentialsProvider(StaticCredentialsProvider.create(AwsBasicCredentials.create(accessKey, secretKey)))
                .serviceConfiguration(S3Configuration.builder().pathStyleAccessEnabled(true).build())
                // 필요한 요청에만 체크섬 (기본 CRC 트레일러는 일부 MinIO 버전이 거절)
                .requestChecksumCalculation(RequestChecksumCalculation.WHEN_REQUIRED)
                .responseChecksumValidation(ResponseChecksumValidation.WHEN_REQUIRED)
                .build();
    }
}
