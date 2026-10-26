import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';
part 'app_config.g.dart';

/// 플랫폼 1개의 버전 정책: 최소 버전(미만 차단), 권장 버전(미만 안내), 스토어 링크
@freezed
class AppPlatformVersionPolicy with _$AppPlatformVersionPolicy {
  const factory AppPlatformVersionPolicy({
    @Default('0.0.0') String minimumVersion,
    @Default('0.0.0') String recommendedVersion,
    String? storeUrl,
  }) = _AppPlatformVersionPolicy;

  factory AppPlatformVersionPolicy.fromJson(Map<String, dynamic> json) =>
      _$AppPlatformVersionPolicyFromJson(json);
}

/// 점검 상태: 점검 여부, 관리자 문구(비면 앱 기본 문구)
@freezed
class AppMaintenanceStatus with _$AppMaintenanceStatus {
  const factory AppMaintenanceStatus({
    @Default(false) bool isUnderMaintenance,
    @Default('') String message,
  }) = _AppMaintenanceStatus;

  factory AppMaintenanceStatus.fromJson(Map<String, dynamic> json) =>
      _$AppMaintenanceStatusFromJson(json);
}

/// 관리자가 등록한 공지 1건 (본문은 마크다운 일부: 굵게·목록·링크)
/// publishedAt: 게시 시각 = 노출 시작, 없으면 등록 시각 (KST, 구버전 서버 응답이면 null)
@freezed
class AppNotice with _$AppNotice {
  const factory AppNotice({
    required String noticeUuid,
    required String title,
    required String body,
    @Default(false) bool isImportant,
    DateTime? publishedAt,
  }) = _AppNotice;

  factory AppNotice.fromJson(Map<String, dynamic> json) =>
      _$AppNoticeFromJson(json);
}

/// 사업자 정보 표기 (#658): 서버 app_setting business.* 원본, 빈 값은 null
/// companyName 이 null 이면 섹션 숨김 (구버전 서버·조회 실패도 같음)
@freezed
class BusinessInfo with _$BusinessInfo {
  const factory BusinessInfo({
    String? companyName,
    String? representativeName,
    String? registrationNumber,
    String? contactEmail,
    String? mailOrderSalesNumber,
  }) = _BusinessInfo;

  factory BusinessInfo.fromJson(Map<String, dynamic> json) =>
      _$BusinessInfoFromJson(json);
}

/// 앱 시작 시 1회 받는 운영 설정 (GET /meta/app-config)
@freezed
class AppConfig with _$AppConfig {
  const factory AppConfig({
    @Default(AppPlatformVersionPolicy()) AppPlatformVersionPolicy ios,
    @Default(AppPlatformVersionPolicy()) AppPlatformVersionPolicy android,
    @Default(AppMaintenanceStatus()) AppMaintenanceStatus maintenance,
    @Default([]) List<AppNotice> notices,
    // 서버 결제 스위치 (false 면 잠금·칩·시트를 그리지 않음)
    @Default(false) bool isAndroidBillingEnabled,
    // 사업자 정보 (구버전 서버면 빈 값 > 섹션 숨김)
    @Default(BusinessInfo()) BusinessInfo businessInfo,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);
}
