package com.passql.common.util;

import java.util.regex.Pattern;

/**
 * 마크다운 > 평문 (목록 카드 미리보기용): 코드 울타리·인라인 기호·제목·인용·목록 기호·링크·이미지 제거, 공백 정리
 */
public final class MarkdownTextStripper {

    private static final Pattern CODE_FENCE = Pattern.compile("```[a-zA-Z0-9_-]*");
    private static final Pattern IMAGE = Pattern.compile("!\\[([^\\]]*)]\\([^)]*\\)");
    private static final Pattern LINK = Pattern.compile("\\[([^\\]]*)]\\([^)]*\\)");
    private static final Pattern LINE_PREFIX = Pattern.compile("(?m)^\\s*(#{1,6}\\s+|>\\s?|[-*+]\\s+|\\d+\\.\\s+)");
    private static final Pattern INLINE_MARKS = Pattern.compile("[`*_~]");
    private static final Pattern WHITESPACE = Pattern.compile("\\s+");

    private MarkdownTextStripper() {
    }

    /** 마크다운 > 한 줄 평문 (null > 빈 문자열) */
    public static String toPlainText(String markdown) {
        if (markdown == null) {
            return "";
        }
        String text = CODE_FENCE.matcher(markdown).replaceAll("");
        text = IMAGE.matcher(text).replaceAll("$1");
        text = LINK.matcher(text).replaceAll("$1");
        text = LINE_PREFIX.matcher(text).replaceAll("");
        text = INLINE_MARKS.matcher(text).replaceAll("");
        return WHITESPACE.matcher(text).replaceAll(" ").trim();
    }
}
