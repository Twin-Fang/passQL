import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/external_url_launcher.dart';
import '../../providers/app_config_providers.dart';
import '../../widgets/app_gate/launch_blocking_view.dart';

/// 강제 업데이트 차단 화면: 최소 버전 미만이면 업데이트 전까지 앱 사용 불가
/// 스토어 링크가 없으면 버튼 대신 스토어 검색 안내
class ForceUpdatePage extends ConsumerWidget {
  const ForceUpdatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decision = ref.watch(appLaunchDecisionProvider).valueOrNull;
    final storeUrl = decision?.versionPolicy.storeUrl;
    final hasStoreUrl = storeUrl != null && storeUrl.isNotEmpty;
    return LaunchBlockingView(
      icon: CupertinoIcons.arrow_down_circle_fill,
      title: '업데이트가 필요해요',
      message: hasStoreUrl
          ? '새 버전이 나왔어요.\n최신 버전으로 업데이트한 뒤 이용해 주세요.'
          : '새 버전이 나왔어요.\n스토어에서 passQL 을 검색해 업데이트해 주세요.',
      detail: decision == null
          ? null
          : '현재 버전 ${decision.currentVersion} · 필요 버전 ${decision.versionPolicy.minimumVersion} 이상',
      actionLabel: hasStoreUrl ? '업데이트하기' : null,
      onActionPressed: hasStoreUrl ? () => launchExternalUrl(storeUrl) : null,
    );
  }
}
