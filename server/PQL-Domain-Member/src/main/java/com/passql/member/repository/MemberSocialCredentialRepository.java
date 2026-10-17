package com.passql.member.repository;

import com.passql.member.entity.MemberSocialCredential;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface MemberSocialCredentialRepository extends JpaRepository<MemberSocialCredential, UUID> {
}
