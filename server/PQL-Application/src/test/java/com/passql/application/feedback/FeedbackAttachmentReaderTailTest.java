package com.passql.application.feedback;

import org.junit.jupiter.api.Test;

import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;

import static org.assertj.core.api.Assertions.assertThat;

class FeedbackAttachmentReaderTailTest {

    private static final int TAIL_BYTES = 1000;
    private static final long NO_LIMIT = Long.MAX_VALUE;

    @Test
    void returnsWholeTextWhenInputIsSmall() throws Exception {
        byte[] input = "작은 로그\nline2".getBytes(StandardCharsets.UTF_8);
        assertThat(FeedbackAttachmentReader.readTailText(new ByteArrayInputStream(input), TAIL_BYTES, NO_LIMIT))
            .isEqualTo("작은 로그\nline2");
    }

    @Test
    void keepsOnlyLastBytesOnValidUtf8Boundary() throws Exception {
        // 5 x 한글 3바이트 반복: 꼬리 시작이 글자 중간에 걸리도록 크기 조정
        byte[] input = "가".repeat(5000).getBytes(StandardCharsets.UTF_8);
        byte[] withPrefix = new byte[input.length + 1];
        System.arraycopy("x".getBytes(StandardCharsets.UTF_8), 0, withPrefix, 0, 1);
        System.arraycopy(input, 0, withPrefix, 1, input.length);

        String tail = FeedbackAttachmentReader.readTailText(new ByteArrayInputStream(withPrefix), TAIL_BYTES, NO_LIMIT);

        assertThat(tail).doesNotContain("�").doesNotContain("x");
        assertThat(tail).matches("가+");
        byte[] expectedTail = Arrays.copyOfRange(withPrefix, withPrefix.length - TAIL_BYTES, withPrefix.length);
        assertThat(expectedTail.length).isEqualTo(TAIL_BYTES);
        assertThat(tail.getBytes(StandardCharsets.UTF_8).length).isBetween(TAIL_BYTES - 2, TAIL_BYTES);
    }

    @Test
    void stopsReadingAtLimit() throws Exception {
        byte[] input = "a".repeat(5000).getBytes(StandardCharsets.UTF_8);
        String tail = FeedbackAttachmentReader.readTailText(new ByteArrayInputStream(input), TAIL_BYTES, 2000);
        assertThat(tail.length()).isEqualTo(TAIL_BYTES);
    }
}
