package com.passql.ai.dto;

/**
 * 생성 메타데이터(모델·토큰 수)를 함께 돌려주는 AI 서버 응답 (호출 기록이 모델·토큰을 채우는 기준, #557)
 */
public interface GenerationMetadataCarrier {

    /** 생성 메타데이터 (AI 서버가 보내지 않으면 null) */
    GenerationMetadataDto metadata();
}
