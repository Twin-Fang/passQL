import 'package:flutter/material.dart';

import '../../design/design.dart';
import '../../widgets/settings/business_info_group.dart';

/// 사업자 정보 화면 (#658): 설정 > 정보 > 사업자 정보
class BusinessInfoPage extends StatelessWidget {
  const BusinessInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PassqlNavBar(
        title: '사업자 정보',
        leading: PassqlNavLeading.back,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.md),
          children: const [BusinessInfoGroup()],
        ),
      ),
    );
  }
}
