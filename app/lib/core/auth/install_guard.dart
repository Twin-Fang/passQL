import 'package:shared_preferences/shared_preferences.dart';

import 'token_store.dart';

/// 앱을 지웠다가 다시 설치한 경우 이전 로그인이 되살아나지 않게 한다.
///
/// iOS 키체인(보안 저장소)은 앱을 삭제해도 남는 것이 기본 동작이라, 재설치하면 이전 계정이
/// 자동 로그인되고 약관 안내도 건너뛴다. 일반 설정 저장소는 앱 삭제와 함께 지워지므로
/// "이 설치에서 처음 실행인가"의 표식으로 쓴다. 표식이 없는데 토큰이 남아 있으면 새 설치로 보고 지운다.
Future<void> resetSecureStorageOnFreshInstall(TokenStore store) async {
  const marker = 'install_initialized';
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(marker) ?? false) return;

  await store.clear();
  await prefs.setBool(marker, true);
}
