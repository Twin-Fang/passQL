import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/network/dio_client.dart';

void main() {
  test('BACKEND_BASE_URL 이 비어 있으면 시작 시 실패한다', () {
    dotenv.loadFromString(envString: 'BACKEND_BASE_URL=   ');
    expect(readBackendBaseUrl, throwsStateError);
  });

  test('BACKEND_BASE_URL 이 있으면 그 값을 쓴다', () {
    dotenv.loadFromString(
      envString: 'BACKEND_BASE_URL=https://example.test/api',
    );
    expect(readBackendBaseUrl(), 'https://example.test/api');
  });
}
