import 'package:url_launcher/url_launcher.dart';

/// 외부 앱(스토어·브라우저)으로 링크 열기. 열지 못하면 false
Future<bool> launchExternalUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
