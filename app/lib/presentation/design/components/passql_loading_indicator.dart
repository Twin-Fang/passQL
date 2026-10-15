import 'package:flutter/cupertino.dart';

import '../tokens/passql_tokens.dart';

/// 로딩 표시가 놓이는 자리 3종: 버튼·행 안, 섹션·시트·상태 화면, 화면 잠금
enum PassqlLoadingSize { inline, section, blocking }

/// 앱의 모든 로딩 스피너. 화면에서 CupertinoActivityIndicator 를 직접 쓰지 않는다.
class PassqlLoadingIndicator extends StatelessWidget {
  const PassqlLoadingIndicator({
    super.key,
    this.size = PassqlLoadingSize.inline,
    this.color,
  });

  final PassqlLoadingSize size;

  /// 없으면 테마 기본색. 채운 버튼 위처럼 배경 대비가 필요할 때만 지정
  final Color? color;

  double get _radius => switch (size) {
    PassqlLoadingSize.inline => PassqlSize.loadingIndicatorInlineRadius,
    PassqlLoadingSize.section => PassqlSize.loadingIndicatorSectionRadius,
    PassqlLoadingSize.blocking => PassqlSize.loadingIndicatorBlockingRadius,
  };

  @override
  Widget build(BuildContext context) =>
      CupertinoActivityIndicator(radius: _radius, color: color);
}
