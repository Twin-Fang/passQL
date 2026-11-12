import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/network/dio_client.dart';

/// 두 진입점(main·lockScreenMain) 공통 시작 준비: .env > 서버 주소 확인 > Firebase
/// 서버 주소 누락은 첫 요청이 아니라 시작 시점에 실패
Future<void> prepareAppEnvironment() async {
  await dotenv.load(fileName: '.env');
  readBackendBaseUrl();
  // google-services.json / GoogleService-Info.plist 의 설정으로 초기화 (같은 프로세스 두 번째 엔진이면 기존 앱 재사용)
  await Firebase.initializeApp();
}
