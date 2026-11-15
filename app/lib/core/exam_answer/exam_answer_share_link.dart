/// 가채점 공유 링크 원본 (#1075): 소개 사이트 회차 페이지 (설계 `/sqld/63/`)
abstract final class ExamAnswerShareLink {
  // 소개 사이트 주소 (CORS 허용 origin 과 같은 값, 서버 설계 문서 참조)
  static const String introSiteOrigin = 'https://passql.suhsaechan.kr';

  /// 회차 페이지: https://passql.suhsaechan.kr/sqld/63/
  static String roundPageOf(String certType, int roundNumber) =>
      '$introSiteOrigin/${certType.toLowerCase()}/$roundNumber/';

  /// 이미지에 적는 짧은 주소: passql.suhsaechan.kr/sqld/63 (scheme·끝 / 제외)
  static String displayRoundPageOf(String certType, int roundNumber) =>
      roundPageOf(
        certType,
        roundNumber,
      ).replaceFirst(RegExp(r'^https?://'), '').replaceFirst(RegExp(r'/$'), '');
}
