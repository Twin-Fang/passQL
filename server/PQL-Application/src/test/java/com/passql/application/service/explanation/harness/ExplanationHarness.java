package com.passql.application.service.explanation.harness;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.passql.ai.client.GeminiClient;
import com.passql.ai.service.AiCallLogService;
import com.passql.application.service.explanation.ChoiceSetExplanationGenerationResult;
import com.passql.application.service.explanation.ChoiceSetExplanationGenerator;
import com.passql.application.service.explanation.ChoiceSetExplanationPrompt;
import com.passql.application.service.explanation.ChoiceSetExplanationValidator;
import com.passql.application.service.explanation.ExplanationValidationResult;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.service.AppSettingService;
import com.passql.meta.service.PromptService;
import com.passql.question.dto.explanation.ChoiceSetExplanation;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.service.ChoiceExplanationComposer;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * AI 해설 품질 하네스 (#521): 샘플 문제 > 해설 생성(실호출) 또는 기록본(오프라인) > 서버와 같은 검증 > 가독성 지표 > 리포트
 * 프롬프트·검증·마크다운은 운영 코드(ChoiceSetExplanationPrompt·Validator·Composer) 그대로 사용 (사본 없음)
 * 실행 방법: tools/explanation-harness/README.md
 */
public final class ExplanationHarness {

    // 하네스 폴더 (레포 루트 기준)
    static final String HARNESS_DIRECTORY = "tools/explanation-harness";
    // Oracle 검증 샘플 (tools/sqld-question-harness/harness.py verify 출력)
    static final String SAMPLE_FILE = "samples/oracle-verified-import.json";
    // 실호출 응답 기록: recorded/v{프롬프트 버전}/{샘플 id}.json
    static final String RECORDED_DIRECTORY = "recorded";
    // 실호출 리포트: reports/prompt-v{프롬프트 버전}.md
    static final String REPORT_DIRECTORY = "reports";

    // 실호출 모델 기본값 (운영 diff_explain 활성 프롬프트 모델, V0_0_228)
    private static final String DEFAULT_LIVE_MODEL = "gemini-3.5-flash-lite";
    private static final float LIVE_TEMPERATURE = 0.3f;
    private static final int LIVE_MAX_TOKENS = 1024;
    // 문장 나누기 (마침표·줄바꿈)
    private static final Pattern SENTENCE_SPLIT_PATTERN = Pattern.compile("(?<=[.!?])\\s+|\\n+");

    private static final ObjectMapper JSON_MAPPER = new ObjectMapper().enable(SerializationFeature.INDENT_OUTPUT);

    private ExplanationHarness() {
    }

    /** 샘플 1건: id, 문제, 보기 */
    record HarnessSample(String sampleId, String topicCode, Question question, List<QuestionChoiceSetItem> items) {}

    /** 샘플 1건 평가: 해설·검증·가독성 지표·시도·시간 (해설 없으면 파싱·호출 실패) */
    record HarnessSampleResult(HarnessSample sample, ChoiceSetExplanation explanation, ExplanationValidationResult validation,
                               int attemptCount, long elapsedMilliseconds, ReadabilityMetrics readability) {

        boolean isPassed() {
            return explanation != null && validation.isValid();
        }
    }

    /** 가독성 지표: 마크다운 총 글자 수, 문장 수, 문장 평균 글자 수, 가장 긴 문장 */
    record ReadabilityMetrics(int totalCharacters, int sentenceCount, int averageSentenceCharacters, int longestSentenceCharacters) {}

    // ── 샘플 ─────────────────────────────────────────────

    /** Oracle 검증 가져오기 JSON > 샘플 목록 (id = 순번-토픽), isWithRationale false 면 생성 근거 제거 (AI 자체 추론 평가) */
    static List<HarnessSample> loadSamples(Path harnessDirectory, boolean isWithRationale) throws IOException {
        JsonNode root = JSON_MAPPER.readTree(harnessDirectory.resolve(SAMPLE_FILE).toFile());
        List<HarnessSample> samples = new ArrayList<>();
        for (int index = 0; index < root.size(); index++) {
            JsonNode node = root.get(index);
            String sampleId = String.format(Locale.ROOT, "%02d-%s", index + 1, node.path("topicCode").asText());
            Question question = Question.builder()
                    .stem(node.path("stem").asText())
                    .schemaDdl(textOrNull(node, "schemaDdl"))
                    .schemaSampleData(textOrNull(node, "schemaSampleData"))
                    .answerSql(textOrNull(node, "answerSql"))
                    .build();
            List<QuestionChoiceSetItem> items = new ArrayList<>();
            int sortOrder = 0;
            for (JsonNode choice : node.path("choices")) {
                items.add(QuestionChoiceSetItem.builder()
                        .choiceKey(choice.path("choiceKey").asText())
                        .sortOrder(sortOrder++)
                        .body(choice.path("body").asText())
                        .isCorrect(choice.path("isCorrect").asBoolean())
                        .rationale(isWithRationale ? textOrNull(choice, "rationale") : null)
                        .build());
            }
            samples.add(new HarnessSample(sampleId, node.path("topicCode").asText(), question, items));
        }
        return samples;
    }

    // ── 평가 ─────────────────────────────────────────────

    /** 실호출: 운영 생성기(재시도 포함)로 생성 > 마지막 응답 원문 기록 (호출 실패면 기존 기록본 유지) */
    static HarnessSampleResult evaluateLive(ChoiceSetExplanationGenerator generator, HarnessSample sample, Path recordedDirectory)
            throws IOException {
        ChoiceSetExplanationGenerationResult result = generator.generate(sample.question(), sample.items());
        if (result.rawResponse() == null) {
            return new HarnessSampleResult(sample, null, new ExplanationValidationResult(
                    List.of("AI 호출 실패 (키·IP 제한·할당량 확인, 로그 참고)"), List.of()),
                    result.attemptCount(), result.elapsedMilliseconds(), null);
        }
        ObjectNode record = JSON_MAPPER.createObjectNode();
        record.put("source", "live");
        record.put("promptVersion", ChoiceSetExplanationPrompt.PROMPT_VERSION);
        record.put("attemptCount", result.attemptCount());
        record.put("elapsedMilliseconds", result.elapsedMilliseconds());
        record.put("rawResponse", result.rawResponse());
        Files.createDirectories(recordedDirectory);
        Files.writeString(recordedDirectory.resolve(sample.sampleId() + ".json"), JSON_MAPPER.writeValueAsString(record));
        return evaluateRawResponse(sample, result.rawResponse(), result.attemptCount(), result.elapsedMilliseconds());
    }

    /** 오프라인: 기록본 원문 > 같은 검증 (기록 없으면 실패) */
    static HarnessSampleResult evaluateRecorded(HarnessSample sample, Path recordedDirectory) throws IOException {
        Path recordFile = recordedDirectory.resolve(sample.sampleId() + ".json");
        if (!Files.exists(recordFile)) {
            return new HarnessSampleResult(sample, null,
                    new ExplanationValidationResult(List.of("기록본 없음: " + recordFile.getFileName()), List.of()), 0, 0, null);
        }
        JsonNode record = JSON_MAPPER.readTree(recordFile.toFile());
        return evaluateRawResponse(sample, textOrNull(record, "rawResponse"),
                record.path("attemptCount").asInt(1), record.path("elapsedMilliseconds").asLong(0));
    }

    /** 원문 > 파싱 > 검증 > 가독성 (운영 저장 직전과 같은 검증) */
    static HarnessSampleResult evaluateRawResponse(HarnessSample sample, String rawResponse, int attemptCount, long elapsedMilliseconds) {
        ChoiceSetExplanation explanation = ChoiceExplanationComposer.parse(rawResponse).orElse(null);
        ExplanationValidationResult validation = explanation == null
                ? new ExplanationValidationResult(List.of("응답 JSON 파싱 실패"), List.of())
                : ChoiceSetExplanationValidator.validate(explanation, sample.items());
        ReadabilityMetrics readability = explanation == null ? null : measureReadability(toWrongPickMarkdown(explanation, sample));
        return new HarnessSampleResult(sample, explanation, validation, attemptCount, elapsedMilliseconds, readability);
    }

    /** 대표 화면: 첫 오답 보기를 고른 학습자 기준 마크다운 */
    static String toWrongPickMarkdown(ChoiceSetExplanation explanation, HarnessSample sample) {
        String wrongChoiceKey = sample.items().stream().filter(item -> !Boolean.TRUE.equals(item.getIsCorrect()))
                .map(QuestionChoiceSetItem::getChoiceKey).findFirst().orElse(explanation.correctChoiceKey());
        return ChoiceExplanationComposer.toMarkdown(ChoiceExplanationComposer.composeForSelectedChoice(explanation, wrongChoiceKey));
    }

    static ReadabilityMetrics measureReadability(String markdown) {
        String plainText = markdown.replace("**", "").replace("`", "").replaceAll("(?m)^- ", "");
        List<String> sentences = SENTENCE_SPLIT_PATTERN.splitAsStream(plainText).map(String::strip).filter(s -> !s.isEmpty()).toList();
        int totalSentenceCharacters = sentences.stream().mapToInt(String::length).sum();
        int longest = sentences.stream().mapToInt(String::length).max().orElse(0);
        return new ReadabilityMetrics(plainText.length(), sentences.size(),
                sentences.isEmpty() ? 0 : totalSentenceCharacters / sentences.size(), longest);
    }

    // ── 리포트 ───────────────────────────────────────────

    /** 리포트 마크다운: 요약 > 샘플별 표 > 위반·경고 > 대표 화면 해설 전문 */
    static String buildReport(List<HarnessSampleResult> results, String modeLabel) {
        long passedCount = results.stream().filter(HarnessSampleResult::isPassed).count();
        long retriedCount = results.stream().filter(result -> result.attemptCount() > 1).count();
        long warningCount = results.stream().mapToLong(result -> result.validation().warnings().size()).sum();
        double averageElapsedSeconds = results.stream().mapToLong(HarnessSampleResult::elapsedMilliseconds).average().orElse(0) / 1000.0;
        double averageCharacters = results.stream().filter(result -> result.readability() != null)
                .mapToInt(result -> result.readability().totalCharacters()).average().orElse(0);

        StringBuilder report = new StringBuilder();
        report.append("# AI 해설 하네스 리포트 (프롬프트 v").append(ChoiceSetExplanationPrompt.PROMPT_VERSION).append(")\n\n");
        report.append("- 모드: ").append(modeLabel).append("\n");
        report.append("- 통과(형식·사실 위반 0): ").append(passedCount).append(" / ").append(results.size()).append("\n");
        report.append("- 재시도 발생: ").append(retriedCount).append("건, 경고 합계: ").append(warningCount).append("건\n");
        report.append(String.format(Locale.ROOT, "- 평균 생성 시간: %.1f초, 평균 해설 길이: %.0f자%n%n", averageElapsedSeconds, averageCharacters));

        report.append("| 샘플 | 결과 | 시도 | 시간(초) | 글자 | 문장 | 문장 평균 | 최장 문장 | 위반 | 경고 |\n");
        report.append("|---|---|---|---|---|---|---|---|---|---|\n");
        for (HarnessSampleResult result : results) {
            ReadabilityMetrics readability = result.readability();
            report.append(String.format(Locale.ROOT, "| %s | %s | %d | %.1f | %s | %s | %s | %s | %d | %d |%n",
                    result.sample().sampleId(), result.isPassed() ? "PASS" : "FAIL", result.attemptCount(),
                    result.elapsedMilliseconds() / 1000.0,
                    readability == null ? "-" : readability.totalCharacters(),
                    readability == null ? "-" : readability.sentenceCount(),
                    readability == null ? "-" : readability.averageSentenceCharacters(),
                    readability == null ? "-" : readability.longestSentenceCharacters(),
                    result.validation().violations().size(), result.validation().warnings().size()));
        }
        report.append("\n## 위반·경고\n\n");
        for (HarnessSampleResult result : results) {
            if (result.validation().violations().isEmpty() && result.validation().warnings().isEmpty()) continue;
            report.append("- **").append(result.sample().sampleId()).append("**\n");
            result.validation().violations().forEach(violation -> report.append("  - 위반: ").append(violation).append("\n"));
            result.validation().warnings().forEach(warning -> report.append("  - 경고: ").append(warning).append("\n"));
        }
        report.append("\n## 해설 전문 (첫 오답 보기를 고른 학습자 화면, 출시 앱 text 와 같은 마크다운)\n");
        for (HarnessSampleResult result : results) {
            if (result.explanation() == null) continue;
            report.append("\n### ").append(result.sample().sampleId()).append("\n\n");
            report.append(toWrongPickMarkdown(result.explanation(), result.sample())).append("\n");
        }
        return report.toString();
    }

    // ── 실행 환경 ─────────────────────────────────────────

    /** 테스트 작업 디렉터리(모듈)에서 위로 올라가며 하네스 폴더 찾기 */
    static Path findHarnessDirectory() {
        Path current = Paths.get("").toAbsolutePath();
        while (current != null) {
            Path candidate = current.resolve(HARNESS_DIRECTORY);
            if (Files.isDirectory(candidate)) return candidate;
            current = current.getParent();
        }
        throw new IllegalStateException("harness directory not found: " + HARNESS_DIRECTORY);
    }

    /** 실호출용 생성기: 운영 GeminiClient(키는 환경변수) + 모델 설정만 담은 프롬프트 */
    static ChoiceSetExplanationGenerator createLiveGenerator(String geminiApiKey, String model) {
        AppSettingService appSettingService = mock(AppSettingService.class);
        when(appSettingService.getSecret(AppSettingKeys.AI_GEMINI_API_KEY)).thenReturn(geminiApiKey);
        PromptService promptService = mock(PromptService.class);
        when(promptService.getActivePrompt(anyString())).thenReturn(PromptTemplate.builder()
                .keyName("diff_explain").version(0).model(model == null || model.isBlank() ? DEFAULT_LIVE_MODEL : model)
                .systemPrompt("").temperature(LIVE_TEMPERATURE).maxTokens(LIVE_MAX_TOKENS).build());
        return new ChoiceSetExplanationGenerator(new GeminiClient(appSettingService, mock(AiCallLogService.class), DEFAULT_LIVE_MODEL), promptService);
    }

    static Path recordedDirectoryForCurrentVersion(Path harnessDirectory) {
        return harnessDirectory.resolve(RECORDED_DIRECTORY).resolve("v" + ChoiceSetExplanationPrompt.PROMPT_VERSION);
    }

    static void writeReport(Path reportFile, String report) throws IOException {
        Files.createDirectories(reportFile.getParent());
        Files.writeString(reportFile, report, StandardCharsets.UTF_8);
    }

    private static String textOrNull(JsonNode node, String fieldName) {
        JsonNode value = node.get(fieldName);
        return value == null || value.isNull() ? null : value.asText();
    }
}
