/// 불러오기 실패 문구 원본: '…을 불러오지 못했어요'(마침표 없음) + '다시 시도' 한 형태로 통일 (#995)
/// 상태 뷰·목록 끝 실패 줄·인라인 다시 시도 줄이 이 값을 씀
abstract final class PassqlLoadFailureCopy {
  // 실패 상태 다시 받기 버튼
  static const String retryLabel = '다시 시도';

  // 목록 끝 다음 페이지 다시 받기 버튼
  static const String reloadLabel = '다시 불러오기';

  // 목록 끝 다음 페이지 받기 실패 안내
  static const String loadMoreFailedMessage = '더 불러오지 못했어요';

  // 대상을 특정하지 않는 실패 안내
  static const String genericMessage = '불러오지 못했어요';

  /// 대상(조사 포함) > 실패 문구: '공지를' > '공지를 불러오지 못했어요'
  static String messageOf(String targetWithParticle) =>
      '$targetWithParticle 불러오지 못했어요';
}
