package com.passql.meta.service;

import com.passql.meta.entity.ServerErrorLog;
import com.passql.meta.repository.ServerErrorLogRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 오류 기록은 요청 처리에 절대 영향을 주면 안 되고, 긴 값은 컬럼 길이 안으로 자른다 (#440). */
class ServerErrorLogServiceTest {

    private final ServerErrorLogRepository repository = mock(ServerErrorLogRepository.class);
    private final ServerErrorLogService service = new ServerErrorLogService(repository);

    @Test
    void 긴_URI와_원인은_잘라서_저장한다() {
        service.record("rid00001", "abcd1234", "GET", "/api/" + "x".repeat(600), 500, "e".repeat(5000));

        ArgumentCaptor<ServerErrorLog> saved = ArgumentCaptor.forClass(ServerErrorLog.class);
        verify(repository).save(saved.capture());
        assertThat(saved.getValue().getUri()).hasSize(ServerErrorLogService.MAX_URI);
        assertThat(saved.getValue().getDetail()).hasSize(ServerErrorLogService.MAX_DETAIL);
        assertThat(saved.getValue().getStatus()).isEqualTo(500);
        assertThat(saved.getValue().getOccurredAt()).isNotNull();
    }

    @Test
    void 저장에_실패해도_예외를_던지지_않는다() {
        when(repository.save(any())).thenThrow(new RuntimeException("db down"));

        assertThatCode(() -> service.record("rid00001", null, "GET", "/api/x", 500, null))
                .doesNotThrowAnyException();
    }
}
