import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 회원 uuid > Play 계정 값 (소문자 하이픈 문자열 UTF-8 > SHA-256 소문자 hex 64자)
/// 서버 PlayBillingService.toObfuscatedAccountId 와 같은 계산 (다른 계정으로 구매 재전송 차단)
String toPlayObfuscatedAccountId(String memberUuid) =>
    sha256.convert(utf8.encode(memberUuid.toLowerCase())).toString();
