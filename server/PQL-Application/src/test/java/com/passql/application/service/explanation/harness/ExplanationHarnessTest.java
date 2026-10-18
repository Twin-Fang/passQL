package com.passql.application.service.explanation.harness;

import com.passql.application.service.explanation.ChoiceSetExplanationGenerator;
import com.passql.application.service.explanation.ChoiceSetExplanationPrompt;
import com.passql.application.service.explanation.harness.ExplanationHarness.HarnessSample;
import com.passql.application.service.explanation.harness.ExplanationHarness.HarnessSampleResult;
import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * AI 해설 하네스 (#521)
 * - 오프라인(기본, CI): 현재 프롬프트 버전 기록본이 형식·사실 검증 통과 + 일부러 망가뜨린 응답을 검증이 잡는지
 * - 실호출: EXPLANATION_HARNESS_LIVE=true + GEMINI_API_KEY 일 때만 Gemini 호출 > 기록본·리포트 갱신
 */
class ExplanationHarnessTest {

    // 실호출 스위치·키·모델 (환경변수, CI 에서는 꺼짐)
    private static final String LIVE_SWITCH_ENV = "EXPLANATION_HARNESS_LIVE";
    private static final String GEMINI_API_KEY_ENV = "GEMINI_API_KEY";
    private static final String MODEL_ENV = "EXPLANATION_HARNESS_MODEL";
    // true 면 보기 생성 근거(rationale)도 프롬프트에 넣음 (기본: 빼고 AI 자체 추론 평가)
    private static final String WITH_RATIONALE_ENV = "EXPLANATION_HARNESS_WITH_RATIONALE";
    // 오프라인 리포트 위치 (커밋 대상 아님)
    private static final Path OFFLINE_REPORT_FILE = Paths.get("build", "explanation-harness", "report.md");

    @Test
    void 오프라인_기록본은_형식과_사실_검증을_통과한다() throws Exception {
        Path harnessDirectory = ExplanationHarness.findHarnessDirectory();
        Path recordedDirectory = ExplanationHarness.recordedDirectoryForCurrentVersion(harnessDirectory);
        Assumptions.assumeTrue(Files.isDirectory(recordedDirectory),
                "현재 프롬프트 버전 기록본 없음 > 실호출로 먼저 기록: " + recordedDirectory);

        List<HarnessSampleResult> results = new ArrayList<>();
        for (HarnessSample sample : ExplanationHarness.loadSamples(harnessDirectory, isEnabled(WITH_RATIONALE_ENV))) {
            results.add(ExplanationHarness.evaluateRecorded(sample, recordedDirectory));
        }
        ExplanationHarness.writeReport(OFFLINE_REPORT_FILE, ExplanationHarness.buildReport(results, "오프라인(기록본)"));

        assertThat(results).isNotEmpty();
        assertThat(results).allSatisfy(result -> assertThat(result.validation().violations())
                .as(result.sample().sampleId()).isEmpty());
    }

    @Test
    void 일부러_망가뜨린_응답은_검증이_잡는다() throws Exception {
        Path harnessDirectory = ExplanationHarness.findHarnessDirectory();
        HarnessSample sample = ExplanationHarness.loadSamples(harnessDirectory, false).get(0);
        String correctChoiceKey = sample.items().stream().filter(item -> Boolean.TRUE.equals(item.getIsCorrect()))
                .findFirst().orElseThrow().getChoiceKey();
        String wrongChoiceKey = sample.items().stream().filter(item -> !Boolean.TRUE.equals(item.getIsCorrect()))
                .findFirst().orElseThrow().getChoiceKey();

        // 깨진 JSON / 정답 키 바꿔치기 / 보기 누락
        String validJson = """
                {"correctChoiceKey":"%s","correctReason":"근거","keyConcepts":[{"name":"개념","description":"설명"}],
                 "confusingPoints":["지점"],"choiceAnalyses":%s,"examTip":"팁"}
                """;
        String allAnalyses = analysesJson(sample, correctChoiceKey);
        String swappedAnalyses = analysesJson(sample, wrongChoiceKey);

        assertThat(ExplanationHarness.evaluateRawResponse(sample, "{oops", 1, 0).validation().violations())
                .containsExactly("응답 JSON 파싱 실패");
        assertThat(ExplanationHarness.evaluateRawResponse(sample, validJson.formatted(correctChoiceKey, allAnalyses), 1, 0).isPassed())
                .isTrue();
        assertThat(ExplanationHarness.evaluateRawResponse(sample, validJson.formatted(wrongChoiceKey, swappedAnalyses), 1, 0)
                .validation().violations())
                .anyMatch(violation -> violation.startsWith("correctChoiceKey 불일치"))
                .anyMatch(violation -> violation.contains("정답 여부 모순"));
        assertThat(ExplanationHarness.evaluateRawResponse(sample, validJson.formatted(correctChoiceKey, "[]"), 1, 0)
                .validation().violations())
                .anyMatch(violation -> violation.startsWith("choiceAnalyses 보기 키 불일치"));
    }

    @Test
    void 실호출로_해설을_생성해_기록본과_리포트를_갱신한다() throws Exception {
        String geminiApiKey = System.getenv(GEMINI_API_KEY_ENV);
        Assumptions.assumeTrue(isEnabled(LIVE_SWITCH_ENV) && geminiApiKey != null && !geminiApiKey.isBlank(),
                "실호출 꺼짐 (EXPLANATION_HARNESS_LIVE=true, GEMINI_API_KEY 필요)");

        Path harnessDirectory = ExplanationHarness.findHarnessDirectory();
        Path recordedDirectory = ExplanationHarness.recordedDirectoryForCurrentVersion(harnessDirectory);
        ChoiceSetExplanationGenerator generator = ExplanationHarness.createLiveGenerator(geminiApiKey, System.getenv(MODEL_ENV));
        List<HarnessSampleResult> results = new ArrayList<>();
        for (HarnessSample sample : ExplanationHarness.loadSamples(harnessDirectory, isEnabled(WITH_RATIONALE_ENV))) {
            results.add(ExplanationHarness.evaluateLive(generator, sample, recordedDirectory));
        }
        Path reportFile = harnessDirectory.resolve(ExplanationHarness.REPORT_DIRECTORY)
                .resolve("prompt-v" + ChoiceSetExplanationPrompt.PROMPT_VERSION + ".md");
        ExplanationHarness.writeReport(reportFile, ExplanationHarness.buildReport(results, "실호출"));
        System.out.println("[explanation harness] report : " + reportFile);
    }

    private static String analysesJson(HarnessSample sample, String correctChoiceKey) {
        return sample.items().stream()
                .map(item -> "{\"choiceKey\":\"%s\",\"isCorrect\":%s,\"reason\":\"이유\"}"
                        .formatted(item.getChoiceKey(), item.getChoiceKey().equals(correctChoiceKey)))
                .reduce((left, right) -> left + "," + right)
                .map(joined -> "[" + joined + "]")
                .orElse("[]");
    }

    private static boolean isEnabled(String environmentName) {
        return "true".equalsIgnoreCase(System.getenv(environmentName));
    }
}
