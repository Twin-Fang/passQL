package com.passql.question.service;

import com.passql.question.dto.explanation.ChoiceAnalysis;
import com.passql.question.dto.explanation.ChoiceSetExplanation;
import com.passql.question.dto.explanation.KeyConcept;

import java.util.List;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 줄표·가운뎃점 정리 단일 원본 (#905 규칙 1): AI 보기·근거·해설·코멘트 저장·응답 전, 관리자 일괄 정리가 모두 이 함수만 씀
 * 순서: "→ A·B" > "→ (A, B)", 가운뎃점 > ", ", 줄표 > ": " (코드 울타리·인라인 코드 안은 그대로, → 든 인라인 코드는 정리)
 */
public final class ForbiddenPunctuationCleaner {

    // 금지 줄표 3종: — (U+2014 em), – (U+2013 en), ― (U+2015 가로 막대)
    public static final String DASH_CHARACTERS = "—–―";
    // 금지 가운뎃점 2종: · (U+00B7), ・ (U+30FB), 목록 글머리 • 는 제외 (규칙 7 목록 기호)
    public static final String MIDDLE_DOT_CHARACTERS = "·・";
    // 줄표 자리 (#903 지문 블록 분해와 같은 기준: "용어: 설명")
    public static final String TERM_DESCRIPTION_SEPARATOR = ": ";
    private static final String LIST_SEPARATOR = ", ";
    private static final String LIST_ITEM_PREFIX = "- ";
    // 함수 종속 화살표 (인라인 코드 안이어도 정리)
    private static final String DEPENDENCY_ARROW = "→";
    // 긴 낱말 줄바꿈용 폭 0 공백 (가운뎃점 바로 뒤에 붙어 있으면 함께 지움)
    private static final String ZERO_WIDTH_SPACE = "​";

    private static final String FORBIDDEN_CLASS = "[" + DASH_CHARACTERS + MIDDLE_DOT_CHARACTERS + "]";
    private static final String DASH_CLASS = "[" + DASH_CHARACTERS + "]";
    private static final String MIDDLE_DOT_TOKEN = "[" + MIDDLE_DOT_CHARACTERS + "]" + ZERO_WIDTH_SPACE + "?";
    private static final Pattern ANY_FORBIDDEN_PUNCTUATION = Pattern.compile(FORBIDDEN_CLASS);
    // 코드 울타리 블록 (```...```, 닫히지 않으면 끝까지)
    private static final Pattern CODE_FENCE_BLOCK = Pattern.compile("```[\\s\\S]*?(?:```|$)");
    private static final Pattern INLINE_CODE = Pattern.compile("`[^`\\n]*`");
    // "→ A·B·C" 묶음: 화살표 뒤 가운뎃점으로 이은 낱말 2개 이상
    private static final String GROUP_WORD = "[^\\s" + MIDDLE_DOT_CHARACTERS + ",()`]+";
    private static final Pattern ARROW_MIDDLE_DOT_GROUP = Pattern.compile(
            DEPENDENCY_ARROW + "\\s*(" + GROUP_WORD + "(?:" + MIDDLE_DOT_TOKEN + GROUP_WORD + ")+)");
    private static final Pattern MIDDLE_DOT_SEPARATOR = Pattern.compile(MIDDLE_DOT_TOKEN);
    // 줄 맨 앞 기호 + 공백 > 목록 글머리
    private static final Pattern LINE_LEADING_PUNCTUATION = Pattern.compile(
            "(?m)^([ \\t]*)(?:" + DASH_CLASS + "|" + MIDDLE_DOT_TOKEN + ")[ \\t]+");
    private static final Pattern SPACED_MIDDLE_DOT = Pattern.compile("[ \\t]*" + MIDDLE_DOT_TOKEN + "[ \\t]*");
    private static final Pattern SPACED_DASH = Pattern.compile("[ \\t]*" + DASH_CLASS + "[ \\t]*");
    // 줄 끝 기호 (정리 뒤 ": "·", " 가 줄 끝에 남지 않게 먼저 지움)
    private static final Pattern LINE_TRAILING_PUNCTUATION = Pattern.compile("(?m)[ \\t]*" + FORBIDDEN_CLASS + ZERO_WIDTH_SPACE + "?[ \\t]*$");

    private ForbiddenPunctuationCleaner() {
    }

    /** 정리하면 바뀌는 글인지 (코드 안 기호는 세지 않음) */
    public static boolean hasForbiddenPunctuation(String text) {
        return text != null && ANY_FORBIDDEN_PUNCTUATION.matcher(text).find() && !Objects.equals(clean(text), text);
    }

    /** 글 1개 정리 (금지 기호 없으면 원문 그대로, null > null) */
    public static String clean(String text) {
        if (text == null || !ANY_FORBIDDEN_PUNCTUATION.matcher(text).find()) return text;
        StringBuilder cleaned = new StringBuilder(text.length());
        Matcher fenceMatcher = CODE_FENCE_BLOCK.matcher(text);
        int position = 0;
        while (fenceMatcher.find()) {
            cleaned.append(cleanOutsideFence(text.substring(position, fenceMatcher.start())));
            cleaned.append(fenceMatcher.group());
            position = fenceMatcher.end();
        }
        cleaned.append(cleanOutsideFence(text.substring(position)));
        return cleaned.toString();
    }

    /** 구조화 해설 전체 글 정리 (null > null) */
    public static ChoiceSetExplanation clean(ChoiceSetExplanation explanation) {
        if (explanation == null) return null;
        List<KeyConcept> keyConcepts = explanation.keyConcepts() == null ? null : explanation.keyConcepts().stream()
                .map(concept -> new KeyConcept(clean(concept.name()), clean(concept.description()))).toList();
        List<String> confusingPoints = explanation.confusingPoints() == null ? null
                : explanation.confusingPoints().stream().map(ForbiddenPunctuationCleaner::clean).toList();
        List<ChoiceAnalysis> choiceAnalyses = explanation.choiceAnalyses() == null ? null
                : explanation.choiceAnalyses().stream()
                .map(analysis -> new ChoiceAnalysis(analysis.choiceKey(), analysis.isCorrect(), clean(analysis.reason())))
                .toList();
        return new ChoiceSetExplanation(explanation.correctChoiceKey(), clean(explanation.correctReason()),
                keyConcepts, confusingPoints, choiceAnalyses, clean(explanation.examTip()));
    }

    // 울타리 밖: 인라인 코드는 → 가 있을 때만 정리, 나머지 글은 정리
    private static String cleanOutsideFence(String text) {
        StringBuilder cleaned = new StringBuilder(text.length());
        Matcher inlineCodeMatcher = INLINE_CODE.matcher(text);
        int position = 0;
        while (inlineCodeMatcher.find()) {
            cleaned.append(cleanPlainText(text.substring(position, inlineCodeMatcher.start())));
            String inlineCode = inlineCodeMatcher.group();
            cleaned.append(inlineCode.contains(DEPENDENCY_ARROW) ? cleanPlainText(inlineCode) : inlineCode);
            position = inlineCodeMatcher.end();
        }
        cleaned.append(cleanPlainText(text.substring(position)));
        return cleaned.toString();
    }

    // 글: 화살표 묶음 > 줄 끝 기호 삭제 > 줄 맨 앞 기호 "- " > 가운뎃점 ", " > 줄표 ": "
    private static String cleanPlainText(String text) {
        if (!ANY_FORBIDDEN_PUNCTUATION.matcher(text).find()) return text;
        String cleaned = ARROW_MIDDLE_DOT_GROUP.matcher(text).replaceAll(match -> Matcher.quoteReplacement(
                DEPENDENCY_ARROW + " (" + String.join(LIST_SEPARATOR, MIDDLE_DOT_SEPARATOR.split(match.group(1))) + ")"));
        cleaned = LINE_TRAILING_PUNCTUATION.matcher(cleaned).replaceAll("");
        cleaned = LINE_LEADING_PUNCTUATION.matcher(cleaned).replaceAll("$1" + LIST_ITEM_PREFIX);
        cleaned = SPACED_MIDDLE_DOT.matcher(cleaned).replaceAll(LIST_SEPARATOR);
        return SPACED_DASH.matcher(cleaned).replaceAll(TERM_DESCRIPTION_SEPARATOR);
    }
}
