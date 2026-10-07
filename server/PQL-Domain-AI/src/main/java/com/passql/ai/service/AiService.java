package com.passql.ai.service;

import com.passql.ai.client.OllamaClient;
import com.passql.ai.client.QdrantSearchClient;
import com.passql.ai.dto.AiResult;
import com.passql.ai.dto.SimilarQuestion;
import com.passql.meta.service.PromptService;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class AiService {
    private final OllamaClient ollamaClient;
    private final QdrantSearchClient qdrantSearchClient;
    private final PromptService promptService;

    // 오류·선택지 해설은 AiExplainService(PQL-Application)로 옮겼다. 여기에는 유사 문제 검색만 남긴다.

    public List<SimilarQuestion> getSimilar(UUID questionUuid, int k) {
        throw new UnsupportedOperationException("TODO");
    }
}
