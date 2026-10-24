package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.member.constant.PushLinkTarget;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

/** 관리자 푸시 템플릿: 이름, 제목, 본문, 이동 경로 (대상·전달 방식은 발송 때 고름) */
@Entity
@Table(
    name = "push_template",
    uniqueConstraints = @UniqueConstraint(name = "uk_push_template_name", columnNames = "name")
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PushTemplate extends BaseEntity {

    // 템플릿 이름 최대 길이 (문자 수)
    public static final int MAX_NAME_LENGTH = 50;

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID pushTemplateUuid;

    @Column(length = MAX_NAME_LENGTH, nullable = false)
    private String name;

    @Column(length = PushSendHistory.MAX_TITLE_LENGTH, nullable = false)
    private String title;

    @Column(length = PushSendHistory.MAX_BODY_LENGTH, nullable = false)
    private String body;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private PushLinkTarget linkTarget;

    // linkTarget QUESTION_DETAIL 일 때만 값
    private UUID linkQuestionUuid;

    public static PushTemplate of(String name, String title, String body, PushLinkTarget linkTarget, UUID linkQuestionUuid) {
        PushTemplate template = new PushTemplate();
        template.update(name, title, body, linkTarget, linkQuestionUuid);
        return template;
    }

    /** 내용 전체 교체 (같은 이름으로 다시 저장하면 덮어쓰기) */
    public void update(String name, String title, String body, PushLinkTarget linkTarget, UUID linkQuestionUuid) {
        this.name = name;
        this.title = title;
        this.body = body;
        this.linkTarget = linkTarget;
        this.linkQuestionUuid = linkQuestionUuid;
    }
}
