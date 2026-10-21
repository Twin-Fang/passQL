package com.passql.common.util;

import java.util.regex.Pattern;

/**
 * 마크다운 > 평문 (목록 카드 미리보기용): 표·코드 울타리·인라인 기호·제목·인용·목록 기호·링크·이미지 제거, 공백 정리
 */
public final class MarkdownTextStripper {

    // 마크다운 표 블록: | 로 시작하는 줄이 2줄 이상 이어짐 (머리 줄 + 구분 줄 이상)
    private static final Pattern TABLE_BLOCK = Pattern.compile("(?m)(^[ \\t]*\\|.*(?:\\r?\\n|$)){2,}");
    // 미리보기에서 표 자리 표시 (오답 노트 코드 블록 [SQL] 과 같은 형식)
    public static final String TABLE_PLACEHOLDER = "[표]";
    private static final Pattern CODE_FENCE = Pattern.compile("```[a-zA-Z0-9_-]*");
    private static final Pattern IMAGE = Pattern.compile("!\\[([^\\]]*)]\\([^)]*\\)");
    private static final Pattern LINK = Pattern.compile("\\[([^\\]]*)]\\([^)]*\\)");
    private static final Pattern LINE_PREFIX = Pattern.compile("(?m)^\\s*(#{1,6}\\s+|>\\s?|[-*+]\\s+|\\d+\\.\\s+)");
    // 밑줄은 SQL 이름(EMP_ID)에 흔해 강조 표시(_글자_, __글자__)일 때만 걷어 낸다
    private static final Pattern UNDERSCORE_EMPHASIS = Pattern.compile("(?<![\\w])_{1,2}([^_\\s][^_]*?)_{1,2}(?![\\w])");
    private static final Pattern INLINE_MARKS = Pattern.compile("[`*~]");
    private static final Pattern WHITESPACE = Pattern.compile("\\s+");

    private MarkdownTextStripper() {
    }

    /** 표 블록 > [표] (미리보기에 | ID | NAME | 원문이 보이지 않게, #566) */
    public static String replaceTables(String markdown) {
        if (markdown == null) {
            return "";
        }
        return TABLE_BLOCK.matcher(markdown).replaceAll(TABLE_PLACEHOLDER + "\n");
    }

    /** 마크다운 > 한 줄 평문 (null > 빈 문자열) */
    public static String toPlainText(String markdown) {
        if (markdown == null) {
            return "";
        }
        String text = replaceTables(markdown);
        text = CODE_FENCE.matcher(text).replaceAll("");
        text = IMAGE.matcher(text).replaceAll("$1");
        text = LINK.matcher(text).replaceAll("$1");
        text = LINE_PREFIX.matcher(text).replaceAll("");
        text = UNDERSCORE_EMPHASIS.matcher(text).replaceAll("$1");
        text = INLINE_MARKS.matcher(text).replaceAll("");
        return WHITESPACE.matcher(text).replaceAll(" ").trim();
    }
}
