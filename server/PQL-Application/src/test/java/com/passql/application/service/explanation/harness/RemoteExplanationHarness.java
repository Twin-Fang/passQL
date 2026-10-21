package com.passql.application.service.explanation.harness;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.passql.application.service.explanation.ChoiceSetExplanationPrompt;
import com.passql.application.service.explanation.ExplanationValidationResult;
import com.passql.application.service.explanation.harness.ExplanationHarness.HarnessSample;
import com.passql.application.service.explanation.harness.ExplanationHarness.HarnessSampleResult;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 원격 실측 (#558): 운영 키가 IP 제한·암호화라 호출은 운영 AI 서버 컨테이너(remote_run.py)에서, 요청 생성·채점은 여기서
 * 요청 내보내기(운영 프롬프트 그대로) > 원격 호출 결과 > 운영 검증 채점 > 모델 비교 리포트 (1회 시도 기준, 재시도 없음)
 */
final class RemoteExplanationHarness {

    // 운영 생성기와 같은 호출 값 (ChoiceSetExplanationGenerator: 기본 온도 0.3, 최소 출력 토큰 4096)
    static final float REMOTE_TEMPERATURE = 0.3f;
    static final int REMOTE_MAX_OUTPUT_TOKENS = 4096;

    private static final ObjectMapper JSON_MAPPER = new ObjectMapper().enable(SerializationFeature.INDENT_OUTPUT);

    private RemoteExplanationHarness() {
    }

    /** 원격 호출 1건 결과: 모델, 반복 번호, 샘플, 원문, 지연, 토큰(입력·출력·thinking), 호출 오류 */
    record RemoteCallResult(String model, int run, String sampleId, String rawResponse, long elapsedMilliseconds,
                            Long promptTokenCount, Long candidatesTokenCount, Long thoughtsTokenCount, String error) {
    }

    /** 샘플 > 원격 요청 JSON (시스템 지시·사용자 프롬프트·응답 스키마·온도·출력 상한) */
    static void exportRequests(List<HarnessSample> samples, Path requestFile) throws IOException {
        String responseSchemaJson = ChoiceSetExplanationPrompt.responseSchema().toJson();
        ArrayNode requests = JSON_MAPPER.createArrayNode();
        for (HarnessSample sample : samples) {
            ObjectNode request = requests.addObject();
            request.put("sampleId", sample.sampleId());
            request.put("systemInstruction", ChoiceSetExplanationPrompt.systemInstruction());
            request.put("userPrompt", ChoiceSetExplanationPrompt.buildUserPrompt(sample.question(), sample.items()));
            request.put("responseSchemaJson", responseSchemaJson);
            request.put("temperature", REMOTE_TEMPERATURE);
            request.put("maxOutputTokens", REMOTE_MAX_OUTPUT_TOKENS);
        }
        Files.createDirectories(requestFile.toAbsolutePath().getParent());
        Files.writeString(requestFile, JSON_MAPPER.writeValueAsString(requests), StandardCharsets.UTF_8);
    }

    static List<RemoteCallResult> loadResults(Path resultFile) throws IOException {
        List<RemoteCallResult> results = new ArrayList<>();
        for (JsonNode node : JSON_MAPPER.readTree(resultFile.toFile())) {
            results.add(new RemoteCallResult(node.path("model").asText(), node.path("run").asInt(1), node.path("sampleId").asText(),
                    textOrNull(node, "rawResponse"), node.path("elapsedMilliseconds").asLong(0),
                    longOrNull(node, "promptTokenCount"), longOrNull(node, "candidatesTokenCount"),
                    longOrNull(node, "thoughtsTokenCount"), textOrNull(node, "error")));
        }
        return results;
    }

    /** 모델 비교 리포트: 모델별 요약 표 > 모델별 샘플 리포트(운영 검증 그대로) */
    static String buildComparisonReport(List<HarnessSample> samples, List<RemoteCallResult> callResults) {
        Map<String, HarnessSample> sampleById = samples.stream()
                .collect(Collectors.toMap(HarnessSample::sampleId, Function.identity()));
        Map<String, List<RemoteCallResult>> callsByModel = callResults.stream()
                .collect(Collectors.groupingBy(RemoteCallResult::model, LinkedHashMap::new, Collectors.toList()));

        StringBuilder report = new StringBuilder();
        report.append("# AI 해설 모델 비교 (프롬프트 v").append(ChoiceSetExplanationPrompt.PROMPT_VERSION).append(", 1회 시도 기준)\n\n");
        report.append("| 모델 | 통과 | 호출 실패 | 평균 시간(초) | 평균 입력 토큰 | 평균 출력 토큰 | 평균 thinking 토큰 |\n");
        report.append("|---|---|---|---|---|---|---|\n");
        StringBuilder details = new StringBuilder();
        callsByModel.forEach((model, calls) -> {
            List<HarnessSampleResult> evaluated = calls.stream()
                    .map(call -> evaluate(sampleById.get(call.sampleId()), call))
                    .toList();
            long passedCount = evaluated.stream().filter(HarnessSampleResult::isPassed).count();
            long callFailedCount = calls.stream().filter(call -> call.rawResponse() == null).count();
            report.append(String.format(Locale.ROOT, "| %s | %d / %d | %d | %.1f | %.0f | %.0f | %.0f |%n",
                    model, passedCount, calls.size(), callFailedCount,
                    average(calls, call -> (double) call.elapsedMilliseconds()) / 1000.0,
                    average(calls, call -> toDouble(call.promptTokenCount())),
                    average(calls, call -> toDouble(call.candidatesTokenCount())),
                    average(calls, call -> toDouble(call.thoughtsTokenCount()))));
            details.append("\n---\n\n").append(ExplanationHarness.buildReport(evaluated, "원격 실측 " + model)
                    .replaceFirst("^# ", "## "));
        });
        return report.append(details).toString();
    }

    // 원격 결과 1건 > 운영 검증 (호출 실패는 위반 1건)
    private static HarnessSampleResult evaluate(HarnessSample sample, RemoteCallResult call) {
        if (call.rawResponse() == null) {
            return new HarnessSampleResult(sample, null, new ExplanationValidationResult(
                    List.of("AI 호출 실패: " + call.error()), List.of()), 1, call.elapsedMilliseconds(), null);
        }
        return ExplanationHarness.evaluateRawResponse(sample, call.rawResponse(), 1, call.elapsedMilliseconds());
    }

    // 값 있는 것만 평균 (없으면 0)
    private static double average(List<RemoteCallResult> calls, Function<RemoteCallResult, Double> valueOf) {
        return calls.stream().map(valueOf).filter(value -> value != null).mapToDouble(Double::doubleValue).average().orElse(0);
    }

    private static Double toDouble(Long value) {
        return value == null ? null : value.doubleValue();
    }

    private static String textOrNull(JsonNode node, String fieldName) {
        JsonNode value = node.get(fieldName);
        return value == null || value.isNull() ? null : value.asText();
    }

    private static Long longOrNull(JsonNode node, String fieldName) {
        JsonNode value = node.get(fieldName);
        return value == null || value.isNull() ? null : value.asLong();
    }
}
