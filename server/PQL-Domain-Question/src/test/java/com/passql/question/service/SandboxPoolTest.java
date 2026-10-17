package com.passql.question.service;

import com.passql.meta.service.AppSettingService;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;

/**
 * 임시 샌드박스 공통 진입점 고정: 획득 > 작업 > 반납 (작업 실패 시에도 반납)
 */
class SandboxPoolTest {

    @Test
    void 작업이_성공하면_결과를_돌려주고_반납한다() {
        SandboxPool sandboxPool = spyPoolReturning("sandbox_1");

        String taskResult = sandboxPool.runWithTemporaryDatabase(dbName -> "ran on " + dbName);

        assertThat(taskResult).isEqualTo("ran on sandbox_1");
        verify(sandboxPool).release("sandbox_1");
    }

    @Test
    void 작업이_실패해도_반납한다() {
        SandboxPool sandboxPool = spyPoolReturning("sandbox_2");

        assertThatThrownBy(() -> sandboxPool.runWithTemporaryDatabase(dbName -> {
            throw new IllegalStateException("task failed");
        })).isInstanceOf(IllegalStateException.class);
        verify(sandboxPool).release("sandbox_2");
    }

    /** DB 없이 획득·반납만 대체한 풀 */
    private SandboxPool spyPoolReturning(String dbName) {
        SandboxPool sandboxPool = spy(new SandboxPool(mock(AppSettingService.class)));
        doReturn(dbName).when(sandboxPool).acquire();
        doNothing().when(sandboxPool).release(dbName);
        return sandboxPool;
    }
}
