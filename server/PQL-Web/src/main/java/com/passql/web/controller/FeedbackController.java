package com.passql.web.controller;

import com.passql.application.feedback.FeedbackSubmitService;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.meta.dto.FeedbackSubmitRequest;
import com.passql.meta.dto.FeedbackSubmitResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/feedback")
@RequiredArgsConstructor
public class FeedbackController implements FeedbackControllerDocs {

    private final FeedbackSubmitService feedbackSubmitService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public FeedbackSubmitResponse submit(
        @AuthMember LoginMember loginMember,
        @RequestPart("request") FeedbackSubmitRequest request,
        @RequestPart(value = "images", required = false) List<MultipartFile> images,
        @RequestPart(value = "diagnostics", required = false) MultipartFile diagnostics,
        @RequestPart(value = "log", required = false) MultipartFile logFile
    ) {
        return feedbackSubmitService.submit(loginMember.memberUuid(), request, images, diagnostics, logFile);
    }
}
