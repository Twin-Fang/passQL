package com.passql.ai.service;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.dto.AiModelPrice;
import com.passql.common.exception.CustomException;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

/**
 * AI 비용 추정: 단가표(app_setting ai.model_price_table) × 토큰 수, 월 예산(ai.monthly_budget_usd) 조회
 * 모델 매칭: 정확 일치 > 가장 긴 접두 일치 > 단가 미등록 (#557)
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AiCostCalculator {

    // 단가 기준 토큰 수 (1M)
    private static final double TOKENS_PER_PRICE_UNIT = 1_000_000d;
    // 월 예산 설정 없음·형식 오류 시 기본값 (USD)
    static final double DEFAULT_MONTHLY_BUDGET_USD = 10d;

    private static final ObjectMapper PRICE_TABLE_MAPPER = new ObjectMapper();
    private static final TypeReference<Map<String, PriceTableEntry>> PRICE_TABLE_TYPE = new TypeReference<>() {
    };

    private final AppSettingService appSettingService;

    // 단가표 재조회 간격 (30초, 통계 1회 요청에서 행마다 설정을 읽지 않게)
    private static final long PRICE_TABLE_REFRESH_MILLISECONDS = 30_000L;

    // 마지막으로 읽은 단가표 원문·결과·읽은 시각 (30초 지나면 원문 다시 읽고, 원문이 바뀔 때만 다시 파싱)
    private volatile ParsedPriceTable cachedPriceTable;

    private record ParsedPriceTable(String rawJson, List<AiModelPrice> prices, long loadedAtMilliseconds) {
    }

    // 단가표 JSON 항목 1개 ({"inputUsdPerMillion":0.10,"outputUsdPerMillion":0.40}, 그 외 키는 무시)
    @JsonIgnoreProperties(ignoreUnknown = true)
    private record PriceTableEntry(Double inputUsdPerMillion, Double outputUsdPerMillion) {
    }

    /** 모델 단가 (정확 일치 > 가장 긴 접두 일치, 없으면 empty) */
    public Optional<AiModelPrice> findPrice(String modelName) {
        if (modelName == null || modelName.isBlank()) {
            return Optional.empty();
        }
        String trimmedModelName = modelName.trim();
        List<AiModelPrice> prices = getPriceTable();
        Optional<AiModelPrice> exactMatch = prices.stream()
                .filter(price -> price.modelName().equals(trimmedModelName))
                .findFirst();
        if (exactMatch.isPresent()) {
            return exactMatch;
        }
        return prices.stream()
                .filter(price -> trimmedModelName.startsWith(price.modelName()))
                .max(Comparator.comparingInt(price -> price.modelName().length()));
    }

    /** 추정 비용 (USD, 단가 미등록이면 0) */
    public double estimateCostUsd(String modelName, long promptTokenCount, long completionTokenCount) {
        return findPrice(modelName)
                .map(price -> (promptTokenCount * price.inputUsdPerMillion()
                        + completionTokenCount * price.outputUsdPerMillion()) / TOKENS_PER_PRICE_UNIT)
                .orElse(0d);
    }

    public boolean isPriceRegistered(String modelName) {
        return findPrice(modelName).isPresent();
    }

    /** 단가표 전체 (모델명순, 설정 없음·JSON 깨짐이면 빈 목록) */
    public List<AiModelPrice> getPriceTable() {
        long nowMilliseconds = System.currentTimeMillis();
        ParsedPriceTable cached = cachedPriceTable;
        if (cached != null && nowMilliseconds - cached.loadedAtMilliseconds() < PRICE_TABLE_REFRESH_MILLISECONDS) {
            return cached.prices();
        }
        String rawJson = Objects.requireNonNullElse(readSettingOrNull(AppSettingKeys.AI_MODEL_PRICE_TABLE), "");
        List<AiModelPrice> prices = cached != null && cached.rawJson().equals(rawJson)
                ? cached.prices()
                : parsePriceTableOrEmpty(rawJson);
        cachedPriceTable = new ParsedPriceTable(rawJson, prices, nowMilliseconds);
        return prices;
    }

    // 빈 설정은 빈 표
    private static List<AiModelPrice> parsePriceTableOrEmpty(String rawJson) {
        return rawJson.isBlank() ? List.of() : parsePriceTable(rawJson);
    }

    /** 월 예산 (USD, 설정 없음·형식 오류면 기본 10) */
    public double getMonthlyBudgetUsd() {
        String rawBudget = readSettingOrNull(AppSettingKeys.AI_MONTHLY_BUDGET_USD);
        if (rawBudget == null || rawBudget.isBlank()) {
            return DEFAULT_MONTHLY_BUDGET_USD;
        }
        try {
            double budgetUsd = Double.parseDouble(rawBudget.trim());
            return Double.isFinite(budgetUsd) && budgetUsd >= 0 ? budgetUsd : DEFAULT_MONTHLY_BUDGET_USD;
        } catch (NumberFormatException e) {
            log.warn("[ai cost] invalid monthly budget : using default {}", DEFAULT_MONTHLY_BUDGET_USD);
            return DEFAULT_MONTHLY_BUDGET_USD;
        }
    }

    // 설정 행 없음은 null (마이그레이션 전 환경에서도 대시보드가 멈추지 않게)
    private String readSettingOrNull(String settingKey) {
        try {
            return appSettingService.getString(settingKey);
        } catch (CustomException e) {
            return null;
        }
    }

    /** 단가표 JSON > 단가 목록 (JSON 깨짐은 빈 목록, 단가 빠진 항목은 제외) */
    private static List<AiModelPrice> parsePriceTable(String rawJson) {
        Map<String, PriceTableEntry> entryByModelName;
        try {
            entryByModelName = PRICE_TABLE_MAPPER.readValue(rawJson, PRICE_TABLE_TYPE);
        } catch (Exception e) {
            log.warn("[ai cost] price table parse failed : {}", e.getClass().getSimpleName());
            return List.of();
        }
        if (entryByModelName == null) {
            return List.of();
        }
        return entryByModelName.entrySet().stream()
                .filter(entry -> isValidPriceEntry(entry.getKey(), entry.getValue()))
                .map(entry -> new AiModelPrice(entry.getKey().trim(),
                        entry.getValue().inputUsdPerMillion(), entry.getValue().outputUsdPerMillion()))
                .sorted(Comparator.comparing(AiModelPrice::modelName))
                .toList();
    }

    private static boolean isValidPriceEntry(String modelName, PriceTableEntry entry) {
        boolean isValid = modelName != null && !modelName.isBlank() && entry != null
                && entry.inputUsdPerMillion() != null && entry.outputUsdPerMillion() != null;
        if (!isValid) {
            log.warn("[ai cost] price table entry skipped : missing model name or price");
        }
        return isValid;
    }
}
