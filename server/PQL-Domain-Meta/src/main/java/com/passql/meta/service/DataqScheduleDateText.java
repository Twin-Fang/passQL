package com.passql.meta.service;

import java.time.DateTimeException;
import java.time.MonthDay;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 공식 일정 표 날짜 칸 1개 > 월·일 (연도 없음, 연도는 DataqScheduleHtmlParser 가 정함)
 * 허용 형식 5종: "2.20", "3.7(토)", "2.2~6"(끝은 같은 달 일), "2.3~2.7", "-"(빈 칸)
 *
 * @param startMonthDay 시작 (단일 날짜면 끝과 같음, 빈 칸이면 null)
 * @param endMonthDay   끝
 */
public record DataqScheduleDateText(MonthDay startMonthDay, MonthDay endMonthDay) {

    // 빈 칸 ("-" 또는 공백)
    public static final DataqScheduleDateText BLANK = new DataqScheduleDateText(null, null);

    // 요일 괄호 "(토)", 공백
    private static final Pattern WEEKDAY_OR_SPACE = Pattern.compile("\\([^)]*\\)|\\s+");
    // 물결표 변형 (전각 ～, 파형 〜)
    private static final Pattern TILDE_VARIANT = Pattern.compile("[～〜]");
    // 월.일 (끝 점 허용)
    private static final Pattern SINGLE_DATE = Pattern.compile("^(\\d{1,2})\\.(\\d{1,2})\\.?$");
    // 월.일~[월.]일
    private static final Pattern DATE_RANGE = Pattern.compile("^(\\d{1,2})\\.(\\d{1,2})~(?:(\\d{1,2})\\.)?(\\d{1,2})\\.?$");
    private static final String BLANK_MARK = "-";

    public boolean isBlank() {
        return startMonthDay == null;
    }

    /** 칸 글자 > 월·일 (해석 불가 > empty, "-"·공백 > BLANK) */
    public static Optional<DataqScheduleDateText> parse(String cellText) {
        String normalizedText = TILDE_VARIANT.matcher(WEEKDAY_OR_SPACE.matcher(cellText == null ? "" : cellText).replaceAll(""))
                .replaceAll("~");
        if (normalizedText.isEmpty() || BLANK_MARK.equals(normalizedText)) {
            return Optional.of(BLANK);
        }
        try {
            Matcher singleMatcher = SINGLE_DATE.matcher(normalizedText);
            if (singleMatcher.matches()) {
                MonthDay date = toMonthDay(singleMatcher.group(1), singleMatcher.group(2));
                return Optional.of(new DataqScheduleDateText(date, date));
            }
            Matcher rangeMatcher = DATE_RANGE.matcher(normalizedText);
            if (rangeMatcher.matches()) {
                MonthDay start = toMonthDay(rangeMatcher.group(1), rangeMatcher.group(2));
                // 끝 월 생략("2.2~6") > 시작 월
                String endMonth = rangeMatcher.group(3) == null ? rangeMatcher.group(1) : rangeMatcher.group(3);
                MonthDay end = toMonthDay(endMonth, rangeMatcher.group(4));
                return Optional.of(new DataqScheduleDateText(start, end));
            }
        } catch (DateTimeException e) {
            // 13월·32일 같은 없는 날짜
            return Optional.empty();
        }
        return Optional.empty();
    }

    private static MonthDay toMonthDay(String month, String day) {
        return MonthDay.of(Integer.parseInt(month), Integer.parseInt(day));
    }
}
