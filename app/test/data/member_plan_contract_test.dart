import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';

/// 등급 계약 검사: 앱 MemberPlanType 와이어 값 <-> api-contract/openapi.json MemberPlanResponse.plan enum (#791)
/// 서버가 등급 이름을 바꾸면 앱이 조용히 무료로 떨어지는 것 차단 (새 값 추가는 unknownEnumValue 로 허용)

// flutter test 실행 위치(app/) 기준 레포 루트 계약 파일
const _contractFilePath = '../api-contract/openapi.json';

void main() {
  test('앱 등급 값은 모두 서버 계약 MemberPlan enum 에 있다', () {
    final contract =
        jsonDecode(File(_contractFilePath).readAsStringSync())
            as Map<String, dynamic>;
    final schemas =
        (contract['components'] as Map<String, dynamic>)['schemas']
            as Map<String, dynamic>;
    final planProperty =
        ((schemas['MemberPlanResponse'] as Map<String, dynamic>)['properties']
                as Map<String, dynamic>)['plan']
            as Map<String, dynamic>;
    final serverPlanValues = (planProperty['enum'] as List<dynamic>)
        .cast<String>()
        .toSet();

    // 앱 enum > 직렬화 문자열 (JsonValue 원본 그대로)
    final appPlanValues = MemberPlanType.values
        .map((plan) => MemberPlanResponse(plan: plan).toJson()['plan'] as String)
        .toSet();

    expect(
      appPlanValues.difference(serverPlanValues),
      isEmpty,
      reason: '서버 계약에 없는 등급 값: member_plan_response.dart 정리 필요',
    );
  });

  test('계약에 없는 등급 값은 무료로 읽는다', () {
    final planResponse = MemberPlanResponse.fromJson({'plan': 'ENTERPRISE'});
    expect(planResponse.plan, MemberPlanType.free);
  });
}
