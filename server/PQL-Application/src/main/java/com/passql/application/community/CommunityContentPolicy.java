package com.passql.application.community;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.entity.CommunityPost;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Locale;

/**
 * 커뮤니티 글 내용 검증: 공백 정리, 길이 1~500자, 금칙어 (resources/community/banned-words.txt)
 */
@Slf4j
@Component
public class CommunityContentPolicy {

    // 금칙어 목록 리소스 (한 줄 하나, # 주석)
    private static final String BANNED_WORDS_RESOURCE = "community/banned-words.txt";

    private final List<String> bannedWords;

    @Autowired
    public CommunityContentPolicy() {
        this(loadBannedWordsFromResource());
    }

    CommunityContentPolicy(List<String> bannedWords) {
        this.bannedWords = bannedWords.stream().map(CommunityContentPolicy::toComparable).toList();
    }

    /** 본문 > 앞뒤 공백 제거한 본문 (비었거나 500자 초과 > COMMUNITY_CONTENT_INVALID, 금칙어 > COMMUNITY_CONTENT_FORBIDDEN_WORD) */
    public String validateAndNormalize(String content) {
        String normalized = content == null ? "" : content.strip();
        if (normalized.isEmpty() || normalized.length() > CommunityPost.MAX_CONTENT_LENGTH) {
            throw new CustomException(ErrorCode.COMMUNITY_CONTENT_INVALID);
        }
        String comparable = toComparable(normalized);
        if (bannedWords.stream().anyMatch(comparable::contains)) {
            log.warn("[community] rejected 400 : forbidden word detected");
            throw new CustomException(ErrorCode.COMMUNITY_CONTENT_FORBIDDEN_WORD);
        }
        return normalized;
    }

    /** 비교용 변환: 소문자, 공백 제거 (띄어쓰기로 금칙어를 피하는 경우 방지) */
    private static String toComparable(String text) {
        return text.toLowerCase(Locale.ROOT).replaceAll("\\s+", "");
    }

    private static List<String> loadBannedWordsFromResource() {
        try (var inputStream = new ClassPathResource(BANNED_WORDS_RESOURCE).getInputStream()) {
            String text = new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
            return text.lines().map(String::strip).filter(line -> !line.isEmpty() && !line.startsWith("#")).toList();
        } catch (IOException e) {
            throw new UncheckedIOException("failed to load community banned words", e);
        }
    }
}
