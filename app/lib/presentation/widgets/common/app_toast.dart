import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/text_styles.dart';

/// 앱 공통 토스트. 화면마다 SnackBar 스타일을 따로 만들지 않도록 한곳에 둔다.
void showAppToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.paragraph_14.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.toastBg,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}
