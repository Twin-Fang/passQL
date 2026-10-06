import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_providers.dart';
import '../../data/models/legal/legal_models.dart';

/// 약관 본문. 화면을 벗어나면 해제된다. 로그인 전에도 호출되는 공개 API 다.
final legalDocumentProvider = FutureProvider.autoDispose
    .family<LegalDocument, LegalType>(
      (ref, type) => ref.read(metaApiProvider).getLegal(type.serverValue),
    );
