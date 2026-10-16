import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sources/api_providers.dart';
import '../../data/models/legal/legal_models.dart';

/// 약관 본문. 로그인 전에도 호출되는 공개 API 다.
/// 성공한 본문만 앱이 살아 있는 동안 캐시 (약관은 거의 안 바뀜, 실패는 다시 열면 재요청)
final legalDocumentProvider = FutureProvider.autoDispose
    .family<LegalDocument, LegalType>((ref, type) async {
      final document = await ref
          .read(metaApiProvider)
          .getLegal(type.serverValue);
      ref.keepAlive();
      return document;
    });
