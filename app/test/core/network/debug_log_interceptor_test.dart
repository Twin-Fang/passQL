import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/network/debug_log_interceptor.dart';

/// 요청 1건을 로그 인터셉터에 통과시키고 찍힌 줄 모음
List<String> _loggedLinesOf(String path, Map<String, String> body) {
  final loggedLines = <String>[];
  DebugLogInterceptor(
    logPrint: (object) => loggedLines.add('$object'),
  ).onRequest(
    RequestOptions(
      baseUrl: 'https://api.example.com/api',
      path: path,
      method: 'POST',
      data: body,
    ),
    RequestInterceptorHandler(),
  );
  return loggedLines;
}

void main() {
  test('billingRequest_hidesPurchaseTokenBody', () {
    final loggedText = _loggedLinesOf('/billing/play/verify', {
      'purchaseToken': 'secret-purchase-token',
    }).join('\n');

    expect(loggedText, contains('/billing/play/verify'));
    expect(loggedText, isNot(contains('secret-purchase-token')));
  });

  test('otherRequest_keepsBody', () {
    final loggedText = _loggedLinesOf('/questions/q1/submit', {
      'selectedChoiceKey': 'A',
    }).join('\n');

    expect(loggedText, contains('selectedChoiceKey'));
  });
}
