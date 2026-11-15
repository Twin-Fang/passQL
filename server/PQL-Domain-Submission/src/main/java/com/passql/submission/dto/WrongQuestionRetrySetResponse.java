package com.passql.submission.dto;

import java.util.List;
import java.util.UUID;

/** 오답 다시 풀기 묶음: 정리 안 된 오답을 많이 틀린 순으로 최대 10개 (#1081) */
public record WrongQuestionRetrySetResponse(
    List<UUID> questionUuids
) {}
