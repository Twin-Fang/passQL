package com.passql.question.service;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;

/**
 * 문제 그림 SVG 검사 (순수, #1132): 모양 > 크기 > 금지 요소 (스크립트, 외부 참조, HTML 끼워 넣기)
 * 통과면 null, 아니면 거부 사유. 앱은 flutter_svg 로 그대로 그림
 */
public final class QuestionFigureSvgRule {

    // 그림 1개 최대 크기 (40KB, ERD 1장은 보통 5~15KB)
    public static final int MAX_FIGURE_SVG_BYTES = 40 * 1024;

    // 금지 요소 6개: 스크립트, HTML 끼워 넣기, 외부 이미지, 이벤트 속성, 외부·스크립트 링크, CSS 외부 불러오기
    private static final List<Pattern> FORBIDDEN_PATTERNS = List.of(
        Pattern.compile("<\\s*script"),
        Pattern.compile("<\\s*foreignobject"),
        Pattern.compile("<\\s*image"),
        Pattern.compile("\\son[a-z]+\\s*="),
        Pattern.compile("href\\s*=\\s*[\"']\\s*(?!#)"),
        Pattern.compile("@import|url\\s*\\(\\s*[\"']?\\s*(?!#)"));

    private QuestionFigureSvgRule() {
    }

    /** 거부 사유 (통과면 null, 빈 값은 그림 없음으로 통과) */
    public static String findRejectReason(String figureSvg) {
        if (figureSvg == null || figureSvg.isBlank()) {
            return null;
        }
        String trimmed = figureSvg.trim();
        if (!trimmed.startsWith("<svg") || !trimmed.endsWith("</svg>")) {
            return "SVG 문서가 아님 (<svg ...>...</svg> 하나여야 함)";
        }
        if (trimmed.getBytes(StandardCharsets.UTF_8).length > MAX_FIGURE_SVG_BYTES) {
            return "그림이 " + (MAX_FIGURE_SVG_BYTES / 1024) + "KB 를 넘음";
        }
        String lowered = trimmed.toLowerCase(Locale.ROOT);
        for (Pattern forbiddenPattern : FORBIDDEN_PATTERNS) {
            if (forbiddenPattern.matcher(lowered).find()) {
                return "허용하지 않는 요소 포함 (" + forbiddenPattern.pattern() + ")";
            }
        }
        return null;
    }
}
