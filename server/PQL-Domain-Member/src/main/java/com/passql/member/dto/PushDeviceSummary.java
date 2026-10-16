package com.passql.member.dto;

/** 회원의 푸시 기기 현황 (관리자 회원 상세): 등록 기기 수, 수신 동의 기기 수 */
public record PushDeviceSummary(long registeredDeviceCount, long pushEnabledDeviceCount) {
}
