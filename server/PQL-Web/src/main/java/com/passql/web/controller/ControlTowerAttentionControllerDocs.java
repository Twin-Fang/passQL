package com.passql.web.controller;

import com.passql.application.controltower.ControlTowerAttentionResponse;
import com.passql.common.dto.Author;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

@Tag(name = "ControlTower", description = "관제소 확인할 일 연동 (attention v1)")
public interface ControlTowerAttentionControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.11.08", author = Author.SUHSAECHAN, issueNumber = 959, description = "관제소 확인할 일 수집 엔드포인트 추가: 새 의견·확인 중 의견 개수"),
    })
    @Operation(
        summary = "관제소 확인할 일 스냅샷 (관제소 pull 수집)",
        description = """
            ## 인증(JWT): **없음** (관제소가 호출, `X-Control-Token` 헤더로 검증)

            관제소(suh-project-control) attention v1 규격 스냅샷. 관제소 관리 화면에 이 주소를 pull 소스로 등록한다.
            토큰 = 설정 `control-tower.attention.token` (교체 중에는 `token-previous` 도 허용), 상수 시간 비교

            ## 항목 (0건이어도 항상 포함)
            - `feedback.new` 새 의견 (PENDING 개수, `total` = 전체 의견 수)
            - `feedback.in_progress` 확인 중 의견 (REVIEWED 개수)
            - 수준: 0건 `ok`, 1건 이상 `info`

            ## 에러코드
            - **`RESOURCE_NOT_FOUND`** (404): 연동 꺼짐 (`control_tower.attention.enabled`)
            - **`UNAUTHORIZED`** (401): 토큰 없음·불일치, 서버에 토큰 미설정
            """
    )
    ResponseEntity<ControlTowerAttentionResponse> getAttention(String presentedToken);
}
