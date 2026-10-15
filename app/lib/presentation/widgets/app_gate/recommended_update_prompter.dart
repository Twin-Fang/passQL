import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/external_url_launcher.dart';
import '../../design/design.dart';
import '../../providers/app_config_providers.dart';

/// 권장 업데이트 안내: 탭 쉘 첫 진입 시 1회, 같은 권장 버전은 다시 안 띄움
/// 업데이트 > 스토어 이동, 나중에 > 닫기 (둘 다 기록)
class RecommendedUpdatePrompter extends ConsumerStatefulWidget {
  const RecommendedUpdatePrompter({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RecommendedUpdatePrompter> createState() =>
      _RecommendedUpdatePrompterState();
}

class _RecommendedUpdatePrompterState
    extends ConsumerState<RecommendedUpdatePrompter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _promptIfNeeded());
  }

  Future<void> _promptIfNeeded() async {
    final String? recommendedVersion;
    try {
      recommendedVersion = await ref.read(
        recommendedUpdateVersionToPromptProvider.future,
      );
    } catch (error) {
      debugPrint('[recommended update] check failed : $error');
      return;
    }
    if (recommendedVersion == null || !mounted) return;

    // 다시 안 띄우도록 먼저 기록 (안내 도중 앱 종료 포함)
    await saveRecommendedUpdatePrompted(recommendedVersion);
    if (!mounted) return;
    final decision = ref.read(appLaunchDecisionProvider).valueOrNull;
    final storeUrl = decision?.versionPolicy.storeUrl;
    final hasStoreUrl = storeUrl != null && storeUrl.isNotEmpty;
    final isUpdateChosen = await showPassqlConfirmDialog(
      context,
      title: '새 버전이 나왔어요',
      message: hasStoreUrl
          ? '더 나아진 passQL 을 최신 버전 $recommendedVersion 에서 만나 보세요.'
          : '스토어에서 passQL 최신 버전 $recommendedVersion 으로 업데이트할 수 있어요.',
      confirmLabel: hasStoreUrl ? '업데이트' : '확인',
      cancelLabel: '나중에',
      isDestructive: false,
    );
    if (isUpdateChosen && hasStoreUrl) await launchExternalUrl(storeUrl);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
