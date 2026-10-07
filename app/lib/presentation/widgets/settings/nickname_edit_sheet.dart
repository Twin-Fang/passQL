import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/text_styles.dart';
import '../../../core/validation/nickname_validator.dart';
import '../../providers/settings_providers.dart';

/// 닉네임 직접 변경 바텀시트.
///
/// 형식 검증 → 중복 확인 → 저장 순서로 진행한다. 서버가 거절하면(쿨다운 등)
/// 서버 메시지를 그대로 보여준다. 저장에 성공하면 true 를 반환하며 닫힌다.
class NicknameEditSheet extends ConsumerStatefulWidget {
  const NicknameEditSheet({super.key, required this.currentNickname});

  final String currentNickname;

  static Future<bool?> show(BuildContext context, String currentNickname) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => NicknameEditSheet(currentNickname: currentNickname),
    );
  }

  @override
  ConsumerState<NicknameEditSheet> createState() => _NicknameEditSheetState();
}

class _NicknameEditSheetState extends ConsumerState<NicknameEditSheet> {
  late final TextEditingController _controller;

  /// 중복 확인을 통과한 닉네임. 입력이 바뀌면 다시 확인해야 하므로 값을 함께 기억한다.
  String? _verified;
  bool _checking = false;
  bool _saving = false;
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _value => _controller.text.trim();

  bool get _canCheck =>
      NicknameValidator.isValid(_value) &&
      _value != widget.currentNickname &&
      !_checking &&
      !_saving;

  bool get _canSave => _verified == _value && !_saving;

  void _setMessage(String? message, {bool error = false}) {
    _message = message;
    _messageIsError = error;
  }

  Future<void> _check() async {
    final nickname = _value;
    setState(() {
      _checking = true;
      _setMessage(null);
    });
    try {
      final available = await ref
          .read(nicknameNotifierProvider.notifier)
          .isAvailable(nickname);
      if (!mounted) return;
      setState(() {
        _verified = available ? nickname : null;
        _setMessage(
          available ? '사용 가능한 닉네임이에요' : '이미 사용 중인 닉네임이에요',
          error: !available,
        );
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _setMessage(e.message, error: true));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _setMessage(null);
    });
    try {
      await ref.read(nicknameNotifierProvider.notifier).change(_value);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      // 쿨다운(NICKNAME_COOLDOWN) 등 서버 거절 사유가 그대로 보인다.
      if (!mounted) return;
      setState(() {
        _saving = false;
        _setMessage(e.message, error: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatError = NicknameValidator.validate(_value);
    final hint = formatError ?? _message;
    final hintIsError = formatError != null || _messageIsError;

    return Padding(
      // 키보드가 올라와도 입력창이 가려지지 않게 한다.
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('닉네임 변경', style: AppTextStyles.heading_24),
          const SizedBox(height: 4),
          Text(
            '변경 후 3일간은 다시 바꿀 수 없어요',
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLength: NicknameValidator.maxLength,
                  onChanged: (_) => setState(() {
                    // 확인한 값과 달라지면 이전 결과 안내는 지운다.
                    if (_verified != _value) _setMessage(null);
                  }),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '한글, 영문, 숫자 2~10자',
                    filled: true,
                    fillColor: AppColors.pageBg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.borderDefault,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.borderDefault,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _canCheck ? _check : null,
                  // 앱 테마의 최소 폭이 무한대(Size.fromHeight)라 가로 Row 안에서 레이아웃이 깨진다.
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(88, 48),
                  ),
                  child: _checking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('중복확인'),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 28,
            child: Align(
              alignment: Alignment.centerLeft,
              child: hint == null
                  ? null
                  : Text(
                      hint,
                      style: AppTextStyles.tag_12.copyWith(
                        color: hintIsError
                            ? AppColors.red
                            : AppColors.brandIndigo,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _canSave ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandIndigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('저장'),
            ),
          ),
        ],
      ),
    );
  }
}
