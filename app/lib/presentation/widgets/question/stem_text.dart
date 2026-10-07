import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_colors.dart';
import '../../../core/text_styles.dart';

/// 지문 안의 ```lang ... ``` 블록 분리용 정규식.
final RegExp _fenceRe = RegExp(r'```[A-Za-z]*\r?\n?([\s\S]*?)```');

/// 목록 미리보기용: 코드 펜스(```sql, ```)와 인라인 백틱을 걷어내고 내용은 한 줄로 합친다.
/// 잘린 미리보기는 닫는 펜스가 없을 수 있어 남은 ``` 도 함께 지운다.
String stripCodeFences(String text) {
  return text
      .replaceAll(RegExp(r'```[A-Za-z]*'), '')
      .replaceAll('`', '')
      .replaceAll(RegExp(r'\s*\n\s*'), ' ')
      .trim();
}

/// 문제 지문. 코드 펜스 구간은 고정폭 코드 박스로, 나머지는 일반 글로 그린다.
class StemText extends StatelessWidget {
  const StemText(this.stem, {super.key});

  final String stem;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    var cursor = 0;

    void addText(String raw) {
      final t = raw.trim();
      if (t.isEmpty) return;
      children.add(InlineCodeText(t));
    }

    for (final m in _fenceRe.allMatches(stem)) {
      addText(stem.substring(cursor, m.start));
      children.add(_CodeBox(code: (m.group(1) ?? '').trimRight()));
      cursor = m.end;
    }
    addText(stem.substring(cursor));

    // 펜스가 하나도 없으면 기존과 같은 한 덩어리 글
    if (children.isEmpty) return const SizedBox.shrink();

    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) spaced.add(SizedBox(height: 12.h));
      spaced.add(children[i]);
    }
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: spaced,
      ),
    );
  }
}

/// 긴 줄이 가로로 잘려 보이지 않도록 줄바꿈한다. 첫 줄 들여쓰기는 그대로 둔다.
class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.black100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        code,
        style: AppTextStyles.paragraph_14.copyWith(
          color: AppColors.textPrimary,
          fontFamily: 'JetBrainsMono',
          fontSize: 12.sp,
          height: 1.5,
        ),
      ),
    );
  }
}

/// 인라인 코드(`키워드`)를 고정폭 + 연한 배경으로 강조하는 일반 글.
/// 백틱은 표시하지 않는다. 짝이 맞지 않는 백틱은 글자 그대로 둔다.
class InlineCodeText extends StatelessWidget {
  const InlineCodeText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  static final RegExp _inlineRe = RegExp(r'`([^`\n]+)`');

  @override
  Widget build(BuildContext context) {
    final base =
        style ??
        AppTextStyles.paragraph_14.copyWith(color: AppColors.textPrimary);
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final m in _inlineRe.allMatches(text)) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, m.start)));
      }
      spans.add(
        TextSpan(
          text: m.group(1),
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: (base.fontSize ?? 14) * 0.92,
            backgroundColor: AppColors.black100,
          ),
        ),
      );
      cursor = m.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return Text.rich(TextSpan(style: base, children: spans));
  }
}
