package com.passql.web.controller.admin;

import com.passql.application.questionformat.dto.QuestionFormatFixApplyRequest;
import com.passql.application.questionformat.dto.QuestionFormatFixApplyResult;
import com.passql.application.questionformat.dto.QuestionFormatFixPreview;
import com.passql.common.dto.Author;
import com.passql.question.dto.AdminQuestionFormatCheckRequest;
import com.passql.question.dto.AdminQuestionFormatCheckResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

import java.util.List;

@Tag(name = "Admin - QuestionFormat", description = "관리자 문항 형식 규칙 검사·자동 정리 (관리자 세션, #905)")
public interface AdminQuestionFormatApiControllerDocs {

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 905, description = "문항 저장 전 형식 검사 API 추가")})
    @Operation(summary = "저장 전 형식 검사", description = "등록·편집·AI 생성 검수 화면이 저장 전에 호출. 새 문항은 위반 전부, 편집은 저장본에 없던 사유만 저장을 막음")
    ResponseEntity<AdminQuestionFormatCheckResponse> checkBeforeSave(AdminQuestionFormatCheckRequest request);

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 905, description = "형식 자동 정리 미리보기 API 추가")})
    @Operation(summary = "자동 정리 미리보기", description = "활성 문제 중 바뀌는 문제만: 스키마와 같은 지문 표 삭제, 개념형 지문 표 > 스키마 표, 목록 기호·줄표(보기 글·세트 해설 포함). 필드 전후 전문")
    ResponseEntity<List<QuestionFormatFixPreview>> previewAutoFix();

    @ApiLogs({@ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 905, description = "형식 자동 정리 적용 API 추가")})
    @Operation(summary = "자동 정리 적용", description = "고른 문제만. 서버가 정리 내용을 다시 계산해 적용, 문제마다 감사 로그, 지문이 바뀌면 추천 색인 다시 적재")
    ResponseEntity<QuestionFormatFixApplyResult> applyAutoFix(QuestionFormatFixApplyRequest request);
}
