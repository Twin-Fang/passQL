package com.passql.question.service;

import com.passql.question.constant.QuestionInternalTagNamespace;
import com.passql.question.dto.QuestionInternalTagFilter;
import com.passql.question.dto.QuestionInternalTagNormalizeResult;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * 내부 태그 규칙 단일 지점: 정규화(앞뒤 공백 제거, 영문만 소문자), 검증(길이·공백·금지 문자·개수), 필터 해석
 * 가져오기·관리자 편집·일괄 API·목록 필터가 모두 이 규칙을 거침 (하네스 internal_tags.py 와 같은 규칙)
 */
public final class QuestionInternalTagRule {

    // 태그 1개 최대 길이 (글자 수, 한글 1자 = 1) > question_internal_tag.tag VARCHAR(64)
    public static final int MAXIMUM_TAG_LENGTH = 64;
    // 문제 1개당 최대 태그 수
    public static final int MAXIMUM_TAG_COUNT_PER_QUESTION = 20;
    // 필터 앞부분 일치 표시 (source:63-* )
    public static final String FILTER_PREFIX_WILDCARD = "*";
    // 태그에 쓸 수 없는 문자 (* 필터 기호, 쉼표 목록 구분자)
    private static final String FORBIDDEN_CHARACTERS = "*,";

    private QuestionInternalTagRule() {
    }

    /** 태그 1개 정규화: 앞뒤 공백 제거 > 영문 A-Z 만 소문자 (한글·숫자·기호 그대로, null > 빈 문자열) */
    public static String normalizeTag(String rawTag) {
        if (rawTag == null) {
            return "";
        }
        String trimmedTag = rawTag.strip();
        StringBuilder normalizedTag = new StringBuilder(trimmedTag.length());
        for (char character : trimmedTag.toCharArray()) {
            normalizedTag.append(character >= 'A' && character <= 'Z' ? (char) (character + ('a' - 'A')) : character);
        }
        return normalizedTag.toString();
    }

    /** 정규화된 태그 1개 거부 사유 (통과면 null): 빈 값 > 길이 > 공백·제어 문자 > 금지 문자 > 네임스페이스·값 빈칸 */
    public static String findRejectReason(String normalizedTag) {
        if (normalizedTag.isEmpty()) {
            return "빈 태그";
        }
        if (normalizedTag.codePointCount(0, normalizedTag.length()) > MAXIMUM_TAG_LENGTH) {
            return "태그 " + MAXIMUM_TAG_LENGTH + "자 초과: " + normalizedTag;
        }
        String characterRejectReason = findCharacterRejectReason(normalizedTag);
        if (characterRejectReason != null) {
            return characterRejectReason;
        }
        String namespacePrefix = QuestionInternalTagNamespace.extractPrefixOrNull(normalizedTag);
        if (namespacePrefix != null
                && (namespacePrefix.isEmpty() || QuestionInternalTagNamespace.extractValue(normalizedTag).isEmpty())) {
            return "네임스페이스 또는 값이 비어 있음: " + normalizedTag;
        }
        return null;
    }

    /** 태그 목록 정규화: 건별 정규화·검증 > 중복 제거 (입력 순서) > 개수 확인 (null > 빈 목록) */
    public static QuestionInternalTagNormalizeResult normalizeTags(List<String> rawTags) {
        if (rawTags == null) {
            return QuestionInternalTagNormalizeResult.passed(List.of());
        }
        Set<String> normalizedTags = new LinkedHashSet<>();
        for (String rawTag : rawTags) {
            String normalizedTag = normalizeTag(rawTag);
            String rejectReason = findRejectReason(normalizedTag);
            if (rejectReason != null) {
                return QuestionInternalTagNormalizeResult.rejected(rejectReason);
            }
            normalizedTags.add(normalizedTag);
        }
        if (normalizedTags.size() > MAXIMUM_TAG_COUNT_PER_QUESTION) {
            return QuestionInternalTagNormalizeResult.rejected(
                    "태그 " + normalizedTags.size() + "개 (문제당 최대 " + MAXIMUM_TAG_COUNT_PER_QUESTION + "개)");
        }
        return QuestionInternalTagNormalizeResult.passed(List.copyOf(normalizedTags));
    }

    /**
     * 필터 문자열 1개 > 필터 (빈 값 > null): 끝 * 1개면 앞부분 일치 (source:63-*, source:*), 아니면 정확 일치
     * 잘못된 필터 > IllegalArgumentException (거부 사유 메시지)
     */
    public static QuestionInternalTagFilter toFilterOrNull(String rawFilter) {
        String normalizedFilter = normalizeTag(rawFilter);
        if (normalizedFilter.isEmpty()) {
            return null;
        }
        boolean isPrefixMatch = normalizedFilter.endsWith(FILTER_PREFIX_WILDCARD);
        String matchValue = isPrefixMatch
                ? normalizedFilter.substring(0, normalizedFilter.length() - FILTER_PREFIX_WILDCARD.length())
                : normalizedFilter;
        // 앞부분 일치는 "source:" 처럼 값이 빈 것까지 허용 > 금지 문자·공백만 확인
        String rejectReason = isPrefixMatch ? findPrefixRejectReason(matchValue) : findRejectReason(matchValue);
        if (rejectReason != null) {
            throw new IllegalArgumentException("태그 필터 " + rawFilter.strip() + " : " + rejectReason);
        }
        return new QuestionInternalTagFilter(matchValue, isPrefixMatch);
    }

    /** 앞부분 일치 필터 거부 사유: 비었거나 공백·금지 문자 포함 */
    private static String findPrefixRejectReason(String matchValue) {
        return matchValue.isEmpty() ? "앞부분이 비어 있음" : findCharacterRejectReason(matchValue);
    }

    /** 문자 단위 거부 사유: 공백·제어 문자 > 금지 문자 (통과면 null) */
    private static String findCharacterRejectReason(String tag) {
        if (tag.codePoints().anyMatch(codePoint -> Character.isWhitespace(codePoint)
                || Character.isSpaceChar(codePoint) || Character.isISOControl(codePoint))) {
            return "태그에 공백 포함: " + tag;
        }
        if (tag.chars().anyMatch(character -> FORBIDDEN_CHARACTERS.indexOf(character) >= 0)) {
            return "태그에 쓸 수 없는 문자(*, 쉼표): " + tag;
        }
        return null;
    }
}
