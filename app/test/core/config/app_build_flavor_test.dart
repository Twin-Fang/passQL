import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/config/app_build_flavor.dart';

/// 개발자 도구 노출 판정 (#809): 운영 빌드는 .env 값과 무관하게 꺼짐
void main() {
  test('운영 빌드는 .env 가 true 여도 보이지 않는다', () {
    expect(
      AppBuildFlavor.isDevToolsVisible(
        canUseDevTools: false,
        showDevToolsEnvValue: 'true',
      ),
      isFalse,
    );
  });

  test('개발 빌드는 .env 가 true 일 때만 보인다', () {
    expect(
      AppBuildFlavor.isDevToolsVisible(
        canUseDevTools: true,
        showDevToolsEnvValue: ' TRUE ',
      ),
      isTrue,
    );
    expect(
      AppBuildFlavor.isDevToolsVisible(
        canUseDevTools: true,
        showDevToolsEnvValue: null,
      ),
      isFalse,
    );
    expect(
      AppBuildFlavor.isDevToolsVisible(
        canUseDevTools: true,
        showDevToolsEnvValue: 'false',
      ),
      isFalse,
    );
  });
}
