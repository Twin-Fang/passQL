import 'package:flutter/cupertino.dart';
import '../../design/design.dart';

/// SSE 선택지 생성 중 로딩 상태. 스피너 + 상태 메시지.
class SseLoadingWidget extends StatelessWidget {
  final String statusMessage;

  const SseLoadingWidget({super.key, this.statusMessage = '선택지 생성 중...'});

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PqSpace.md,
        vertical: PqSpace.xs,
      ),
      child: PqCard(
        child: Row(
          children: [
            const CupertinoActivityIndicator(),
            const SizedBox(width: PqSpace.sm),
            Expanded(
              child: Text(
                statusMessage,
                style: PqType.subheadline.copyWith(color: c.secondaryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
