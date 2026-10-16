import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/error/error_code.dart';

/// 에러 코드 계약 검사: 앱 매핑 서버 코드 <-> api-contract/openapi.json ErrorCode enum (#458)
/// 서버에서 코드 이름이 바뀌거나 지워지면 앱 분기가 조용히 unknown 으로 떨어지는 것 차단

// flutter test 실행 위치(app/) 기준 레포 루트 계약 파일
const _contractFilePath = '../api-contract/openapi.json';

void main() {
  test('앱이 매핑한 서버 코드는 모두 서버 ErrorCode 에 있다', () {
    final contract =
        jsonDecode(File(_contractFilePath).readAsStringSync())
            as Map<String, dynamic>;
    final schemas =
        (contract['components'] as Map<String, dynamic>)['schemas']
            as Map<String, dynamic>;
    final serverErrorCodes =
        ((schemas['ErrorCode'] as Map<String, dynamic>)['enum']
                as List<dynamic>)
            .cast<String>()
            .toSet();

    final unknownToServer = ErrorCodeMapper.mappedServerCodes
        .where((code) => !serverErrorCodes.contains(code))
        .toList();

    expect(
      unknownToServer,
      isEmpty,
      reason: '서버 ErrorCode 에 없는 코드: error_code.dart 매핑 정리 필요',
    );
  });
}
