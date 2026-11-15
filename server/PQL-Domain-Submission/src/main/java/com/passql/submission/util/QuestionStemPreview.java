package com.passql.submission.util;

import com.passql.common.util.MarkdownTextStripper;
import com.passql.common.util.TextPreview;

/**
 * 문제 지문 > 목록 미리보기 (마크다운 표 > [표], 코드 블록 > [SQL], 줄바꿈 제거, 50자)
 * 쓰는 곳 3개: 오답 노트, 즐겨찾기, 오답률 TOP
 */
public final class QuestionStemPreview {

    private QuestionStemPreview() {
    }

    /** 지문 원문 > 50자 미리보기 (null > 빈 문자열) */
    public static String toListPreview(String stem) {
        if (stem == null) return "";
        String cleaned = MarkdownTextStripper.replaceTables(stem)
            .replaceAll("```[\\s\\S]*?```", "[SQL]")
            .replaceAll("\n", " ")
            .trim();
        return TextPreview.truncateWithEllipsis(cleaned, TextPreview.SHORT_STEM_LENGTH);
    }
}
